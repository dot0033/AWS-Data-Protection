# 06 - Data Handling Standard

## Purpose
Define how data must be stored, encrypted, shared, retained, and deleted for each classification level. See `02-classification-scheme.md` for the levels.

## Handling Rules by Classification

| Rule | Public | Internal | Confidential | Restricted |
|---|---|---|---|---|
| Storage | Any approved bucket | Private S3 bucket | Private S3 bucket, versioning on | Dedicated private bucket, versioning on |
| Encryption at rest | Optional | SSE-S3 | SSE-S3 (SSE-KMS in Week 2) | SSE-S3 (SSE-KMS in Week 2) |
| Encryption in transit | HTTPS recommended | HTTPS required | HTTPS required (bucket policy deny) | HTTPS required (bucket policy deny) |
| Access | Anyone | All employees via IAM roles | Need-to-know IAM roles | Specific named roles only |
| Sharing | Allowed | Internal only, Access Points | Access Points or short-lived presigned URLs, owner approval | No external sharing without written approval |
| Logging | Optional | Recommended | Required | Required, reviewed regularly |
| Retention | Per business need | 1 year | 1 year, then archive or delete | Per legal or compliance requirement |
| Archive | Optional | Standard-IA after 30 days | Standard-IA after 30 days, Glacier after 90 | Glacier after 90 days |
| Deletion | Standard delete | Lifecycle expiration | Lifecycle expiration + noncurrent version cleanup | Lifecycle expiration + noncurrent version cleanup + verified deletion |

## Allowed
- Storing data only in buckets tagged with the correct `DataClassification`.
- Accessing data through IAM roles with least privilege.
- Sharing through Access Points or presigned URLs with short expiry.
- Using Block Public Access on all buckets that are not Public.

## Not Allowed
- Making Internal, Confidential, or Restricted buckets public.
- Storing data in a bucket with a lower classification than the data.
- Sharing Restricted data over HTTP or without approval.
- Using long-term IAM user access keys for application access.
- Committing credentials, keys, or account secrets to Git.
- Removing the `DataClassification` tag from a bucket.

## Roles and Responsibilities

| Role | Responsibility |
|---|---|
| Data Owner | Assigns the classification and approves access and reclassification |
| Security Team | Defines and audits controls, reviews access |
| Engineers | Apply the controls and tags when creating storage |

## Review and Exceptions
- Access reviews follow the schedule in `02-classification-scheme.md`.
- Any exception must be approved by the Data Owner and documented in `HANDOFF.md`.
