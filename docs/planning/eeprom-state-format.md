# EEPROM State Format

Status: yellow, schema added.

Dashboard Pi V1 stores durable local Matter state as a single boot EEPROM config
variable on supported Raspberry Pi models:

```text
DASHBOARD_PI_STATE_V1=<base64url(payload)>
```

The payload is JSON before encoding and is validated against
`docs/schemas/dashboard-pi-state-v1.schema.json`.

## Conceptual Payload

```json
{
  "schema": "dashboard-pi-state",
  "schema_version": 1,
  "device": {
    "state_generation": 0,
    "factory_reset_generation": 0
  },
  "matter": {
    "enabled": true,
    "commissioned": false,
    "node_label": "Dashboard Pi",
    "fabric_state": {
      "encoding": "chip-kvs-v1",
      "payload": "base64url..."
    }
  },
  "local": {
    "last_scene": "default-dashboard"
  },
  "integrity": {
    "crc32c": "...",
    "payload_sha256": "..."
  }
}
```

## Size Limits

- Target encoded maximum: 3000 bytes.
- Absolute maximum: red until measured on real Raspberry Pi boot EEPROM config
  storage across Pi 4/400/CM4/CM4S and Pi 5/500/CM5.

If state does not fit safely:

- do not write partial state;
- do not fake Matter persistence;
- do not fall back silently to writable rootfs;
- mark the board/storage status red or yellow;
- document future alternatives.

## Integrity

Integrity fields are computed over the canonical payload without the integrity
object. The reader must ignore the state safely if schema, CRC32C or SHA-256
validation fails.

## Migration

Readers must be schema-version aware:

- known same version: read normally;
- known older version: migrate in tmpfs, then commit only after successful
  validation and write debounce;
- newer unknown version: ignore safely and stay uncommissioned unless a
  documented compatibility path exists.

## Write Policy

EEPROM writes are rare and durable only. Writes require debounce and a maximum
write rate. Runtime telemetry, subscriptions, logs and browser state never
trigger EEPROM writes.
