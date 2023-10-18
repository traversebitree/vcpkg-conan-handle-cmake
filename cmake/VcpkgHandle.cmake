# Put this before project() !!!
include_guard(GLOBAL)
set(X_VCPKG_APPLOCAL_DEPS_INSTALL TRUE CACHE BOOL "Automatically copy dependencies into the install target directory for executables.")
set(__TEMP_FILE "${CMAKE_BINARY_DIR}/tmp.txt")
set(_VCPKG_ROOT_DIR "${CMAKE_SOURCE_DIR}/.vcpkg")
set(_VCPKG_SOURCE_DIR "${_VCPKG_ROOT_DIR}/vcpkg-src")
set(_VCPKG_SUBBUILD_DIR "${_VCPKG_ROOT_DIR}/vcpkg-subbuild")
set(_VCPKG_DOWNLOAD_DIR "${_VCPKG_ROOT_DIR}")
set(_VCPKG_BINARY_DIR "${_VCPKG_ROOT_DIR}/vcpkg-build")

if(WIN32)
    set(_VCPKG_BOOTSTRAP_SCRIPT "${_VCPKG_SOURCE_DIR}/scripts/bootstrap.ps1")
    set(_VCPKG_EXECUTEABLE "${_VCPKG_SOURCE_DIR}/vcpkg.exe")
elseif(UNIX)
    set(_VCPKG_BOOTSTRAP_SCRIPT "${_VCPKG_SOURCE_DIR}/scripts/bootstrap.sh")
    set(_VCPKG_EXECUTEABLE "${_VCPKG_SOURCE_DIR}/vcpkg")
endif()

if(NOT EXISTS "${_VCPKG_EXECUTEABLE}")
    include(FetchContent)
    message(STATUS "Fetching vcpkg ...")
    FetchContent_Declare(
        _vcpkg
        GIT_REPOSITORY "https://github.com/microsoft/vcpkg.git"
        DOWNLOAD_DIR "${_VCPKG_DOWNLOAD_DIR}"
        SOURCE_DIR "${_VCPKG_SOURCE_DIR}"
        SUBBUILD_DIR "${_VCPKG_SUBBUILD_DIR}"
        BINARY_DIR "${_VCPKG_BINARY_DIR}"
    )
    FetchContent_MakeAvailable(_vcpkg)
endif()

execute_process(COMMAND "git" "status" WORKING_DIRECTORY "${_VCPKG_SOURCE_DIR}" OUTPUT_FILE "${__TEMP_FILE}" OUTPUT_QUIET)
file(STRINGS "${__TEMP_FILE}" __TEMP_FILE_STRING)
string(REGEX MATCH "nothing to commit, working tree clean" _GIT_STATUS "${__TEMP_FILE_STRING}")

if("${_GIT_STATUS}" STREQUAL "")
    execute_process(COMMAND "git" "restore" "." WORKING_DIRECTORY "${_VCPKG_SOURCE_DIR}")
endif()

if("${WIN32}" AND NOT EXISTS "${_VCPKG_EXECUTEABLE}")
    execute_process(COMMAND ".\\bootstrap-vcpkg.bat"
        WORKING_DIRECTORY "${_VCPKG_SOURCE_DIR}"
        OUTPUT_QUIET
    )
elseif("${UNIX}" AND NOT EXISTS "${_VCPKG_EXECUTEABLE}")
    execute_process(COMMAND "./bootstrap-vcpkg.sh"
        WORKING_DIRECTORY "${_VCPKG_SOURCE_DIR}"
        OUTPUT_QUIET
    )
endif()

if(EXISTS "${_VCPKG_EXECUTEABLE}")
    set(_VCPKG_EXECUTEABLE_FOUND TRUE)
else()
    set(_VCPKG_EXECUTEABLE_FOUND FALSE)
endif()

file(REMOVE "${__TEMP_FILE}")

message(STATUS "VCPKG_EXECUTEABLE: ${_VCPKG_EXECUTEABLE}")

if("${_VCPKG_EXECUTEABLE_FOUND}")
    message(STATUS "VCPKG_EXECUTEABLE_FOUND: ${_VCPKG_EXECUTEABLE_FOUND}")
else()
    message(FATAL_ERROR "VCPKG_EXECUTEABLE_FOUND: ${_VCPKG_EXECUTEABLE_FOUND}")
endif()

set(VCPKG_INSTALLED_DIR "${_VCPKG_ROOT_DIR}/vcpkg-installed")
set(CMAKE_TOOLCHAIN_FILE "${_VCPKG_SOURCE_DIR}/scripts/buildsystems/vcpkg.cmake")
