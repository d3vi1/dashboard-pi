#!/bin/sh
set -eu

exec "$(dirname "$0")/../common/post-image.sh" "$(dirname "$0")"
