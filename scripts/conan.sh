#!/usr/bin/env bash
BUILD_DIR=${PROJECT_DIR}/cmake/build

usage() {
  echo "$0 usage: \n
    -s setup conan remotes
    -b build and install dependencies via conan
    -c clean conan build info
  "
}

while getopts "sbch" arg; do
  case $arg in
  s)
    conan remote add bincrafters https://api.bintray.com/conan/bincrafters/public-conan
    ;;
  b)
    mkdir -p ${BUILD_DIR} && cd ${BUILD_DIR} && conan install ${PROJECT_DIR} --build
    ;;
  c)
    rm -rf ${BUILD_DIR}/conanbuildinfo.cmake
    ;;
  h | *)
    usage
    exit 0
    ;;
  esac
done
