# OpenClaw Docker

Docker image for [OpenClaw](https://openclaw.ai) with additional tools.

## Features

- **OpenClaw** (from npm, version-pinned)
- **Claude Code** CLI
- **Matrix** bot SDK + E2EE crypto
- **GitHub CLI** (gh)
- **Helm** v3.20.0
- **Go** 1.26.0
- **Trivy** security scanner
- **Networking tools** (telnet, ping)

## Quick Start

```bash
docker run -it --rm \
  -p 18901:18789 \
  -v ~/.openclaw:/home/openclaw \
  docker.io/bborbe/openclaw:2026.2.15
```

Access: http://localhost:18901

## Available Commands

```bash
# Build image
make build

# Run (foreground)
make run

# Start (background)
make start

# Stop background container
make stop

# View logs
make logs

# Run onboarding
make onboard

# Push to DockerHub
make upload

# Clean local images
make clean
```

## Version

Current OpenClaw version: **2026.2.15**

To update, edit `VERSION` in Makefile and rebuild.

## Architecture

- Base: `node:22-slim` (required by OpenClaw >=22.12.0)
- User: `openclaw` (non-root)
- Port: 18789 (exposed as 18901)
- State: `/home/openclaw/.openclaw`

## License

MIT
