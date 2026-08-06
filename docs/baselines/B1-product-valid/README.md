# Pi 4 product-valid baseline B1

This directory preserves the first complete Pi 4 build with the mandatory
multimedia and HDMI audio paths restored. The source commit is
`335a3d8b911c7acc314a4fd6f3131482c57e9c91`, published as the annotated tag
`B1-product-valid`.

This is the comparison point for the Pi 4 slimming pass. It is not a hardware
validation result or a boot-time result.

## Build evidence

- Buildroot: `2026.05`
- Raspberry Pi Linux: `21b410140c47ffab5668399f6f143c7d7b935c8b`
- WPE WebKit: `2.52.5`
- WPE multimedia, MSE, video, WebAudio, WebCodecs and GStreamer GL: enabled
- GStreamer shared plugin files: 32
- Kernel `CONFIG_*=y` count: 3,760
- Installed kernel modules: 0

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| `Image` | 174459392 | `fa8d1f024a599be08cd9c0c34547c7019ec9fa15ae933897365824d0515883c0` |
| `rootfs.cpio` | 293272064 | `2df71c940a6067a76ac56a08de7e2efe64db7f574e6b65c7eae6c261437797a8` |
| `boot.vfat` | 201326592 | `2d7e67b801fed96d97ed444e8b0a6c68baa5f3065f20df5dbaa9f45ca16708d5` |
| `sdcard.img` | 201327104 | `d5a80f7ed65e6778117d05184d5a88030e647449bcd3ad703a2c0a9e75608247` |

The FAT allocation is 201326592 bytes; 179011584 bytes are occupied and
22315008 bytes are free according to `mdir`.

`rootfs.cpio` is an uncompressed SVR4 archive. The kernel build separately
compresses it with `CONFIG_INITRAMFS_COMPRESSION_GZIP=y`; the resulting
`usr/initramfs_inc_data` embedded blob is 114465814 bytes. Subtracting those
archive bytes from the 174459392-byte raw `Image` leaves 59993578 bytes for
the kernel payload and alignment. This subtraction is useful accounting, not
a claim that the residual is one ELF section.

The generated `vmlinux` section totals are 40220756 bytes of text, 134053175
bytes of data and 1166480 bytes of BSS. The broad baseline also enables every
`CONFIG_RD_*` decompressor; those are reviewed during kernel slimming while
gzip remains required.

## Scope and limitations

The full cross-build proves that WPE and its Web/GPU/Network processes link
with the selected GStreamer, EGL/GBM and ALSA dependencies. It does not prove
Pi 4 rendering, codec behavior, HDMI audio synchronization, CEC, PoE fan
operation or first-useful-pixel timing. Those remain hardware gates.

`gstreamer-plugin-files.tsv` is a static package manifest. A runtime
`gst-inspect-1.0` manifest and dynamically loaded-library trace must be
captured on Pi 4 before removing multimedia plugins.

The saved Buildroot and Linux configurations, CMake options, package/file size
reports and machine-readable artifact report are immutable evidence for B1.
