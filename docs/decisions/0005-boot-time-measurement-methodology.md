# Decision Record: Boot-Time Measurement Methodology

Status: Accepted methodology, measurements pending

Date: 2026-07-08

## Context

The project target is an aggressive maximum of three seconds from power applied
to first useful dashboard pixels on Raspberry Pi 4. This cannot be claimed by
measuring only process start.

## Decision

Measure the boot path in stages:

| Stage | Primary method |
| --- | --- |
| Power to firmware handoff | video timing or GPIO marker when available |
| Kernel start | UART log with kernel timestamps |
| Display ready | DRM/KMS logs and video timing |
| systemd start | kernel/systemd logs |
| Network link and DHCP lease | networkd logs |
| URL discovered | `dashboard-url.service` log timestamp |
| WPEPlatform runtime started | systemd journal timestamp |
| First useful dashboard pixels | video measurement or launcher first-paint signal |

Use `systemd-analyze`, UART logs, optional GPIO markers and video-based timing.
Release notes must distinguish measured hardware results from targets.

## Rationale

Different bottlenecks live in firmware, kernel, networking, browser startup and
page rendering. A single timestamp hides the real bottleneck and can create
misleading optimization work.

## Open Items

- Add GPIO marker support if it can be done without delaying production boot.
- Teach the WPEPlatform launcher to emit first-navigation and first-paint events.
- Define the benchmark page used for repeatable first-pixel tests.
