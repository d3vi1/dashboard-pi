# Decision Record: CEC Power Safe Defaults

Status: accepted/yellow, implementation pending

Date: 2026-07-08

## Context

Dashboard Pi receives control inputs from HDMI-CEC and Matter. CEC display power
behavior is vendor-fragile: televisions differ in standby, active-source,
hotplug and wake semantics. A home appliance must not surprise users by turning
an attached TV on or off because a dashboard state changed.

## Decision

The safe default is dashboard-only power control:

```yaml
display:
  power_model: dashboard-only
  cec:
    enabled: true
    power_control: false
    allow_matter_to_control_tv_power: false
```

Matter `OnOff.On` unblanks or activates the local dashboard. Matter
`OnOff.Off` blanks or hides the dashboard, or displays a local standby screen.
`LowPower.Sleep` uses local low-power/blank behavior. None of these commands
put the TV into standby by default.

TV power actions are separate opt-in commands controlled by policy:

- wake attached TV through HDMI-CEC;
- put attached TV into standby through HDMI-CEC;
- mark Dashboard Pi as active source;
- allow Matter power commands to affect TV power.

Raw CEC events must never directly control browser or TV power behavior. Events
flow through a mapping layer and then through policy.

## Alternatives Considered

- Default to CEC TV power control: rejected because it is unsafe and surprising.
- Disable CEC entirely by default: rejected because remote navigation is useful
  and can be safe if power control remains disabled.
- Bind Matter OnOff directly to TV standby: rejected because the Matter node is
  the Dashboard Pi appliance, not necessarily the television.

## Consequences

The first CEC bridge must expose state and actions separately. UI/configuration
may later enable TV power behavior, but the shipped policy remains conservative.

## R&D Status

- green: dashboard-only power semantics are accepted.
- yellow: CEC device discovery and display power reporting must be tested across
  televisions.
- red: automatic TV power control without explicit policy is not allowed.
