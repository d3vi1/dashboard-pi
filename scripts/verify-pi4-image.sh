#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-only
set -euo pipefail

output_dir=${1:?Buildroot output directory required}
repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
buildroot_config="$output_dir/.config"
kernel_config="$output_dir/build/linux-custom/.config"
images="$output_dir/images"
mdir="$output_dir/host/bin/mdir"

fail() {
	printf 'FAILED: %s\n' "$*" >&2
	exit 1
}

require_line() {
	local file=$1
	local line=$2
	rg -qx --fixed-strings "$line" "$file" || fail "$file lacks: $line"
}

reject_enabled() {
	local file=$1
	local symbol=$2
	! rg -qx --fixed-strings "$symbol=y" "$file" || fail "$file enables $symbol"
}

require_cache_value() {
	local file=$1
	local name=$2
	local value=$3
	rg -q "^${name}:[^=]+=${value}$" "$file" \
		|| fail "$file does not set $name=$value"
}

for path in "$buildroot_config" "$kernel_config" "$images/Image" \
	"$images/boot.vfat" "$images/sdcard.img" "$images/artifact-metrics.json"; do
	[[ -e $path ]] || fail "missing artifact: $path"
done

for setting in \
	BR2_PACKAGE_DASHBOARD_PI_WPEWEBKIT \
	BR2_PACKAGE_DASHBOARD_PI_LAUNCHER \
	BR2_PACKAGE_GSTREAMER1 \
	BR2_PACKAGE_GST1_LIBAV \
	BR2_PACKAGE_GST1_PLUGINS_BASE_PLUGIN_ALSA \
	BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_V4L2CODECS; do
	require_line "$buildroot_config" "$setting=y"
done

for setting in \
	BR2_PACKAGE_COG \
	BR2_PACKAGE_WPEWEBKIT \
	BR2_PACKAGE_WPEBACKEND_FDO \
		BR2_PACKAGE_WAYLAND \
		BR2_PACKAGE_WESTON \
		BR2_PACKAGE_XZ \
		BR2_PACKAGE_XORG7 \
	BR2_PACKAGE_RPI_FIRMWARE_INSTALL_DTB_OVERLAYS; do
	reject_enabled "$buildroot_config" "$setting"
done

for setting in \
	CONFIG_MODULES \
	CONFIG_KVM \
	CONFIG_VIRTUALIZATION \
	CONFIG_NUMA \
	CONFIG_COMPAT \
	CONFIG_BTRFS_FS \
	CONFIG_XFS_FS \
	CONFIG_BCACHEFS_FS \
	CONFIG_DRM_FBDEV_EMULATION \
	CONFIG_VT \
	CONFIG_FRAMEBUFFER_CONSOLE; do
	reject_enabled "$kernel_config" "$setting"
done

for setting in \
	CONFIG_BLK_DEV_INITRD \
	CONFIG_DEVTMPFS \
	CONFIG_TMPFS \
	CONFIG_CGROUPS \
	CONFIG_SECCOMP \
	CONFIG_INET \
	CONFIG_IPV6 \
	CONFIG_BCMGENET \
	CONFIG_DRM \
	CONFIG_DRM_VC4 \
	CONFIG_DRM_V3D \
	CONFIG_DRM_VC4_HDMI_CEC \
	CONFIG_CEC_CORE \
	CONFIG_SND \
	CONFIG_SND_SOC \
	CONFIG_SND_SOC_HDMI_CODEC \
	CONFIG_VIDEO_RPI_HEVC_DEC \
	CONFIG_USB_XHCI_HCD \
	CONFIG_USB_HID \
	CONFIG_INPUT_EVDEV \
	CONFIG_MMC \
	CONFIG_MFD_RASPBERRYPI_POE_HAT \
	CONFIG_PWM_RASPBERRYPI_POE; do
	require_line "$kernel_config" "$setting=y"
done

wpe_build=$(find "$output_dir/build" -maxdepth 1 -type d \
	-name 'dashboard-pi-wpewebkit-*' -print -quit)
[[ -n $wpe_build ]] || fail "WPE WebKit build directory not found"
wpe_cache="$wpe_build/CMakeCache.txt"
for setting in \
	ENABLE_MEDIA_SOURCE:BOOL=ON \
	ENABLE_VIDEO:BOOL=ON \
	ENABLE_WEB_AUDIO:BOOL=ON \
	ENABLE_WEB_CODECS:BOOL=ON \
	USE_GSTREAMER:BOOL=ON \
	USE_GSTREAMER_GL:BOOL=ON \
	ENABLE_PDFJS:BOOL=OFF \
	ENABLE_WEBDRIVER:BOOL=OFF \
	ENABLE_WPE_PLATFORM_HEADLESS:BOOL=OFF; do
	require_line "$wpe_cache" "$setting"
done
require_line "$wpe_cache" 'ENABLE_WPE_PLATFORM:BOOL=ON'
require_line "$wpe_cache" 'ENABLE_WPE_PLATFORM_DRM:BOOL=ON'
require_line "$wpe_cache" 'ENABLE_WPE_LEGACY_API:BOOL=OFF'
require_line "$wpe_cache" 'ENABLE_WPE_PLATFORM_WAYLAND:BOOL=OFF'
require_cache_value "$wpe_cache" ENABLE_WEBINSPECTORUI OFF
require_cache_value "$wpe_cache" ENABLE_THUNDER OFF
require_cache_value "$wpe_cache" ENABLE_WK_WEB_EXTENSIONS OFF

rg -q '^dtparam=audio=off$' \
	"$repo_root/br2_external/dashboard_pi/board/raspberrypi/rpi4-64/config.txt" \
	&& fail "production config.txt disables HDMI audio"
rg -q '(^|[[:space:]])console=tty1([[:space:]]|$)' \
	"$repo_root/br2_external/dashboard_pi/board/raspberrypi/rpi4-64/cmdline.txt" \
	&& fail "production cmdline enables tty1"

python3 - "$images/sdcard.img" <<'PY'
from pathlib import Path
import sys

image = Path(sys.argv[1]).read_bytes()[:512]
if len(image) != 512 or image[510:512] != b"\x55\xaa":
    raise SystemExit("FAILED: invalid MBR")
entries = [image[446 + index * 16:462 + index * 16] for index in range(4)]
used = [entry for entry in entries if entry[4] != 0]
if len(used) != 1 or used[0][4] != 0x0C:
    raise SystemExit("FAILED: image must contain exactly one FAT32 LBA partition")
PY

actual_overlays=$(mktemp)
expected_overlays=$(mktemp)
trap 'rm -f "$actual_overlays" "$expected_overlays"' EXIT
"$mdir" -i "$images/boot.vfat" -b ::/overlays \
	| sed -n 's#^::/overlays/##;s/\.dtbo$//p' | sort > "$actual_overlays"
sed 's/#.*//;s/[[:space:]]//g;/^$/d' \
	"$repo_root/br2_external/dashboard_pi/board/raspberrypi/rpi4-64/boot-overlays.list" \
	| sort > "$expected_overlays"
cmp -s "$expected_overlays" "$actual_overlays" \
	|| fail "boot.vfat overlay set differs from the Pi 4 whitelist"

actual_dtbs=$("$mdir" -i "$images/boot.vfat" -b :: \
	| sed -n 's#^::/\(.*\.dtb\)$#\1#p' | sort)
expected_dtbs=$(printf '%s\n' \
	bcm2711-rpi-4-b.dtb \
	bcm2711-rpi-400.dtb \
	bcm2711-rpi-cm4.dtb \
	bcm2711-rpi-cm4s.dtb | sort)
[[ $actual_dtbs == "$expected_dtbs" ]] \
	|| fail "boot.vfat does not contain exactly the four selected Pi 4 DTBs"

actual_root=$("$mdir" -i "$images/boot.vfat" -b :: \
	| sed 's#^::/##;s#/$##' | sort)
expected_root=$(printf '%s\n' \
	Image \
	bcm2711-rpi-4-b.dtb \
	bcm2711-rpi-400.dtb \
	bcm2711-rpi-cm4.dtb \
	bcm2711-rpi-cm4s.dtb \
	cmdline.txt \
	config.txt \
	fixup4.dat \
	overlays \
	start4.elf | sort)
[[ $actual_root == "$expected_root" ]] \
	|| fail "boot.vfat root contains files outside the reviewed Pi 4 payload"

find "$output_dir/target/usr/lib/gstreamer-1.0" -name 'libgst*.so' -print -quit \
	| rg -q . || fail "target has no GStreamer plugins"

if find "$output_dir/target" -type f -name 'inspector.gresource' \
	-print -quit | rg -q .; then
	fail "target contains disabled Web Inspector resources"
fi
if [[ -e $output_dir/target/usr/bin/xz || -e $output_dir/target/bin/xz ]]; then
	fail "target contains the unused xz command"
fi
busybox_config=$(find "$output_dir/build" -maxdepth 2 -path '*/busybox-*/.config' -print -quit)
[[ -n $busybox_config ]] || fail "BusyBox build configuration not found"
for setting in CONFIG_UNXZ CONFIG_XZCAT CONFIG_XZ; do
	reject_enabled "$busybox_config" "$setting"
done

if find "$output_dir/target" -type f \( -name '*.a' -o -name '*.la' \) \
	-print -quit | rg -q .; then
	fail "target contains static archives or libtool metadata"
fi
for directory in usr/include usr/lib/pkgconfig usr/share/pkgconfig; do
	if [[ -d $output_dir/target/$directory ]] \
		&& find "$output_dir/target/$directory" -type f -print -quit | rg -q .; then
		fail "target contains development metadata under /$directory"
	fi
done

printf 'Pi 4 image verification passed: %s\n' "$images/sdcard.img"
