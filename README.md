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
- clang++

## USAGE
### For test
You can use the following command to test in this repo.
```sh
git clone https://github.com/traversebitree/vcpkg-handle-cmake.git
cd vcpkg-handle-cmake
# FOR MINGW
cmake --preset="GCC-x64-REL"
# OR FOR MSVC
cmake --preset="MSVC-x64-REL"
# OR FOR MSVC
cmake --preset="CLANG-x64-REL"
```

### For usage on yourself
You need put `VcpkgHandle.cmake` to your project dir, for example, `cmake\VcpkgHandle.cmake`. Then write your CMakeLists.txt like this:
```cmake
cmake_minimum_required(VERSION 3.25 FATAL_ERROR)
project(app VERSION 1.2.3)
enable_language(CXX)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
include(VcpkgHandle)
add_subdirectory(src)
AddLibraryFromVcpkg(fmt TRUE)
find_package(fmt CONFIG REQUIRED GLOBAL)
```

