# Pi 4 product validation matrix

This matrix separates build evidence from Raspberry Pi hardware evidence. A
successful cross-build does not validate decoding, synchronization, graphics
acceleration or first visible pixels.

| Capability | Build gate | Hardware gate | Current status |
| --- | --- | --- | --- |
| WPEPlatform DRM | DRM backend on; legacy, headless and Wayland backends off | Page renders through `wpe-display-drm` | Build-gated; hardware pending |
| Mesa acceleration | V3D/GBM/EGL/GLES packages and VC4/V3D kernel drivers | Renderer is V3D, never llvmpipe | Build-gated; hardware pending |
| HTML5 video | WPE video, MSE, WebCodecs and GStreamer on | Local test clip displays | Build-gated; hardware pending |
| MP4/H.264/AAC | isomp4, parsers and gst-libav present | Software fallback and Pi decode path play correctly | Build-gated; hardware pending |
| WebM/VP9/Opus | matroska, VPX and Opus components present | 1080p workload plays within thermal limits | Build-gated; hardware pending |
| GStreamer GL | `gstreamer-gl-1.0` built for EGL/GBM | DMA-BUF/GL path observed without copies where supported | Build-gated; hardware pending |
| HDMI audio | ALSA plugin and VC4 HDMI codec built; firmware audio not disabled | Audible synchronized output on both applicable connectors | Build-gated; hardware pending |
| YouTube | Required web/media features remain enabled | Playback, fullscreen and recovery test | Hardware pending |
| CEC | Kernel CEC, libcec and bridge service present | Remote reload/back/forward/navigation | Build-gated; hardware pending |
| PoE fan | Kernel drivers and PoE overlay files present | PoE and PoE+ fan thresholds operate | Build-gated; hardware pending |

`artifact-metrics.json` records every installed `libgst*.so` file. That is a
static packaging manifest only. The target includes `gst-inspect-1.0`; capture
its registry and the libraries/plugins opened by the WPE processes on real Pi 4
hardware before removing any further plugin.

Recommended target capture:

```sh
gst-inspect-1.0 > /run/dashboard-pi/gst-inspect.txt
GST_DEBUG=2 dashboard-pi-launcher 2> /run/dashboard-pi/gstreamer.log
```

Do not enable the debug logging in production or use it for boot-time results.
