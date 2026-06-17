cmake_minimum_required(VERSION 3.25...3.28)  # 3.25: dependency providers + SYSTEM (cmake/Dependencies.cmake)

# Wire CPM in as the dependency provider BEFORE the first project() call. That is
# the one moment CMake lets a provider register, and it makes every find_package()
# below resolvable from source. Only when WE are the top-level build: if a parent
# add_subdirectory's us, the provider is theirs to choose, and CMake reads this var
# only at that first (top-level) project() anyway, so setting it here would be a
# dead no-op. We can't gate on PROJECT_IS_TOP_LEVEL (it doesn't exist until
# project() runs), so we compare source dirs. A preset, a -D, or a vcpkg toolchain
# still overrides it.
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR
   AND NOT DEFINED CMAKE_PROJECT_TOP_LEVEL_INCLUDES)
    set(CMAKE_PROJECT_TOP_LEVEL_INCLUDES ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Dependencies.cmake)
endif()

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

# Tooling (Module 8): the compile database (clang-tidy / clangd / IDEs) is a
# per-developer, configure-time choice, so it is enabled in CMakePresets.json
# (cacheVariables), not hard-set here. Hard-setting it would also override a
# consumer who passes -DCMAKE_EXPORT_COMPILE_COMMANDS=OFF. ASan likewise lives in
# a toolchain file (cmake/toolchains/asan.cmake), selected by a preset.

# Bonus (Module 10): a compiler launcher (ccache/sccache) for fast rebuilds.
# Guarded by find_program, so it's a silent no-op where the tool isn't installed.
option(DUNGEON_USE_CCACHE "Use ccache/sccache if available" ON)
if(DUNGEON_USE_CCACHE)
    find_program(CCACHE_PROGRAM NAMES ccache sccache)
    if(CCACHE_PROGRAM)
        set(CMAKE_CXX_COMPILER_LAUNCHER ${CCACHE_PROGRAM})
        set(CMAKE_C_COMPILER_LAUNCHER   ${CCACHE_PROGRAM})
        message(STATUS "Compiler launcher: ${CCACHE_PROGRAM}")
    endif()
endif()

# Dependencies are DECLARED once in cmake/Dependencies.cmake (wired in as the
# provider above). No targets are created here: each subdirectory pulls what it
# needs with find_package(Foo CONFIG REQUIRED) and CPM satisfies the call. That
# is the exact same line a vcpkg or Conan shop would write, which is the point.

# Targets are declared in subdirectories. Order matters: a target must exist
# before another can link it, so the library comes first.
include(cmake/GitVersion.cmake)     # build-time git SHA + version stamping (dungeon-version target)

add_subdirectory(libs/game-core)
include(cmake/HostTool.cmake)       # resolves the levelpack host tool (native build vs. cross)
add_subdirectory(apps/dungeon)

# LTO/IPO (Module 9): only after a support check, only in Release, never blindly
# global. Set here because both targets must already exist.
include(CheckIPOSupported)
check_ipo_supported(RESULT _ipo OUTPUT _ipo_msg)
if(_ipo)
    set_target_properties(game-core dungeon PROPERTIES INTERPROCEDURAL_OPTIMIZATION_RELEASE ON)
endif()

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

# Tests (Module 6). include(CTest) calls enable_testing() and adds BUILD_TESTING.
# Catch2 is pulled with find_package(Catch2) inside tests/, same vendor-neutral
# pattern as SDL3/fmt. The subdir is added before the check target below so it
# can depend on the test executable.
option(DUNGEON_BUILD_TESTS "Build the unit tests" ${PROJECT_IS_TOP_LEVEL})
if(DUNGEON_BUILD_TESTS)
    include(CTest)
    add_subdirectory(tests)
endif()

include(cmake/CaptureTheBuild.cmake)
