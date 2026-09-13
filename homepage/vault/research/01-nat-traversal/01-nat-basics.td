---
_type: Research
_label: "NAT Basics"
_icon: icon.globe
status: 'draft'
---

This section introduces:

- The background.
- The motivation of NAT.
- The concept and mechanism of NAT.
- The implications of NAT (then & now).
- Some real world use cases.

This is based on:

- The book [Computer Networking - A Top-Down Approach](https://ebooks.karbust.me/Technology/Computer%20Networking%20A%20Top-Down%20Approach,%208th%20Edition%20by%20James%20F.%20Kurose,%20Keith%20W.%20Ross-Pearson-9780136681557.pdf) by James Kurose.
- [RFC 2663](https://datatracker.ietf.org/doc/html/rfc2663): IP Network Address Translator (NAT) Terminology and Considerations (dedicated additional reading)
- [RFC 3022](https://datatracker.ietf.org/doc/html/rfc3022): Traditional IP Network Address Translator (Traditional NAT) (dedicated additional reading)

## Background

This section revises some basic knowledge about the structure and the functioning of the Internet.

There are 3 terms that can be easily confused: **network**, **the Internet** and **the Web**.

- **Network**: A collection of interconnected computers that can communicate with each other. Usually refers to both the **topology** of connections and the **protocols** that govern communication.
- **The Internet**: A specific global network, descended from ARPANET, that connects nearly every computer in the world. It refers specifically to **the infrastructure (IP routing, DNS, physical links)** that makes this possible.
- **The Web**: An application layer service running on top of the Internet, using HTTP to serve and link documents.

We specifically focus on **the Internet**.

### The Internet

The Internet is a global network that interconnects billions of devices. We can look at it from two angles: its **infrastructure** (the physical and organizational pieces) and its **mechanisms** (how data actually moves through it).

#### Infrastructure

Every layer is made up of **communication links** (the physical media: fiber, copper, coaxial, radio) and **packet switches** (devices that forward packets: link-layer switches in access networks, routers in the core). These layers are owned and operated by **ISPs** and **content provider networks** (see below).

From the edge inward:

1. **End systems (hosts)**: The devices at the edge. Computers, phones, servers, IoT things. They run applications and are the source and destination of all traffic.

2. **Access networks**: The "last mile" that connects your local network to the ISP's network.
   - On your side: your home router (or campus switch) manages the local network
   - On the ISP's side: an **edge router** sits at the ISP's facility (central office, cable head end, etc.)
   - The access network is the link between them: DSL line, coaxial cable, fiber, 5G radio, etc.
   - Types:
     - Home: DSL, cable (HFC), fiber (FTTH), 5G fixed wireless
     - Enterprise/campus: Ethernet (wired LAN), WiFi (wireless LAN)
     - Mobile: 4G/5G cellular

3. **The network core (backbone)**: The high-speed interior of the Internet. A mesh of routers interconnected by long-haul fiber links that carries traffic between ISPs, across regions, and across continents.

These layers are owned and operated by **ISPs (Internet Service Providers)**. Each ISP is itself a network of links and routers. They form a rough hierarchy, where each tier roughly maps to a layer above:

- **Access ISPs**: Own the access networks. Your home ISP, university, mobile carrier.
- **Regional ISPs**: Connect access ISPs within a region. Operate regional core infrastructure.
- **Tier-1 ISPs**: Own the backbone. A dozen or so globally (Level 3, AT&T, NTT). They interconnect with each other directly and don't pay anyone upstream. Their high-speed fiber links and routers form the network core.
- **Content provider networks**: Companies like Google essentially act as their own ISP by building private global networks, peering directly with lower-tier ISPs and at IXPs to bypass the hierarchy.

ISPs interconnect with each other through:

- **Customer/provider**: Lower-tier ISPs pay higher-tier ISPs for transit
- **Peering**: Two ISPs at the same level connect directly, usually settlement-free, so traffic between them skips upstream ISPs
- **IXPs (Internet Exchange Points)**: Physical locations (600+ worldwide) where multiple ISPs meet and peer
- **PoPs (Points of Presence)**: A group of routers at a location where customer ISPs can connect into a provider ISP
- **Multi-homing**: An ISP connects to multiple providers for redundancy

#### Mechanisms

How data gets from one end system to another:

1. A source end system wants to send data to a destination. It breaks the data into **packets**, each tagged with the destination's **IP address**.
2. The packets leave the source through its access network and hit the first router.
3. Each router along the way looks up the destination IP in its **forwarding table** and sends the packet out the appropriate link to the next hop.
4. This repeats, router by router, until the packet reaches the destination's access network and arrives at the destination end system.
5. The destination reassembles the packets back into the original data.

This is **packet switching**: each packet travels independently, on demand, with no resources reserved in advance. Along the way, packets may sit in router buffers waiting for a link (**queuing delay**), or get dropped if the buffer is full (**packet loss**).

Behind the scenes:

- **Routing protocols** automatically build and update the forwarding tables across all routers, figuring out the best paths through the network.
- All of this is governed by **TCP/IP**: IP handles addressing and forwarding, TCP handles reliable delivery on top.
- Standards are published as **RFCs** by the **IETF**.

### The TCP/IP Networking Model

The Internet is complex, so its protocols are organized into **layers**: Each layer provides a service to the layer above it and uses the services of the layer below it.

The Internet protocol stack has 5 layers, from top to bottom:

1. **Application**: Where applications and their protocols live (HTTP, SMTP, DNS, FTP). Produces **messages** that need to be sent to another end system.

2. **Transport**: Delivers messages between application endpoints. Two protocols:
   - **TCP**: Reliable, ordered delivery & connection-oriented.
   - **UDP**: Unreliable.

3. **Network (IP layer)**: Moves **datagrams** from one host to another. This is where IP addressing, forwarding tables, and routing protocols live. For example, every Internet device with a network layer runs the IP protocol, which is why this layer is often just called "the IP layer".

4. **Link**: Moves **frames** between adjacent nodes (one hop at a time). Different links use different protocols (Ethernet, WiFi, DOCSIS). A single datagram may be handled by different link-layer protocols on different hops.

5. **Physical**: Moves individual **bits** across a single link. Depends on the medium (copper, fiber, radio).

As data moves down the stack, each layer wraps the data from above with its own header. This is **encapsulation**:

- Application produces a message: `M`
- Transport adds its header: `Ht | M` (segment)
- Network adds its header: `Hn | Ht | M` (datagram)
- Link adds its header: `Hl | Hn | Ht | M` (frame)
- Physical sends the bits

At each hop, the packet only goes up as far as needed:

- **Link-layer switches** only look at layers 1-2 (physical + link). They forward frames based on link-layer addresses (e.g. MAC addresses).
- **Routers** look at layers 1-3 (physical + link + network). They forward datagrams based on IP addresses.

At the destination, the process reverses: each layer strips its header and passes the payload up to the layer above, until the application gets the original message.

### IP Addresses and CIDR

Every device on the Internet is identified by an **IP address**. There are two versions:

- **IPv4**: 32-bit addresses, written as four decimal numbers separated by dots (e.g. `192.168.1.1`). This gives about 4.3 billion possible addresses, which has long been exhausted.
- **IPv6**: 128-bit addresses, written in hexadecimal groups separated by colons (e.g. `2001:0db8:85a3::8a2e:0370:7334`). This gives a practically unlimited address space (~3.4 × 10³⁸ addresses). Adoption is growing but still incomplete (~40-45% of traffic as of 2024).

IP addresses are organized into **networks** using prefixes. Originally, these were divided into fixed classes (Class A = `/8`, Class B = `/16`, Class C = `/24`), but this was wasteful. **CIDR (Classless Inter-Domain Routing)** replaced this by allowing prefixes at any bit boundary.

CIDR notation looks like `address/prefix_length`:

- The number after `/` says how many leading bits are the network part (fixed), and the remaining bits identify hosts within that network.
- `10.0.0.0/8` means the first 8 bits are fixed, covering all of `10.x.x.x` (~16.7 million addresses).
- `192.168.1.0/24` means the first 24 bits are fixed, covering `192.168.1.0` to `192.168.1.255` (256 addresses).
- You can split at any boundary: `/20`, `/22`, `/27`, whatever fits your needs.

CIDR matters for routing because it lets routers **aggregate** many smaller address blocks into a single prefix. Instead of advertising 16 separate `/24` networks, a router can advertise one `/20` that covers them all. This keeps forwarding tables small and manageable.

## Motivation of NAT

- Every device on the Internet needs an IP address, and as more devices showed up in homes and offices (phones, tablets, TVs, printers, etc.), IPv4's ~4.3 billion addresses simply ran out.
- IPv6 solves this but adoption is slow (~40-45% as of 2024).

**NAT (Network Address Translation)** is the practical workaround to avoid exhausting the address space.

## Concept and Mechanism of NAT

The idea is simple:

- Instead of giving every device in a home a public IP address, the home router gets a single public IP from the ISP (consumes 1 entry).
- All devices inside the home use **private IP addresses** (e.g. `10.0.0.x` or `192.168.1.x`) that are only meaningful within the local network.
- The router then translates between the private addresses and its single public address as traffic flows in and out.

The private address spaces reserved for this purpose (defined in RFC 1918) are:

- `10.0.0.0/8`
- `172.16.0.0/12`
- `192.168.0.0/16`

Hundreds of thousands of home networks can all use `10.0.0.0/24` internally without any conflict, because these addresses never appear on the public Internet. NAT is what makes this work.

From the outside world, the entire home network looks like one device with one IP address.

But if every incoming packet has the same destination IP (the router's public address), how does the router know which internal device to forward it to?

### The Translation Table

The router maintains a **NAT translation table** that maps connections using both IP addresses and **port numbers**.

For example, suppose a device at `10.0.0.1` in your home wants to load a web page from a server at `128.119.40.186:80`:

1. The device sends a packet with source `10.0.0.1:3345`, destination `128.119.40.186:80`.
2. The NAT router intercepts this. It rewrites the source to its own public IP and picks a new port number: `138.76.29.7:5001`. It saves the mapping `138.76.29.7:5001 <-> 10.0.0.1:3345` in the translation table.
3. The web server receives the request from `138.76.29.7:5001` and replies to that address. It has no idea there's a whole network behind it.
4. The reply arrives at the router with destination `138.76.29.7:5001`. The router looks up `5001` in the translation table, finds it maps to `10.0.0.1:3345`, rewrites the destination, and forwards the packet to the internal device.

Since port numbers are 16 bits, a single public IP can support over 60,000 simultaneous connections through NAT.

## Implications of NAT

### Pros

NAT let the Internet keep growing despite IPv4 address exhaustion. It gave households a simple way to connect many devices without worrying about IP allocation, and it provides incidental security since devices behind NAT are not directly reachable from the outside.

### Cons

- **Inbound connections don't work**:
  - NAT only creates table entries when an internal device connects outward.
  - External hosts can't reach devices behind NAT, because unsolicited inbound packets have no matching entry and get dropped.
  - Essentially, This is the core problem that **NAT traversal** exists to solve.
- **Port misuse**:
  - Ports were designed to identify processes on a host, not hosts behind a router.
  - NAT repurposes them as host identifiers.
- **Violates the end-to-end principle**: NAT modifies packets in transit, breaking the idea that hosts should talk directly without intermediaries tampering with their data.
- **NAT stacking**: ISPs facing their own address shortages deploy **Carrier-Grade NAT (CGNAT)**, adding a second NAT layer (`device -> home NAT -> ISP CGNAT -> Internet`), making traversal even harder.

## Real World Use Cases of NAT

- **Home networks**: A single public IP shared by all household devices. Virtually every consumer router does NAT.
- **Private/isolated networks**: Organizations use NAT to intentionally hide internal network topology and keep internal addresses unreachable from the outside.
- **CGNAT**: ISPs (especially mobile carriers and regions with severe IPv4 exhaustion) put subscribers behind an additional NAT layer using `100.64.0.0/10` (RFC 6598).
- **Cloud**: NAT gateways allow instances with private IPs to reach the Internet without being directly exposed (e.g. AWS NAT Gateway).
- **Mobile networks**: Nearly all mobile carriers use NAT (often symmetric NAT + CGNAT), which is why P2P connections from mobile devices are particularly hard.
