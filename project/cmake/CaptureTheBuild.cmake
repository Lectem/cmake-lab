# Capture the Build — Module 8 verifier.
#
# Proves the tooling layer is wired the modern way: sanitizers live in a
# TOOLCHAIN file selected by a PRESET (not in the project's listfiles, and not
# via global CMAKE_CXX_FLAGS), and compile_commands.json is exported for clang
# tooling. The live ASan catch is the demo; this confirms one-command repro.
add_custom_target(check
    COMMAND ${CMAKE_COMMAND}
            -DBUILD=${CMAKE_BINARY_DIR}
            -DSRC=${CMAKE_SOURCE_DIR}
            -DFLAGFILE=${CMAKE_BINARY_DIR}/flag.txt
            -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/CheckTooling.cmake
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E cat "${CMAKE_BINARY_DIR}/flag.txt"
    VERBATIM)
