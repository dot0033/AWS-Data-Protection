# TLS and AWS Certificate Manager

## 1. Objective

This document explains the local TLS certificate demonstration and the role of AWS Certificate Manager (ACM) in certificate lifecycle management.

## 2. Local OpenSSL Demonstration

A self-signed RSA certificate was generated locally using OpenSSL.

Recorded certificate details:

| Property | Result |
|---|---|
| Common Name | `localhost` |
| Issuer | `localhost` |
| Key type | RSA |
| Key size | 2048 bits |
| Validity period | Two days |
| Subject Alternative Names | `DNS:localhost`, `IP:127.0.0.1` |

The certificate's recorded validity interval was:

- Not before: 21 October 2026, 13:25:08 GMT
- Not after: 23 October 2026, 13:25:08 GMT

The certificate and its private key were created in `/tmp/week3-tls-lab`.

## 3. Public-Key Matching Test

The public key was extracted from the certificate:

    openssl x509 -in server.crt -pubkey -noout | sha256sum

The public key was also derived from the private key:

    openssl pkey -in server.key -pubout | sha256sum

Both commands returned the same SHA-256 hash:

    dfac8434c340acd9403b7caf952d97831cfe716aa591af9d3ea93789cf8856d2

This verifies that the public key in the certificate matches the public key derived from the corresponding private key.

This check does not, by itself, verify certificate trust or prove that a live TLS connection works.

## 4. Self-Signed Certificate Limitations

A self-signed certificate is suitable for a controlled local demonstration, but it is not automatically trusted by browsers or external clients.

The certificate is not an ACM-issued certificate. Its short validity period is intentional for this exercise. A new certificate can be generated for a later demonstration if necessary.

## 5. AWS Certificate Manager Concepts

ACM manages supported TLS certificates for integration with eligible AWS services. Depending on the certificate type and use case, obtaining a public certificate can require domain control validation.

A production certificate workflow should include:

1. Selecting the correct certificate type and domain names.
2. Completing the required validation.
3. Attaching the certificate to a supported service.
4. Monitoring certificate status and renewal.
5. Protecting any separately managed private keys.

## 6. Evidence

Expected evidence files:

- `evidence/tls/06-local-certificate.png`
- `evidence/tls/07-certificate-key-match.png`

Evidence file paths are listed above. Confirm the screenshot contents before final submission.

## 7. Scope Limitations

This project performed a local certificate-generation and public-key-matching demonstration. It does not claim that a public ACM certificate was issued, a public domain was configured, or a production TLS endpoint was deployed.
