# Factory Reset

Status: yellow, design only.

Dashboard Pi factory reset clears Dashboard Pi state while preserving Raspberry
Pi bootability.

## Reset Clears

- `DASHBOARD_PI_STATE_V1` from boot EEPROM config.
- Volatile Matter runtime state.
- Local runtime config generated from EEPROM.
- Temporary Matter/CEC overrides.

## Reset Preserves

- Raspberry Pi bootloader settings.
- Boot order.
- Unknown non-Dashboard-Pi EEPROM keys.
- The ability to boot the appliance image.

## Methods

### Software

`dashboard-pi-factory-reset` removes `DASHBOARD_PI_STATE_V1`, schedules a safe
EEPROM config update, clears tmpfs runtime state and reboots.

### Optional Hardware Trigger

A GPIO/button hold at boot may request reset. The handler must clear only
Dashboard Pi state. It must not perform full bootloader recovery.

### Full Bootloader Recovery

Full bootloader recovery is a separate Raspberry Pi recovery procedure and is
not the normal Dashboard Pi factory reset.

## Failure Handling

If EEPROM update fails, the tool must report failure and avoid pretending reset
completed. If state is corrupt, reset may remove the Dashboard Pi variable
without attempting to parse the payload.

## Tests

- Software reset removes only Dashboard Pi state.
- Bootloader reset clears all bootloader config and is documented separately.
- Device returns to uncommissioned Matter state.
- Dashboard still boots after reset.
