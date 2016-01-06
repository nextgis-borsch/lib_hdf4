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

set (HDF4_MFHDF_XDR_SRCS
    xdr.c
    xdrfloat.c
    xdrstdio.c
    xdrarray.c
)

set (HDF4_MFHDF_XDR_HDRS
    types.h
)

set (HDF4_MFHDF_XDR_PUBLIC
    xdr.h
)

include_directories (${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_BINARY_DIR})
include_directories (${HDF4_HDFSOURCE_DIR})

add_definitions (-DHDF)

if (WIN32)
  add_definitions (-DDOS_FS -DNO_SYS_XDR_INC)
  set(HDF4_MFHDF_XDR_SRCS ${HDF4_MFHDF_XDR_SRCS} xdr.def)
endif (WIN32)

if (MSVC OR MINGW)
  add_library (${HDF4_MF_XDR} ${LIB_TYPE} ${HDF4_MFHDF_XDR_SRCS} ${HDF4_MFHDF_XDR_HDRS} ${HDF4_MFHDF_XDR_PUBLIC})
  target_link_libraries (${HDF4_MF_XDR} "ws2_32.lib")
else ()
  add_library (${HDF4_MF_XDR} ${LIB_TYPE} ${HDF4_MFHDF_XDR_SRCS} ${HDF4_MFHDF_XDR_HDRS} ${HDF4_MFHDF_XDR_PUBLIC})
endif ()

if (BUILD_SHARED_LIBS)
    if (WIN32)
      set (LIB_VERSION ${HDF4_PACKAGE_VERSION_MAJOR})
    else ()
      set (LIB_VERSION ${HDF4_PACKAGE_VERSION})
    endif ()
    set_target_properties (${HDF4_MF_XDR} PROPERTIES VERSION ${LIB_VERSION})
    set_target_properties (${HDF4_MF_XDR} PROPERTIES SOVERSION ${LIB_VERSION})
endif ()

#-- Apple Specific install_name for libraries
if (APPLE)
    option (H4_BUILD_WITH_INSTALL_NAME "Build with library install_name set to the installation path" OFF)
    if (H4_BUILD_WITH_INSTALL_NAME)
      set_target_properties(HDF4_MF_XDR PROPERTIES
          LINK_FLAGS "-current_version ${HDF4_PACKAGE_VERSION} -compatibility_version ${HDF4_PACKAGE_VERSION}"
          INSTALL_NAME_DIR "${INSTALL_LIB_DIR}"
          BUILD_WITH_INSTALL_RPATH ${H4_BUILD_WITH_INSTALL_NAME}
      )
    endif ()
endif ()

if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL )
    install(TARGETS ${HDF4_MF_XDR} 
        RUNTIME DESTINATION "${INSTALL_BIN_DIR}"
        ARCHIVE DESTINATION "${INSTALL_LIB_DIR}"
        LIBRARY DESTINATION "${INSTALL_LIB_DIR}" )
endif()
if(NOT SKIP_INSTALL_HEADERS AND NOT SKIP_INSTALL_ALL )
    install(FILES ${HDF4_MFHDF_XDR_PUBLIC} DESTINATION "${INSTALL_INC_DIR}")
endif()

