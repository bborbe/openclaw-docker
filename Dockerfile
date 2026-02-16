# Custom OpenClaw Docker image with gh + helm
# Place this in the openclaw repo root, then:
# docker build -t openclaw:custom -f Dockerfile.custom .

FROM openclaw:base

USER root

# Install gh (GitHub CLI) from default repos
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt/lists \
    apt-get update && apt-get install -y --no-install-recommends \
    gh \
    git \
    curl \
    ca-certificates \
    gnupg \
    wget \
    apt-transport-https \
    lsb-release \
    telnet \
    iputils-ping

# Install Trivy
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt/lists \
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor -o /usr/share/keyrings/trivy.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" > /etc/apt/sources.list.d/trivy.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends trivy

# Install Helm (binary - simpler than apt repo)
RUN curl -fsSL https://get.helm.sh/helm-v3.20.0-linux-arm64.tar.gz \
    | tar xz -C /usr/local/bin --strip-components=1 linux-arm64/helm

# Install Golang
RUN curl -fsSL https://go.dev/dl/go1.26.0.linux-arm64.tar.gz -o /tmp/go.tar.gz \
    && tar -C /opt -xzf /tmp/go.tar.gz \
    && rm /tmp/go.tar.gz
ENV PATH="/opt/go/bin:${PATH}"

# Install Bun (required for OpenClaw build scripts)
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

RUN corepack enable

WORKDIR /app

# pnpm install — cache the store
RUN --mount=type=cache,target=/root/.local/share/pnpm/store \
    pnpm install --frozen-lockfile

# Matrix E2EE crypto support (native Rust bindings)
RUN pnpm add -w @matrix-org/matrix-sdk-crypto-nodejs && \
    pnpm rebuild @matrix-org/matrix-sdk-crypto-nodejs

# Build OpenClaw
RUN pnpm build
RUN pnpm ui:install
RUN pnpm ui:build

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code

ENV NODE_ENV=production

# Create openclaw user, pre-create GPG dir
RUN useradd --create-home --shell /bin/bash openclaw && \
    mkdir -p /opt/gnupg && chown openclaw:openclaw /opt/gnupg && chmod 700 /opt/gnupg && \
    chown -R openclaw:openclaw /app

# GPG: copy keys from read-only mount at startup
ENV GNUPGHOME=/opt/gnupg
COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENV OPENCLAW_STATE_DIR=/home/openclaw/.openclaw
ENV HOME=/home/openclaw

USER openclaw
ENTRYPOINT ["/entrypoint.sh"]
CMD ["node", "/app/openclaw.mjs", "gateway", "--allow-unconfigured", "--bind", "lan"]
