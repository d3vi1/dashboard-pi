# Decision Record: Buildroot WPEPlatform Version Pin

Status: Accepted, cross-build and hardware validation pending

Date: 2026-08-05

## Context

Dashboard Pi needs the WPEPlatform API and its built-in DRM/KMS backend without
the legacy `libwpe` and `wpebackend-fdo` path. Buildroot 2026.05 and Buildroot
master package WPE WebKit 2.50.5, select `wpebackend-fdo`, and do not enable the
new API. WPE WebKit 2.52.5 is a stable upstream bug-fix release and supports an
opt-in WPEPlatform-only build.

## Decision

Keep the Buildroot baseline at 2026.05 and package WPE WebKit 2.52.5 inside the
Dashboard Pi external tree as `dashboard-pi-wpewebkit`.

The package must enable:

- `ENABLE_WPE_PLATFORM=ON`;
- `ENABLE_WPE_PLATFORM_DRM=ON`;
- `ENABLE_WPE_PLATFORM_HEADLESS=OFF` in the production package;
- `USE_LIBDRM=ON` and `USE_GBM=ON`.
- `USE_GSTREAMER=ON` and `USE_GSTREAMER_GL=ON`.

It must disable:

- `ENABLE_WPE_LEGACY_API`;
- the WPEPlatform Wayland display backend;
- the Qt API, MiniBrowser, PDFJS, WebDriver, Web Inspector UI and WebRTC.

Multimedia is a product requirement, not a bring-up option. Video, Web Audio,
WebCodecs and Media Source Extensions remain enabled. Buildroot 2026.05 lacks a
Kconfig choice for GStreamer's direct EGL/GBM winsys, so the external tree adds
that supported Meson configuration without pulling in X11 or Wayland.

The Pi 4 defconfig must select this package and the project-owned C launcher.
It must not select Buildroot's `wpewebkit`, `wpebackend-fdo` or Cog packages.

## Why Not Patch Buildroot

An external package keeps the project on a released Buildroot baseline and
avoids carrying modifications inside a vendored Buildroot tree. It also makes
the divergence easy to remove when a future Buildroot release provides a
WPEPlatform-only package with equivalent options.

## Verification Contract

CI must:

1. evaluate every defconfig for a Linux x86_64 host;
2. assert that systemd and initramfs remain enabled;
3. assert the Pi 4 WPEPlatform, EGL, GBM, GLES, GStreamer/GL, ALSA, libinput,
   CA and MIME symbols;
4. reject enabled legacy WPE WebKit, backend-fdo and Cog symbols;
5. download the WPE WebKit 2.52.5 source through Buildroot and verify its hash.

A successful source download is not a successful WPE build. Release readiness
still requires a Linux x86_64 cross-build, boot on Raspberry Pi 4, proof of V3D
acceleration and measurement to first useful pixels.

## Rollback

Remove the external WPE package only after a pinned Buildroot release provides
the same WPEPlatform-only feature set. A fallback to Cog or legacy libwpe needs
a separate decision record and must remain explicitly non-production.
