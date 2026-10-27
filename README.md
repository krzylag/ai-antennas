# Isolated OpenCode for antenna work

This project runs OpenCode, `xnec2c`/`nec2c`, and optional local DeepSeek GGUF models inside an Ubuntu 24.04 container. Its writable host directories are `./workspace`, the model cache in `./models`, and persistent OpenCode data in `./sessions`. The image has no Docker socket, broad host filesystem mount, extra Linux capabilities, or privilege escalation path.

## Start

1. Copy `.env.example` to `.env` and fill at least `GEMINI_API_KEY`. The `LOCAL_<MODEL>_FILE`, `LOCAL_<MODEL>_URL`, and `LOCAL_<MODEL>_ALIAS` groups define each local model; modify those values in `.env` to use a different GGUF source or filename.
2. Pull the published image and open the TUI:

```bash
docker compose pull
docker compose run --rm opencode
```

Use `/models` in OpenCode to select a configured provider. The default is `google/gemini-3.8-flash`.

On Windows 11, run these commands in a WSL2 shell with Docker Desktop's WSL integration and the NVIDIA Container Toolkit support enabled. Docker Desktop must be able to run `docker run --gpus all nvidia/cuda:12.8.1-runtime-ubuntu24.04 nvidia-smi`.

## Building and publishing the image

Compose uses `ciemnyzenek/ai-antennas-opencode:latest` from Docker Hub and always checks for the latest image when starting the service. To build the image locally, use GNU Make from a WSL2 shell or another environment with Make and Docker installed:

```bash
make build
```

By default, this builds `ciemnyzenek/ai-antennas-opencode:latest`. You can build a versioned tag and optionally tag that image as `latest`:

```bash
make build TAG=1.0.0
make tag SOURCE_TAG=1.0.0 TAG=latest
```

Push a tag after building it. Docker Hub authentication is intentionally not handled by the Makefile; log in separately with `docker login` before pushing:

```bash
docker login
make push TAG=1.0.0
make push TAG=latest
```

The Makefile accepts `IMAGE`, `TAG`, `SOURCE_TAG`, `LOCAL_UID`, and `LOCAL_GID` overrides. For example, set `LOCAL_UID` and `LOCAL_GID` to your Linux user and group IDs when building on Linux.

## API keys and free tiers

`GEMINI_API_KEY` is required for the default Gemini model. Create it without charge in [Google AI Studio](https://aistudio.google.com/app/apikey). Gemini API free-tier quotas and availability depend on country and Google account; check the current limits in AI Studio.

`OPENROUTER_API_KEY` is optional. Create an account and key at [OpenRouter](https://openrouter.ai/keys). The configuration exposes `openrouter-free/deepseek-r1-free`, currently mapped to `deepseek/deepseek-r1:free`. Free routes are capacity-limited and OpenRouter can change their model IDs or availability; select it with `/models` only when present in their catalog.

`DEEPSEEK_API_KEY` is included for future direct use but is not configured as a free fallback: DeepSeek's direct API is generally paid. Do not put secrets in `opencode.json`; it is intentionally read-only in the container and refers to environment variables only.

## Local DeepSeek fallback

The local models are not bundled in the image. Download one only when needed; files persist in the ignored `./models` directory:

```bash
./scripts/download-model.sh coder
./scripts/download-model.sh r1
./scripts/download-model.sh qwen-coder
```

Start OpenCode against a downloaded model by setting `LOCAL_MODEL` for one invocation:

```bash
LOCAL_MODEL=coder docker compose run --rm opencode
LOCAL_MODEL=r1 docker compose run --rm opencode
LOCAL_MODEL=qwen-coder docker compose run --rm opencode
```

Then choose `local-deepseek/coder`, `local-deepseek/r1`, or `local-deepseek/qwen-coder` in `/models`. `qwen-coder` is the recommended local model for agent work: Qwen2.5-Coder-7B-Instruct supports tool/function calling and is configured accordingly. Its Q4_K_M GGUF is 4.68 GB; the supplied `8192` context leaves VRAM for the KV cache on an 8 GB RTX 5060 Laptop GPU. The container starts `llama-server` on its private loopback interface with CUDA offload. No model port is published to the host. Reduce `LOCAL_CONTEXT_SIZE` if VRAM is exhausted.

## Antenna simulations

Write NEC input files and outputs under `workspace/`. `xnec2c` and `nec2c` are installed in the image. For unattended calculations, ask OpenCode to invoke `nec2c` from `/workspace`; `workspace/AGENTS.md` explains the expected output location and long-running simulation policy.

## Configuration and isolation

Edit `opencode.json` from this project to change models, capabilities, or limits. It is mounted read-only as `/config/opencode.json`; OpenCode receives full tool permissions *inside* its container but cannot change that configuration at runtime. Quit and restart OpenCode after every configuration change, since it reads configuration at startup.

The `workspace/`, `models/`, `.env`, and `sessions/` paths intentionally survive rebuilds. `workspace/`, `models/`, and `sessions/` are ignored by Git. The container retains network access for cloud providers and on-demand downloads. Network access is required for those features and is not a host filesystem escape boundary.

### Persistent session history

The local `./sessions` directory is mounted at `/home/opencode/.local/share/opencode`. It stores all persistent OpenCode data, including session history, configuration, and state. Keep the existing XDG paths: data is stored under `sessions/data/opencode`, configuration under `sessions/config/opencode`, and state under `sessions/state/opencode`. Rebuilding the image, removing a container, or running `docker compose down --volumes` does not delete this host directory. To back it up, exit all OpenCode instances first, then copy the entire `sessions/` directory. It may contain credentials and conversation content; do not commit it.

If upgrading from the previous named volume, exit all OpenCode instances before copying the old data into an empty `sessions/` directory. In the WSL2 shell:

```bash
mkdir -p sessions
docker volume ls --filter label=com.docker.compose.volume=opencode-state
docker run --rm --network none --entrypoint bash \
  -v ai-antennas_opencode-state:/old-state:ro \
  -v "$(pwd)/sessions:/sessions" \
  ciemnyzenek/ai-antennas-opencode:latest -c 'cp -R /old-state/. /sessions/'
```

Replace `ai-antennas_opencode-state` with the existing volume name from the listing if your Compose project has a different name. Retain the old volume until you have confirmed that OpenCode can list and resume historical sessions from `sessions/`.
