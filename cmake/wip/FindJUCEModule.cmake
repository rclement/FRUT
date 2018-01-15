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

set(${_JUCE_module}_FOUND TRUE)

if(NOT TARGET JUCE::${_JUCE_module})

  find_file(${_JUCE_module}_header "${_JUCE_module}/${_JUCE_module}.h"
    HINTS "${JUCE_ROOT}/modules" "${JUCE_MODULES_DIR}"
  )

  if(${_JUCE_module}_header)
    include("${CMAKE_CURRENT_LIST_DIR}/FindJUCE-helpers.cmake")
    _JUCE_add_target_from_module_header("${${_JUCE_module}_header}"
      "${${_JUCE_module}_FIND_VERSION_EXACT}"
      "${${_JUCE_module}_FIND_QUIETLY}"
      "${${_JUCE_module}_FIND_REQUIRED}"
    )
  else()
    set(${_JUCE_module}_FOUND FALSE)
    string(CONCAT ${_JUCE_module}_NOT_FOUND_REASON
      "Unable to find the ${_JUCE_module} header file."
      " Please set JUCE_ROOT to the root directory containing JUCE or"
      " set JUCE_MODULES_DIR to the directory containing JUCE's modules."
    )
  endif()
endif()

if(${_JUCE_module}_FOUND)
  if(NOT ${_JUCE_module}_FIND_QUIETLY)
    message(STATUS "Found ${_JUCE_module} (${${_JUCE_module}_VERSION})")
  endif()
else()
  if(${_JUCE_module}_FIND_REQUIRED)
    message(SEND_ERROR
      "Could not find ${_JUCE_module}\n${${_JUCE_module}_NOT_FOUND_REASON}\n"
    )
  elseif(NOT ${_JUCE_module}_FIND_QUIETLY)
    message(STATUS "Could not find ${_JUCE_module}")
  endif()
endif()
