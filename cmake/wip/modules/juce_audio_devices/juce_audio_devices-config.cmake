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

if(NOT TARGET JUCE::juce_audio_devices)

  if(NOT DEFINED JUCE_ROOT)
    set(juce_audio_devices_FOUND FALSE)
    set(juce_audio_devices_NOT_FOUND_MESSAGE "JUCE_ROOT must be defined")
    return()
  endif()

  if(CMAKE_VERSION VERSION_LESS 3.1)
    set(juce_audio_devices_FOUND FALSE)
    set(juce_audio_devices_NOT_FOUND_MESSAGE "juce_audio_devices requires at least CMake version 3.1")
    return()
  endif()

  include("${CMAKE_CURRENT_LIST_DIR}/../JUCE-macros.cmake")
  _JUCE_add_target_from_module_header(
    "${JUCE_ROOT}/modules/juce_audio_devices/juce_audio_devices.h"
  )

endif()
