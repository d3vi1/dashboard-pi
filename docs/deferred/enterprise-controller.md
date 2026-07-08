# Deferred Enterprise Controller

Status: deferred.

The enterprise controller is a separate future product boundary. It is not part
of Dashboard Pi V1 and must not be required for the appliance to boot, display a
dashboard, receive DHCP provisioning, run local Matter or process CEC input.

## Product Boundary

The V1 appliance remains open-source and server-less. A future enterprise
controller may be separately licensable and may live in a separate repository or
clearly separated source tree. It should use a documented API/protocol boundary
so the open appliance does not accidentally pull commercial controller code into
the GPLv2 appliance licensing boundary.

## Required Future Capabilities

- Device enrollment and adoption.
- Fleet desired-state management.
- Image rollout orchestration.
- Centralized logging and audit.
- RBAC and enterprise identity.
- High availability and backup/restore.
- Support bundles.
- Edition and feature-gate model.

## V1 Non-Goals

- No enterprise controller implementation.
- No production database.
- No OVA or Helm builder.
- No SAML2/OIDC/SCIM implementation.
- No license enforcement.
