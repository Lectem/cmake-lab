# Capture the Build — Module 7 helper (run via cmake -P).
# Expected -D variables: GENERATED, TOOLCHAIN, FLAGFILE

set(_missing "")

if(NOT EXISTS "${GENERATED}")
    list(APPEND _missing "the generated header — wire the levelpack add_custom_command so the host tool runs")
endif()

if(NOT EXISTS "${TOOLCHAIN}")
    list(APPEND _missing "cmake/toolchains/practice.cmake — author a toolchain file (see the lab)")
else()
    file(READ "${TOOLCHAIN}" _t)
    if(NOT _t MATCHES "CMAKE_SYSTEM_NAME")
        list(APPEND _missing "CMAKE_SYSTEM_NAME in your toolchain file — a toolchain answers 'what target system?'")
    endif()
endif()

if(_missing)
    list(JOIN _missing "\n        - " _m)
    file(WRITE "${FLAGFILE}" "  ⛔  Not there yet. Fix:\n        - ${_m}\n")
else()
    file(WRITE "${FLAGFILE}"
        "  ✅  Host tool generated the level header, and your toolchain file parses.\n"
        "  🚩  flag{it_runs_in_the_browser}\n")
endif()
