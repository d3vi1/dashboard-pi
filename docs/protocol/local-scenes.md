# Local Scenes Protocol

Status: yellow.

Local scenes are small dashboard/display presets. They are not a replacement for
an enterprise desired-state system.

## Scene Model

A scene may contain:

- scene ID;
- dashboard URL or local app ID;
- display blank/active state;
- optional CEC active-source request;
- optional TV wake/standby request, allowed only if policy permits it.

## Safe Behavior

Applying a scene must not wake or standby the TV unless:

- CEC is enabled;
- CEC power control is enabled;
- the scene requests that action;
- policy allows the source of the request.

## Matter Mapping

Matter Scenes may later map to local scenes, but only small scene selectors may
be persisted in EEPROM. Full scene tables, logs and telemetry stay out of
EEPROM.
