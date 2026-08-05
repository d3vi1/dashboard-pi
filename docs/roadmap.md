# Roadmap

Status markers:

- green: accepted or validated;
- yellow: plausible but requiring more testing;
- red: blocked or unsafe;
- deferred: design goal, not implemented in V1.

## V1: Home/Local Server-Less Appliance

Status: yellow.

V1 is the open-source local appliance. It must remain useful without any
Dashboard Pi server.

Scope:

- Buildroot external tree.
- initramfs-only runtime.
- minimal systemd boot path.
- DHCP/DHCPv6 network configuration.
- DHCPv4 option 224 dashboard URL MVP.
- DHCPv4 option 7 remote syslog MVP.
- WPE WebKit WPEPlatform dashboard runtime on direct DRM/KMS.
- local Matter node/server on EEPROM-equipped Raspberry Pi boards.
- HDMI-CEC navigation with safe display power policy.
- volatile logs, cache and runtime state.
- factory reset for Dashboard Pi state only.

Out of scope:

- production enterprise controller;
- database;
- OVA or Helm chart;
- SAML/OIDC/SCIM;
- fleet manager;
- license enforcement;
- writable persistent rootfs.

## Milestones

| Milestone | Scope | Status |
| --- | --- | --- |
| 1 | Repository skeleton, external tree, docs, Pi 4 primary defconfig | green |
| 2 | Minimal Pi 4 initramfs-only systemd boot | yellow |
| 3 | DHCP/DHCPv6 provisioning and remote syslog | yellow |
| 4 | WPEPlatform packaging, launcher and Pi 4 graphics validation | yellow |
| 5 | CEC bridge, policy mapping and optional TV power | yellow |
| 6 | Boot-time measurement and optimization | yellow |
| 7 | EEPROM-backed local Matter node/server | yellow |
| 8 | Active V1 board validation: Pi 4/400/CM4 and Pi 5/500/CM5 | yellow |
| 9 | Release pipeline, checksums and release notes | yellow |

## Deferred Enterprise Track

Status: deferred.

Enterprise management is a separate future licensable product boundary. It may
share open protocols with the appliance, but it must not block V1 and must not
accidentally enter the GPLv2 appliance licensing boundary.

See `docs/deferred/enterprise-controller.md`.
