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

# Build-time code generation (Module 7): the levelpack HOST tool packs
# levels/intro.txt into a header before main.cpp compiles. Listing `levelpack`
# in DEPENDS makes CMake build it for the host and run it first — exactly what
# lets the game cross-compile while the tool stays a host artifact.
set(_gen ${CMAKE_CURRENT_BINARY_DIR}/generated/dungeon/levels.generated.hpp)
add_custom_command(
    OUTPUT  ${_gen}
    COMMAND levelpack ${CMAKE_SOURCE_DIR}/levels/intro.txt ${_gen}
    DEPENDS levelpack ${CMAKE_SOURCE_DIR}/levels/intro.txt
    COMMENT "Packing levels with the host tool"
    VERBATIM)
target_sources(dungeon PRIVATE ${_gen})
target_include_directories(dungeon PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/generated)

# Build-time git SHA (Module 9): see version.generated.hpp, stamped by the
# dungeon-version target. Depend on it so the header exists before we compile.
target_include_directories(dungeon PRIVATE ${DUNGEON_VERSION_INCLUDE_DIR})
add_dependencies(dungeon dungeon-version)

# Install the executable into the platform's bin/ dir.
include(GNUInstallDirs)
install(TARGETS dungeon RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

# Emscripten (WebAssembly): the .html suffix makes emcc emit the HTML glue
# automatically; SINGLE_FILE inlines JS + WASM so the result opens from file://.
if(EMSCRIPTEN)
    set_target_properties(dungeon PROPERTIES SUFFIX ".html")
    target_link_options(dungeon PRIVATE -sSINGLE_FILE=1)
endif()
