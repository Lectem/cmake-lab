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

# Export the package so downstream projects can `find_package(Dungeon CONFIG)`.
# The export set ships our targets WITH their usage requirements (the PUBLIC
# include dir + C++17) across the package boundary.
install(EXPORT DungeonTargets
        NAMESPACE dungeon::
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Dungeon
        FILE DungeonTargets.cmake)

include(CMakePackageConfigHelpers)
configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/DungeonConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/DungeonConfig.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Dungeon)
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/DungeonConfigVersion.cmake
    VERSION ${PROJECT_VERSION} COMPATIBILITY SameMajorVersion)
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/DungeonConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/DungeonConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Dungeon)

# CPack reuses the install() rules to produce redistributable packages.
# Top-level only: a project that add_subdirectory's us shouldn't inherit our packaging.
if(PROJECT_IS_TOP_LEVEL)
    set(CPACK_PACKAGE_VENDOR "Dungeon")
    set(CPACK_GENERATOR "ZIP;TGZ")   # + NSIS/WIX on Windows, DEB/RPM on Linux
    include(CPack)
endif()

include(cmake/CaptureTheBuild.cmake)
