# Capture the Build — Module 4 verifier.
#
# The `check` target installs the project into build/_stage and then verifies the
# tree is complete (executable + public headers + a find_package-able config
# package). The actual file checks live in cmake/CheckInstall.cmake.

add_custom_target(check
    COMMAND ${CMAKE_COMMAND} -E rm -rf "${CMAKE_BINARY_DIR}/_stage"
    COMMAND ${CMAKE_COMMAND} --install "${CMAKE_BINARY_DIR}" --prefix "${CMAKE_BINARY_DIR}/_stage"
    COMMAND ${CMAKE_COMMAND}
            -DSTAGE=${CMAKE_BINARY_DIR}/_stage
            -DFLAGFILE=${CMAKE_BINARY_DIR}/flag.txt
            -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/CheckInstall.cmake
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E cat "${CMAKE_BINARY_DIR}/flag.txt"
    DEPENDS dungeon game-core
    VERBATIM)
