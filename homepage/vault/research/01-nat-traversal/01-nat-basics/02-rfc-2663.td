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
