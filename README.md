# labhost-lite

`labhost-lite` is a lightweight Alpine Linux–based container image designed for use as a **generic Linux host inside [containerlab](https://containerlab.dev) topologies**.

This image is primarily intended to support an upcoming **containerlab-based lab series** focused on network engineering, testing, and experimentation. It is published separately so it can be reused consistently across multiple labs and topologies.

It is intended to act as a:
- management / utility host
- traffic generator or sink
- debugging and observability node
- general-purpose Linux endpoint connected to lab networks

This image is **not** a network operating system and does not attempt to configure or manage its own networking. Instead, it follows containerlab’s interface and management conventions strictly.

---

## Design goals

- **Predictable behavior**  
  Built on a pinned Alpine Linux release for reproducible builds.

- **Containerlab-first networking model**  
  - `eth0` is reserved for containerlab management and is never modified by the image.
  - `eth1+` are available for data-plane connections defined in the lab topology.

- **Small, fast, and transparent**  
  No init system, no network managers, no background services beyond what is explicitly enabled.

- **Admin-friendly but not opinionated**  
  Includes common networking and debugging tools, plus sudo access for interactive lab use.

---

## What’s included

- **Base OS**
  - Alpine Linux (pinned release)

- **Shell & editor**
  - `bash`, `sh`
  - `vim`

- **Networking & diagnostics**
  - `iproute2`, `iputils`
  - `tcpdump`, `tshark`
  - `ethtool`
  - `mtr`, `fping`
  - `iperf3`
  - `nmap`
  - `socat`
  - `net-tools`
  - `bind-tools` (dig, nslookup)

- **HTTP / data utilities**
  - `curl`
  - `jq`

- **System & process utilities**
  - `busybox-extras`
  - `ca-certificates`
  - `tini` (for proper signal handling)

- **SSH & privilege management**
  - `openssh-client`, `openssh-server`
  - `sudo` (passwordless via `wheel` group)

This toolset is intentionally broad enough to support:
- connectivity testing
- traffic generation and capture
- protocol inspection
- ad-hoc troubleshooting inside containerlab labs

At the same time, the image avoids configuration frameworks or background services that would interfere with containerlab’s networking model.

---

## Default credentials

For convenience in lab environments, the image includes a preconfigured user:

- **Username:** `lab`
- **Password:** `lab`
- **Sudo:** passwordless (`NOPASSWD`) via the `wheel` group

These credentials are intended **only for local lab use**.  
Do not expose this container to untrusted networks or production environments.

---

## Networking model

This image follows containerlab’s standard Linux node contract:

- **eth0**
  - Management interface
  - Created, configured, and routed by containerlab
  - Must not be modified inside the container

- **eth1+**
  - Data-plane interfaces
  - Used for links defined in the containerlab topology
  - Configured manually or by lab automation as needed

Whether the container can reach external networks (including the internet) is determined entirely by:
- the Docker networks it is attached to
- host firewall and NAT configuration
- containerlab topology design

The image itself does not attempt to restrict or override network reachability.

---

## Security posture

`labhost-lite` is designed for **local, trusted lab environments** and intentionally applies **no additional hardening beyond sensible defaults**.

Specifically:

- The image does **not** enforce network isolation.
  - Internet reachability depends on Docker and containerlab network configuration.
  - No firewall rules are applied inside the container.

- The image includes:
  - an unprivileged default user (`lab`)
  - a known default password (`lab`)
  - passwordless `sudo` access
  - common debugging and networking tools

- The container runs with whatever privileges and capabilities are granted by the runtime.
  - Capability dropping, read-only filesystems, and privilege restrictions must be enforced at runtime if desired.

This image should **not** be considered a security boundary.

Any isolation or restriction requirements should be implemented via:
- containerlab topology design
- Docker network configuration
- host-level firewall and policy controls

The goal is transparency and predictability, not sandboxing.

---

## Typical containerlab usage

```yaml
topology:
  nodes:
    host1:
      kind: linux
      image: labhost-lite:1.0
