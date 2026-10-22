# Week 3 Progress Log

## Session 1 — Project Setup

- Status: Project files and documentation are present locally.
- Project directory: `~/AWS-Data-Protection-upload-review/week-3-transit-secrets`
- Python environment: `.venv`
- Exact setup date: Not recorded.
- Evidence: Project documentation and source files.

## Session 2 — AWS Parameter Store

- Recorded date: 20 October 2026.
- Parameter name: `/week3/dev/app-name`
- Region: `eu-central-1` (Frankfurt).
- Tier: Standard.
- Parameter type: String.
- Recorded value: `week3-demo-api`.
- Result: Parameter existence and metadata were verified using AWS CLI.
- Additional test: `/week3/dev/demo-secret` was configured as a SecureString for demonstration.
- Evidence: `evidence/aws/01-parameter-created.png` and the parameter-read evidence file.
- Cost note: No new AWS resources should be created without checking potential costs first.

## Session 3 — API Security

- Application: FastAPI local demonstration in `src/api.py`.
- Health endpoint: `GET /health`.
- Protected endpoint: `GET /protected`.
- Authentication configuration: `DEMO_API_TOKEN` environment variable.
- Automated test result: 5 passed in the latest recorded run.
- Coverage: Health endpoint, missing token, unconfigured server token, valid token, invalid token.
- Evidence: `evidence/api/05-pytest-results.txt`.
- Deployment status: A deployment to AWS has not been confirmed.

## Session 4 — TLS, VPN, and Architecture

- Local TLS certificate and private-key match were checked.
- Certificate type: Local self-signed certificate.
- Certificate validity: Short-lived; verify its current validity before demonstrating it.
- Evidence: `evidence/tls/06-local-certificate.png` and `evidence/tls/07-certificate-key-match.png`.
- ACM: Public certificate deployment has not been confirmed.
- VPN/IPsec: Design documentation only; a live VPN connection has not been confirmed.
- Service-to-service communication: Architecture and security concepts documented.

## Session 5 — Final Review

- Latest recorded API test result: 5 passed.
- Documentation consistency review: README and core status wording reviewed; final evidence and secret review remain.
- Secret review: Must be completed before sharing or publishing the project.
- Git branch, commit, and push: Not recorded; GitHub work is currently paused.
- Remaining work: Inspect evidence image contents, review files for accidental secrets before sharing, and confirm the final deliverables against the assignment requirements.

## Session 6 — Current Review Run

- Recorded date: 22 October 2026.
- Project directory: `~/AWS-Data-Protection-upload-review/week-3-transit-secrets`.
- Python environment: `.venv-review` using Python 3.14.4.
- Test framework: pytest 9.1.1.
- API test result: 5 passed, 0 failed, 1 deprecation warning.
- Evidence: `evidence/api/06-pytest-results-review.txt`.
- Warning: `StarletteDeprecationWarning` related to `httpx` and `starlette.testclient`; tests passed despite the warning.
- Scope: Local API tests only; AWS deployment remains unconfirmed.
- - Git status: `.gitignore`, current test evidence, and documentation updates were prepared for staging and review; no commit or push performed.
