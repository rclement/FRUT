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

include("${CMAKE_CURRENT_LIST_DIR}/VS.cmake")


get_filename_component(exporter_projucer_build_dir
  "${jucer_DIR}/Builds/VisualStudio2013" ABSOLUTE
)
get_filename_component(exporter_reprojucer_build_dir
  "${jucer_DIR}/VisualStudio2013_build" ABSOLUTE
)

set(exporter_cmake_generator "Visual Studio 12 2013")


function(exporter_compile_projucer_project out_compile_cmd)

  vs_compile_project("${exporter_projucer_build_dir}" compile_cmd)
  set(${out_compile_cmd} "${compile_cmd}" PARENT_SCOPE)

endfunction()


function(exporter_compile_reprojucer_project out_compile_cmd)

  vs_compile_project("${exporter_reprojucer_build_dir}" compile_cmd)
  set(${out_compile_cmd} "${compile_cmd}" PARENT_SCOPE)

endfunction()
