cmake_minimum_required(VERSION 3.25 FATAL_ERROR)
include(cmake/VcpkgHandle.cmake)

project(app LANGUAGES CXX VERSION 1.2.3)
set(CMAKE_CXX_STANDARD 20)
include(cmake/ConanHandle.cmake)
set(CMAKE_VISIBILITY_INLINES_HIDDEN TRUE)

if(MSVC)
  add_compile_options(/Zc:__cplusplus /EHsc)
endif()

if(APPLE) # APPLE put first
  set(CMAKE_INSTALL_RPATH "@loader_path")
elseif(UNIX)
  set(CMAKE_INSTALL_RPATH "$ORIGIN")
endif()

if(CMAKE_BUILD_TYPE MATCHES "RelWithDebInfo")
  add_compile_options("-fsanitize=address")
endif()

include(GNUInstallDirs)

set(BUILD_SHARED_LIBS TRUE)

find_package(CURL CONFIG REQUIRED GLOBAL)
find_package(fmt CONFIG REQUIRED GLOBAL)
find_package(ZLIB CONFIG REQUIRED GLOBAL)

add_subdirectory(src)

install(TARGETS app RUNTIME COMPONENT "app_exe" DESTINATION ${CMAKE_INSTALL_BINDIR})

install(FILES $<TARGET_RUNTIME_DLLS:app> COMPONENT "app_dll" DESTINATION ${CMAKE_INSTALL_BINDIR})

if(MINGW AND ${CMAKE_CXX_COMPILER_ID} MATCHES "GNU")
  get_filename_component(mingw_path ${CMAKE_CXX_COMPILER} PATH)
  file(GLOB mingw_runtimes "${mingw_path}/*.dll")
  list(FILTER mingw_runtimes EXCLUDE REGEX "fortran")
  set(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS ${mingw_runtimes})
  install(PROGRAMS ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS} DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT "app_dll")
endif()

if(NOT WIN32)
  install(
    CODE [[
                file(GET_RUNTIME_DEPENDENCIES
                RESOLVED_DEPENDENCIES_VAR RESOLVED_DEPS
                UNRESOLVED_DEPENDENCIES_VAR UNRESOLVED_DEPS
                EXECUTABLES $<TARGET_FILE:app>
                LIBRARIES $<TARGET_FILE:app>
                DIRECTORIES $<TARGET_FILE_DIR:app>
                PRE_INCLUDE_REGEXES $<TARGET_FILE_DIR:app>
                POST_INCLUDE_REGEXES $<TARGET_FILE_DIR:app>
                )
                foreach(DEP_LIB ${RESOLVED_DEPS})
                file(INSTALL ${DEP_LIB} DESTINATION ${CMAKE_INSTALL_PREFIX}/bin FOLLOW_SYMLINK_CHAIN)
                endforeach()
                ]]
    COMPONENT "app_dll"
  )
endif()

add_custom_target(
  install_project
  COMMAND ${CMAKE_COMMAND} --install ${CMAKE_BINARY_DIR} --component "app_dll" --config "${CMAKE_BUILD_TYPE}"
  COMMAND ${CMAKE_COMMAND} --install ${CMAKE_BINARY_DIR} --component "app_exe" --config "${CMAKE_BUILD_TYPE}"
  DEPENDS app
)
