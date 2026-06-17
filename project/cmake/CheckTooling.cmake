# Capture the Build — Module 8 helper (run via cmake -P).
# Expected -D variables: BUILD, SRC, FLAGFILE

set(_missing "")

# Sanitizers as a toolchain file (Module 7 concept) selected by a preset
# (Module 8) — the project listfiles stay free of sanitizer logic.
if(NOT EXISTS "${SRC}/cmake/toolchains/asan.cmake")
    list(APPEND _missing "cmake/toolchains/asan.cmake — put sanitizer flags in a toolchain, not the listfiles")
endif()

if(NOT EXISTS "${SRC}/CMakePresets.json")
    list(APPEND _missing "CMakePresets.json with an ASan preset (encode the build, don't document it)")
else()
    file(READ "${SRC}/CMakePresets.json" _p)
    if(NOT _p MATCHES "asan")
        list(APPEND _missing "an ASan configure preset that selects the toolchain (name containing 'asan')")
    endif()
endif()

if(NOT EXISTS "${BUILD}/compile_commands.json")
    list(APPEND _missing "compile_commands.json (configure with -DCMAKE_EXPORT_COMPILE_COMMANDS=ON, or via a preset)")
endif()

if(_missing)
    list(JOIN _missing "\n        - " _m)
    file(WRITE "${FLAGFILE}" "  ⛔  Tooling not wired yet. Fix:\n        - ${_m}\n")
else()
    file(WRITE "${FLAGFILE}"
        "  ✅  compile_commands.json exported; sanitizers in a toolchain, selected by a preset.\n"
        "  🚩  flag{asan_caught_me}\n")
endif()
