# Capture the Build — Module 7 verifier.
#
# Two things to prove:
#   1. the host tool runs during the build and generates levels.generated.hpp
#      (so cross-compiling the game still works — the tool is a host artifact);
#   2. you authored a toolchain file that declares a target system.
#
# Building `check` builds `dungeon`, which forces the codegen custom command.
add_custom_target(check
    COMMAND ${CMAKE_COMMAND}
            -DGENERATED=$<TARGET_PROPERTY:dungeon,BINARY_DIR>/generated/dungeon/levels.generated.hpp
            -DTOOLCHAIN=${CMAKE_SOURCE_DIR}/cmake/toolchains/practice.cmake
            -DFLAGFILE=${CMAKE_BINARY_DIR}/flag.txt
            -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/CheckCross.cmake
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E cat "${CMAKE_BINARY_DIR}/flag.txt"
    DEPENDS dungeon
    VERBATIM)
