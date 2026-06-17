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

# --- Module 9: export macro + visibility ---------------------------------
# Generate DUNGEON_API (used in world.hpp). It expands to dllexport/dllimport
# when shared, nothing when static. Hide everything else for a clean ABI.
include(GenerateExportHeader)
generate_export_header(game-core
    BASE_NAME DUNGEON
    EXPORT_MACRO_NAME DUNGEON_API
    EXPORT_FILE_NAME ${CMAKE_CURRENT_BINARY_DIR}/exports/dungeon/dungeon_api.hpp)
target_include_directories(game-core PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/exports>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/exports/dungeon/dungeon_api.hpp
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/dungeon)

set_target_properties(game-core PROPERTIES
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN ON)

# Static build → DUNGEON_API must be empty; define the static flag (PUBLIC so
# consumers compiling against the static lib see it too).
get_target_property(_gc_type game-core TYPE)
if(_gc_type STREQUAL "STATIC_LIBRARY")
    target_compile_definitions(game-core PUBLIC DUNGEON_STATIC_DEFINE)
endif()
# (LTO is enabled at the top level, once both targets exist — see CMakeLists.txt.)

# Make game-core installable & exportable. EXPORT records the target (with its
# usage requirements) into an export set we ship from the top-level CMakeLists.
install(TARGETS game-core EXPORT DungeonTargets
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
