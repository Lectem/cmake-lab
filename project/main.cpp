#include <iostream>

// Module 1 — the smallest possible CMake project: one source, one executable.
// We will grow this into a real (SDL3) game over the next two days.
int main() {
    std::cout << R"(
   ____                       __
  / __ \__ _____  ___ ____ __/ /  ___  ___
 / /_/ / // / _ \/ _ `/ -_) _  / / _ \/ _ \   D U N G E O N
 \____/\_,_/_//_/\_, /\__/\_,_/  \___/_//_/   v0.1.0 — hello, CMake!
                /___/
)" << '\n';
    std::cout << "It builds. Tomorrow it runs in your browser.\n";
    return 0;
}
