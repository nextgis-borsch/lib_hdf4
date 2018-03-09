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
PROJECT (HDF4_MFHDF_LIBSRC C CXX)

set(HDF4_MFHDF_LIBSRC_INSTALL_INC_DIR ${INSTALL_INC_DIR})
#-----------------------------------------------------------------------------
# Generate the netcdf.h file containing user settings needed by compilation
#-----------------------------------------------------------------------------
if (WIN32)
  set (H4_WINDOWS_INCLUDE_FILE "#include <hdfi.h>")
  set (NETCDF_EXTERN HDFLIBAPI)
else ()
  set (NETCDF_EXTERN extern)
endif ()

set (NC_OLD_FILLVALUES 0)

set (HDF4_MFHDF_LIBSRC_CSRCS
    ${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/array.c
    ${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/attr.c
    ${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/cdf.c
    ${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/dim.c
    ${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/file.c
    ${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/hdfsds.c
    ${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/iarray.c
    ${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/error.c
    ${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/globdef.c
    ${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/mfdatainfo.c
    ${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/mfsd.c
    ${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/nssdc.c
    ${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/putget.c
    ${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/putgetg.c
    ${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/sharray.c
    ${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/string.c
    ${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/var.c
    ${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/xdrposix.c
)

set (HDF4_MFHDF_LIBSRC_CHDRS
    ${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/alloc.h
    ${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/error.h
    ${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/local_nc.h
    ${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/mfhdf.h
    ${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/mfhdfi.h
    ${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/mfdatainfo.h
    ${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/hdf2netcdf.h
)

if (HDF4_ENABLE_NETCDF)
  configure_file (${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/netcdf.h.in ${HDF4_BINARY_DIR}/netcdf.h)
  set (HDF4_MFHDF_LIBSRC_CHDRS ${HDF4_MFHDF_LIBSRC_CHDRS} ${HDF4_BINARY_DIR}/netcdf.h)
else ()
  configure_file (${HDF4_MFHDF_LIBSRC_SOURCE_DIR}/netcdf.h.in ${HDF4_BINARY_DIR}/hdf4_netcdf.h)
  set (HDF4_MFHDF_LIBSRC_CHDRS ${HDF4_MFHDF_LIBSRC_CHDRS}  ${HDF4_BINARY_DIR}/hdf4_netcdf.h)
endif ()

include_directories (${HDF4_HDFSOURCE_DIR})
include_directories (${HDF4_MFHDFSOURCE_DIR})

add_library (${HDF4_MF_LIB_TARGET} STATIC ${HDF4_MFHDF_LIBSRC_CSRCS} ${HDF4_MFHDF_LIBSRC_CHDRS})
if (HDF4_BUILD_XDR_LIB)
  include_directories (${HDF4_MFHDF_XDR_DIR})
  target_link_libraries (${HDF4_MF_LIB_TARGET} PRIVATE ${HDF4_MF_XDR_LIB_TARGET})
endif ()
TARGET_C_PROPERTIES (${HDF4_MF_LIB_TARGET} STATIC " " " ")
target_link_libraries (${HDF4_MF_LIB_TARGET} PRIVATE ${HDF4_SRC_LIB_TARGET})
H4_SET_LIB_OPTIONS (${HDF4_MF_LIB_TARGET} ${HDF4_MF_LIB_NAME} STATIC)
set_target_properties (${HDF4_MF_LIB_TARGET} PROPERTIES
    FOLDER libraries
    COMPILE_DEFINITIONS "HDF"
    INTERFACE_INCLUDE_DIRECTORIES "$<INSTALL_INTERFACE:$<INSTALL_PREFIX>/include>"
)
if (WIN32)
  set_property (TARGET ${HDF4_MF_LIB_TARGET} APPEND PROPERTY COMPILE_DEFINITIONS "DOS_FS;SWAP")
endif ()

if (HDF4_BUILD_XDR_LIB)
  set_property (TARGET ${HDF4_MF_LIB_TARGET} APPEND PROPERTY COMPILE_DEFINITIONS "NO_SYS_XDR_INC")
endif ()

if(BUILD_STATIC_LIBS)
    set_global_variable (HDF4_LIBRARIES_TO_EXPORT "${HDF4_LIBRARIES_TO_EXPORT};${HDF4_MF_LIB_TARGET}")
    set (install_targets ${HDF4_MF_LIB_TARGET})
endif()

if (BUILD_SHARED_LIBS)
  add_library (${HDF4_MF_LIBSH_TARGET} SHARED ${HDF4_MFHDF_LIBSRC_CSRCS} ${HDF4_MFHDF_LIBSRC_CHDRS})
  if (HDF4_BUILD_XDR_LIB)
    INCLUDE_DIRECTORIES (${HDF4_MFHDF_XDR_DIR})
    target_link_libraries (${HDF4_MF_LIBSH_TARGET} PRIVATE ${HDF4_MF_XDR_LIBSH_TARGET})
  endif ()
  TARGET_C_PROPERTIES (${HDF4_MF_LIBSH_TARGET} SHARED " " " ")
  target_link_libraries (${HDF4_MF_LIBSH_TARGET} PRIVATE ${HDF4_SRC_LIBSH_TARGET})
  set_global_variable (HDF4_LIBRARIES_TO_EXPORT "${HDF4_LIBRARIES_TO_EXPORT};${HDF4_MF_LIBSH_TARGET}")
  H4_SET_LIB_OPTIONS (${HDF4_MF_LIBSH_TARGET} ${HDF4_MF_LIB_NAME} SHARED)
  set_target_properties (${HDF4_MF_LIBSH_TARGET} PROPERTIES
      FOLDER libraries
      COMPILE_DEFINITIONS "HDF;H4_BUILT_AS_DYNAMIC_LIB"
      INTERFACE_INCLUDE_DIRECTORIES "$<INSTALL_INTERFACE:$<INSTALL_PREFIX>/include>"
      INTERFACE_COMPILE_DEFINITIONS H4_BUILT_AS_DYNAMIC_LIB=1
  )
  if (WIN32)
    set_property (TARGET ${HDF4_MF_LIBSH_TARGET} APPEND PROPERTY COMPILE_DEFINITIONS "DOS_FS;SWAP")
    if (HDF4_BUILD_XDR_LIB)
      set_property (TARGET ${HDF4_MF_LIBSH_TARGET} APPEND PROPERTY COMPILE_DEFINITIONS "NO_SYS_XDR_INC")
    endif ()
  endif ()
  set (install_targets ${install_targets} ${HDF4_MF_LIBSH_TARGET})
elseif(OSX_FRAMEWORK)
    set(HDF4_MFHDF_LIBSRC_INSTALL_INC_DIR ${INSTALL_LIB_DIR}/mfhdf.framework/Headers)
    add_library(${HDF4_MF_LIBSH_TARGET} SHARED ${HDF4_MFHDF_LIBSRC_CSRCS} ${HDF4_MFHDF_LIBSRC_CHDRS})
    set_target_properties(${HDF4_MF_LIBSH_TARGET} PROPERTIES
      FRAMEWORK TRUE
      FRAMEWORK_VERSION ${FRAMEWORK_VERSION}
      MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${VERSION}
      MACOSX_FRAMEWORK_BUNDLE_VERSION ${VERSION}
      MACOSX_FRAMEWORK_IDENTIFIER org.libhdf.libmf
      XCODE_ATTRIBUTE_INSTALL_PATH "@rpath"
      PUBLIC_HEADER "${HDF4_MFHDF_LIBSRC_CHDRS}"
      VERSION ${VERSION}
      SOVERSION ${SO_VERSION}
      OUTPUT_NAME mfhdf
      COMPILE_DEFINITIONS "HDF;H4_BUILT_AS_DYNAMIC_LIB"
      INTERFACE_COMPILE_DEFINITIONS "H4_BUILT_AS_DYNAMIC_LIB=1"
      )
      if (HDF4_BUILD_XDR_LIB)
        set_property (TARGET ${HDF4_MF_LIBSH_TARGET} APPEND PROPERTY COMPILE_DEFINITIONS "NO_SYS_XDR_INC")
      endif ()

      target_link_libraries (${HDF4_MF_LIBSH_TARGET} PRIVATE ${HDF4_SRC_LIBSH_TARGET})
      set_global_variable (HDF4_LIBRARIES_TO_EXPORT "${HDF4_LIBRARIES_TO_EXPORT};${HDF4_MF_LIBSH_TARGET}")
      set (install_targets ${install_targets} ${HDF4_MF_LIBSH_TARGET})
endif ()

#-----------------------------------------------------------------------------
# Add file(s) to CMake Install
#-----------------------------------------------------------------------------
if(NOT SKIP_INSTALL_HEADERS AND NOT SKIP_INSTALL_ALL )
    install (
    FILES
        ${HDF4_MFHDF_LIBSRC_CHDRS}
    DESTINATION
        ${HDF4_INSTALL_INCLUDE_DIR}
    COMPONENT
        headers
)
endif()

#-----------------------------------------------------------------------------
# Add library to CMake Install : Installs lib and cmake config info
#-----------------------------------------------------------------------------
# if (BUILD_SHARED_LIBS)
#   INSTALL_TARGET_PDB (${HDF4_MF_LIBSH_TARGET} ${HDF4_INSTALL_BIN_DIR} libraries)
# endif ()
# INSTALL_TARGET_PDB (${HDF4_MF_LIB_TARGET} ${HDF4_INSTALL_BIN_DIR} libraries)
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
    INCLUDES DESTINATION ${HDF4_MFHDF_LIBSRC_INSTALL_INC_DIR}
)
endif()

# Copy dll's for tests
if(WIN32)
    file(GLOB_RECURSE IMPORTED_WIN_DLLS ${CMAKE_BINARY_DIR}/third-party/*.dll)
    foreach(IMPORTED_WIN_DLL ${IMPORTED_WIN_DLLS})
        add_custom_command(TARGET ${HDF4_MF_LIBSH_TARGET}
                            POST_BUILD
                            COMMAND ${CMAKE_COMMAND} -E copy ${IMPORTED_WIN_DLL} $<TARGET_FILE_DIR:${HDF4_MF_LIBSH_TARGET}>
                            COMMENT "Copy ${IMPORTED_WIN_DLL} to ${HDF4_MF_LIBSH_TARGET} out directory"
                        )

    endforeach()
endif()

# Create the <Package>Config.cmake file
configure_file(${CMAKE_SOURCE_DIR}/cmake/PackageConfig.cmake.in
    ${CMAKE_BINARY_DIR}/${PACKAGE_UPPER_NAME}Config.cmake @ONLY)

if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL)
    # Install the <Package>Config.cmake
    install(FILES
      ${CMAKE_BINARY_DIR}/${PACKAGE_UPPER_NAME}Config.cmake
      DESTINATION ${INSTALL_CMAKECONF_DIR} COMPONENT dev)

    # Install the export set for use with the install-tree
    install(EXPORT ${HDF4_EXPORTED_TARGETS} DESTINATION ${INSTALL_CMAKECONF_DIR} COMPONENT dev)
endif()
