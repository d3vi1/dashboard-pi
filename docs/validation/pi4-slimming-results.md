# Pi 4 slimming results

This report records independently built candidates from the Pi 4 product-valid
slimming pass. Byte counts come from each candidate's
`images/artifact-metrics.json`; they are not estimates from the nominal SD-card
image size. Hardware behavior and first-useful-pixel timing remain separate
acceptance gates.

## Artifact results

| Candidate | Commit | `Image` bytes | Rootfs CPIO bytes | FAT used / allocated bytes | Kernel `y` | `vmlinux` text / data / bss bytes |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| B1 product-valid | `335a3d8` | 174,459,392 | 293,272,064 | 179,011,584 / 201,326,592 | 3,760 | 40,220,756 / 134,053,175 / 1,166,480 |
| Dedicated config mechanism, no selection change | `8e40249` | 174,459,392 | 293,272,064 | 179,011,584 / 201,326,592 | 3,760 | 40,220,756 / 134,053,175 / 1,166,480 |
| Reviewed Pi 4 kernel families | `fcd3c6d` | 129,182,208 | 293,272,064 | 133,734,400 / 201,326,592 | 1,197 | 10,739,084 / 118,238,195 / 426,736 |
| Production VT/fbcon removed | `c7ad467` | 128,969,216 | 293,272,064 | 133,521,408 / 201,326,592 | 1,176 | 10,601,964 / 118,191,731 / 413,808 |
| WPE production feature trim | `8791753` | 123,726,336 | 286,752,256 | 128,278,528 / 201,326,592 | 1,176 | 10,601,964 / 112,966,323 / 413,808 |
| Target `xz` and BusyBox applets removed | `a0855bc` | 123,595,264 | 286,458,368 | 128,147,456 / 201,326,592 | 1,176 | 10,601,964 / 112,832,331 / 413,808 |
| Pi 4 overlay whitelist and dynamic FAT | `0668684` | 123,595,264 | 286,458,368 | 126,345,216 / 145,752,064 | 1,176 | 10,601,964 / 112,833,131 / 413,808 |

`7ce13c6` was an intentionally measured intermediate kernel selection that did
not link because it retained Pi 5 RP1 clock consumers without the RP1 platform
provider. `fcd3c6d` removed the complete unrelated Pi 5/RP1 family and is the
first successful kernel-family candidate. A failed link is recorded as a
dependency finding, not reported as an image reduction.

The first `xz` candidate, `05e7e73`, removed the standalone package but exposed
BusyBox's default `xz`, `xzcat` and `unxz` applets. The product gate rejected
that candidate. `a0855bc` adds an explicit BusyBox fragment and is the first
accepted rootfs candidate. Likewise, removing the overlay symbol from the
defconfig was insufficient because Buildroot defaults it to `y`; `0668684`
explicitly sets it off and is the accepted boot-payload candidate.

## Baseline encoding

At B1, `rootfs.cpio` is an uncompressed SVR4 CPIO report artifact of
293,272,064 bytes. The kernel embeds a distinct gzip-compressed initramfs blob
of 114,465,814 bytes. The raw `Image` outside that embedded archive is
59,993,578 bytes. The kernel settings select gzip for the built-in initramfs and
retain only gzip decompression for early userspace. These representations must
not be described as though `rootfs.cpio` itself were copied byte-for-byte into
`Image`.

## Interpretation

The dedicated-config mechanism was deliberately built before changing kernel
selection and produced the same byte counts as B1. That isolates the mechanism
from the subsequent driver reduction. The successful family trim reduced raw
`Image` by 45,277,184 bytes (25.95 percent) relative to B1. Removing production
VT, framebuffer console and DRM fbdev compatibility reduced a further 212,992
bytes, for a cumulative 45,490,176-byte (26.07 percent) reduction relative to
B1.

The clean WPE candidate removed Web Inspector resources and unused production
backends while retaining the complete multimedia feature gate. It reduced
`Image` by another 5,242,880 bytes relative to the VT/fbcon candidate. The
accepted rootfs candidate removed 293,888 uncompressed CPIO bytes and 131,072
`Image` bytes relative to the clean WPE candidate. The overlay whitelist then
removed 1,802,240 occupied FAT bytes and reduced FAT allocation by 55,574,528
bytes.

Relative to B1, the accepted `0668684` candidate reduces `Image` by 50,864,128
bytes (29.16 percent), uncompressed rootfs CPIO by 6,813,696 bytes (2.32
percent), occupied FAT bytes by 52,666,368 bytes (29.42 percent), and allocated
FAT bytes by 55,574,528 bytes (27.60 percent).

The rootfs size does not fall when kernel-only code is removed because the
uncompressed rootfs report remains the same. The embedded gzip archive and the
kernel proper must therefore be measured separately, as the artifact report
does.

`8791753` was built from an empty Buildroot output directory. The rootfs and
overlay candidates were then generated from an empty target/images tree while
retaining already compiled package build directories. This isolates target
composition from compilation cost. The final `main` acceptance image is built
again from an empty output directory; only that final build supplies the
release-grade package-size report and clean-build reproducibility evidence.

## Product validity boundary

All candidates retain the required build-time selections for WPEPlatform DRM,
Mesa VC4/V3D, GStreamer GL, video, Web Audio, WebCodecs, MSE, ALSA HDMI audio,
CEC, PoE fan support, systemd, DHCP/DHCPv6, volatile logging and a module-free
embedded initramfs. The build gates do not prove rendering, decode acceleration,
HDMI synchronization, CEC behavior, PoE fan operation or boot timing on real
hardware. Those checks remain pending in `pi4-product-matrix.md`.
