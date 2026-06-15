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
    std::cout << "Start:\n";
    render(world);

    // Scripted walk for now — real keyboard input arrives with SDL3 in Module 5.
    const std::string script = "ddddsss"; // right x4, down x3
    for (const char c : script) {
        switch (c) {
            case 'd': world.tryMove(1, 0); break;
            case 'a': world.tryMove(-1, 0); break;
            case 'w': world.tryMove(0, -1); break;
            case 's': world.tryMove(0, 1); break;
            default: break;
        }
    }

    std::cout << "\nAfter walking \"" << script << "\":\n";
    render(world);
    return 0;
}
