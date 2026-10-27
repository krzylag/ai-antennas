IMAGE ?= ciemnyzenek/ai-antennas-opencode
TAG ?= latest
SOURCE_TAG ?= latest
LOCAL_UID ?= 1000
LOCAL_GID ?= 1000
DOCKER ?= docker

.PHONY: build tag push

build:
	$(DOCKER) build \
		--build-arg USER_ID=$(LOCAL_UID) \
		--build-arg GROUP_ID=$(LOCAL_GID) \
		-t $(IMAGE):$(TAG) .

tag:
	$(DOCKER) tag $(IMAGE):$(SOURCE_TAG) $(IMAGE):$(TAG)

push:
	$(DOCKER) push $(IMAGE):$(TAG)
