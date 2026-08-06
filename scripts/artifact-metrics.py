#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-only

"""Generate deterministic size and dependency metrics for a Buildroot image."""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import os
from pathlib import Path
import re
import stat
import subprocess
from typing import Any


def run(command: list[str]) -> str:
    environment = os.environ.copy()
    environment["LC_ALL"] = "C"
    return subprocess.check_output(command, text=True, env=environment)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def read_kernel_config(path: Path) -> tuple[dict[str, str], int]:
    settings: dict[str, str] = {}
    enabled = 0
    for line in path.read_text().splitlines():
        if line.startswith("CONFIG_") and "=" in line:
            name, value = line.split("=", 1)
            settings[name] = value
            if value == "y":
                enabled += 1
    return settings, enabled


def selected_kernel_settings(settings: dict[str, str]) -> dict[str, str]:
    prefixes = ("CONFIG_INITRAMFS_COMPRESSION_", "CONFIG_KERNEL_", "CONFIG_RD_")
    return {
        key: value
        for key, value in sorted(settings.items())
        if key.startswith(prefixes)
    }


def regular_target_files(target: Path) -> list[tuple[int, Path]]:
    files: list[tuple[int, Path]] = []
    for path in target.rglob("*"):
        try:
            metadata = path.lstat()
        except FileNotFoundError:
            continue
        if stat.S_ISREG(metadata.st_mode):
            files.append((metadata.st_size, path))
    return sorted(files, key=lambda item: (-item[0], str(item[1])))


def relative_file_entry(target: Path, item: tuple[int, Path]) -> dict[str, Any]:
    size, path = item
    return {"path": "/" + str(path.relative_to(target)), "bytes": size}


def parse_size(size_tool: Path, path: Path) -> dict[str, int] | None:
    try:
        lines = run([str(size_tool), "-B", str(path)]).splitlines()
        fields = lines[-1].split()
        return {
            "text": int(fields[0]),
            "data": int(fields[1]),
            "bss": int(fields[2]),
            "total": int(fields[3]),
        }
    except (subprocess.CalledProcessError, IndexError, ValueError):
        return None


def elf_entries(target: Path, files: list[tuple[int, Path]], size_tool: Path) -> list[dict[str, Any]]:
    entries: list[dict[str, Any]] = []
    for file_size, path in files:
        try:
            with path.open("rb") as source:
                if source.read(4) != b"\x7fELF":
                    continue
        except OSError:
            continue
        sections = parse_size(size_tool, path)
        entry: dict[str, Any] = {
            "path": "/" + str(path.relative_to(target)),
            "file_bytes": file_size,
        }
        if sections:
            entry.update(sections)
        entries.append(entry)
    return entries[:50]


def needed_libraries(readelf: Path, path: Path) -> list[str]:
    try:
        output = run([str(readelf), "-d", str(path)])
    except subprocess.CalledProcessError:
        return []
    return re.findall(r"\(NEEDED\).*?\[(.+?)\]", output)


def dependency_tree(target: Path, readelf: Path, root: Path) -> dict[str, Any]:
    libraries: dict[str, Path] = {}
    for directory in (target / "lib", target / "usr/lib"):
        if directory.exists():
            for path in directory.rglob("*"):
                if path.is_file():
                    libraries.setdefault(path.name, path)

    queue = [root]
    visited: set[Path] = set()
    nodes: list[dict[str, Any]] = []
    missing: set[str] = set()
    while queue:
        path = queue.pop(0)
        if path in visited:
            continue
        visited.add(path)
        needed = needed_libraries(readelf, path)
        nodes.append({
            "path": "/" + str(path.relative_to(target)),
            "needed": needed,
        })
        for name in needed:
            dependency = libraries.get(name)
            if dependency is None:
                missing.add(name)
            elif dependency not in visited:
                queue.append(dependency)
    return {"nodes": nodes, "unresolved": sorted(missing)}


def read_package_sizes(path: Path) -> list[dict[str, Any]]:
    if not path.exists():
        return []
    entries: list[dict[str, Any]] = []
    with path.open(newline="") as source:
        for row in csv.DictReader(source):
            entries.append({
                "package": row["Package name"],
                "bytes": int(row["Package size"]),
                "system_percent": float(row["Package size in system (%)"]),
            })
    return sorted(entries, key=lambda item: (-item["bytes"], item["package"]))


def boot_metrics(mdir: Path, image: Path) -> dict[str, Any]:
    listing = run([str(mdir), "-i", str(image), "-/", "-b", "::"])
    summary = run([str(mdir), "-i", str(image), "::"])
    match = re.search(r"([0-9 ]+) bytes free", summary)
    if not match:
        raise RuntimeError("could not parse free bytes from mdir output")
    free_bytes = int(match.group(1).replace(" ", ""))
    allocated_bytes = image.stat().st_size
    return {
        "allocated_bytes": allocated_bytes,
        "free_bytes": free_bytes,
        "occupied_bytes": allocated_bytes - free_bytes,
        "files": [line.removeprefix("::") for line in listing.splitlines() if line],
    }


def find_tool(host: Path, suffix: str) -> Path:
    matches = sorted((host / "bin").glob(f"*-{suffix}"))
    if not matches:
        raise FileNotFoundError(f"no cross {suffix} tool found under {host / 'bin'}")
    return matches[0]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", required=True, type=Path)
    parser.add_argument("--git-commit", required=True)
    parser.add_argument("--buildroot-version", required=True)
    parser.add_argument("--output", type=Path)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    output_dir = args.output_dir.resolve()
    images = output_dir / "images"
    target = output_dir / "target"
    host = output_dir / "host"
    kernel_build = output_dir / "build/linux-custom"
    kernel_config_path = kernel_build / ".config"
    buildroot_config_path = output_dir / ".config"

    kernel_settings, enabled_count = read_kernel_config(kernel_config_path)
    buildroot_config = buildroot_config_path.read_text()
    linux_match = re.search(r"linux,([0-9a-f]{40})", buildroot_config)
    wpe_builds = sorted((output_dir / "build").glob("dashboard-pi-wpewebkit-*"))
    wpe_version = wpe_builds[-1].name.removeprefix("dashboard-pi-wpewebkit-") if wpe_builds else "unknown"

    size_tool = find_tool(host, "size")
    readelf = find_tool(host, "readelf")
    mdir = host / "bin/mdir"
    target_files = regular_target_files(target)
    vmlinux_sections = parse_size(size_tool, kernel_build / "vmlinux")

    dependency_roots: dict[str, Path] = {}
    requested_names = {
        "dashboard-pi-launcher",
        "WebKitWebProcess",
        "WebKitNetworkProcess",
        "WebKitGPUProcess",
        "NetworkProcess",
        "GPUProcess",
        "WPEWebProcess",
        "WPENetworkProcess",
        "WPEGPUProcess",
    }
    for _, path in target_files:
        if path.name in requested_names:
            dependency_roots["/" + str(path.relative_to(target))] = path

    image_names = ("Image", "rootfs.cpio", "boot.vfat", "sdcard.img")
    image_metrics = {
        name: {"bytes": (images / name).stat().st_size, "sha256": sha256(images / name)}
        for name in image_names
        if (images / name).exists()
    }
    initramfs_algorithms = sorted(
        key.removeprefix("CONFIG_INITRAMFS_COMPRESSION_").lower()
        for key, value in kernel_settings.items()
        if key.startswith("CONFIG_INITRAMFS_COMPRESSION_") and value == "y"
    )

    report = {
        "schema_version": 1,
        "git_commit": args.git_commit,
        "buildroot_version": args.buildroot_version,
        "linux_commit": linux_match.group(1) if linux_match else "unknown",
        "wpe_webkit_version": wpe_version,
        "images": image_metrics,
        "rootfs_cpio_encoding": "uncompressed-svr4-cpio",
        "embedded_initramfs_compression": initramfs_algorithms,
        "boot_fat": boot_metrics(mdir, images / "boot.vfat"),
        "vmlinux_sections": vmlinux_sections,
        "kernel_config_y_count": enabled_count,
        "kernel_module_file_count": len(list(target.rglob("*.ko"))),
        "kernel_selected_settings": selected_kernel_settings(kernel_settings),
        "largest_target_files": [relative_file_entry(target, item) for item in target_files[:50]],
        "largest_elf_files": elf_entries(target, target_files, size_tool),
        "package_sizes": read_package_sizes(output_dir / "graphs/package-size-stats.csv"),
        "dependency_trees": {
            name: dependency_tree(target, readelf, path)
            for name, path in sorted(dependency_roots.items())
        },
        "runtime_observation": {
            "dlopen_libraries": [],
            "gstreamer_plugins": [],
            "status": "requires execution on Raspberry Pi 4 hardware",
        },
    }

    destination = args.output or images / "artifact-metrics.json"
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")


if __name__ == "__main__":
    main()
