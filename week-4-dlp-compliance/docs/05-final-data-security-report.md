# 05 - Final Audit-Ready Data Security Report

**Project:** AWS Data Protection, Encryption & Privacy Compliance
**Region:** eu-central-1 (Frankfurt)
**Period:** October - November 2026 (Weeks 1-4)
**Report date:** 2026-11-24

## 1. Executive summary

Over four weeks the project built and tested a layered data protection setup on AWS: classification and access control for S3 (Week 1), KMS encryption with separated keys (Week 2), encryption in transit and secrets management (Week 3), and sensitive data discovery, DLP and compliance mapping (Week 4).

In Week 4, a discovery scan of a test bucket found sensitive data in 3 of 4 objects (credentials, card numbers, SSNs, passport number), with no false positive on the public file, and all 6 control checks passed. Amazon Macie and GuardDuty could not be enabled because the account is not subscribed to them (`SubscriptionRequiredException`); a $0 substitute scanner and CloudTrail evidence were used, and ready-to-run scripts are included for when the services are activated.

Overall: 13 of 18 mapped controls verified, 3 designed, 2 out of scope (legal/organisational). The main open risks are the missing managed threat detection (R7, R9) and use of the root user for labs (R8).

## 2. Scope and method

| Week | Focus | Evidence location |
|------|-------|-------------------|
| 1 | Data lifecycle, classification, S3 security | `week-1-data-lifecycle-s3/` (docs, policies, scripts, evidence) |
| 2 | Encryption at rest, KMS key hierarchy, key policies | `week-2-encryption-kms/` |
| 3 | TLS, secrets, API protection | `week-3-transit-secrets/` |
| 4 | Discovery, DLP, threat detection, compliance | `week-4-dlp-compliance/` |

Each week used scripts that create resources, verify them and clean them up. Evidence is stored as command output and screenshots with account IDs redacted. Resources were deleted after each lab.

## 3. Controls and results

| Area | Control | Result |
|------|---------|--------|
| Classification | 4 levels, mandatory `DataClassification` / `Owner` / `Environment` tags | Implemented W1, checked again W4 (PASS) |
| Public exposure | Block Public Access on all buckets, Access Analyzer | Implemented W1, W4 PASS (all 4 settings) |
| Access control | Least privilege, named roles for restricted data, access review | Implemented W1 |
| Encryption at rest | SSE-KMS, separate keys for confidential and restricted, explicit Deny in key policy | Implemented W2 (lab resources since deleted) |
| Key management | Rotation and audit plan | Documented W2 |
| Encryption in transit | Deny insecure transport, TLS certificate exercise | W1 policy, W3 local TLS lab |
| Secrets | Parameter Store SecureString, no secrets in repo | W3 |
| Discovery | Macie-style scan of S3 objects | W4: 3/4 objects flagged, 20 sensitive values, 0 false positives |
| Detection | CloudTrail event history of config changes; GuardDuty design | W4: 4 events recorded; GuardDuty not activated |
| DLP | Discover / protect / detect / respond plan with response times | W4 `02-dlp-plan.md` |
| Compliance | GDPR, HIPAA, PCI DSS mapping | W4 `03-compliance-control-matrix.md` |
| Risk | 13-item risk register with owners | W4 `04-data-protection-risk-register.md` |

## 4. Week 4 lab results

| Check | Result |
|-------|--------|
| Bucket exists | PASS |
| Block Public Access: all 4 settings on | PASS |
| Default encryption (SSE-S3) | PASS |
| `DataClassification=restricted` tag | PASS |
| Sensitive data discovered by scan | PASS |
| No false positive on `public-faq.txt` | PASS |
| **Total** | **6 passed, 0 failed** |

Findings: `app-config.env` (AWS credentials, High), `customers.csv` (cards, SSNs, emails, phones, High), `support-ticket.txt` (card, passport, phone, date of birth, High). Details in `01-macie-findings-report.md`.

## 5. Deviations from the plan

| Planned | Actual | Reason | Impact |
|---------|--------|--------|--------|
| Amazon Macie classification job | Python substitute with Macie-style identifiers | Account not subscribed to Macie | Same findings type and logic; no Macie console evidence |
| GuardDuty sample findings | Design document + CloudTrail evidence | Account not subscribed to GuardDuty | Threat detection not demonstrated live |
| Restricted bucket with SSE-KMS | SSE-S3 on the temporary lab bucket | Avoid KMS key charges for a 15-minute lab; W2 already proved SSE-KMS | Documented; restricted data in production must use SSE-KMS |
| Run as lab-admin | Run as root | Console session was root, as in W2 | Recorded as risk R8 |

## 6. Open findings and recommendations

| Priority | Recommendation | Risk ID |
|----------|----------------|---------|
| 1 | Ask AWS Support to activate Macie, GuardDuty and Security Hub, then run `02-macie-scan.sh` and `03-guardduty.sh` | R1, R7, R9 |
| 2 | Use lab-admin or a scoped role for all future work; keep root for account tasks only | R8 |
| 3 | Create a CloudTrail trail with S3 data events for restricted buckets, stored with Object Lock | R7, R13 |
| 4 | Add the data perimeter Deny statement to confidential and restricted bucket policies | R7 |
| 5 | Turn on EBS encryption by default | R4 |
| 6 | Route High findings to SNS through EventBridge | R10 |

## 7. Audit evidence index

| Evidence | File |
|----------|------|
| Sample bucket created and objects uploaded | `evidence/01-bucket-objects.txt`, `evidence/01-sample-bucket-created.png` |
| Macie / GuardDuty / Security Hub not available | `evidence/02-macie-guardduty-subscription-error.txt`, `evidence/02-*.png` |
| Sensitive data findings | `evidence/pii-scan-findings.json`, `evidence/06-pii-scan-output.txt` |
| Control verification | `evidence/05-verify-result.txt`, `evidence/06-pii-scan-cloudtrail-verify.png` |
| Configuration change trail | `evidence/07-cloudtrail-events.txt` |
| Cleanup | `evidence/99-cleanup-output.txt` |
| Weeks 1-3 | See each week's `evidence/` folder |

## 8. Cost

Week 4 cost about $0.00: one small S3 bucket for about 15 minutes, CloudShell and CloudTrail event history are free, and Macie/GuardDuty were not activated. All Week 4 resources were deleted (`aws s3 ls | grep -c dp-lab-w4` returned 0).
