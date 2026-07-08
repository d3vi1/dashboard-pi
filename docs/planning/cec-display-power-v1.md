# CEC Display Power V1

Status: yellow.

HDMI-CEC is useful for remote navigation and optional display power, but it is
vendor-fragile. Dashboard Pi V1 keeps TV power control disabled by default.

## Default Policy

```yaml
display:
  power_model: dashboard-only
  cec:
    enabled: true
    power_control: false
    wake_on_apply_scene: false
    standby_on_blank: false
    active_source_on_wake: true
    allow_matter_to_control_tv_power: false
```

With this policy:

- Matter `OnOff.On` unblanks the dashboard only.
- Matter `OnOff.Off` blanks/hides the dashboard only.
- `LowPower.Sleep` uses local dashboard low-power behavior only.
- CEC remote navigation works through mapping and policy.
- TV standby/wake commands are not sent.

## Optional TV Power Policy

TV power behavior may be enabled only through explicit configuration:

```yaml
display:
  power_model: cec-tv
  cec:
    enabled: true
    power_control: true
    wake_on_apply_scene: false
    standby_on_blank: true
    active_source_on_wake: true
    allow_matter_to_control_tv_power: true
```

Even when enabled, wake, standby and active-source should remain separate
internal actions so the policy can authorize them independently.

## Internal Actions

- `display.power.on`
- `display.power.standby`
- `display.active_source`
- `display.identify`
- `remote.key.up`
- `remote.key.down`
- `remote.key.left`
- `remote.key.right`
- `remote.key.select`
- `remote.key.back`
- `remote.key.menu`
- `remote.key.exit`
- `browser.reload`
- `browser.back`
- `browser.forward`
- `browser.scroll_up`
- `browser.scroll_down`

Raw CEC events must not directly control browser behavior.

## R&D Risks

- Some TVs misreport power status.
- Some TVs ignore standby/wake commands unless active-source state is set.
- Some displays expose no useful vendor/model information.
- Hotplug and active-source timing varies across displays.
