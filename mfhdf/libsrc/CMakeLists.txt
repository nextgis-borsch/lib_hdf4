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

include_directories (${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_BINARY_DIR})
#-----------------------------------------------------------------------------
# Generate the netcdf.h file containing user settings needed by compilation
#-----------------------------------------------------------------------------
if (WIN32)
  set (H4_WINDOWS_INCLUDE_FILE "#include <hdfi.h>")
  set (NETCDF_EXTERN HDFLIBAPI)
else (WIN32)
  set (NETCDF_EXTERN extern)
endif (WIN32)

set (NC_OLD_FILLVALUES 0)

set (HDF4_MFHDF_LIBSRC_CSRCS
    array.c
    attr.c
    cdf.c
    dim.c
    file.c
    hdfsds.c
    iarray.c
    error.c
    globdef.c
    mfdatainfo.c
    mfsd.c
    nssdc.c
    putget.c
    putgetg.c
    sharray.c
    string.c
    var.c
    xdrposix.c
)

set (HDF4_MFHDF_LIBSRC_CHDRS
    alloc.h
    error.h
    local_nc.h
    mfhdf.h
    mfhdfi.h
    mfdatainfo.h
    hdf2netcdf.h
)

if (HDF4_ENABLE_NETCDF)
  configure_file (netcdf.h.in ${CMAKE_BINARY_DIR}/netcdf.h)
  set (HDF4_MFHDF_LIBSRC_XCHDRS ${CMAKE_BINARY_DIR}/netcdf.h)
else ()
  configure_file (netcdf.h.in ${CMAKE_BINARY_DIR}/hdf4_netcdf.h)
  set (HDF4_MFHDF_LIBSRC_XCHDRS ${CMAKE_BINARY_DIR}/hdf4_netcdf.h)
endif ()

if (CYGWIN)
  include_directories (/usr/include/tirpc)
else (CYGWIN)
  include_directories (/usr/include/rpc)
endif (CYGWIN)

set(PUBLIC_HEADERS
    ${HDF4_MFHDF_LIBSRC_CHDRS} ${HDF4_MFHDF_LIBSRC_XCHDRS}
)

include_directories (${HDF4_HDFSOURCE_DIR})
include_directories (${CMAKE_CURRENT_SOURCE_DIR})

add_definitions (-DHDF)

if (WIN32)
  add_definitions (-DDOS_FS -DSWAP)
endif (WIN32)

set(LIB_NAME ${HDF4_MF_LIB})
if(BUILD_SHARED_LIBS)
    add_library(${LIB_NAME} SHARED ${HDF4_MFHDF_LIBSRC_CSRCS} ${PUBLIC_HEADERS})
    set_target_properties (${LIB_NAME} PROPERTIES
        VERSION ${VERSION}
        SOVERSION ${SO_VERSION})
elseif(OSX_FRAMEWORK)
    add_library(${LIB_NAME} SHARED ${HDF4_MFHDF_LIBSRC_CSRCS} ${PUBLIC_HEADERS})
    set_target_properties(${LIB_NAME} PROPERTIES
      FRAMEWORK TRUE
      FRAMEWORK_VERSION ${FRAMEWORK_VERSION}
      MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${VERSION}
      MACOSX_FRAMEWORK_BUNDLE_VERSION ${VERSION}
      MACOSX_FRAMEWORK_IDENTIFIER org.libhdf.libmf
      XCODE_ATTRIBUTE_INSTALL_PATH "@rpath"
      PUBLIC_HEADER "${PUBLIC_HEADERS}"
      VERSION ${VERSION}
      SOVERSION ${SO_VERSION}
      )
else()
    add_library(${LIB_NAME} STATIC ${HDF4_MFHDF_LIBSRC_CSRCS} ${PUBLIC_HEADERS})
endif()

if(TARGET_LINK_LIB)
    target_link_libraries(${LIB_NAME} ${TARGET_LINK_LIB})
endif()
if(DEPENDENCY_LIB)
    add_dependencies(${LIB_NAME} ${DEPENDENCY_LIB})
endif()

if (HDF4_BUILD_XDR_LIB)
  if (WIN32)
    add_definitions (-DNO_SYS_XDR_INC)
  endif (WIN32)
  include_directories (${HDF4_MFHDF_XDR_DIR})
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
    install(FILES ${PUBLIC_HEADERS} DESTINATION ${INSTALL_INC_DIR} COMPONENT headers)
endif()
