# Future dashboard-pi-cec-bridge

Status: yellow, planning only.

`dashboard-pi-cec-bridge` is the future stable bridge between Linux CEC devices,
Dashboard Pi policy and the local dashboard runtime. Early prototypes may use
`cec-ctl`, but the internal interface should remain stable.

## Adapter State

The bridge should expose:

- detected `/dev/cec*` adapters;
- CEC physical address;
- logical address;
- vendor/model information if available;
- active source state;
- display power status if available;
- hotplug/display presence;
- last CEC error;
- supported commands.

## Event Flow

```text
/dev/cec* -> cec bridge -> normalized event -> policy -> mapped action -> runtime
```

Raw events never bypass policy.

## Internal Commands

Display commands:

- `display.power.on`
- `display.power.standby`
- `display.active_source`
- `display.identify`

Remote commands:

- `remote.key.up`
- `remote.key.down`
- `remote.key.left`
- `remote.key.right`
- `remote.key.select`
- `remote.key.back`
- `remote.key.menu`
- `remote.key.exit`

Browser commands:

- `browser.reload`
- `browser.back`
- `browser.forward`
- `browser.scroll_up`
- `browser.scroll_down`

## Policy Inputs

The bridge consumes local config from `docs/protocol/local-config.md`, including:

- `display.power_model`;
- `display.cec.enabled`;
- `display.cec.power_control`;
- `display.cec.wake_on_apply_scene`;
- `display.cec.standby_on_blank`;
- `display.cec.active_source_on_wake`;
- `display.cec.allow_matter_to_control_tv_power`.

## Prototype Guidance

A shell prototype may use `cec-ctl --monitor` for development. It is not the
final architecture and must not be treated as the stable API. The production
bridge should avoid Python on target and should be small enough for the
initramfs appliance.
