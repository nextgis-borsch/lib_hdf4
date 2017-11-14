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
cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)

project (hdf4)

## Some init settings
set(CMAKE_COLOR_MAKEFILE ON)
# Set path to additional CMake modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

if(OSX_FRAMEWORK AND (BUILD_SHARED_LIBS OR BUILD_STATIC_LIBS))
  message(FATAL_ERROR "Only OSX_FRAMEWORK key or any or both BUILD_SHARED_LIBS
                       and BUILD_STATIC_LIBS keys are permitted")
endif()

if(OSX_FRAMEWORK)
  set(INSTALL_BIN_DIR "${CMAKE_INSTALL_PREFIX}/bin" CACHE INTERNAL "Installation directory for executables" FORCE)
  set(INSTALL_LIB_DIR "${CMAKE_INSTALL_PREFIX}/Library/Frameworks" CACHE INTERNAL "Installation directory for libraries" FORCE)
  # set(INSTALL_INC_DIR "${INSTALL_LIB_DIR}/${PROJECT_NAME}.framework/Headers" CACHE INTERNAL "Installation directory for headers" FORCE)
  set(SKIP_INSTALL_HEADERS ON)
  set(SKIP_INSTALL_FILES ON)
  set(SKIP_INSTALL_EXPORT ON)
  set(CMAKE_MACOSX_RPATH ON)
  set(SKIP_INSTALL_DOCS ON)
else()
    include(GNUInstallDirs)

    set(INSTALL_BIN_DIR ${CMAKE_INSTALL_BINDIR} CACHE INTERNAL "Installation directory for executables" FORCE)
    set(INSTALL_LIB_DIR ${CMAKE_INSTALL_LIBDIR} CACHE INTERNAL "Installation directory for libraries" FORCE)
    set(INSTALL_INC_DIR ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME} CACHE INTERNAL "Installation directory for headers" FORCE)
    set(INSTALL_SHARE_DIR ${CMAKE_INSTALL_DATADIR} CACHE INTERNAL "Installation directory for share files" FORCE)
    set(INSTALL_DATA_DIR ${INSTALL_SHARE_DIR}/${PROJECT_NAME} CACHE INTERNAL "Installation directory for doc files" FORCE)
    set(INSTALL_MAN_DIR ${CMAKE_INSTALL_MANDIR} CACHE INTERNAL "Installation directory for manual pages" FORCE)
endif()

# if(WIN32)
#     set(INSTALL_INC_DIR "${CMAKE_INSTALL_FULL_INCLUDEDIR}/${PROJECT_NAME}" CACHE INTERNAL "Installation directory for headers" FORCE)
# endif()

include(util)
check_version(H4_VERS_MAJOR H4_VERS_MINOR H4_VERS_RELEASE H4_VERS_SUBRELEASE)

if(H4_VERS_SUBRELEASE)
    set(VERSION "${H4_VERS_MAJOR}.${H4_VERS_MINOR}.${H4_VERS_RELEASE}.${H4_VERS_SUBRELEASE}")
else()
    set(VERSION "${H4_VERS_MAJOR}.${H4_VERS_MINOR}.${H4_VERS_RELEASE}")
endif()

set(SO_VERSION ${H4_VERS_MAJOR})

if(OSX_FRAMEWORK)
    set(FRAMEWORK_VERSION "${H4_VERS_MAJOR}")
endif()
report_version(${PROJECT_NAME} "${VERSION}")

if (MSVC OR MINGW)
  set (H4_HDSETVBUF "HDsetvbuf(F,S,M,Z) (((Z)>1)?setvbuf(F,S,M,Z):setvbuf(F,S,M,2))")
else (MSVC OR MINGW)
  set (H4_HDSETVBUF "NOP")
endif (MSVC OR MINGW)
set (H4_F77_FUNC "H4_F77_FUNC(name,NAME) name ## _")
set (H4_F77_FUNC_ "H4_F77_FUNC_(name,NAME) name ## __")

include(FindAnyProject)
find_anyproject(ZLIB REQUIRED)
if (ZLIB_FOUND)
    set (HDFEOS_ENABLE_Z_LIB_SUPPORT ON)
    set (H4_HAVE_FILTER_DEFLATE 1)
    set (H4_HAVE_ZLIB_H 1)
    set (H4_HAVE_LIBZ 1)
    set (H4_ZLIB_HEADER "zlib.h")
endif()

find_anyproject(JPEG REQUIRED)
if (JPEG_FOUND)
    set (HDFEOS_ENABLE_JPEG_LIB_SUPPORT ON)
    set (H4_HAVE_JPEGLIB_H 1)
    set (H4_HAVE_LIBJPEG 1)
    set (H4_JPEGLIB_HEADER "jpeglib.h")
endif()

find_anyproject(SZIP DEFAULT OFF)
if (SZIP_FOUND)
    set (HDFEOS_ENABLE_SZIP_SUPPORT ON)
    set (H4_HAVE_FILTER_SZIP 1)
    set (H4_HAVE_SZLIB_H 1)
    set (H4_HAVE_LIBSZ 1)
endif()

include(configure)

#-----------------------------------------------------------------------------
# Option to use code coverage
#-----------------------------------------------------------------------------
option (HDF4_ENABLE_COVERAGE "Enable code coverage for Libraries and Programs" OFF)
if (HDF4_ENABLE_COVERAGE)
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -O0 -fprofile-arcs -ftest-coverage")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -O0 -fprofile-arcs -ftest-coverage")
    set (LDFLAGS "${LDFLAGS} -fprofile-arcs -ftest-coverage")
endif (HDF4_ENABLE_COVERAGE)

#-----------------------------------------------------------------------------
# Option to use deprecated public API symbols
#-----------------------------------------------------------------------------
option (HDF4_ENABLE_DEPRECATED_SYMBOLS "Enable deprecated public API symbols" ON)
if (HDF4_ENABLE_DEPRECATED_SYMBOLS)
  set (H4_NO_DEPRECATED_SYMBOLS 0)
else ()
  set (H4_NO_DEPRECATED_SYMBOLS 1)
endif ()

#-----------------------------------------------------------------------------
# Compiler specific flags : Shouldn't there be compiler tests for these
#-----------------------------------------------------------------------------
if (CMAKE_COMPILER_IS_GNUCC)
  if (CMAKE_BUILD_TYPE MATCHES Debug)
    set (CMAKE_C_FLAGS "${CMAKE_ANSI_CFLAGS} ${CMAKE_C_FLAGS} -std=c99 -finline-functions -fno-common")
  else ()
    set (CMAKE_C_FLAGS "${CMAKE_ANSI_CFLAGS} ${CMAKE_C_FLAGS} -std=c99 -fomit-frame-pointer -finline-functions -fno-common")
  endif ()
endif ()
if (CMAKE_COMPILER_IS_GNUCXX)
  if (CMAKE_BUILD_TYPE MATCHES Debug)
    set (CMAKE_CXX_FLAGS "${CMAKE_ANSI_CFLAGS} ${CMAKE_CXX_FLAGS} -finline-functions -fno-common")
  else ()
    set (CMAKE_CXX_FLAGS "${CMAKE_ANSI_CFLAGS} ${CMAKE_CXX_FLAGS} -fomit-frame-pointer -finline-functions -fno-common")
  endif ()
endif ()

#-----------------------------------------------------------------------------
# Option to allow the user to disable compiler warnings
#-----------------------------------------------------------------------------
option (HDF4_DISABLE_COMPILER_WARNINGS "Disable compiler warnings" OFF)
if (HDF4_DISABLE_COMPILER_WARNINGS)
  # MSVC uses /w to suppress warnings.  It also complains if another
  # warning level is given, so remove it.
  if (MSVC)
    set (HDF4_WARNINGS_BLOCKED 1)
    string (REGEX REPLACE "(^| )([/-])W[0-9]( |$)" " " CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /w")
    string (REGEX REPLACE "(^| )([/-])W[0-9]( |$)" " " CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /w")
  endif (MSVC)
  if (WIN32)
    add_definitions (-D_CRT_SECURE_NO_WARNINGS)
  endif (WIN32)
  # Borland uses -w- to suppress warnings.
  if (BORLAND)
    set (HDF4_WARNINGS_BLOCKED 1)
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -w-")
  endif (BORLAND)

  # Most compilers use -w to suppress warnings.
  if (NOT HDF4_WARNINGS_BLOCKED)
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -w")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -w")
  endif (NOT HDF4_WARNINGS_BLOCKED)
endif (HDF4_DISABLE_COMPILER_WARNINGS)

#-----------------------------------------------------------------------------
# This is in here to help some of the GCC based IDES like Eclipse
# and code blocks parse the compiler errors and warnings better.
#-----------------------------------------------------------------------------
if (CMAKE_COMPILER_IS_GNUCC)
  set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fmessage-length=0")
endif (CMAKE_COMPILER_IS_GNUCC)
if (CMAKE_COMPILER_IS_GNUCXX)
  set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fmessage-length=0")
endif (CMAKE_COMPILER_IS_GNUCXX)

set (HDF4_SRC_LIB   "hdf")
set (HDF4_MF_LIB    "mfhdf")
set (HDF4_MF_XDR    "xdr")
set (HDF4_HDFSOURCE_DIR       ${CMAKE_SOURCE_DIR}/hdf/src)
set (HDF4_MFHDFSOURCE_DIR     ${CMAKE_SOURCE_DIR}/mfhdf/libsrc)
set (HDF4_MFHDF_XDR_DIR       ${CMAKE_SOURCE_DIR}/mfhdf/xdr)

#-----------------------------------------------------------------------------
# Option to build HDF4 xdr Library
#-----------------------------------------------------------------------------
option (HDF4_BUILD_XDR_LIB  "Build HDF4 XDR Library" OFF)
if (WIN32 AND NOT MINGW)
  set (HDF4_BUILD_XDR_LIB ON CACHE BOOL "Build HDF4 XDR Library" FORCE)
endif ()

if (HDF4_BUILD_XDR_LIB)
  add_subdirectory (${CMAKE_SOURCE_DIR}/mfhdf/xdr ${CMAKE_BINARY_DIR}/xdr)
  set(HDF4_TARGETS ${HDF4_TARGETS} ${HDF4_MF_XDR})
  set(TARGET_LINK_LIB ${TARGET_LINK_LIB} ${HDF4_MF_XDR})
endif ()

#-----------------------------------------------------------------------------
# Add the HDF4 Library Target to the build
#-----------------------------------------------------------------------------
add_subdirectory (${CMAKE_SOURCE_DIR}/hdf/src    ${CMAKE_BINARY_DIR}/hdf/src )
set(HDF4_TARGETS ${HDF4_TARGETS} ${HDF4_SRC_LIB})
set(TARGET_LINK_LIB ${TARGET_LINK_LIB} ${HDF4_SRC_LIB})
add_subdirectory (${CMAKE_SOURCE_DIR}/mfhdf/libsrc   ${CMAKE_BINARY_DIR}/mfhdf/libsrc)
set(HDF4_TARGETS ${HDF4_TARGETS} ${HDF4_MF_LIB})

if (HDF4_BUILD_XDR_LIB)
#    target_link_libraries (${HDF4_MF_LIB} ${HDF4_MF_XDR})
    add_dependencies (${HDF4_MF_LIB} ${HDF4_MF_XDR})
    add_dependencies (${HDF4_SRC_LIB} ${HDF4_MF_XDR})
endif ()

if (REGISTER_PACKAGE)
    export(TARGETS ${HDF4_TARGETS} FILE ${PROJECT_NAME}-exports.cmake)

    set(EXPORT_PACKAGE_NAME hdf4)
    string(TOUPPER ${EXPORT_PACKAGE_NAME} EXPORT_PACKAGE_NAME_UPPER)
    set(EXPORT_PACKAGE_LIB_NAMES ${HDF4_TARGETS})
    if(OSX_FRAMEWORK)
        set(EXPORT_PACKAGE_INC_DIRS ${INSTALL_LIB_DIR}/${HDF4_SRC_LIB}.framework/Headers ${INSTALL_LIB_DIR}/${HDF4_MF_LIB}.framework/Headers)
    else()
        set(EXPORT_PACKAGE_INC_DIRS ${INSTALL_INC_DIR})
    endif()
    export(PACKAGE ${EXPORT_PACKAGE_NAME})

    include(CMakePackageConfigHelpers)
    configure_package_config_file(
        ${CMAKE_SOURCE_DIR}/cmake/PackageConfig.cmake.in
        ${CMAKE_CURRENT_BINARY_DIR}/${EXPORT_PACKAGE_NAME}Config.cmake
    INSTALL_DESTINATION ${CMAKE_CURRENT_BINARY_DIR} )
    write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/${EXPORT_PACKAGE_NAME}ConfigVersion.cmake
        VERSION ${VERSION}
        COMPATIBILITY AnyNewerVersion )
else()
    export(TARGETS ${HDF4_TARGETS} FILE ${PROJECT_NAME}-exports.cmake EXPORT_LINK_INTERFACE_LIBRARIES)
endif()

include(install)

add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)
