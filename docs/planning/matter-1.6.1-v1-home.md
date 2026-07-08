# Matter 1.6.1 V1 Home Model

Status: yellow.

This document summarizes the V1 Matter model from the upstream Matter 1.6.1 XML
data model in `connectedhomeip/data_model/1.6.1`.

## Device Type Candidates

| Device type | XML status | Fit for Dashboard Pi V1 |
| --- | --- | --- |
| Casting Video Player | server device with mandatory OnOff, MediaPlayback, KeypadInput and ContentLauncher | preferred if URL launch validates cleanly |
| Basic Video Player | server device with mandatory OnOff, MediaPlayback and KeypadInput | fallback if ContentLauncher is not safe enough |
| Content App | server endpoint for per-app modeling | future/local app manifests only |
| Video Remote Control | client role for controlling a player | not primary identity |

## Dashboard Pi Endpoint Direction

Initial V1 endpoint model:

- root node endpoint with Matter base clusters supplied by the Matter stack;
- one video-player-like endpoint representing the local Dashboard Pi runtime;
- optional diagnostics clusters if they do not create persistence or boot-time
  cost issues;
- no Content App endpoints unless local app manifests are implemented.

## Compliance Notes

The XML-derived matrix is in `matter-cluster-compliance-matrix.md`. Any
implementation must be checked against the exact generated Matter code and
certification requirements at the time it is built; this repository currently
contains only design documentation.

## Deferred Features

- Matter controller/client behavior.
- Multi-app Content App endpoint model.
- Network commissioning for Wi-Fi onboarding.
- Diagnostic log export beyond volatile, policy-filtered support bundles.
- Certified production attestation storage.
