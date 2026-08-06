# Pi 4 integration baseline at 8c0c70e

This directory preserves the first structurally complete Raspberry Pi 4 image
at commit `8c0c70e13d58b5645227b07dd1f622ff56d2e792`. The public tag is
`pi4-integration-baseline-8c0c70e`.

This is an integration baseline, not a product-valid size or fast-boot
baseline. In particular, its WPE WebKit build has multimedia disabled. Size
reductions after multimedia restoration must be compared with the separate
`B1-product-valid` baseline, not with these numbers.

Measured artifacts:

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| `Image` | 154601984 | `b82313ec01b61416da269e238bd98eb6c4e8130bcd34ca1223f81442d915818e` |
| `rootfs.cpio` | 248381952 | `6e71e04ead76846a6b5bb77503ee78d26500c4cbf4791979ca17b2ccd471951a` |
| `boot.vfat` | 201326592 | `618d4b17e3e2d109759f998623ba2194adda7ff6b94007d0e4ec9876ccdb5826` |
| `sdcard.img` | 201327104 | `16521229957366b6fc4643875d7218a05775af1efb2421474eda04fabb7112ff` |

The FAT allocation is 201326592 bytes; 159154176 bytes are occupied according
to `mdir`. `rootfs.cpio` is an uncompressed SVR4 archive. The kernel separately
uses `CONFIG_INITRAMFS_COMPRESSION_GZIP=y` when embedding that archive.

`artifact-metrics.json` is the canonical machine-readable report. The saved
Buildroot reports and generated configurations are immutable evidence for this
baseline.
