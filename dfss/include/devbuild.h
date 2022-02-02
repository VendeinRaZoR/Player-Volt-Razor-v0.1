
/* ###########################################################################
#
# Copyright (c) 1999-2002 Atmel Corporation  All Rights Reserved
#
# Atmel Confidential and Proprietary
#
# The following software source code ("Software") is strictly confidential
# and is proprietary to Atmel, Incorporated ("Atmel").  It may only be read,
# used, copied, adapted, modified or otherwise utilized by parties
# (individuals, corporations, or organizations) that have entered into a
# license agreement or confidentiality agreement with Atmel, and are thus
# subject to the terms of that license agreement or confidentiality agreement
# and any other applicable agreement between the party and Atmel.  If there
# is any doubt as to whether a party is entitled to access, read, use, copy,
# adapt, modify or otherwise utilize the Software, or whether a party is
# entitled to disclose the Software to any other party, you should contact
# Atmel.  If you, as a party, have not entered into a license agreement or
# confidentiality agreement with Atmel granting access to this Software,
# all media, copies and printed listings containing the Software should be
# forthwith returned to Atmel.
#
# ##########################################################################*/

/*
 *  config.h
 *
 *      Build Configurations for the FAT File System
 */

#ifndef __DEVBUILD_H
#define __DEVBUILD_H

/*
 *  Architecture
 *
 *      Little or Big Endian (one of these must be defined)
 *
 */

#define _DEV_LITTLE_ENDIAN      1
#define _DEV_BIG_ENDIAN         2

#define _DEV_ARCHITECTURE       _DEV_LITTLE_ENDIAN

#if ( _DEV_ARCHITECTURE == _DEV_LITTLE_ENDIAN ) && \
                ( _DEV_ARCHITECTURE == _DEV_BIG_ENDIAN )

    #error Architecture can only be specified as Little or Big Endian, not both

#elif (_DEV_ARCHITECTURE < _DEV_LITTLE_ENDIAN) && \
                ( _DEV_ARCHITECTURE > _DEV_BIG_ENDIAN )

    #error Architecture must be defined as Little or Big Endian 

#endif
    
/*
 *  Structure Packing
 *
 *      Not all compilers or development platforms support packing of data
 *      structures. Since structures saved on storage devices are typically
 *      packed, reading in their raw byte form into a structure either via
 *      a copy or casting, may cause alignment issues.
 *
 *      Define and use this Equate, when no Compiler Packing support is
 *      available. This specifies that an explicit packing routine is used
 *      instead.
 *
 */

#define _NO_COMPILER_STRUCT_PACKING

/*
 *  File Objects
 *
 *      _FILEOBJ_STATIC
 *
 *          File Objects are defined at runtime and not allocated dyanmically
 *          using the heap. This improves run-time performance, with a penalty
 *          in memory usage.
 */

/*
 *  #define _FILEOBJ_STATIC
 */

/*
 *      _FILES_OPEN
 *
 *          Defines the Maximum number of opened files allowed. For each file
 *          opened an Object associated with that file, FileObj, exists.
 */

#define _FILES_OPEN         32

/*
 *      _FILES_MUTUAL_EXCLUSION
 *
 *          Does not allow MULTIPLE HANDLES open on a file simultaneously. 
 *          This MUST always be set, since the option of file sharing is
 *          not supported for this version.
 */

#define _FILES_MUTUAL_EXCLUSION

/*
 *  Filesystem Defines, which allow a smaller code footprint if the target
 *  device(s) is(are) known ahead of time (fixed build)
 *
 *      _FILESYSTEM_FLAT
 *
 *           The filesystem is FLAT, similar to FAT, but no directory
 *           hiearchy or concept of clusters (only blocks). Not 
 *
 *      _FILESYSTEM_FAT12_ONLY
 *
 *          The FAT filesystem supports FAT12 only
 *
 *      _FILESYSTEM_FAT16_ONLY
 *
 *          The FAT filesystem supports FAT16 only
 */

/*
 *  #define _FILESYSTEM_FLAT
 *  
 *  #define _FILESYSTEM_FAT12_ONLY
 *
 *  #define _FILESYSTEM_FAT16_ONLY
 */

#ifdef _FILESYSTEM_FAT12_ONLY
    #ifdef _FILESYSTEM_FAT16_ONLY
        #undef _FILESYSTEM_FAT12_ONLY
        #undef _FILESYSTEM_FAT16_ONLY
    #endif
#endif

#endif

