# Decision Record: Raspberry Pi V1 Target Matrix Requires EEPROM

Status: accepted/yellow, hardware validation pending

Date: 2026-07-08

## Context

Dashboard Pi V1 requires onboard EEPROM-backed Matter persistence while keeping
the root filesystem initramfs-only and non-persistent.

## Decision

Active V1 targets are limited to Raspberry Pi models with suitable onboard boot
EEPROM-backed storage:

- Raspberry Pi 4 Model B;
- Raspberry Pi 400;
- Compute Module 4;
- Compute Module 4S;
- Raspberry Pi 5;
- Raspberry Pi 500/500+;
- Compute Module 5.

Unsupported for V1 unless an alternative persistent storage backend is added:

- Raspberry Pi 1;
- Raspberry Pi 2;
- Raspberry Pi 3;
- Raspberry Pi Zero family;
- any Raspberry Pi model without suitable onboard EEPROM-backed storage.

Existing Pi 1/2/3 defconfigs may remain as historical/experimental bring-up
targets. They must not be advertised as supported V1 release targets.

## Alternatives Considered

- Keep Pi 1/2/3 as V1 targets with no Matter persistence: rejected because V1
  requires local Matter usefulness.
- Add a writable state partition for old boards: rejected for V1.
- Delay all non-Pi-4 targets: rejected because Pi 5/CM5 are useful future V1
  targets if EEPROM behavior validates.

## Current Implementation Status

Documentation corrected. Defconfigs are not removed in this pass because the
request permits keeping historical/experimental targets.

## R&D Status

- green: Pi 1/2/3/Zero are unsupported for V1.
- yellow: exact EEPROM state behavior must be measured on Pi 4/400/CM4/CM4S and
  Pi 5/500/CM5.
