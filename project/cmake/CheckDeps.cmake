# Capture the Build — Module 5 helper (run via cmake -P).
# Reads the dumped link interface and verifies the deps are linked the right way.
# Expected -D variables: LINKS, FLAGFILE

file(READ "${LINKS}" _links)

set(_missing "")
if(NOT _links MATCHES "SDL3::SDL3")
    list(APPEND _missing "SDL3::SDL3 (declare in Dependencies.cmake, find_package + link PRIVATE)")
endif()
if(NOT _links MATCHES "fmt::fmt")
    list(APPEND _missing "fmt::fmt (same find_package treatment as SDL3)")
endif()

# Catch the classic anti-pattern: linking the bare name instead of the namespaced
# imported target. CPM/find_package give you SDL3::SDL3 — use it.
if(_links MATCHES "(^|;)SDL3(;|$)")
    list(APPEND _missing "the NAMESPACED target — you linked bare `SDL3`, use `SDL3::SDL3`")
endif()

if(_missing)
    list(JOIN _missing "\n        - " _m)
    file(WRITE "${FLAGFILE}" "  ⛔  Dependencies not consumed the right way. Fix:\n        - ${_m}\n")
else()
    file(WRITE "${FLAGFILE}"
        "  ✅  SDL3 and fmt consumed via find_package and linked through namespaced targets.\n"
        "  🚩  flag{find_package_the_right_way}\n")
endif()
