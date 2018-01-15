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
  message(SEND_ERROR "The JUCE package requires at least one component")
  return()
endif()

list(SORT JUCE_FIND_COMPONENTS)
list(REMOVE_DUPLICATES JUCE_FIND_COMPONENTS)
set(_JUCE_modules)
set(_JUCE_optional_modules)
foreach(component ${JUCE_FIND_COMPONENTS})
  if(JUCE_FIND_REQUIRED_${component})
    list(APPEND _JUCE_modules ${component})
  else()
    list(APPEND _JUCE_optional_modules ${component})
  endif()
endforeach()

set(_JUCE_find_module_exact)
if(JUCE_FIND_VERSION_EXACT)
  set(_JUCE_find_module_exact EXACT)
endif()

set(_JUCE_find_module_quiet)
if(JUCE_FIND_QUIETLY)
  set(_JUCE_find_module_quiet QUIET)
endif()

set(_JUCE_find_module_required)
if(JUCE_FIND_REQUIRED)
  set(_JUCE_find_module_required REQUIRED)
endif()

if(_JUCE_modules)
  set(_JUCE_found_modules TRUE)
  foreach(module ${_JUCE_modules})
    find_package(${module}
      ${JUCE_FIND_VERSION}
      ${_JUCE_find_module_exact}
      ${_JUCE_find_module_quiet}
      ${_JUCE_find_module_required}
    )
    if(NOT ${module}_FOUND)
      set(_JUCE_found_modules FALSE)
    endif()
  endforeach()
else()
  set(_JUCE_found_modules FALSE)
endif()

set(_JUCE_found_optional_modules FALSE)
foreach(module ${_JUCE_optional_modules})
  find_package(${module}
    ${JUCE_FIND_VERSION}
    ${_JUCE_find_module_exact}
    ${_JUCE_find_module_quiet}
  )
  if(${module}_FOUND)
    set(_JUCE_found_optional_modules TRUE)
  endif()
endforeach()

if(_JUCE_found_modules)
  set(JUCE_FOUND TRUE)
elseif(_JUCE_found_optional_modules)
  set(JUCE_FOUND TRUE)
else()
  set(JUCE_FOUND FALSE)
endif()

if(JUCE_FOUND)
  if(NOT JUCE_FIND_QUIETLY)
    message(STATUS "Found JUCE")
  endif()
else()
  if(JUCE_FIND_REQUIRED)
    message(SEND_ERROR "Could not find JUCE")
  elseif(NOT JUCE_FIND_QUIETLY)
    message(STATUS "Could not find JUCE")
  endif()
endif()
