# AWS Data Protection, Encryption & Privacy Compliance

## Week 3: Encryption in Transit, Secrets & API Protection

**Project scope:** Secure communication, TLS, VPN/IPsec concepts, API security, secrets management, and service-to-service communication.

## Objectives

- Understand TLS and certificate management with AWS Certificate Manager.
- Explore VPN and IPsec architecture.
- Implement and test a local API authentication example.
- Demonstrate secure configuration management with AWS Systems Manager Parameter Store.
- Document AWS Secrets Manager, secret rotation, and least privilege.
- Design secure communication between services.

## Implementation Status

| Component | Status | Notes |
|---|---|---|
| AWS Systems Manager Parameter Store | Implemented and tested | Existing `/week3/dev/app-name` parameter verified |
| SecureString encryption and decryption | Implemented and tested | `/week3/dev/demo-secret` retrieved encrypted and decrypted successfully |
| Local API security | Implemented and tested | Health endpoint and protected endpoint tests passed |
| TLS local certificate lab | Implemented and tested | Local self-signed certificate inspected; certificate/key match verified |
| TLS / AWS Certificate Manager (ACM) documentation | Documented | Public ACM certificate deployment is not confirmed |
| VPN / IPsec design | Documented | A production VPN connection has not been deployed |
| Secrets management | Documented | AWS Parameter Store SecureString tested; rotation is not confirmed |
| Service-to-service communication | Documented | Architecture and security concepts documented |
| Test results | Updated | API tests: 5 passed; AWS-01 and AWS-02 passed |
| Evidence and final report | Final review pending | Evidence files exist; final security review remains |

## Scope and Limitations

- The API tests were executed locally; the API has not been confirmed as deployed to AWS.
- The TLS lab uses a local self-signed certificate, not a publicly trusted ACM certificate.
- The VPN/IPsec and service-to-service sections document the design; they do not prove a live production deployment.
- The SecureString value used in testing is a harmless demonstration value, not a real credential.

## Security and Cost Notes

- Never commit credentials, API tokens, private keys, or real secrets.
- Use Standard Parameter Store parameters unless a documented requirement needs another tier.
- No paid AWS infrastructure should be created without reviewing its estimated cost.
- Local simulations and theoretical designs must be clearly identified as such.

## Evidence

Screenshots and sanitized test outputs are stored in the `evidence/` directory.

## Final Deliverables

- Technical documentation
- Architecture diagrams
- Test results
- Sanitized screenshots
- Final security assessment
