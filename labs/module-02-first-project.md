# Lab 2 — First project: split into a library 🚩

**Goal:** turn a monolithic executable into a reusable `game-core` **library** + a `dungeon`
**executable**, and let C++17 and the include path travel **transitively**.

**Start from:** `git checkout m2-start`

You inherit a single-target project:

```
project/
├─ CMakeLists.txt          # one add_executable(dungeon) with everything
├─ cmake/CaptureTheBuild.cmake
└─ src/{world.hpp, world.cpp, main.cpp}
```

Build it and watch the verifier say *"not yet"*:

```bash
cmake -S project -B project/build && cmake --build project/build --target check
```

Stuck on any step? The full worked solution is always `git diff m2-start m2-solution`.

---

## 1. Reorganize into a pitchfork layout

Target layout:

```
libs/game-core/
├─ include/dungeon/world.hpp     # public header (note the dungeon/ prefix)
├─ source/world.cpp
└─ CMakeLists.txt                # you write this (step 2)
apps/dungeon/
├─ main.cpp
└─ CMakeLists.txt                # you write this (step 3)
```

**Move the 3 files — copy-paste this, no need to do it by hand:**

```bash
cd project
mkdir -p libs/game-core/include/dungeon libs/game-core/source apps/dungeon
git mv src/world.hpp libs/game-core/include/dungeon/world.hpp
git mv src/world.cpp libs/game-core/source/world.cpp
git mv src/main.cpp  apps/dungeon/main.cpp
rmdir src
cd ..
```

Then change `#include "world.hpp"` to `#include "dungeon/world.hpp"` in **both** `world.cpp` and
`main.cpp`. That `dungeon/` prefix makes the public API unambiguous for consumers — it's the path your
library will expose in step 2.

## 2. Declare the library (`libs/game-core/CMakeLists.txt`)

Write the listfile that:
- declares the library with `add_library(game-core)` and adds an `add_library(... ALIAS ...)` under the
  `dungeon::` namespace (a habit that pays off in Module 5),
- attaches `source/world.cpp` with `target_sources` (PRIVATE — sources are never usage requirements),
- exposes the `include/` dir and the `cxx_std_17` feature. Both must reach consumers, so think about
  which keyword (`PRIVATE` / `PUBLIC` / `INTERFACE`) lets a usage requirement **propagate**.

## 3. Declare the app (`apps/dungeon/CMakeLists.txt`)

`add_executable(dungeon)` + its `main.cpp`, then `target_link_libraries` it to `dungeon::game-core`.
Nobody links the executable, so pick the keyword accordingly — and don't repeat the include dir or
C++17, they arrive transitively from the library.

## 4. Wire them in the top-level `CMakeLists.txt`

Replace the single `add_executable(...)` block with two `add_subdirectory(...)` calls. **Order matters:**
a target must exist before another can link it, so the library comes first.

## 5. Capture the flag

```bash
rm -rf project/build         # topology changed; reconfigure cleanly
cmake -S project -B project/build
cmake --build project/build --target check
```

```
  🚩  flag{transitive_propagation_unlocked}
```

---

## Think about it
- Why does dropping the `PUBLIC` on the library's include dir break the **app** but not the **library**?
  (Usage requirements only propagate with `PUBLIC`/`INTERFACE`.)
- What breaks if you mark `world.cpp` `PUBLIC` instead of `PRIVATE`? (Sources aren't usage requirements
  — keep them `PRIVATE`.)

✅ Full solution: `git diff m2-start m2-solution`.
