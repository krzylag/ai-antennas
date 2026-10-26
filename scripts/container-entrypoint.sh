#!/usr/bin/env bash
set -euo pipefail

model_path=""
model_prefix=""
case "${LOCAL_MODEL:-}" in
  "") ;;
  coder) model_prefix="LOCAL_CODER" ;;
  r1) model_prefix="LOCAL_R1" ;;
  qwen-coder) model_prefix="LOCAL_QWEN_CODER" ;;
  *)
    printf 'Unknown LOCAL_MODEL: %s (use coder, r1, or qwen-coder)\n' "$LOCAL_MODEL" >&2
    exit 2
    ;;
esac

if [[ -n "$model_prefix" ]]; then
  file_var="${model_prefix}_FILE"
  alias_var="${model_prefix}_ALIAS"
  model_file="${!file_var:-}"
  model_alias="${!alias_var:-}"
  if [[ -z "$model_file" || -z "$model_alias" ]]; then
    printf 'Set %s_FILE and %s_ALIAS in .env.\n' "$model_prefix" "$model_prefix" >&2
    exit 2
  fi

  model_path="/models/${model_file}"
  if [[ ! -f "$model_path" ]]; then
    printf 'Local model is missing: %s\nRun ./scripts/download-model.sh %s first.\n' "$model_path" "$LOCAL_MODEL" >&2
    exit 1
  fi

  llama-server \
    --model "$model_path" \
    --alias "$model_alias" \
    --host 127.0.0.1 \
    --port 8080 \
    --ctx-size "${LOCAL_CONTEXT_SIZE:-8192}" \
    --n-gpu-layers "${LOCAL_GPU_LAYERS:-999}" \
    --jinja \
    --parallel 1 \
    > /tmp/llama-server.log 2>&1 &
fi

exec "$@"
