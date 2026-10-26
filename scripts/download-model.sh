#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || ( "$1" != "coder" && "$1" != "r1" && "$1" != "qwen-coder" ) ]]; then
  printf 'Usage: %s {coder|r1|qwen-coder}\n' "$0" >&2
  exit 2
fi

docker compose run --rm --no-deps --entrypoint /usr/local/bin/download-local-model opencode "$1"
