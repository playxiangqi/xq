CC=gcc-8
CXX=g++-8

#------------------------------------------------------------------------------
# Environments
#------------------------------------------------------------------------------
SOURCE_ENV=PROJECT_DIR=${PWD} CC=${CC} CXX=${CXX}

APP_NAME ?= `grep 'app:' xq_portal/mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g'`
APP_VSN ?= `grep 'version:' xq_portal/mix.exs | cut -d '"' -f2`
BUILD ?= `git rev-parse --short HEAD`

#------------------------------------------------------------------------------
# Targets
#------------------------------------------------------------------------------
.PHONY: start
start:
	@cd xq_portal && mix compile --force && mix phx.server

.PHONY: setup
setup:
	@./scripts/setup.bash

.PHONY: test
test:
	@cd xq_portal && MIX_ENV=test mix coveralls.json --trace

.PHONY: conan
conan:
	@${SOURCE_ENV} ./scripts/conan.bash -b

.PHONY: gen
gen:
	@${SOURCE_ENV} ./scripts/cmake.bash -g

.PHONY: build
build:
	@cd xq_app && yarn
	@${SOURCE_ENV} ./scripts/cmake.bash -b

.PHONY: docker-compose-dev
docker-compose-dev:
	docker-compose --file ./docker/docker-compose.dev.yml --project-name xq up --detach

.PHONY: docker-dev-local
docker-dev-local:
	docker build --build-arg MIX_ENV=dev --build-arg BUILD=$(BUILD) \
		--build-arg ENGINE_IMAGE=$(ENGINE_IMAGE) \
		-f docker/Dockerfile -t $(APP_NAME):$(APP_VSN) .

.PHONY: docker-dev
docker-dev:
	docker build --build-arg APP_VSN=$(APP_VSN) --build-arg MIX_ENV=prod \
		--build-arg BUILD=$(BUILD) \
		--build-arg ENGINE_IMAGE=$(ENGINE_IMAGE) \
		-f docker/Dockerfile -t ${AWS_ECR_URL}:latest .

.PHONY: push-dev
push-dev:
	docker push ${AWS_ECR_URL}:latest

.PHONY: docker-engine
docker-engine:
	docker build -f docker/Dockerfile.$(ENGINE_NAME) -t $(AWS_ECR_URL):latest .
