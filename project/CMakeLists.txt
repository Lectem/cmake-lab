cmake_minimum_required(VERSION 3.22...3.28)

project(Dungeon
    VERSION 0.1.0
    DESCRIPTION "A tiny roguelike we grow across the CMake course"
    LANGUAGES CXX)

# Bury the first anti-pattern: stop in-source builds before they pollute the tree.
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
    message(FATAL_ERROR "In-source builds are not allowed. Use: cmake -S . -B build")
endif()

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
