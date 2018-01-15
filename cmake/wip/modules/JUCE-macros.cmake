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

if(_FRUT_JUCE_macros_INCLUDED)
  return()
endif()
set(_FRUT_JUCE_macros_INCLUDED TRUE)


function(_JUCE_add_target_from_module_header module_header_file)

  if(NOT EXISTS "${module_header_file}")
    message(FATAL_ERROR "No such file: ${module_header_file}")
  endif()

  unset(module_info_ID)
  unset(module_info_dependencies)

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
        set(module_info_${key} ${value})
      endif()
    endif()
  endforeach()

  set(target JUCE::${module_info_ID})

  add_library(${target} INTERFACE IMPORTED)

  set_property(TARGET ${target} APPEND PROPERTY
    INTERFACE_COMPILE_DEFINITIONS "JUCE_MODULE_AVAILABLE_${module_info_ID}"
  )

  if(module_info_dependencies)
    string(REPLACE " " ";" dependencies "${module_info_dependencies}")
    string(REPLACE "," ";" dependencies "${dependencies}")
    list(SORT dependencies)
    list(REMOVE_DUPLICATES dependencies)
    foreach(juce_module ${dependencies})
      find_package(${juce_module} REQUIRED)
      set_property(TARGET ${target} APPEND PROPERTY
        INTERFACE_LINK_LIBRARIES JUCE::${juce_module}
      )
    endforeach()
  endif()

  if(APPLE)
    if(module_info_OSXFrameworks)
      string(REPLACE " " ";" osx_frameworks "${module_info_OSXFrameworks}")
      string(REPLACE "," ";" osx_frameworks "${osx_frameworks}")
      list(SORT osx_frameworks)
      list(REMOVE_DUPLICATES osx_frameworks)
      foreach(framework_name ${osx_frameworks})
        find_library(${framework_name}_framework ${framework_name})
        set_property(TARGET ${target} APPEND PROPERTY
          INTERFACE_LINK_LIBRARIES "${${framework_name}_framework}"
        )
      endforeach()
    endif()
  endif()

  if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
    if(module_info_linuxPackages)
      string(REPLACE " " ";" linux_packages "${module_info_linuxPackages}")
      string(REPLACE "," ";" linux_packages "${linux_packages}")
      list(SORT linux_packages)
      list(REMOVE_DUPLICATES linux_packages)
      find_package(PkgConfig REQUIRED)
      foreach(pkg ${linux_packages})
        pkg_check_modules(${pkg} "${pkg}")
        if(NOT ${pkg}_FOUND)
          message(FATAL_ERROR "pkg-config could not find ${pkg} required by ${target}")
        endif()
        set_property(TARGET ${target} APPEND PROPERTY
          INTERFACE_COMPILE_OPTIONS ${${pkg}_CFLAGS}
        )
        set_property(TARGET ${target} APPEND PROPERTY
          INTERFACE_LINK_LIBRARIES ${${pkg}_LIBRARIES}
        )
      endforeach()
    endif()

    if(module_info_linuxLibs)
      string(REPLACE " " ";" linux_libs "${module_info_linuxLibs}")
      string(REPLACE "," ";" linux_libs "${linux_libs}")
      list(SORT linux_libs)
      list(REMOVE_DUPLICATES linux_libs)
      foreach(lib ${linux_libs})
        if(lib STREQUAL "pthread")
          set_property(TARGET ${target} APPEND PROPERTY
            INTERFACE_COMPILE_OPTIONS "-pthread"
          )
        endif()
        set_property(TARGET ${target} APPEND PROPERTY
          INTERFACE_LINK_LIBRARIES "-l${lib}"
        )
      endforeach()
    endif()
  endif()

  if(WIN32 AND NOT MSVC) # MinGW
    if(module_info_mingwLibs)
      string(REPLACE " " ";" mingw_libs "${module_info_mingwLibs}")
      string(REPLACE "," ";" mingw_libs "${mingw_libs}")
      list(SORT mingw_libs)
      list(REMOVE_DUPLICATES mingw_libs)
      foreach(lib ${mingw_libs})
        set_property(TARGET ${target} APPEND PROPERTY
          INTERFACE_LINK_LIBRARIES "-l${lib}"
        )
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
      set_property(TARGET ${target} APPEND PROPERTY INTERFACE_SOURCES "${src_file}")
    endif()
  endforeach()

endfunction()
