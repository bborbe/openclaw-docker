REGISTRY ?= docker.io
IMAGE ?= bborbe/openclaw
VERSION ?= 2026.2.15

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
	-p 18901:18789 \
	-v ~/.openclaw/localclaw:/home/openclaw \
	openclaw:localclaw \
	openclaw onboard

start:
	docker run \
		--rm \
		-d \
		--name localclaw \
		-p 18901:18789 \
		-v ~/.openclaw/localclaw:/home/openclaw \
		openclaw:localclaw

stop:
	docker kill localclaw

run:
	docker run \
		--rm \
		--name localclaw \
		-p 18901:18789 \
		-v ~/.openclaw/localclaw:/home/openclaw \
		openclaw:localclaw

logs:
	docker logs localclaw -f

exec:
	docker exec -ti localclaw bash

open:
	open http://localhost:18901
