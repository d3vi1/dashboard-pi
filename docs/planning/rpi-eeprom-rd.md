# Raspberry Pi EEPROM R&D Plan

Status: yellow/red until hardware validation.

## 1. Detect EEPROM Support

Detect and validate:

- Raspberry Pi 4 Model B;
- Raspberry Pi 400;
- Compute Module 4;
- Compute Module 4S;
- Raspberry Pi 5;
- Raspberry Pi 500/500+;
- Compute Module 5.

If no supported EEPROM is detected, V1 support check fails.

## 2. Read EEPROM Boot Config

Evaluate, in order:

- `/sys/firmware/devicetree/base/aliases/blconfig`;
- nvmem device exposed by the kernel;
- `vcgencmd bootloader_config` as development/reference tooling;
- `rpi-eeprom-config` as development/reference tooling.

The production image should avoid large tooling if a safe minimal reader can be
implemented and validated.

## 3. Write EEPROM Boot Config

Do not write EEPROM blindly. Evaluate:

- official `rpi-eeprom-config` / `rpi-eeprom-update` flow;
- whether a minimal native writer is safe;
- Pi 4 versus Pi 5 EEPROM layout differences;
- Pi 5 A/B EEPROM behavior;
- power-loss behavior;
- automatic bootloader update interaction;
- preservation of unknown `DASHBOARD_PI_STATE_V1` across bootloader updates.

## 4. Size Tests

Measure encoded state after Matter commissioning into:

- one fabric;
- two fabrics;
- three fabrics;
- ACLs;
- group keys;
- scenes;
- ContentLauncher/ApplicationLauncher state.

## 5. Endurance Tests

Matter storage must not write EEPROM frequently:

- commit debounce;
- maximum write rate;
- durable state changes only;
- no writes for subscriptions, telemetry, logs or metrics.

## 6. Factory Reset Tests

Verify:

- software reset removes only Dashboard Pi state;
- bootloader recovery is documented separately;
- device returns to uncommissioned Matter state;
- dashboard still boots.

## Current R&D Status

- green: no persistent rootfs fallback.
- yellow: read path options identified.
- red: write safety and absolute size limit are unvalidated.
