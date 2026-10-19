# 04 - Access Review

## Scope
Review of who can access each Week 1 bucket, whether that follows least privilege, and what action is needed. Sources: bucket policies in `policies/`, IAM Access Analyzer findings in `evidence/`.

Date of review: 2026-10-11

## Bucket Access Summary

| Bucket | Classification | Who has access | Least privilege? | Action required |
|---|---|---|---|---|
| dp-lab-internal-`<ACCOUNT_ID>` | internal | `lab-admin` (AdministratorAccess), Access Point `analytics-ap` | No. Admin-level access is broader than needed | Week 2: replace with a scoped role for analytics access |
| dp-lab-confidential-`<ACCOUNT_ID>` | confidential | `lab-admin` (AdministratorAccess) | No. Same reason | Week 2: define need-to-know roles and attach scoped policies |
| dp-lab-restricted-`<ACCOUNT_ID>` | restricted | `lab-admin`, role `dp-lab-restricted-reader`, IAM Access Analyzer service-linked role | Yes at bucket level (explicit deny for everyone else) | Create the `dp-lab-restricted-reader` role (not created yet) and tie it to the KMS key policy in Week 2 |

## Controls Applied at Bucket Level

| Control | internal | confidential | restricted |
|---|---|---|---|
| Account-level Block Public Access | Yes | Yes | Yes |
| Deny HTTP (`aws:SecureTransport`) | Yes | Yes | Yes |
| Deny all except named principals | No | No | Yes |
| Versioning | Yes | Yes | Yes |
| Default encryption | SSE-S3 | SSE-S3 | SSE-S3 |
| Tags (DataClassification, Owner, Environment) | Yes | Yes | Yes |
| Lifecycle policy | Yes | No | No |
| Access Point | `analytics-ap` | No | No |

## IAM Access Analyzer Findings

| Run | Result | Evidence |
|---|---|---|
| 1 | One finding on the restricted bucket: `ACCESS_DENIED`. The analyzer could not read the bucket policy, because the "deny all except named principals" statement also blocked the analyzer's service-linked role | `evidence/access-analyzer-findings-before-fix.json` |
| 2 | No findings, after adding `AWSServiceRoleForAccessAnalyzer` to the allowed principals in `bucket-policy-restricted.json` | `evidence/access-analyzer-findings.json` |

A final empty result means Access Analyzer found no public or cross-account access on the analyzed buckets.

## Issues and Recommendations
1. **`lab-admin` has AdministratorAccess.** Acceptable for the lab, not for production. Week 2 should introduce scoped roles per classification level.
2. **The `dp-lab-restricted-reader` role does not exist yet.** The restricted bucket policy already references it, so nobody except `lab-admin` can read that bucket today.
3. **Deny-all-except policies block monitoring services too.** Any service that must read the bucket (Access Analyzer, and later Macie and KMS-related services) has to be added to the allowed principals. Check this each time a new service is introduced.
4. **Console access to the restricted bucket is denied** for principals not in the allowed list, such as the Management Account console role. This is expected behavior of the policy. Use the CLI as `lab-admin`.
5. **Encryption is SSE-S3.** Week 2 upgrades the confidential and restricted buckets to SSE-KMS.

## Next Review
Re-run this review after Week 2 changes (KMS key policies and roles), and then on the schedule in `02-classification-scheme.md`.
