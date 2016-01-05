################################################################################
# Project:  Lib hdf4
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, dmitry.baryshnikov@nexgis.com
################################################################################
# Copyright (C) 2015, NextGIS <info@nextgis.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
################################################################################

#-----------------------------------------------------------------------------
# Add file(s) to CMake Install
#-----------------------------------------------------------------------------

if (NOT HDF4_INSTALL_NO_DEVELOPMENT)
  install (
      FILES ${CMAKE_BINARY_DIR}/h4config.h
      DESTINATION ${INSTALL_INC_DIR}
      COMPONENT headers
  )
endif ()

#-----------------------------------------------------------------------------
# Add Target(s) to CMake Install for import into other projects
#-----------------------------------------------------------------------------
if (NOT SKIP_INSTALL_FILES AND NOT SKIP_INSTALL_ALL)
  install (
      FILES
          ${CMAKE_SOURCE_DIR}/COPYING
      DESTINATION ${INSTALL_DATA_DIR}
      COMPONENT hdfdocuments
  )
  if (EXISTS "${CMAKE_SOURCE_DIR}/release_notes" AND IS_DIRECTORY "${CMAKE_SOURCE_DIR}/release_notes")
    set (release_files
        ${CMAKE_SOURCE_DIR}/release_notes/USING_HDF4_CMake.txt
        ${CMAKE_SOURCE_DIR}/release_notes/RELEASE.txt
    )
    if (WIN32)
      set (release_files
          ${release_files}
          ${CMAKE_SOURCE_DIR}/release_notes/USING_HDF4_VS.txt
      )
    endif ()
    if (HDF4_PACK_INSTALL_DOCS)
      set (release_files
          ${release_files}
          ${CMAKE_SOURCE_DIR}/release_notes/INSTALL_CMake.txt
          ${CMAKE_SOURCE_DIR}/release_notes/HISTORY.txt
          ${CMAKE_SOURCE_DIR}/release_notes/INSTALL
      )
      if (WIN32)
        set (release_files
            ${release_files}
            ${CMAKE_SOURCE_DIR}/release_notes/INSTALL_Windows.txt
        )
      endif ()
      if (CYGWIN)
        set (release_files
            ${release_files}
            ${CMAKE_SOURCE_DIR}/release_notes/INSTALL_Cygwin.txt
        )
      endif ()
    endif ()
    install (
        FILES ${release_files}
        DESTINATION ${INSTALL_DATA_DIR}
        COMPONENT hdfdocuments
    )
    install(FILES man/gr_chunk.3 DESTINATION "${INSTALL_MAN_DIR}/man3")
    install(FILES "man/hdf.1" "man/hdfunpac.1" DESTINATION "${INSTALL_MAN_DIR}/man1")
  endif ()
endif ()

