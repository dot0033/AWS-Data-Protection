# API Security

## 1. Objective

This document describes the API security controls implemented in the Week 3 project. The demonstration uses FastAPI and a bearer-token authentication mechanism.

## 2. Implemented Components

- FastAPI application: `src/api.py`
- Health endpoint: `GET /health`
- Protected endpoint: `GET /protected`
- Configuration: `DEMO_API_TOKEN` environment variable
- Authentication scheme: HTTP Bearer token
- Token comparison: Python `secrets.compare_digest`
- Automated tests: `tests/test_api.py`

## 3. Endpoint Behavior

### GET /health

Returns an HTTP 200 response when the application is running.

Example response:

    {"status": "ok"}

This endpoint is intended for basic application health checks. It does not establish that every dependency is healthy.

### GET /protected

Requires an Authorization header in the following format:

    Authorization: Bearer <token>

Expected behavior:

| Condition | Expected HTTP Status |
|---|---:|
| Missing token | 401 Unauthorized |
| Invalid token | 401 Unauthorized |
| Valid token | 200 OK |
| Server token not configured | 503 Service Unavailable |

The application uses `secrets.compare_digest` to compare the expected authorization value with the supplied value.

## 4. Configuration and Security Considerations

The demonstration token is supplied through the `DEMO_API_TOKEN` environment variable rather than being hard-coded into the application source.

The local test token is for demonstration purposes only. It must not be reused as a production credential.

For a production deployment:

- Use HTTPS to protect credentials in transit.
- Store production secrets in an appropriate secret-management service.
- Apply authentication and authorization appropriate to the application.
- Validate token expiration, issuer, audience, and other relevant claims when using a token standard that supports them.
- Apply rate limiting, request validation, logging, and monitoring.
- Avoid logging authorization headers or secret values.
- Use a dedicated least-privilege identity for AWS access.

## 5. Verification

The following automated tests passed in the local environment:

- Health endpoint returns HTTP 200.
- Protected endpoint rejects a request without a token when authentication is configured.
- Protected endpoint returns HTTP 503 when the server token is not configured.
- Protected endpoint accepts the configured test token.
- Protected endpoint rejects an incorrect token.

Recorded result: `5 passed`.

The local tests do not constitute a production security audit.

## 6. Scope Limitations

This is a local educational API demonstration. A public API gateway, production identity provider, WAF, rate limiting, and deployed HTTPS endpoint have not been claimed as implemented by this document.
