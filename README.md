# OpenClaw Docker

Docker image and compose runtime for [OpenClaw](https://openclaw.ai).

## Quick Start

```bash
# 1) Build the image
make build

# 2) Run onboarding (interactive, creates config in ~/.openclaw/localclaw)
make onboard

# 3) Disable Control UI (required — OpenClaw crashes without this in a fresh container)
#    Edit ~/.openclaw/localclaw/.openclaw/openclaw.json and add to the "gateway" section:
```

```json
"controlUi": {
  "allowedOrigins": [
    "http://localhost:18789",
    "http://127.0.0.1:18789"
  ],
  "enabled": false
},
```

```bash
# 4) Run in foreground (rebuilds image + starts via compose)
make run

# 5) Stop when done (or Ctrl+C then stop)
make stop
```

Note: The controlUi workaround above disables the web UI. To use the UI later, set `"enabled": true` in `~/.openclaw/localclaw/.openclaw/openclaw.json` and restart.

OpenClaw UI: http://localhost:18789

---

## Commands

| Command | Description |
|---------|-------------|
| `make build` | Build image (local arch) |
| `make build-multiarch` | Build multi-arch (amd64 + arm64) and push |
| `make onboard` | Run onboarding (interactive, one-shot) |
| `make run` | Run in foreground via compose (build + start) |
| `make start` | Start background service via compose (build + start) |
| `make stop` | Stop service |
| `make restart` | Restart service (stop + start) |
| `make logs` | View logs |
| `make exec` | Open shell in running container |
| `make open` | Open UI in browser |
| `make upload` | Push image to registry |
| `make clean` | Remove local images |

---

## Why docker compose

`make run` uses `docker compose up --build` (foreground).
`make start` uses `docker compose up -d --build` (background) with `restart: unless-stopped`.

So LocalClaw comes back automatically after:
- process crashes
- Docker daemon restart
- host reboot

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
- Claude Code CLI, Codex CLI, Gemini CLI
- Matrix bot SDK + E2EE crypto libs
- GitHub CLI (`gh`), gcloud CLI
- Helm, kubectl, Go, Trivy, govulncheck, gosec, osv-scanner
- ripgrep, bat, fd, fzf, jq, ffmpeg
- network/debug tools (telnet, ping, ssh)

---

## Messaging

For the easiest start, use **Telegram** — setup is straightforward and works out of the box.

### Telegram Setup

1. Open Telegram and message [@BotFather](https://t.me/BotFather)
2. Send `/newbot` and follow the prompts to choose a name and username
3. BotFather gives you a **bot token** — copy it
4. Open a chat with your new bot and send any message (this creates the chat)
5. Pair your bot with OpenClaw:

```bash
docker run -it --rm \
  -v ~/.openclaw/localclaw:/home/openclaw \
  openclaw:localclaw \
  openclaw pairing approve telegram YOUR_BOT_TOKEN
```

6. Start OpenClaw with `make run` — your bot is now live in Telegram

Once comfortable, consider switching to **Matrix** for better security (end-to-end encryption, self-hosted homeserver support).

---

## Setup Codex

```bash
openclaw onboard --auth-choice openai-codex
openclaw models set openai-codex/gpt-5.3-codex
openclaw models status --plain
```
