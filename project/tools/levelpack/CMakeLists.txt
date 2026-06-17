# levelpack: the codegen tool that packs levels/*.txt into a header. It runs on
# the BUILD HOST, so when the game is cross-compiled this still has to be built
# natively. It is also usable as a standalone source root, which lets a cross
# build produce a host binary without configuring (and fetching) the rest:
#     cmake -B build-host project/tools/levelpack
#     cmake --build build-host
cmake_minimum_required(VERSION 3.22...3.28)
project(levelpack LANGUAGES CXX)

add_executable(levelpack levelpack.cpp)
target_compile_features(levelpack PRIVATE cxx_std_17)
