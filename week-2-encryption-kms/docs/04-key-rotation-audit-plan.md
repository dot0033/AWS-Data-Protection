# 04 - Key Rotation and Audit Plan

## Rotation

| Key | Automatic rotation | On-demand rotation | Evidence |
|---|---|---|---|
| alias/dp-lab-restricted | Every 90 days | Yes, after any suspected exposure, admin change or audit request (tested in the lab) | `evidence/kms-rotation-restricted.json` |
| alias/dp-lab-confidential | Every 365 days | Only on incident | `evidence/kms-rotation-confidential.json` |
| AWS managed / owned keys | Every year, by AWS | Not possible | - |

How KMS rotation works:
- Only the key material changes. Key ID, ARN, alias and policy stay the same, so no application change is needed.
- Old key material is kept, so data encrypted before rotation can still be decrypted. Data is **not** re-encrypted.
- Cost: each rotated version adds $1/month (first and second rotation only), so rotation periods are chosen per classification, not set to the minimum everywhere.
- Rotation is not a fix for a leaked data key or a wrong policy. If a key is compromised: disable the key, review CloudTrail, re-encrypt data under a new key (S3 Batch Operations copy, RDS snapshot copy with the new key), then schedule deletion of the old key.

Imported key material and asymmetric keys cannot rotate automatically; none are used here.

## Key lifecycle rules

- Create: only key admins, with tags `DataClassification`, `Owner`, `Environment`, and an alias `alias/dp-lab-<level>`.
- Disable before delete: disable the key, wait one review cycle, check CloudTrail for failed `Decrypt` calls (shows hidden dependencies), then schedule deletion.
- Delete: 30-day waiting window in production (7 days in the lab). Deletion is irreversible; data encrypted under the key becomes unreadable.

## Audit logging

| Source | What it records | Status |
|---|---|---|
| CloudTrail event history | Every KMS API call (Encrypt, Decrypt, GenerateDataKey, CreateGrant, RotateKeyOnDemand, PutKeyPolicy...) for 90 days, free | On by default. Lab export: `evidence/cloudtrail-kms-events.json` |
| CloudTrail trail to S3 (production) | Same events kept long term, log file integrity validation on, bucket encrypted with a separate log key | Planned for production, not created in the lab to save cost |
| EventBridge rules (production) | Alerts on `DisableKey`, `ScheduleKeyDeletion`, `PutKeyPolicy`, `CreateGrant` on the restricted key | Planned |
| AWS Config rules | `cmk-backing-key-rotation-enabled`, `kms-cmk-not-scheduled-for-deletion`, `s3-default-encryption-kms`, `encrypted-volumes`, `rds-storage-encrypted`, `dynamodb-table-encrypted-kms` | Planned (Week 4 compliance matrix) |

In the lab export, `User: null` means the call was made by an AWS service on the user's behalf (S3, EBS, RDS, DynamoDB using the key). Event history lags by a few minutes, so the last lab calls (grant revoke, on-demand rotation) are not in the export; the rotation itself is shown in `evidence/kms-rotation-restricted.json`.

## Review schedule

| Check | Frequency | Owner |
|---|---|---|
| Rotation status of all CMKs (`get-key-rotation-status`) | Monthly | security-team |
| Key policies vs. this design (diff against `policies/`) | Quarterly and after each change | security-team |
| Active grants (`list-grants`), revoke unused | Monthly | security-team |
| CloudTrail: Decrypt on the restricted key by unexpected principals, AccessDenied spikes | Weekly | security-team |
| Keys pending deletion or disabled | Monthly | security-team |

How to re-run the evidence: `bash scripts/05-verify.sh`.
