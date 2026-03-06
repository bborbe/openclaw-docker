REGISTRY ?= docker.io
IMAGE ?= bborbe/openclaw
VERSION ?= 2026.3.1

export REGISTRY IMAGE VERSION

COMPOSE ?= docker compose
SERVICE ?= localclaw
CONTAINER_NAME ?= localclaw

default: build

.PHONY: build
build:
	DOCKER_BUILDKIT=1 docker build \
		--build-arg VERSION=$(VERSION) \
		--build-arg BUILDKIT_INLINE_CACHE=1 \
		-t $(REGISTRY)/$(IMAGE):$(VERSION) \
		-t $(REGISTRY)/$(IMAGE):latest \
		-f Dockerfile \
		.

.PHONY: build-multiarch
build-multiarch:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--build-arg VERSION=$(VERSION) \
		-t $(REGISTRY)/$(IMAGE):$(VERSION) \
		-t $(REGISTRY)/$(IMAGE):latest \
		--push \
		-f Dockerfile \
		.

.PHONY: upload
upload:
	docker push $(REGISTRY)/$(IMAGE):$(VERSION)
	docker push $(REGISTRY)/$(IMAGE):latest

.PHONY: clean
clean:
	docker rmi $(REGISTRY)/$(IMAGE):$(VERSION) || true
	docker rmi $(REGISTRY)/$(IMAGE):latest || true

.PHONY: onboard
onboard:
	docker run -it --rm \
		-p 18789:18789 \
		-v ~/.openclaw/localclaw:/home/openclaw \
		$(REGISTRY)/$(IMAGE):latest \
		openclaw onboard

.PHONY: start
start:
	$(COMPOSE) up -d --build

.PHONY: stop
stop:
	$(COMPOSE) down

.PHONY: restart
restart: stop start

.PHONY: run
run:
	$(COMPOSE) up --build

.PHONY: logs
logs:
	$(COMPOSE) logs -f $(SERVICE)

.PHONY: exec
exec:
	$(COMPOSE) exec $(SERVICE) bash

.PHONY: open
open:
	open http://localhost:18789

STATE_DIR ?= $(HOME)/.openclaw/localclaw
CONFIG ?= $(STATE_DIR)/.openclaw/openclaw.json

.PHONY: fix-config
fix-config:
	@command -v jq >/dev/null || { echo "Error: jq is required. Install with: brew install jq (macOS) or apt install jq (Linux)"; exit 1; }
	@test -f $(CONFIG) || { echo "Error: $(CONFIG) not found. Run 'make onboard' first."; exit 1; }
	jq '.gateway.controlUi = {"allowedOrigins": ["http://localhost:18789","http://127.0.0.1:18789"], "enabled": false}' $(CONFIG) > $(CONFIG).tmp && mv $(CONFIG).tmp $(CONFIG)
	@echo "Done: controlUi disabled in $(CONFIG)"

.PHONY: pair-telegram
pair-telegram:
	@test -n "$(TOKEN)" || { echo "Usage: make pair-telegram TOKEN=your_bot_token"; exit 1; }
	docker run -it --rm \
		-v $(STATE_DIR):/home/openclaw \
		$(REGISTRY)/$(IMAGE):latest \
		openclaw pairing approve telegram $(TOKEN)
