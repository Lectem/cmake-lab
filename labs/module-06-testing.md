# Lab 6 — Testing with CTest + Catch2 v3 🚩

**Goal:** drive unit tests through **CTest**, pull **Catch2 v3** through the provider you built in
Module 5, and auto-register tests with `catch_discover_tests()`. Mostly CMake — plus *one* assertion you
write.

**Start from:** `git checkout m6-start`

`tests/test_world.cpp` already holds tests against `game-core` (which has no I/O — that's the payoff of
the Module 2 split). The last one ships as a **failing placeholder**. Nothing builds them yet:

```bash
cmake -S project -B project/build
cmake --build project/build --target check     # ❌ "No tests were found"
```

Stuck on any step? The full worked solution is always `git diff m6-start m6-solution`.

---

## 1. Declare Catch2 + enable testing (top-level `CMakeLists.txt`)

Catch2 is a dependency like SDL3 and fmt — declare it in `cmake/Dependencies.cmake` the same way (its
tags are `vX.Y.Z`, so `VERSION 3.5.2` derives the tag for you). Then, **before**
`include(cmake/CaptureTheBuild.cmake)`, enable testing with `include(CTest)` (it calls
`enable_testing()` and adds the `BUILD_TESTING` switch — prefer it over a bare `enable_testing()`) and
`add_subdirectory(tests)`.

> Note there's **no acquisition** in this block — Catch2 arrives the moment `tests/` calls
> `find_package(Catch2)`, exactly like SDL3 and fmt. That's the provider earning its keep.

## 2. Build the test target (`tests/CMakeLists.txt`)

- `find_package(Catch2 CONFIG REQUIRED)` (routed to CPM by the provider),
- build a `game-core-tests` executable from `test_world.cpp`, linked PRIVATE to `dungeon::game-core` and
  Catch2's `Catch2WithMain` target (the variant that provides `main()`),
- auto-register every `TEST_CASE` with CTest via `catch_discover_tests`. That command ships in Catch2's
  *extras*, so you'll need those on the module path first (a CPM source build exposes them under
  `Catch2_SOURCE_DIR`).

## 3. Write your one assertion (`tests/test_world.cpp`)

The last `TEST_CASE("player starts at the @ marker")` is a **failing placeholder**, so the suite is red
and the flag stays locked until you finish it. Build a world whose `@` isn't at the origin, then `CHECK`
that `w.player()` points at it. Look at the neighbouring tests for the `fromAscii` / `player()` API.
This is the *only* C++ you write all course.

## 4. Capture the flag

```bash
rm -rf project/build
cmake -S project -B project/build
cmake --build project/build --target check
```

```
  🚩  flag{green_tests}
```

---

## Explore CTest
```bash
cd project/build
ctest                       # run all
ctest --output-on-failure   # show output for failures
ctest -R wall               # only tests matching "wall"
ctest -j8                   # parallel
ctest --output-junit r.xml  # JUnit XML for CI dashboards
```

**See a red test:** open `libs/game-core/source/world.cpp`, break `tryMove` (e.g. drop the bounds
check), rebuild, `ctest --output-on-failure` → watch it fail, then revert → green.

## Frameworks (the pattern is identical)
- **Catch2 v3** — a real compiled CMake package; `catch_discover_tests` (what we used).
- **doctest** — one header, fastest compile; `doctest_discover_tests`.
- **GoogleTest** — ubiquitous; `gtest_discover_tests`.

The `*_discover_tests` mechanism is the same across all three — learn it once.

✅ Full solution: `git diff m6-start m6-solution`.
