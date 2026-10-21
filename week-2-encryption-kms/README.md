# Week 2 - Encryption at Rest & Key Management (KMS)

Status: complete (lab run 2026-10-21 in AWS CloudShell, eu-central-1, then cleaned up).

## Deliverables

| Deliverable | Where |
|---|---|
| KMS key hierarchy (+ CloudHSM concepts) | [docs/01-kms-key-hierarchy.md](docs/01-kms-key-hierarchy.md) |
| Key policy design | [docs/02-key-policy-design.md](docs/02-key-policy-design.md), [policies/](policies/) |
| Encrypted data stores (S3, RDS, DynamoDB, EBS, Glacier) | [docs/03-encrypted-data-stores.md](docs/03-encrypted-data-stores.md) |
| KMS lab evidence | [evidence/](evidence/) |
| Key rotation / audit plan | [docs/04-key-rotation-audit-plan.md](docs/04-key-rotation-audit-plan.md) |

## Scripts

Run in order from `scripts/` (CloudShell or Git Bash, as the key admin):

| Script | What it does |
|---|---|
| 00-env.sh | Shared variables and helpers (sourced by the others) |
| 01-roles-and-keys.sh | Role `dp-lab-restricted-reader`, two CMKs + aliases, rotation |
| 02-s3-sse-kms.sh | Confidential and restricted buckets with SSE-KMS, Bucket Keys, bucket policies, test objects (incl. Glacier IR) |
| 03-data-stores.sh | DynamoDB table, 1 GiB EBS volume, RDS PostgreSQL db.t3.micro, all with the confidential CMK |
| 04-kms-lab.sh | Direct encrypt/decrypt, envelope encryption, deny test, grant create/revoke, on-demand rotation |
| 05-verify.sh | Writes all evidence to `evidence/` with the account ID redacted |
| 99-cleanup.sh | Deletes everything; keys are scheduled for deletion (7 days) |

Cost of the lab run: a few cents (RDS for under an hour, two KMS keys for a few days until deletion).
