# Decision Record: EEPROM-Backed Matter State

Status: accepted/yellow, constrained R&D target

Date: 2026-07-08

## Context

V1 has no persistent writable root filesystem. Matter commissioning creates
durable state, including fabric metadata, credentials and ACL data. Dashboard Pi
needs a local persistence strategy that preserves the initramfs-only invariant.

## Decision

Use one small Raspberry Pi boot EEPROM config variable on supported boards:

```text
DASHBOARD_PI_STATE_V1=<base64url(payload)>
```

The decoded payload is schema-versioned, checksummed, small, rarely written,
factory-resettable and ignored safely if invalid. Target encoded size is 3000
bytes. The absolute maximum must be measured from real Raspberry Pi EEPROM boot
config behavior before claiming green status.

EEPROM state may contain only small durable configuration/state. It must not
contain logs, telemetry, browser cache, DHCP leases, screenshots or runtime
status.

## Alternatives Considered

- Writable rootfs: rejected by V1 invariant.
- Hidden `/state` partition: rejected for V1 because it silently changes the
  storage model.
- External I2C/SPI EEPROM, secure element, TPM or per-device image: deferred as
  future alternatives if boot EEPROM storage is too small or unsafe.

## Consequences

The Matter KVS adapter must debounce writes, enforce a maximum write frequency,
handle corruption, and fail closed when state does not fit. If EEPROM storage is
not safe, V1 Matter persistence for that board is red/yellow, not faked.

## Current Implementation Status

Documentation and JSON schema only. No EEPROM writer is implemented in this
pass.

## R&D Status

- green: single-variable state model is the accepted design target.
- yellow: EEPROM size, Pi 4/Pi 5 layout differences, A/B behavior and power-loss
  behavior require testing.
- red: fallback to writable rootfs without an explicit future architecture
  decision.
