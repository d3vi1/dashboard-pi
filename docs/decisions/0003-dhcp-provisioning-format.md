# Decision Record: DHCP And DHCPv6 Provisioning Format

Status: Accepted MVP, production vendor format pending

Date: 2026-07-08

## Context

Dashboard Pi needs zero-touch dashboard URL provisioning and optional remote
syslog configuration. DHCP strings are untrusted input and must not be passed to
the shell.

## Decision

For DHCPv4 MVP:

- send vendor class identifier `Dashboard-Pi`;
- request option 224;
- interpret option 224 as a dashboard URL string;
- use standard option 7 for syslog server IPv4 addresses.

For DHCPv6 production work:

- send a vendor class identifying Dashboard Pi;
- use DHCPv6 vendor options rather than reusing DHCPv4 option numbers;
- define suboptions for dashboard URL and logging endpoint after selecting an
  enterprise number strategy.

Fallback order is DHCP URL, local build-time URL, embedded local error page.

## Rationale

Option 224 is easy to configure in common DHCP servers and gives a pragmatic
bring-up path. Vendor options are cleaner for production because they avoid
collisions and support structured extension.

## Safety Requirements

- Accept only `http://` and `https://` URLs from provisioning.
- Reject control characters and shell-sensitive characters.
- Write provisioning results as data under `/run/dashboard-pi`.
- Never evaluate DHCP-provided strings.

## Open Items

- Implement robust systemd-networkd lease parsing for DHCPv6 vendor options.
- Add tests for malformed option 224 values.
- Decide whether syslog protocol/port should be DHCP vendor suboptions.
