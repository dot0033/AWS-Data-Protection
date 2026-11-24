# 02 - Data Loss Prevention (DLP) Plan

## Purpose

Stop sensitive data from being stored in the wrong place, shared with the wrong people, or leaving the AWS account. The plan builds on the Week 1 classification scheme (public, internal, confidential, restricted), the Week 2 KMS keys and the Week 3 secrets management.

## Scope

All S3 buckets in the account, data moving in and out through APIs and the console, and credentials used by workloads. Data in use (memory, analytics) is covered by access control and logging, not content inspection.

## DLP strategy: discover, protect, detect, respond

### 1. Discover (know where sensitive data is)

| Control | Tool | Frequency | Status in lab |
|---------|------|-----------|---------------|
| Sensitive data discovery in S3 | Amazon Macie (substitute: `scripts/06-pii-scan.py`) | Weekly for restricted and confidential, monthly for internal | Substitute run, 3 of 4 objects flagged |
| Classification tag on every bucket | `DataClassification` tag (Week 1) | At creation, checked by `05-verify.sh` | Verified |
| Inventory of buckets and their public status | IAM Access Analyzer (Week 1), Macie bucket inventory | Continuous | Week 1 verified |

### 2. Protect (prevent loss)

| Data at risk | Control | Implemented in |
|--------------|---------|----------------|
| Public exposure | Block Public Access on account and buckets | Week 1, Week 4 lab |
| Theft of stored data | SSE-KMS with separate keys per level, explicit Deny in key policy | Week 2 |
| Interception in transit | `aws:SecureTransport` Deny, TLS 1.2+ | Week 1 policies, Week 3 |
| Secrets in files or code | Secrets Manager / Parameter Store SecureString, no keys in repos | Week 3, `.gitignore` |
| Copy to another account | Bucket policy Deny unless `aws:PrincipalOrgID` / account matches; VPC endpoint policy limits buckets | Design (below) |
| Over-sharing | Least privilege roles, named roles only for restricted data | Week 1-2 |
| Accidental deletion | Versioning, lifecycle policy, MFA delete for restricted | Week 1 |

Data perimeter statement to add to confidential and restricted bucket policies:

```json
{
  "Sid": "DenyAccessFromOutsideAccount",
  "Effect": "Deny",
  "Principal": "*",
  "Action": "s3:*",
  "Resource": ["arn:aws:s3:::dp-lab-restricted-<ACCOUNT_ID>", "arn:aws:s3:::dp-lab-restricted-<ACCOUNT_ID>/*"],
  "Condition": {
    "StringNotEquals": { "aws:PrincipalAccount": "<ACCOUNT_ID>" },
    "Bool": { "aws:PrincipalIsAWSService": "false" }
  }
}
```

### 3. Detect (notice loss attempts)

| Signal | Source | Finding / event |
|--------|--------|-----------------|
| Sensitive data in the wrong bucket | Macie | `SensitiveData:S3Object/*` in an internal or public bucket |
| Unusual bulk download | GuardDuty S3 Protection | `Exfiltration:S3/AnomalousBehavior` |
| Access from Tor or a known bad IP | GuardDuty | `UnauthorizedAccess:S3/TorIPCaller`, `...MaliciousIPCaller` |
| Public access switched off | GuardDuty, CloudTrail | `Policy:S3/BucketBlockPublicAccessDisabled`, `PutBucketPublicAccessBlock` |
| Policy or encryption changes | CloudTrail | `PutBucketPolicy`, `PutBucketEncryption`, `ScheduleKeyDeletion` (lab evidence: `evidence/07-cloudtrail-events.txt`) |
| Key misuse | CloudTrail KMS events | `Decrypt` by an unexpected principal |

High-severity findings are routed with `policies/eventbridge-high-severity-findings.json` to an SNS topic owned by the security team.

### 4. Respond

| Severity | Example | Response time | Actions |
|----------|---------|---------------|---------|
| High | Credentials or card numbers found outside the restricted bucket; exfiltration finding | 1 hour | Block access (bucket policy Deny), rotate exposed keys, move or delete the object, open an incident, check CloudTrail for reads |
| Medium | Personal data in a confidential bucket without a business reason | 3 business days | Owner confirms purpose or deletes; reclassify bucket if needed |
| Low | Sample findings, test data | Next review | Suppress with a Macie findings filter and document why |

Every response is logged in the risk register (`04-data-protection-risk-register.md`) if it reveals a new risk.

## Rules for people

1. Never store real personal data in internal or public buckets; it takes the restricted classification.
2. Never put access keys in files, code or tickets. Use roles and Secrets Manager.
3. Mask or tokenise card numbers; never store CVV.
4. Exports of restricted data need Owner approval and go only to the confidential or restricted buckets.
5. Test data must be synthetic, as in `sample-data/`.

## Metrics

| Metric | Target |
|--------|--------|
| Buckets with a DataClassification tag | 100% |
| Restricted and confidential buckets scanned in the last 7 days | 100% |
| High findings closed within 1 hour | 95% |
| Exposed credentials rotated within 1 hour | 100% |
| Buckets with Block Public Access off | 0 |
