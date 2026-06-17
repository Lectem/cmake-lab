# Capture the Build — Module 6 verifier.
#
# `check` drives the test suite through CTest. The flag prints only if every
# test passes. At the module start no tests are registered, so CTest reports
# "No tests were found" and the flag stays locked.
#
# The dependency is wired only when the test target exists (i.e. once you've
# added tests/ and fetched Catch2), so this same file works before and after.
add_custom_target(check
    COMMAND ${CMAKE_CTEST_COMMAND} --test-dir "${CMAKE_BINARY_DIR}" --output-on-failure
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "  ✅  game-core is green."
    COMMAND ${CMAKE_COMMAND} -E echo "  🚩  flag{green_tests}"
    USES_TERMINAL
    VERBATIM)

if(TARGET game-core-tests)
    add_dependencies(check game-core-tests)
endif()
