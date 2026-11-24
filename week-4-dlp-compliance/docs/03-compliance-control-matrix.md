# 03 - Compliance Control Matrix (GDPR / HIPAA / PCI DSS)

Maps the controls built in Weeks 1-4 to the main requirements of GDPR, HIPAA and PCI DSS v4.0. Status shows what is implemented and verified in the lab, what is documented as design, and what is still open. This is a lab mapping, not a formal compliance certification.

Status key: **Verified** = run in the lab with evidence. **Designed** = documented, not deployed. **Gap** = not covered yet.

| # | Control | Project evidence | GDPR | HIPAA (Security Rule) | PCI DSS v4.0 | Status |
|---|---------|------------------|------|------------------------|--------------|--------|
| 1 | Data classification scheme and tags | W1 `docs/02-classification-scheme.md`, W4 `05-verify.sh` | Art. 30 (records of processing) | 164.308(a)(1) risk analysis | 12.5.2 (data inventory / scope) | Verified |
| 2 | Data lifecycle and retention | W1 `docs/01-data-lifecycle.md`, `policies/lifecycle-policy.json` | Art. 5(1)(e) storage limitation | 164.316(b)(2) retention | 3.2.1 retention and disposal | Verified |
| 3 | Block Public Access on all buckets | W1 evidence `01-block-public-access.png`, W4 verify | Art. 32 security of processing | 164.312(a)(1) access control | 1.4 network controls | Verified |
| 4 | Least privilege, named roles for restricted data | W1 `bucket-policy-restricted.json`, W1 access review | Art. 25 data protection by design | 164.308(a)(4) access management | 7.2 least privilege | Verified |
| 5 | Periodic access review | W1 `docs/04-access-review.md`, Access Analyzer | Art. 32(1)(d) regular testing | 164.308(a)(3) workforce access | 7.2.4 review accounts every 6 months | Verified |
| 6 | Encryption at rest with KMS, key separation | W2 `docs/01-kms-key-hierarchy.md`, `02-key-policy-design.md` | Art. 32(1)(a) encryption | 164.312(a)(2)(iv) encryption | 3.5 protect stored PAN | Verified (W2) |
| 7 | Key rotation and audit | W2 `docs/04-key-rotation-audit-plan.md` | Art. 32 | 164.312(b) audit controls | 3.6, 3.7 key management | Verified (W2) |
| 8 | Encryption in transit (TLS, deny insecure transport) | W1 `bucket-policy-deny-insecure.json`, W3 `docs/tls-acm.md` | Art. 32(1)(a) | 164.312(e)(1) transmission security | 4.2 strong cryptography in transit | Verified |
| 9 | Secrets management | W3 Parameter Store SecureString | Art. 32 | 164.312(d) authentication | 8.3.2, 8.6 protect credentials | Verified (W3) |
| 10 | Sensitive data discovery | W4 `01-macie-findings-report.md`, `pii-scan-findings.json` | Art. 30, Art. 35 (DPIA input) | 164.308(a)(1)(ii)(A) risk analysis | 12.5.2 locate cardholder data | Verified (substitute scan); Macie: Gap |
| 11 | Threat detection on data stores | W4 `06-guardduty-data-threats.md` | Art. 32, Art. 33 breach detection | 164.308(a)(6) incident procedures | 10.7, 11.5 detect intrusions | Designed (GuardDuty not on Free plan) |
| 12 | Audit logging of data access and config changes | CloudTrail event history, W4 `07-cloudtrail-events.txt` | Art. 5(2) accountability | 164.312(b) audit controls | 10.2 audit logs | Verified (management events); S3 data events: Gap |
| 13 | DLP policy and incident response | W4 `02-dlp-plan.md` | Art. 33-34 breach notification (72 h) | 164.308(a)(6) | 12.10 incident response plan | Designed |
| 14 | Data minimisation and masking | W4 DLP rules 3 and 5, masked findings | Art. 5(1)(c) data minimisation | 164.514 de-identification | 3.4 mask PAN when displayed | Designed |
| 15 | Risk assessment and register | W4 `04-data-protection-risk-register.md` | Art. 35 DPIA | 164.308(a)(1)(ii)(A)-(B) | 12.3 targeted risk analysis | Verified (document) |
| 16 | Backup / versioning | W1 versioning evidence | Art. 32(1)(c) availability | 164.308(a)(7) contingency plan | 9.4 media protection | Verified |
| 17 | Data subject rights (access, erasure) | Not covered by this project | Art. 15-17 | n/a | n/a | Gap |
| 18 | Business associate / processor agreements | Not covered (legal) | Art. 28 | 164.308(b) BAA | 12.8 service providers | Gap |

## Coverage summary

| Framework | Requirements mapped | Verified | Designed | Gap |
|-----------|--------------------|----------|----------|-----|
| GDPR | 18 | 13 | 3 | 2 |
| HIPAA | 17 | 13 | 3 | 1 |
| PCI DSS | 17 | 13 | 3 | 1 |

Rows 10 and 12 count as Verified for the part that ran (substitute scan, management events); their remaining parts are listed under open gaps.

## Open gaps and next steps

1. Upgrade the account from the AWS Free plan to the paid plan (Macie and GuardDuty are not included in the Free plan), then run `scripts/02-macie-scan.sh` and `scripts/03-guardduty.sh` (rows 10, 11).
2. Create a CloudTrail trail with S3 data events for the restricted bucket, delivered to a separate log bucket with Object Lock (row 12, PCI 10.5).
3. Data subject request process and processor agreements are organisational and legal tasks outside this technical lab (rows 17, 18).
4. A real PCI DSS environment would also need network segmentation, vulnerability scanning and a QSA assessment; this lab only shows the data protection controls.
