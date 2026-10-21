# Handoff

## Current status

- Week 1 is complete: documents, policies, scripts, lab run and evidence.
- Week 2 is complete: KMS key hierarchy, key policy design, encrypted data stores, KMS lab evidence, key rotation/audit plan. See `week-2-encryption-kms/README.md`.
- The Week 2 lab was run on 2026-10-21 in AWS CloudShell (scripts 01 to 05), then `99-cleanup.sh` was run. Buckets, DynamoDB table, EBS volume, RDS instance and the reader role are deleted. Both KMS keys are scheduled for deletion (7-day window) and their aliases are removed.
- The Week 2 lab was run as the account **root user** (the console was signed in as root). Because root cannot assume roles, the reader role was checked with the IAM policy simulator. Next labs should run as `lab-admin` or a scoped admin role.
- The AWS account was suspended for payment and identity verification, then reinstated. Billing was checked afterwards and showed $0.00.
- Access is through the AWS Builder ID and the IAM user lab-admin.

## Done so far

- Week 1: data lifecycle, classification scheme, access review and data handling standard in `week-1-data-lifecycle-s3/docs/`; bucket policies and lifecycle policy in `policies/`, lab scripts in `scripts/`, evidence in `evidence/`.
- Week 2: docs in `week-2-encryption-kms/docs/`, key/IAM/bucket policy templates in `policies/`, scripts in `scripts/`, evidence in `evidence/`.

## Conventions

- Region: eu-central-1
- Bucket naming: `dp-lab-<level>-<accountid>` (internal, confidential, restricted)
- KMS aliases: `alias/dp-lab-<level>` (confidential, restricted)
- Required tags: DataClassification, Owner, Environment
- One folder per week with docs/, policies/, scripts/, evidence/
- Branch per week, Pull Request into main
- No secrets, access keys or unredacted account IDs in the repo

## Week 3 starts here

- Week 2 scripts 01 and 02 rebuild the keys and SSE-KMS buckets if Week 3 needs them (new key IDs will be created).
- Use ACM / TLS and Secrets Manager. Secrets Manager secrets can be encrypted with `alias/dp-lab-confidential`.
- Week 4: add the Macie service-linked role to the allowed principals of the restricted bucket policy, and give Macie `kms:Decrypt` on the restricted key, otherwise Macie cannot scan it.

## Known issues and decisions

- SSE-S3 (AES256) was used in Week 1 on purpose and upgraded to SSE-KMS in Week 2.
- Restricted key policy has explicit Deny statements: only the key admin and `dp-lab-restricted-reader` can use it, and the admin only through S3. Any new service (Macie) must be added to both Deny exceptions.
- Bucket policies deny an upload only when it **sends** a wrong encryption header (`Null` + `StringNotEquals`). Using `StringNotEqualsIfExists` blocked plain uploads that rely on default encryption.
- `EbsEncryptionByDefault` is off in the account (recommendation in `week-2-encryption-kms/docs/03-encrypted-data-stores.md`).
- Scripts run on Windows Git Bash and CloudShell: aws.exe cannot read /tmp paths, so scripts convert paths with cygpath when it exists.
- The restricted bucket policy must also allow the Access Analyzer service-linked role, otherwise the analyzer reports ACCESS_DENIED.
- The Console cannot open the restricted bucket (expected). Use the CLI.
- The account is on a paid plan with advanced features activated (irreversible). Spend limits are not available, so budgets of $1 and $10 only send email alerts.
- New AWS accounts can be asked for payment and identity verification. If the card belongs to another person, that person's ID is also required. Documents are sent only through the secure link AWS provides, never by email.
- Later weeks cost money: Macie, GuardDuty and Secrets Manager. Run each week's cleanup script when finished.

## How to verify

```
bash week-1-data-lifecycle-s3/scripts/04-verify.sh
bash week-2-encryption-kms/scripts/05-verify.sh
```

## Cleanup

```
bash week-1-data-lifecycle-s3/scripts/99-cleanup.sh
bash week-2-encryption-kms/scripts/99-cleanup.sh
```
