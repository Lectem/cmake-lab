# A practice toolchain file. Real toolchains (emscripten, Android NDK, an
# aarch64 cross-GCC) follow this same skeleton — the point of the exercise is
# that target definitions live HERE, outside CMakeLists.txt, and are selected
# with `cmake --toolchain cmake/toolchains/practice.cmake`.

set(CMAKE_SYSTEM_NAME      Linux)      # the TARGET system we build FOR
set(CMAKE_SYSTEM_PROCESSOR x86_64)

# Find programs on the host, but libraries/headers/packages in the target root.
# This is the knob that stops a cross build from picking up host libraries.
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
