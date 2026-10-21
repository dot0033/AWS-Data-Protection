# 01 - KMS Key Hierarchy

Date: 2026-10-21 · Region: eu-central-1

## Design

One customer managed key (CMK) per classification level that needs its own key. Public and Internal data keep AWS managed encryption (SSE-S3), because a separate key adds cost without adding a new access boundary.

```
AWS KMS (FIPS 140-3 validated HSMs, key material never leaves KMS)
│
├── alias/dp-lab-restricted   CMK, symmetric AES-256, rotation every 90 days
│     └── S3 bucket dp-lab-restricted-<ACCOUNT_ID>  (SSE-KMS + S3 Bucket Key)
│           └── per-object data keys (envelope encryption)
│
├── alias/dp-lab-confidential CMK, symmetric AES-256, rotation every 365 days
│     ├── S3 bucket dp-lab-confidential-<ACCOUNT_ID> (SSE-KMS + S3 Bucket Key)
│     │     └── archive/ objects in S3 Glacier Instant Retrieval
│     ├── DynamoDB table dp-lab-confidential
│     ├── EBS volume dp-lab-ebs
│     └── RDS PostgreSQL dp-lab-rds
│
└── AWS managed / owned keys  (Internal and Public data: SSE-S3, AES-256)
```

| Level | Key | Key type | Who manages | Who can use it | Rotation |
|---|---|---|---|---|---|
| Restricted | alias/dp-lab-restricted | Customer managed | Key admins (lab-admin) | lab-admin and dp-lab-restricted-reader, **only through S3** | 90 days + on demand |
| Confidential | alias/dp-lab-confidential | Customer managed | Key admins (lab-admin) | lab-admin through S3, DynamoDB, EC2/EBS, RDS | 365 days |
| Internal / Public | SSE-S3 | AWS owned | AWS | Anyone allowed by IAM and bucket policy | Managed by AWS |

## Envelope encryption

KMS keys never encrypt bulk data directly (direct `Encrypt` is limited to 4 KB). Services ask KMS for a data key (`GenerateDataKey`), encrypt the data locally with the plaintext data key, throw the plaintext away and store the encrypted data key next to the data. To read, the service sends the encrypted data key to KMS (`Decrypt`), which checks the key policy first. See the lab in `evidence/kms-lab-output.txt`.

S3 Bucket Keys are enabled, so S3 asks KMS for a bucket-level key instead of one call per object. This cuts KMS requests and cost by up to 99%.

## Why two keys, not one

- Separate blast radius: disabling or losing the restricted key does not affect confidential data.
- Separate access boundary: the restricted key policy denies data use to every principal except two, even if IAM would allow it.
- Separate audit trail: CloudTrail shows which key was used, so restricted access is easy to filter.

## CloudHSM (concepts, not deployed)

| | AWS KMS | AWS CloudHSM |
|---|---|---|
| Tenancy | Multi-tenant, AWS-run HSMs | Single-tenant HSM cluster in your VPC |
| Control | AWS manages HSMs, you manage keys and policies | You manage users, keys and the HSM (crypto officer / crypto user) |
| Validation | FIPS 140-3 Level 3 | FIPS 140-3 Level 3 |
| Integration | Native in S3, EBS, RDS, DynamoDB and more | PKCS#11, JCE, OpenSSL; or as a KMS custom key store |
| Cost | $1 per key per month + requests | Roughly $1.5-2 per HSM per hour, depending on Region (two HSMs for HA) |
| Use when | Default for almost all workloads | Regulations require exclusive control of the HSM, or you need custom crypto (e.g. TLS offload, Oracle TDE) |

Decision: KMS is used. CloudHSM is not deployed in the lab because of its hourly cost and because no requirement needs single-tenant HSMs. If one appears later, a **KMS custom key store** backed by CloudHSM keeps the same S3/RDS integrations.
