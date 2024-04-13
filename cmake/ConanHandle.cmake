include_guard(GLOBAL)
block(PROPAGATE CMAKE_PREFIX_PATH)
set(ENV{CONAN_HOME} "${CMAKE_CURRENT_SOURCE_DIR}/.conan")
if(DEFINED CONAN_CACHE_LOCATION)
  set(ENV{CONAN_HOME} "${CONAN_CACHE_LOCATION}")
endif()
set(_CONAN_HOME $ENV{CONAN_HOME})
cmake_path(GET _CONAN_HOME PARENT_PATH _CONAN_HOME_PARENT_PATH)
set(_VENV_ROOT_PATH "${_CONAN_HOME_PARENT_PATH}/.venv")
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

if(DEFINED CMAKE_CXX_COMPILER_ID)
  set(_COMPILER ${CMAKE_CXX_COMPILER_ID})
  set(_COMPILER_VERSION ${CMAKE_CXX_COMPILER_VERSION})
else()
  if(NOT DEFINED CMAKE_C_COMPILER_ID)
    message(FATAL_ERROR "C or C++ compiler not defined")
  endif()
  set(_COMPILER ${CMAKE_C_COMPILER_ID})
  set(_COMPILER_VERSION ${CMAKE_C_COMPILER_VERSION})
endif()

if(_COMPILER MATCHES MSVC)
  set(_COMPILER "msvc")
  string(SUBSTRING ${MSVC_VERSION} 0 3 _COMPILER_VERSION)
elseif(_COMPILER MATCHES AppleClang)
  set(_COMPILER "apple-clang")
  string(REPLACE "." ";" VERSION_LIST ${CMAKE_CXX_COMPILER_VERSION})
  list(GET VERSION_LIST 0 _COMPILER_VERSION)
elseif(_COMPILER MATCHES Clang)
  set(_COMPILER "clang")
  string(REPLACE "." ";" VERSION_LIST ${CMAKE_CXX_COMPILER_VERSION})
  list(GET VERSION_LIST 0 _COMPILER_VERSION)
elseif(_COMPILER MATCHES GNU)
  set(_COMPILER "gcc")
  string(REPLACE "." ";" VERSION_LIST ${CMAKE_CXX_COMPILER_VERSION})
  list(GET VERSION_LIST 0 _COMPILER_VERSION)
endif()

execute_process(
  COMMAND
    ${_CONAN_EXEC} "install" "${CMAKE_CURRENT_SOURCE_DIR}" "--output-folder=${_CONAN_BUILD_ROOT_PATH}"
    "--build=missing" "--settings:host=build_type=${CMAKE_BUILD_TYPE}" "--settings:host=compiler=${_COMPILER}"
    "--settings:build=compiler=${_COMPILER}" "--settings:host=compiler.cppstd=${CMAKE_CXX_STANDARD}"
    "--settings:build=compiler.version=${_COMPILER_VERSION}" "--settings:host=compiler.version=${_COMPILER_VERSION}"
    "--settings:build=build_type=${CMAKE_BUILD_TYPE}" "--settings:build=compiler.cppstd=${CMAKE_CXX_STANDARD}"
    "--deployer" "direct_deploy" COMMAND_ERROR_IS_FATAL LAST
)

list(APPEND CMAKE_PREFIX_PATH "${_CONAN_BUILD_ROOT_PATH}")
endblock()
