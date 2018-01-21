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

set(juce_core_NOT_FOUND_REASON)

if(NOT TARGET JUCE::juce_core)
  find_file(juce_core_header "juce_core/juce_core.h"
    HINTS "${JUCE_ROOT}/modules" "${JUCE_MODULES_DIR}"
  )

  if(NOT juce_core_header)
    string(APPEND juce_core_NOT_FOUND_REASON
      "\nUnable to find the juce_core header file."
      " Please set JUCE_ROOT to the root directory containing JUCE or"
      " set JUCE_MODULES_DIR to the directory containing JUCE's modules."
    )

  else()
    include("${CMAKE_CURRENT_LIST_DIR}/FindJUCE-helpers.cmake")
    _JUCE_add_target_from_module_header("${juce_core_header}" juce_core)

    if(TARGET JUCE::juce_core)
      string(CONCAT _define_JUCE_STANDALONE_APPLICATION
        "JUCE_STANDALONE_APPLICATION=$<OR:"
          "$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>,"
          "$<STREQUAL:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY>"
        ">"
      )
      set_property(TARGET JUCE::juce_core APPEND PROPERTY
        INTERFACE_COMPILE_DEFINITIONS
        "JUCE_GLOBAL_MODULE_SETTINGS_INCLUDED"
        "${_define_JUCE_STANDALONE_APPLICATION}"
      )

      get_filename_component(juce_core_dir "${juce_core_header}" DIRECTORY)
      get_filename_component(juce_modules_dir "${juce_core_dir}" DIRECTORY)
      set_property(TARGET JUCE::juce_core APPEND PROPERTY
        INTERFACE_INCLUDE_DIRECTORIES "${juce_modules_dir}"
      )
    endif()
  endif()
endif()

if(juce_core_NOT_FOUND_REASON)
  set(juce_core_FOUND FALSE)
else()
  set(juce_core_FOUND TRUE)
endif()

if(juce_core_FOUND)
  if(NOT juce_core_FIND_QUIETLY)
    message(STATUS "Found juce_core (${juce_core_VERSION})")
  endif()
else()
  if(juce_core_FIND_REQUIRED)
    message(SEND_ERROR "Could not find juce_core${juce_core_NOT_FOUND_REASON}\n")
  elseif(NOT juce_core_FIND_QUIETLY)
    message(STATUS "Could not find juce_core")
  endif()
endif()
