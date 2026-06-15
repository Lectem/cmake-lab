cmake_minimum_required(VERSION 3.22...3.28)

project(Dungeon
    VERSION 0.1.0
    DESCRIPTION "A tiny roguelike we grow across the CMake course"
    LANGUAGES CXX)

# ---------------------------------------------------------------------------
# TODO (Module 1 lab):
#   Right now this project happily configures even when you run CMake *inside*
#   the source tree, scattering CMakeCache.txt / CMakeFiles/ all over your
#   sources. Add a guard here that stops configuration with a FATAL_ERROR on an
#   in-source build, then re-run the `check` target to capture your first flag.
#
#   Hint: compare CMAKE_SOURCE_DIR with CMAKE_BINARY_DIR.
# ---------------------------------------------------------------------------

add_executable(dungeon)
target_sources(dungeon PRIVATE main.cpp)
target_compile_features(dungeon PRIVATE cxx_std_17)

# --- Capture the Build -------------------------------------------------------
# Builds the game, runs it, then awards the flag if the build is well-formed.
add_custom_target(check
    COMMAND ${CMAKE_COMMAND} -E echo "── Running Dungeon ──────────────────────"
    COMMAND $<TARGET_FILE:dungeon>
    COMMAND ${CMAKE_COMMAND}
            -DFLAG=flag{hello_cmake}
            -DSRC=${CMAKE_SOURCE_DIR}
            -DBIN=${CMAKE_BINARY_DIR}
            -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Flag.cmake
    DEPENDS dungeon
    VERBATIM)
