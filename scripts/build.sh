#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
buildroot_version=${BUILDROOT_VERSION:-2026.05}
defconfig=${1:-dashboard_pi_rpi4_64_defconfig}
cache_root=${DASHBOARD_PI_CACHE:-"$HOME/.cache/dashboard-pi"}
buildroot_dir=${BUILDROOT_DIR:-"$cache_root/buildroot-$buildroot_version"}
output_base=${DASHBOARD_PI_OUTPUT_BASE:-"$cache_root/output"}
external_link="$cache_root/br2_external_dashboard_pi"

mkdir -p "$cache_root" "$output_base"

if [[ ! -d "$buildroot_dir" ]]; then
	tmp_tar="$cache_root/buildroot-$buildroot_version.tar.xz"
	curl -L --fail --show-error \
		"https://buildroot.org/downloads/buildroot-$buildroot_version.tar.xz" \
		-o "$tmp_tar"
	tar -C "$cache_root" -xf "$tmp_tar"
fi

rm -f "$external_link"
ln -s "$repo_root/br2_external/dashboard_pi" "$external_link"

output_dir="$output_base/$defconfig"
make -C "$buildroot_dir" BR2_EXTERNAL="$external_link" O="$output_dir" "$defconfig"
make -C "$output_dir"

printf '\nBuild output: %s\n' "$output_dir"
printf 'Image: %s/images/sdcard.img\n' "$output_dir"
