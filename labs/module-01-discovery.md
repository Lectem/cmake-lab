# Lab 1 — Discovery: your first configure & build 🚩

**Goal:** internalize the two-phase model (configure → build) by driving CMake by hand, then
capture your first flag.

**Start from:** `git checkout m1-start`

Stuck on any step? The full worked solution is always `git diff m1-start m1-solution`.

---

## 1. Configure (phase 1: generate a build system)

From the repo root:

```bash
cmake -S project -B project/build
```

- `-S` = source dir (where the top `CMakeLists.txt` lives)
- `-B` = build dir (created if missing — **never** the source dir)

👀 **Look around `project/build/`.** You did not write any of these files. CMake *generated* a
build system (Makefiles or a Ninja file, depending on your default generator). That is the whole
idea: **CMake is a build-system generator, not a build system.**

> Try `cmake -S project -B project/build-ninja -G Ninja` and diff what gets generated.

## 2. Build (phase 2: the generated tool does the work)

```bash
cmake --build project/build
```

`cmake --build` is the portable front-end — it calls `make` / `ninja` / `msbuild` for you, so the
same command works on every machine in the room.

## 3. Capture the flag

```bash
cmake --build project/build --target check
```

You should see the Dungeon banner and:

```
  🚩  flag{hello_cmake}
```

---

## 4. Bonus — bury the first anti-pattern 🪦

Right now nothing stops a colleague from running CMake *inside* `project/`, scattering build files
across the sources. Open `project/CMakeLists.txt`, find the `TODO`, and add an in-source-build guard:
fail with `message(FATAL_ERROR ...)` when `CMAKE_SOURCE_DIR` equals `CMAKE_BINARY_DIR`.

Verify it works (this should now fail fast):

```bash
cd project && cmake .        # expect a FATAL_ERROR — good!
cd .. && rm -rf project/CMakeCache.txt project/CMakeFiles   # clean up the mess it half-made
```

✅ Full solution: `git diff m1-start m1-solution`.
