# Decision Record: Matter Storage Security Boundary

Status: accepted/yellow, certification implications unresolved

Date: 2026-07-08

## Context

Raspberry Pi boot EEPROM is a constrained configuration store, not a secure
element. Matter commissioning may involve operational credentials and, for
certified products, device attestation material with stronger storage
requirements.

## Decision

Dashboard Pi V1 treats EEPROM-backed state as durability only, not
tamper-resistant secret storage. It is acceptable for development and
non-certified appliance R&D only after size and power-loss behavior validate.
Do not claim certified/commercial Matter key protection from Raspberry Pi boot
EEPROM alone.

Production device attestation private keys may require a secure element, TPM,
factory provisioning process or another certified storage design.

## Alternatives Considered

- Treat boot EEPROM as secure NVRAM: rejected.
- Avoid Matter until secure storage exists: rejected for R&D, but certification
  status must be documented honestly.
- Store Matter state on rootfs: rejected by V1 filesystem invariant.

## Consequences

Docs, release notes and product claims must separate development Matter support
from certified/commercial Matter behavior. Any future commercial path needs a
storage and provisioning security review.

## R&D Status

- green: EEPROM is not a secure element.
- yellow: exact certification path and attestation storage design are open.
- red: representing EEPROM-backed Matter state as tamper-resistant.
