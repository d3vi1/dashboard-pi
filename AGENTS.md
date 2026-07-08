# AGENTS.md

This repository builds Dashboard Pi, a read-only Raspberry Pi dashboard
distribution using Buildroot.

## Invariants

- Keep the target runtime initramfs-only.
- Keep systemd as init unless there is a documented hard blocker.
- Do not add SSH to production images by default.
- Do not add a persistent writable root filesystem.
- Do not switch the product runtime back to Cog/direct WPE launcher. The target
  architecture is WPEPlatform/Thunder.
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
```

The wrapper scripts use `~/.cache/dashboard-pi` because the repository path may
contain spaces and Buildroot/Make paths are fragile in that case.

## Conventions

- Keep project files ASCII unless an upstream file requires otherwise.
- Prefer Buildroot external-tree files over patching upstream Buildroot.
- Put board files under `br2_external/dashboard_pi/board/raspberrypi/<target>/`.
- Put runtime files in the `dashboard-pi-runtime` package.
- Document non-obvious boot, kernel, graphics and provisioning choices in
  `docs/decisions/`.
- Preserve upstream license notices and SPDX identifiers.

## Review Checklist

- Defconfigs run through `./scripts/check-defconfigs.sh`.
- Production cmdline has no serial console unless intentionally changed.
- No package pulls in an unnecessary network service.
- DHCP strings are validated before use.
- Logs and caches remain volatile.
- Documentation states tested versus untested board status accurately.
- Documentation clearly separates open-source V1 appliance scope from deferred
  enterprise/licensable controller scope.
