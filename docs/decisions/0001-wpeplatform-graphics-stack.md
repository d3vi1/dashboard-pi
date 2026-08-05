# Decision Record: WPEPlatform Graphics Runtime

Status: Accepted; Buildroot packaging implemented, hardware validation pending

Date: 2026-07-08

## Context

Dashboard Pi needs a minimal fullscreen WebKit runtime for Raspberry Pi boards. The original planning text described WPE WebKit through cog/libwpe. That is no longer the target architecture.

WPE WebKit remains the browser engine target, but the launcher and platform integration should be built around the new WPEPlatform API. WPEPlatform is intended to replace the legacy `libwpe` plus `wpebackend-fdo` integration path and avoids designing Dashboard Pi around cog as the primary launcher.

WPE WebKit 2.52 made WPEPlatform available as an opt-in API in March 2026. The
2.52.5 stable bug-fix release is the current Dashboard Pi pin. Upstream plans to
enable WPEPlatform by default and make the old API legacy in 2.54.

Relevant upstream references:

- WPE WebKit developer overview: https://wpewebkit.org/developers/
- WPE architecture overview, useful as the legacy baseline: https://wpewebkit.org/about/architecture.html
- WebKit graphics documentation for WPE new API DMA-BUF rendering: https://docs.webkit.org/Ports/WebKitGTK%20and%20WPE%20WebKit/Graphics.html
- Igalia WPEPlatform launcher write-up, March 2026: https://blogs.igalia.com/klee/building-a-custom-html-context-menu-with-the-new-wpeplatform-api/
- WPE FAQ and minimal launcher: https://wpewebkit.org/about/faq.html
- WPE WebKit 2.52.5 release: https://wpewebkit.org/release/wpewebkit-2.52.5.html

## Decision

Dashboard Pi will target a custom minimal WPEPlatform-based dashboard launcher instead of cog/libwpe as the primary runtime path.

The launcher should:

- use WPE WebKit with the WPEPlatform API;
- run fullscreen without browser chrome;
- use WPEPlatform window, fullscreen, input, and rendering integration rather than cog platform plugins;
- keep the graphics path DRM/KMS, GBM, Mesa, EGL, DMA-BUF, and Raspberry Pi vc4/v3d focused where supported;
- avoid X11;
- avoid Weston or another compositor unless R&D proves it is needed for a specific board or WPEPlatform backend;
- run as a non-root dashboard user when device permissions allow it;
- expose a narrow control surface for reload, back, forward, page navigation, and relaunch;
- preserve the initramfs-only, volatile runtime design.

`cog`, legacy `libwpe` launcher glue, and `wpebackend-fdo` should be treated as compatibility, comparison, or temporary bring-up tools only. They must not become the default production path unless WPEPlatform is blocked for a target release and the fallback is documented.

## Rationale

The project is optimizing for a maintainable appliance runtime, not a general browser shell. A small launcher owned by this repository gives direct control over boot ordering, URL validation, error-page behavior, CEC/keyboard bindings, logging, crash handling, and first-pixel instrumentation.

WPEPlatform is also the better strategic fit if upstream deprecates the legacy stack. Its new API is GObject-based and moves platform integration into a cleaner layer, reducing the amount of legacy backend and launcher-specific code Dashboard Pi needs to carry.

The WebKit graphics documentation describes the WPE new API using DMA-BUF for accelerated frames, with dynamic buffer/device negotiation and possible direct scanout in fullscreen cases. That aligns with Dashboard Pi's requirement for a hardware-accelerated, fullscreen dashboard on Raspberry Pi DRM/KMS.

## Consequences

Buildroot integration must not simply enable cog and call the browser milestone complete. The project needs either:

- an upstream Buildroot WPE WebKit package new enough to expose WPEPlatform; or
- a Dashboard Pi package overlay for the required WPE WebKit revision and launcher; or
- a temporary development branch using a known-good upstream WebKit/WPE stack until Buildroot catches up.

The launcher becomes a project-owned component. It should remain intentionally small and appliance-specific. It should not grow into a general browser.

The graphics milestone must validate the real Raspberry Pi path, including:

- whether WPEPlatform can run directly on the selected Raspberry Pi DRM/KMS stack without Weston;
- whether the current Buildroot release has sufficient WPEPlatform support;
- required Mesa, EGL, GBM, libdrm, udev, seat/device access, and kernel options;
- vc4/v3d behavior on Raspberry Pi 4 and 5;
- degraded or unsupported acceleration paths on Raspberry Pi 1/2/3;
- first visible content timing, not merely process start.

## Non-Goals

- Do not target cog as the default launcher.
- Do not build a GTK, Qt, or X11 browser shell.
- Do not force static linking for WPE WebKit, Mesa, Wayland-related libraries, or other large graphics/browser userspace components.
- Do not add a persistent writable root filesystem to solve browser cache or runtime state issues.

## Implemented Baseline

- Buildroot remains pinned to `2026.05`.
- `dashboard-pi-wpewebkit` pins WPE WebKit `2.52.5` because Buildroot 2026.05
  and Buildroot master still package 2.50.5.
- The package enables WPEPlatform DRM and headless backends and disables the
  legacy API, Wayland display backend, Qt binding, MiniBrowser and multimedia.
- `dashboard-pi-launcher` links against `wpe-webkit-2.0` and
  `wpe-platform-2.0` and runs with `WPE_DISPLAY=wpe-display-drm`.
- The Pi 4 image includes Mesa EGL/GBM/GLES, V3D, libdrm, libinput, one sans
  font family and CA certificates.

See `0015-buildroot-wpeplatform-pin.md` for the package-version decision.

## Open Validation Items

- Confirm whether Raspberry Pi 4 can use WPEPlatform directly on DRM/KMS/GBM without a compositor in the selected WebKit revision.
- Confirm the C launcher against the cross-built 2.52.5 headers and libraries.
- Measure WPEPlatform launcher startup time against any temporary cog/libwpe baseline used during bring-up.
- Decide whether any board release must temporarily ship a documented legacy fallback because WPEPlatform support is unavailable or unstable there.
