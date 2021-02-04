CC=gcc-8
CXX=g++-8

#------------------------------------------------------------------------------
# Environments
#------------------------------------------------------------------------------
BUILD_DIR=cmake/build
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
