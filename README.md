# Dashboard Pi

Dashboard Pi is a minimal read-only Raspberry Pi dashboard appliance
distribution built with Buildroot. V1 is server-less and home/local first: a
Raspberry Pi boots an initramfs-only systemd runtime, gets network configuration
from DHCP/DHCPv6, discovers an optional dashboard URL from provisioning data,
displays it through a hardware-accelerated WPEPlatform stack, and runs local
Matter functionality on the Pi itself.

V1 does not require a Dashboard Pi controller, cloud service, appliance server,
database, OVA, Helm chart, SAML/OIDC/SCIM, fleet manager or licensing server.
Enterprise fleet management is a deferred, separately licensable product track.

## Current Status

This repository is at Milestone 1:

- Buildroot external tree is present.
- Buildroot is pinned by tooling to upstream `2026.05`.
- Raspberry Pi 4/400/CM4-class hardware is the primary V1 target family.
- Raspberry Pi 5/500/CM5 is best-effort V1 pending EEPROM, kernel, firmware and
  graphics validation.
- Raspberry Pi 1/2/3/Zero-class boards are not V1 targets because V1 Matter
  persistence requires onboard EEPROM-backed state. Their defconfigs are
  historical/experimental only.
- The runtime uses systemd, systemd-networkd, volatile journald, initramfs and a
  WPEPlatform launch placeholder.
- Cog/direct WPE launcher is not the default architecture.
- WPEPlatform/Thunder packaging and plugin activation are Milestone 4 R&D.
- Matter 1.6/`connectedhomeip` data model 1.6.1 is the public design baseline.
- EEPROM-backed Matter persistence is a constrained R&D target, not secure
  storage.

## Architecture

| Area | Decision |
| --- | --- |
| Build system | Buildroot external tree, no vendored Buildroot copy |
| Buildroot baseline | `2026.05` |
| Init | systemd |
| Runtime root | initramfs-only; no persistent root filesystem |
| Network | systemd-networkd DHCP/DHCPv6 |
| URL provisioning | DHCPv4 option 224 MVP, then vendor-specific DHCPv4/DHCPv6 |
| Browser platform | WPEPlatform/Thunder, not Cog as the product runtime |
| Graphics | DRM/KMS plus Mesa VC4/V3D paths, no X11 |
| Matter | Local Raspberry Pi Matter node/server; no V1 controller |
| Matter persistence | Single small EEPROM boot config variable where supported |
| CEC power policy | TV power control opt-in; dashboard-only by default |
| Logging | volatile journald; optional non-blocking remote syslog |
| SSH | disabled by default |
| Enterprise | Deferred, separate licensable product boundary |

Critical boot path:

1. Raspberry Pi firmware loads the kernel.
2. Kernel starts with embedded initramfs.
3. systemd starts `dashboard.target`.
4. systemd-networkd acquires DHCP/DHCPv6 data.
5. `dashboard-url.service` validates provisioning data.
6. WPEPlatform runtime starts once URL discovery has completed.

## Supported Boards

| Target | Defconfig | V1 status | Expected graphics path |
| --- | --- | --- | --- |
| Raspberry Pi 4 Model B | `dashboard_pi_rpi4_64_defconfig` | active V1, untested | `vc4` KMS + `v3d` Mesa |
| Raspberry Pi 400 | `dashboard_pi_rpi4_64_defconfig` | active V1, untested | `vc4` KMS + `v3d` Mesa |
| Compute Module 4/4S | `dashboard_pi_rpi4_64_defconfig` | active V1, untested | `vc4` KMS + `v3d` Mesa |
| Raspberry Pi 5 | `dashboard_pi_rpi5_defconfig` | best-effort V1, untested | `vc4` KMS + `v3d` Mesa |
| Raspberry Pi 500/500+ | `dashboard_pi_rpi5_defconfig` | best-effort V1, untested | `vc4` KMS + `v3d` Mesa |
| Compute Module 5 | `dashboard_pi_rpi5_defconfig` | best-effort V1, untested | `vc4` KMS + `v3d` Mesa |
| Raspberry Pi 1/2/3/Zero family | historical defconfigs only | unsupported for V1 | experimental |

## Build

The requested repository path contains a space. Use the wrapper scripts; they
place Buildroot and output directories under `~/.cache/dashboard-pi` to avoid
Make path issues.

```sh
./scripts/build.sh dashboard_pi_rpi4_64_defconfig
```

Check all defconfigs without building full images:

```sh
./scripts/check-defconfigs.sh
```

The built image is reported at the end of `scripts/build.sh`, normally:

```text
~/.cache/dashboard-pi/output/dashboard_pi_rpi4_64_defconfig/images/sdcard.img
```

## Flash And Boot

Write the image to the target boot medium:

```sh
sudo dd if=sdcard.img of=/dev/sdX bs=4M conv=fsync status=progress
```

The image contains a minimal FAT boot partition. The runtime is embedded in the
kernel initramfs, so there is no persistent rootfs partition to repair after
power loss.

## DHCP Provisioning

Dashboard Pi sends DHCP vendor class `Dashboard-Pi`.

MVP DHCPv4 behavior:

- Option 224: dashboard URL as text.
- Option 7: remote syslog IPv4 servers.
- Option 225: reserved future enterprise controller URL; ignored for V1.

Fallback order:

1. Valid DHCP-provided dashboard URL.
2. Build-time local fallback in `/etc/dashboard-pi/default-url`.
3. Embedded local error page.

Only `http://` and `https://` URLs are accepted from DHCP. Provisioned strings
are written as data to `/run/dashboard-pi/url.env`; they are not evaluated as
commands.

Examples are in `docs/examples/dhcp/`.

## Debugging

Serial console is disabled in the production Pi 4 cmdline. For UART debugging,
copy `br2_external/dashboard_pi/board/raspberrypi/rpi4-64/cmdline-debug-uart.txt`
over the production `cmdline.txt` path in a debug defconfig or local build.

Useful commands on a debug build:

```sh
systemd-analyze
systemd-analyze critical-chain dashboard.target
journalctl -b -u dashboard-url.service -u dashboard-browser.service
```

For boot timing, collect:

- UART logs with kernel timestamps.
- `systemd-analyze blame` and `critical-chain`.
- Video measurement from power applied to first visible useful dashboard pixel.
- Optional GPIO markers added during the boot-time R&D milestone.

The three-second power-to-browser target is an R&D target. Do not claim success
unless first useful browser content is measured, not merely process start.

## Raspberry Pi EEPROM Notes

V1 Matter persistence is designed around one small boot EEPROM config variable:
`DASHBOARD_PI_STATE_V1=<base64url(payload)>`. The payload is schema-versioned,
checksummed, factory-resettable, and ignored safely if invalid. This is not
secure storage and must not contain logs, telemetry, browser cache or volatile
runtime data.

For fastest local boot, configure the EEPROM boot order to try the intended
medium first and avoid unnecessary network or USB fallback delays. Preserve
unknown bootloader settings during Dashboard Pi state updates and factory reset.

## Security And Updates

- No SSH by default.
- No package manager on target.
- No persistent writable rootfs.
- Browser/platform runtime should run as a non-root user where feasible.
- Runtime state, logs, cache and DHCP state are volatile.
- Matter runs locally on the appliance. V1 does not add a controller server.
- HDMI-CEC TV power control is disabled by default; Matter On/Off controls only
  dashboard blank/unblank behavior unless policy explicitly allows TV power.
- HTTPS dashboard URLs are supported when the image includes an appropriate CA
  certificate store.
- Updates are full-image rebuilds and reflashes for now; A/B update design is
  intentionally out of scope for the first milestones.

## Licensing

Project-specific Buildroot integration, scripts, configuration and documentation
are GPL-2.0-only unless a file states otherwise. Buildroot, Linux, Raspberry Pi
firmware, Mesa, systemd, WPEPlatform/Thunder and other dependencies retain their
own upstream licenses.
