---
_label: "[Dedicated Reading] RFC 2663: IP Network Address Translator (NAT) Terminology and Considerations"
_icon: icon.globe
---

This is an **informational** IETF RFC, meaning it documents and defines terminology rather than specifying a protocol that implementations must follow. It doesn't mandate anything on its own.

::: details What are the types of IETF RFCs?
RFCs are published under different statuses, which tells you what kind of document it is:

- **Standards Track**: defines a protocol the Internet is expected to adopt.
  - It goes through stages: Proposed Standard, then Internet Standard.
  - It uses strict language like MUST, SHALL, REQUIRED (defined in RFC 2119).
- **Best Current Practice (BCP)**: Documents operational or process best practices.
  - It is not a protocol spec, but carries weight in how the Internet is run.
- **Informational**: shares useful reference material with the community.
  - It has no requirements, no conformance expected.
- **Experimental**: describes experimental work that isn't ready for standardization yet.
- **Historic**: the document is obsolete, kept around for reference.

:::

::: details How do you identify the type of an RFC?
You can tell which one you're looking at from the "Status of this Memo" section at the top of every RFC. The word "memo" itself is a historical artifact from the ARPANET era, when these were literally memos passed around the research community.
:::

::: details What does "informational" mean for RFC 2663 specifically?
It means the RFC defines NAT terminology without mandating that anyone implement or follow it. There's no conformance requirement attached.

In practice though, it became the de facto standard vocabulary because other RFCs (like RFC 4787) adopted its terms by convention. So it functions as the canonical reference for NAT concepts, not through mandate, but through widespread adoption.
:::

The RFC's purpose: "NAT" means different things in different contexts, so this document exists to **define the various flavors** and **standardize the terminology** around them.

## Abstract

- NAT **maps IP addresses between address realms** so that **routing stays transparent to the hosts involved**.
- The _classic setup_ is a private network with unregistered addresses on one side, and the public Internet with globally unique addresses on the other.
  ::: note
  It's by no means the only setup.
  :::

This document:

1. Covers how NAT devices work.
2. Pins down the terminology for the different flavors of NAT. (It doesn't explain their operations though)
3. Describes other considerations applicable to NAT devices in general. (It does not explain the use cases in which NATs can be applied)

## Why NAT (According to them)?

The need for IP address translation comes up when **internal addresses** can't be used outside the network. Two reasons:

- The internal addressing needs to stay hidden from the outside world for privacy or security reasons. -> That's why one would like to use internal addresses.
- The addresses are invalid externally, like private address space that has no meaning on the public Internet.

=> Address translation allows hosts in a private network to transparently communicate with destinations on an external network and vice versa (with exceptions).

## Some Scenarios Where NATs Cannot Support Well

How NAT achieves transparency is essentially rewriting **addresses in-flight** and **tracks session state** so packets reach the right host on either side.

Consequently, it only works when apps don't embed IP addresses in the payload.

-> In these cases, using DNS names instead of hardcoded IPs keeps apps NAT-friendly.

Where it breaks down:

- **Apps that embed IPs in the payload** need an **Application Level Gateway (ALG)** to rewrite the payload too.
  ::: details What is an ALG?
  An ALG is a component (usually built into the NAT device) that understands a specific application protocol and rewrites IP addresses inside the payload, not just the header. For example, FTP sends its own IP address in the payload to tell the server where to connect back. Without an ALG, NAT rewrites the header but leaves the payload address untouched, so the server connects to the wrong address. The FTP ALG intercepts this and fixes the payload too.
  :::
- **IPsec (AH/ESP)** cryptographically protects the IP header from modification, which directly conflicts with what NAT does.

## Terminologies

### Address Realm/Realm

A **network domain** where:

1. Addresses are uniquely assigned  to entities.
2. Routing protocols in the network allow datagrams can be routed to their destinations.

> As I have stated in ${fref("research/01-nat-traversal/01-nat-basics/01-revision.td")}, a **network** mainly refers to the interconnection topology & routing protocol.

### Transparent Routing

It refers to the **routing** of a datagram between **disparate address realms** by modifying address contents in the IP header to be valid in the destination realm.

Only applies to NATs, not traditional routers.

### Session Flow vs Packet Flow

Directions are defined relative to a **network interface**: **outbound** means leaving the private network toward the external realm, **inbound** means arriving from the external realm.

**Session flow** and **packet flow** are not the same thing:

- **Session flow**: the direction a session was initiated, relative to a network interface.

  For example, a telnet session started from inside the network is an **outbound session flow**.
- **Packet flow**: the direction individual packets travel, relative to a network interface.

  For example, that same telnet session has both outbound packets (keystrokes) and inbound packets (screen output from the server).

### TU Ports/Server Port/Client Port

TCP/UDP ports associated with an IP address.

- Ports 0-1023 are server ports.
- Ports 1024-65535 are client ports (by convention, not always followed).

### Session

A contextful communication channel between two devices.

A session is identified by the 5-ary tuple of (protocol, src IP, src port, dst IP, dst port).

-> The NAT's view of a session may not match the application's. (NAT translates the src IP + src port)

#### Start of (TCP/UDP) Session

- **TCP**: first packet with SYN set and ACK absent in the TCP header flags. All subsequent TCP packets must have ACK set.
- **UDP**: no deterministic signal, as UDP is connection-less (it has no notion of sessions). Heuristic: first packet with a new session tuple.

#### End of Session

- **TCP**: FIN acknowledged by both sides, or RST received by either half.
  - Nunace: However, NAT can't know whether those segments were actually delivered (they may be dropped and retransmitted), so it can't safely treat them as the final packets. A session is only assumed terminated after 4 minutes following detection (2 \* MSL per RFC 793).
  - **Silent termination**: a TCP connection can die without NAT knowing (e.g., a peer reboots). NAT needs garbage collection to clean up stale state, but can't distinguish idle connections from dead ones.
    - **Timeout heuristics**: TCP sessions idle for 24 hours and non-TCP sessions idle for a few minutes are commonly assumed terminated. Timeouts must be configurable since there's no universally correct value, and NAT's idea of termination may not match the application's.
    - **Alternative**: timestamp entries and evict the longest-idle session when space is needed, rather than relying on fixed timeouts.
- **UDP**: no signal. Heuristic: idle timeout, typically a few minutes. Must be configurable.

### Public/Global/External Network

Address realm with globally unique addresses assigned by IANA or equivalent.

### Private/Local Network

Address realm independent of external addresses, also called Local Network. A NAT router facilitates transparent routing between the private realm and the external realm.

RFC 1918 reserves three blocks for private internets:

- `10/8` (a single class A network in pre-CIDR terms)
- `172.16/12` (16 contiguous class B networks)
- `192.168/16` (256 contiguous class C networks)

Any organization can use these ranges without coordinating with IANA, APNIC, RIPE, or ARIN.

Multiple independent organizations can use the same private ranges simultaneously with no conflict. If they later need to reach each other or the public Internet, they either renumber their networks or enable NAT on their border routers.

### ALG (Application Level Gateway)

- An application-specific agent that rewrites payload contents so apps that embed IPs or ports in their payload can work transparently across NAT.
- Can interact with NAT to set up state, rewrite payload, or do whatever the app needs.
- Purpose-built for a specific protocol (FTP, SIP, H.323, etc.), rewriting at the address/port level to fix NAT incompatibilities.
