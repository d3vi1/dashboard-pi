# AGENTS.md

This repository builds Dashboard Pi, a read-only Raspberry Pi dashboard
distribution using Buildroot.

## Invariants

- Keep the target runtime initramfs-only.
- Keep systemd as init unless there is a documented hard blocker.
- Do not add SSH to production images by default.
- Do not add a persistent writable root filesystem.
- Do not switch the product runtime to Cog, legacy libwpe or wpebackend-fdo.
  The target architecture is the project launcher on WPEPlatform DRM/KMS.
- Keep V1 server-less. Do not add a Dashboard Pi controller, production
  database, OVA, Helm chart, SAML/OIDC/SCIM, fleet manager or license
  enforcement to the V1 appliance.
- Matter runs locally on the Raspberry Pi as a node/server/end-device. Do not
  model V1 as requiring a Dashboard Pi Matter controller.
- Treat EEPROM-backed Matter persistence as constrained R&D and never replace
  it with a silent writable rootfs or hidden `/state` partition.
- Raspberry Pi boards without suitable onboard EEPROM-backed state are not
  active V1 targets. Pi 1/2/3/Zero defconfigs are experimental only.
- CEC TV power control is opt-in. Matter power commands must not control TV
  power by default.
- Keep the kernel boot-critical path built in rather than relying on modules.
- Treat the 3-second power-to-useful-pixels target as a measurement goal, not a
  claim.

## Build Commands

```sh
./scripts/check-defconfigs.sh
./scripts/build.sh dashboard_pi_rpi4_64_defconfig
./scripts/verify-pi4-image.sh ~/.cache/dashboard-pi/output/dashboard_pi_rpi4_64_defconfig
```

The wrapper scripts use `~/.cache/dashboard-pi` because the repository path may
contain spaces and Buildroot/Make paths are fragile in that case.
Full image builds require Linux x86_64. The defconfig checker may run on macOS
and deliberately evaluates Kconfig as a Linux x86_64 host so Bootlin toolchain
options remain visible.

A reproducible Ubuntu development host is available under
`contrib/dev-container/`. It must remain unprivileged, publish no ports and have
no access to the host Docker socket.

## Conventions

- Keep project files ASCII unless an upstream file requires otherwise.
- Prefer Buildroot external-tree files over patching upstream Buildroot.
- Put board files under `br2_external/dashboard_pi/board/raspberrypi/<target>/`.
- Put runtime files in the `dashboard-pi-runtime` package.
- Document non-obvious boot, kernel, graphics and provisioning choices in
  `docs/decisions/`.
- Preserve upstream license notices and SPDX identifiers.
- Keep the Pi 4 production kernel on its dedicated custom configuration. Do
  not restore `bcm2711_defconfig` plus `CONFIG_MODULES=n`.
- Measure slimming against the preserved `B1-product-valid` report, not the
  earlier media-disabled integration baseline.

## Review Checklist

- Defconfigs run through `./scripts/check-defconfigs.sh`.
- Pi 4 keeps `dashboard-pi-wpewebkit` and `dashboard-pi-launcher` enabled.
- Pi 4 does not enable Buildroot `wpewebkit`, `wpebackend-fdo` or Cog.
- Pi 4 keeps WPE video, Web Audio, WebCodecs, MSE, GStreamer GL and HDMI audio.
- Production cmdline has no serial console unless intentionally changed.
- No package pulls in an unnecessary network service.
- DHCP strings are validated before use.
- Logs and caches remain volatile.
- Documentation states tested versus untested board status accurately.
- Documentation clearly separates open-source V1 appliance scope from deferred
  enterprise/licensable controller scope.
