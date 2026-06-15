# Capture the Build — flag helper.
#
# Invoked by the `check` target via `cmake -P`. It awards the module flag only
# when the build was done the right way. Kept tiny on purpose: the point is to
# reward correct CMake, not to be a test framework.
#
# Expected -D variables: FLAG, SRC, BIN

if(SRC STREQUAL BIN)
    message(FATAL_ERROR
        "\n  ❌  In-source build detected.\n"
        "      Configure into a separate directory, e.g. cmake -S . -B build\n")
endif()

message(STATUS "")
message(STATUS "  ✅  Out-of-source build verified.")
message(STATUS "  🚩  ${FLAG}")
message(STATUS "")
