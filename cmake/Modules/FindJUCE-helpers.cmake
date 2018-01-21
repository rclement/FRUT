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

if(_FRUT_FindJUCE_helpers_INCLUDED)
  return()
endif()
set(_FRUT_FindJUCE_helpers_INCLUDED TRUE)


function(_FRUT_add_target_from_module_header_file module_header_file)

  set(package_name ${CMAKE_FIND_PACKAGE_NAME})

  if(CMAKE_VERSION VERSION_LESS 3.1)
    string(APPEND ${package_name}_NOT_FOUND_MSG
      "\n${package_name} requires at least CMake version 3.1"
    )
    set(${package_name}_NOT_FOUND_MSG ${${package_name}_NOT_FOUND_MSG} PARENT_SCOPE)
    return()
  endif()

  _FRUT_parse_module_header_file("${module_header_file}")

  if(NOT module_ID STREQUAL "${package_name}")
    string(APPEND ${package_name}_NOT_FOUND_MSG
      "\nUnexpected ID \"${module_ID}\" in the ${package_name} header file."
      " Please check that your installation of JUCE is not corrupted."
    )
    set(${package_name}_NOT_FOUND_MSG ${${package_name}_NOT_FOUND_MSG} PARENT_SCOPE)
    return()
  endif()

  set(${package_name}_VERSION "${module_version}" PARENT_SCOPE)

  # TODO, handle ${package_name}_FIND_VERSION and ${package_name}_FIND_VERSION_EXACT
  if(${package_name}_FIND_VERSION_EXACT
      AND NOT ${package_name}_FIND_VERSION VERSION_EQUAL module_version)
    string(APPEND ${package_name}_NOT_FOUND_MSG "\nFound version ${module_version} "
      "doesn't match requested version ${${package_name}_FIND_VERSION}."
    )
    set(${package_name}_NOT_FOUND_MSG ${${package_name}_NOT_FOUND_MSG} PARENT_SCOPE)
    return()
  endif()

  unset(compile_options)
  unset(link_libraries)
  unset(sources)

  set(compile_definitions "JUCE_MODULE_AVAILABLE_${package_name}")

  if(module_dependencies)
    foreach(dependency ${module_dependencies})
      if(NOT ${dependency}_FOUND)
        set(exact_kw)
        if(${package_name}_FIND_VERSION_EXACT)
          set(exact_kw EXACT)
        endif()
        set(quiet_kw)
        if(${package_name}_FIND_QUIETLY)
          set(quiet_kw QUIET)
        endif()
        set(required_kw)
        if(${package_name}_FIND_REQUIRED)
          set(required_kw REQUIRED)
        endif()
        find_package(${dependency} ${${package_name}_FIND_VERSION}
          ${exact_kw} ${quiet_kw} ${required_kw}
        )
        if(${dependency}_FOUND)
          list(APPEND link_libraries JUCE::${dependency})
        else()
          string(APPEND ${package_name}_NOT_FOUND_MSG
            "\nCould not find ${dependency}."
          )
        endif()
      endif()
    endforeach()
  endif()

  if(APPLE)
    if(module_OSXFrameworks)
      foreach(framework_name ${module_OSXFrameworks})
        find_library(${framework_name}_framework ${framework_name})
        if(NOT ${framework_name}_framework)
          string(APPEND ${package_name}_NOT_FOUND_MSG
            "\nCould not find OSX framework ${framework_name}."
          )
        endif()
        list(APPEND link_libraries "${${framework_name}_framework}")
      endforeach()
    endif()
  endif()

  if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
    if(module_linuxPackages)
      find_package(PkgConfig REQUIRED)
      foreach(package_name ${module_linuxPackages})
        pkg_check_modules(${package_name}_pkg "${package_name}")
        if(NOT ${package_name}_pkg_FOUND)
          string(APPEND ${package_name}_NOT_FOUND_MSG
            "\npkg-config could not find ${package_name}."
          )
        endif()
        list(APPEND compile_options ${${package_name}_pkg_CFLAGS})
        list(APPEND link_libraries ${${package_name}_pkg_LIBRARIES})
      endforeach()
    endif()

    if(module_linuxLibs)
      foreach(linux_lib ${module_linuxLibs})
        if(linux_lib STREQUAL "pthread")
          list(APPEND compile_options "-pthread")
        endif()
        list(APPEND link_libraries "-l${linux_lib}")
      endforeach()
    endif()
  endif()

  if(WIN32 AND NOT MSVC) # MinGW
    if(module_mingwLibs)
      foreach(mingw_lib ${module_mingwLibs})
        list(APPEND link_libraries "-l${mingw_lib}")
      endforeach()
    endif()
  endif()

  get_filename_component(module_folder "${module_header_file}" DIRECTORY)

  file(GLOB module_src_files "${module_folder}/*.cpp" "${module_folder}/*.mm")
  foreach(src_file ${module_src_files})
    set(to_compile FALSE)

    get_filename_component(src_file_extension "${src_file}" EXT)
    if(src_file_extension STREQUAL ".mm")
      if(APPLE)
        set(to_compile TRUE)
      endif()
    elseif(APPLE)
      string(REGEX REPLACE ".cpp$" ".mm" objcxx_src_file "${src_file}")
      if(NOT "${objcxx_src_file}" IN_LIST module_src_files)
        set(to_compile TRUE)
      endif()
    else()
      set(to_compile TRUE)
    endif()

    if(to_compile)
      list(APPEND sources "${src_file}")
    endif()
  endforeach()

  if(NOT ${package_name}_NOT_FOUND_MSG)
    add_library(JUCE::${package_name} INTERFACE IMPORTED)
    set_target_properties(JUCE::${package_name} PROPERTIES
      INTERFACE_COMPILE_DEFINITIONS "${compile_definitions}"
      INTERFACE_COMPILE_OPTIONS "${compile_options}"
      INTERFACE_LINK_LIBRARIES "${link_libraries}"
      INTERFACE_SOURCES "${sources}"
    )
  endif()

  set(${package_name}_NOT_FOUND_MSG ${${package_name}_NOT_FOUND_MSG} PARENT_SCOPE)

endfunction()


function(_FRUT_parse_module_header_file module_header_file)

  if(NOT EXISTS "${module_header_file}")
    message(FATAL_ERROR "No such file: ${module_header_file}")
  endif()

  set(compulsory_keys
    ID
    version
  )

  set(space_or_comma_list_keys
    dependencies
    OSXFrameworks
    iOSFrameworks
    linuxLibs
    linuxPackages
    mingwLibs
  )

  foreach(key ${compulsory_keys} ${space_or_comma_list_keys})
    set(module_${key})
  endforeach()

  file(STRINGS "${module_header_file}" all_lines)
  set(in_module_declaration FALSE)
  foreach(line ${all_lines})
    string(STRIP "${line}" stripped_line)
    if(stripped_line MATCHES "^BEGIN_JUCE_MODULE_DECLARATION")
      set(in_module_declaration TRUE)
      continue()
    elseif(stripped_line MATCHES "^END_JUCE_MODULE_DECLARATION")
      break()
    endif()

    if(in_module_declaration)
      string(FIND "${line}" ":" colon_pos)
      if(NOT colon_pos EQUAL -1)
        string(SUBSTRING "${line}" 0 ${colon_pos} key)
        string(STRIP "${key}" key)
        math(EXPR colon_pos_plus_one "${colon_pos} + 1")
        string(SUBSTRING "${line}" ${colon_pos_plus_one} -1 value)
        string(STRIP "${value}" value)
        set(module_${key} ${value})
      endif()
    endif()
  endforeach()

  foreach(key ${space_or_comma_list_keys})
    if(module_${key})
      string(REPLACE " " ";" module_${key} "${module_${key}}")
      string(REPLACE "," ";" module_${key} "${module_${key}}")
      list(SORT module_${key})
      list(REMOVE_DUPLICATES module_${key})
    endif()
  endforeach()

  foreach(key ${compulsory_keys} ${space_or_comma_list_keys})
    set(module_${key} ${module_${key}} PARENT_SCOPE)
  endforeach()

endfunction()
