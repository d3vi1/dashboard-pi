# DHCPv6 Notes

Dashboard Pi should use DHCPv6 vendor class and vendor options rather than
reusing DHCPv4 option numbers.

Planned production mechanism:

- Client sends OPTION_VENDOR_CLASS identifying `Dashboard-Pi`.
- Server replies with OPTION_VENDOR_OPTS under the Dashboard Pi enterprise
  number or a project-assigned temporary enterprise number during development.
- Suboption 1: dashboard URL string.
- Suboption 2: remote syslog endpoint string.

The current runtime contains only the DHCPv4 option 224 MVP parser. DHCPv6
vendor-option parsing is Milestone 3 work.
