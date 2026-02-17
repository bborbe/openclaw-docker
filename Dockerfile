# OpenClaw from npm (no base image needed)
FROM node:22-slim

ARG VERSION
ARG TARGETARCH

USER root

# Install system tools
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

# Install Helm
RUN curl -fsSL https://get.helm.sh/helm-v3.20.0-linux-${TARGETARCH}.tar.gz \
    | tar xz -C /usr/local/bin --strip-components=1 linux-${TARGETARCH}/helm

# Install Golang
RUN curl -fsSL https://go.dev/dl/go1.26.0.linux-${TARGETARCH}.tar.gz -o /tmp/go.tar.gz \
    && tar -C /opt -xzf /tmp/go.tar.gz \
    && rm /tmp/go.tar.gz
ENV PATH="/opt/go/bin:${PATH}"

# Install OpenClaw & Claude Code from npm (no build needed!)
RUN npm install -g openclaw@${VERSION} @anthropic-ai/claude-code

# Matrix support (bot SDK + E2EE crypto)
RUN npm install -g @vector-im/matrix-bot-sdk @matrix-org/matrix-sdk-crypto-nodejs

ENV NODE_ENV=production

# Create openclaw user
RUN useradd --create-home --shell /bin/bash openclaw && \
    mkdir -p /opt/gnupg && chown openclaw:openclaw /opt/gnupg && chmod 700 /opt/gnupg

ENV GNUPGHOME=/opt/gnupg
COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENV OPENCLAW_STATE_DIR=/home/openclaw/.openclaw
ENV HOME=/home/openclaw

USER openclaw
ENTRYPOINT ["/entrypoint.sh"]
CMD ["openclaw", "gateway", "--allow-unconfigured", "--bind", "lan"]
