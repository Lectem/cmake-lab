# Lab 8 — Tooling & Presets: sanitizers in one command 🚩

**Goal:** export `compile_commands.json`, and make an **ASan/UBSan build a one-command preset** — with
the sanitizer flags living in a **toolchain file**, not in your `CMakeLists.txt` and not in global
`CMAKE_CXX_FLAGS`. Pure CMake + JSON.

**Start from:** `git checkout m8-start`

```bash
cmake -S project -B project/build && cmake --build project/build --target check   # ❌ nothing wired
```

> **Why a toolchain + preset (and not an interface "sanitizer" target)?** Sanitizers are a property of
> *how you build*, not of *what the project is*. Keeping them in a toolchain file (Module 7) selected by
> a preset (Module 8) leaves the project listfiles clean and makes the build reproducible in one command.
> Setting `CMAKE_CXX_FLAGS` directly would be the global-flags anti-pattern we buried in Module 3.

Stuck on any step? The full worked solution is always `git diff m8-start m8-solution`.

---

## 1. Export the compile database (configure time, not a listfile)

`compile_commands.json` is the universal key for clang-tidy, clangd, and IDEs. But it describes *how you
build*, not *what the project is*, so it's a per-developer, configure-time choice. Enable it on the
command line — **never** with `set(CMAKE_EXPORT_COMPILE_COMMANDS ON)` in a listfile (that would also
override a consumer who passes `-D...=OFF`):

```bash
cmake -B build . -DCMAKE_EXPORT_COMPILE_COMMANDS=ON    # build/compile_commands.json appears
```

We carry it in the preset instead (§3), so every config gets it without touching `CMakeLists.txt`.

## 2. A sanitizer toolchain file (`cmake/toolchains/asan.cmake`, new file)

Toolchain files seed initial flags through the **`_INIT`** flag variables — the blessed way to set
starting compiler/linker flags that the user can still override (versus hard-coding into the build). Put
`-fsanitize=address,undefined -fno-omit-frame-pointer` on the compiler `*_FLAGS_INIT` variables and the
sanitizer on the linker ones. (The MSVC equivalent, `/fsanitize=address`, would live in its own
toolchain.)

## 3. A preset that selects it (`CMakePresets.json`, project root, new file)

Author a `CMakePresets.json` (schema `version` 3) with a `configurePresets` entry that:
- sets `toolchainFile` to your `cmake/toolchains/asan.cmake`,
- sets `binaryDir`, `generator` (Ninja), and `CMAKE_BUILD_TYPE` Debug under `cacheVariables`,
- also carries `CMAKE_EXPORT_COMPILE_COMMANDS: ON` in `cacheVariables` (that's how §1 gets satisfied
  without a `-D`),
- optionally guards on host with a `condition`.

Add matching `buildPresets` / `testPresets`. The whole sanitized build is then one command:
`cmake --preset linux-debug-asan`.

## 4. Capture the flag

Enable the compile DB at configure time (§1) — never with `set()` in the listfile:

```bash
cmake -S project -B project/build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build project/build --target check
```

```
  🚩  flag{asan_caught_me}
```

> The §3 preset carries `CMAKE_EXPORT_COMPILE_COMMANDS` too, so `cmake --preset linux-debug-asan` gets
> the same compile DB without the `-D`. Either way it's config, not a listfile edit.

---

## See ASan actually catch a bug
Introduce a one-line off-by-one in `libs/game-core/source/world.cpp` (e.g. in `tileAt`, let
`x == width_` slip past the bounds check), then build the test suite under the preset:

```bash
cmake --preset linux-debug-asan
cmake --build build/linux-debug-asan --target game-core-tests
ctest --preset linux-debug-asan          # ASan prints the exact file:line of the overflow
```

Revert the bug → green again. **That** is `flag{asan_caught_me}`: the sanitizer pinpointing a bug a
normal build silently tolerated — reproduced by a teammate in one `--preset`.

## Buried in the graveyard 🪦
- Documenting build steps in a README instead of encoding them in presets.
- Sanitizer flags via global `CMAKE_CXX_FLAGS` (or buried in a listfile) instead of a toolchain + preset.
- Committing IDE-specific build files — `compile_commands.json` is generated, not checked in.

✅ Full solution: `git diff m8-start m8-solution`.
