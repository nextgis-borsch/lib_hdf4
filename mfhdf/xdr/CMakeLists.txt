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
endif()

set(LIB_NAME ${HDF4_MF_XDR})
if(BUILD_SHARED_LIBS)
    add_library(${LIB_NAME} SHARED ${HDF4_MFHDF_XDR_SRCS} ${HDF4_MFHDF_XDR_HDRS} ${HDF4_MFHDF_XDR_PUBLIC})
    set_target_properties (${LIB_NAME} PROPERTIES
        VERSION ${VERSION}
        SOVERSION ${SO_VERSION})
elseif(OSX_FRAMEWORK)
    add_library(${LIB_NAME} SHARED ${HDF4_MFHDF_XDR_SRCS} ${HDF4_MFHDF_XDR_HDRS} ${HDF4_MFHDF_XDR_PUBLIC})
    set_target_properties(${LIB_NAME} PROPERTIES
      FRAMEWORK TRUE
      FRAMEWORK_VERSION ${FRAMEWORK_VERSION}
      MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${VERSION}
      MACOSX_FRAMEWORK_BUNDLE_VERSION ${VERSION}
      MACOSX_FRAMEWORK_IDENTIFIER org.libhdf.libxdr
      XCODE_ATTRIBUTE_INSTALL_PATH "@rpath"
      PUBLIC_HEADER "${HDF4_MFHDF_XDR_PUBLIC}"
      VERSION ${VERSION}
      SOVERSION ${SO_VERSION}
      )
else()
    add_library(${LIB_NAME} STATIC ${HDF4_MFHDF_XDR_SRCS} ${HDF4_MFHDF_XDR_HDRS} ${HDF4_MFHDF_XDR_PUBLIC})
endif()


if (MSVC OR MINGW)
  target_link_libraries (${LIB_NAME} "ws2_32.lib")
endif ()

if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL)
    install(TARGETS ${LIB_NAME}
        RUNTIME DESTINATION ${INSTALL_BIN_DIR} COMPONENT applications
        ARCHIVE DESTINATION ${INSTALL_LIB_DIR} COMPONENT libraries
        LIBRARY DESTINATION ${INSTALL_LIB_DIR} COMPONENT libraries
        FRAMEWORK DESTINATION ${INSTALL_LIB_DIR}
    )
endif()
if(NOT SKIP_INSTALL_HEADERS AND NOT SKIP_INSTALL_ALL )
    install(FILES ${HDF4_MFHDF_XDR_PUBLIC} DESTINATION ${INSTALL_INC_DIR} COMPONENT headers)
endif()
