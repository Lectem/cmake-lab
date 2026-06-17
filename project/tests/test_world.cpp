// Unit tests for game-core. This is why we split the logic out in Module 2:
// World has zero I/O, so testing it needs no SDL, no window — just the library.
//
// PROVIDED — except the last test, which is yours to finish (Module 6 lab).

#include <catch2/catch_test_macros.hpp>

#include "dungeon/world.hpp"

using dungeon::Tile;
using dungeon::World;

namespace {
constexpr const char* kTiny =
    "#####\n"
    "#@..#\n"
    "#.#.#\n"
    "#...#\n"
    "#####\n";
}

TEST_CASE("fromAscii measures the grid") {
    const World w = World::fromAscii(kTiny);
    CHECK(w.width()  == 5);
    CHECK(w.height() == 5);
}

TEST_CASE("walls block movement") {
    World w = World::fromAscii(kTiny);
    // Player starts at (1,1); a wall sits directly above and to the left.
    CHECK_FALSE(w.tryMove(0, -1)); // into the top wall
    CHECK_FALSE(w.tryMove(-1, 0)); // into the left wall
}

TEST_CASE("floor lets the player through") {
    World w = World::fromAscii(kTiny);
    REQUIRE(w.tryMove(1, 0));      // step right onto floor
    CHECK(w.player().x == 2);
    CHECK(w.player().y == 1);
}

TEST_CASE("out-of-bounds moves are rejected") {
    World w = World::fromAscii("@");  // a 1x1 world
    CHECK_FALSE(w.tryMove(1, 0));
    CHECK_FALSE(w.tryMove(0, 1));
}

TEST_CASE("player starts at the @ marker") {
    // TODO (Module 6 lab -- your one assertion):
    //   Build a world whose '@' is NOT at the origin (see World::fromAscii in the
    //   tests above), then CHECK that w.player() reports its row/column.
    //   Replace the FAIL below once your assertion is in place.
    FAIL("write the assertion for this test -- see labs/module-06-testing.md");
}
