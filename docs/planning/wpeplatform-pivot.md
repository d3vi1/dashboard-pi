# WPEPlatform Pivot Plan

Date: 2026-07-08

## Summary

The dashboard/browser runtime plan is amended: Dashboard Pi should not build its production browser path around cog or legacy libwpe launcher integration. The project should target WPE WebKit through WPEPlatform and implement a minimal Dashboard Pi launcher around that API.

The earlier product goals remain unchanged:

- Buildroot-based Raspberry Pi distribution.
- Primary target Raspberry Pi 4.
- Release targets Raspberry Pi 1, 2, 3, 4, and best-effort 5.
- initramfs-only read-only runtime.
- minimal systemd userspace.
- DHCP/DHCPv6 dashboard provisioning.
- remote syslog support.
- hardware-accelerated fullscreen WebKit where each board can support it.
- aggressive boot-time measurement to first useful browser pixels.

## Plan Changes

Replace this runtime assumption:

> WPE WebKit through cog/libwpe as the preferred launcher path.

With this runtime assumption:

> WPE WebKit through WPEPlatform, using a small Dashboard Pi launcher as the preferred production path.

Milestone wording should be interpreted as follows:

| Milestone | Amended Direction |
| --- | --- |
| Milestone 4: browser runtime | Build and package WPE WebKit with WPEPlatform support, then package a minimal Dashboard Pi fullscreen launcher. cog/libwpe may be used only for temporary comparison or bring-up. |
| Milestone 5: HDMI-CEC navigation | Feed CEC-derived actions into the Dashboard Pi launcher control surface, not into cog-specific mechanisms. |
| Milestone 6: boot optimization | Measure WPEPlatform first content timing and compare only where a temporary legacy baseline is useful. |
| Milestone 7: board targets | Document per-board WPEPlatform support and acceleration status. Mark legacy fallbacks explicitly if any board cannot support WPEPlatform. |
| Milestone 8: releases | Release artifacts should identify WPEPlatform/WebKit revisions and known graphics limitations per board. |

## Buildroot Implementation

The Pi 4 implementation now uses the external `dashboard-pi-wpewebkit` package
to pin WPE WebKit 2.52.5 and the `dashboard-pi-launcher` package for the minimal
C launcher. Buildroot 2026.05 remains the baseline because the external package
contains the browser-version divergence cleanly.

Remaining work needs to validate:

- the smallest systemd, udev, Mesa, libdrm, GBM, EGL, and certificate-store package set that supports the launcher;
- the right way to expose render/card/input/CEC device access to a non-root dashboard user in an initramfs-only image.

The current package enables the built-in DRM/KMS and headless backends and
disables the WPE legacy API, backend-fdo dependency and Wayland display backend.
Hardware validation remains open.

## Launcher Requirements

The Dashboard Pi launcher should be deliberately narrow:

- read one validated dashboard URL from the provisioning result;
- load a local failure page when no valid URL is available;
- run fullscreen at the active display mode;
- expose reload, back, forward, scroll/page navigation, and relaunch actions;
- accept keyboard events and a small IPC or event interface for CEC-derived commands;
- emit structured startup, first-load, load-failure, and crash events for volatile journal and optional remote syslog;
- use tmpfs-backed cache/state paths or disable cache where practical;
- avoid shell interpolation of DHCP-provided values;
- exit or signal readiness in a way systemd can supervise and measure.

The launcher should not include tabs, address bars, developer tools, a package manager, persistent credentials, or a general-purpose browsing UI.

## Graphics R&D Queue

The graphics work should now answer these WPEPlatform-specific questions before release claims are made:

1. Which WPE WebKit revision is required for WPEPlatform on Buildroot?
2. Can Raspberry Pi 4 render through DRM/KMS/GBM/Mesa without Weston?
3. Does fullscreen WPEPlatform on Raspberry Pi 4 get DMA-BUF acceleration and any direct-scanout benefit?
4. What kernel options, CMA/GPU memory settings, Mesa Gallium drivers, and firmware overlays are required for vc4/v3d?
5. What acceleration mode is realistic for Raspberry Pi 1 and 2?
6. Does Raspberry Pi 5 require a newer kernel, Mesa, firmware, or Buildroot branch than the Pi 4 target?
7. What is the measured delta between firmware handoff, kernel start, systemd start, network-ready, launcher start, first navigation, and first useful dashboard pixels?

Any uncertain item should stay marked as R&D validation in release notes until tested on hardware.

## Documentation Follow-Up

When README and AGENTS.md are next edited, update their wording so they:

- say WPEPlatform is the target runtime path;
- avoid presenting cog as the preferred launcher;
- describe cog/libwpe only as legacy, temporary, or fallback tooling;
- link to `docs/decisions/0001-wpeplatform-graphics-stack.md`;
- preserve the explicit constraints around systemd, initramfs-only runtime, DHCP provisioning, optional serial console, and non-persistent state.
