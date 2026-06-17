# Resolve the `levelpack` HOST tool so codegen works in BOTH a native build and
# a cross build.
#
# The trap: a tool you must RUN during the build has to be built for the build
# HOST, never the target. If you just add_subdirectory(tools/levelpack) and then
# cross-compile (emscripten, Android, aarch64…), CMake builds levelpack with the
# cross toolchain — and you can't execute a .wasm / foreign binary mid-build.
#
# Approach used here: build it natively; IMPORT a host-built copy when crossing.
# (Alternatives: a superbuild that builds it via ExternalProject in a host
#  context, or finding a prebuilt one — same goal, more machinery.)

if(CMAKE_CROSSCOMPILING)
    # We can't run a target binary. Require a levelpack built for the host.
    # find_program already appends the host executable suffix, so NAMES levelpack
    # also matches levelpack.exe on Windows.
    find_program(LEVELPACK_EXECUTABLE NAMES levelpack
        DOC "Host-built levelpack, used during cross compilation")
    # find_program caches a path you pass via -D without checking it exists, so a
    # wrong or not-yet-built path would otherwise fail late, when codegen runs.
    # The EXISTS stat is cheap (find_program itself does not re-search) and turns
    # that into an early error with the recipe.
    if(NOT LEVELPACK_EXECUTABLE OR NOT EXISTS "${LEVELPACK_EXECUTABLE}")
        message(FATAL_ERROR
            "No host levelpack at '${LEVELPACK_EXECUTABLE}'. Build JUST the tool natively\n"
            "  first (configuring the tool alone avoids fetching SDL3/fmt):\n"
            "    cmake -B build-host project/tools/levelpack\n"
            "    cmake --build build-host --config Release\n"
            "  then point the cross build at the built binary:\n"
            "    -DLEVELPACK_EXECUTABLE=<build-host>/levelpack            # single-config\n"
            "    -DLEVELPACK_EXECUTABLE=<build-host>/<Config>/levelpack   # multi-config (e.g. Release/)")
    endif()
    # Expose it under the SAME target name, so the rest of the build doesn't care
    # whether the tool was built here or imported.
    add_executable(levelpack IMPORTED GLOBAL)
    set_target_properties(levelpack PROPERTIES IMPORTED_LOCATION "${LEVELPACK_EXECUTABLE}")
    message(STATUS "levelpack: importing host build ${LEVELPACK_EXECUTABLE}")
else()
    # Native build: the build host IS the target, so just build the tool.
    add_subdirectory(tools/levelpack)
endif()
