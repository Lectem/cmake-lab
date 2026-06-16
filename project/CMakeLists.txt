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
# TODO (Module 3 lab) — make the project configurable the RIGHT way.
#
#   (a) Delete the line below. Forcing -O2 globally clobbers the config type:
#       it breaks Debug, ignores the user's MinSizeRel/RelWithDebInfo choice,
#       and fights package maintainers. Optional features stay optional.
#
#   (b) Add a proper opt-in switch:
#         option(DUNGEON_ENABLE_CHEATS "Build with cheat output" OFF)
#       and wire the DUNGEON_CHEATS define onto the app when it is ON.
#
#   (c) Add a Debug-only HUD on the app with a GENERATOR EXPRESSION:
#         $<$<CONFIG:Debug>:DUNGEON_HUD>
#       NOT if(CMAKE_BUILD_TYPE STREQUAL "Debug") — that silently does nothing
#       under multi-config generators (Visual Studio, Xcode, Ninja Multi-Config).
#
#   The wiring for (b)/(c) goes on the dungeon target in apps/dungeon/CMakeLists.txt.
# ---------------------------------------------------------------------------
set(CMAKE_CXX_FLAGS "-O2")   # ← (a) the anti-pattern to remove

# Targets are declared in subdirectories. Order matters: a target must exist
# before another can link it, so the library comes first.
add_subdirectory(libs/game-core)
add_subdirectory(apps/dungeon)

include(cmake/CaptureTheBuild.cmake)
