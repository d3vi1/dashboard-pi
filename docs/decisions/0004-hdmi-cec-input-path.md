# Decision Record: HDMI-CEC Input Path

Status: Accepted direction, implementation pending

Date: 2026-07-08

## Context

Dashboard Pi needs basic remote-control navigation. The browser platform is now
WPEPlatform, so the CEC path must target a project-owned launcher control
surface rather than Cog-specific behavior.

## Decision

Use the Linux kernel CEC device path exposed as `/dev/cec*` where available.
During early bring-up, allow `cec-ctl` or `cec-client` only as diagnostic tools.
The production design should translate CEC key events into a narrow Dashboard Pi
launcher API:

- reload;
- back;
- forward;
- scroll/page navigation;
- relaunch.

## Rationale

The kernel CEC API matches the DRM/KMS direction and keeps the integration close
to the platform devices that Raspberry Pi exposes under the full KMS stack.
A launcher-owned API avoids binding CEC behavior to a temporary browser tool.

## Open Items

- Confirm exact Raspberry Pi CEC kernel symbols for Pi 4 and Pi 5.
- Decide whether the daemon should be C/C++ or a small event bridge script.
- Define the launcher IPC/event mechanism.
- Test HDMI-CEC behavior across displays, because TV implementations vary.
