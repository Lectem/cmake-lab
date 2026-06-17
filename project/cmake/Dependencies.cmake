# Dependencies.cmake -- the project's single source of dependency truth.
#
# Wired in via CMAKE_PROJECT_TOP_LEVEL_INCLUDES (set just before project() in the
# top CMakeLists), so CMake reads this during the first project() call. That is
# the one moment a dependency provider may be installed. From here on, every
# listfile consumes deps the vendor-neutral way: find_package(Foo CONFIG REQUIRED)
# then link Foo::Foo. CPM is simply the backend that satisfies those calls. Swap
# in vcpkg or Conan and the consumer code does not change.
#
# Two features set this project's floor at 3.25 rather than 3.22:
#   3.24  cmake_language(SET_DEPENDENCY_PROVIDER) -- the provider hook below.
#   3.25  the SYSTEM keyword on add_subdirectory()/FetchContent_Declare(), which
#         CPM forwards from the SYSTEM YES arguments on each declaration below.
# Prefer to stay on 3.22? Drop the provider, call CPMAddPackage here directly, and
# link the targets (no find_package). You keep SYSTEM YES -- CPM simply ignores it
# below 3.25 -- and pay for it with third-party warnings in your own build.
# find_package-everywhere is one option, not the only one.

include(${CMAKE_CURRENT_LIST_DIR}/CPM.cmake)

# Versions live HERE, in one place. CPMDeclarePackage only records the arguments.
# Nothing is fetched until something actually asks for the package.
# Tag handling differs per project: Catch2's tags are vX.Y.Z, so VERSION alone
# derives the right tag (vX.Y.Z). fmt's tags are unprefixed (11.0.2) and SDL uses
# release-X, so those two need an explicit GIT_TAG.
# SYSTEM YES on each: their headers reach our compiler as -isystem, so their
# warnings stay theirs. CPM's "gh:owner/repo#tag" shorthand implies it; this
# keyword form does not, so we say it out loud.
CPMDeclarePackage(fmt
    NAME fmt
    VERSION 11.0.2
    GIT_TAG 11.0.2
    GITHUB_REPOSITORY fmtlib/fmt
    SYSTEM YES
    OPTIONS "FMT_INSTALL OFF")

CPMDeclarePackage(SDL3
    NAME SDL3
    VERSION 3.2.4
    GIT_TAG release-3.2.4
    GITHUB_REPOSITORY libsdl-org/SDL
    SYSTEM YES)

CPMDeclarePackage(Catch2
    NAME Catch2
    VERSION 3.5.2
    GITHUB_REPOSITORY catchorg/Catch2
    SYSTEM YES)

# The redirect. CMake calls this for every find_package(). If we declared the
# package above, satisfy it from CPM and report success so CMake skips its own
# search. Anything we did not declare falls through to the normal find_package()
# (CMake disables the provider while this macro runs, so there is no recursion).
macro(dungeon_dependency_provider method package_name)
    if("${method}" STREQUAL "FIND_PACKAGE" AND DEFINED CPM_DECLARATION_${package_name})
        CPMAddPackage(NAME ${package_name})
        set(${package_name}_FOUND TRUE)
    endif()
endmacro()

cmake_language(SET_DEPENDENCY_PROVIDER dungeon_dependency_provider
    SUPPORTED_METHODS FIND_PACKAGE)
