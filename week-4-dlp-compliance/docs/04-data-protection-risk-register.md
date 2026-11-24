# 04 - Data Protection Risk Register

Scoring: Likelihood (L) and Impact (I) from 1 (low) to 5 (high). Risk = L x I. Rating: 1-6 Low, 8-12 Medium, 15-25 High. Residual risk is after the listed controls.

| ID | Risk | Asset | L | I | Inherent | Controls in place | Residual | Owner | Treatment / next action |
|----|------|-------|---|---|----------|-------------------|----------|-------|-------------------------|
| R1 | Restricted data (PII, card data) stored in a bucket with weaker controls | S3 buckets | 4 | 5 | 20 High | Classification tags (W1), sensitive data discovery found 3/4 objects (W4) | 3x5 = 15 High | Data owner | Activate Macie, weekly scheduled job on all buckets |
| R2 | Bucket made public by mistake | S3 buckets | 3 | 5 | 15 High | Block Public Access account and bucket level (W1, verified W4), Access Analyzer (W1) | 1x5 = 5 Low | Cloud admin | Add SCP denying `PutPublicAccessBlock` changes when an organisation is used |
| R3 | Long-term access keys leaked in files or code | IAM credentials | 4 | 5 | 20 High | No keys in repo rule, Secrets Manager / Parameter Store (W3); scan detected keys in `app-config.env` (W4) | 2x5 = 10 Medium | Developers | Use roles only; enable GitHub secret scanning; rotate on detection |
| R4 | Data stolen from storage media or snapshot | S3, EBS, RDS | 2 | 5 | 10 Medium | SSE-KMS with separate keys and explicit Deny (W2) | 1x5 = 5 Low | Cloud admin | Turn on EBS encryption by default (open item from W2) |
| R5 | Interception of data in transit | APIs, S3 | 2 | 4 | 8 Medium | Deny insecure transport (W1), TLS (W3) | 1x4 = 4 Low | Cloud admin | Enforce TLS 1.2 minimum with `s3:TlsVersion` condition |
| R6 | KMS key deleted or disabled, data unreadable | KMS keys | 2 | 5 | 10 Medium | 7-30 day deletion window, key admin separation (W2) | 1x5 = 5 Low | Key admin | CloudTrail alarm on `ScheduleKeyDeletion` |
| R7 | Bulk exfiltration by a compromised user | S3 | 3 | 5 | 15 High | Least privilege (W1), CloudTrail management events (W4) | 3x5 = 15 High | Security team | Activate GuardDuty S3 Protection; S3 data events trail; data perimeter Deny (DLP plan) |
| R8 | Account root used for daily work | AWS account | 4 | 5 | 20 High | MFA on root, IAM user lab-admin exists | 3x5 = 15 High | Account owner | W2 and W4 labs ran as root: move all lab work to lab-admin / scoped role |
| R9 | Security services unavailable (Macie, GuardDuty, Security Hub not included in the AWS Free plan) | Detection | 5 | 4 | 20 High | Substitute scanner, CloudTrail event history (W4) | 5x3 = 15 High | Account owner | Upgrade to the paid plan when budget allows, then rerun W4 scripts |
| R10 | Findings not acted on in time | Detection and response | 3 | 4 | 12 Medium | DLP response times (W4) | 2x4 = 8 Medium | Security team | EventBridge -> SNS routing for High findings |
| R11 | Unexpected cost from lab resources | Billing | 3 | 2 | 6 Low | Cleanup scripts every week, $1 and $10 budget alerts | 2x2 = 4 Low | Account owner | Keep running 99-cleanup.sh after each lab |
| R12 | Personal data kept longer than needed | All stores | 3 | 3 | 9 Medium | Lifecycle policy (W1) | 2x3 = 6 Low | Data owner | Review retention per data type yearly |
| R13 | Missing audit trail of object reads | S3 restricted | 3 | 4 | 12 Medium | Management events only | 3x4 = 12 Medium | Security team | CloudTrail trail with S3 data events for restricted bucket |

## Top risks to treat first

1. **R1, R7, R9**: upgrade from the Free plan, enable Macie and GuardDuty, then schedule discovery and enable S3 Protection.
2. **R8**: stop using root; run future labs as lab-admin.
3. **R3**: enforce no-long-term-keys and secret scanning.

## Review

Reviewed after every lab week and at least quarterly. Next review: after a decision on upgrading from the Free plan.
