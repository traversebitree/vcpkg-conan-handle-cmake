add_executable(app main.cpp)
target_link_libraries(app PRIVATE CURL::libcurl fmt::fmt ZLIB::ZLIB)

if(WIN32)
  add_custom_command(
    TARGET app
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_RUNTIME_DLLS:app> $<TARGET_FILE_DIR:app>
    COMMAND_EXPAND_LISTS
  )
endif()

set_target_properties(app PROPERTIES INSTALL_RPATH "$ORIGIN")
