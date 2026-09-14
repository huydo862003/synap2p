---
_type: Research
_label: "NAT Types & Behavior"
_icon: icon.library
status: 'draft'
---

This section covers:

Taxonomy:

- A high-level overview of the classic NAT types.
- The RFC 4787 behavioral taxonomy (the modern way to think about it).

Properties:

- NAT mapping lifetimes and keepalives.
- Hairpin NAT.

Real-world:

- Carrier-Grade NAT (CGNAT) and how it stacks.
- Mobile networks and their quirks.
- IPv6 and what it changes.
- Real-world distribution stats.

This is based on:

- [RFC 2663](https://datatracker.ietf.org/doc/html/rfc2663): NAT Terminology and Considerations (section 4.0 covers the various NAT flavors)
- [RFC 3489](https://datatracker.ietf.org/doc/html/rfc3489): STUN - Simple Traversal of User Datagram Protocol (origin of the classic four-type taxonomy)
- [RFC 4787](https://datatracker.ietf.org/doc/html/rfc4787): NAT Behavioral Requirements for Unicast UDP
- [RFC 6888](https://datatracker.ietf.org/doc/html/rfc6888): Requirements for Carrier-Grade NAT
- [RFC 6598](https://datatracker.ietf.org/doc/html/rfc6598): IANA-Reserved IPv4 Prefix for Shared Address Space
- [RFC 6146](https://datatracker.ietf.org/doc/html/rfc6146) / [RFC 6147](https://datatracker.ietf.org/doc/html/rfc6147): Stateful NAT64 and DNS64

## Taxonomy

### RFC 2663: Various NAT Flavors & RFC 3489: The Classic Four Types

#### RFC 2663 Various NAT Flavors

See the preceding note in ${fref("research/01-nat-traversal/01-nat-basics/02-rfc-2663.td")}.

##### Base Model

RFC 2663 defines a base model used to illustrate all NAT flavors:

```
                        ___________________
                       (                   )
                       (  External Realm   )    +--+
                       (     (N-Ext)       ) -- |  |
                       (___________________)    /--\
                                |              Host-X
                           (Addr-Nx)          (Addr-X)
                       +---------------+
                       |               |
                       |   NAT router  |
                       |               |
                       +---------------+
                           (Addr-Np)
                                |
                        - - - - - - - - -
                       (                 )
+--+                   (  Private Realm  )
|  | - - - - - - - - - (    (N-Pri)      )
/--\                   (                 )
Host-A                  - - - - - - - - -
(Addr-A)
```

Components:

- **N-Pri (Private Address Realm)**: the internal network.
  - Hosts here use private addresses that are not routable on the external network.
- **N-Ext (External Address Realm)**: the external network, typically the public Internet.
  - Addresses here are globally unique and routable.
- **Host-A (`Addr-A`)**: a host inside N-Pri.
  - `Addr-A` is a private address, invisible to the outside world.
- **Host-X (`Addr-X`)**: a host inside N-Ext.
  - `Addr-X` is a public address, reachable from anywhere.
- **NAT router**: the border device between the two realms. It has two interfaces:
  - `Addr-Np`: the interface facing the private realm (N-Pri). Private hosts see this as their gateway.
  - `Addr-Nx`: the interface facing the external realm (N-Ext). The outside world sees traffic from the private network as coming from this address.

In the following subsections:

- **Session flows** refer to the direction in which a connection is initiated from the POV of Host-A.
- **Packet flows** refer to the direction a packet travel from the POV of Host-A.

##### Traditional/Outbound NAT

Traditional/Outbound NATs are NATs such that:

- **Session flows** are **uni-directional, outbound only**.

It is used by **any site with private addresses that needs outbound Internet access**.

Consequently:

- **External addresses** are unique and valid in **both realms**. **Private addresses** are unique only within N-Pri and are **not advertised** to N-Ext, though N-Ext routes may be advertised into N-Pri.
- Private and external addresses must **not overlap**. Any address is either one or the other, not both.

**Traditional NAT/Outbound NAT** has 2 types: **Basic NAT** and **NAPT (Network Address Port Translation)**.

- **Basic NAT**:
  - A **pool of external addresses** (`Addr-i` through `Addr-n`) is reserved. Each active private host is assigned one external address from the pool for the duration of its session. This means Basic NAT needs **as many external addresses as there are concurrent sessions**.
    ::: note
    Only **IP addresses** are translated, not ports.
    :::
  - Outbound packet: **source IP** and related fields (IP, TCP, UDP, ICMP header checksums) are rewritten to the assigned address from the pool.
  - Inbound packet: **destination IP** and related fields are rewritten back to the private address.
- **NAPT (Network Address Port Translation)**: Extends Basic NAT by also translating **transport identifiers** (TCP/UDP port numbers, ICMP query IDs), allowing many private hosts to share a **single external address**. This is what most people mean by "NAT" today.
  - It can be combined with Basic NAT. In practice, the NAT router's own external interface address (`Addr-Nx`) is commonly used as the single external address.
  - Outbound packet: **source IP** and **source transport identifier** (port or ICMP query ID) are rewritten, along with IP, TCP, UDP, and ICMP header checksums.
  - Inbound packet: **destination IP** and **destination transport identifier** are rewritten back, along with the corresponding checksums.

##### Bi-directional/Two-Way NAT

Bi-directional NATs are NATs such that:

- **Session flows** are **bi-directional**. Host-A can initiate sessions to Host-X, and Host-X can initiate sessions to Host-A.

It is used by **sites that need to accept inbound connections from the external network**.

Mechanism:

- Private addresses are **bound to globally unique addresses**, _statically or dynamically_ as sessions are established in either direction.
- **FQDNs** are assumed to be end-to-end unique across both realms. External hosts reach private hosts via **DNS** for address resolution.
  > Hmm, interesting, so NAT and DNS are kind of coupled here?
- **DNS-ALG** is required: it translates private realm addresses in DNS queries and responses into their external bindings (and vice versa) as DNS packets traverse between realms.

Consequently:

- Same address space constraints as Traditional NAT apply. N-Ext is routable from N-Pri, but N-Pri is not routable from N-Ext.

##### Twice NAT

Twice NAT is a variation of NAT such that:

- **Both source and destination addresses** are translated as a packet crosses address realms. This is in contrast to Traditional NAT and Bi-directional NAT, where only one address is translated.

It is used by **sites whose private address space overlaps with public addresses** (e.g., a site that internally uses a public range assigned to another organization).

Mechanism:

- When Host-A initiates a session to Host-X, a **DNS-ALG** intercepts the DNS query and replaces Host-X's address with one routable within the private network (say `Host-XPRIME`). Host-A then connects to `Host-XPRIME`.
- When the packet reaches the NAT device, the **source IP** is translated (as in Traditional NAT) and the **destination IP** is translated from `Host-XPRIME` back to Host-X. The reverse happens for return packets.

Consequently:

- External addresses are unique in N-Ext but not necessarily within N-Pri, and vice versa. The address space used to locate hosts in each realm is **unrelated** across realms.
- Neither N-Ext nor N-Pri is routable from the other side. Twice NAT does not advertise local networks to the external realm or vice versa.
- Session flows are **bi-directional**: Host-A can reach Host-X and Host-X can reach Host-A.

Example: a private site uses `200.200.200.0/24`, which is publicly assigned to another organization. Host-A (`200.200.200.1`) wants to reach Host-X (`200.200.200.100`) in the public Internet. The Twice NAT at the site border is configured:

```
Private -> Public : 200.200.200.0/24 -> 138.76.28.0/24
Public  -> Private: 200.200.200.0/24 -> 172.16.1.0/24
```

Host-A -> Host-X:

```
Within private network:   DA: 172.16.1.100    SA: 200.200.200.1
After Twice NAT:          DA: 200.200.200.100  SA: 138.76.28.1
```

Host-X -> Host-A:

```
Within public network:    DA: 138.76.28.1      SA: 200.200.200.100
After Twice NAT:          DA: 172.16.1.100     SA: 200.200.200.1
```

##### Multihomed NAT

Multihomed NAT is a topology variant such that:

- The private network has **multiple links to the external network**, either through multiple NAT routers or multiple links on the same NAT box. This allows traffic to flow through whichever NAT router has the best metric for a given destination.

It is used by **sites that need redundancy or load distribution across multiple ISP connections**.

Consequently:

- NAT maintains per-session state, so all packets for a session must traverse **the same NAT router**. A backup NAT device must **exchange session state** with the primary so it can take over transparently on failure.
- Failover is simpler when NAT is configured with **static maps**, since static bindings do not need to be re-established after a switchover.

#### Conclusion

So per RFC 2663, we only care about NAPTs.

### RFC 4787: The Modern Taxonomy

## Properties

### RFC 4787: Mapping Lifetimes

### RFC 4787: Hairpin NAT

## Real-World

### RFC 6888: Carrier-Grade NAT (CGNAT)

### Mobile Networks

### RFC 6146/6147: IPv6

### Real-World Distribution
