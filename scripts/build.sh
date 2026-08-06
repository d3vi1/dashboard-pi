#!/usr/bin/env bash
set -euo pipefail

if [[ $(uname -s) != Linux || $(uname -m) != x86_64 ]]; then
	printf '%s\n' \
		'Dashboard Pi image builds currently require a Linux x86_64 host.' \
		'The pinned Bootlin cross-toolchain is distributed for Linux x86_64.' \
		'Run this script in a Linux x86_64 VM or CI runner.' >&2
	exit 2
fi

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
buildroot_version=${BUILDROOT_VERSION:-2026.05}
defconfig=${1:-dashboard_pi_rpi4_64_defconfig}
cache_root=${DASHBOARD_PI_CACHE:-"$HOME/.cache/dashboard-pi"}
buildroot_dir=${BUILDROOT_DIR:-"$cache_root/buildroot-$buildroot_version"}
output_base=${DASHBOARD_PI_OUTPUT_BASE:-"$cache_root/output"}
external_link="$cache_root/br2_external_dashboard_pi"
export BR2_CCACHE_DIR=${BR2_CCACHE_DIR:-"$cache_root/ccache"}

mkdir -p "$cache_root" "$output_base" "$BR2_CCACHE_DIR"

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
make -C "$output_dir" graph-size
python3 "$repo_root/scripts/artifact-metrics.py" \
	--output-dir "$output_dir" \
	--git-commit "$(git -C "$repo_root" rev-parse HEAD)" \
	--buildroot-version "$buildroot_version"

printf '\nBuild output: %s\n' "$output_dir"
printf 'Image: %s/images/sdcard.img\n' "$output_dir"
printf 'Metrics: %s/images/artifact-metrics.json\n' "$output_dir"
