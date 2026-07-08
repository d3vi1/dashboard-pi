# Enterprise Packaging

Status: deferred.

Future enterprise packaging is out of scope for V1. It requires separate R&D:

- OVA virtual appliance.
- Helm chart.
- Air-gapped install.
- Offline update bundles.
- Proxy-aware install.
- Private registry support.
- External database support.
- Bundled database option for small installs.
- Sizing guide.
- Backup/restore guide.
- Upgrade/migration guide.
- Disaster recovery guide.

## Kubernetes Production Behavior

- Readiness probes.
- Liveness probes.
- Startup probes.
- Resource requests/limits.
- PodDisruptionBudget.
- Topology spread/anti-affinity.
- Ingress TLS.
- cert-manager integration.
- External secrets integration.
- Network policies.
- Persistent volume strategy.

## High Availability

- Stateless API replicas.
- Database HA story.
- Queue/job worker HA story.
- Controller leader election if needed.
- Local cache/mirror option for image/content artifacts.
- Device behavior when the controller is unavailable.
