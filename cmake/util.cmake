################################################################################
# Project:  Lib TIFF
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

function(check_version major minor patch rev)

    #-----------------------------------------------------------------------------
    # parse the full version number from hfile.h and include in H4_VERS_INFO
    #-----------------------------------------------------------------------------
    set(VERSION_FILE ${CMAKE_SOURCE_DIR}/hdf/src/hfile.h)

    file(READ ${VERSION_FILE} _hfile_h_contents)
    string (REGEX REPLACE ".*#define[ \t]+LIBVER_MAJOR[ \t]+([0-9]*).*$"
        "\\1" H4_VERS_MAJOR ${_hfile_h_contents})
    string (REGEX REPLACE ".*#define[ \t]+LIBVER_MINOR[ \t]+([0-9]*).*$"
        "\\1" H4_VERS_MINOR ${_hfile_h_contents})
    string (REGEX REPLACE ".*#define[ \t]+LIBVER_RELEASE[ \t]+([0-9]*).*$"
        "\\1" H4_VERS_RELEASE ${_hfile_h_contents})
    string (REGEX REPLACE ".*#define[ \t]+LIBVER_SUBRELEASE[ \t]+\"([0-9A-Za-z.]*)\".*$"
        "\\1" H4_VERS_SUBRELEASE ${_hfile_h_contents})


    set(${major} ${H4_VERS_MAJOR} PARENT_SCOPE)
    set(${minor} ${H4_VERS_MINOR} PARENT_SCOPE)
    set(${patch} ${H4_VERS_RELEASE} PARENT_SCOPE)
    set(${rev} ${H4_VERS_SUBRELEASE} PARENT_SCOPE)

    # Store version string in file for installer needs
    file(TIMESTAMP ${VERSION_FILE} VERSION_DATETIME "%Y-%m-%d %H:%M:%S" UTC)
    set(VERSION ${H4_VERS_MAJOR}.${H4_VERS_MINOR}.${H4_VERS_RELEASE})
    get_cpack_filename(${VERSION} PROJECT_CPACK_FILENAME)
    file(WRITE ${CMAKE_BINARY_DIR}/version.str "${VERSION}\n${VERSION_DATETIME}\n${PROJECT_CPACK_FILENAME}")

endfunction(check_version)


function(report_version name ver)

    string(ASCII 27 Esc)
    set(BoldYellow  "${Esc}[1;33m")
    set(ColourReset "${Esc}[m")

    message("${BoldYellow}${name} version ${ver}${ColourReset}")

endfunction()

# macro to find packages on the host OS
macro( find_exthost_package )
    if(CMAKE_CROSSCOMPILING)
        set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
        set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER )
        set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER )

        find_package( ${ARGN} )

        set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY )
        set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
        set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
    else()
        find_package( ${ARGN} )
    endif()
endmacro()


# macro to find programs on the host OS
macro( find_exthost_program )
    if(CMAKE_CROSSCOMPILING)
        set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
        set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER )
        set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER )

        find_program( ${ARGN} )

        set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY )
        set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
        set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
    else()
        find_program( ${ARGN} )
    endif()
endmacro()

function(get_cpack_filename ver name)
    get_compiler_version(COMPILER)
    if(BUILD_STATIC_LIBS)
        set(STATIC_PREFIX "static-")
    endif()

    set(${name} ${PROJECT_LOWER_NAME}-${STATIC_PREFIX}${ver}-${COMPILER} PARENT_SCOPE)
endfunction()

function(get_compiler_version ver)
    ## Limit compiler version to 2 or 1 digits
    string(REPLACE "." ";" VERSION_LIST ${CMAKE_C_COMPILER_VERSION})
    list(LENGTH VERSION_LIST VERSION_LIST_LEN)
    if(VERSION_LIST_LEN GREATER 2 OR VERSION_LIST_LEN EQUAL 2)
        list(GET VERSION_LIST 0 COMPILER_VERSION_MAJOR)
        list(GET VERSION_LIST 1 COMPILER_VERSION_MINOR)
        set(COMPILER ${CMAKE_C_COMPILER_ID}-${COMPILER_VERSION_MAJOR}.${COMPILER_VERSION_MINOR})
    else()
        set(COMPILER ${CMAKE_C_COMPILER_ID}-${CMAKE_C_COMPILER_VERSION})
    endif()

    if(WIN32)
        if(CMAKE_CL_64)
            set(COMPILER "${COMPILER}-64bit")
        endif()
    endif()

    set(${ver} ${COMPILER} PARENT_SCOPE)
endfunction()
