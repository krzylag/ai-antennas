#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || ( "$1" != "coder" && "$1" != "r1" && "$1" != "qwen-coder" ) ]]; then
  printf 'Usage: %s {coder|r1|qwen-coder}\n' "$0" >&2
  exit 2
fi

case "$1" in
  coder) model_prefix="LOCAL_CODER" ;;
  r1) model_prefix="LOCAL_R1" ;;
  qwen-coder) model_prefix="LOCAL_QWEN_CODER" ;;
esac

file_var="${model_prefix}_FILE"
url_var="${model_prefix}_URL"
filename="${!file_var:-}"
url="${!url_var:-}"
if [[ -z "$filename" || -z "$url" ]]; then
  printf 'Set %s_FILE and %s_URL in .env.\n' "$model_prefix" "$model_prefix" >&2
  exit 2
fi

destination="/models/${filename}"
if [[ -f "$destination" ]]; then
  printf 'Already downloaded: %s\n' "$destination"
  exit 0
fi

printf 'Downloading %s to %s\n' "$filename" "$destination"
curl --fail --location --continue-at - --output "$destination" "$url"
