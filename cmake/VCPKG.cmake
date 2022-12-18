if("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
    set(PROJ_OS_WINDOWS TRUE)
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
    set(PROJ_OS_LINUX TRUE)
endif()

set(TEMP_FILE "${CMAKE_BINARY_DIR}/tmp.txt")
execute_process(COMMAND "nslookup" "github.com" OUTPUT_FILE "${TEMP_FILE}" OUTPUT_QUIET)
file(STRINGS "${TEMP_FILE}" TEMP_FILE_STRING)
string(REGEX MATCH "[0-9]\+\\.[0-9]\+\\.[0-9]\+\\.[0-9]\+" GITHUB_IP_ADDRESS "${TEMP_FILE_STRING}")

# message(STATUS ${GITHUB_IP_ADDRESS})
execute_process(COMMAND "curl" "-G" "-s" "ipinfo.io/${GITHUB_IP_ADDRESS}/country" OUTPUT_FILE "${TEMP_FILE}" OUTPUT_QUIET)
file(STRINGS "${TEMP_FILE}" GITHUB_IP_COUNTRY)

# message(STATUS ${GITHUB_IP_COUNTRY})
if("${GITHUB_IP_COUNTRY}" STREQUAL "CN")
    set(USE_PROXY TRUE)
    set(PROXY_PREPEND "https://ghproxy.com/")
    set(PROXY_DOMAIN "ghproxy.com")
endif()

include(FetchContent)
FetchContent_Declare(
    vcpkg
    GIT_REPOSITORY "${PROXY_PREPEND}https://github.com/microsoft/vcpkg.git"
    GIT_TAG 2022.11.14
)
FetchContent_MakeAvailable(vcpkg)

execute_process(COMMAND "git" "status" WORKING_DIRECTORY "${vcpkg_SOURCE_DIR}" OUTPUT_FILE "${TEMP_FILE}" OUTPUT_QUIET)
file(STRINGS "${TEMP_FILE}" TEMP_FILE_STRING)
string(REGEX MATCH "nothing to commit, working tree clean" GIT_STATUS "${TEMP_FILE_STRING}")

if("${GIT_STATUS}" STREQUAL "")
    execute_process(COMMAND "git" "restore" "." WORKING_DIRECTORY "${vcpkg_SOURCE_DIR}")
endif()

if(USE_PROXY)
    if("${PROJ_OS_WINDOWS}")
        set(VCPKG_BOOTSTRAP_SCRIPT "${vcpkg_SOURCE_DIR}/scripts/bootstrap.ps1")
        set(VCPKG_EXECUTEABLE "${vcpkg_SOURCE_DIR}/vcpkg.exe")
        file(READ ${VCPKG_BOOTSTRAP_SCRIPT} TEMP_FILE_STRING)
        string(REGEX REPLACE "github\\.com \"" "${PROXY_DOMAIN} \"/github.com" TEMP_FILE_STRING "${TEMP_FILE_STRING}")
    elseif("${PROJ_OS_LINUX}")
        set(VCPKG_BOOTSTRAP_SCRIPT "${vcpkg_SOURCE_DIR}/scripts/bootstrap.sh")
        set(VCPKG_EXECUTEABLE "${vcpkg_SOURCE_DIR}/vcpkg")
        file(READ ${VCPKG_BOOTSTRAP_SCRIPT} TEMP_FILE_STRING)
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
    execute_process(COMMAND ".\\bootstrap-vcpkg.sh"
        WORKING_DIRECTORY "${vcpkg_SOURCE_DIR}"
        OUTPUT_QUIET
    )
endif()

if(EXISTS "${VCPKG_EXECUTEABLE}")
    set(VCPKG_EXECUTEABLE_FOUND TRUE)
else()
    set(VCPKG_EXECUTEABLE_FOUND FALSE)
endif()
