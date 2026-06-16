# Lab 4 — Packaging: install, export, CPack 🚩

**Goal:** make `Dungeon` installable, exportable (so another project can `find_package(Dungeon)`),
and packageable with CPack. Pure CMake.

**Start from:** `git checkout m4-start`

The `check` target installs into `build/_stage` and verifies the tree. Run it first to see what's
missing:

```bash
cmake -S project -B project/build && cmake --build project/build --target check
```

Stuck on any step? The full worked solution is always `git diff m4-start m4-solution`.

---

## 1. Install the library + headers (`libs/game-core/CMakeLists.txt`)

Make the library and its public headers installable, and record the target into an **export set**
(you'll ship it in step 3). Use `GNUInstallDirs` so you're not hardcoding `bin/ lib/ include/`.

> ⚠️ Exporting fails with *"INTERFACE_INCLUDE_DIRECTORIES … is prefixed in the source directory."* Your
> Module 2 include path points into the source tree, which is meaningless once installed. Split it into
> its build-tree and install-tree forms with the `$<BUILD_INTERFACE:...>` / `$<INSTALL_INTERFACE:...>`
> generator expressions.

## 2. Install the executable (`apps/dungeon/CMakeLists.txt`)

Install the `dungeon` binary into the standard runtime location.

## 3. Export the package + enable CPack (top-level `CMakeLists.txt`)

- Install the export set under the `dungeon::` namespace, so consumers link `dungeon::game-core`
  (matching the Module 2 ALIAS).
- Generate a package config + version file with the `CMakePackageConfigHelpers` helpers — the
  `*.cmake.in` template is already in `cmake/` — and install them.
- Turn on `CPack` with a vendor and a couple of generators.

## 4. Capture the flag

```bash
rm -rf project/build
cmake -S project -B project/build
cmake --build project/build --target check        # 🚩 flag{shipped_it}
```

---

## See what you shipped
```bash
cmake --install project/build --prefix /tmp/dungeon-out
find /tmp/dungeon-out            # bin/, include/dungeon/, lib/cmake/Dungeon/

cd project/build && cpack        # produces Dungeon-0.1.0-*.zip and .tar.gz
```

**Platform note:** on Windows the executable lands in `bin/` with no rpath; on Linux you get a `.a` and
rpath handling. CPack picks ZIP/TGZ here; add `NSIS`/`WIX` on Windows, `DEB` on Linux. We revisit
shared-lib / rpath / symbol details in Module 9.

✅ Full solution: `git diff m4-start m4-solution`.
