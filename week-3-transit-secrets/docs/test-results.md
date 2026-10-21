## TLS Certificate Tests

| Test ID | Test | Expected Result | Actual Result | Status |
|---|---|---|---|---|
| TLS-01 | Inspect local TLS certificate | Certificate details are displayed | Subject and issuer are localhost; validity dates displayed | PASS |
| TLS-02 | Compare public-key hashes | Hashes match | Both SHA-256 hashes match | PASS |

### Notes

- Generated a local self-signed RSA 2048-bit certificate using OpenSSL.
- The certificate includes localhost and 127.0.0.1 subject alternative names.
- The certificate is valid for two days for demonstration purposes.
- The certificate is not a publicly trusted ACM certificate.
- The private key is stored outside the project directory.
## API Security Tests

| Test ID | Test | Expected Result | Actual Result | Status |
|---|---|---|---|---|
| API-01 | Health endpoint | Returns HTTP 200 and healthy status | Passed in pytest | PASS |
| API-02 | Protected endpoint without token | Request is rejected with HTTP 401 | Passed in pytest | PASS |
| API-03 | Protected endpoint with valid token | Request is authorized | Passed in pytest | PASS |
| API-04 | Protected endpoint with invalid token | Request is rejected with HTTP 401 | Passed in pytest | PASS |
| API-05 | Protected endpoint when token is not configured | Returns HTTP 503 | Passed in pytest | PASS |

### API Test Notes

- Test framework: pytest 9.1.1.
- Application framework: FastAPI.
- Latest recorded run: 5 passed, 0 failed.
- A Starlette deprecation warning related to `httpx` appeared; it did not cause test failures.
- Automated tests were run locally. This does not mean the API was deployed to AWS.

## AWS Parameter Store Tests

| Test ID | Test | Expected Result | Actual Result | Status |
|---|---|---|---|---|
| AWS-01 | Read `/week3/dev/app-name` | Parameter value is returned | Returned `week3-demo-api`, type `String`, version 1 | PASS |
| AWS-02 | Verify encrypted `SecureString` parameter | Encrypted value is stored and can be decrypted with permission | Retrieved encrypted ciphertext without `--with-decryption`; recovered the expected test value with `--with-decryption`; type `SecureString`, version 1 | PASS |

### AWS Test Notes

- Region: `eu-central-1`.
- `/week3/dev/app-name` remains a standard `String`; it was not modified.
- `/week3/dev/demo-secret` is a standard-tier `SecureString` encrypted using AWS KMS.
- Reading the `SecureString` without `--with-decryption` returned ciphertext; reading it with `--with-decryption` returned the expected test value.
- The test value is a harmless demo value, not a real credential.
