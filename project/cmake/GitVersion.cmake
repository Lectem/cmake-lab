# Build-time version stamping (Module 9). Defines a `dungeon-version` target that
# regenerates dungeon/version.generated.hpp on every build by running
# GitVersionGen.cmake. Because it's a custom target (always considered stale),
# the git SHA refreshes on rebuild — unlike a configure_file(), which would bake
# a stale SHA at configure time and never update it.
set(_verdir ${CMAKE_BINARY_DIR}/version)
set(_verhdr ${_verdir}/dungeon/version.generated.hpp)
file(MAKE_DIRECTORY ${_verdir}/dungeon)

add_custom_target(dungeon-version ALL
    BYPRODUCTS ${_verhdr}
    COMMAND ${CMAKE_COMMAND}
            -DOUT=${_verhdr}
            -DVERSION=${PROJECT_VERSION}
            -DSRC=${CMAKE_SOURCE_DIR}
            -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/GitVersionGen.cmake
    COMMENT "Stamping git SHA + version into version.generated.hpp"
    VERBATIM)

# Consumers add this dir to their includes and depend on dungeon-version.
set(DUNGEON_VERSION_INCLUDE_DIR ${_verdir} CACHE INTERNAL "git-version generated header dir")
