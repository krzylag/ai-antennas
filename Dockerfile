FROM nvidia/cuda:12.8.1-devel-ubuntu24.04 AS llama-builder

ARG LLAMA_CPP_VERSION=v0.7.0

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        cmake \
        curl \
        git \
        g++ \
        make \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch ${LLAMA_CPP_VERSION} https://github.com/ggml-org/llama.cpp.git /src/llama.cpp \
    && cmake -S /src/llama.cpp -B /src/llama.cpp/build \
        -DGGML_CUDA=ON \
        -DGGML_NATIVE=OFF \
        -DLLAMA_CURL=OFF \
        -DCMAKE_EXE_LINKER_FLAGS=-Wl,--allow-shlib-undefined \
    && cmake --build /src/llama.cpp/build --target llama-server -j"$(nproc)"

FROM nvidia/cuda:12.8.1-runtime-ubuntu24.04

# Leave empty to install the latest stable OpenCode release. Set a concrete
# version at build time for a reproducible image.
ARG OPENCODE_VERSION=
ARG USER_ID=1000
ARG GROUP_ID=1000

ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/home/opencode \
    XDG_CONFIG_HOME=/home/opencode/.config \
    XDG_DATA_HOME=/home/opencode/.local/share \
    XDG_CACHE_HOME=/home/opencode/.cache \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        admesh \
        ca-certificates \
        curl \
        file \
        fonts-dejavu-core \
        git \
        gnuplot-nox \
        imagemagick \
        jq \
        less \
        librsvg2-bin \
        nano \
        nec2c \
        openscad \
        prusa-slicer \
        python3 \
        python3-matplotlib \
        python3-numpy \
        python3-pil \
        python3-pip \
        python3-venv \
        procps \
        ripgrep \
        sudo \
        tini \
        xvfb \
        xnec2c \
    && rm -rf /var/lib/apt/lists/* \
    && (groupadd --gid "${GROUP_ID}" opencode || true) \
    && useradd --non-unique --uid "${USER_ID}" --gid "${GROUP_ID}" --create-home --shell /bin/bash opencode \
    && printf '%s\n' 'opencode ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/opencode \
    && chmod 0440 /etc/sudoers.d/opencode \
    && visudo -cf /etc/sudoers.d/opencode

RUN python3 -m venv /opt/cad \
    && /opt/cad/bin/pip install --no-cache-dir numpy trimesh manifold3d

RUN export HOME=/root \
    && if [ -n "${OPENCODE_VERSION}" ]; then \
      curl -fsSL https://opencode.ai/v2/install | bash -s -- --version "${OPENCODE_VERSION}" --no-modify-path; \
    else \
      curl -fsSL https://opencode.ai/v2/install | bash -s -- --no-modify-path; \
    fi \
    && install -m 0755 /root/.opencode/bin/opencode /usr/local/bin/opencode

COPY --from=llama-builder /src/llama.cpp/build/bin/llama-server /usr/local/bin/llama-server
COPY --from=llama-builder /src/llama.cpp/build/bin/*.so* /usr/local/lib/
COPY scripts/container-entrypoint.sh /usr/local/bin/container-entrypoint
COPY scripts/download-local-model.sh /usr/local/bin/download-local-model

RUN ldconfig \
    && chmod 0755 /usr/local/bin/container-entrypoint /usr/local/bin/download-local-model \
    && mkdir -p /models /workspace /home/opencode/.config/opencode /home/opencode/.local/share/opencode \
    && chown -R "${USER_ID}:${GROUP_ID}" /models /workspace /home/opencode

USER opencode
WORKDIR /workspace

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/container-entrypoint"]
CMD ["opencode"]
