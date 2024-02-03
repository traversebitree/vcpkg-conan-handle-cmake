include_guard(GLOBAL)
set(ENV{CONAN_HOME} "${CMAKE_CURRENT_SOURCE_DIR}/.conan")
set(ENV{VIRTUAL_ENV} "$ENV{CONAN_HOME}/.venv")
set(_CONAN_BUILD_ROOT_PATH "$ENV{CONAN_HOME}/build")
set(Python3_FIND_VIRTUALENV ONLY)
find_package(Python3 COMPONENTS Interpreter)
if(NOT Python3_EXECUTABLE)
  set(Python3_FIND_VIRTUALENV STANDARD)
  find_package(Python3 COMPONENTS Interpreter REQUIRED)
  execute_process(COMMAND ${Python3_EXECUTABLE} "-m" "venv" "$ENV{VIRTUAL_ENV}" COMMAND_ECHO STDOUT)
  unset(Python3_EXECUTABLE)
  set(Python3_FIND_VIRTUALENV ONLY)
  find_package(Python3 COMPONENTS Interpreter REQUIRED)
endif()
cmake_path(GET Python3_EXECUTABLE PARENT_PATH _PYTHON_SCRIPT_ROOT_PATH)
find_program(_CONAN_EXEC "conan" HINTS "${_PYTHON_SCRIPT_ROOT_PATH}" NO_DEFAULT_PATH)
if(NOT EXISTS "${_CONAN_EXEC}")
  execute_process(
    COMMAND ${Python3_EXECUTABLE} "-m" "pip" "install" "conan" "--no-warn-script-location" COMMAND_ERROR_IS_FATAL LAST
            COMMAND_ECHO STDOUT
  )
  find_program(_CONAN_EXEC "conan" HINTS "$ENV{VIRTUAL_ENV}/Scripts" REQUIRED)
endif()
set(_CONAN_PROFILE_FILE_PATH "$ENV{CONAN_HOME}/profiles/default")
if(NOT EXISTS "${_CONAN_PROFILE_FILE_PATH}")
  execute_process(COMMAND ${_CONAN_EXEC} "profile" "detect" COMMAND_ERROR_IS_FATAL LAST COMMAND_ECHO STDOUT)
endif()
execute_process(
  COMMAND
    ${_CONAN_EXEC} "install" "${CMAKE_CURRENT_SOURCE_DIR}" "--output-folder=${_CONAN_BUILD_ROOT_PATH}"
    "--build=missing" "--settings:host=build_type=${CMAKE_BUILD_TYPE}"
    "--settings:host=compiler.cppstd=${CMAKE_CXX_STANDARD}" "--settings:build=build_type=${CMAKE_BUILD_TYPE}"
    "--settings:build=compiler.cppstd=${CMAKE_CXX_STANDARD}" COMMAND_ERROR_IS_FATAL LAST COMMAND_ECHO STDOUT
)
list(APPEND CMAKE_PREFIX_PATH "${_CONAN_BUILD_ROOT_PATH}")
