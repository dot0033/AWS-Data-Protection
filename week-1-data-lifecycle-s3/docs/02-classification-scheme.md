# 02 - Data Classification Scheme

## Purpose
Define how data is classified by sensitivity, and which controls apply to each level. Every S3 bucket in this project maps to exactly one level.

## Classification Levels

| Level | Description | Examples | Required Controls |
|---|---|---|---|
| Public | Approved for anyone to see | Marketing content, public docs | No access restrictions. Integrity controls only. |
| Internal | For employees only | Internal documents, runbooks | Authenticated access, encryption at rest, HTTPS only |
| Confidential | Business-sensitive, customer data | Customer records, contracts | All Internal controls + least privilege, access logging, versioning |
| Restricted | Regulated or highest-risk data | PII, PCI, PHI | All Confidential controls + named roles only, periodic access review, KMS encryption (Week 2) |

## Controls Matrix

| Control | Public | Internal | Confidential | Restricted |
|---|---|---|---|---|
| Block Public Access | Reviewed case by case | Yes | Yes | Yes |
| Encryption at rest | Optional | SSE-S3 | SSE-S3 (SSE-KMS in Week 2) | SSE-S3 (SSE-KMS in Week 2) |
| HTTPS only (deny insecure transport) | Recommended | Yes | Yes | Yes |
| Versioning | Optional | Yes | Yes | Yes |
| Access scope | Anyone | All employees | Need-to-know roles | Specific named roles only |
| Access review | None | Yearly | Every 6 months | Every 3 months |

## Tag Standard
Every bucket must carry these tags.

| Tag Key | Allowed Values | Example |
|---|---|---|
| DataClassification | public, internal, confidential, restricted | confidential |
| Owner | Team or person responsible | security-team |
| Environment | lab, dev, staging, prod | lab |

## Bucket Mapping (Week 1 Lab)

| Bucket | Classification |
|---|---|
| dp-lab-internal-<accountid> | internal |
| dp-lab-confidential-<accountid> | confidential |
| dp-lab-restricted-<accountid> | restricted |

## Rules
1. Data takes the highest classification of any data it contains.
2. Unclassified data is treated as Internal until reviewed.
3. Reclassification requires approval from the data Owner.
4. Classification must be applied through the `DataClassification` tag at bucket creation.
