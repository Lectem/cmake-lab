# Capture the Build — Module 9 verifier.
#
# Proves the production-grade build-time codegen works: the git SHA is stamped
# into version.generated.hpp and compiled into the binary. Building `check`
# builds `dungeon`, which forces both the export header and the version stamp.
add_custom_target(check
    COMMAND ${CMAKE_COMMAND}
            -DVERHDR=${CMAKE_BINARY_DIR}/version/dungeon/version.generated.hpp
            -DFLAGFILE=${CMAKE_BINARY_DIR}/flag.txt
            -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/CheckVersion.cmake
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E cat "${CMAKE_BINARY_DIR}/flag.txt"
    DEPENDS dungeon
    VERBATIM)
