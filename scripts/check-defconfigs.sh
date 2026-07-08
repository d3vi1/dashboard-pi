#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
buildroot_version=${BUILDROOT_VERSION:-2026.05}
cache_root=${DASHBOARD_PI_CACHE:-"$HOME/.cache/dashboard-pi"}
buildroot_dir=${BUILDROOT_DIR:-"$cache_root/buildroot-$buildroot_version"}
external_link="$cache_root/br2_external_dashboard_pi"
check_output="$cache_root/check"

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
for cfg in "$repo_root"/br2_external/dashboard_pi/configs/*_defconfig; do
	name=$(basename "$cfg")
	out="$check_output/${name%.defconfig}"
	rm -rf "$out"
	if ! make -C "$buildroot_dir" BR2_EXTERNAL="$external_link" O="$out" "$name"; then
		printf 'FAILED: %s\n' "$name" >&2
		status=1
	fi
done

exit "$status"
