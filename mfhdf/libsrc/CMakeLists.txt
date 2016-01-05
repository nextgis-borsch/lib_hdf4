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

include_directories (${CMAKE_CURENT_SOURCE_DIR} ${CMAKE_BINARY_DIR})
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

include_directories (${HDF4_HDFSOURCE_DIR})
include_directories (${CMAKE_CURRENT_SOURCE_DIR})

add_definitions (-DHDF)

if (WIN32)
  add_definitions (-DDOS_FS -DSWAP)
endif (WIN32)

add_library (${HDF4_MF_LIB} ${LIB_TYPE} ${HDF4_MFHDF_LIBSRC_CSRCS} ${HDF4_MFHDF_LIBSRC_CHDRS})
if (BUILD_SHARED_LIBS)
    if (WIN32)
      set (LIB_VERSION ${HDF4_PACKAGE_VERSION_MAJOR})
    else ()
      set (LIB_VERSION ${HDF4_PACKAGE_VERSION})
    endif ()
    set_target_properties (${HDF4_MF_LIB} PROPERTIES VERSION ${LIB_VERSION})
    set_target_properties (${HDF4_MF_LIB} PROPERTIES SOVERSION ${LIB_VERSION})
endif ()

#-- Apple Specific install_name for libraries
if (APPLE)
    option (H4_BUILD_WITH_INSTALL_NAME "Build with library install_name set to the installation path" OFF)
    if (H4_BUILD_WITH_INSTALL_NAME)
      set_target_properties(HDF4_MF_LIB PROPERTIES
          LINK_FLAGS "-current_version ${HDF4_PACKAGE_VERSION} -compatibility_version ${HDF4_PACKAGE_VERSION}"
          INSTALL_NAME_DIR "${INSTALL_LIB_DIR}"
          BUILD_WITH_INSTALL_RPATH ${H4_BUILD_WITH_INSTALL_NAME}
      )
    endif ()
endif ()

if (HDF4_BUILD_XDR_LIB)
  if (WIN32)
    add_definitions (-DNO_SYS_XDR_INC)
  endif (WIN32)
  include_directories (${HDF4_MFHDF_XDR_DIR})  
endif (HDF4_BUILD_XDR_LIB)

if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL )
    install(TARGETS ${HDF4_MF_LIB} 
        RUNTIME DESTINATION "${INSTALL_BIN_DIR}"
        ARCHIVE DESTINATION "${INSTALL_LIB_DIR}"
        LIBRARY DESTINATION "${INSTALL_LIB_DIR}" )
endif()
if(NOT SKIP_INSTALL_HEADERS AND NOT SKIP_INSTALL_ALL )
    install(FILES ${HDF4_MFHDF_LIBSRC_CHDRS} ${HDF4_MFHDF_LIBSRC_XCHDRS} DESTINATION "${INSTALL_INC_DIR}")
endif()


