

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
 *  file_api.h
 *
 *      Minimum Supported FILE API
 *
 *      The API follows the UNIX convention for the most part. There will be
 *      a translation between the file system and the file system driver.
 *      The file system or I/O API resides at the application level.
 *
 *      All functions, unless otherwise specified will return either a "0" or
 *      valid positive value on success. For a failure -1 is always returned!      
 */

#ifndef __FILE_API_H
#define __FILE_API_H

#ifdef __cplusplus
extern "C" {
#endif

#include "fsd.h"

/*
 *  Equates (Unix and Windows compatible)
 */

typedef int FILEDESC;
typedef int DIRDESC;

typedef long FILEPOS;
typedef long DIRPOS;

#define UNDEFINED_FILEDESC      -1
#define UNDEFINED_DIRDESC       -1

#define _ERRNO(e) \
    ((int)( -(e) ))

#define _ISERROR(e) \
    ((e) < 0)

/*
 *  SYSTEM Startup and SHUTDOWN
 */

void sys_initialize( DEV_BOOL func );

#define sys_startup() \
     sys_initialize( DEVOBJ_TRUE )
   
#define sys_shutdown() \
    sys_initialize( DEVOBJ_FALSE )

/*
 *  Volume specific operations
 */

int sys_volume( char* devname, DEV_IOCODE func );

#define sys_mount( devname ) \
    sys_volume( devname, _FSD_IOCTL_MOUNT )

int sys_umount( char* devname );

int sys_devstats( char* devname, PDEVSTATS stats );

int sys_format( char* devname, char* volname );

/*
 *  Directory specific operations
 */

int sys_dir( char* dirname, DEV_IOCODE func );

#define sys_mkdir( dirname ) \
    sys_dir( dirname, _FSD_IOCTL_MKDIR )

#define sys_rmdir( dirname ) \
    sys_dir( dirname, _FSD_IOCTL_RMDIR )

DIRDESC sys_opendir( char* dirname );

#define sys_closedir( fd ) \
    sys_close( fd )

int sys_readdir( DIRDESC fd, PDIRECT dir );

#define sys_rewinddir( fd ) \
    (int)sys_lseek( fd, 0, _SEEK_BEG )

/*
 *  File I/O operations
 */

FILEDESC sys_creat( char* name, int perm );

FILEDESC sys_open( char* name, int flags, int perm );

int sys_close( FILEDESC fd );

int sys_read( FILEDESC fd, void* buf, unsigned int count );

int sys_write( FILEDESC fd, void* buf, unsigned int count );

/*
 *  Support functionality
 */

FILEPOS sys_tell( FILEDESC fd );

FILEPOS sys_lseek( FILEDESC fd, FILEPOS offset, int origin );

int sys_eof( FILEDESC fd );

int sys_stat( char* name, PSTAT pstat );

int sys_rename( char* oldname, char* newname );

int sys_remove( char* name );

#define sys_unlink(name) \
    sys_remove( name )

#ifdef __cplusplus
}
#endif

#endif
