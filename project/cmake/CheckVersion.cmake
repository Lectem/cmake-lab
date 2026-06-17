# Capture the Build — Module 9 helper (run via cmake -P).
# Expected -D variables: VERHDR, FLAGFILE

set(_ok FALSE)
if(EXISTS "${VERHDR}")
    file(READ "${VERHDR}" _v)
    # A real short SHA is hex; "unknown" (no git) does not count.
    if(_v MATCHES "kGitSha  = \"([0-9a-fA-F]+)\"")
        set(_ok TRUE)
        set(_sha "${CMAKE_MATCH_1}")
    endif()
endif()

if(_ok)
    file(WRITE "${FLAGFILE}"
        "  ✅  Git SHA ${_sha} baked into the binary at build time.\n"
        "  🚩  flag{git_sha_baked_in}\n")
else()
    file(WRITE "${FLAGFILE}"
        "  ⛔  No git SHA in version.generated.hpp yet.\n"
        "      Wire cmake/GitVersion.cmake and make `dungeon` depend on dungeon-version.\n")
endif()
