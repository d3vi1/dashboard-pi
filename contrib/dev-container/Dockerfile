# SPDX-License-Identifier: GPL-2.0-only

ARG UBUNTU_IMAGE=ubuntu:24.04@sha256:561618e2c15bf2397621dd04f96926663a3b5616c189cf7e38db7e82f5c538ea
FROM ${UBUNTU_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
ARG BUILDER_UID=1000
ARG BUILDER_GID=1000

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		bash \
		bc \
		binutils \
		bison \
		build-essential \
		bzip2 \
		ca-certificates \
		ccache \
		cmake \
		cpio \
		curl \
		file \
		flex \
		gawk \
		git \
		gzip \
		jq \
		libncurses-dev \
		libssl-dev \
		locales \
		meson \
		ninja-build \
		openssh-client \
		patch \
		perl \
		pkg-config \
		python3 \
		python3-dev \
		python3-matplotlib \
		python3-setuptools \
		python3-venv \
		rsync \
		ripgrep \
		sed \
		tar \
		unzip \
		wget \
		xz-utils \
	&& locale-gen C.UTF-8 \
	&& rm -rf /var/lib/apt/lists/* \
	&& existing_group="$(getent group "${BUILDER_GID}" | cut -d: -f1 || true)" \
	&& if [ -n "${existing_group}" ]; then \
		groupmod --new-name builder "${existing_group}"; \
	else \
		groupadd --gid "${BUILDER_GID}" builder; \
	fi \
	&& existing_user="$(getent passwd "${BUILDER_UID}" | cut -d: -f1 || true)" \
	&& if [ -n "${existing_user}" ]; then \
		usermod --login builder --home /home/builder --move-home \
			--shell /bin/bash "${existing_user}"; \
	else \
		useradd --uid "${BUILDER_UID}" --gid "${BUILDER_GID}" \
			--create-home --shell /bin/bash builder; \
	fi

RUN usermod --groups builder builder

ENV LANG=C.UTF-8 \
	LC_ALL=C.UTF-8 \
	HOME=/home/builder \
	DASHBOARD_PI_CACHE=/cache/dashboard-pi \
	CCACHE_DIR=/cache/ccache

WORKDIR /workspace/dashboard-pi
USER builder

CMD ["sleep", "infinity"]
