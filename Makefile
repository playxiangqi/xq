CC=gcc-8
CXX=g++-8

#------------------------------------------------------------------------------
# Environments
#------------------------------------------------------------------------------
SOURCE_ENV=PROJECT_DIR=${PWD} CC=${CC} CXX=${CXX}

#------------------------------------------------------------------------------
# Targets
#------------------------------------------------------------------------------
.PHONY: start
start:
	@cd xq_portal && mix phx.server

.PHONY: setup
setup:
	@cd xq_app && yarn
	@cd xq_portal && mix phx.setup

.PHONY: docker
docker:
	@./scripts/docker-compose.sh

.PHONY: conan
conan:
	@${SOURCE_ENV} ./scripts/conan.sh -b

.PHONY: gen
gen:
	@${SOURCE_ENV} ./scripts/cmake.sh -g

.PHONY: build
build:
	@${SOURCE_ENV} ./scripts/cmake.sh -b
	@cd xq_portal && mix compile.cmake
