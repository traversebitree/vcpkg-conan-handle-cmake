cmake_minimum_required(VERSION 3.25 FATAL_ERROR)
include(cmake/VcpkgHandle.cmake)

project(app LANGUAGES CXX VERSION 1.2.3)
set(CMAKE_CXX_STANDARD 20)

set(CMAKE_VISIBILITY_INLINES_HIDDEN TRUE)

if(MSVC)
    add_compile_options(/Zc:__cplusplus /EHsc)
endif()

if(UNIX)
    set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
endif()

if(CMAKE_BUILD_TYPE MATCHES "RelWithDebInfo")
    add_compile_options("-fsanitize=address")
endif()

include(GNUInstallDirs)
add_subdirectory(src)
find_package(fmt CONFIG REQUIRED GLOBAL)
