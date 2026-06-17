add_executable(dungeon)
target_sources(dungeon PRIVATE main.cpp)

# SDL3 and fmt are real CMake packages. We ask for them the vendor-neutral way.
# The dependency provider (cmake/Dependencies.cmake) maps these onto CPM, but the
# lines below are identical to what a vcpkg or Conan build would use.
find_package(SDL3 CONFIG REQUIRED)
find_package(fmt  CONFIG REQUIRED)

# Nobody links the executable → PRIVATE. The include path and C++17 arrive
# transitively from game-core's PUBLIC usage requirements — don't repeat them.
# SDL3 and fmt are implementation details of the app → PRIVATE, and linked
# through their NAMESPACED imported targets (not bare `SDL3`).
target_link_libraries(dungeon PRIVATE
    dungeon::game-core
    SDL3::SDL3
    fmt::fmt)

# Debug-only HUD via a generator expression — evaluated per-config at generation
# time, so it works under single- AND multi-config generators (unlike branching
# on CMAKE_BUILD_TYPE, which is empty at configure time under Visual Studio).
target_compile_definitions(dungeon PRIVATE $<$<CONFIG:Debug>:DUNGEON_HUD>)

# Opt-in cheats: an option's value IS known at configure time, so if() is fine.
if(DUNGEON_ENABLE_CHEATS)
    target_compile_definitions(dungeon PRIVATE DUNGEON_CHEATS)
endif()

# Install the executable into the platform's bin/ dir.
include(GNUInstallDirs)
install(TARGETS dungeon RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
