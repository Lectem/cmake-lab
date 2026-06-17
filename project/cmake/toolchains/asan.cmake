# ASan + UBSan expressed as a build ENVIRONMENT — a toolchain file, not project
# code. Selected by the `linux-debug-asan` preset (or `--toolchain`). This keeps
# sanitizer logic out of CMakeLists.txt entirely.
#
# We seed the _INIT variables: the toolchain-blessed way to set *initial* flags.
# They populate the cache once and remain overridable — this is NOT the
# "mutate CMAKE_CXX_FLAGS in a listfile" anti-pattern from Module 3.
set(_san "-fsanitize=address,undefined -fno-omit-frame-pointer")

set(CMAKE_C_FLAGS_INIT             "${_san}")
set(CMAKE_CXX_FLAGS_INIT           "${_san}")
set(CMAKE_EXE_LINKER_FLAGS_INIT    "-fsanitize=address,undefined")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "-fsanitize=address,undefined")

# (For MSVC you'd ship a sibling toolchain using /fsanitize=address.)
