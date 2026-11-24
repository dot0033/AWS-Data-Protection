#!/usr/bin/env python3
"""Sensitive data discovery for the Week 4 sample bucket.

Substitute for an Amazon Macie classification job (Macie returned
SubscriptionRequiredException on this account). It reads every object in the
bucket, runs Macie-style detectors (regex + Luhn check + nearby keywords) and
writes findings in a Macie-like JSON shape. Only masked values are stored.
"""
import json, os, re, sys, datetime, boto3

BUCKET = sys.argv[1]
OUT = os.path.expanduser(os.environ.get("OUT_DIR", "~/w4-evidence"))
os.makedirs(OUT, exist_ok=True)

def luhn(num):
    d = [int(x) for x in num][::-1]
    return sum(d[0::2] + [sum(divmod(2 * x, 10)) for x in d[1::2]]) % 10 == 0

def near(text, start, words, window=40):
    seg = text[max(0, start - window):start].lower()
    return any(w in seg for w in words)

# (type, category, regex, validator)
DETECTORS = [
    ("CREDIT_CARD_NUMBER", "FINANCIAL_INFORMATION", r"\b(?:\d[ -]?){13,19}\b",
     lambda t, m: luhn(re.sub(r"\D", "", m.group())) and near(t, m.start(), ["credit card", "card"])),
    ("USA_SOCIAL_SECURITY_NUMBER", "PERSONAL_INFORMATION", r"\b\d{3}-\d{2}-\d{4}\b",
     lambda t, m: near(t, m.start(), ["ssn", "social security"])),
    ("USA_PASSPORT_NUMBER", "PERSONAL_INFORMATION", r"\b\d{9}\b",
     lambda t, m: near(t, m.start(), ["passport"])),
    ("EMAIL_ADDRESS", "PERSONAL_INFORMATION", r"\b[\w.+-]+@[\w-]+\.[\w.]+\b", None),
    ("PHONE_NUMBER", "PERSONAL_INFORMATION", r"\(\d{3}\) \d{3}-\d{4}", None),
    ("DATE_OF_BIRTH", "PERSONAL_INFORMATION", r"\b\d{4}-\d{2}-\d{2}\b",
     lambda t, m: near(t, m.start(), ["date of birth", "dob", "birth"])),
    ("AWS_CREDENTIALS", "CREDENTIALS", r"\b(?:AKIA[0-9A-Z]{16}|[A-Za-z0-9/+]{40})\b",
     lambda t, m: near(t, m.start(), ["aws_access_key_id", "aws_secret_access_key"])),
]
SEVERITY = {"CREDENTIALS": "High", "FINANCIAL_INFORMATION": "High", "PERSONAL_INFORMATION": "Medium"}
ORDER = ["Low", "Medium", "High"]

def mask(v):
    v = v.strip()
    return v[:2] + "*" * max(len(v) - 4, 0) + v[-2:] if len(v) > 4 else "****"

s3 = boto3.client("s3")
findings, scanned = [], 0
for page in s3.get_paginator("list_objects_v2").paginate(Bucket=BUCKET):
    for obj in page.get("Contents", []):
        key = obj["Key"]
        text = s3.get_object(Bucket=BUCKET, Key=key)["Body"].read().decode("utf-8", "ignore")
        scanned += 1
        hits = {}
        for typ, cat, rx, ok in DETECTORS:
            for m in re.finditer(rx, text):
                if ok is None or ok(text, m):
                    h = hits.setdefault(typ, {"type": typ, "category": cat, "count": 0, "maskedExamples": []})
                    h["count"] += 1
                    if len(h["maskedExamples"]) < 2:
                        h["maskedExamples"].append(mask(m.group()))
        if not hits:
            continue
        cats = {h["category"] for h in hits.values()}
        sev = max((SEVERITY[c] for c in cats), key=ORDER.index)
        ftype = "SensitiveData:S3Object/Multiple" if len(cats) > 1 else \
            "SensitiveData:S3Object/" + {"CREDENTIALS": "Credentials", "FINANCIAL_INFORMATION": "Financial",
                                         "PERSONAL_INFORMATION": "Personal"}[cats.pop()]
        findings.append({"type": ftype, "severity": sev, "bucket": BUCKET, "key": key,
                         "sizeBytes": obj["Size"], "detections": list(hits.values())})

report = {"generatedAt": datetime.datetime.now(datetime.timezone.utc).isoformat(),
          "tool": "06-pii-scan.py (Macie substitute)", "bucket": BUCKET,
          "objectsScanned": scanned, "objectsWithFindings": len(findings), "findings": findings}
acct = boto3.client("sts").get_caller_identity()["Account"]
out = json.dumps(report, indent=2).replace(acct, "<ACCOUNT_ID>")
open(os.path.join(OUT, "pii-scan-findings.json"), "w").write(out)
print(f"Scanned {scanned} objects, {len(findings)} with sensitive data")
for f in findings:
    print(f"  [{f['severity']:<6}] {f['type']:<36} {f['key']:<20} " +
          ", ".join(f"{d['type']}x{d['count']}" for d in f["detections"]))
