# Lab 5 — Dependencies: SDL3 + fmt the `find_package` way 🚩

**Goal:** turn the console stub into a real **SDL3 window** by declaring your dependencies **once** and
wiring **CPM in as a `find_package` provider**, so consumers ask for packages the vendor-neutral way.
All C++ is provided — this is pure CMake.

**Start from:** `git checkout m5-start` *(the floor moves to 3.25 — the provider hook needs 3.24, `SYSTEM` needs 3.25)*

`apps/dungeon/main.cpp` already uses SDL3 (window + arrow keys) and fmt (the title). The build is
broken — nothing provides those headers yet:

```bash
cmake -S project -B project/build
cmake --build project/build           # ❌ fatal error: SDL3/SDL.h: No such file or directory
```

> First configure builds SDL3 from source — a few minutes, **once**. CPM caches it, so the second
> configure is instant. (Warm the cache before class if your network is slow.)

Stuck on any step? The full worked solution is always `git diff m5-start m5-solution`.

---

## 1. Register the provider before `project()`

A dependency provider can only install itself **before the first `project()` call**. In the top-level
`CMakeLists.txt`, bump the floor to **3.25** (the provider API needs 3.24, and `SYSTEM` in step 2
needs 3.25) and set
`CMAKE_PROJECT_TOP_LEVEL_INCLUDES` to a `cmake/Dependencies.cmake` you'll write next.

## 2. Declare SDL3 + fmt once (`cmake/Dependencies.cmake`)

`cmake/CPM.cmake` is already vendored for you. Create `cmake/Dependencies.cmake` that:
- `include`s the vendored `CPM.cmake`,
- `CPMDeclarePackage`s **SDL3** and **fmt** — pin SDL3 to `release-3.2.4` and fmt to `11.0.2` (fmt also
  wants `FMT_INSTALL` off). Pass **`SYSTEM YES`** on both: their headers then arrive as
  `-isystem`, so their warnings never become yours. Declaring only records the args, nothing is
  fetched yet.
- registers a provider macro with `cmake_language(SET_DEPENDENCY_PROVIDER ...)` so that a
  `find_package()` for a package you declared gets routed to CPM.

> `CPMAddPackage("gh:libsdl-org/SDL#release-3.2.4")` — declare-and-fetch in one line — exists too. It's
> fine for a spike, but it scatters acquisition into every CMakeLists. Declaring once keeps consumers
> clean, which is the point of this module. Note the shorthand quietly implies `SYSTEM YES` and
> `EXCLUDE_FROM_ALL YES`; the keyword form you're writing implies neither, hence the explicit flag.

## 3. Consume them (`apps/dungeon/CMakeLists.txt`)

`find_package(SDL3 CONFIG REQUIRED)` (and the same for fmt), then link `SDL3::SDL3` and `fmt::fmt`
PRIVATE to `dungeon` — namespaced, like every link since Module 2. A bare `SDL3`, or a `find_package`
missing `CONFIG`/`REQUIRED`, fails the flag on purpose.

## 4. Capture the flag

```bash
cmake -S project -B project/build
cmake --build project/build --target check
```

```
  🚩  flag{find_package_the_right_way}
```

Then build and run — a window opens, arrow keys move the coral square:

```bash
cmake --build project/build
./project/build/apps/dungeon/dungeon        # dungeon.exe on Windows
```

---

## Think about it
- Why `PRIVATE`? Nobody links `dungeon` — SDL3 and fmt are implementation details of the app, not part
  of any public interface. (Contrast: `game-core`'s C++17 was `PUBLIC`.)
- The consumer line `find_package(SDL3 CONFIG REQUIRED)` is identical under vcpkg or Conan — only
  `Dependencies.cmake` changes. That's the payoff of routing acquisition through the provider.
- Staying on CMake 3.22? Skip the provider, `CPMAddPackage` directly in `Dependencies.cmake`, and link
  the targets. `find_package`-everywhere is one honest option, not a mandate. Keep `SYSTEM YES` either
  way — CPM ignores it below 3.25, so it costs nothing and starts working the day you upgrade.

✅ Full solution: `git diff m5-start m5-solution`.
