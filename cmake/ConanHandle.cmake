include_guard(GLOBAL)
set(ENV{CONAN_HOME} "${CMAKE_CURRENT_SOURCE_DIR}/.conan")
set(_CONAN_BUILD_ROOT_PATH "$ENV{CONAN_HOME}/build")
find_program(_PYTHON_EXEC "python" NO_CACHE REQUIRED)
cmake_path(GET _PYTHON_EXEC PARENT_PATH _PYTHON_ROOT)
set(_GET_PIP_PY_DOWNLOAD_LOCATION "${_PYTHON_ROOT}/get-pip.py")
set(_PYTHON_SCRIPT_ROOT_PATH "${_PYTHON_ROOT}/Scripts")
if(NOT EXISTS "${_GET_PIP_PY_DOWNLOAD_LOCATION}")
  file(DOWNLOAD https://bootstrap.pypa.io/get-pip.py "${_PYTHON_ROOT}/get-pip.py")
endif()
if(NOT EXISTS "${_PYTHON_SCRIPT_ROOT_PATH}")
  execute_process(COMMAND ${_PYTHON_EXEC} "get-pip.py" "--no-warn-script-location" WORKING_DIRECTORY ${_PYTHON_ROOT})
endif()
find_program(_PIP_EXEC "pip" HINTS "${_PYTHON_SCRIPT_ROOT_PATH}" NO_DEFAULT_PATH REQUIRED)
find_program(_CONAN_EXEC "conan" HINTS "${_PYTHON_SCRIPT_ROOT_PATH}" NO_DEFAULT_PATH)

if(NOT EXISTS "${_CONAN_EXEC}")
  message(STATUS "CONAN_EXEC: ${_CONAN_EXEC}")
  execute_process(COMMAND ${_PIP_EXEC} "install" "conan")
  find_program(_CONAN_EXEC "conan" HINTS "${_PYTHON_SCRIPT_ROOT_PATH}" NO_DEFAULT_PATH REQUIRED)
endif()
set(_CONAN_PROFILE_FILE_PATH "$ENV{CONAN_HOME}/profiles/default")
if(NOT EXISTS "${_CONAN_PROFILE_FILE_PATH}")
  execute_process(COMMAND ${_CONAN_EXEC} "profile" "detect" COMMAND_ECHO STDOUT)
endif()
execute_process(
  COMMAND
    ${_CONAN_EXEC} "install" "${CMAKE_CURRENT_SOURCE_DIR}" "--output-folder=${_CONAN_BUILD_ROOT_PATH}"
    "--build=missing" "--settings:host=build_type=${CMAKE_BUILD_TYPE}"
    "--settings:build=build_type=${CMAKE_BUILD_TYPE}"
)
list(APPEND CMAKE_PREFIX_PATH "${_CONAN_BUILD_ROOT_PATH}")
