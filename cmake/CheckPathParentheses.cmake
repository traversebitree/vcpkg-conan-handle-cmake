include_guard(GLOBAL)

block()
cmake_path(ABSOLUTE_PATH CMAKE_CURRENT_SOURCE_DIR OUTPUT_VARIABLE CURRENT_PATH)
string(FIND "${CURRENT_PATH}" "(" FIND_L_INDEX)
string(FIND "${CURRENT_PATH}" ")" FIND_R_INDEX)
if((NOT FIND_L_INDEX EQUAL -1) OR (NOT FIND_R_INDEX EQUAL -1))
  message(FATAL_ERROR "Parentheses in the path.")
endif()
endblock()
