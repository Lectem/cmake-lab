# game-core unit tests (Module 6).
#
# TODO (lab): turn this into a working Catch2 test target.
#   1. add_executable(game-core-tests test_world.cpp)
#   2. link dungeon::game-core and Catch2::Catch2WithMain (PRIVATE)
#   3. register the tests with catch_discover_tests() so CTest sees each
#      TEST_CASE individually (no stale manual add_test() lists).
#
# See labs/module-06-testing.md. The Catch2 package is fetched by the top-level
# CMakeLists once you wire it there.
