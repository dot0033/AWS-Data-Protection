# 06 - GuardDuty for Data Threats

## Status

GuardDuty could not be enabled: `aws guardduty list-detectors` returned `SubscriptionRequiredException` on 2026-11-24 (`evidence/02-macie-guardduty-subscription-error.txt`). This document is the design and runbook; `scripts/03-guardduty.sh` enables it and generates sample findings once the account is activated.

## What GuardDuty S3 Protection watches

GuardDuty reads CloudTrail S3 data events (it does not need a trail of your own) and flags suspicious access patterns.

| Finding type | Meaning | Severity | DLP response |
|--------------|---------|----------|--------------|
| `Exfiltration:S3/AnomalousBehavior` | Unusual volume of `GetObject` calls by a principal | High | Revoke the principal's sessions, check what was read |
| `Exfiltration:S3/MaliciousIPCaller` | Data read from a known malicious IP | High | Block the IP, rotate credentials |
| `UnauthorizedAccess:S3/TorIPCaller` | S3 API called from a Tor exit node | High | Same as above |
| `Discovery:S3/AnomalousBehavior` | Unusual listing of buckets or objects | Low-Medium | Investigate the principal |
| `Policy:S3/BucketBlockPublicAccessDisabled` | Block Public Access turned off | Low | Re-enable, find who changed it (CloudTrail) |
| `Policy:S3/BucketAnonymousAccessGranted` | Bucket opened to everyone | High | Remove the policy statement immediately |
| `Impact:S3/AnomalousBehavior.Delete` | Unusual deletes (ransomware pattern) | High | Restore from versions, lock the principal |

## Lab plan (ready to run)

1. `bash scripts/03-guardduty.sh` creates a detector with `S3_DATA_EVENTS` enabled and generates four sample findings (marked `[SAMPLE]` by AWS).
2. `bash scripts/04-export-findings.sh guardduty` exports them with the account ID redacted.
3. `bash scripts/99-cleanup.sh` deletes the detector.

Cost: GuardDuty has a 30-day free trial per Region; sample findings are free.

## Alerting

Route findings with severity 7 or higher to SNS with the pattern in `policies/eventbridge-high-severity-findings.json`.

## Free detection used instead in this lab

CloudTrail event history recorded every security change to the lab bucket (`evidence/07-cloudtrail-events.txt`): `CreateBucket`, `PutBucketPublicAccessBlock`, `PutBucketEncryption`, `PutBucketTagging`, all by `root`. The same lookup run for `DeleteBucketPublicAccessBlock` or `PutBucketPolicy` would reveal the change behind a `Policy:S3/...` finding.
