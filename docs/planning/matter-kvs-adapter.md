# Matter KVS Adapter

Status: yellow, design only.

`dashboard-pi-matter-storage` is the planned adapter between the local Matter
stack KVS and Dashboard Pi EEPROM-backed state.

## Boot

1. Detect whether the board is an active V1 EEPROM-equipped target.
2. Read `DASHBOARD_PI_STATE_V1` from Raspberry Pi boot EEPROM config.
3. Base64url-decode the payload.
4. Validate schema name and version.
5. Validate CRC32C and SHA-256 integrity fields.
6. If valid, expose decoded Matter KVS entries to the local Matter stack.
7. If invalid or absent, start uncommissioned without failing the dashboard boot.

## Runtime

- Keep the working KVS copy in tmpfs.
- Accept KVS updates from Matter.
- Track durable changes only.
- Debounce EEPROM commits.
- Enforce maximum write frequency.
- Never write EEPROM for subscriptions, telemetry, logs, metrics or temporary
  commands.
- Refuse commits that exceed the encoded state size limit.

## Factory Reset

Factory reset removes only `DASHBOARD_PI_STATE_V1`, clears tmpfs Matter state,
removes generated runtime config and restarts Matter uncommissioned. It must
preserve normal Raspberry Pi bootloader settings and boot order.

## Persist If Size Permits

- Matter fabric table and metadata.
- Operational credentials issued during commissioning.
- ACLs required for commissioned operation.
- Group keys if used and size permits.
- Local Matter node state required across reboot.
- Local endpoint configuration.
- Tiny local scene selector.

## Do Not Persist

- Logs.
- Subscriptions.
- Browser cache.
- Dashboard page state.
- Temporary commands.
- Metrics.
- Support bundles.
- Screenshots.
- DHCP leases.
- Syslog history.
- Volatile runtime status.

## R&D Tests

- One, two and three fabric encoded sizes.
- ACL and group key size impact.
- Corruption handling.
- Power-loss behavior during EEPROM update.
- Pi 4 versus Pi 5 EEPROM layout and update path.
- Preservation across bootloader updates.
