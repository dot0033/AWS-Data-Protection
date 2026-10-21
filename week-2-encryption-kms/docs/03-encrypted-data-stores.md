# 03 - Encrypted Data Stores

Lab run: 2026-10-21, eu-central-1. All resources were deleted afterwards with `scripts/99-cleanup.sh`.

| Store | Resource | Encryption | Key | Verified by |
|---|---|---|---|---|
| S3 (Confidential) | dp-lab-confidential-<ACCOUNT_ID> | SSE-KMS default, S3 Bucket Key on, SSE-C blocked | alias/dp-lab-confidential | `evidence/s3-confidential-encryption.txt` |
| S3 (Restricted) | dp-lab-restricted-<ACCOUNT_ID> | SSE-KMS default, S3 Bucket Key on, SSE-C blocked, bucket policy denies SSE-S3 or other keys | alias/dp-lab-restricted | `evidence/s3-restricted-encryption.txt`, `evidence/s3-policy-enforcement.txt` |
| Glacier tier | `archive/archive.txt` in the confidential bucket, storage class GLACIER_IR | SSE-KMS | alias/dp-lab-confidential | `evidence/s3-confidential-encryption.txt` |
| DynamoDB | table dp-lab-confidential (on-demand) | SSE type KMS, customer managed key | alias/dp-lab-confidential | `evidence/dynamodb-encryption.json` |
| EBS | 1 GiB gp3 volume dp-lab-ebs | Encrypted = true | alias/dp-lab-confidential | `evidence/ebs-encryption.json` |
| RDS | PostgreSQL db.t3.micro dp-lab-rds, not public | StorageEncrypted = true (storage, snapshots, logs, read replicas) | alias/dp-lab-confidential | `evidence/rds-encryption.json` |

## Notes per service

- **S3:** Week 1 used SSE-S3 (AES256). Both buckets are now SSE-KMS. Existing objects keep their old encryption until rewritten (`aws s3 cp s3://b/k s3://b/k --sse aws:kms --sse-kms-key-id ...` or S3 Batch Operations). The test upload with an `AES256` header to the restricted bucket was denied by the bucket policy.
- **Glacier:** Legacy S3 Glacier *vaults* always use AWS-managed AES-256 and cannot use a customer managed key. The modern way, used here, is S3 Glacier storage classes (Instant/Flexible Retrieval, Deep Archive) inside an SSE-KMS bucket, so archived data stays under the classification key. The Week 1 lifecycle rule moves data into these classes.
- **DynamoDB:** Encryption at rest is always on. Options are AWS owned key (default), AWS managed key (`aws/dynamodb`) or a customer managed key. The CMK gives a key policy and CloudTrail records of each use.
- **EBS:** Encryption covers the volume, data in transit between the instance and the volume, and snapshots. `EbsEncryptionByDefault` is **false** in this account (`evidence/ebs-encryption-by-default.json`). Recommendation: enable it account-wide with the confidential key as default.
- **RDS:** Encryption can only be chosen at creation. To encrypt an existing unencrypted DB: snapshot → copy snapshot with a KMS key → restore. The lab DB had no backups and a random master password that was never displayed or stored.

## Gaps and recommendations

| Gap | Recommendation | Priority |
|---|---|---|
| EBS encryption by default is off | `aws ec2 enable-ebs-encryption-by-default` + `modify-ebs-default-kms-key-id` | High |
| No SCP or Config rule forces encryption on new resources | AWS Config rules (see 04-key-rotation-audit-plan.md) and an SCP that denies `rds:CreateDBInstance` with `rds:StorageEncrypted = false` | Medium |
| One key covers all Confidential services | Acceptable for the lab. In production, split per service or application if teams differ | Low |
