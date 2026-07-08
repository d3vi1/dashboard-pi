# Matter Cluster Compliance Matrix

Status: yellow.

Source: upstream `connectedhomeip/data_model/1.6.1` XML files read on
2026-07-08. The XML files are not copied into this repository.

## Device Type Cluster Matrix

| Cluster | Casting Video Player | Basic Video Player | Content App | Video Remote Control | V1 stance |
| --- | --- | --- | --- | --- | --- |
| On/Off | server mandatory | server mandatory | absent | client mandatory | implement dashboard active/blank |
| Media Playback | server mandatory | server mandatory | server optional | client mandatory | implement only if real media/playlist mode exists |
| Keypad Input | server mandatory | server mandatory | server mandatory | client mandatory | implement navigation subset |
| Content Launcher | server mandatory | absent | server optional | client optional | preferred URL-launch path for Casting Video Player |
| Application Launcher | server mandatory if ContentAppPlatform | absent | server mandatory | client optional | defer until local app manifests exist |
| Application Basic | absent | absent | server mandatory | absent | defer with Content App endpoint |
| Low Power | server optional | server optional | absent | client optional | implement local sleep/blank only |
| Content Control | provisional/optional | provisional/optional | absent | provisional/optional client | defer |
| Content App Observer | absent | absent | client mandatory if ObserverClient | absent | defer |
| Media Input | server mandatory if PhysicalInputs | server mandatory if PhysicalInputs | absent | client optional | avoid unless physical media inputs are modeled |
| Channel | server optional | server optional | server optional | client optional | defer |
| Target Navigator | server optional | server optional | server optional | client optional | defer |
| Wake On LAN | server optional | server optional | absent | client optional | defer; not CEC wake |
| Audio Output | server optional | server optional | absent | client optional | defer |

## Cluster Command Summary

| Cluster | Relevant commands | V1 decision |
| --- | --- | --- |
| OnOff | Off, On, Toggle, OffWithEffect, OnWithRecallGlobalScene, OnWithTimedOff | support On/Off; map Toggle only after state model exists |
| LowPower | Sleep | support local dashboard blank/sleep |
| KeypadInput | SendKey | support navigation keys only |
| ContentLauncher | LaunchContent, LaunchURL | support LaunchURL only after URL validation and policy are implemented |
| ApplicationLauncher | LaunchApp, StopApp, HideApp | defer until local app manifest model exists |
| MediaPlayback | Play, Pause, Stop, Previous, Next, seek/track commands | defer except real media modes |
| DiagnosticLogs | RetrieveLogsRequest | defer; must be volatile and policy-filtered |
| Ethernet/Wi-Fi/Software Diagnostics | ResetCounts, ResetWatermarks | diagnostic-only; no boot blocker |
| Scenes | Add/View/Remove/Store/Recall/Copy scene commands | defer local scene mapping until scene schema is implemented |

## V1 Implemented Subset

Initial safe subset:

- `OnOff.On` -> dashboard active/unblank.
- `OnOff.Off` -> dashboard blank/inactive.
- `LowPower.Sleep` -> local blank/low-power behavior.
- `KeypadInput.SendKey` -> up/down/left/right/select/back/exit/menu.
- `ContentLauncher.LaunchURL` -> validated dashboard URL load, if Casting Video
  Player is selected.

Deferred subset:

- Content Control.
- Content App Observer.
- Application Launcher and Application Basic unless local app manifests exist.
- Scenes cluster persistence beyond a tiny local scene selector.
- Network Commissioning unless selected device type or Wi-Fi onboarding requires
  it.

## R&D Gaps

- Confirm generated Matter code requirements for base/root-node clusters.
- Validate whether Casting Video Player can represent a dashboard appliance
  without misrepresenting non-media dashboard URLs.
- Measure EEPROM payload size after one, two and three fabrics.
- Confirm certification implications of EEPROM-backed KVS.
