# Capture the Build — Module 5 verifier.
#
# Goal of the module: consume real dependencies the RIGHT way — fetched via CPM
# and linked through their NAMESPACED imported targets (SDL3::SDL3, fmt::fmt),
# never the bare library name.
#
# We dump the executable's link interface at generation time with a generator
# expression, then a -P script asserts the namespaced targets are present.
file(GENERATE
    OUTPUT  "${CMAKE_BINARY_DIR}/dungeon-links.txt"
    CONTENT "$<TARGET_PROPERTY:dungeon,LINK_LIBRARIES>")

add_custom_target(check
    COMMAND ${CMAKE_COMMAND}
            -DLINKS=${CMAKE_BINARY_DIR}/dungeon-links.txt
            -DFLAGFILE=${CMAKE_BINARY_DIR}/flag.txt
            -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/CheckDeps.cmake
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E cat "${CMAKE_BINARY_DIR}/flag.txt"
    DEPENDS dungeon
    VERBATIM)
