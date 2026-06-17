# Run via `cmake -P` at BUILD time (not configure) so the SHA refreshes on every
# build. Writes dungeon/version.generated.hpp only when its content changes, to
# avoid triggering needless rebuilds.
# Expected -D variables: OUT, VERSION, SRC

set(_sha "unknown")
find_package(Git QUIET)
if(Git_FOUND)
    execute_process(
        COMMAND "${GIT_EXECUTABLE}" -C "${SRC}" rev-parse --short HEAD
        OUTPUT_VARIABLE _sha
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
        RESULT_VARIABLE _rc)
    if(NOT _rc EQUAL 0 OR _sha STREQUAL "")
        set(_sha "unknown")
    endif()
endif()

set(_content
"// Generated from git — do not edit.
#pragma once
namespace dungeon {
inline constexpr const char* kVersion = \"${VERSION}\";
inline constexpr const char* kGitSha  = \"${_sha}\";
} // namespace dungeon
")

set(_old "")
if(EXISTS "${OUT}")
    file(READ "${OUT}" _old)
endif()
if(NOT _old STREQUAL _content)
    file(WRITE "${OUT}" "${_content}")
endif()
