# Week 1 - Data Lifecycle, Classification & S3 Security

## Summary
Mapped the data lifecycle, defined a classification scheme, then built and verified a secure S3 baseline (one bucket per classification level).

## Deliverables

| # | Deliverable | File | Status |
|---|---|---|---|
| 1 | Data lifecycle | `docs/01-data-lifecycle.md` | Done |
| 2 | Classification scheme | `docs/02-classification-scheme.md` | Done |
| 3 | S3 secure baseline | `scripts/01-*.sh`, `02-*.sh`, `03-*.sh`, `policies/` | Done |
| 4 | Access review | `docs/04-access-review.md` | Done |
| 5 | Lifecycle policy | `policies/lifecycle-policy.json` | Done |
| 6 | Data handling standard | `docs/06-data-handling-standard.md` | Done |
| 7 | Evidence | `evidence/` | Done |

## Prerequisites
- AWS account and AWS CLI v2 configured (`aws sts get-caller-identity` works)
- Region: `eu-central-1`
- Admin-level IAM user (not root)

## How to run the lab
From the repo root, in order:

```bash
bash week-1-data-lifecycle-s3/scripts/01-setup-buckets.sh
bash week-1-data-lifecycle-s3/scripts/02-apply-policies.sh
bash week-1-data-lifecycle-s3/scripts/03-access-analyzer.sh
bash week-1-data-lifecycle-s3/scripts/04-verify.sh
```

## What each script does
- `01-setup-buckets.sh`: account-level Block Public Access, 3 buckets (internal, confidential, restricted) with versioning, SSE-S3 encryption and tags.
- `02-apply-policies.sh`: deny-HTTP policy on internal and confidential, restricted policy (named principals only), lifecycle policy and Access Point on the internal bucket.
- `03-access-analyzer.sh`: creates IAM Access Analyzer and exports findings to `evidence/`.
- `04-verify.sh`: checks encryption, HTTP denial, public-policy rejection, tags and versioning.
- `99-cleanup.sh`: deletes everything created by the lab.

## Evidence checklist
- [x] `head-object` output showing `ServerSideEncryption` (`evidence/verify-output.txt`)
- [x] HTTP request denied
- [x] Public bucket policy rejected by Block Public Access
- [x] Access Analyzer findings before and after the fix
- [x] Console screenshots (Block Public Access, versioning, tags, encryption, Access Analyzer, Access Point)
- [x] Restricted bucket denied in the Console, and the policy source

See `evidence/README.md` for notes on each file.

## Cleanup
```bash
bash week-1-data-lifecycle-s3/scripts/99-cleanup.sh
```
