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

#-----------------------------------------------------------------------------
# Setup include Directories
#-----------------------------------------------------------------------------

include_directories (${HDF4_HDFSOURCE_DIR})
include_directories (${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_BINARY_DIR})

set (HDF4_HDF_SRC_CSRCS
    atom.c
    bitvect.c    
    cnbit.c
    cnone.c
    crle.c
    cskphuff.c
    df24.c
    dfan.c
    dfcomp.c
    dfconv.c
    dfgr.c
    dfgroup.c
    dfimcomp.c
    dfknat.c
    dfkswap.c
    dfp.c
    dfr8.c
    dfrle.c
    dfsd.c
    dfstubs.c
    dfufp2i.c
    dfutil.c
    dynarray.c
    glist.c
    hbitio.c
    hblocks.c
    hbuffer.c
    hchunks.c
    hcomp.c
    hcompri.c
    hdatainfo.c
    hdfalloc.c
    herr.c
    hextelt.c
    hfile.c
    hfiledd.c
    hkit.c
    linklist.c
    mcache.c
    mfan.c
    mfgr.c
    mstdio.c
    tbbt.c
    vattr.c
    vconv.c
    vg.c
    vgp.c
    vhi.c
    vio.c
    vparse.c
    vrw.c
    vsfld.c
)

set (HDF4_HDF_SRC_CHDRS
    atom.h
    bitvect.h
    cnbit.h
    cnone.h
    crle.h
    cskphuff.h
    df.h
    dfan.h
    dfgr.h
    dfrig.h
    dfi.h
    dfsd.h
    dfstubs.h
    dfufp2i.h
    dynarray.h
    glist.h
    H4api_adpt.h
    hbitio.h
    hchunks.h
    hcomp.h
    hcompi.h
    hconv.h
    hdatainfo.h
    hdf.h
    hdfi.h
    herr.h
    hfile.h
    hkit.h
    hlimits.h
    hntdefs.h
    hproto.h
    hqueue.h
    htags.h
    linklist.h
    mcache.h
    mfan.h
    mfgr.h
    mstdio.h
    tbbt.h
    vattr.h
    vg.h
    vgint.h
)

if(JPEG_FOUND)
    set(HDF4_HDF_SRC_CSRCS ${HDF4_HDF_SRC_CSRCS}       
        dfunjpeg.c
        dfjpeg.c
    )
endif()

if(ZLIB_FOUND)
    set(HDF4_HDF_SRC_CSRCS ${HDF4_HDF_SRC_CSRCS}     
        cdeflate.c
        cszip.c
    )
    
    set(HDF4_HDF_SRC_CHDRS ${HDF4_HDF_SRC_CHDRS}  
        cszip.h
        cdeflate.h
    )
endif()

add_library (${HDF4_SRC_LIB} ${LIB_TYPE} ${HDF4_HDF_SRC_CSRCS} ${HDF4_HDF_SRC_CHDRS} ${CMAKE_BINARY_DIR}/h4config.h)

if (BUILD_SHARED_LIBS)
    if (WIN32)
      set (LIB_VERSION ${HDF4_PACKAGE_VERSION_MAJOR})
    else ()
      set (LIB_VERSION ${HDF4_PACKAGE_VERSION})
    endif ()
    set_target_properties (${HDF4_SRC_LIB} PROPERTIES VERSION ${LIB_VERSION})
    set_target_properties (${HDF4_SRC_LIB} PROPERTIES SOVERSION ${LIB_VERSION})
endif ()

#-- Apple Specific install_name for libraries
if (APPLE)
    option (H4_BUILD_WITH_INSTALL_NAME "Build with library install_name set to the installation path" OFF)
    if (H4_BUILD_WITH_INSTALL_NAME)
      set_target_properties(HDF4_SRC_LIB PROPERTIES
          LINK_FLAGS "-current_version ${HDF4_PACKAGE_VERSION} -compatibility_version ${HDF4_PACKAGE_VERSION}"
          INSTALL_NAME_DIR "${INSTALL_LIB_DIR}"
          BUILD_WITH_INSTALL_RPATH ${H4_BUILD_WITH_INSTALL_NAME}
      )
    endif ()
endif ()

if(TARGET_LINK_LIB)
    target_link_libraries(${HDF4_SRC_LIB} PRIVATE ${TARGET_LINK_LIB}) 
endif()
if(DEPENDENCY_LIB)
    add_dependencies(${HDF4_SRC_LIB} ${DEPENDENCY_LIB})  
endif() 

if (WIN32)
  add_definitions (-DDOS_FS)
endif (WIN32)

if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL )
    install(TARGETS ${HDF4_SRC_LIB} 
        RUNTIME DESTINATION "${INSTALL_BIN_DIR}"
        ARCHIVE DESTINATION "${INSTALL_LIB_DIR}"
        LIBRARY DESTINATION "${INSTALL_LIB_DIR}" )
endif()
if(NOT SKIP_INSTALL_HEADERS AND NOT SKIP_INSTALL_ALL )
    install(FILES ${HDF4_HDF_SRC_CHDRS} DESTINATION "${INSTALL_INC_DIR}")
endif()

