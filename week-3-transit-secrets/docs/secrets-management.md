# Secrets Management

## 1. Objective

This document describes the use of AWS Systems Manager Parameter Store and the design considerations for protecting application configuration and secrets.

## 2. Implemented: Parameter Store Demonstration

Two Parameter Store demonstrations were tested: a standard String parameter for application configuration and a SecureString parameter for encrypted demonstration data.

| Property | Recorded Value |
|---|---|
| Parameter name | `/week3/dev/app-name` |
| Parameter type | `String` |
| Parameter value | `week3-demo-api` |
| Version | `1` |
| AWS Region | `eu-central-1` |

The parameter contains a non-sensitive application identifier. It is configuration data, not a password or private credential.

Evidence recorded for this operation: `evidence/aws/01-parameter-created.png`.

## 3. Parameter Store and Secrets Manager

### Systems Manager Parameter Store

Parameter Store can hold application configuration and supports different parameter types. `SecureString` parameters use AWS KMS encryption.

### AWS Secrets Manager

Secrets Manager is designed for managing sensitive values such as database credentials, API keys, and other application secrets. It supports versioning and can support automated rotation when an appropriate rotation configuration and compatible target are configured.

The two services have different features and pricing. The correct choice depends on the secret lifecycle, rotation requirements, integration needs, and cost constraints.

## 4. Recommended Production Workflow

1. Create a secret or secure parameter using an appropriately authorized identity.
2. Apply least-privilege IAM permissions to the workload that needs access.
3. Encrypt sensitive values at rest using the service's supported encryption features.
4. Retrieve the value at runtime over authenticated AWS API connections.
5. Avoid embedding secrets in source code, logs, screenshots, or Git history.
6. Rotate credentials according to the application's requirements.
7. Validate the replacement credential before retiring the previous credential.
8. Monitor access and investigate unexpected retrieval activity.

## 5. Rotation Design

A typical rotation workflow is:

1. Generate or obtain a replacement credential.
2. Update the target service with the new credential.
3. Publish the new secret version.
4. Update or refresh consuming applications.
5. Verify successful authentication.
6. Retire the previous credential when safe to do so.
7. Record and monitor the rotation outcome.

The exact sequence depends on the target system and whether overlapping credentials are supported.

## 6. Security Notes

- The Parameter Store value in this project is a demo application name, not a secret.
- The local API token used for tests is also a demonstration value.
- Never commit production credentials, private keys, or access tokens.
- Do not assume that a parameter is encrypted merely because it is stored in Parameter Store; select the appropriate parameter type.
- Use least-privilege IAM policies and review AWS costs before enabling additional services.

## 7. Scope Limitations

The project tested reading a standard String parameter and retrieving a SecureString parameter both as ciphertext and with decryption. A production Secrets Manager secret, automatic rotation workflow, and production credential integration have not been implemented.
