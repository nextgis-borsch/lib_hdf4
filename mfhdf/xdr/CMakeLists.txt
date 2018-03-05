################################################################################
# Project:  Lib hdf4
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, dmitry.baryshnikov@nexgis.com
################################################################################
# Copyright (C) 2015-2018, NextGIS <info@nextgis.com>
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
project (HDF4_MFHDF_XDR C CXX)

set(HDF4_MFHDF_XDR_INSTALL_INC_DIR ${INSTALL_INC_DIR})

set (HDF4_MFHDF_XDR_SRCS
    ${HDF4_MFHDF_XDR_SOURCE_DIR}/xdr.c
    ${HDF4_MFHDF_XDR_SOURCE_DIR}/xdrfloat.c
    ${HDF4_MFHDF_XDR_SOURCE_DIR}/xdrstdio.c
    ${HDF4_MFHDF_XDR_SOURCE_DIR}/xdrarray.c
)

set (HDF4_MFHDF_XDR_HDRS
    ${HDF4_MFHDF_XDR_SOURCE_DIR}/xdr.h
    ${HDF4_MFHDF_XDR_SOURCE_DIR}/types.h
)

INCLUDE_DIRECTORIES (${HDF4_HDFSOURCE_DIR})
INCLUDE_DIRECTORIES (${HDF4_MFHDF_XDR_DIR})

add_library (${HDF4_MF_XDR_LIB_TARGET} STATIC ${HDF4_MFHDF_XDR_SRCS} ${HDF4_MFHDF_XDR_HDRS})
if (MSVC OR MINGW)
  target_link_libraries (${HDF4_MF_XDR_LIB_TARGET} "ws2_32.lib")
endif ()
TARGET_C_PROPERTIES (${HDF4_MF_XDR_LIB_TARGET} STATIC " " " ")
H4_SET_LIB_OPTIONS (${HDF4_MF_XDR_LIB_TARGET} ${HDF4_MF_XDR_LIB_NAME} STATIC)
set_target_properties (${HDF4_MF_XDR_LIB_TARGET} PROPERTIES
    FOLDER libraries
    COMPILE_DEFINITIONS "HDF"
    INTERFACE_INCLUDE_DIRECTORIES "$<INSTALL_INTERFACE:$<INSTALL_PREFIX>/include>"
)
if (WIN32)
  set_property (TARGET ${HDF4_MF_XDR_LIB_TARGET} APPEND PROPERTY COMPILE_DEFINITIONS "DOS_FS;NO_SYS_XDR_INC")
endif ()
if(BUILD_STATIC_LIBS)
    set_global_variable (HDF4_LIBRARIES_TO_EXPORT "${HDF4_LIBRARIES_TO_EXPORT};${HDF4_MF_XDR_LIB_TARGET}")
    set (install_targets ${HDF4_MF_XDR_LIB_TARGET})
endif()

if (BUILD_SHARED_LIBS)
  add_library (${HDF4_MF_XDR_LIBSH_TARGET} SHARED ${HDF4_MFHDF_XDR_SRCS} ${HDF4_MFHDF_XDR_HDRS})
  if (MSVC OR MINGW)
    target_link_libraries (${HDF4_MF_XDR_LIBSH_TARGET} PRIVATE "ws2_32.lib")
  endif ()
  TARGET_C_PROPERTIES (${HDF4_MF_XDR_LIBSH_TARGET} SHARED " " " ")
  set_global_variable (HDF4_LIBRARIES_TO_EXPORT "${HDF4_LIBRARIES_TO_EXPORT};${HDF4_MF_XDR_LIBSH_TARGET}")
  H4_SET_LIB_OPTIONS (${HDF4_MF_XDR_LIBSH_TARGET} ${HDF4_MF_XDR_LIB_NAME} SHARED)
  set_target_properties (${HDF4_MF_XDR_LIBSH_TARGET} PROPERTIES
      FOLDER libraries
      COMPILE_DEFINITIONS "HDF;H4_BUILT_AS_DYNAMIC_LIB"
      INTERFACE_INCLUDE_DIRECTORIES "$<INSTALL_INTERFACE:$<INSTALL_PREFIX>/include>"
      INTERFACE_COMPILE_DEFINITIONS H4_BUILT_AS_DYNAMIC_LIB=1
  )
  if (WIN32)
    set_property (TARGET ${HDF4_MF_XDR_LIBSH_TARGET} APPEND PROPERTY COMPILE_DEFINITIONS "DOS_FS;NO_SYS_XDR_INC")
  endif ()
  set (install_targets ${install_targets} ${HDF4_MF_XDR_LIBSH_TARGET})
elseif(OSX_FRAMEWORK)
    set(HDF4_MFHDF_XDR_INSTALL_INC_DIR ${INSTALL_LIB_DIR}/xdr.framework/Headers)
    add_library(${HDF4_MF_XDR_LIBSH_TARGET} SHARED ${HDF4_MFHDF_XDR_SRCS} ${HDF4_MFHDF_XDR_HDRS})
    set_target_properties(${HDF4_MF_XDR_LIBSH_TARGET} PROPERTIES
      FRAMEWORK TRUE
      FRAMEWORK_VERSION ${FRAMEWORK_VERSION}
      MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${VERSION}
      MACOSX_FRAMEWORK_BUNDLE_VERSION ${VERSION}
      MACOSX_FRAMEWORK_IDENTIFIER org.libhdf.libxdr
      XCODE_ATTRIBUTE_INSTALL_PATH "@rpath"
      PUBLIC_HEADER "${HDF4_MFHDF_XDR_HDRS}"
      VERSION ${VERSION}
      SOVERSION ${SO_VERSION}
      OUTPUT_NAME xdr
      COMPILE_DEFINITIONS "HDF;H4_BUILT_AS_DYNAMIC_LIB"
      INTERFACE_COMPILE_DEFINITIONS H4_BUILT_AS_DYNAMIC_LIB=1
      )
      set_property (TARGET ${HDF4_MF_XDR_LIBSH_TARGET} APPEND PROPERTY COMPILE_DEFINITIONS "NO_SYS_XDR_INC")
      set (install_targets ${install_targets} ${HDF4_MF_XDR_LIBSH_TARGET})
      set_global_variable (HDF4_LIBRARIES_TO_EXPORT "${HDF4_LIBRARIES_TO_EXPORT};${HDF4_MF_XDR_LIBSH_TARGET}")
endif ()

#-----------------------------------------------------------------------------
# Add library to CMake Install : Installs lib and cmake config info
#-----------------------------------------------------------------------------
# if (BUILD_SHARED_LIBS)
#   INSTALL_TARGET_PDB (${HDF4_MF_XDR_LIBSH_TARGET} ${HDF4_INSTALL_BIN_DIR} libraries)
# endif ()
# INSTALL_TARGET_PDB (${HDF4_MF_XDR_LIB_TARGET} ${HDF4_INSTALL_BIN_DIR} libraries)
if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL)
install (
    TARGETS
        ${install_targets}
    EXPORT
        ${HDF4_EXPORTED_TARGETS}
    LIBRARY DESTINATION ${HDF4_INSTALL_LIB_DIR} COMPONENT libraries
    ARCHIVE DESTINATION ${HDF4_INSTALL_LIB_DIR} COMPONENT libraries
    RUNTIME DESTINATION ${HDF4_INSTALL_BIN_DIR} COMPONENT libraries
    FRAMEWORK DESTINATION ${HDF4_INSTALL_FWRK_DIR} COMPONENT libraries
    INCLUDES DESTINATION ${HDF4_MFHDF_XDR_INSTALL_INC_DIR}
)
endif()
