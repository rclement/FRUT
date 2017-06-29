# Copyright (c) 2017 Alain Martin
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

get_filename_component(exporter_projucer_build_dir
  "${jucer_DIR}/Builds/MacOSX" ABSOLUTE
)
get_filename_component(exporter_reprojucer_build_dir
  "${jucer_DIR}/MacOSX_build" ABSOLUTE
)

set(exporter_cmake_generator "Xcode")


function(xcode_compile_project build_dir out_compile_cmd)

  execute_process(
    COMMAND "${CMAKE_MAKE_PROGRAM}" "-configuration" "${configuration}" "clean"
    WORKING_DIRECTORY "${build_dir}"
    OUTPUT_VARIABLE ignored
  )

  execute_process(
    COMMAND "${CMAKE_MAKE_PROGRAM}" "-configuration" "${configuration}" "build"
    WORKING_DIRECTORY "${build_dir}"
    OUTPUT_VARIABLE xcodebuild_output
    RESULT_VARIABLE result
  )

  if(NOT result EQUAL 0)
    message("${xcodebuild_output}")
    message(FATAL_ERROR "")
  endif()

  string(REGEX MATCH "\n[ ]+([^\n]+-c [^\n]+main.cpp -o [^\n]+main.o)\n" m "${xcodebuild_output}")
  set(${out_compile_cmd} "${CMAKE_MATCH_1}" PARENT_SCOPE)

endfunction()


function(exporter_compile_projucer_project out_compile_cmd)

  xcode_compile_project("${exporter_projucer_build_dir}" compile_cmd)
  set(${out_compile_cmd} "${compile_cmd}" PARENT_SCOPE)

endfunction()


function(exporter_compile_reprojucer_project out_compile_cmd)

  xcode_compile_project("${exporter_reprojucer_build_dir}" compile_cmd)
  set(${out_compile_cmd} "${compile_cmd}" PARENT_SCOPE)

endfunction()
