# Capture the Build — Module 3 verifier.
#
# Confirms the project is customizable the modern way: no hardcoded global
# optimization flag, an opt-in cheats OPTION, and a config-gated debug HUD that
# uses a generator expression (so it survives multi-config generators).

set(_ok TRUE)
set(_why "")

# Precondition: the Module 2 split must still stand.
if(NOT TARGET game-core OR NOT TARGET dungeon)
    set(_ok FALSE)
    set(_why "the game-core / dungeon split is missing")
endif()

# (a) No optimization flag hardcoded into the global flags — let the config decide.
if(_ok AND CMAKE_CXX_FLAGS MATCHES "-O[0-9s]")
    set(_ok FALSE)
    set(_why "remove the hardcoded optimization flag from CMAKE_CXX_FLAGS — the config type owns that")
endif()

# (b) Cheats must be an opt-in cache option (optional features stay optional).
if(_ok)
    get_property(_cheats_type CACHE DUNGEON_ENABLE_CHEATS PROPERTY TYPE)
    if(NOT _cheats_type STREQUAL "BOOL")
        set(_ok FALSE)
        set(_why "add option(DUNGEON_ENABLE_CHEATS ...) instead of hardcoding the feature")
    endif()
endif()

# (c) The debug HUD must be gated by a generator expression on the config.
if(_ok)
    get_target_property(_defs dungeon COMPILE_DEFINITIONS)
    if(NOT _defs MATCHES "CONFIG:Debug" OR NOT _defs MATCHES "DUNGEON_HUD")
        set(_ok FALSE)
        set(_why "gate DUNGEON_HUD with a generator expression: $<$<CONFIG:Debug>:DUNGEON_HUD>")
    endif()
endif()

if(_ok)
    file(WRITE "${CMAKE_BINARY_DIR}/flag.txt"
        "  ✅  Configurable the modern way — no global flag clobbering, optional stays optional.\n"
        "  🚩  flag{options_stay_optional}\n")
else()
    file(WRITE "${CMAKE_BINARY_DIR}/flag.txt"
        "  ⛔  Not yet: ${_why}.\n")
endif()

add_custom_target(check
    COMMAND ${CMAKE_COMMAND} -E echo "── Running Dungeon ──────────────────────"
    COMMAND $<TARGET_FILE:dungeon>
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E cat "${CMAKE_BINARY_DIR}/flag.txt"
    DEPENDS dungeon
    VERBATIM)
