# V1 Target Matrix

Status: yellow.

V1 requires suitable onboard EEPROM-backed storage for local Matter persistence.
This removes older Raspberry Pi models from the active V1 support matrix.

| Board | Defconfig | V1 status | EEPROM state status | Notes |
| --- | --- | --- | --- | --- |
| Raspberry Pi 4 Model B | `dashboard_pi_rpi4_64_defconfig` | active | yellow | Primary validation target |
| Raspberry Pi 400 | `dashboard_pi_rpi4_64_defconfig` | active | yellow | Pi 4-class platform |
| Compute Module 4 | `dashboard_pi_rpi4_64_defconfig` | active | yellow | Carrier-specific boot media validation needed |
| Compute Module 4S | `dashboard_pi_rpi4_64_defconfig` | active | yellow | Validate EEPROM behavior |
| Raspberry Pi 5 | `dashboard_pi_rpi5_defconfig` | best effort | yellow/red | Pi 5 EEPROM/A-B behavior requires R&D |
| Raspberry Pi 500/500+ | `dashboard_pi_rpi5_defconfig` | best effort | yellow/red | Validate model detection |
| Compute Module 5 | `dashboard_pi_rpi5_defconfig` | best effort | yellow/red | Carrier-specific validation needed |
| Raspberry Pi 1 | `dashboard_pi_rpi1_defconfig` | unsupported for V1 | red | Historical/experimental only |
| Raspberry Pi 2 | `dashboard_pi_rpi2_defconfig` | unsupported for V1 | red | Historical/experimental only |
| Raspberry Pi 3 | `dashboard_pi_rpi3_64_defconfig` | unsupported for V1 | red | Historical/experimental only |
| Raspberry Pi Zero family | none | unsupported for V1 | red | No V1 EEPROM persistence backend |

## Support Rule

If no supported EEPROM-backed state path is detected, V1 support check fails.
Do not silently fall back to a writable rootfs or hidden state partition.
