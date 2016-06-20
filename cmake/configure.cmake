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

if(CMAKE_GENERATOR_TOOLSET MATCHES "v([0-9]+)_xp")
    add_definitions(-D_WIN32_WINNT=0x0501)
endif()

if (BUILD_SHARED_LIBS)
  set (H4_BUILT_AS_DYNAMIC_LIB 1)
  set (H4_ENABLE_SHARED_LIB YES)
else ()
  set (H4_BUILT_AS_STATIC_LIB 1)
  set (H4_ENABLE_STATIC_LIB YES)
  set (CMAKE_POSITION_INDEPENDENT_CODE ON)
endif ()

include (CheckSymbolExists)
include (CheckIncludeFiles)
include (CheckLibraryExists) 
include (CheckFunctionExists)
include (TestBigEndian)
include (CheckTypeSize)

option (HDF4_ENABLE_NETCDF "Build HDF4 versions of NetCDF-3 APIS" ON)
if (HDF4_ENABLE_NETCDF)
  set (H4_HAVE_NETCDF 1)
endif (HDF4_ENABLE_NETCDF)

if (WIN32)
  if (MINGW)
    set (WINDOWS 1) # MinGW tries to imitate Windows
    set (CMAKE_REQUIRED_FLAGS "-DWIN32_LEAN_AND_MEAN=1 -DNOGDI=1")
  endif ()
  set (CMAKE_REQUIRED_LIBRARIES "ws2_32.lib;wsock32.lib")
  if (NOT UNIX AND NOT MINGW)
    set (WINDOWS 1)
    set (CMAKE_REQUIRED_FLAGS "/DWIN32_LEAN_AND_MEAN=1 /DNOGDI=1")
  endif ()
endif ()

check_library_exists (m ceil "" H4_HAVE_LIBM) 
check_library_exists (dl dlopen "" H4_HAVE_LIBDL)
check_library_exists (ws2_32 WSAStartup "" H4_HAVE_LIBWS2_32)
check_library_exists (wsock32 gethostbyname "" H4_HAVE_LIBWSOCK32)
check_library_exists (ucb    gethostname "" H4_HAVE_LIBUCB)
check_library_exists (socket connect "" H4_HAVE_LIBSOCKET)
check_library_exists (c gethostbyname "" NOT_NEED_LIBNSL)
test_big_endian (H4_WORDS_BIGENDIAN)

check_include_files ("ctype.h" HAVE_CTYPE_H)
check_include_files ("stdlib.h" HAVE_STDLIB_H)

if (HAVE_CTYPE_H AND HAVE_STDLIB_H)
    set(H4_STDC_HEADERS 1)
endif ()

check_include_files ("sys/resource.h"  H4_HAVE_SYS_RESOURCE_H)
check_include_files ("sys/time.h"      H4_HAVE_SYS_TIME_H)
check_include_files ("unistd.h"        H4_HAVE_UNISTD_H)
check_include_files ("sys/ioctl.h"     H4_HAVE_SYS_IOCTL_H)
check_include_files ("sys/stat.h"      H4_HAVE_SYS_STAT_H)
check_include_files ("sys/socket.h"    H4_HAVE_SYS_SOCKET_H)
check_include_files ("sys/types.h"     H4_HAVE_SYS_TYPES_H)
check_include_files ("stddef.h"        H4_HAVE_STDDEF_H)
check_include_files ("setjmp.h"        H4_HAVE_SETJMP_H)
check_include_files ("features.h"      H4_HAVE_FEATURES_H)
check_include_files ("dirent.h"        H4_HAVE_DIRENT_H)
check_include_files ("stdint.h"        H4_HAVE_STDINT_H)
check_include_files ("mach/mach_time.h" H4_HAVE_MACH_MACH_TIME_H)
check_include_files ("io.h"            H4_HAVE_IO_H)
check_include_files ("winsock2.h"      H4_HAVE_WINSOCK2_H)
check_include_files ("sys/timeb.h"     H4_HAVE_SYS_TIMEB_H)
check_include_files ("sys/sysinfo.h"   H4_HAVE_SYS_SYSINFO_H)
check_include_files ("sys/proc.h"      H4_HAVE_SYS_PROC_H)
check_include_files ("globus/common.h" H4_HAVE_GLOBUS_COMMON_H)
check_include_files ("pdb.h"           H4_HAVE_PDB_H)
check_include_files ("pthread.h"       H4_HAVE_PTHREAD_H)
check_include_files ("srbclient.h"     H4_HAVE_SRBCLIENT_H)
check_include_files ("string.h"        H4_HAVE_STRING_H)
check_include_files ("strings.h"       H4_HAVE_STRINGS_H)
check_include_files ("time.h"          H4_HAVE_TIME_H)
check_include_files ("stdlib.h"        H4_HAVE_STDLIB_H)
check_include_files ("memory.h"        H4_HAVE_MEMORY_H)
check_include_files ("dlfcn.h"         H4_HAVE_DLFCN_H)
check_include_files ("inttypes.h"      H4_HAVE_INTTYPES_H)
check_include_files ("netinet/in.h"    H4_HAVE_NETINET_IN_H)

check_type_size(off64_t OFF64_T)
if(HAVE_OFF64_T)
   add_definitions(-D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE=1 -D_LARGEFILE_SOURCE)
endif()

check_function_exists (lseek64            H4_HAVE_LSEEK64)
check_function_exists (fseeko64           H4_HAVE_FSEEKO64)
check_function_exists (ftello64           H4_HAVE_FTELLO64)
check_function_exists (ftruncate64        H4_HAVE_FTRUNCATE64)
check_function_exists (fseeko             H4_HAVE_FSEEKO)
check_function_exists (ftello             H4_HAVE_FTELLO)

check_type_size(stat64 STAT64_STRUCT)
check_function_exists (fstat64            H4_HAVE_FSTAT64)
check_function_exists (stat64             H4_HAVE_STAT64)

check_type_size (char           H4_SIZEOF_CHAR)
check_type_size (short          H4_SIZEOF_SHORT)
check_type_size (int            H4_SIZEOF_INT)
check_type_size (unsigned       H4_SIZEOF_UNSIGNED)
check_type_size (long           H4_SIZEOF_LONG)
check_type_size ("long long"    H4_SIZEOF_LONG_LONG)
check_type_size (__int64        H4_SIZEOF___INT64)
if (NOT H4_SIZEOF___INT64)
  set (H4_SIZEOF___INT64 0)
endif ()

check_type_size (float          H4_SIZEOF_FLOAT)
check_type_size (double         H4_SIZEOF_DOUBLE)
check_type_size ("long double"  H4_SIZEOF_LONG_DOUBLE)

check_type_size (int8_t         H4_SIZEOF_INT8_T)
check_type_size (uint8_t        H4_SIZEOF_UINT8_T)
check_type_size (int_least8_t   H4_SIZEOF_INT_LEAST8_T)
check_type_size (uint_least8_t  H4_SIZEOF_UINT_LEAST8_T)
check_type_size (int_fast8_t    H4_SIZEOF_INT_FAST8_T)
check_type_size (uint_fast8_t   H4_SIZEOF_UINT_FAST8_T)

check_type_size (int16_t        H4_SIZEOF_INT16_T)
check_type_size (uint16_t       H4_SIZEOF_UINT16_T)
check_type_size (int_least16_t  H4_SIZEOF_INT_LEAST16_T)
check_type_size (uint_least16_t H4_SIZEOF_UINT_LEAST16_T)
check_type_size (int_fast16_t   H4_SIZEOF_INT_FAST16_T)
check_type_size (uint_fast16_t  H4_SIZEOF_UINT_FAST16_T)

check_type_size (int32_t        H4_SIZEOF_INT32_T)
check_type_size (uint32_t       H4_SIZEOF_UINT32_T)
check_type_size (int_least32_t  H4_SIZEOF_INT_LEAST32_T)
check_type_size (uint_least32_t H4_SIZEOF_UINT_LEAST32_T)
check_type_size (int_fast32_t   H4_SIZEOF_INT_FAST32_T)
check_type_size (uint_fast32_t  H4_SIZEOF_UINT_FAST32_T)

check_type_size (int64_t        H4_SIZEOF_INT64_T)
check_type_size (uint64_t       H4_SIZEOF_UINT64_T)
check_type_size (int_least64_t  H4_SIZEOF_INT_LEAST64_T)
check_type_size (uint_least64_t H4_SIZEOF_UINT_LEAST64_T)
check_type_size (int_fast64_t   H4_SIZEOF_INT_FAST64_T)
check_type_size (uint_fast64_t  H4_SIZEOF_UINT_FAST64_T)

check_type_size (size_t         H4_SIZEOF_SIZE_T)
check_type_size (ssize_t        H4_SIZEOF_SSIZE_T)
if (NOT H4_SIZEOF_SSIZE_T)
    set (H4_SIZEOF_SSIZE_T 0)
endif ()
  
check_type_size (ptrdiff_t      H4_SIZEOF_PTRDIFF_T)  
check_type_size (off_t          H4_SIZEOF_OFF_T)
check_type_size (off64_t        H4_SIZEOF_OFF64_T)
if (NOT H4_SIZEOF_OFF64_T)
  set (H4_SIZEOF_OFF64_T 0)
endif ()

check_type_size (int*  H4_SIZEOF_INTP)

check_function_exists (fork     H4_HAVE_FORK)
check_function_exists (vfork    H4_HAVE_VFORK)
check_function_exists (system   H4_HAVE_SYSTEM)
check_function_exists (wait     H4_HAVE_WAIT)

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


configure_file(${CMAKE_SOURCE_DIR}/cmake/h4config.h.cmakein ${CMAKE_CURRENT_BINARY_DIR}/h4config.h IMMEDIATE @ONLY)
#add_definitions(-DHAVE_H4CONFIG_H) 
add_definitions (-DHAVE_CONFIG_H)

configure_file(${CMAKE_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake IMMEDIATE @ONLY)

