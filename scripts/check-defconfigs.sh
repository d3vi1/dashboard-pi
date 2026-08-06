#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
buildroot_version=${BUILDROOT_VERSION:-2026.05}
cache_root=${DASHBOARD_PI_CACHE:-"$HOME/.cache/dashboard-pi"}
buildroot_dir=${BUILDROOT_DIR:-"$cache_root/buildroot-$buildroot_version"}
external_link="$cache_root/br2_external_dashboard_pi"
check_output="$cache_root/check"
check_hostarch=${BUILDROOT_CHECK_HOSTARCH:-x86_64}

mkdir -p "$cache_root" "$check_output"

if [[ ! -d "$buildroot_dir" ]]; then
	tmp_tar="$cache_root/buildroot-$buildroot_version.tar.xz"
	curl -L --fail --show-error \
		"https://buildroot.org/downloads/buildroot-$buildroot_version.tar.xz" \
		-o "$tmp_tar"
	tar -C "$cache_root" -xf "$tmp_tar"
fi

rm -f "$external_link"
ln -s "$repo_root/br2_external/dashboard_pi" "$external_link"

status=0

require_config() {
	local config_file=$1
	local setting=$2
	local name=$3

	if ! rg -qx --fixed-strings "$setting" "$config_file"; then
		printf 'FAILED: %s dropped required setting: %s\n' "$name" "$setting" >&2
		status=1
	fi
}

reject_enabled_config() {
	local config_file=$1
	local symbol=$2
	local name=$3

	if rg -qx --fixed-strings "$symbol=y" "$config_file"; then
		printf 'FAILED: %s enabled forbidden setting: %s=y\n' "$name" "$symbol" >&2
		status=1
	fi
}

for cfg in "$repo_root"/br2_external/dashboard_pi/configs/*_defconfig; do
	name=$(basename "$cfg")
	out="$check_output/${name%.defconfig}"
	rm -rf "$out"
	if ! make -C "$buildroot_dir" BR2_EXTERNAL="$external_link" O="$out" \
		HOSTARCH="$check_hostarch" "$name"; then
		printf 'FAILED: %s\n' "$name" >&2
		status=1
		continue
	fi

	require_config "$out/.config" 'BR2_INIT_SYSTEMD=y' "$name"
	require_config "$out/.config" 'BR2_PACKAGE_DASHBOARD_PI_RUNTIME=y' "$name"
	require_config "$out/.config" 'BR2_TARGET_ROOTFS_INITRAMFS=y' "$name"
	require_config "$out/.config" '# BR2_TARGET_ROOTFS_TAR is not set' "$name"

	if [[ $name == dashboard_pi_rpi4_64_defconfig ]]; then
		require_config "$out/.config" 'BR2_PACKAGE_DASHBOARD_PI_WPEWEBKIT=y' "$name"
		require_config "$out/.config" 'BR2_PACKAGE_DASHBOARD_PI_LAUNCHER=y' "$name"
		require_config "$out/.config" 'BR2_PACKAGE_MESA3D_GBM=y' "$name"
		require_config "$out/.config" 'BR2_PACKAGE_MESA3D_OPENGL_EGL=y' "$name"
		require_config "$out/.config" 'BR2_PACKAGE_MESA3D_OPENGL_ES=y' "$name"
		require_config "$out/.config" 'BR2_PACKAGE_LIBINPUT=y' "$name"
		require_config "$out/.config" 'BR2_PACKAGE_CA_CERTIFICATES=y' "$name"
		require_config "$out/.config" 'BR2_PACKAGE_SHARED_MIME_INFO=y' "$name"
		require_config "$out/.config" 'BR2_PACKAGE_GSTREAMER1_INSTALL_TOOLS=y' "$name"
		require_config "$out/.config" 'BR2_PACKAGE_GST1_LIBAV=y' "$name"
		require_config "$out/.config" 'BR2_PACKAGE_GST1_PLUGINS_BAD_PLUGIN_V4L2CODECS=y' "$name"
		require_config "$out/.config" 'BR2_PACKAGE_GST1_PLUGINS_BASE_LIB_OPENGL_EGL=y' "$name"
		require_config "$out/.config" 'BR2_PACKAGE_GST1_PLUGINS_BASE_PLUGIN_ALSA=y' "$name"
		require_config "$out/.config" 'BR2_PACKAGE_GST1_PLUGINS_GOOD_PLUGIN_ISOMP4=y' "$name"
		require_config "$out/.config" 'BR2_PACKAGE_GST1_PLUGINS_GOOD_PLUGIN_VPX=y' "$name"
		reject_enabled_config "$out/.config" BR2_PACKAGE_WPEWEBKIT "$name"
		reject_enabled_config "$out/.config" BR2_PACKAGE_WPEBACKEND_FDO "$name"
		reject_enabled_config "$out/.config" BR2_PACKAGE_COG "$name"
	fi
done

exit "$status"
