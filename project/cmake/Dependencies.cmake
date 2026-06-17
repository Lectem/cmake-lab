# Dependencies.cmake -- the project's single source of dependency truth.
#
# Wired in via CMAKE_PROJECT_TOP_LEVEL_INCLUDES (set just before project() in the
# top CMakeLists), so CMake reads this during the first project() call. That is
# the one moment a dependency provider may be installed. From here on, every
# listfile consumes deps the vendor-neutral way: find_package(Foo CONFIG REQUIRED)
# then link Foo::Foo. CPM is simply the backend that satisfies those calls.

include(${CMAKE_CURRENT_LIST_DIR}/CPM.cmake)

# TODO: declare SDL3 and fmt here with CPMDeclarePackage.
# Pin SDL3 to release-3.2.4 and fmt to 11.0.2 (disable FMT_INSTALL), and pass
# SYSTEM YES on both so their headers arrive as -isystem (warnings stay theirs).
# CPMDeclarePackage only records the arguments -- nothing is fetched yet.
#
# CPMDeclarePackage(fmt
#     NAME fmt  VERSION ...  GIT_TAG ...  GITHUB_REPOSITORY fmtlib/fmt
#     SYSTEM YES  OPTIONS "FMT_INSTALL OFF")
# CPMDeclarePackage(SDL3
#     NAME SDL3  VERSION ...  GIT_TAG ...  GITHUB_REPOSITORY libsdl-org/SDL  SYSTEM YES)

# The provider hook -- routes find_package() for declared packages through CPM.
# This is per-project boilerplate: copy it once, then forget it.
macro(dungeon_dependency_provider method package_name)
    if("${method}" STREQUAL "FIND_PACKAGE" AND DEFINED CPM_DECLARATION_${package_name})
        CPMAddPackage(NAME ${package_name})
        set(${package_name}_FOUND TRUE)
    endif()
endmacro()

cmake_language(SET_DEPENDENCY_PROVIDER dungeon_dependency_provider
    SUPPORTED_METHODS FIND_PACKAGE)
