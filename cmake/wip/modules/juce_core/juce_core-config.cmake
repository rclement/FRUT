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

if(NOT TARGET JUCE::juce_core)

  if(NOT DEFINED JUCE_ROOT)
    set(juce_core_FOUND FALSE)
    set(juce_core_NOT_FOUND_MESSAGE "JUCE_ROOT must be defined")
    return()
  endif()

  if(CMAKE_VERSION VERSION_LESS 3.1)
    set(juce_core_FOUND FALSE)
    set(juce_core_NOT_FOUND_MESSAGE "juce_core requires at least CMake version 3.1")
    return()
  endif()

  include("${CMAKE_CURRENT_LIST_DIR}/../JUCE-macros.cmake")
  _JUCE_add_target_from_module_header(
    "${JUCE_ROOT}/modules/juce_core/juce_core.h"
  )

  string(CONCAT _define_JUCE_STANDALONE_APPLICATION
    "JUCE_STANDALONE_APPLICATION=$<OR:"
      "$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>,"
      "$<STREQUAL:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY>"
    ">"
  )
  set_property(TARGET JUCE::juce_core PROPERTY
    INTERFACE_COMPILE_DEFINITIONS
      "JUCE_GLOBAL_MODULE_SETTINGS_INCLUDED"
      "${_define_JUCE_STANDALONE_APPLICATION}"
  )

  set_property(TARGET JUCE::juce_core PROPERTY
    INTERFACE_INCLUDE_DIRECTORIES "${JUCE_ROOT}/modules"
  )

endif()
