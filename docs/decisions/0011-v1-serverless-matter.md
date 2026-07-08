# Decision Record: V1 Server-Less Matter

Status: accepted/yellow, implementation pending

Date: 2026-07-08

## Context

Dashboard Pi V1 must be useful without any Dashboard Pi controller, cloud
service, appliance server, database or fleet manager. Matter support must run on
the Raspberry Pi appliance itself.

## Decision

Dashboard Pi V1 exposes local Matter functionality directly from the Raspberry
Pi. In Matter terms, the appliance acts as a Matter node/server/end-device on
the user's Matter fabric. V1 does not implement a Dashboard Pi Matter controller
or require a Dashboard Pi server.

The public design baseline is Matter 1.6 with the `connectedhomeip`
`data_model/1.6.1` XML model. The preferred candidate identity is Casting Video
Player if the WPEPlatform dashboard runtime can cleanly support
`ContentLauncher.LaunchURL` and, later, `ApplicationLauncher`. Basic Video
Player is the fallback if V1 exposes only power, keypad and basic playback-like
semantics.

## Alternatives Considered

- Build an enterprise controller first: rejected for V1 because it would make a
  local appliance depend on a separate product.
- Treat Video Remote Control as the primary identity: rejected because its
  clusters are client-side in the XML model; it is a controller role, not the
  primary Dashboard Pi server identity.
- Ship Matter only through a future controller: rejected because V1 requires
  local Matter usefulness.

## Consequences

Matter commissioning, endpoint state and required durable Matter KVS entries
must be stored locally. Dashboard Pi must define a local Matter storage adapter,
safe factory reset behavior and strict write limits.

## Current Implementation Status

Documentation and schemas only. No Matter SDK, Matter service or Matter
controller is added in this pass.

## R&D Status

- green: server-less V1 product boundary is accepted.
- yellow: selected device type and endpoint composition require prototype
  validation against Matter 1.6.1 and the local WPEPlatform launcher.
- red: any V1 dependency on a Dashboard Pi server or controller.
