if("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
    set(PROJ_OS_WINDOWS TRUE)
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
    set(PROJ_OS_LINUX TRUE)
endif()

if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    set(PROJ_COMPILER_MSVC TRUE)
elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    set(PROJ_COMPILER_MINGW TRUE)
endif()

set(TEMP_FILE "${CMAKE_BINARY_DIR}/tmp.txt")
execute_process(COMMAND "nslookup" "github.com" OUTPUT_FILE "${TEMP_FILE}" OUTPUT_QUIET ERROR_QUIET)
file(STRINGS "${TEMP_FILE}" TEMP_FILE_STRING REGEX "Address")
string(REGEX MATCH [[([^ #]+\.[^ #]+\.[^ #]+\.[^ #]+$)]] GITHUB_IP_ADDRESS "${TEMP_FILE_STRING}")
set(GITHUB_IP_ADDRESS "${CMAKE_MATCH_${CMAKE_MATCH_COUNT}}")

# message(STATUS ${GITHUB_IP_ADDRESS})
execute_process(COMMAND "curl" "-G" "-s" "ipinfo.io/${GITHUB_IP_ADDRESS}/country" OUTPUT_FILE "${TEMP_FILE}" OUTPUT_QUIET)
file(STRINGS "${TEMP_FILE}" GITHUB_IP_COUNTRY)

# message(STATUS ${GITHUB_IP_COUNTRY})
if("${GITHUB_IP_COUNTRY}" STREQUAL "CN" OR "${GITHUB_IP_COUNTRY}" MATCHES "400")
    set(USE_PROXY TRUE)
    set(PROXY_PREPEND "https://ghproxy.com/")
    set(PROXY_DOMAIN "ghproxy.com")
endif()

include(FetchContent)
FetchContent_Declare(
    vcpkg
    GIT_REPOSITORY "${PROXY_PREPEND}https://github.com/microsoft/vcpkg.git"
)
FetchContent_MakeAvailable(vcpkg)

execute_process(COMMAND "git" "status" WORKING_DIRECTORY "${vcpkg_SOURCE_DIR}" OUTPUT_FILE "${TEMP_FILE}" OUTPUT_QUIET)
file(STRINGS "${TEMP_FILE}" TEMP_FILE_STRING)
string(REGEX MATCH "nothing to commit, working tree clean" GIT_STATUS "${TEMP_FILE_STRING}")

if("${GIT_STATUS}" STREQUAL "")
    execute_process(COMMAND "git" "restore" "." WORKING_DIRECTORY "${vcpkg_SOURCE_DIR}")
endif()

if("${USE_PROXY}")
    if("${PROJ_OS_WINDOWS}")
        set(VCPKG_BOOTSTRAP_SCRIPT "${vcpkg_SOURCE_DIR}/scripts/bootstrap.ps1")
        set(VCPKG_EXECUTEABLE "${vcpkg_SOURCE_DIR}/vcpkg.exe")
        file(READ "${VCPKG_BOOTSTRAP_SCRIPT}" TEMP_FILE_STRING)
        string(REGEX REPLACE "github\\.com \"" "${PROXY_DOMAIN} \"/github.com" TEMP_FILE_STRING "${TEMP_FILE_STRING}")
    elseif("${PROJ_OS_LINUX}")
        set(VCPKG_BOOTSTRAP_SCRIPT "${vcpkg_SOURCE_DIR}/scripts/bootstrap.sh")
        set(VCPKG_EXECUTEABLE "${vcpkg_SOURCE_DIR}/vcpkg")
        file(READ "${VCPKG_BOOTSTRAP_SCRIPT}" TEMP_FILE_STRING)
        string(REGEX REPLACE "https://github\\.com" "${PROXY_PREPEND}github.com" TEMP_FILE_STRING "${TEMP_FILE_STRING}")
    endif()

    file(WRITE "${VCPKG_BOOTSTRAP_SCRIPT}" "${TEMP_FILE_STRING}")
endif()

if("${PROJ_OS_WINDOWS}" AND NOT EXISTS "${VCPKG_EXECUTEABLE}")
    execute_process(COMMAND ".\\bootstrap-vcpkg.bat"
        WORKING_DIRECTORY "${vcpkg_SOURCE_DIR}"
        OUTPUT_QUIET
    )
elseif("${PROJ_OS_LINUX}" AND NOT EXISTS "${VCPKG_EXECUTEABLE}")
    execute_process(COMMAND "./bootstrap-vcpkg.sh"
        WORKING_DIRECTORY "${vcpkg_SOURCE_DIR}"
        OUTPUT_QUIET
    )
endif()

if(EXISTS "${VCPKG_EXECUTEABLE}")
    set(VCPKG_EXECUTEABLE_FOUND TRUE)
else()
    set(VCPKG_EXECUTEABLE_FOUND FALSE)
endif()

file(REMOVE "${TEMP_FILE}")

message(STATUS "VCPKG_EXECUTEABLE: ${VCPKG_EXECUTEABLE}")
message(STATUS "VCPKG_EXECUTEABLE_FOUND: ${VCPKG_EXECUTEABLE_FOUND}")

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
    if("${PROJ_OS_WINDOWS}")
        if("${PROJ_COMPILER_MSVC}")
            if("${static}")
                set(${pkg_name}_TRIPLET "x64-windows-static")
            elseif(NOT "${static}")
                set(${pkg_name}_TRIPLET "x64-windows")
            endif()
        elseif("${PROJ_COMPILER_MINGW}")
            if("${static}")
                set(${pkg_name}_TRIPLET "x64-mingw-static")
            elseif(NOT "${static}")
                set(${pkg_name}_TRIPLET "x64-mingw-dynamic")
            endif()
        endif()
    elseif("${PROJ_OS_LINUX}")
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

    set(${pkg_name}_PACKAGE_CONFIG_PATH "${vcpkg_SOURCE_DIR}/installed/${${pkg_name}_TRIPLET}/share/${pkg_name}")

    if(NOT EXISTS "${${pkg_name}_PACKAGE_CONFIG_PATH}")
        execute_process(COMMAND "${VCPKG_EXECUTEABLE}" "install" "${pkg_name}:${${pkg_name}_TRIPLET}" OUTPUT_QUIET)
    endif()

    if(EXISTS "${${pkg_name}_PACKAGE_CONFIG_PATH}")
        list(APPEND CMAKE_PREFIX_PATH "${${pkg_name}_PACKAGE_CONFIG_PATH}")
    else()
        message(FATAL_ERROR "Package: ${pkg_name} NOT FOUND!")
    endif()
endmacro()