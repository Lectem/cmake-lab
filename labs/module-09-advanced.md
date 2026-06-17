# Lab 9 — Advanced: shared libs, export macros, baked-in git SHA, LTO 🚩

**Goal:** the production toolkit. Give `game-core` a proper **export macro** so it can ship as a shared
library, **bake the git SHA** into the binary at build time, and turn on **LTO the safe way**. Pure
CMake. Pick at least the SHA (the flag) + one more.

**Start from:** `git checkout m9-start`

Two generated headers are now referenced but unwired, so the build fails twice:

```bash
cmake -S project -B project/build
cmake --build project/build
#  ❌ dungeon/dungeon_api.hpp: No such file   (export header — game-core)
#  ❌ dungeon/version.generated.hpp: No such file   (git SHA — dungeon)
```

Stuck on any step? The full worked solution is always `git diff m9-start m9-solution`.

---

## 1. Export header + visibility (`libs/game-core/CMakeLists.txt`)

`world.hpp` is annotated with `DUNGEON_API`. Generate the header that defines it with
`GenerateExportHeader` — but watch the default macro name, it won't be `DUNGEON_API`, so override it.
Put the generated header on the target's interface (build-vs-install, as in Module 4) and install it.
Then give the shared lib a clean ABI: hide symbols by default with the visibility properties, and handle
the static-build case so the macro expands to nothing.

> Flip to a shared library any time with `-DBUILD_SHARED_LIBS=ON` — same code, and now
> `generate_export_header` earns its keep (dllexport/dllimport on Windows, visibility on ELF).

## 2. Bake the git SHA at build time (top-level `CMakeLists.txt`)

`cmake/GitVersion.cmake` is provided and defines the version-stamping target — just `include()` it.
(It's an always-stale custom target that re-stamps every build, so the SHA stays fresh — unlike
`configure_file()`, which would freeze it at configure time. Peek inside to see it only rewrites the
header when the SHA actually changed.)

## 3. Consume the version header (`apps/dungeon/CMakeLists.txt`)

Add the generated dir to the app's includes, and make the app **depend on** the stamping target so the
header is stamped before `main.cpp` compiles.

## 4. LTO, the safe way (top-level `CMakeLists.txt`, after both subdirectories)

Enable interprocedural optimization, but only after confirming the toolchain supports it with
`check_ipo_supported`, and only for Release. Put it **after** `add_subdirectory(apps/dungeon)` — both
targets must exist first. Never set it globally and unconditionally: not every toolchain supports it, and
a blind global flag breaks the build on the one machine in the room that doesn't.

## 5. Capture the flag

```bash
rm -rf project/build
cmake -S project -B project/build
cmake --build project/build --target check
```

```
  🚩  flag{git_sha_baked_in}
```

Run the game — the window title shows `Dungeon 0.1.0 (<sha>) …`. Commit something, rebuild, watch the
SHA change.

---

## Going shared — see the export surface
```bash
cmake -S project -B project/build-shared -DBUILD_SHARED_LIBS=ON
cmake --build project/build-shared
# Linux:   nm -D --defined-only libgame-core.so | grep Dungeon   → only exported symbols
# Windows: a game-core.dll + import lib; symbols you marked DUNGEON_API
```

## Buried in the graveyard 🪦
- `INTERPROCEDURAL_OPTIMIZATION` ON globally without `check_ipo_supported()`.
- Exporting **all** symbols by default (`WINDOWS_EXPORT_ALL_SYMBOLS`) instead of an explicit macro.
- Stamping version info with `configure_file()` at configure time → a stale SHA forever.

✅ Full solution: `git diff m9-start m9-solution`.
