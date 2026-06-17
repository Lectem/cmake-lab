# ASan expressed as a toolchain file — MSVC variant.
# Selected by the `windows-debug-asan` preset (or --toolchain).
# MSVC ASan is address-only: no UBSan equivalent exists in cl.exe.
#
# We seed the _INIT variables: the toolchain-blessed way to set *initial* flags.
# They populate the cache once and remain overridable — this is NOT the
# "mutate CMAKE_CXX_FLAGS in a listfile" anti-pattern from Module 3.
set(CMAKE_C_FLAGS_INIT   "/fsanitize=address")
set(CMAKE_CXX_FLAGS_INIT "/fsanitize=address")
# MSVC links the ASan runtime automatically — no linker flag needed.
