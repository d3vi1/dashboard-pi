# Raspberry Pi 4 production kernel

Dashboard Pi uses
`board/raspberrypi/rpi4-64/dashboard-pi-rpi4.config`, generated for the pinned
Raspberry Pi Linux commit. It is a complete custom configuration, not
`bcm2711_defconfig` with module support disabled.

## Generation method

1. Generate `bcm2711_defconfig` with modules enabled.
2. Record every `CONFIG_*=m` symbol.
3. Change all recorded modules to `n`.
4. Promote only the reviewed appliance features below to `y`.
5. Disable the unrelated built-in families listed below.
6. Set `CONFIG_MODULES=n` and run `olddefconfig` with the pinned AArch64
   toolchain.
7. Build `Image` and all four selected Pi 4-family DTBs.

The integration baseline had 3,760 `CONFIG_*=y` values because disabling
module support over the broad Raspberry Pi configuration promoted a large
driver set. Counts for the final configuration and binary section sizes are
recorded by `artifact-metrics.json` on every full build.

## Required feature groups

| Group | Principal built-in symbols | Reason |
| --- | --- | --- |
| Platform | `ARCH_BCM2835`, `SMP`, `RASPBERRYPI_FIRMWARE` | BCM2711 and four Cortex-A72 cores |
| Root/runtime | `BLK_DEV_INITRD`, `DEVTMPFS`, `PROC_FS`, `SYSFS`, `TMPFS` | Embedded initramfs and volatile systemd runtime |
| Isolation | `CGROUPS`, namespaces, `SECCOMP`, `BPF_SYSCALL` | Existing systemd service hardening |
| Network | `INET`, `IPV6`, `PACKET`, `UNIX`, `BCMGENET`, Broadcom PHY/MDIO | networkd DHCP/DHCPv6 over onboard Ethernet |
| Display/GPU | `DRM`, `DRM_VC4`, `DRM_V3D`, DRM helpers | WPEPlatform direct DRM/KMS and Mesa V3D |
| Audio | `SND`, `SND_PCM`, `SND_SOC`, `SND_SOC_HDMI_CODEC` | VC4 KMS HDMI audio through ALSA/GStreamer |
| CEC/input | `CEC_CORE`, `DRM_VC4_HDMI_CEC`, `MEDIA_CEC_RC`, `INPUT_EVDEV`, USB HID | CEC bridge and keyboard fallback |
| Video decode | V4L2 mem2mem/videobuf2, `VIDEO_RPI_HEVC_DEC`, `VIDEO_CODEC_BCM2835` | Pi 4 HEVC plus legacy V4L2 H.264 path pending hardware validation |
| Storage/USB | BCM MMC/SDHCI, xHCI host, DWC2 host, USB storage | SD, eMMC and USB diagnostics/boot-media support |
| Board health | thermal, BCM2835 watchdog, Raspberry Pi hwmon | unattended appliance operation |
| PoE | `MFD_RASPBERRYPI_POE_HAT`, `PWM_RASPBERRYPI_POE` | Preserve official PoE/PoE+ HAT fan support |

`CONFIG_STAGING=y` is a reviewed exception: the pinned Raspberry Pi kernel
still locates `VIDEO_CODEC_BCM2835`, VCHIQ MMAL and VC shared-memory support
under staging. Other staging drivers inherited as modules are disabled.

## Deliberate exclusions

The production configuration excludes modules; KVM and generic virtualization;
NUMA; AArch32 compatibility; Xen; netfilter/NAT/bridging/tunnels; unrelated
network vendors; Bluetooth and Wi-Fi pending the connectivity milestone;
software RAID, device mapper and bcache; unused local/network filesystems;
unrelated media capture, tuner, DVB and radio families; USB gadget stacks;
fbdev, VT and framebuffer console; AppArmor/audit/integrity policy stacks; and
production tracing, profiling, KGDB/KDB and debugfs.

These exclusions describe this Ethernet dashboard profile. They do not decide
the future Wi-Fi or Matter commissioning architecture.

## UART debug profile

Production keeps the UART drivers but omits serial-console support and has no
console argument. For a diagnostic build, apply
`linux-debug-uart.fragment`, add `enable_uart=1` to the firmware configuration,
and use `cmdline-debug-uart.txt`. Do not ship that profile as the production
image.

The production command line retains `root=/dev/ram0` until the first hardware
boot comparison proves it can be removed without changing firmware or kernel
handoff behavior.

## Hardware gates

Cross-compilation proves configuration consistency, not device behavior. Before
calling this configuration product-valid, test Pi 4B and CM4 where available:

- boot from SD, eMMC and USB as applicable;
- both HDMI connectors at native EDID resolution;
- DRM/V3D rendering without llvmpipe;
- HTML5/YouTube video and synchronized HDMI audio;
- CEC navigation;
- PoE and PoE+ HAT fan control;
- Ethernet DHCP/DHCPv6 and remote syslog;
- UART logs and first-useful-pixel timing.
