# game-core unit tests (Module 6).

# Catch2 the vendor-neutral way. The provider (cmake/Dependencies.cmake) maps
# this find_package onto CPM, same as SDL3 and fmt in the app.
find_package(Catch2 CONFIG REQUIRED)

add_executable(game-core-tests test_world.cpp)
target_link_libraries(game-core-tests PRIVATE
    dungeon::game-core
    Catch2::Catch2WithMain)          # the WithMain variant provides main()

# catch_discover_tests lives in Catch2's "extras". A source build (CPM) exposes
# it under Catch2_SOURCE_DIR; an installed Catch2 already puts it on the module
# path. Cover both, then register every TEST_CASE with CTest (no stale add_test).
if(DEFINED Catch2_SOURCE_DIR)
    list(APPEND CMAKE_MODULE_PATH ${Catch2_SOURCE_DIR}/extras)
endif()
include(Catch)
catch_discover_tests(game-core-tests)
