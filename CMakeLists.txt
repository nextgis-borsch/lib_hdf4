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
cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)

project(HDF4 C CXX)

## Some init settings
set(CMAKE_COLOR_MAKEFILE ON)
# Set path to additional CMake modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

if(OSX_FRAMEWORK AND (BUILD_SHARED_LIBS OR BUILD_STATIC_LIBS))
  message(FATAL_ERROR "Only OSX_FRAMEWORK key or any or both BUILD_SHARED_LIBS and BUILD_STATIC_LIBS keys are permitted")
endif()

string(TOLOWER ${PROJECT_NAME} PROJECT_LOWER_NAME)

if(OSX_FRAMEWORK)
    set(INSTALL_BIN_DIR "bin" CACHE INTERNAL "Installation directory for executables" FORCE)
    set(INSTALL_LIB_DIR "Library/Frameworks" CACHE INTERNAL "Installation directory for libraries" FORCE)
    set(INSTALL_INC_DIR ${INSTALL_LIB_DIR}/${PROJECT_LOWER_NAME}.framework/Headers CACHE INTERNAL "Installation directory for headers" FORCE)
    set(INSTALL_CMAKECONF_DIR ${INSTALL_LIB_DIR}/${PROJECT_LOWER_NAME}.framework/Resources/CMake CACHE INTERNAL "Installation directory for cmake config files" FORCE)
    set(INSTALL_DATA_DIR ${INSTALL_LIB_DIR}/${PROJECT_LOWER_NAME}.framework/Resources CACHE INTERNAL "Installation directory for doc files" FORCE)

    set(SKIP_INSTALL_HEADERS ON)
    set(SKIP_INSTALL_FILES ON)
    set(SKIP_INSTALL_EXPORT ON)
    set(CMAKE_MACOSX_RPATH ON)
    set(SKIP_INSTALL_DOCS ON)
    set(HDF4_BUILD_FRAMEWORKS TRUE CACHE INTERNAL "Build as frameworks libraries" FORCE)
else()
    include(GNUInstallDirs)

    set(INSTALL_BIN_DIR ${CMAKE_INSTALL_BINDIR} CACHE INTERNAL "Installation directory for executables" FORCE)
    set(INSTALL_LIB_DIR ${CMAKE_INSTALL_LIBDIR} CACHE INTERNAL "Installation directory for libraries" FORCE)
    set(INSTALL_INC_DIR ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_LOWER_NAME} CACHE INTERNAL "Installation directory for headers" FORCE)
    set(INSTALL_SHARE_DIR ${CMAKE_INSTALL_DATADIR} CACHE INTERNAL "Installation directory for share files" FORCE)
    set(INSTALL_DATA_DIR ${INSTALL_SHARE_DIR}/${PROJECT_LOWER_NAME} CACHE INTERNAL "Installation directory for doc files" FORCE)
    set(INSTALL_MAN_DIR ${CMAKE_INSTALL_MANDIR} CACHE INTERNAL "Installation directory for manual pages" FORCE)
    set(INSTALL_CMAKECONF_DIR ${CMAKE_INSTALL_DATADIR}/${PROJECT_LOWER_NAME}/CMake CACHE INTERNAL "Installation directory for cmake config files" FORCE)
endif()

set(HDF4_INSTALL_BIN_DIR ${INSTALL_BIN_DIR})
set(HDF4_INSTALL_LIB_DIR ${INSTALL_LIB_DIR})
SET(HDF4_INSTALL_FWRK_DIR ${INSTALL_LIB_DIR})
set(HDF4_INSTALL_INCLUDE_DIR ${INSTALL_INC_DIR})
set(HDF4_INSTALL_DATA_DIR ${INSTALL_DATA_DIR})

#########

string(TIMESTAMP CONFIG_DATE "%Y-%m-%d")

#-----------------------------------------------------------------------------
# Allow Visual Studio solution directories
#-----------------------------------------------------------------------------
# Provide a way for Visual Studio Express users to turn OFF the new FOLDER
# organization feature. Default to ON for non-Express users. Express users must
# explicitly turn off this option to build HDF4 in the Express IDE...
#
option (HDF4_USE_FOLDERS "Enable folder grouping of projects in IDEs." ON)
mark_as_advanced (HDF4_USE_FOLDERS)
if (HDF4_USE_FOLDERS)
  set_property (GLOBAL PROPERTY USE_FOLDERS ON)
endif ()
option (HDF4_NO_PACKAGES "CPACK - Disable packaging" OFF)
mark_as_advanced (HDF4_NO_PACKAGES)

#-----------------------------------------------------------------------------
# Set the core names of all the libraries
#-----------------------------------------------------------------------------
set (HDF4_SRC_LIB_CORENAME          "hdf")
set (HDF4_SRC_FCSTUB_LIB_CORENAME   "hdf_fcstub")
set (HDF4_SRC_FORTRAN_LIB_CORENAME  "hdf_fortran")
set (HDF4_MF_LIB_CORENAME           "mfhdf")
set (HDF4_MF_XDR_LIB_CORENAME       "xdr")
set (HDF4_HDF_TEST_LIB_CORENAME     "hdf_test")
set (HDF4_HDF_TEST_FCSTUB_LIB_CORENAME     "hdf_test_fcstub")
set (HDF4_MF_FCSTUB_LIB_CORENAME    "mfhdf_fcstub")
set (HDF4_MF_FORTRAN_LIB_CORENAME   "mfhdf_fortran")
set (HDF4_MF_TEST_LIB_CORENAME      "mf_test")
set (HDF4_TOOLS_LIB_CORENAME        "h4tools")
set (HDF4_JAVA_JNI_LIB_CORENAME     "hdf_java")
set (HDF4_JAVA_HDF_LIB_CORENAME     "jarhdf")
set (HDF4_JAVA_TEST_LIB_CORENAME    "jartest4")

#-----------------------------------------------------------------------------
# Set the true names of all the libraries if customized by external project
#-----------------------------------------------------------------------------
set (HDF4_SRC_LIB_NAME          "${HDF4_EXTERNAL_LIB_PREFIX}${HDF4_SRC_LIB_CORENAME}")
set (HDF4_SRC_FCSTUB_LIB_NAME   "${HDF4_EXTERNAL_LIB_PREFIX}${HDF4_SRC_FCSTUB_LIB_CORENAME}")
set (HDF4_SRC_FORTRAN_LIB_NAME  "${HDF4_EXTERNAL_LIB_PREFIX}${HDF4_SRC_FORTRAN_LIB_CORENAME}")
set (HDF4_MF_LIB_NAME           "${HDF4_EXTERNAL_LIB_PREFIX}${HDF4_MF_LIB_CORENAME}")
set (HDF4_MF_XDR_LIB_NAME       "${HDF4_EXTERNAL_LIB_PREFIX}${HDF4_MF_XDR_LIB_CORENAME}")
set (HDF4_HDF_TEST_LIB_NAME     "${HDF4_EXTERNAL_LIB_PREFIX}${HDF4_HDF_TEST_LIB_CORENAME}")
set (HDF4_HDF_TEST_FCSTUB_LIB_NAME     "${HDF4_EXTERNAL_LIB_PREFIX}${HDF4_HDF_TEST_FCSTUB_LIB_CORENAME}")
set (HDF4_MF_FCSTUB_LIB_NAME    "${HDF4_EXTERNAL_LIB_PREFIX}${HDF4_MF_FCSTUB_LIB_CORENAME}")
set (HDF4_MF_FORTRAN_LIB_NAME   "${HDF4_EXTERNAL_LIB_PREFIX}${HDF4_MF_FORTRAN_LIB_CORENAME}")
set (HDF4_MF_TEST_LIB_NAME      "${HDF4_EXTERNAL_LIB_PREFIX}${HDF4_MF_TEST_LIB_CORENAME}")
set (HDF4_TOOLS_LIB_NAME        "${HDF4_EXTERNAL_LIB_PREFIX}${HDF4_TOOLS_LIB_CORENAME}")
set (HDF4_JAVA_JNI_LIB_NAME     "${HDF4_EXTERNAL_LIB_PREFIX}${HDF4_JAVA_JNI_LIB_CORENAME}")
set (HDF4_JAVA_HDF_LIB_NAME     "${HDF4_EXTERNAL_LIB_PREFIX}${HDF4_JAVA_HDF_LIB_CORENAME}")
set (HDF4_JAVA_TEST_LIB_NAME    "${HDF4_EXTERNAL_LIB_PREFIX}${HDF4_JAVA_TEST_LIB_CORENAME}")

#-----------------------------------------------------------------------------
# Set the target names of all the libraries
#-----------------------------------------------------------------------------
set (HDF4_SRC_LIB_TARGET          "${HDF4_SRC_LIB_CORENAME}-static")
set (HDF4_SRC_FCSTUB_LIB_TARGET   "${HDF4_SRC_FCSTUB_LIB_CORENAME}-static")
set (HDF4_SRC_FORTRAN_LIB_TARGET  "${HDF4_SRC_FORTRAN_LIB_CORENAME}-static")
set (HDF4_MF_LIB_TARGET           "${HDF4_MF_LIB_CORENAME}-static")
set (HDF4_MF_XDR_LIB_TARGET       "${HDF4_MF_XDR_LIB_CORENAME}-static")
set (HDF4_HDF_TEST_LIB_TARGET     "${HDF4_HDF_TEST_LIB_CORENAME}-static")
set (HDF4_HDF_TEST_FCSTUB_LIB_TARGET     "${HDF4_HDF_TEST_FCSTUB_LIB_CORENAME}-static")
set (HDF4_MF_FCSTUB_LIB_TARGET    "${HDF4_MF_FCSTUB_LIB_CORENAME}-static")
set (HDF4_MF_FORTRAN_LIB_TARGET   "${HDF4_MF_FORTRAN_LIB_CORENAME}-static")
set (HDF4_MF_TEST_LIB_TARGET      "${HDF4_MF_TEST_LIB_CORENAME}-static")
set (HDF4_TOOLS_LIB_TARGET        "${HDF4_TOOLS_LIB_CORENAME}-static")
set (HDF4_JAVA_JNI_LIB_TARGET     "${HDF4_JAVA_JNI_LIB_CORENAME}")
set (HDF4_JAVA_HDF_LIB_TARGET     "${HDF4_JAVA_HDF_LIB_CORENAME}")
set (HDF4_JAVA_TEST_LIB_TARGET    "${HDF4_JAVA_TEST_LIB_CORENAME}")
set (HDF4_SRC_LIBSH_TARGET          "${HDF4_SRC_LIB_CORENAME}-shared")
set (HDF4_SRC_FCSTUB_LIBSH_TARGET   "${HDF4_SRC_FCSTUB_LIB_CORENAME}-shared")
set (HDF4_SRC_FORTRAN_LIBSH_TARGET  "${HDF4_SRC_FORTRAN_LIB_CORENAME}-shared")
set (HDF4_MF_LIBSH_TARGET           "${HDF4_MF_LIB_CORENAME}-shared")
set (HDF4_MF_XDR_LIBSH_TARGET       "${HDF4_MF_XDR_LIB_CORENAME}-shared")
set (HDF4_HDF_TEST_LIBSH_TARGET     "${HDF4_HDF_TEST_LIB_CORENAME}-shared")
set (HDF4_HDF_TEST_FCSTUB_LIBSH_TARGET     "${HDF4_HDF_TEST_FCSTUB_LIB_CORENAME}-shared")
set (HDF4_MF_FCSTUB_LIBSH_TARGET    "${HDF4_MF_FCSTUB_LIB_CORENAME}-shared")
set (HDF4_MF_FORTRAN_LIBSH_TARGET   "${HDF4_MF_FORTRAN_LIB_CORENAME}-shared")
set (HDF4_MF_TEST_LIBSH_TARGET      "${HDF4_MF_TEST_LIB_CORENAME}-shared")
set (HDF4_TOOLS_LIBSH_TARGET        "${HDF4_TOOLS_LIB_CORENAME}-shared")

#-----------------------------------------------------------------------------
# Define some CMake variables for use later in the project
#-----------------------------------------------------------------------------
# set (HDF_RESOURCES_DIR        ${HDF4_SOURCE_DIR}/config/cmake)
# set (HDF_RESOURCES_EXT_DIR    ${HDF4_SOURCE_DIR}/config/cmake_ext_mod)
set (HDF_RESOURCES_DIR        ${HDF4_SOURCE_DIR}/cmake)
set (HDF_RESOURCES_EXT_DIR    ${HDF4_SOURCE_DIR}/cmake/ext_mod)
set (HDF4_HDFSOURCE_DIR       ${HDF4_SOURCE_DIR}/hdf/src)
set (HDF4_HDF_TESTSOURCE_DIR  ${HDF4_SOURCE_DIR}/hdf/test)
set (HDF4_MFHDFSOURCE_DIR     ${HDF4_SOURCE_DIR}/mfhdf/libsrc)
set (HDF4_MFHDF_TEST_DIR      ${HDF4_SOURCE_DIR}/mfhdf/test)
set (HDF4_MFHDF_FORTRAN_DIR   ${HDF4_SOURCE_DIR}/mfhdf/fortran)
set (HDF4_MFHDF_XDR_DIR       ${HDF4_SOURCE_DIR}/mfhdf/xdr)
set (HDF4_JAVA_JNI_SRC_DIR         ${HDF4_SOURCE_DIR}/java/src/jni)
set (HDF4_JAVA_HDF_SRC_DIR         ${HDF4_SOURCE_DIR}/java/src/hdf)
set (HDF4_JAVA_TEST_SRC_DIR        ${HDF4_SOURCE_DIR}/java/test)
set (HDF4_JAVA_LIB_DIR             ${HDF4_SOURCE_DIR}/java/lib)
set (HDF4_JAVA_LOGGING_JAR         ${HDF4_SOURCE_DIR}/java/lib/slf4j-api-1.7.5.jar)
set (HDF4_JAVA_LOGGING_NOP_JAR     ${HDF4_SOURCE_DIR}/java/lib/ext/slf4j-nop-1.7.5.jar)
set (HDF4_JAVA_LOGGING_SIMPLE_JAR  ${HDF4_SOURCE_DIR}/java/lib/ext/slf4j-simple-1.7.5.jar)


if (APPLE)
  option (HDF4_BUILD_FRAMEWORKS "TRUE to build as frameworks libraries, FALSE to build according to BUILD_SHARED_LIBS" FALSE)
endif ()

if (NOT HDF4_INSTALL_BIN_DIR)
  set (HDF4_INSTALL_BIN_DIR bin)
  set (HDF4_INSTALL_UTILS_BIN_DIR ${HDF4_INSTALL_BIN_DIR})
  set (HDF4_INSTALL_TOOLS_BIN_DIR ${HDF4_INSTALL_BIN_DIR})
endif ()
if (NOT HDF4_INSTALL_LIB_DIR)
  if (APPLE)
    if (HDF4_BUILD_FRAMEWORKS)
      set (HDF4_INSTALL_JAR_DIR ../Java)
    else ()
      set (HDF4_INSTALL_JAR_DIR lib)
    endif ()
    set (HDF4_INSTALL_FMWK_DIR ${CMAKE_INSTALL_FRAMEWORK_PREFIX})
  else ()
    set (HDF4_INSTALL_JAR_DIR lib)
  endif ()
  set (HDF4_INSTALL_LIB_DIR lib)
endif ()
if (NOT HDF4_INSTALL_INCLUDE_DIR)
  set (HDF4_INSTALL_INCLUDE_DIR include)
endif ()
if (NOT HDF4_INSTALL_DATA_DIR)
  if (NOT WIN32)
    if (APPLE)
      if (HDF4_BUILD_FRAMEWORKS)
        set (HDF4_INSTALL_EXTRA_DIR ../SharedSupport)
      else ()
        set (HDF4_INSTALL_EXTRA_DIR share)
      endif ()
      set (HDF4_INSTALL_FWRK_DIR ${CMAKE_INSTALL_FRAMEWORK_PREFIX})
    endif ()
    set (HDF4_INSTALL_DATA_DIR share)
    set (HDF4_INSTALL_CMAKE_DIR share/cmake)
  else ()
    set (HDF4_INSTALL_DATA_DIR ".")
    set (HDF4_INSTALL_CMAKE_DIR cmake)
  endif ()
endif ()

if(DEFINED ADDITIONAL_CMAKE_PREFIX_PATH AND EXISTS "${ADDITIONAL_CMAKE_PREFIX_PATH}")
  set (CMAKE_PREFIX_PATH ${ADDITIONAL_CMAKE_PREFIX_PATH} ${CMAKE_PREFIX_PATH})
endif()

#-----------------------------------------------------------------------------
# parse the full version number from hfile.h and include in H4_VERS_INFO
#-----------------------------------------------------------------------------

include(util)
check_version(H4_VERS_MAJOR H4_VERS_MINOR H4_VERS_RELEASE H4_VERS_SUBRELEASE)
set(VERSION "${H4_VERS_MAJOR}.${H4_VERS_MINOR}.${H4_VERS_RELEASE}")

set(SO_VERSION ${H4_VERS_MAJOR})

if(OSX_FRAMEWORK)
    set(FRAMEWORK_VERSION "${H4_VERS_MAJOR}")
    set(HDF4_INSTALL_DATA_DIR ${INSTALL_LIB_DIR}/${PROJECT_LOWER_NAME}.framework/Versions/${FRAMEWORK_VERSION}/Resources)
endif()
report_version(${PROJECT_NAME} "${VERSION}")

#-----------------------------------------------------------------------------
# Basic HDF4 stuff here
#-----------------------------------------------------------------------------
set (HDF4_PACKAGE "hdf4")
set (HDF4_PACKAGE_NAME "HDF")
set (HDF4_PACKAGE_VERSION "${H4_VERS_MAJOR}.${H4_VERS_MINOR}.${H4_VERS_RELEASE}")
set (HDF4_PACKAGE_VERSION_MAJOR "${H4_VERS_MAJOR}.${H4_VERS_MINOR}")
set (HDF4_PACKAGE_VERSION_MINOR "${H4_VERS_RELEASE}")
set (HDF4_PACKAGE_VERSION_STRING "${HDF4_PACKAGE_VERSION}")
if (NOT "${H4_VERS_SUBRELEASE}" STREQUAL "")
  set (HDF4_PACKAGE_VERSION_STRING "${HDF4_PACKAGE_VERSION_STRING}-${H4_VERS_SUBRELEASE}")
endif ()
set (HDF4_PACKAGE_STRING "${HDF4_PACKAGE_NAME} ${HDF4_PACKAGE_VERSION_STRING}")
set (HDF4_PACKAGE_TARNAME "${HDF4_PACKAGE}${HDF_PACKAGE_EXT}")
set (HDF4_PACKAGE_URL "http://www.hdfgroup.org")
set (HDF4_PACKAGE_BUGREPORT "help@hdfgroup.org")

#-----------------------------------------------------------------------------
# Include some macros for reusable code
#-----------------------------------------------------------------------------
include (${HDF_RESOURCES_EXT_DIR}/HDFMacros.cmake)
include (${HDF_RESOURCES_EXT_DIR}/HDFLibMacros.cmake)
include (${HDF_RESOURCES_DIR}/HDF4Macros.cmake)

#-----------------------------------------------------------------------------
# Setup output Directories
#-----------------------------------------------------------------------------
if (NOT HDF4_EXTERNALLY_CONFIGURED)
  set (CMAKE_RUNTIME_OUTPUT_DIRECTORY
      ${PROJECT_BINARY_DIR}/bin CACHE PATH "Single Directory for all Executables."
  )
  set (CMAKE_LIBRARY_OUTPUT_DIRECTORY
      ${PROJECT_BINARY_DIR}/bin CACHE PATH "Single Directory for all Libraries"
  )
  set (CMAKE_ARCHIVE_OUTPUT_DIRECTORY
      ${PROJECT_BINARY_DIR}/bin CACHE PATH "Single Directory for all static libraries."
  )
  set (CMAKE_Fortran_MODULE_DIRECTORY
      ${PROJECT_BINARY_DIR}/bin/fortran CACHE PATH "Single Directory for all fortran modules."
  )
  if (WIN32)
    set (CMAKE_TEST_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CMAKE_BUILD_TYPE})
    set (CMAKE_PDB_OUTPUT_DIRECTORY
        ${PROJECT_BINARY_DIR}/bin CACHE PATH "Single Directory for all pdb files."
    )
  else ()
    set (CMAKE_TEST_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
  endif ()
else ()
  # if we are externally configured, but the project uses old cmake scripts
  # this may not be set and utilities like Hdetect will fail
  if (NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY)
    set (CMAKE_RUNTIME_OUTPUT_DIRECTORY ${EXECUTABLE_OUTPUT_PATH})
  endif ()
endif ()

#-----------------------------------------------------------------------------
# Targets built within this project are exported at Install time for use
# by other projects using FindHDF4.
#-----------------------------------------------------------------------------
if (NOT HDF4_EXPORTED_TARGETS)
  set (HDF4_EXPORTED_TARGETS "${PROJECT_NAME}Targets")
endif ()

#-----------------------------------------------------------------------------
# To include a library in the list exported by the project AT BUILD TIME,
# add it to this variable. This is NOT used by Make Install, but for projects
# which include hdf4 as a sub-project within their build tree
#-----------------------------------------------------------------------------
set_global_variable (HDF4_LIBRARIES_TO_EXPORT "")
set_global_variable (HDF4_UTILS_TO_EXPORT "")
set (EXTERNAL_HEADER_LIST "")
set (EXTERNAL_LIBRARY_LIST "")
set (EXTERNAL_LIBRARYDLL_LIST "")

#-----------------------------------------------------------------------------
# Run all the CMake configuration tests for our build environment
#-----------------------------------------------------------------------------
include (${HDF_RESOURCES_DIR}/ConfigureChecks.cmake)
configure_file(${CMAKE_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake IMMEDIATE @ONLY)


set (CMAKE_INCLUDE_CURRENT_DIR_IN_INTERFACE ON)

#-----------------------------------------------------------------------------
# Mac OS X Options
#-----------------------------------------------------------------------------
# if (HDF4_BUILD_FRAMEWORKS AND NOT BUILD_SHARED_LIBS)
#   set (BUILD_SHARED_LIBS ON CACHE BOOL "Build Shared Libraries")
# endif ()

#-----------------------------------------------------------------------------
# Option to Build Shared and Static libs, default is static
#-----------------------------------------------------------------------------
# option (BUILD_SHARED_LIBS "Build Shared Libraries" OFF)
set (H4_ENABLE_SHARED_LIB NO)
if (BUILD_SHARED_LIBS)
  set (H4_ENABLE_SHARED_LIB YES)
  set (LINK_SHARED_LIBS ${LINK_LIBS})
endif ()
set (H4_ENABLE_STATIC_LIB YES)
set (CMAKE_POSITION_INDEPENDENT_CODE ON)

add_definitions (-DBIG_LONGS -DSWAP)
add_definitions (-DHAVE_CONFIG_H)

#-----------------------------------------------------------------------------
# Temporary disable optimization flag
#-----------------------------------------------------------------------------
if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin" OR CYGWIN)
  foreach (flag_var
      CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE
      CMAKE_C_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO
      CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE
      CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_RELWITHDEBINFO)
    if (${flag_var} MATCHES "O3")
      string (REGEX REPLACE "O3" "O0" ${flag_var} "${${flag_var}}")
    endif ()
  endforeach ()
endif ()

#-----------------------------------------------------------------------------
# Option to use code coverage
#-----------------------------------------------------------------------------
option (HDF4_ENABLE_COVERAGE "Enable code coverage for Libraries and Programs" OFF)
if (HDF4_ENABLE_COVERAGE)
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -O0 -fprofile-arcs -ftest-coverage")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -O0 -fprofile-arcs -ftest-coverage")
    set (LDFLAGS "${LDFLAGS} -fprofile-arcs -ftest-coverage")
endif ()

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
# Include the main src and config directories
#-----------------------------------------------------------------------------
set (HDF4_INCLUDE_DIRECTORIES
    ${HDF4_HDFSOURCE_DIR}
    ${HDF4_MFHDFSOURCE_DIR}
    ${HDF4_SOURCE_DIR}
    ${HDF4_BINARY_DIR}
    ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
)
INCLUDE_DIRECTORIES (${HDF4_INCLUDE_DIRECTORIES} )

#-----------------------------------------------------------------------------
# When building utility executables that generate other (source) files :
# we make use of the following variables defined in the root CMakeLists.
# Certain systems may add /Debug or /Release to output paths
# and we need to call the executable from inside the CMake configuration
#-----------------------------------------------------------------------------
set (EXE_EXT "")
if (WIN32)
  set (EXE_EXT ".exe")
  if (NOT CYGWIN)
    add_definitions (-D_BIND_TO_CURRENT_VCLIBS_VERSION=1)
    add_definitions (-D_CRT_SECURE_NO_WARNINGS)
    add_definitions (-D_CONSOLE)
  endif ()
endif ()

if (MSVC)
  set (CMAKE_MFC_FLAG 0)
  set (WIN_COMPILE_FLAGS "")
  set (WIN_LINK_FLAGS "")
endif ()

set (MAKE_SYSTEM)
if (CMAKE_BUILD_TOOL MATCHES "make")
  set (MAKE_SYSTEM 1)
endif ()

set (CFG_INIT "/${CMAKE_CFG_INTDIR}")
if (MAKE_SYSTEM)
  set (CFG_INIT "")
endif ()

#-----------------------------------------------------------------------------
# Add some definitions for Debug Builds
#-----------------------------------------------------------------------------
if (CMAKE_BUILD_TYPE MATCHES Debug)
  #-- NMake Makefiles will overwhelm the console with warnings if -Wall is used.
  if (NOT WIN32)
    add_definitions (-Wall)
  endif ()
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
  endif ()
  if (WIN32)
    add_definitions (-D_CRT_SECURE_NO_WARNINGS)
  endif ()
  # Borland uses -w- to suppress warnings.
  if (BORLAND)
    set (HDF4_WARNINGS_BLOCKED 1)
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -w-")
  endif ()

  # Most compilers use -w to suppress warnings.
  if (NOT HDF4_WARNINGS_BLOCKED)
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -w")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -w")
  endif ()
endif ()

#-----------------------------------------------------------------------------
# This is in here to help some of the GCC based IDES like Eclipse
# and code blocks parse the compiler errors and warnings better.
#-----------------------------------------------------------------------------
if (CMAKE_COMPILER_IS_GNUCC)
  set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fmessage-length=0")
endif ()
if (CMAKE_COMPILER_IS_GNUCXX)
  set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fmessage-length=0")
endif ()

#-----------------------------------------------------------------------------
# Option to Enable MPI Parallel
#-----------------------------------------------------------------------------
set (CMAKE_MODULE_PATH ${HDF_RESOURCES_DIR} ${HDF_RESOURCES_EXT_DIR} ${CMAKE_MODULE_PATH})
option (HDF4_ENABLE_PARALLEL "Enable parallel build (requires MPI)" OFF)
if (HDF4_ENABLE_PARALLEL)
  include (FindMPI)
  INCLUDE_DIRECTORIES (${MPI_C_INCLUDE_PATH})
  if (MPI_C_FOUND)
    set (H4_HAVE_PARALLEL 1)
    # MPI checks, only do these if MPI_C_FOUND is true, otherwise they always fail
    # and once set, they are cached as false and not regenerated
    set (CMAKE_REQUIRED_LIBRARIES "${MPI_C_LIBRARIES}" )
    CHECK_FUNCTION_EXISTS (MPI_File_get_size H4_HAVE_MPI_GET_SIZE)
    # Used by Fortran + MPI
    CHECK_SYMBOL_EXISTS (MPI_Comm_c2f "${MPI_C_INCLUDE_PATH}/mpi.h"  H4_HAVE_MPI_MULTI_LANG_Comm)
    CHECK_SYMBOL_EXISTS (MPI_Info_c2f "${MPI_C_INCLUDE_PATH}/mpi.h"  H4_HAVE_MPI_MULTI_LANG_Info)
  else ()
    message (STATUS "Parallel libraries not found")
  endif ()
endif ()

# Parallel IO usage requires MPI to be Linked and Included
if (H4_HAVE_PARALLEL)
  set (LINK_LIBS ${LINK_LIBS} ${MPI_C_LIBRARIES})
  if (MPI_C_LINK_FLAGS)
    set (CMAKE_EXE_LINKER_FLAGS "${MPI_C_LINK_FLAGS} ${CMAKE_EXE_LINKER_FLAGS}")
  endif ()
endif ()

#-----------------------------------------------------------------------------
# Include user macros
#-----------------------------------------------------------------------------
include (UserMacros.cmake)

#-----------------------------------------------------------------------------
# Include filter (zlib, szip, etc.) macros
#-----------------------------------------------------------------------------
# include (CMakeFilters.cmake)

#-----------------------------------------------------------------------------
# Option for external libraries on windows
#-----------------------------------------------------------------------------
# option (HDF4_PACKAGE_EXTLIBS "CPACK - include external libraries" OFF)
# if (NOT HDF4_EXTERNALLY_CONFIGURED)
#   if (HDF4_PACKAGE_EXTLIBS)
#     set (HDF4_NO_PACKAGES OFF CACHE BOOL "CPACK - Disable packaging" FORCE)
#     if (HDF4_ENABLE_JPEG_LIB_SUPPORT AND JPEG_FOUND)
#       PACKAGE_JPEG_LIBRARY (${HDF4_ALLOW_EXTERNAL_SUPPORT})
#     endif ()
#
#     if (HDF4_ENABLE_Z_LIB_SUPPORT AND ZLIB_FOUND)
#       PACKAGE_ZLIB_LIBRARY (${HDF4_ALLOW_EXTERNAL_SUPPORT})
#     endif ()
#
#     if (HDF4_ENABLE_SZIP_SUPPORT AND SZIP_FOUND)
#       PACKAGE_SZIP_LIBRARY (${HDF4_ALLOW_EXTERNAL_SUPPORT})
#     endif ()
#   endif ()
# endif ()

include(FindAnyProject)
find_anyproject(ZLIB DEFAULT ON)
if (ZLIB_FOUND)
    set (HDFEOS_ENABLE_Z_LIB_SUPPORT ON)
    set (H4_HAVE_FILTER_DEFLATE 1)
    set (H4_HAVE_ZLIB_H 1)
    set (H4_HAVE_LIBZ 1)
    set (H4_ZLIB_HEADER "zlib.h")
endif()

find_anyproject(JPEG DEFAULT ON)
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

set(LINK_LIBS ${LINK_LIBS} ${TARGET_LINK_LIB})
set(LINK_SHARED_LIBS ${LINK_SHARED_LIBS} ${TARGET_LINK_LIB})
# set(LINK_COMP_LIBS ${LINK_COMP_LIBS} ${TARGET_LINK_LIB})

set(PACKAGE_NAME ${PROJECT_LOWER_NAME})
set(PACKAGE_UPPER_NAME ${PROJECT_NAME})

if(OSX_FRAMEWORK OR BUILD_SHARED_LIBS)
    set(HDF_TARGET_NAME ${HDF4_SRC_LIBSH_TARGET})
    set(MFHDF_TARGET_NAME ${HDF4_MF_LIBSH_TARGET})
    set(XDR_TARGET_NAME ${HDF4_MF_XDR_LIBSH_TARGET})
else()
    set(HDF_TARGET_NAME ${HDF4_SRC_LIB_TARGET})
    set(MFHDF_TARGET_NAME ${HDF4_MF_LIB_TARGET})
    set(XDR_TARGET_NAME ${HDF4_MF_XDR_LIB_TARGET})
endif()

#-----------------------------------------------------------------------------
# Option to build HDF4 xdr Library
#-----------------------------------------------------------------------------
option (HDF4_BUILD_XDR_LIB  "Build HDF4 XDR Library" OFF)
if (WIN32 AND NOT MINGW)
  set (HDF4_BUILD_XDR_LIB ON CACHE BOOL "Build HDF4 XDR Library" FORCE)
else ()
  include (FindXDR)
  if (XDR_FOUND)
    set (CMAKE_REQUIRED_LIBRARIES "${XDR_LIBRARIES}" )
    message (STATUS "HDF4 XDR Library found: ${XDR_LIBRARIES}")
    set (LINK_LIBS ${LINK_LIBS} ${XDR_LIBRARIES})
    set (LINK_SHARED_LIBS ${LINK_SHARED_LIBS} ${XDR_LIBRARIES})
    include_directories(${XDR_INCLUDE_DIRS})
  else ()
    set (HDF4_BUILD_XDR_LIB ON CACHE BOOL "Build HDF4 XDR Library" FORCE)
    message (STATUS "HDF4 XDR Library will be built")
  endif ()
endif ()

if (HDF4_BUILD_XDR_LIB)
  add_subdirectory (${HDF4_SOURCE_DIR}/mfhdf/xdr ${PROJECT_BINARY_DIR}/xdr)
endif ()

#-----------------------------------------------------------------------------
# Add the HDF4 Library Target to the build
#-----------------------------------------------------------------------------
add_subdirectory (${HDF4_SOURCE_DIR}/hdf/src    ${PROJECT_BINARY_DIR}/hdf/src )
add_subdirectory (${HDF4_SOURCE_DIR}/mfhdf/libsrc   ${PROJECT_BINARY_DIR}/mfhdf/libsrc)

# if (HDF4_ALLOW_EXTERNAL_SUPPORT MATCHES "GIT" OR HDF4_ALLOW_EXTERNAL_SUPPORT MATCHES "SVN" OR HDF4_ALLOW_EXTERNAL_SUPPORT MATCHES "TGZ")
#   if (JPEG_FOUND AND JPEG_USE_EXTERNAL)
#     add_dependencies (${HDF4_SRC_LIB_TARGET} JPEG)
#     if (BUILD_SHARED_LIBS)
#       add_dependencies (${HDF4_SRC_LIBSH_TARGET} JPEG)
#     endif ()
#   endif ()
#   if (ZLIB_FOUND AND ZLIB_USE_EXTERNAL)
#     add_dependencies (${HDF4_SRC_LIB_TARGET} ZLIB)
#     if (BUILD_SHARED_LIBS)
#       add_dependencies (${HDF4_SRC_LIBSH_TARGET} ZLIB)
#     endif ()
#   endif ()
#   if (SZIP_FOUND AND SZIP_USE_EXTERNAL)
#     add_dependencies (${HDF4_SRC_LIB_TARGET} SZIP)
#     if (BUILD_SHARED_LIBS)
#       add_dependencies (${HDF4_SRC_LIBSH_TARGET} SZIP)
#     endif ()
#   endif ()
# endif ()

if (HDF4_BUILD_XDR_LIB)
  add_dependencies (${HDF4_MF_LIB_TARGET} ${HDF4_MF_XDR_LIB_TARGET})
  if (BUILD_SHARED_LIBS)
    add_dependencies (${HDF4_MF_LIBSH_TARGET} ${HDF4_MF_XDR_LIBSH_TARGET})
  endif ()
endif ()

#-----------------------------------------------------------------------------
# Dashboard and Testing Settings
#-----------------------------------------------------------------------------
option (BUILD_TESTING "Build HDF4 Unit Testing" ON)
if (BUILD_TESTING)
  set (DART_TESTING_TIMEOUT 1200
      CACHE INTEGER
      "Timeout in seconds for each test (default 1200=20minutes)"
  )
  enable_testing ()
  include (CTest)

  # include (${HDF4_SOURCE_DIR}/CTestConfig.cmake)
  configure_file (${HDF_RESOURCES_DIR}/CTestCustom.cmake ${HDF4_BINARY_DIR}/CTestCustom.ctest @ONLY)

  if (NOT HDF4_EXTERNALLY_CONFIGURED)
    if (EXISTS "${HDF4_SOURCE_DIR}/hdf/test" AND IS_DIRECTORY "${HDF4_SOURCE_DIR}/hdf/test")
      add_subdirectory (${HDF4_SOURCE_DIR}/hdf/test   ${PROJECT_BINARY_DIR}/hdf/test)
    endif ()
    if (EXISTS "${HDF4_SOURCE_DIR}/mfhdf/test" AND IS_DIRECTORY "${HDF4_SOURCE_DIR}/mfhdf/test")
      add_subdirectory (${HDF4_SOURCE_DIR}/mfhdf/test ${PROJECT_BINARY_DIR}/mfhdf/test)
    endif ()
  endif ()
endif ()

#-----------------------------------------------------------------------------
# Option to build Fortran bindings/tests/examples
# Make sure this appears before the CONFIGURE_FILE step
# so that fortran name mangling is detected before writing H4config.h
#-----------------------------------------------------------------------------
# Set default name mangling : overridden by Fortran detection in fortran dir
set (H4_F77_FUNC "H4_F77_FUNC(name,NAME) name ## _")
set (H4_F77_FUNC_ "H4_F77_FUNC_(name,NAME) name ## __")
if (EXISTS "${HDF4_SOURCE_DIR}/mfhdf/fortran" AND IS_DIRECTORY "${HDF4_SOURCE_DIR}/mfhdf/fortran")
  option (HDF4_BUILD_FORTRAN "Build FORTRAN support" ON)
  if (HDF4_BUILD_FORTRAN)
    if (WIN32)
      set (H4_F77_FUNC "H4_F77_FUNC(name,NAME) NAME")
      set (H4_F77_FUNC_ "H4_F77_FUNC_(name,NAME) NAME")
    endif ()
    include (${HDF_RESOURCES_DIR}/HDF4UseFortran.cmake)
    add_subdirectory (${HDF4_SOURCE_DIR}/mfhdf/fortran ${PROJECT_BINARY_DIR}/mfhdf/fortran)
    add_subdirectory (${HDF4_SOURCE_DIR}/hdf/fortran ${PROJECT_BINARY_DIR}/hdf/fortran)
  endif ()
endif ()

if (MSVC OR MINGW)
  set (H4_HDSETVBUF "HDsetvbuf(F,S,M,Z) (((Z)>1)?setvbuf(F,S,M,Z):setvbuf(F,S,M,2))")
else ()
  set (H4_HDSETVBUF "NOP")
endif ()

#-----------------------------------------------------------------------------
# Library utilities
#-----------------------------------------------------------------------------
add_subdirectory (${HDF4_SOURCE_DIR}/hdf   ${PROJECT_BINARY_DIR}/hdf)
add_subdirectory (${HDF4_SOURCE_DIR}/mfhdf ${PROJECT_BINARY_DIR}/mfhdf)

#-----------------------------------------------------------------------------
# Option to build HDF4 Examples
#-----------------------------------------------------------------------------
if (EXISTS "${HDF4_SOURCE_DIR}/mfhdf/examples" AND IS_DIRECTORY "${HDF4_SOURCE_DIR}/mfhdf/examples")
  option (HDF4_BUILD_EXAMPLES  "Build HDF4 Examples" OFF)
  if (HDF4_BUILD_EXAMPLES)
    if (HDF4_BUILD_FORTRAN)
      if (EXISTS "${HDF4_SOURCE_DIR}/hdf/fortran/examples" AND IS_DIRECTORY "${HDF4_SOURCE_DIR}/hdf/fortran/examples")
        add_subdirectory (${HDF4_SOURCE_DIR}/hdf/fortran/examples     ${PROJECT_BINARY_DIR}/hdf/fortran/examples)
      endif ()
      if (EXISTS "${HDF4_SOURCE_DIR}/mfhdf/fortran/examples" AND IS_DIRECTORY "${HDF4_SOURCE_DIR}/mfhdf/fortran/examples")
        add_subdirectory (${HDF4_SOURCE_DIR}/mfhdf/fortran/examples     ${PROJECT_BINARY_DIR}/mfhdf/fortran/examples)
      endif ()
    endif ()

    add_subdirectory (${HDF4_SOURCE_DIR}/hdf/examples    ${PROJECT_BINARY_DIR}/hdf/examples)
    add_subdirectory (${HDF4_SOURCE_DIR}/mfhdf/examples    ${PROJECT_BINARY_DIR}/mfhdf/examples)
  endif ()
endif ()

#-----------------------------------------------------------------------------
# Option to build HDF4 Java Library
#-----------------------------------------------------------------------------
if (EXISTS "${HDF4_SOURCE_DIR}/java" AND IS_DIRECTORY "${HDF4_SOURCE_DIR}/java")
  option (HDF4_BUILD_JAVA  "Build Java HDF Library" OFF)
  if (HDF4_BUILD_JAVA)
    add_subdirectory (${HDF4_SOURCE_DIR}/java ${PROJECT_BINARY_DIR}/java)
  endif ()
endif ()

#-----------------------------------------------------------------------------
# Generate the H4config.h file containing user settings needed by compilation
#-----------------------------------------------------------------------------
configure_file (${HDF_RESOURCES_DIR}/h4config.h.in      ${PROJECT_BINARY_DIR}/h4config.h @ONLY)

# message("HDF4_LIBRARIES_TO_EXPORT ${HDF4_LIBRARIES_TO_EXPORT}")
include (CMakeInstallation.cmake)

add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)
