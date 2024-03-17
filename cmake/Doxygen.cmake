include_guard(GLOBAL)

find_package(Doxygen REQUIRED)

include(FetchContent)
FetchContent_Declare(
  doxygen-awesome-css
  GIT_REPOSITORY https://github.com/jothepro/doxygen-awesome-css.git
  SOURCE_DIR
  "${_DOXYAWS_BIN_DIR}"
  DOWNLOAD_DIR
  "${_DOXYAWS_DOWNLOAD_DIR}"
  BINARY_DIR
  "${_DOXYAWS_BUILD_DIR}"
  GIT_TAG v2.3.1
)
FetchContent_MakeAvailable(doxygen-awesome-css)

function(Doxygen input_dir out_dir)
  set(_DOXYGEN_NAME "doxygen")
  set(DOXYGEN_HTML_OUTPUT ${PROJECT_BINARY_DIR}/${out_dir})
  set(DOXYGEN_USE_MDFILE_AS_MAINPAGE "${CMAKE_SOURCE_DIR}/README.md")
  set(DOXYGEN_USE_MATHJAX YES) # better formula rendering
  set(DOXYGEN_JAVADOC_AUTOBRIEF "YES") # for short '///' docstring support
  set(DOXYGEN_BUILTIN_STL_SUPPORT YES)
  set(DOXYGEN_EXTRACT_LOCAL_CLASSES NO)
  set(DOXYGEN_GENERATE_HTML "YES")
  set(DOXYGEN_GENERATE_TREEVIEW "YES")
  set(DOXYGEN_HAVE_DOT "YES")
  set(DOXYGEN_DOT_IMAGE_FORMAT "svg")
  set(DOXYGEN_DOT_TRANSPARENT "YES")
  set(DOXYGEN_HTML_EXTRA_STYLESHEET "${doxygen-awesome-css_SOURCE_DIR}/doxygen-awesome.css;\
        ${doxygen-awesome-css_SOURCE_DIR}/doxygen-awesome-sidebar-only.css"
  )
  set(DOXYGEN_DISABLE_INDEX "NO")
  set(DOXYGEN_FULL_SIDEBAR "NO")
  set(DOXYGEN_HTML_COLORSTYLE "LIGHT")
  doxygen_add_docs(${_DOXYGEN_NAME} ${PROJECT_SOURCE_DIR}/${input_dir} COMMENT "Generate HTML documentation")
endfunction()
