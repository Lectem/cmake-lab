# Capture the Build — Module 4 helper (run via cmake -P after `cmake --install`).
# Verifies the staged install tree is complete, then writes the flag.
# Expected -D variables: STAGE, FLAGFILE

set(_missing "")

if(NOT EXISTS "${STAGE}/bin/dungeon" AND NOT EXISTS "${STAGE}/bin/dungeon.exe")
    list(APPEND _missing "the dungeon executable in bin/")
endif()

if(NOT EXISTS "${STAGE}/include/dungeon/world.hpp")
    list(APPEND _missing "the public header in include/dungeon/")
endif()

file(GLOB _cfg "${STAGE}/lib*/cmake/Dungeon/DungeonConfig.cmake")
if(NOT _cfg)
    list(APPEND _missing "the package config (lib/cmake/Dungeon/DungeonConfig.cmake)")
endif()

if(_missing)
    list(JOIN _missing "\n        - " _m)
    file(WRITE "${FLAGFILE}" "  ⛔  Install tree incomplete. Missing:\n        - ${_m}\n")
else()
    file(WRITE "${FLAGFILE}"
        "  ✅  Installable, exportable (find_package-able), and packageable.\n"
        "  🚩  flag{shipped_it}\n")
endif()
