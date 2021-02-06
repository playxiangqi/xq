#!/usr/bin/env bash
BUILD_DIR=${PROJECT_DIR}/cmake/build

usage() {
  echo "$0 usage: ./cmake.sh -g -b
    -g generate Makefiles
    -b build targets
  "
}

while getopts "gbh" arg; do
  case $arg in
  g)
    mkdir -p ${BUILD_DIR} && cd ${BUILD_DIR}
    rm -rf CMakeFiles CMakeCache.txt
    cmake ${PROJECT_DIR} -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release
    ;;
  b)
    mkdir -p ${BUILD_DIR} && cd ${BUILD_DIR}
    CMAKE_BINARY_DIR=${BUILD_DIR} cmake --build . --target xq_native
    ;;
  h)
    usage
    exit 0
    ;;
  *)
    usage
    exit 1
    ;;
  esac
done
