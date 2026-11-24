# 01 - Sensitive Data Discovery (Macie) Findings Report

## Summary

| Item | Result |
|------|--------|
| Date | 2026-11-24 |
| Region | eu-central-1 (Frankfurt) |
| Target | `dp-lab-w4-sample-<ACCOUNT_ID>` (temporary lab bucket, deleted after the lab) |
| Objects scanned | 4 |
| Objects with sensitive data | 3 (75%) |
| Highest severity | High |
| False positives | 0 (`public-faq.txt` correctly returned no findings) |
| Tool used | `scripts/06-pii-scan.py` (Macie substitute, see below) |
| Amazon Macie job | Not run: the account is on the AWS Free plan, which does not include Macie |

## Why Macie itself did not run

`aws macie2 enable-macie` failed with `SubscriptionRequiredException` ("The AWS Access Key Id needs a subscription for the service"). GuardDuty and Security Hub returned the same error, while S3, STS and CloudTrail worked.

The cause is the account plan. `aws freetier get-account-plan-state` returns `accountPlanType: FREE`. The AWS Free plan does not include Macie, GuardDuty or Security Hub; they become available only after upgrading the account to the paid plan. Upgrading is irreversible and was not done, to keep the project at $0 and within the Free plan.
Evidence: `evidence/02-macie-guardduty-subscription-error.txt`, `evidence/02-macie-subscription-error.png`.

To keep the lab at $0 and still produce real findings, the same discovery logic was run with a small Python scanner. The Macie job script (`scripts/02-macie-scan.sh`) is included and ready to run if the account is upgraded to the paid plan.

## Method

1. `scripts/01-create-sample-bucket.sh` created a private bucket (Block Public Access on, default encryption, `DataClassification=restricted`) and uploaded four **synthetic** files from `sample-data/`. No real personal data was used; card numbers are public test numbers and the AWS keys are the documentation examples.
2. `scripts/06-pii-scan.py` read every object through the S3 API and applied Macie-style managed identifiers: a regex, a validator (Luhn check for cards) and required nearby keywords (for SSN, passport, card, date of birth, credentials), which is the same approach Macie uses to cut false positives.
3. Results were written in a Macie-like shape (finding type, severity, object, detection type, count). Only masked values are stored.

## Findings

| # | Object | Finding type | Severity | Detections |
|---|--------|--------------|----------|------------|
| 1 | `app-config.env` | SensitiveData:S3Object/Credentials | High | AWS_CREDENTIALS x2 |
| 2 | `customers.csv` | SensitiveData:S3Object/Multiple | High | CREDIT_CARD_NUMBER x3, USA_SOCIAL_SECURITY_NUMBER x3, EMAIL_ADDRESS x3, PHONE_NUMBER x3 |
| 3 | `support-ticket.txt` | SensitiveData:S3Object/Multiple | High | CREDIT_CARD_NUMBER x1, USA_PASSPORT_NUMBER x1, PHONE_NUMBER x1, DATE_OF_BIRTH x1 |
| - | `public-faq.txt` | none | - | - |

Totals: 20 sensitive values in 3 objects. Full output: `evidence/pii-scan-findings.json`, `evidence/06-pii-scan-output.txt`, `evidence/06-pii-scan-cloudtrail-verify.png`.

## Interpretation

| Finding | Risk | Action under the DLP plan (`02-dlp-plan.md`) |
|---------|------|----------------------------------------------|
| Credentials in a config file | Account takeover if the file leaks | Rotate the keys immediately, move secrets to Secrets Manager / Parameter Store SecureString (Week 3), block `.env` uploads |
| Card numbers next to names and SSNs | PCI DSS scope; highest fine and fraud risk | Remove full PAN, keep only tokens or last 4 digits; data must live only in the restricted, KMS-encrypted bucket |
| Passport number and date of birth in a support ticket | Identity theft; GDPR personal data | Redact in the ticketing tool before export; shorten retention |
| Public FAQ | None | Correctly classified as public |

## Macie configuration to use after upgrading to the paid plan

| Setting | Value | Reason |
|---------|-------|--------|
| Automated sensitive data discovery | Disabled during the lab, enabled for prod | Lab cost control; prod needs continuous coverage |
| Job type | One-time for the lab, scheduled weekly for restricted and confidential buckets | Cost scales with GB scanned |
| Managed identifiers | Recommended set | Covers credentials, financial and personal data |
| Custom identifier | `policies/macie-custom-identifier-employee-id.json` | Internal ID formats Macie cannot know |
| Restricted bucket access | `policies/macie-restricted-bucket-statement.json` + `policies/macie-restricted-kms-statement.json` | The Week 2 Deny statements otherwise block Macie (see HANDOFF.md) |
| Findings routing | `policies/eventbridge-high-severity-findings.json` -> SNS | High findings reach the owner within minutes |
| Findings retention | Export to the confidential bucket (SSE-KMS) | Macie keeps findings only 90 days |

## Cost

| Item | Cost |
|------|------|
| S3 storage and requests (1.1 KB, about 15 minutes) | ~$0.00 |
| CloudTrail event history | Free |
| CloudShell | Free |
| Macie / GuardDuty | $0 (not available on the Free plan) |
| **Total** | **~$0.00** |
