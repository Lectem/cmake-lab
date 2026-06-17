# Lab 10 — Bonus, buffer & the final flag 🏆

**Goal:** the victory lap. Run the whole pipeline end to end for the **final flag**, then explore the
à-la-carte bonus topics as time and curiosity allow. ~à-la-carte.

**Start from:** `git checkout m10-start` (it's the complete project from Module 9 + the grand-finale check)

---

## Capture the final flag

The finale `check` runs everything you built across two days — tests, install/export, and the git-SHA
stamp — and only then awards the trophy:

```bash
cmake -S project -B project/build
cmake --build project/build --target check
```

```
  🏆  All ten flags captured.
  🚩  flag{capture_the_build_complete}
```

---

## À-la-carte — pick what interests the room

### ccache / sccache — dramatic rebuild speedups
A compiler launcher caches object files; a clean rebuild becomes near-instant. Guarded so it's a no-op
when the tool isn't installed (top-level `CMakeLists.txt`):

```cmake
option(DUNGEON_USE_CCACHE "Use ccache/sccache if available" ON)
if(DUNGEON_USE_CCACHE)
    find_program(CCACHE_PROGRAM NAMES ccache sccache)
    if(CCACHE_PROGRAM)
        set(CMAKE_CXX_COMPILER_LAUNCHER ${CCACHE_PROGRAM})
        set(CMAKE_C_COMPILER_LAUNCHER   ${CCACHE_PROGRAM})
    endif()
endif()
```

Time it: `cmake --build build` (cold) → `rm -rf build && cmake … && cmake --build build` (warm cache).

### CMake policies — closing the version-range loop
Remember `cmake_minimum_required(VERSION 3.22...3.28)` from Day 1? The upper bound sets *policy*
defaults. Inspect and pin one explicitly:

```cmake
cmake_policy(GET CMP0077 _p)        # e.g. option() honoring normal variables
message(STATUS "CMP0077 = ${_p}")
```

### Android NDK — Module 7's mental model, reused
The NDK ships a toolchain file. Nothing new to learn:

```bash
cmake -S project -B build-android \
  --toolchain $ANDROID_NDK/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=arm64-v8a -DANDROID_PLATFORM=android-24
```

### Build-time profiling — where do the seconds go?
```bash
# Clang: per-TU time traces → load in chrome://tracing or ClangBuildAnalyzer
cmake -S project -B build-trace -DCMAKE_CXX_FLAGS="-ftime-trace"
# Configure-time profiling:
cmake -S project -B build --profiling-output=cfg.json --profiling-format=google-trace
```

---

## What to delete from your real CMakeLists on Monday
`file(GLOB)` source lists · `include_directories()` / `link_directories()` · `set(CMAKE_CXX_FLAGS …)` ·
naked `target_link_libraries(app lib)` without a keyword · `set(CMAKE_CXX_STANDARD)` sprinkled around ·
documented build steps that should be a preset.

✅ Full solution: `git diff m10-start m10-solution`.
