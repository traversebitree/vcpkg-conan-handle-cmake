cmake_minimum_required(VERSION 3.24 FATAL_ERROR)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
include(VcpkgHandle)
set(VCPKG_TARGET_TRIPLET "x64-windows")

project(app VERSION 1.2.3)
enable_language(CXX)
set(CMAKE_CXX_STANDARD 23)
enable_testing()
include(GNUInstallDirs)

add_subdirectory(src)

find_package(fmt CONFIG REQUIRED GLOBAL)
