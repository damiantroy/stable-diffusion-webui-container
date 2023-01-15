REPO_NAME ?= localhost
IMAGE_NAME ?= stable-diffusion-webui
APP_NAME := ${REPO_NAME}/${IMAGE_NAME}
CONTAINER_RUNTIME := $(shell command -v podman 2> /dev/null || echo docker)

.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
.DEFAULT_GOAL := help

.PHONY: build
build: ## Build the container.
	./scripts/build.sh

.PHONY: build-nc
build-nc: ## Build the container without cache.
	./scripts/build.sh -n

.PHONY: shell
shell: ## Launch a shell in the container.
	./scripts/shell.sh

.PHONY: run
run: ## Launch the container in the foreground.
	./scripts/run.sh

.PHONY: run-bg
run-bg: ## Launch the container in the background.
	./scripts/run.sh -d

.PHONY: clean
clean: ## Clean the generated files/images.
	sudo $(CONTAINER_RUNTIME) rmi "${APP_NAME}"
