# Decision Record: systemd Unit Topology And Critical Path

Status: Accepted initial topology, measurement pending

Date: 2026-07-08

## Context

Dashboard Pi must keep systemd but avoid a generic boot path that starts
unneeded services before the dashboard is visible. The runtime is initramfs-only
and has no persistent root filesystem.

## Decision

Use a custom `dashboard.target` as the default systemd target. The target starts
only the services needed for volatile state, network provisioning, URL discovery,
optional logging, CEC input and the WPEPlatform runtime.

Initial ordering:

1. systemd early boot and tmpfiles.
2. `systemd-networkd.service` and `systemd-resolved.service`.
3. `dashboard-url.service` validates DHCP/local URL input.
4. `dashboard-browser.service` launches the WPEPlatform DRM runtime wrapper.
5. `dashboard-cec.service` and `dashboard-syslog.service` run as non-critical
   side services.

## Rationale

This keeps the critical path explicit and makes `systemd-analyze critical-chain
dashboard.target` useful. Optional services must not block the first useful
dashboard pixels.

## Open Items

- Convert the WPEPlatform launcher to `Type=notify` if it can report first
  navigation or first paint.
- Decide whether `network-online.target` is too conservative after DHCP lease
  parsing is implemented.
- Replace load-finished timing with a real first-frame/first-pixel signal.
