# OpenClaw Docker

Docker image and compose runtime for [OpenClaw](https://openclaw.ai).

## TL;DR

```bash
# 1) run in foreground (build + start via compose)
make run

# 2) stop when done (or Ctrl+C then stop)
make stop

# 3) for background mode instead
make start
```

OpenClaw UI: http://localhost:18789

---

## Why docker compose

`make run` uses `docker compose up --build` (foreground).
`make start` uses `docker compose up -d --build` (background) with `restart: unless-stopped`.

So LocalClaw comes back automatically after:
- process crashes
- Docker daemon restart
- host reboot

---

## Commands

```bash
# Build image (local arch)
make build

# Build multi-arch (amd64 + arm64) and push
make build-multiarch

# Start background service via compose (build + start)
make start

# Restart service
make restart

# Stop service
make stop

# View logs
make logs

# Open shell in running container
make exec

# Run onboarding (interactive, one-shot)
make onboard

# Run service in foreground via compose (build + start)
make run

# Push image to registry
make upload

# Remove local images
make clean
```

---

## Runtime details

- Container name: `localclaw`
- Port mapping: `18789:18789`
- State mount: `~/.openclaw/localclaw:/home/openclaw`
- Compose file: `docker-compose.yml`
- Restart policy: `unless-stopped`

---

## What's in the image

- OpenClaw (npm, version-pinned)
- Claude Code CLI
- Matrix bot SDK + E2EE crypto libs
- GitHub CLI (`gh`)
- Helm, kubectl, Go, Trivy
- network/debug tools

---

## Setup Codex

```bash
openclaw onboard --auth-choice openai-codex
openclaw models set openai-codex/gpt-5.3-codex
openclaw models status --plain
```
