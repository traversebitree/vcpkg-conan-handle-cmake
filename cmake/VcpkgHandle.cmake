if("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
    set(_PROJ_OS_WINDOWS TRUE)
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
    set(_PROJ_OS_LINUX TRUE)
endif()

if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    set(_PROJ_COMPILER_MSVC TRUE)
elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    set(_PROJ_COMPILER_MINGW TRUE)
endif()

set(__TEMP_FILE "${CMAKE_BINARY_DIR}/tmp.txt")

include(FetchContent)
FetchContent_Declare(
    _vcpkg
    GIT_REPOSITORY "https://github.com/microsoft/vcpkg.git"
)
FetchContent_MakeAvailable(_vcpkg)

execute_process(COMMAND "git" "status" WORKING_DIRECTORY "${_vcpkg_SOURCE_DIR}" OUTPUT_FILE "${__TEMP_FILE}" OUTPUT_QUIET)
file(STRINGS "${__TEMP_FILE}" __TEMP_FILE_STRING)
string(REGEX MATCH "nothing to commit, working tree clean" _GIT_STATUS "${__TEMP_FILE_STRING}")

if("${_GIT_STATUS}" STREQUAL "")
    execute_process(COMMAND "git" "restore" "." WORKING_DIRECTORY "${_vcpkg_SOURCE_DIR}")
endif()

if("${_PROJ_OS_WINDOWS}")
    set(_VCPKG_BOOTSTRAP_SCRIPT "${_vcpkg_SOURCE_DIR}/scripts/bootstrap.ps1")
    set(_VCPKG_EXECUTEABLE "${_vcpkg_SOURCE_DIR}/vcpkg.exe")
elseif("${_PROJ_OS_LINUX}")
    set(_VCPKG_BOOTSTRAP_SCRIPT "${_vcpkg_SOURCE_DIR}/scripts/bootstrap.sh")
    set(_VCPKG_EXECUTEABLE "${_vcpkg_SOURCE_DIR}/vcpkg")
endif()

if("${_PROJ_OS_WINDOWS}" AND NOT EXISTS "${_VCPKG_EXECUTEABLE}")
    execute_process(COMMAND ".\\bootstrap-vcpkg.bat"
        WORKING_DIRECTORY "${_vcpkg_SOURCE_DIR}"
        OUTPUT_QUIET
    )
elseif("${_PROJ_OS_LINUX}" AND NOT EXISTS "${_VCPKG_EXECUTEABLE}")
    execute_process(COMMAND "./bootstrap-vcpkg.sh"
        WORKING_DIRECTORY "${_vcpkg_SOURCE_DIR}"
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
message(STATUS "VCPKG_EXECUTEABLE_FOUND: ${_VCPKG_EXECUTEABLE_FOUND}")

macro(AddLibraryFromVcpkg pkg_name static)
    #[[
        Triplet have these catogaries:
        x64-windows (for MSVC dynamic)
        x64-windows-static (for MSVC static)
        x64-linux (for linux static)
        x64-linux-dynamic (for linux dynamic)
        x64-mingw-dynamic (for windows MinGW dynamic)
        x64-mingw-static (for windows MinGW static)
    ]]
    if("${_PROJ_OS_WINDOWS}")
        if("${_PROJ_COMPILER_MSVC}")
            if("${static}")
                set(${pkg_name}_TRIPLET "x64-windows-static")
            elseif(NOT "${static}")
                set(${pkg_name}_TRIPLET "x64-windows")
            endif()
        elseif("${_PROJ_COMPILER_MINGW}")
            if("${static}")
                set(${pkg_name}_TRIPLET "x64-mingw-static")
            elseif(NOT "${static}")
                set(${pkg_name}_TRIPLET "x64-mingw-dynamic")
            endif()
        endif()
    elseif("${_PROJ_OS_LINUX}")
        if("${static}")
            set(${pkg_name}_TRIPLET "x64-linux")
        elseif(NOT "${static}")
            set(${pkg_name}_TRIPLET "x64-linux-dynamic")
        endif()
    endif()

    if("${static}")
        set(${pkg_name}_STATIC TRUE)
    else()
        set(${pkg_name}_STATIC FALSE)
    endif()

    set(${pkg_name}_PACKAGE_CONFIG_PATH "${_vcpkg_SOURCE_DIR}/installed/${${pkg_name}_TRIPLET}/share/${pkg_name}")

    if(NOT EXISTS "${${pkg_name}_PACKAGE_CONFIG_PATH}")
        execute_process(COMMAND "${_VCPKG_EXECUTEABLE}" "install" "${pkg_name}:${${pkg_name}_TRIPLET}" OUTPUT_QUIET)
    endif()

    if(EXISTS "${${pkg_name}_PACKAGE_CONFIG_PATH}")
        list(APPEND CMAKE_PREFIX_PATH "${${pkg_name}_PACKAGE_CONFIG_PATH}")
    else()
        message(FATAL_ERROR "Package: ${pkg_name} NOT FOUND!")
    endif()
endmacro()