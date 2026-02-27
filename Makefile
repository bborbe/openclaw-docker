REGISTRY ?= docker.io
IMAGE ?= bborbe/openclaw
VERSION ?= 2026.2.24

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
		-t openclaw:localclaw \
		-f Dockerfile \
		.

.PHONY: build-multiarch
build-multiarch:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--build-arg VERSION=$(VERSION) \
		-t $(REGISTRY)/$(IMAGE):$(VERSION) \
		--push \
		-f Dockerfile \
		.

.PHONY: upload
upload:
	docker push $(REGISTRY)/$(IMAGE):$(VERSION)

.PHONY: clean
clean:
	docker rmi $(REGISTRY)/$(IMAGE):$(VERSION) || true
	docker rmi openclaw:localclaw || true

.PHONY: onboard
onboard:
	docker run -it --rm \
		-p 18789:18789 \
		-v ~/.openclaw/localclaw:/home/openclaw \
		openclaw:localclaw \
		openclaw onboard

.PHONY: start
start:
	$(COMPOSE) up -d

.PHONY: stop
stop:
	$(COMPOSE) down

.PHONY: restart
restart: stop start

.PHONY: run
run:
	docker run \
		--rm \
		--name $(CONTAINER_NAME) \
		-p 18789:18789 \
		-v ~/.openclaw/localclaw:/home/openclaw \
		openclaw:localclaw

.PHONY: logs
logs:
	$(COMPOSE) logs -f $(SERVICE)

.PHONY: exec
exec:
	$(COMPOSE) exec $(SERVICE) bash

.PHONY: open
open:
	open http://localhost:18789
