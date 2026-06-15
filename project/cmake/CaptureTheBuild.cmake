# Capture the Build — Module 2 verifier.
#
# Checks (at configure time, where target topology is visible) that the project
# is split into a `game-core` LIBRARY linked PRIVATE-ly by the `dungeon`
# executable. Writes the result to build/flag.txt; the `check` target prints it.

set(_ok TRUE)
set(_why "")

if(NOT TARGET game-core)
    set(_ok FALSE)
    set(_why "there is no 'game-core' target yet — extract the game logic into a library")
else()
    get_target_property(_type game-core TYPE)
    if(NOT _type MATCHES "LIBRARY")
        set(_ok FALSE)
        set(_why "'game-core' is a ${_type}, not a library")
    endif()
endif()

if(_ok)
    get_target_property(_src_dir game-core SOURCE_DIR)
    if(_src_dir STREQUAL CMAKE_SOURCE_DIR)
        set(_ok FALSE)
        set(_why "'game-core' was defined in the root CMakeLists.txt — use add_subdirectory() to move it into its own directory")
    endif()
endif()

if(_ok)
    get_target_property(_libs dungeon LINK_LIBRARIES)
    if(NOT _libs MATCHES "game-core")
        set(_ok FALSE)
        set(_why "'dungeon' does not link game-core")
    endif()
endif()

if(_ok)
    file(WRITE "${CMAKE_BINARY_DIR}/flag.txt"
        "  ✅  Library + executable split is well-formed.\n"
        "  🚩  flag{transitive_propagation_unlocked}\n")
else()
    file(WRITE "${CMAKE_BINARY_DIR}/flag.txt"
        "  ⛔  Not yet: ${_why}.\n"
        "      Goal: a 'game-core' library with PUBLIC include dir, linked PRIVATE by 'dungeon'.\n")
endif()

add_custom_target(check
    COMMAND ${CMAKE_COMMAND} -E echo "── Running Dungeon ──────────────────────"
    COMMAND $<TARGET_FILE:dungeon>
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E cat "${CMAKE_BINARY_DIR}/flag.txt"
    DEPENDS dungeon
    VERBATIM)
