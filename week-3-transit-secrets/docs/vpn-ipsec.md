# VPN and IPsec Architecture

## 1. Objective

This document describes a reference site-to-site VPN architecture and the security properties provided by IPsec.

## 2. Reference Architecture

    On-Premises Network
          |
          v
    Customer Gateway Device
          |
          | IPsec VPN tunnel over an untrusted network
          |
          v
    AWS VPN Endpoint
          |
          v
    Amazon VPC and Private Resources

This diagram is a conceptual architecture. It is not evidence that a VPN tunnel or VPN gateway was created in the AWS account.

## 3. IPsec Security Properties

IPsec can provide network-layer protection between configured peers, including:

- Confidentiality through encryption.
- Integrity protection against unauthorized modification.
- Peer authentication, depending on the selected configuration.
- Replay protection through supported protocol mechanisms.

The exact protections depend on the negotiated algorithms, authentication method, and tunnel configuration.

## 4. Site-to-Site VPN Design Considerations

A production design should consider:

1. Non-overlapping on-premises and VPC CIDR ranges.
2. Appropriate customer gateway and AWS-side configuration.
3. Strong supported cryptographic proposals.
4. Secure storage and rotation of authentication material.
5. Routing configuration and access restrictions.
6. Tunnel health monitoring and alerting.
7. Redundancy and failover requirements.
8. Operational ownership and incident response.

AWS Site-to-Site VPN commonly uses IPsec tunnels to connect a customer network with an AWS network endpoint.

## 5. Security Boundaries

A VPN tunnel protects traffic between configured tunnel endpoints. It does not automatically make every resource behind those endpoints trusted.

Additional controls should include least-privilege security group rules, network ACLs where appropriate, host-level controls, identity-based access, and application-layer encryption where required.

## 6. Cost and Implementation Scope

This project documents the architecture and security considerations only. No AWS VPN gateway, customer gateway resource, or VPN tunnel is claimed as deployed.

Before implementing a real VPN, review the current AWS pricing, account credits, network requirements, and cleanup procedure.
