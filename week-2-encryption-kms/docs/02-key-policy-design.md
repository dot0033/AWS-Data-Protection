# 02 - Key Policy Design

Templates: `policies/kms-key-policy-confidential.json`, `policies/kms-key-policy-restricted.json`.
Applied versions (account ID redacted): `evidence/kms-key-policy-*-applied.json`.

## Principles

1. **Separation of duties.** Key administrators manage the key (`Create*`, `Put*`, `Enable*`, `Disable*`, `ScheduleKeyDeletion`...). Key users only get crypto operations (`Decrypt`, `GenerateDataKey*`...). In this lab one identity holds both roles; in production they are different roles.
2. **Use only through approved services.** Crypto permissions carry `kms:ViaService`, so the key can be used by S3/RDS/DynamoDB/EBS on behalf of a user, not called directly from a laptop.
3. **Grants only for AWS resources.** `CreateGrant` is allowed only with `kms:GrantIsForAWSResource = true` (EBS and RDS need grants to attach encrypted storage).
4. **Account recovery kept.** Each policy keeps the `arn:aws:iam::<ACCOUNT_ID>:root` statement. Without it, deleting the admin principal would make the key unmanageable (AWS Support cannot recover it).
5. **Explicit deny for Restricted.** Because the root statement lets IAM policies grant access, the restricted key adds explicit `Deny` statements that IAM cannot override.

## Confidential key statements

| Sid | Effect | Principal | Actions | Condition |
|---|---|---|---|---|
| EnableAccountRootRecovery | Allow | account root | kms:* | - |
| KeyAdministrators | Allow | key admin | management actions | - |
| AllowUseThroughApprovedServicesOnly | Allow | key admin | Encrypt, Decrypt, ReEncrypt*, GenerateDataKey*, DescribeKey | ViaService = s3 / dynamodb / ec2 / rds in eu-central-1 |
| AllowGrantsForAwsResourcesOnly | Allow | key admin | CreateGrant, ListGrants, RevokeGrant | GrantIsForAWSResource = true |

## Restricted key statements

| Sid | Effect | Principal | Actions | Condition |
|---|---|---|---|---|
| EnableAccountRootRecovery | Allow | account root | kms:* | - |
| KeyAdministrators | Allow | key admin | management actions + RetireGrant | - |
| AllowRestrictedReaderDecryptViaS3 | Allow | key admin, dp-lab-restricted-reader | Decrypt, DescribeKey | ViaService = s3 |
| AllowAdminEncryptViaS3 | Allow | key admin | Encrypt, GenerateDataKey*, ReEncrypt* | ViaService = s3 |
| DenyDataUseByAnyoneElse | **Deny** | * | Decrypt, Encrypt, GenerateDataKey*, ReEncrypt*, CreateGrant | PrincipalArn not admin or reader |
| DenyDirectUseOutsideS3 | **Deny** | * | Decrypt, Encrypt, GenerateDataKey*, ReEncrypt* | not via S3, and caller is not the reader (who may use a temporary grant) |

Result: only two principals can ever decrypt restricted data, and the admin can do it only through S3. Lab evidence: direct `GenerateDataKey` on the restricted key by the admin is denied (`evidence/kms-lab-output.txt`, step 3).

## Matching IAM and bucket controls

- Role `dp-lab-restricted-reader` (created this week, referenced since Week 1): `s3:GetObject`/`ListBucket` on the restricted bucket and `kms:Decrypt` on the restricted key via S3 only (`policies/restricted-reader-policy.json`). Trust: key admin only.
- Restricted bucket policy (`policies/bucket-policy-restricted-kms.json`) adds the reader to the allowed principals and denies uploads that ask for SSE-S3 or another KMS key.
- Confidential bucket policy denies uploads that request a non-KMS encryption header.
- KMS and Macie: KMS needs no bucket policy entry, because S3 calls KMS as the requesting user. Macie's service-linked role will be added in Week 4.

## Lab deviation

The lab ran in CloudShell signed in as the account **root user** (owner's choice for speed), so the "key admin" principal resolved to the account root ARN. Consequences:
- The root user cannot assume IAM roles, so the reader role was verified with the IAM policy simulator instead of a live `AssumeRole`.
- Production rule: never use root for daily work. Key admin must be a named IAM role (e.g. `kms-key-admin`), and key users separate roles per classification.
