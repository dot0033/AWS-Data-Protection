# AWS Data Protection, Encryption & Privacy Compliance

## Week 3 — Encryption in Transit, Secrets & API Protection

**Project status: Completed within the documented lab scope.**

This project demonstrates practical cloud-security concepts through AWS Systems Manager Parameter Store, a locally tested FastAPI application, a local TLS certificate exercise, and security architecture documentation.

The project distinguishes verified lab results from conceptual designs and services that were not deployed.

## Objectives

- Explore TLS and certificate management with AWS Certificate Manager (ACM).
- Understand site-to-site VPN and IPsec security concepts.
- Implement and test API authentication behavior using FastAPI.
- Demonstrate AWS Systems Manager Parameter Store configuration management.
- Explore SecureString encryption and secrets-management practices.
- Document secure service-to-service communication.
- Record test results, evidence, limitations, and security considerations.

## Implementation Summary

| Component | Status | Result |
|---|---|---|
| AWS Systems Manager Parameter Store | Implemented and verified | `/week3/dev/app-name` metadata verified in `eu-central-1` |
| SecureString and AWS KMS | Lab tested and documented | Demo SecureString workflow recorded; see test documentation for the test details |
| FastAPI API security | Implemented and tested locally | Five automated tests passed |
| API health endpoint | Tested | `GET /health` |
| Protected API endpoint | Tested | `GET /protected`, including valid, invalid, and missing-token scenarios |
| Local TLS certificate | Implemented and tested | Self-signed certificate inspected and certificate/public-key match verified |
| AWS Certificate Manager | Concepts documented | Public ACM certificate deployment is not claimed |
| VPN/IPsec | Architecture documented | No live VPN tunnel is claimed |
| Secrets management | Implemented and documented within lab scope | Parameter Store demonstration and production recommendations documented; automatic rotation is not claimed |
| Service-to-service communication | Architecture documented | Security boundaries and recommended controls described |
| Automated test evidence | Recorded | Latest local API run: 5 passed, 0 failed, 1 warning |
| Project documentation and evidence | Prepared | Supporting documentation and lab evidence are organized in the project |

## API Security Test Results

The FastAPI demonstration was tested locally using pytest.

| Test | Expected behavior | Result |
|---|---|---|
| Health endpoint | Returns a healthy response | PASS |
| Protected endpoint without a token | Rejects the request | PASS |
| Server token not configured | Returns HTTP 503 | PASS |
| Valid token | Authorizes the request | PASS |
| Invalid token | Rejects the request | PASS |

**Latest recorded result:** `5 passed, 0 failed, 1 warning`.

The warning concerns deprecated `httpx` integration with `starlette.testclient`. It did not cause the tests to fail.

Detailed evidence: `evidence/api/06-pytest-results-review.txt`.

## AWS Parameter Store

The project includes a demonstration parameter:

- **Parameter:** `/week3/dev/app-name`
- **Type:** `String`
- **Recorded value:** `week3-demo-api`
- **Region:** `eu-central-1` (Frankfurt)

A separate demonstration parameter, `/week3/dev/demo-secret`, was used to document SecureString and encryption/decryption behavior. The recorded demo values are not production credentials.

See `docs/secrets-management.md` and the relevant files in `evidence/aws/`.

## TLS and Certificate Handling

The local TLS exercise used a self-signed certificate generated with OpenSSL.

- Certificate subject and issuer: `localhost`
- Key type: RSA
- Key size: 2048 bits
- Subject Alternative Names: `localhost` and `127.0.0.1`
- Certificate and corresponding public-key match: verified in the recorded lab
- Certificate type: local self-signed certificate, not a publicly trusted ACM certificate

The certificate was short-lived and intended for demonstration purposes. Its current validity should be checked before reuse.

Evidence:
- `evidence/tls/06-local-certificate.png`
- `evidence/tls/07-certificate-key-match.png`

## VPN/IPsec and Secure Service Communication

The project documents a reference site-to-site VPN architecture and secure communication between clients, APIs, and backend services.

The documentation covers encryption in transit, authentication, integrity, least privilege, network boundaries, and operational considerations.

These sections are architecture and design deliverables. They do not claim that a production VPN, public TLS endpoint, or deployed multi-service environment was created.

See:
- `docs/vpn-ipsec.md`
- `docs/service-communication.md`
- `docs/tls-acm.md`

## Security and Cost Considerations

- Do not commit real credentials, API tokens, private keys, or production secrets.
- Use least-privilege IAM permissions for workloads and administrators.
- Choose the appropriate Parameter Store parameter type for the sensitivity of the data.
- Review AWS pricing and account credits before creating potentially billable resources.
- Clearly distinguish local demonstrations from deployed cloud infrastructure.
- Treat the included API token and parameter values as demonstration data only.

## Project Structure

```text
week-3-transit-secrets/
├── README.md
├── .gitignore
├── docs/
│   ├── api-security.md
│   ├── progress-log.md
│   ├── secrets-management.md
│   ├── service-communication.md
│   ├── test-results.md
│   ├── tls-acm.md
│   └── vpn-ipsec.md
├── evidence/
│   ├── api/
│   ├── aws/
│   └── tls/
├── src/
│   └── api.py
├── tests/
│   └── test_api.py
└── requirements.txt
```

## Final Deliverables

- Technical documentation for API security, TLS/ACM, VPN/IPsec, secrets management, and service communication.
- Local FastAPI implementation and automated test suite.
- AWS Parameter Store demonstration and recorded evidence.
- TLS certificate inspection and certificate/public-key matching evidence.
- Test results, project progress log, and supporting screenshots.

## Final Status and Scope Limitations

**The planned local lab, documentation, and recorded test activities are complete within the scope described above.**

This status does not mean every architecture was deployed as production AWS infrastructure. Specifically:

- The API was tested locally; deployment to AWS is not confirmed.
- The TLS exercise used a local self-signed certificate; public ACM certificate deployment is not confirmed.
- VPN/IPsec and service-to-service communication are documented designs, not verified production deployments.
- Automatic secret rotation is documented as a recommended workflow, not claimed as implemented.
- The latest API test run passed all five tests, with one non-fatal deprecation warning.

For reproducibility, review `docs/test-results.md` and `docs/progress-log.md` alongside the evidence directory.
