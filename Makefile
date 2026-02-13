build:
	DOCKER_BUILDKIT=1 docker build \
		-t openclaw:localclaw \
		-f Dockerfile \
		--build-arg BUILDKIT_INLINE_CACHE=1 \
		.

onboard:
	docker run -it --rm \
	-p 18901:18789 \
	-v ~/.openclaw/localclaw:/home/openclaw \
	openclaw:localclaw \
	node dist/index.js onboard

start:
	docker run \
		--rm \
		-d \
		--name localclaw \
		--user $$(id -u):$$(id -g) \
		-p 18901:18789 \
		-v ~/.openclaw/localclaw:/home/openclaw \
		openclaw:localclaw \
		node dist/index.js gateway --bind=lan

stop:
	docker kill localclaw

run:
	docker run \
		--rm \
		--name localclaw \
		--user $$(id -u):$$(id -g) \
		-p 18901:18789 \
		-v ~/.openclaw/localclaw:/home/openclaw \
		openclaw:localclaw \
		node dist/index.js gateway --bind=lan

logs:
	docker logs localclaw -f

exec:
	docker exec -ti localclaw bash

open:
	open http://localhost:18901
