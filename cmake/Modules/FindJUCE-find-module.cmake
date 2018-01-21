# Copyright (c) 2018 Alain Martin
#
# This file is part of FRUT.
#
# FRUT is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# FRUT is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with FRUT.  If not, see <http://www.gnu.org/licenses/>.

if(TARGET JUCE::${CMAKE_FIND_PACKAGE_NAME})
  set(${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)
  return()
endif()

set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_REASON)

find_file(${CMAKE_FIND_PACKAGE_NAME}_header
  "${CMAKE_FIND_PACKAGE_NAME}/${CMAKE_FIND_PACKAGE_NAME}.h"
  HINTS "${JUCE_ROOT}/modules" "${JUCE_MODULES_DIR}"
)

if(NOT ${CMAKE_FIND_PACKAGE_NAME}_header)
  string(APPEND ${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_REASON
    "\nUnable to find the ${CMAKE_FIND_PACKAGE_NAME} header file."
    " Please set JUCE_ROOT to the root directory containing JUCE or"
    " set JUCE_MODULES_DIR to the directory containing JUCE's modules."
  )
else()
  include("${CMAKE_CURRENT_LIST_DIR}/FindJUCE-helpers.cmake")
  _FRUT_add_target_from_module_header("${${CMAKE_FIND_PACKAGE_NAME}_header}")
endif()

if(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_REASON)
  set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
else()
  set(${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)
endif()

if(${CMAKE_FIND_PACKAGE_NAME}_FOUND)
  if(NOT ${CMAKE_FIND_PACKAGE_NAME}_FIND_QUIETLY)
    message(STATUS "Found ${CMAKE_FIND_PACKAGE_NAME}"
      " (${${CMAKE_FIND_PACKAGE_NAME}_VERSION})"
    )
  endif()
else()
  if(${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED)
    message(SEND_ERROR "Could not find ${CMAKE_FIND_PACKAGE_NAME}"
      "${${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_REASON}\n"
    )
  elseif(NOT ${CMAKE_FIND_PACKAGE_NAME}_FIND_QUIETLY)
    message(STATUS "Could not find ${CMAKE_FIND_PACKAGE_NAME}")
  endif()
endif()
