cmake_minimum_required(VERSION 3.22...3.28)

project(Dungeon
    VERSION 0.1.0
    DESCRIPTION "A tiny roguelike we grow across the CMake course"
    LANGUAGES CXX)

# Bury the first anti-pattern: stop in-source builds before they pollute the tree.
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
    message(FATAL_ERROR "In-source builds are not allowed. Use: cmake -S . -B build")
endif()

# ---------------------------------------------------------------------------
# TODO (Module 2 lab):
#   Everything is crammed into ONE executable target. The game logic (world.*)
#   cannot be reused or unit-tested without dragging in main().
#
#   Refactor into a proper target graph:
#     1. a `game-core` LIBRARY that exposes its headers via a PUBLIC include dir
#        and requires cxx_std_17 PUBLIC-ly (so consumers inherit both);
#     2. the `dungeon` executable that links game-core PRIVATE and gets the
#        include path + C++17 transitively — no need to repeat them.
#
#   Suggested pitchfork layout:
#     libs/game-core/{include/dungeon/world.hpp, source/world.cpp, CMakeLists.txt}
#     apps/dungeon/{main.cpp, CMakeLists.txt}
#   Use add_subdirectory() (library first — order matters).
#
#   The `check` target reports when the split is correct → flag.
# ---------------------------------------------------------------------------

add_executable(dungeon)
target_sources(dungeon PRIVATE src/main.cpp src/world.cpp src/world.hpp)
target_include_directories(dungeon PRIVATE src)
target_compile_features(dungeon PRIVATE cxx_std_17)

include(cmake/CaptureTheBuild.cmake)
