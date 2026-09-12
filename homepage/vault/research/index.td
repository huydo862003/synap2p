
This section documents the research needed to inform the decisions for this project.

## Aims of The Project

Broadly speaking, this project aims to allow 2 Internet users talk to each other out of the box. One basic scenario we desire to support:

1. One user uses the CLI to obtain a code.
2. That user sends the code to connect to the other person.
3. The other person uses that code to establish the connection using the CLI tool.

There can be other more advanced use cases and security for example can be another important factor.

## Scope of Project

This is just a short running project - just a PoC out of pure curiosity.

This project only focuses on:

- Research:
  - A reliable NAT traversal technique over various NAT configurations.
  - Security for P2P.
- Deliverable:
  - A CLI allowing users to selectively/securely connect to each other without a self-hosted server between them.
  - Based on this connection, the user can talk to each other via some standard API.

## Research Roadmap

Here's the entire roadmap for this project research. Mostly I will skim it.

### NAT Traversal

This phase focuses on the basic mechanisms that allow peers on the Internet to talk to each other without a dedicated server.

1. [NAT Basics](./01-nat-traversal/01-nat-traversal): What NAT is, why it exists, how mapping tables work
2. [NAT Types & Behavior](./01-nat-traversal/02-nat-types): The four classic types, RFC 4787 taxonomy, CGNAT, mapping lifetimes, hairpin NAT, mobile networks, IPv6
3. [NAT Traversal Techniques](./01-nat-traversal/03-nat-traversal-techniques): Overview of approaches: STUN, hole punching, UPnP/NAT-PMP/PCP, ICE, relay
  1. [STUN Protocol](./01-nat-traversal/04-techniques/01-stun): RFC 8489, message format, XOR-MAPPED-ADDRESS, NAT type detection (RFC 5780), public servers
  2. [Hole Punching](./01-nat-traversal/04-techniques/02-hole-punching): UDP hole punching, TCP simultaneous open, port prediction for symmetric NAT, CGNAT traversal, timing coordination
  3. [UPnP / NAT-PMP / PCP](./01-nat-traversal/04-techniques/03-upnp-natpmp-pcp): UPnP IGD, NAT-PMP (RFC 6886), PCP (RFC 6887), detection and fallback strategy
  4. [ICE Framework](./01-nat-traversal/04-techniques/04-ice): RFC 8445, candidate types, Trickle ICE, ICE-lite, simplified ICE for CLI tools
  5. [Relay & Fallback](./01-nat-traversal/04-techniques/05-relay-fallback): TURN (RFC 8656), peer relay, DERP-style relay, failure modes, keepalive strategies
4. Reference Implementations
  1. [libp2p](./01-nat-traversal/05-references/01-libp2p): AutoNAT, Circuit Relay v2, DCUtR
  2. [QUIC](./01-nat-traversal/05-references/02-quic): quinn/quiche, connection migration, 0-RTT
  3. [Magic Wormhole](./01-nat-traversal/05-references/03-magic-wormhole): Mailbox server, PAKE, connection string design
  4. [Tailscale / WireGuard](./01-nat-traversal/05-references/04-tailscale-wireguard): DERP relay, coordination server, hard NAT handling
  5. [ZeroTier](./01-nat-traversal/05-references/05-zerotier): Root servers, peer discovery, encrypted protocol

### P2P Security

This phase focuses on securing P2P connections, organized by attack surface.

1. Signaling: Connection string exchange, out-of-band channel
  1. [Vulnerabilities](./02-p2p-security/01-signaling/01-vulnerabilities): Insecure out-of-band exchange, connection string tampering
  2. [Attacks](./02-p2p-security/01-signaling/02-attacks): Connection string interception, public key substitution
  3. [Mitigations](./02-p2p-security/01-signaling/03-mitigations): Encrypted sharing channels, fingerprint verification
2. Discovery: STUN queries, NAT probing, UPnP
  1. [Vulnerabilities](./02-p2p-security/02-discovery/01-vulnerabilities): Untrusted STUN responses, UPnP exposure, IP leakage
  2. [Attacks](./02-p2p-security/02-discovery/02-attacks): STUN spoofing, port scanning, NAT mapping hijack
  3. [Mitigations](./02-p2p-security/02-discovery/03-mitigations): Multi-server validation, candidate filtering, UPnP hardening
3. Handshake: Key exchange, Noise protocol negotiation
  1. [Vulnerabilities](./02-p2p-security/03-handshake/01-vulnerabilities): Weak key exchange, missing mutual authentication
  2. [Attacks](./02-p2p-security/03-handshake/02-attacks): MITM, key replay, downgrade attacks
  3. [Mitigations](./02-p2p-security/03-handshake/03-mitigations): Noise KK pattern, ephemeral keys, transcript binding
4. Transport: Encrypted data channel
  1. [Vulnerabilities](./02-p2p-security/04-transport/01-vulnerabilities): Nonce reuse, missing integrity, metadata leakage
  2. [Attacks](./02-p2p-security/04-transport/02-attacks): Eavesdropping, replay, tampering, traffic analysis
  3. [Mitigations](./02-p2p-security/04-transport/03-mitigations): ChaCha20-Poly1305 AEAD, forward secrecy, padding
5. Relay: Intermediary when direct connection fails
  1. [Vulnerabilities](./02-p2p-security/05-relay/01-vulnerabilities): Relay as trust point, traffic visibility, single point of failure
  2. [Attacks](./02-p2p-security/05-relay/02-attacks): Traffic correlation, resource exhaustion, amplification
  3. [Mitigations](./02-p2p-security/05-relay/03-mitigations): End-to-end encryption, untrusted relay model, rate limiting
