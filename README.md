## DESCRIPTION
Use a cmake module to download and handle vcpkg for package management.

## SUPPORTED COMPILERS
- MSVC
- GCC
- CLANG

## REQUIREMENTS
- CMake (version >= 3.25.0)
- Ninja (apt install ninja-build)
- g++ (apt install g++)
- clang++ (apt install clang-14)

## USAGE

### NOTICE
Put it before `project()`.

### For test
You can use the following command to test in this repo.
```sh
git clone https://github.com/traversebitree/vcpkg-handle-cmake.git
cd vcpkg-handle-cmake
cmake --preset="DEFAULT-REL"
cmake --build --preset "DEFAULT-REL"
cmake --build --preset "DEFAULT-REL" --target "install_project"
./.out/install/DEFAULT-REL/bin/app
```

### For usage on yourself
You need put `VcpkgHandle.cmake` to your project dir, for example, `cmake\VcpkgHandle.cmake`. Then write your `CMakeLists.txt` and `vcpkg.json` like following:

_CMakeLists.txt_
```cmake
cmake_minimum_required(VERSION 3.25 FATAL_ERROR)
include(cmake/VcpkgHandle.cmake)

project(app LANGUAGES CXX VERSION 1.2.3)
set(CMAKE_CXX_STANDARD 20)

find_package(fmt CONFIG REQUIRED GLOBAL)
add_executable(app main.cpp)
target_link_libraries(app PRIVATE fmt::fmt)
```

_vcpkg.json_
```json
{
    "name": "app",
    "version-string": "0.1.0",
    "dependencies": [
        "fmt"
    ]
}
```
