# Capture the Build — Module 10 grand finale (run via cmake -P).
# Verifies the WHOLE journey is intact: the project installs, exports a
# find_package-able config, and has the git SHA baked in.
# Expected -D variables: STAGE, VERHDR, FLAGFILE

set(_missing "")

if(NOT EXISTS "${STAGE}/bin/dungeon" AND NOT EXISTS "${STAGE}/bin/dungeon.exe")
    list(APPEND _missing "the installed dungeon executable (Module 4)")
endif()
if(NOT EXISTS "${STAGE}/include/dungeon/world.hpp")
    list(APPEND _missing "the installed public header (Module 4)")
endif()
file(GLOB _cfg "${STAGE}/lib*/cmake/Dungeon/DungeonConfig.cmake")
if(NOT _cfg)
    list(APPEND _missing "the find_package config package (Module 4)")
endif()

set(_sha_ok FALSE)
if(EXISTS "${VERHDR}")
    file(READ "${VERHDR}" _v)
    if(_v MATCHES "kGitSha  = \"([0-9a-fA-F]+)\"")
        set(_sha_ok TRUE)
    endif()
endif()
if(NOT _sha_ok)
    list(APPEND _missing "the git SHA baked into the binary (Module 9)")
endif()

if(_missing)
    list(JOIN _missing "\n        - " _m)
    file(WRITE "${FLAGFILE}" "  ⛔  Not all levels complete. Still missing:\n        - ${_m}\n")
else()
    file(WRITE "${FLAGFILE}"
        "  ✅  Tests green · installs & exports · packages · git SHA baked in.\n"
        "  🏆  All ten flags captured.\n"
        "  🚩  flag{capture_the_build_complete}\n")
endif()
