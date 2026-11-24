# Week 4 - Data in Use, DLP, Privacy & Compliance

**Status:** Complete within the documented lab scope. Amazon Macie and GuardDuty could not be enabled on this account (`SubscriptionRequiredException`), so a $0 substitute scanner and CloudTrail evidence were used. Scripts for the real services are included and ready to run.

## Tasks (from the project brief)

| Task | Delivered |
|------|-----------|
| Use Amazon Macie for sensitive data discovery | Macie job script `scripts/02-macie-scan.sh` (blocked by subscription); same discovery run with `scripts/06-pii-scan.py` on real S3 objects |
| GuardDuty for data threats | Design and runbook `docs/06-guardduty-data-threats.md`, script `scripts/03-guardduty.sh` (blocked by subscription), CloudTrail detection evidence |
| DLP strategies | `docs/02-dlp-plan.md` |
| GDPR / HIPAA / PCI DSS mapping | `docs/03-compliance-control-matrix.md` |
| Audit readiness | `docs/05-final-data-security-report.md` with evidence index |

## Deliverables

| Deliverable | File |
|-------------|------|
| Macie findings report | `docs/01-macie-findings-report.md` |
| DLP plan | `docs/02-dlp-plan.md` |
| Compliance control matrix | `docs/03-compliance-control-matrix.md` |
| Data protection risk register | `docs/04-data-protection-risk-register.md` |
| Final audit-ready data security report | `docs/05-final-data-security-report.md` |

## Lab results (2026-11-24, eu-central-1)

- Sample bucket: private, Block Public Access on, encrypted, tagged `restricted`, 4 synthetic files.
- Discovery scan: 4 objects scanned, 3 with sensitive data, 20 sensitive values, 0 false positives.
- Verification: 6 passed, 0 failed.
- CloudTrail recorded all 4 security configuration changes.
- Cleanup: bucket deleted, nothing left running. Cost about $0.00.

## Structure

```
week-4-dlp-compliance/
├── README.md
├── docs/
│   ├── 01-macie-findings-report.md
│   ├── 02-dlp-plan.md
│   ├── 03-compliance-control-matrix.md
│   ├── 04-data-protection-risk-register.md
│   ├── 05-final-data-security-report.md
│   ├── 06-guardduty-data-threats.md
│   └── progress-log.md
├── policies/            Macie access statements, custom identifier, EventBridge rule
├── sample-data/         synthetic test files (no real personal data)
├── scripts/
│   ├── 00-env.sh
│   ├── 01-create-sample-bucket.sh
│   ├── 02-macie-scan.sh          (needs Macie subscription)
│   ├── 03-guardduty.sh           (needs GuardDuty subscription)
│   ├── 04-export-findings.sh
│   ├── 05-verify.sh
│   ├── 06-pii-scan.py
│   ├── 07-cloudtrail-evidence.sh
│   └── 99-cleanup.sh
└── evidence/
```

## How to run

In AWS CloudShell (eu-central-1), from this folder:

```bash
bash scripts/01-create-sample-bucket.sh
python3 scripts/06-pii-scan.py dp-lab-w4-sample-$(aws sts get-caller-identity --query Account --output text)
bash scripts/07-cloudtrail-evidence.sh
bash scripts/05-verify.sh
# when Macie / GuardDuty are activated on the account:
bash scripts/02-macie-scan.sh
bash scripts/03-guardduty.sh
# always finish with:
bash scripts/99-cleanup.sh
```

## Notes

- All sample data is synthetic: card numbers are public test numbers and the AWS keys are the AWS documentation examples.
- Account IDs are replaced with `<ACCOUNT_ID>` in all evidence.
- The lab ran as the account root user (the console session was root). Future labs should use lab-admin (risk R8).
