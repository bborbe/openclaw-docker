# OpenClaw Docker

Docker image and compose runtime for [OpenClaw](https://openclaw.ai).

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (with Docker Compose)
- [GNU Make](https://www.gnu.org/software/make/)
- [jq](https://jqlang.github.io/jq/) (for `make fix-config`)
- A Telegram account (for the recommended messaging setup)

## Quick Start

```bash
# 1) Create state directory
mkdir -p ~/.openclaw/localclaw

# 2) Build the image
make build

# 3) Run onboarding — interactive wizard that configures auth, model, and gateway settings
make onboard

# 4) Fix config (required — OpenClaw crashes without this in a fresh container)
make fix-config

# 5) Connect Telegram (see "Telegram Setup" below for how to get a bot token)
make pair-telegram TOKEN=your_bot_token

# 6) Run in foreground
make run
```

You should now be able to message your Telegram bot and get responses from OpenClaw.

To stop: `Ctrl+C` then `make stop`, or just `Ctrl+C` if running in foreground.

---

## Telegram Setup

1. Open Telegram and message [@BotFather](https://t.me/BotFather)
2. Send `/newbot` and follow the prompts to choose a name and username
3. BotFather gives you a **bot token** — copy it
4. Send `/start` to your new bot (opens the chat so it can receive messages)
5. Pair your bot:

```bash
make pair-telegram TOKEN=your_bot_token
```

6. Start OpenClaw with `make run` — your bot is now live in Telegram

Once comfortable, consider switching to **Matrix** for better security (end-to-end encryption, self-hosted homeserver support).

---

## Web UI

The `make fix-config` step disables the web UI to work around a crash in fresh containers. To re-enable it later:

1. Edit `~/.openclaw/localclaw/.openclaw/openclaw.json`
2. Set `gateway.controlUi.enabled` to `true`
3. Restart with `make restart`

OpenClaw UI: http://localhost:18789

---

## Commands

| Command | Description |
|---------|-------------|
| `make build` | Build image (local arch) |
| `make build-multiarch` | Build multi-arch (amd64 + arm64) and push |
| `make onboard` | Run onboarding wizard (interactive, one-shot) |
| `make fix-config` | Apply controlUi workaround (required after fresh onboard) |
| `make pair-telegram TOKEN=...` | Pair a Telegram bot with OpenClaw |
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

## Setup Codex

Run these commands inside the container:

```bash
make exec
# then inside the container:
openclaw onboard --auth-choice openai-codex
openclaw models set openai-codex/gpt-5.3-codex
openclaw models status --plain
```

---

## Troubleshooting

**OpenClaw crashes immediately on start**
- Run `make fix-config` — this disables the controlUi which causes crashes in fresh containers
- Check the config exists: `cat ~/.openclaw/localclaw/.openclaw/openclaw.json`
- If config is missing, run `make onboard` first

**Telegram bot not responding**
- Verify the bot token: message [@BotFather](https://t.me/BotFather) and send `/mybots` to check
- Make sure you sent `/start` to your bot before pairing
- Check logs: `make logs`

**`make onboard` fails with image not found**
- Run `make build` first — the onboard target requires the `openclaw:localclaw` image

**`make fix-config` fails with "jq not found"**
- Install jq: `brew install jq` (macOS) or `sudo apt install jq` (Linux)

**Port 18789 already in use**
- Stop any existing instance: `make stop`
- Or check what's using the port: `lsof -i :18789`
