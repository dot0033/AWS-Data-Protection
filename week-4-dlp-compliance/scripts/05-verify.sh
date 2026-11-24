#!/usr/bin/env bash
# Checks the controls on the sample bucket and the scan result.
source "$(dirname "$0")/00-env.sh"
pass=0; fail=0
ok()  { echo "PASS  $1"; pass=$((pass+1)); }
bad() { echo "FAIL  $1"; fail=$((fail+1)); }
aws s3api head-bucket --bucket "$BUCKET" >/dev/null 2>&1 && ok "Bucket exists" || bad "Bucket exists"
n=$(aws s3api get-public-access-block --bucket "$BUCKET" --output text --query 'PublicAccessBlockConfiguration.[BlockPublicAcls,IgnorePublicAcls,BlockPublicPolicy,RestrictPublicBuckets]' | grep -o True | wc -l)
[ "$n" = 4 ] && ok "Block Public Access: all 4 settings on" || bad "Block Public Access: all 4 settings on"
aws s3api get-bucket-encryption --bucket "$BUCKET" --query 'ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm' --output text | grep -q AES256 && ok "Default encryption (SSE-S3)" || bad "Default encryption (SSE-S3)"
aws s3api get-bucket-tagging --bucket "$BUCKET" --output text | grep -q restricted && ok "DataClassification=restricted tag" || bad "DataClassification=restricted tag"
[ -s "$OUT_DIR/pii-scan-findings.json" ] && grep -q '"objectsWithFindings": [1-9]' "$OUT_DIR/pii-scan-findings.json" && ok "Sensitive data discovered by scan" || bad "Sensitive data discovered by scan"
grep -q '"key": "public-faq.txt"' "$OUT_DIR/pii-scan-findings.json" && bad "No false positive on public-faq.txt" || ok "No false positive on public-faq.txt"
echo "Result: $pass passed, $fail failed" | tee "$OUT_DIR/05-verify-result.txt"
