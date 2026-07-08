# V1 Home/Local Appliance Scope

Status: accepted/yellow.

Dashboard Pi V1 is a server-less local appliance. The Raspberry Pi image must
boot and be useful without any Dashboard Pi controller, cloud service, local
appliance server, database, OVA, Helm chart, SAML/OIDC/SCIM, fleet manager or
licensing server.

## Product Behavior

V1 boots a minimal read-only Raspberry Pi image into an initramfs-only runtime.
systemd starts the critical path, systemd-networkd acquires network
configuration, DHCP may provide a dashboard URL and syslog server, and the
dashboard is displayed through the WPEPlatform/Thunder runtime.

Matter runs locally on the Raspberry Pi as a Matter node/server/end-device.
HDMI-CEC navigation runs locally and is filtered through policy. The appliance
tolerates power loss because the root filesystem is not writable and runtime
state is volatile.

## Active V1 Targets

Active targets require suitable onboard EEPROM-backed storage:

- Raspberry Pi 4 Model B;
- Raspberry Pi 400;
- Compute Module 4;
- Compute Module 4S;
- Raspberry Pi 5;
- Raspberry Pi 500/500+;
- Compute Module 5.

Pi 1/2/3/Zero-family devices are unsupported for V1 unless a future persistent
state backend is accepted. Existing defconfigs are historical/experimental.

## Provisioning

DHCP remains the simplest V1 provisioning path:

- DHCPv4 option 60: `Dashboard-Pi` vendor class identifier;
- DHCPv4 option 7: syslog/log server IP addresses;
- DHCPv4 option 224: dashboard URL as text MVP;
- DHCPv4 option 225: reserved future enterprise controller URL, ignored in V1;
- DHCPv4 option 43/125: future production-grade vendor mechanisms;
- DHCPv6 vendor class/vendor options: documented, not a V1 blocker.

Fallback URL order:

1. valid DHCP-provided URL;
2. build-time default URL;
3. local embedded default config;
4. local fallback/adoption/instructions page.

## Safe Defaults

- No SSH by default.
- No persistent writable rootfs.
- Matter power commands control local dashboard state, not TV power.
- CEC TV power control is disabled unless explicitly enabled.
- Logs, DHCP state, browser cache and generated runtime config stay in tmpfs.

## Non-Goals

- No enterprise controller implementation.
- No production database.
- No OVA/Helm packaging.
- No SAML/OIDC/SCIM implementation.
- No license enforcement.
- No generic browser distribution.
- No X11, GTK browser shell, Qt browser shell or Cog primary launcher.
