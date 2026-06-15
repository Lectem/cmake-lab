add_executable(dungeon)
target_sources(dungeon PRIVATE main.cpp)

# Nobody links the executable → PRIVATE. The include path and C++17 arrive
# transitively from game-core's PUBLIC usage requirements — don't repeat them.
target_link_libraries(dungeon PRIVATE dungeon::game-core)
