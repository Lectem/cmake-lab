add_library(game-core)
add_library(dungeon::game-core ALIAS game-core)   # namespaced alias — habit for Module 5

target_sources(game-core PRIVATE source/world.cpp include/dungeon/world.hpp)

include(GNUInstallDirs)

# Consumers #include "dungeon/world.hpp", so the include/ dir must PROPAGATE → PUBLIC.
# But the path DIFFERS between the build tree and an installed package, so we use
# the two interface generator expressions (required to export this target):
#   BUILD_INTERFACE   → used while building/consuming from this build tree
#   INSTALL_INTERFACE → used by downstream after `find_package(Dungeon)`
target_include_directories(game-core PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)

# The public header is C++17 → PUBLIC so consumers inherit the requirement.
target_compile_features(game-core PUBLIC cxx_std_17)

# Make game-core installable & exportable. EXPORT records the target (with its
# usage requirements) into an export set we ship from the top-level CMakeLists.
install(TARGETS game-core EXPORT DungeonTargets
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
