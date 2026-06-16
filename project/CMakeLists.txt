cmake_minimum_required(VERSION 3.22...3.28)

project(Dungeon
    VERSION 0.1.0
    DESCRIPTION "A tiny roguelike we grow across the CMake course"
    LANGUAGES CXX)

# Bury the first anti-pattern: stop in-source builds before they pollute the tree.
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
    message(FATAL_ERROR "In-source builds are not allowed. Use: cmake -S . -B build")
endif()

# Optional features stay optional: an opt-in switch, default OFF. Its value is
# known at configure time, so a plain if() (in apps/dungeon) is the right tool.
option(DUNGEON_ENABLE_CHEATS "Build with cheat output" OFF)

# Targets are declared in subdirectories. Order matters: a target must exist
# before another can link it, so the library comes first.
add_subdirectory(libs/game-core)
add_subdirectory(apps/dungeon)

# TODO (Module 4 lab) — export the package and enable CPack.
#   After the subdirectory install(TARGETS ... EXPORT DungeonTargets) rules:
#
#   install(EXPORT DungeonTargets
#           NAMESPACE dungeon::
#           DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Dungeon
#           FILE DungeonTargets.cmake)
#
#   include(CMakePackageConfigHelpers)
#   configure_package_config_file(
#       ${CMAKE_CURRENT_SOURCE_DIR}/cmake/DungeonConfig.cmake.in
#       ${CMAKE_CURRENT_BINARY_DIR}/DungeonConfig.cmake
#       INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Dungeon)
#   write_basic_package_version_file(
#       ${CMAKE_CURRENT_BINARY_DIR}/DungeonConfigVersion.cmake
#       VERSION ${PROJECT_VERSION} COMPATIBILITY SameMajorVersion)
#   install(FILES
#       ${CMAKE_CURRENT_BINARY_DIR}/DungeonConfig.cmake
#       ${CMAKE_CURRENT_BINARY_DIR}/DungeonConfigVersion.cmake
#       DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Dungeon)
#
#   set(CPACK_PACKAGE_VENDOR "Dungeon")
#   set(CPACK_GENERATOR "ZIP;TGZ")
#   include(CPack)
# (See labs/module-04-packaging.md — copy-paste ready.)

include(cmake/CaptureTheBuild.cmake)
