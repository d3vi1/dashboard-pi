# Local Config Protocol

Status: yellow.

Local config is generated at boot from build defaults, DHCP-provisioned values
and EEPROM-backed Dashboard Pi state. It lives in tmpfs. It is validated against
`docs/schemas/local-config.schema.json`.

## Safe Default

```yaml
schema: dashboard-pi-local-config
schema_version: 1
dashboard:
  default_url: null
  fallback_page: file:///usr/share/dashboard-pi/error.html
display:
  power_model: dashboard-only
  cec:
    enabled: true
    power_control: false
    wake_on_apply_scene: false
    standby_on_blank: false
    active_source_on_wake: true
    allow_matter_to_control_tv_power: false
matter:
  enabled: true
  device_type: casting-video-player
```

## Sources

1. Build-time defaults.
2. DHCP/DHCPv6 provisioning.
3. EEPROM-backed durable state.
4. Local scene selection.

DHCP strings remain untrusted and must be validated before entering local config.

## Non-Goals

Local config is not a database. It must not persist browser cache, logs, metrics
or support bundles.
