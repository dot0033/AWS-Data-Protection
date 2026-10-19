# Handoff

## Current status
- Week 1 is complete: documents, policies, scripts, lab run and evidence.
- The lab was run on 2026-10-11 (scripts 01 to 04). A restricted-policy fix was applied afterwards for Access Analyzer.
- The AWS account was suspended for payment and identity verification, then reinstated. Billing was checked afterwards and showed $0.00.
- Root sign-in is disabled on the account, so root MFA could not be enabled. Access is through the AWS Builder ID and the IAM user `lab-admin`.
- `99-cleanup.sh` was run after Week 1 was merged. The buckets, Access Point and Analyzer no longer exist. Rebuild them with scripts 01, 02 and 03 before Week 2.

## Done so far
- Data lifecycle, classification scheme, access review and data handling standard in `week-1-data-lifecycle-s3/docs/`.
- Bucket policies and lifecycle policy in `policies/`, lab scripts in `scripts/`, evidence in `evidence/`.

## Conventions
- Region: `eu-central-1`
- Bucket naming: `dp-lab-<level>-<accountid>` (internal, confidential, restricted)
- Required tags: `DataClassification`, `Owner`, `Environment`
- One folder per week with `docs/`, `policies/`, `scripts/`, `evidence/`
- Branch per week, Pull Request into `main`
- No secrets, access keys or unredacted account IDs in the repo

## Week 2 starts here
1. Upgrade encryption from SSE-S3 to SSE-KMS on the Confidential and Restricted buckets.
2. Create KMS keys with key policies tied to the roles in `04-access-review.md`.
3. Create the `dp-lab-restricted-reader` role (referenced by the restricted bucket policy, not created yet).
4. Add any new service that must read the restricted bucket (KMS, Macie) to the allowed principals in the restricted policy.
5. Configure key rotation and audit logging for key use.

## Known issues and decisions
- SSE-S3 (AES256) is used in Week 1 on purpose and is upgraded in Week 2.
- Scripts run on Windows Git Bash: aws.exe cannot read `/tmp` paths, so scripts convert paths with `cygpath`.
- The restricted bucket policy must also allow the Access Analyzer service-linked role, otherwise the analyzer reports `ACCESS_DENIED`. See `evidence/access-analyzer-findings-before-fix.json`.
- The Console cannot open the restricted bucket (expected). Use the CLI as `lab-admin`.
- The account is on a paid plan with advanced features activated (irreversible). Spend limits are not available, so budgets of $1 and $20 only send email alerts.
- New AWS accounts can be asked for payment and identity verification. If the card belongs to another person, that person's ID is also required. Documents are sent only through the secure link AWS provides, never by email.
- Later weeks cost money: KMS keys, Macie, GuardDuty and Secrets Manager. Run each week's cleanup script when finished.

## How to verify
```bash
bash week-1-data-lifecycle-s3/scripts/04-verify.sh
```

## Cleanup
```bash
bash week-1-data-lifecycle-s3/scripts/99-cleanup.sh
```
