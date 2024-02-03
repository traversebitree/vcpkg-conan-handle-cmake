include_guard(GLOBAL)
set(ENV{CONAN_HOME} "${CMAKE_CURRENT_SOURCE_DIR}/.conan")
set(_CONAN_BUILD_ROOT_PATH "$ENV{CONAN_HOME}/build")
find_package(Python3 COMPONENTS Interpreter REQUIRED)
cmake_path(GET Python3_EXECUTABLE PARENT_PATH _PYTHON_ROOT_PATH)
set(_PIP_SCRIPT_ROOT_PATH "${_PYTHON_ROOT_PATH}/Scripts")
find_program(_CONAN_EXEC "conan" HINTS "${_PIP_SCRIPT_ROOT_PATH}")

if(NOT EXISTS "${_CONAN_EXEC}")
  if("${CMAKE_HOST_SYSTEM_NAME}" MATCHES "Darwin")
    execute_process(
      COMMAND ${Python3_EXECUTABLE} "-m" "pip" "install" "conan" "--no-warn-script-location" "--break-system-packages"
              COMMAND_ERROR_IS_FATAL LAST
    )
  else()
    execute_process(
      COMMAND ${Python3_EXECUTABLE} "-m" "pip" "install" "conan" "--no-warn-script-location" COMMAND_ERROR_IS_FATAL
              LAST
    )
  endif()
  find_program(_CONAN_EXEC "conan" HINTS "${_PIP_SCRIPT_ROOT_PATH}" REQUIRED)
endif()

set(_CONAN_PROFILE_FILE_PATH "$ENV{CONAN_HOME}/profiles/default")
if(NOT EXISTS "${_CONAN_PROFILE_FILE_PATH}")
  execute_process(COMMAND ${_CONAN_EXEC} "profile" "detect" COMMAND_ERROR_IS_FATAL LAST)
endif()
execute_process(
  COMMAND
    ${_CONAN_EXEC} "install" "${CMAKE_CURRENT_SOURCE_DIR}" "--output-folder=${_CONAN_BUILD_ROOT_PATH}"
    "--build=missing" "--settings:host=build_type=${CMAKE_BUILD_TYPE}"
    "--settings:host=compiler.cppstd=${CMAKE_CXX_STANDARD}" "--settings:build=build_type=${CMAKE_BUILD_TYPE}"
    "--settings:build=compiler.cppstd=${CMAKE_CXX_STANDARD}" COMMAND_ERROR_IS_FATAL LAST
)
list(APPEND CMAKE_PREFIX_PATH "${_CONAN_BUILD_ROOT_PATH}")
