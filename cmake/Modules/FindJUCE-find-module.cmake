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

if(TARGET JUCE::${_this_module})
  set(${_this_module}_FOUND TRUE)
  return()
endif()

set(${_this_module}_NOT_FOUND_REASON)

find_file(${_this_module}_header "${_this_module}/${_this_module}.h"
  HINTS "${JUCE_ROOT}/modules" "${JUCE_MODULES_DIR}"
)

if(NOT ${_this_module}_header)
  string(APPEND ${_this_module}_NOT_FOUND_REASON
    "\nUnable to find the ${_this_module} header file."
    " Please set JUCE_ROOT to the root directory containing JUCE or"
    " set JUCE_MODULES_DIR to the directory containing JUCE's modules."
  )
else()
  include("${CMAKE_CURRENT_LIST_DIR}/FindJUCE-helpers.cmake")
  _FRUT_add_target_from_module_header("${${_this_module}_header}" ${_this_module})
endif()

if(${_this_module}_NOT_FOUND_REASON)
  set(${_this_module}_FOUND FALSE)
else()
  set(${_this_module}_FOUND TRUE)
endif()

if(${_this_module}_FOUND)
  if(NOT ${_this_module}_FIND_QUIETLY)
    message(STATUS "Found ${_this_module} (${${_this_module}_VERSION})")
  endif()
else()
  if(${_this_module}_FIND_REQUIRED)
    message(SEND_ERROR
      "Could not find ${_this_module}${${_this_module}_NOT_FOUND_REASON}\n"
    )
  elseif(NOT ${_this_module}_FIND_QUIETLY)
    message(STATUS "Could not find ${_this_module}")
  endif()
endif()
