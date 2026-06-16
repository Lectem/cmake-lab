add_executable(dungeon)
target_sources(dungeon PRIVATE main.cpp)

# Nobody links the executable → PRIVATE. The include path and C++17 arrive
# transitively from game-core's PUBLIC usage requirements — don't repeat them.
target_link_libraries(dungeon PRIVATE dungeon::game-core)

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
