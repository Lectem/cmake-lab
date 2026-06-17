// The Dungeon app. From Module 5 on, this is a real SDL3 window: it opens a
// window, draws the grid, and moves the player with the arrow keys / WASD.
//
// PROVIDED — you never edit this file in the labs. The whole game is wired
// through CMake: your job is to make `SDL3::SDL3` and `fmt::fmt` available to
// this translation unit. Until you do (Module 5 lab), this will not compile.
//
// It uses SDL3's "main callbacks" model (SDL_MAIN_USE_CALLBACKS). That keeps
// the same source running natively AND in the browser (Module 7) — no manual
// emscripten main-loop plumbing.

#define SDL_MAIN_USE_CALLBACKS
#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>

#include <fmt/core.h>

#include "dungeon/world.hpp"

// Generated at build time by the levelpack host tool (Module 7). It defines
// dungeon::kIntroLevel. Until you wire the codegen step, this header is missing
// and the app won't compile.
#include "dungeon/levels.generated.hpp"

namespace {

constexpr int kCell = 48; // pixels per tile

struct App {
    SDL_Window*   window   = nullptr;
    SDL_Renderer* renderer = nullptr;
    dungeon::World world   = dungeon::World::fromAscii(dungeon::kIntroLevel);
};

} // namespace

SDL_AppResult SDL_AppInit(void** appstate, int /*argc*/, char** /*argv*/) {
    if (!SDL_Init(SDL_INIT_VIDEO)) {
        SDL_Log("SDL_Init failed: %s", SDL_GetError());
        return SDL_APP_FAILURE;
    }

    auto* app = new App{};
    *appstate = app;

    const int w = app->world.width()  * kCell;
    const int h = app->world.height() * kCell;

    // fmt builds the title string — our first taste of a fetched dependency.
    const std::string title = fmt::format("Dungeon — {}x{}", app->world.width(), app->world.height());

    if (!SDL_CreateWindowAndRenderer(title.c_str(), w, h, 0, &app->window, &app->renderer)) {
        SDL_Log("CreateWindowAndRenderer failed: %s", SDL_GetError());
        return SDL_APP_FAILURE;
    }

    fmt::print("Dungeon is running. Arrow keys / WASD to move, Esc to quit.\n");
    return SDL_APP_CONTINUE;
}

SDL_AppResult SDL_AppEvent(void* appstate, SDL_Event* event) {
    auto* app = static_cast<App*>(appstate);

    if (event->type == SDL_EVENT_QUIT) {
        return SDL_APP_SUCCESS;
    }
    if (event->type == SDL_EVENT_KEY_DOWN) {
        switch (event->key.scancode) {
            case SDL_SCANCODE_ESCAPE: return SDL_APP_SUCCESS;
            case SDL_SCANCODE_UP:    case SDL_SCANCODE_W: app->world.tryMove(0, -1); break;
            case SDL_SCANCODE_DOWN:  case SDL_SCANCODE_S: app->world.tryMove(0,  1); break;
            case SDL_SCANCODE_LEFT:  case SDL_SCANCODE_A: app->world.tryMove(-1, 0); break;
            case SDL_SCANCODE_RIGHT: case SDL_SCANCODE_D: app->world.tryMove( 1, 0); break;
            default: break;
        }
    }
    return SDL_APP_CONTINUE;
}

SDL_AppResult SDL_AppIterate(void* appstate) {
    auto* app = static_cast<App*>(appstate);

    SDL_SetRenderDrawColor(app->renderer, 12, 16, 35, 255); // Sparks navy backdrop
    SDL_RenderClear(app->renderer);

    for (int y = 0; y < app->world.height(); ++y) {
        for (int x = 0; x < app->world.width(); ++x) {
            const bool wall = app->world.tileAt(x, y) == dungeon::Tile::Wall;
            if (wall) {
                SDL_SetRenderDrawColor(app->renderer, 40, 54, 84, 255);
                SDL_FRect r{float(x * kCell), float(y * kCell), float(kCell - 1), float(kCell - 1)};
                SDL_RenderFillRect(app->renderer, &r);
            }
        }
    }

    const auto p = app->world.player();
    SDL_SetRenderDrawColor(app->renderer, 242, 107, 67, 255); // coral player
    SDL_FRect pr{float(p.x * kCell + 6), float(p.y * kCell + 6), float(kCell - 13), float(kCell - 13)};
    SDL_RenderFillRect(app->renderer, &pr);

    SDL_RenderPresent(app->renderer);
    return SDL_APP_CONTINUE;
}

void SDL_AppQuit(void* appstate, SDL_AppResult /*result*/) {
    delete static_cast<App*>(appstate);
}
