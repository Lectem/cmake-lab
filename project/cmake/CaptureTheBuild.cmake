# Capture the Build — Module 10 grand finale.
#
# The victory lap: run the whole pipeline end to end — tests, install/export,
# and the git-SHA stamp — then award the final trophy flag. This is gated on the
# cumulative work of Modules 1–9, so it lights up only when everything is wired.
if(TARGET game-core-tests)
    set(_finale_deps dungeon game-core-tests)
else()
    set(_finale_deps dungeon)
endif()

add_custom_target(check
    COMMAND ${CMAKE_CTEST_COMMAND} --test-dir "${CMAKE_BINARY_DIR}" --output-on-failure
    COMMAND ${CMAKE_COMMAND} -E rm -rf "${CMAKE_BINARY_DIR}/_stage"
    COMMAND ${CMAKE_COMMAND} --install "${CMAKE_BINARY_DIR}" --prefix "${CMAKE_BINARY_DIR}/_stage"
    COMMAND ${CMAKE_COMMAND}
            -DSTAGE=${CMAKE_BINARY_DIR}/_stage
            -DVERHDR=${CMAKE_BINARY_DIR}/version/dungeon/version.generated.hpp
            -DFLAGFILE=${CMAKE_BINARY_DIR}/flag.txt
            -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/CheckFinale.cmake
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E cat "${CMAKE_BINARY_DIR}/flag.txt"
    DEPENDS ${_finale_deps}
    USES_TERMINAL
    VERBATIM)
