#include "dungeon/world.hpp"

#include <iostream>
#include <string>

namespace {

constexpr const char* kMap =
    "##########\n"
    "#@...#...#\n"
    "#.##.#.#.#\n"
    "#....#.#.#\n"
    "#.####.#.#\n"
    "#........#\n"
    "##########\n";

void render(const dungeon::World& w) {
    for (int y = 0; y < w.height(); ++y) {
        for (int x = 0; x < w.width(); ++x) {
            const auto p = w.player();
            if (p.x == x && p.y == y) {
                std::cout << '@';
            } else {
                std::cout << static_cast<char>(w.tileAt(x, y));
            }
        }
        std::cout << '\n';
    }
}

} // namespace

int main() {
    auto world = dungeon::World::fromAscii(kMap);

#ifdef DUNGEON_CHEATS
    std::cout << "[cheats] enabled — you can read this build's secrets.\n";
#endif

    std::cout << "Start:\n";
    render(world);

    // Scripted walk for now — real keyboard input arrives with SDL3 in Module 5.
    const std::string script = "ddddsss"; // right x4, down x3
    int moves = 0;
    for (const char c : script) {
        bool moved = false;
        switch (c) {
            case 'd': moved = world.tryMove(1, 0); break;
            case 'a': moved = world.tryMove(-1, 0); break;
            case 'w': moved = world.tryMove(0, -1); break;
            case 's': moved = world.tryMove(0, 1); break;
            default: break;
        }
        if (moved) ++moves;
    }

    std::cout << "\nAfter walking \"" << script << "\":\n";
    render(world);

#ifdef DUNGEON_HUD
    const auto p = world.player();
    std::cout << "\n[HUD] player=(" << p.x << ',' << p.y << ")"
              << " moves=" << moves << " of " << script.size() << " keys\n";
#endif

    return 0;
}
