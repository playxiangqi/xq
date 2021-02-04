cmake_minimum_required(VERSION 3.10)
project(xq DESCRIPTION "Xiangqi Engine")

include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")

find_package(Erlang REQUIRED)

set(XQ_LIB_TARGET "xq_native")

add_library(${XQ_LIB_TARGET} SHARED)
set_target_properties(${XQ_LIB_TARGET} PROPERTIES CXX_STANDARD 17 PREFIX "")
target_compile_options(${XQ_LIB_TARGET}
  PRIVATE
    -Wall
    -Wextra
    -Werror
    -Wno-unused
    -pedantic-errors
    -O3
    -m64
    -fPIC
    -ffast-math
)
target_sources(${XQ_LIB_TARGET}
  PRIVATE
    xq_portal/lib/xq_native/nif.cpp
)
target_include_directories(${XQ_LIB_TARGET}
  PRIVATE
    xq_portal/lib/xq_native/
  PUBLIC
    xq_engine/include/
    ${ERLANG_EI_INCLUDE_PATH}
    ${ERLANG_ERTS_INCLUDE_PATH}
)

# add_executable(xq_test)
# target_sources(xq_test)
#   PUBLIC
#     test/xq_native/test.cpp)
