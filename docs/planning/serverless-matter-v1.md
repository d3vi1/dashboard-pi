# Server-Less Matter V1

Status: yellow.

Dashboard Pi V1 runs Matter locally on the Raspberry Pi. There is no Dashboard
Pi controller in V1. The Pi joins the user's existing Matter fabric as a
node/server/end-device and exposes endpoints that control the local dashboard
runtime.

## Baseline

- Matter baseline: Matter 1.6.
- Data model source: `connectedhomeip/data_model/1.6.1`.
- XML source paths:
  - `data_model/1.6.1/clusters`;
  - `data_model/1.6.1/device_types`.

The upstream XML files are not vendored because their license must be treated
separately from this GPLv2 repository.

## Candidate Identity

Preferred: Casting Video Player, if V1 can expose `ContentLauncher.LaunchURL`
cleanly and can represent the dashboard runtime as a video-player-like device.

Fallback: Basic Video Player, if V1 should expose only safe power, keypad and
basic playback semantics.

Not primary: Video Remote Control, because the XML model defines it as a client
role for controlling another video device.

Future: Content App endpoints may be added if local app manifests become a V1
feature. They are not required for a server-less dashboard URL appliance.

## Safe V1 Subset

| Matter cluster | V1 mapping | Status |
| --- | --- | --- |
| OnOff | dashboard active/blank only | green |
| LowPower | local blank/low-power dashboard state | green |
| KeypadInput | navigation primitives | green |
| ContentLauncher | `LaunchURL` for safe dashboard URL loads | yellow |
| ApplicationLauncher | local app manifest switching only if manifests exist | deferred |
| ApplicationBasic | expose runtime/app metadata if Content App endpoint is used | deferred |
| MediaPlayback | playlist/video modes only; not generic dashboards | yellow |
| DiagnosticLogs | support bundle/log retrieval policy, volatile only | deferred |
| Ethernet/Wi-Fi/Software Diagnostics | local diagnostic attributes where cheap | yellow |
| PowerSource/PowerSourceConfiguration | expose wired power model if required | yellow |
| PowerTopology | only if endpoint topology needs it | deferred |

## Command Mapping

`OnOff.On` activates or unblanks the dashboard. `OnOff.Off` blanks or hides the
dashboard. Neither command controls TV power by default.

`LowPower.Sleep` enters local low-power/blank behavior. It does not put the TV
into standby by default.

`KeypadInput.SendKey` maps to internal navigation primitives:

- up;
- down;
- left;
- right;
- select;
- back;
- exit;
- menu.

`ContentLauncher.LaunchURL` may load a dashboard URL or temporary URL after the
same validation rules used for DHCP URLs. It must not treat arbitrary dashboard
URLs as media content.

`ApplicationLauncher.LaunchApp` and `StopApp` are deferred until local app
manifests exist. A future app model must define IDs, metadata, allowed URLs and
rollback behavior before exposing these commands.

`MediaPlayback` is reserved for real playlist/video modes. Do not pretend a
Grafana or wallboard URL is generic playable media.

## Implementation Boundary

This pass adds documentation and schemas only. It does not add the Matter SDK,
Matter service, controller code or enterprise server code.
