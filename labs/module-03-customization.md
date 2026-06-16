# Lab 3 — Customisation: options & generator expressions 🚩

**Goal:** make the project configurable *correctly* — kill a global-flag anti-pattern, add an opt-in
feature, and add a Debug-only HUD that survives multi-config generators.

**Start from:** `git checkout m3-start`

The app (`apps/dungeon/main.cpp`) already has the code behind two macros:

```cpp
#ifdef DUNGEON_CHEATS  ... #endif      // a cheat banner
#ifdef DUNGEON_HUD     ... #endif      // [HUD] player coords + move count
```

Your job is to *wire those macros* through CMake — without sinning. Build first and read the
verifier's complaint:

```bash
cmake -S project -B project/build && cmake --build project/build --target check
```

Stuck on any step? The full worked solution is always `git diff m3-start m3-solution`.

---

## (a) Bury the global-flag anti-pattern 🪦

Open `project/CMakeLists.txt` and delete the `set(CMAKE_CXX_FLAGS "-O2")` line.

**Why:** it clobbers every config — your Debug build is now optimized (unsteppable), and you've
overridden whatever the user or a package maintainer chose. **Never set optimization in
`CMAKE_CXX_FLAGS` / `CMAKE_CXX_FLAGS_<CONFIG>`.** The *configuration type* owns that.

## (b) Add an opt-in feature (optional stays optional)

Declare a project `option(...)` (default **OFF**) for the cheats, then in `apps/dungeon/CMakeLists.txt`
define the `DUNGEON_CHEATS` macro **only when it's on** via `target_compile_definitions`.

> A configure-time `if()` is fine here: an *option* is known at configure time. Config type is **not** —
> which is exactly why (c) needs a generator expression.

## (c) Debug-only HUD via a generator expression

Still in `apps/dungeon/CMakeLists.txt`, define `DUNGEON_HUD` only for the Debug config — using a
generator expression that tests `$<CONFIG:Debug>`, not a plain `if()`.

**Why not `if(CMAKE_BUILD_TYPE STREQUAL "Debug")`?** Under Visual Studio / Xcode / Ninja Multi-Config the
config is chosen at *build* time, so `CMAKE_BUILD_TYPE` is empty at configure time and the `if` silently
does nothing. A generator expression is evaluated per-config at build time — correct everywhere.

## Capture the flag

```bash
rm -rf project/build
cmake -S project -B project/build
cmake --build project/build --target check          # 🚩 flag{options_stay_optional}
```

---

## See it actually work
```bash
# HUD appears only in Debug:
cmake -S project -B project/build-dbg -DCMAKE_BUILD_TYPE=Debug
cmake --build project/build-dbg && ./project/build-dbg/apps/dungeon/dungeon   # [HUD] line shows

# Cheats are opt-in (use the option name you declared in (b)):
cmake -S project -B project/build-cheat -DDUNGEON_ENABLE_CHEATS=ON
cmake --build project/build-cheat && ./project/build-cheat/apps/dungeon/dungeon  # [cheats] line shows
```

✅ Full solution: `git diff m3-start m3-solution`.
