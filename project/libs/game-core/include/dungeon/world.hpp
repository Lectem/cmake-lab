#pragma once
#include <vector>

namespace dungeon {

struct Vec2 {
    int x = 0;
    int y = 0;
};

enum class Tile : char { Floor = '.', Wall = '#' };

// A tiny grid world with a single player. Pure logic, no I/O — which is exactly
// what makes it trivial to unit-test later (Module 6). Keep it that way.
class World {
public:
    // Build a world from an ASCII map: '#' = wall, '.' = floor, '@' = player start.
    // Takes a raw C-string — no allocation or copy of the map itself.
    static World fromAscii(const char* map);

    int width() const { return width_; }
    int height() const { return height_; }
    Vec2 player() const { return player_; }
    Tile tileAt(int x, int y) const;

    // Move the player by (dx, dy). Returns false (and does not move) if blocked
    // by a wall or the world edge.
    bool tryMove(int dx, int dy);

private:
    bool inBounds(int x, int y) const;

    int width_ = 0;
    int height_ = 0;
    std::vector<Tile> tiles_;
    Vec2 player_;
};

} // namespace dungeon
