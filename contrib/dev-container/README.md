# Dashboard Pi development container

This container provides the Linux x86_64 build host required by the currently
pinned Bootlin cross-toolchains. It contains build tools only; it does not run
the Dashboard Pi target image and does not require privileged mode, host
networking, published ports or access to the Docker socket.

The default Ubuntu 24.04 image is pinned by digest. Update that digest
deliberately in both `Dockerfile` and `compose.yaml` when refreshing the build
environment.

The Compose project keeps source and Buildroot downloads/output outside the
container so rebuilding the image does not discard them:

- `workspace/dashboard-pi`: repository checkout;
- `cache/dashboard-pi`: Buildroot source and per-target output;
- `cache/ccache`: optional compiler cache.

## Start

```sh
mkdir -p workspace cache/dashboard-pi cache/ccache
git clone https://github.com/d3vi1/dashboard-pi.git workspace/dashboard-pi
docker compose up --build -d
docker compose exec dev ./scripts/check-defconfigs.sh
```

If the host has Docker but not Git, clone through the image before starting the
long-running service:

```sh
docker compose build
docker compose run --rm --workdir /workspace dev \
	git clone https://github.com/d3vi1/dashboard-pi.git /workspace/dashboard-pi
docker compose up -d
```

Build the primary image with:

```sh
docker compose exec dev ./scripts/build.sh dashboard_pi_rpi4_64_defconfig
```

The resulting image is stored at:

```text
cache/dashboard-pi/output/dashboard_pi_rpi4_64_defconfig/images/sdcard.img
```

Use `docker compose exec dev bash` for an interactive shell. Stop the container
with `docker compose stop`; do not use `docker compose down -v` when preserving
development state matters.
