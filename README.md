## DESCRIPTION
Use two cmake modules (`VcpkgHandle.cmake` and `ConanHandle.cmake`) to download and handle vcpkg/conan for package management.

You don't need to manually install either `vcpkg` or `conan`. With these two modules, both tools will bootstrap themselves and the dependencies required by the project will be downloaded and installed into the project directory without polluting the system directory.

It is not necessary to use both modules at the same time, if you want to use only one package manager, then just use that one.

## SUPPORTED OS
- Windows
- Linux
- MacOS

## SUPPORTED COMPILERS
- MSVC
- GCC
- CLANG

## REQUIREMENTS
- CMake (version >= 3.25.0)
- Python3 (version >= 3.6) (* only for `conan`)

## TODO
Automatically copies the dynamic library (`.dll`) from `conan` to the same directory as the corresponding executable.

## USAGE

### NOTICE
- Put `VcpkgHandle.cmake` **before** `project()`.
- Put `ConanHandle.cmake` **after** `project()`.
- `VcpkgHandle.cmake` is paired with `vcpkg.json`. 
- `ConanHandle.cmake` is paired with `conanfile.txt`.

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
include(cmake/ConanHandle.cmake)

find_package(fmt CONFIG REQUIRED GLOBAL)
find_package(ZLIB CONFIG REQUIRED GLOBAL)
add_executable(app main.cpp)
target_link_libraries(app PRIVATE fmt::fmt ZLIB::ZLIB)
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

_conanfile.txt_
```txt
[requires]
zlib/1.3.1

[options]
zlib*:shared=False

[generators]
CMakeDeps
```

_main.cpp_
```cpp
#include <fmt/core.h>
#include <zlib.h>

int main(int argc, char const *argv[])
{
    fmt::print("ZLIB VERSION: {}\n", zlibVersion());
    return 0;
}
```