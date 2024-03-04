include_guard(GLOBAL)
block(PROPAGATE CMAKE_PREFIX_PATH)
set(ENV{CONAN_HOME} "${CMAKE_CURRENT_SOURCE_DIR}/.conan")
set(_VENV_ROOT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/.venv")
set(_CONAN_BUILD_ROOT_PATH "$ENV{CONAN_HOME}/build")

if(WIN32)
  set(_VENV_PYTHON_SCRIPTS_ROOT_PATH "${_VENV_ROOT_PATH}/Scripts")
  set(_VENV_PYTHON_EXEC "${_VENV_PYTHON_SCRIPTS_ROOT_PATH}/python.exe")
  set(_CONAN_EXEC "${_VENV_PYTHON_SCRIPTS_ROOT_PATH}/conan.exe")
else()
  set(_VENV_PYTHON_SCRIPTS_ROOT_PATH "${_VENV_ROOT_PATH}/bin")
  set(_VENV_PYTHON_EXEC "${_VENV_PYTHON_SCRIPTS_ROOT_PATH}/python")
  set(_CONAN_EXEC "${_VENV_PYTHON_SCRIPTS_ROOT_PATH}/conan")
endif()

if(NOT EXISTS "${_VENV_PYTHON_EXEC}")
  if(NOT EXISTS "${_CONAN_EXEC}" AND EXISTS "${_VENV_ROOT_PATH}")
    file(REMOVE_RECURSE "${_VENV_ROOT_PATH}")
  endif()
  find_program(_PYTHON_EXEC NAMES "python" "python3" REQUIRED)
  execute_process(COMMAND ${_PYTHON_EXEC} "-m" "venv" "${_VENV_ROOT_PATH}")
endif()

if(NOT EXISTS "${_CONAN_EXEC}")
  execute_process(
    COMMAND ${_VENV_PYTHON_EXEC} "-m" "pip" "install" "--ignore-installed" "conan" COMMAND_ERROR_IS_FATAL LAST
  )
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
endblock()
