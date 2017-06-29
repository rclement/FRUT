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

function(vs_compile_project build_dir out_compile_cmd)

  get_filename_component(jucer_file_name "${jucer_FILE}" NAME)
  get_filename_component(jucer_file_name_we "${jucer_file_name}" NAME_WE)

  set(msbuild_command
    "${CMAKE_MAKE_PROGRAM}"
    "/v:minimal"
    "/clp:ShowCommandLine"
    "/t:Rebuild"
    "/property:Configuration=${configuration}"
    "${jucer_file_name_we}.sln"
  )

  execute_process(
    COMMAND ${msbuild_command}
    WORKING_DIRECTORY "${build_dir}"
    OUTPUT_VARIABLE msbuild_output
    RESULT_VARIABLE result
  )

  if(NOT result EQUAL 0)
    message("${msbuild_output}")
    message(FATAL_ERROR "")
  endif()

  string(REGEX MATCH "\n  ([^\n]+CL.exe[^\n]+)\n" m "${msbuild_output}")
  set(${out_compile_cmd} "${CMAKE_MATCH_1}" PARENT_SCOPE)

endfunction()
