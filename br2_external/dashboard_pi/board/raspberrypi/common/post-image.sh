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

overlay_list="$board_dir/boot-overlays.list"
if [ -f "$overlay_list" ]; then
	firmware_source=
	for path in "${BUILD_DIR}"/rpi-firmware-*; do
		if [ -d "$path/boot/overlays" ]; then
			firmware_source=$path
			break
		fi
	done
	if [ -z "$firmware_source" ]; then
		echo "Raspberry Pi firmware overlay source not found" >&2
		exit 1
	fi

	overlay_dir="${BINARIES_DIR}/rpi-firmware/overlays"
	rm -rf "$overlay_dir"
	mkdir -p "$overlay_dir"
	while IFS= read -r line; do
		overlay=$(printf '%s' "$line" | sed 's/#.*//;s/[[:space:]]//g')
		[ -n "$overlay" ] || continue
		source="$firmware_source/boot/overlays/$overlay.dtbo"
		if [ ! -f "$source" ]; then
			echo "Whitelisted overlay not found: $overlay.dtbo" >&2
			exit 1
		fi
		cp "$source" "$overlay_dir/"
	done < "$overlay_list"
fi

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
boot_payload_kib=0
while IFS= read -r file; do
	[ -n "$file" ] || continue
	file_kib=$(du -sk "${BINARIES_DIR}/$file" | awk '{print $1}')
	boot_payload_kib=$((boot_payload_kib + file_kib))
done <<EOF
$(printf '%s' "$files" | sed '/^$/d')
EOF

# Reserve 15 percent for FAT metadata, directory entries and image evolution,
# then round to a whole MiB. A 16 MiB floor keeps tiny board images practical.
boot_size_kib=$(((boot_payload_kib * 115 + 99) / 100))
boot_size_mib=$(((boot_size_kib + 1023) / 1024))
[ "$boot_size_mib" -ge 16 ] || boot_size_mib=16

while IFS= read -r line; do
	case "$line" in
	*'#BOOT_FILES#'*) printf '%s\n' "$boot_files" ;;
	*'#BOOT_SIZE#'*) printf '\tsize = %sM\n' "$boot_size_mib" ;;
	*) printf '%s\n' "$line" ;;
	esac
done < "$board_dir/../common/genimage-boot-only.cfg.in" > "$genimage_cfg"

rm -rf "$genimage_tmp"
genimage \
	--rootpath "$rootpath_tmp" \
	--tmppath "$genimage_tmp" \
	--inputpath "$BINARIES_DIR" \
	--outputpath "$BINARIES_DIR" \
	--config "$genimage_cfg"

while IFS= read -r overlay; do
	[ -n "$overlay" ] || continue
	if ! mdir -i "${BINARIES_DIR}/boot.vfat" "::/overlays/$overlay.dtbo" >/dev/null 2>&1; then
		echo "config.txt references missing boot overlay: $overlay.dtbo" >&2
		exit 1
	fi
done <<EOF
$(sed -n 's/^[[:space:]]*dtoverlay=\([^,#]*\).*$/\1/p' "$config")
EOF
