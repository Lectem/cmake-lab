add_library(game-core)
add_library(dungeon::game-core ALIAS game-core)   # namespaced alias — habit for Module 5

target_sources(game-core PRIVATE source/world.cpp include/dungeon/world.hpp)

# Consumers #include "dungeon/world.hpp", so the include/ dir must PROPAGATE → PUBLIC.
# The .cpp needs nothing extra, so no PRIVATE include dir here.
target_include_directories(game-core PUBLIC include)

# The public header is C++17 → PUBLIC so consumers inherit the requirement.
target_compile_features(game-core PUBLIC cxx_std_17)
