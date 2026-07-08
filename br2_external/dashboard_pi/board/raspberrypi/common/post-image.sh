#!/bin/sh
set -eu

board_dir=${1:?board directory argument required}
genimage_cfg="${BINARIES_DIR}/genimage-dashboard-pi.cfg"
genimage_tmp="${BUILD_DIR}/genimage.tmp"
rootpath_tmp=$(mktemp -d)

cleanup() {
	rm -rf "$rootpath_tmp"
}
trap cleanup EXIT

files=
for path in "${BINARIES_DIR}"/*.dtb "${BINARIES_DIR}"/rpi-firmware/*; do
	[ -e "$path" ] || continue
	file=${path#"${BINARIES_DIR}/"}
	files="${files}${file}
"
done

config="${BINARIES_DIR}/rpi-firmware/config.txt"
kernel=$(sed -n 's/^kernel=//p' "$config" | sed -n '1p')
[ -n "$kernel" ] || kernel=Image
files="${files}${kernel}
"

boot_files=$(printf '%s' "$files" | sed '/^$/d;s/.*/\t\t\t"&",/')
sed "s|#BOOT_FILES#|${boot_files}|" \
	"$board_dir/../common/genimage-boot-only.cfg.in" > "$genimage_cfg"

rm -rf "$genimage_tmp"
genimage \
	--rootpath "$rootpath_tmp" \
	--tmppath "$genimage_tmp" \
	--inputpath "$BINARIES_DIR" \
	--outputpath "$BINARIES_DIR" \
	--config "$genimage_cfg"
