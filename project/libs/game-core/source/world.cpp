#include "dungeon/world.hpp"

#include <algorithm>

namespace dungeon {

World World::fromAscii(const char* map) {
    World w;

    // First pass: measure the grid without copying the map.
    int cols = 0;
    for (const char* p = map; *p; ++p) {
        if (*p == '\n') {
            w.width_ = std::max(w.width_, cols);
            ++w.height_;
            cols = 0;
        } else {
            ++cols;
        }
    }
    if (cols > 0) { // last line may have no trailing '\n'
        w.width_ = std::max(w.width_, cols);
        ++w.height_;
    }

    w.tiles_.assign(static_cast<std::size_t>(w.width_) * w.height_, Tile::Floor);

    // Second pass: place walls and the player.
    int x = 0;
    int y = 0;
    for (const char* p = map; *p; ++p) {
        if (*p == '\n') {
            ++y;
            x = 0;
            continue;
        }
        if (*p == '#') {
            w.tiles_[static_cast<std::size_t>(y) * w.width_ + x] = Tile::Wall;
        } else if (*p == '@') {
            w.player_ = {x, y};
        }
        ++x;
    }
    return w;
}

bool World::inBounds(int x, int y) const {
    return x >= 0 && y >= 0 && x < width_ && y < height_;
}

Tile World::tileAt(int x, int y) const {
    if (!inBounds(x, y)) return Tile::Wall;
    return tiles_[static_cast<std::size_t>(y) * width_ + x];
}

bool World::tryMove(int dx, int dy) {
    const int nx = player_.x + dx;
    const int ny = player_.y + dy;
    if (!inBounds(nx, ny) || tileAt(nx, ny) == Tile::Wall) {
        return false;
    }
    player_ = {nx, ny};
    return true;
}

} // namespace dungeon
