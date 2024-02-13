include_guard(GLOBAL)
include(GNUInstallDirs)

function(install_target)
  set(prefix "INSTALL")
  set(no_values "")
  set(single_values "")
  set(multi_values "EXEs" "LIBs" "ASSETs")
  cmake_parse_arguments(
    PARSE_ARGV
    0
    "${prefix}"
    "${no_values}"
    "${single_values}"
    "${multi_values}"
  )
  foreach(tgt IN ITEMS ${${prefix}_EXEs})
    install_exe(${tgt})
  endforeach()
endfunction()

macro(install_exe tgt)
  install(TARGETS ${tgt} RUNTIME COMPONENT "${tgt}_exe" DESTINATION ${CMAKE_INSTALL_BINDIR})
  install(FILES $<TARGET_RUNTIME_DLLS:${tgt}> COMPONENT "${tgt}_dll" DESTINATION ${CMAKE_INSTALL_BINDIR})
  if(MINGW AND ${CMAKE_CXX_COMPILER_ID} MATCHES "GNU")
    get_filename_component(mingw_path ${CMAKE_CXX_COMPILER} PATH)
    file(GLOB mingw_runtimes "${mingw_path}/*.dll")
    list(FILTER mingw_runtimes EXCLUDE REGEX "fortran")
    set(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS ${mingw_runtimes})
    install(PROGRAMS ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS} DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT "${tgt}_dll")
  endif()

  if(NOT WIN32)
    install(
      CODE "
        file(GET_RUNTIME_DEPENDENCIES
            RESOLVED_DEPENDENCIES_VAR RESOLVED_DEPS
            UNRESOLVED_DEPENDENCIES_VAR UNRESOLVED_DEPS
            LIBRARIES $<TARGET_FILE:${tgt}>
            DIRECTORIES $<TARGET_FILE_DIR:${tgt}>
            PRE_INCLUDE_REGEXES $<TARGET_FILE_DIR:${tgt}>
            POST_INCLUDE_REGEXES $<TARGET_FILE_DIR:${tgt}>
        )
        foreach(DEP_LIB \${RESOLVED_DEPS})
            file(INSTALL \${DEP_LIB} DESTINATION \${CMAKE_INSTALL_PREFIX}/bin)
        endforeach()
                  "
      COMPONENT "${tgt}_dll"
    )
  endif()

  add_custom_target(
    install_${tgt}
    COMMAND ${CMAKE_COMMAND} --install ${CMAKE_BINARY_DIR} --component "${tgt}_dll" --config "${CMAKE_BUILD_TYPE}"
    COMMAND ${CMAKE_COMMAND} --install ${CMAKE_BINARY_DIR} --component "${tgt}_exe" --config "${CMAKE_BUILD_TYPE}"
    DEPENDS ${tgt}
  )
endmacro()

macro(install_assets asset_dir)
  install(DIRECTORY "${asset_dir}" COMPONENT "assets" DESTINATION ${CMAKE_INSTALL_BINDIR})
endmacro()
