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
