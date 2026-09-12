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

## Motivation
