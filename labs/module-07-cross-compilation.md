# Lab 7 — Cross-compilation: toolchains + the host-tool trap 🚩

**Goal:** make a **host build tool** generate a source file the game consumes, and **author your own
toolchain file**. These are the two skills that make cross-compiling (the browser demo!) actually work.
Pure CMake.

**Start from:** `git checkout m7-start`

The app now reads its level from a *generated* header, `dungeon/levels.generated.hpp`, produced by the
`levelpack` host tool from `levels/intro.txt`. Nothing generates it yet:

```bash
cmake -B project/build project
cmake --build project/build       # ❌ fatal error: dungeon/levels.generated.hpp: No such file
```

Stuck on any step? The full worked solution is always `git diff m7-start m7-solution`.

---

## 1. Wire the codegen (`apps/dungeon/CMakeLists.txt`)

Produce the header at build time with `add_custom_command`: run `levelpack` on `levels/intro.txt` to
emit the generated header. List `levelpack` itself in the command's `DEPENDS` (that's the crux — it's
what makes CMake build the tool and run it before compiling). Then pull the generated file into the
build graph with `target_sources` and add its dir to the app's includes.

The key idea: `levelpack` in `DEPENDS` makes CMake build the tool and run it *before* compiling
`main.cpp`. That works natively. But cross-compile the game to WebAssembly and `levelpack` would be
built for WASM too — and you can never *run* a `.wasm` mid-build. So the tool needs a **host** build,
which is the next step.

## 2. Resolve the host tool the cross-safe way (`cmake/HostTool.cmake`, you write it)

A tool you run at build time must be built **for the host**, never the target. A naive
`add_subdirectory(tools/levelpack)` works natively but breaks the moment you cross-compile, where it
would be built with the cross toolchain and couldn't execute on your host.

Write `cmake/HostTool.cmake` that branches on `CMAKE_CROSSCOMPILING`:
- **native** (the common case): the host *is* the target, so just `add_subdirectory(tools/levelpack)`,
- **cross**: you can't build it here — import a host-built one instead. That branch is fiddly, so here
  it is to drop straight into the `if`:

```cmake
    # find_program already appends the host .exe suffix, so NAMES levelpack is enough. It won't
    # validate a path passed via -D, so check EXISTS and fail early with a recipe.
    find_program(LEVELPACK_EXECUTABLE NAMES levelpack
        DOC "Host-built levelpack, used during cross compilation")
    if(NOT LEVELPACK_EXECUTABLE OR NOT EXISTS "${LEVELPACK_EXECUTABLE}")
        message(FATAL_ERROR
            "No host levelpack at '${LEVELPACK_EXECUTABLE}'. Build JUST the tool natively first\n"
            "  (configuring the tool alone avoids fetching SDL3/fmt):\n"
            "    cmake -B build-host project/tools/levelpack\n"
            "    cmake --build build-host\n"
            "  then point the cross build at it: -DLEVELPACK_EXECUTABLE=<build-host>/levelpack")
    endif()
    add_executable(levelpack IMPORTED GLOBAL)
    set_target_properties(levelpack PROPERTIES IMPORTED_LOCATION "${LEVELPACK_EXECUTABLE}")
```

Either branch leaves one target named `levelpack`, so the rest of the build doesn't care which ran.
Then `include(cmake/HostTool.cmake)` in the top-level `CMakeLists.txt`, **before**
`add_subdirectory(apps/dungeon)` (the `levelpack` target must exist before the §1 codegen depends on
it). The concept — *build the tool for the host, import it when crossing* — is the lesson; the cross
branch above is just the fiddly bit. (Heavier alternatives: a superbuild via `ExternalProject` in a host
context, or finding a prebuilt one.)

## 3. Author a toolchain file (`cmake/toolchains/practice.cmake`, new file)

A toolchain file answers *"what compiler / target / sysroot?"* **before** `project()`. Write a minimal
one — it doesn't need a real cross-compiler to teach the shape. Set the **target** system with
`CMAKE_SYSTEM_NAME` + `CMAKE_SYSTEM_PROCESSOR`, and steer `find_*` with the four
`CMAKE_FIND_ROOT_PATH_MODE_{PROGRAM,LIBRARY,INCLUDE,PACKAGE}` knobs (programs on the host, libs/headers
in the target root). The point is that this lives **outside** `CMakeLists.txt`.

Validate it configures cleanly into a *separate* build dir, and peek at the cache:

```bash
cmake -B project/build-toolchain project --toolchain cmake/toolchains/practice.cmake
grep CMAKE_SYSTEM_NAME project/build-toolchain/CMakeCache.txt
```

## 4. Capture the flag

```bash
cmake --build project/build --target check
```

```
  🚩  flag{it_runs_in_the_browser}
```

---

## The browser moment (instructor-led — no install for you)
With the **emscripten** SDK, `emcmake cmake` just injects emscripten's toolchain file, and SDL3's web
backend builds the *same source* to `.wasm` + `.html`. Note the host-tool step from §1 in action —
because this is a cross build, you build `levelpack` natively first, then point the web build at it:

```bash
cmake -B build-host project/tools/levelpack          # configure JUST the tool, no SDL3 fetch
cmake --build build-host                             # host-built tool

emcmake cmake -B build-web project \
    -DLEVELPACK_EXECUTABLE=$PWD/build-host/levelpack
cmake --build build-web                              # → dungeon.html + dungeon.wasm
```

You'll get a prebuilt `dungeon.html` to open and **play the game in your browser** — the exact bytes,
no toolchain to install. That's cross-compilation paying off.

## Buried in the graveyard 🪦
- Hardcoding `CMAKE_CXX_COMPILER` / paths inside `CMakeLists.txt` instead of a toolchain file.
- Trying to **run** a cross-compiled binary during the build (the host-tool trap you just avoided).

✅ Full solution: `git diff m7-start m7-solution`.
