# CMake — 2-Day Intensive

The course project: **`Dungeon`**, a small SDL3 game you grow across ten modules to learn modern,
target-based CMake. Each module has a hands-on lab in `labs/`; the project itself lives in `project/`
and evolves tag by tag.

## Repository layout

```
.
├─ labs/                  # your lab handout, one per module
└─ project/               # the Dungeon project, evolves through the modules (see Checkpoints)
```

## Checkpoints: how the project evolves (git tags)

The `project/` tree is the *same* project growing module by module. Each module has two tagged
states on a single linear history:

| Tag           | State                                                              | Built? |
|---------------|-------------------------------------------------------------------|--------|
| `m1-start`    | Hello-world skeleton with one TODO                                | ✅     |
| `m1-solution` | Out-of-source build + in-source guard + first flag                | ✅     |
| `m2-start`    | A **monolithic** game (single target), ready to refactor          | ✅     |
| `m2-solution` | Split into `game-core` lib + `dungeon` exe, correct transitivity  | ✅     |
| `m3-start`    | Global `-O2` to bury; HUD/cheats macros awaiting CMake wiring      | ✅     |
| `m3-solution` | `option()` + config-gated HUD via generator expression            | ✅     |
| `m4-start`    | No install rules yet                                              | ✅     |
| `m4-solution` | `install`/export (`find_package`-able) + CPack; BUILD/INSTALL_INTERFACE | ✅ |
| `m5-start`    | App uses SDL3 + fmt, deps not fetched/linked yet                  | ✅     |
| `m5-solution` | SDL3 + fmt via CPM, namespaced `SDL3::SDL3` / `fmt::fmt` linkage  | ✅     |
| `m6-start`    | `game-core` unit tests present; CTest/Catch2 not wired           | ✅     |
| `m6-solution` | Catch2 v3 via CPM + `catch_discover_tests`; green suite          | ✅     |
| `m7-start`    | App needs a generated level header; host tool unwired            | ✅     |
| `m7-solution` | Host-tool codegen (cross-safe) + a hand-written toolchain file   | ✅     |
| `m8-start`    | No presets, no ASan toolchain, no compile DB                     | ✅     |
| `m8-solution` | ASan toolchain file + `CMakePresets.json` + `compile_commands`   | ✅     |
| `m9-start`    | Export macro + git-SHA headers referenced but unwired            | ✅     |
| `m9-solution` | `generate_export_header` + visibility, git-SHA codegen, checked LTO | ✅  |
| `m10-start`   | Complete project + cumulative grand-finale `check`               | ✅     |
| `m10-solution`| + ccache/sccache launcher; à-la-carte bonus reference            | ✅     |

**Workflow**
- Start a module: `git checkout m2-start`
- Stuck or fell behind: jump to the next module's start tag and you're instantly back in sync.
- See the lesson as a diff: `git diff m2-start m2-solution`

**The "Capture the Build" 🚩 mechanic:** each `*-solution` makes a `check` target succeed and print
a flag (e.g. `flag{transitive_propagation_unlocked}`). Build it with:

```bash
cmake -S project -B project/build
cmake --build project/build --target check
```

## Prerequisites (light, no SDK installs)

- **CMake ≥ 3.25** (`cmake --version`)
- A C++17 compiler: MSVC 2019+ (Windows) or GCC ≥ 9 / Clang ≥ 10 (Linux)
- **Ninja** (single binary) and **Git**
- An IDE with CMake support (VS Code + CMake Tools, Visual Studio, or CLion)
- **No package manager and no emscripten to install.** Dependencies (SDL3, fmt, Catch2) are fetched
  via CPM on first configure; the WebAssembly demo is instructor-led.
- *Linux only:* X11/Wayland dev headers for SDL3's video backend (or use the provided devcontainer).

The first configure builds SDL3 from source (a few minutes); CPM caches it for later builds.
