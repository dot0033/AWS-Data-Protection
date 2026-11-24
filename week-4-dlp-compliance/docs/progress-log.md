# Week 4 Progress Log

| Date | Step | Result |
|------|------|--------|
| 2026-11-24 | Opened CloudShell in eu-central-1 and loaded the Week 4 scripts and synthetic sample data | OK |
| 2026-11-24 | `01-create-sample-bucket.sh`: created `dp-lab-w4-sample-<ACCOUNT_ID>`, Block Public Access, SSE-S3, tags, uploaded 4 files | OK |
| 2026-11-24 | `02-macie-scan.sh`: `EnableMacie` and `CreateClassificationJob` returned `SubscriptionRequiredException` | Blocked |
| 2026-11-24 | Checked other services: GuardDuty and Security Hub return the same error; S3, STS, CloudTrail work | Account not subscribed to security services |
| 2026-11-24 | Decision: keep $0 cost, write Macie-style scanner `06-pii-scan.py` and use CloudTrail event history for detection evidence | - |
| 2026-11-24 | `06-pii-scan.py`: 4 objects, 3 with sensitive data, 0 false positives | OK |
| 2026-11-24 | `07-cloudtrail-evidence.sh`: 4 configuration events found | OK |
| 2026-11-24 | `05-verify.sh`: 6 passed, 0 failed | OK |
| 2026-11-24 | `99-cleanup.sh`: bucket and objects deleted, 0 lab buckets left | OK |
| 2026-11-24 | Wrote deliverables 01-06 and updated HANDOFF / README | OK |
