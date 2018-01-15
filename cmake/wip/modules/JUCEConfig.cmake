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

if(NOT JUCE_FIND_COMPONENTS)
  set(JUCE_FOUND FALSE)
  set(JUCE_NOT_FOUND_MESSAGE "The JUCE package requires at least one component")
  return()
endif()

set(_JUCE_find_components_required)
if(JUCE_FIND_REQUIRED)
  set(_JUCE_find_components_required REQUIRED)
endif()

set(_JUCE_find_components_quiet)
if(JUCE_FIND_QUIETLY)
  set(_JUCE_find_components_quiet QUIET)
endif()

set(_JUCE_not_found)

foreach(module ${JUCE_FIND_COMPONENTS})
  find_package(${module}
    ${_JUCE_find_components_required}
    ${_JUCE_find_components_quiet}
  )
  if(NOT ${module}_FOUND)
    set(_JUCE_not_found TRUE)
  endif()
endforeach()

if(_JUCE_not_found)
  set(JUCE_FOUND FALSE)
endif()
