cmake_minimum_required(VERSION 3.25 FATAL_ERROR)
###########################################################################
# BEGIN: CACHES AND OPTIONS                                               #
###########################################################################
option(PROJECT_BUILD_DOC "Generate documentation." FALSE)
option(DEFAULT_BUILD_SHARED_LIBS "Default option for build shared libs." TRUE)
set(DEFAULT_CPP_STANDARD 20 CACHE STRING "Default value for cmake cxx standard.")
set(VCPKG_CACHE_LOCATION "${CMAKE_CURRENT_LIST_DIR}/.cache/.vcpkg" CACHE PATH "Default path for vcpkg cache root.")
set(CONAN_CACHE_LOCATION "${CMAKE_CURRENT_LIST_DIR}/.cache/.conan" CACHE PATH "Default path for conan cache root.")
###########################################################################
#                                                 END: CACHES AND OPTIONS #
###########################################################################
include(cmake/CheckPathParentheses.cmake)
include(cmake/VcpkgHandle.cmake)

project(app LANGUAGES CXX VERSION 1.2.3)
set(CMAKE_CXX_STANDARD ${DEFAULT_CPP_STANDARD})
include(cmake/ConanHandle.cmake)
set(CMAKE_POSITION_INDEPENDENT_CODE TRUE)
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN TRUE)
set(BUILD_SHARED_LIBS ${DEFAULT_BUILD_SHARED_LIBS})

if(MSVC)
  add_compile_options(/Zc:__cplusplus /EHsc)
endif()

if(APPLE) # put APPLE first
  set(CMAKE_INSTALL_RPATH "@loader_path" "@loader_path/../lib")
elseif(UNIX)
  set(CMAKE_INSTALL_RPATH "$ORIGIN" "$ORIGIN/../lib")
endif()

if(CMAKE_BUILD_TYPE MATCHES "RelWithDebInfo")
  add_compile_options("-fsanitize=address")
endif()

include(cmake/NoInSourceBuilds.cmake)
include(cmake/InstallArtifacts.cmake)
include(GNUInstallDirs)

find_package(CURL CONFIG REQUIRED GLOBAL)
find_package(fmt CONFIG REQUIRED GLOBAL)
find_package(ZLIB CONFIG REQUIRED GLOBAL)

###########################################################################
# BEGIN: SOURCE STRUCTURE                                                 #
###########################################################################
add_subdirectory(src)
###########################################################################
#                                                   END: SOURCE STRUCTURE #
###########################################################################

###########################################################################
# BEGIN: INSTALL                                                          #
###########################################################################
install_target(EXEs app)
###########################################################################
#                                                            END: INSTALL #
###########################################################################

if(PROJECT_BUILD_DOC)
  include(cmake/Doxygen.cmake) # Need download Doxygen and Graphviz
  doxygen(include doc)
endif()
