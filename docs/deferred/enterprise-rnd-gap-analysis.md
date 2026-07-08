# Enterprise R&D Gap Analysis

Status: deferred.

## Identity And Access

- SAML2 SSO.
- OIDC SSO.
- SCIM 2.0 user/group provisioning.
- RBAC.
- Site-level admin roles.
- Break-glass local admin.
- Service accounts.
- API tokens and rotation.
- MFA policy hooks.
- Session timeout policy.

## Audit And Compliance

- Immutable audit trail.
- Audit export.
- Admin action history.
- Device action history.
- Configuration change history.
- Image rollout history.
- Failed login tracking.
- Screenshot access audit.
- Retention policies.
- Privacy/GDPR notes.

## Observability

- Prometheus metrics.
- OpenTelemetry traces/logs/metrics.
- Structured JSON logs.
- Syslog/SIEM export.
- Health endpoints.
- Support bundle collection.
- Alerting recommendations.
- Dashboard templates.

## Operations

- Zero-touch enrollment.
- Manual adoption.
- Enrollment tokens.
- Site/group/tag hierarchy.
- Device decommission.
- Factory reset workflow.
- Lost/stolen handling.
- Desired-state revisions.
- Staged rollouts, canary groups and rollback.
- Maintenance windows.
- Offline device behavior.
- Support mode.

## Security And Supply Chain

- mTLS device identity.
- Certificate rotation.
- Controller CA lifecycle.
- Secret management.
- API rate limiting.
- IP allowlists.
- Tenant isolation.
- CSP/security headers.
- Vulnerability scanning.
- SBOM.
- Signed artifacts.
- Provenance/attestation.
- Dependency update policy.

## Integrations

- Grafana alert webhooks.
- Home Assistant webhooks.
- Matter controller/fabric integration.
- Optional MQTT bridge.
- SIEM/syslog.
- Prometheus.
- REST API.
- Webhooks.
- S3-compatible backup targets.
- Future Terraform provider.
