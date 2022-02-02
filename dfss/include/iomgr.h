

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
 *  iomgr.h
 *
 *      Header File for I/O Manager (simple version)
 *
 *      The I/O Manager in a File System is responsible for the dispatching
 *      and handling of calls into the FSD by routing system calls to the
 *      appropriate (target) device and managing the Control Blocks for such
 *      requests.
 *
 *      This is a very simple I/O Manager in which the I/O Device Table is
 *      fixed (in a complex system, the table may actually use hashing and be
 *      very dynamic). The following shows a Device Table with k file system 
 *      devices in which each consist of an FCB Table of B buckets (hashing
 *      assumed).
 *
 *             +---------+
 *             |         |             
 *           0 |         |
 *             |         |       +---->    +---------+
 *             +---------+       |       0 |         |
 *             |         |       |         +---------+
 *           1 |         |       |       1 |         |
 *             |         |-------+         +---------+
 *             +---------+       |         |    .    |
 *             |         |       |         |         |
 *             |    .    |       |         |    .    |
 *             |         |       |         |         |
 *             |         |       |         |    .    |
 *             |    .    |       |         +---------+
 *             |         |       |     B-1 |         |
 *             |         |       +---->    +---------+
 *             |    .    |
 *             |         |
 *             +---------+
 *             |         |
 *         k-1 |         |
 *             |         |
 *             +---------+
 *
 *  Open Hashing is used and described below on how the FCB entries are 
 *  organized.
 */

#ifndef __IOMGR_H
#define __IOMGR_H

#ifdef __cplusplus
extern "C" {
#endif

#include "fsd.h"

/*
 *  These methods are considered protected and only accessible by the SYSTEM
 */

#define DEVNAME_DELIMETER       ":"
#define DEVNAME_DELIMETER_LEN   (sizeof(DEVNAME_DELIMETER) - 1)

PDEVICE_OBJ IoManager_GetDeviceObject( DEV_STRING strName );

/*
 *  File Control Block - maintains a record of open files on the device
 *
 *      Only MUTUAL EXCLUSION is supported for this release, which means
 *      the file can only have one open reference on it.
 *
 *      The File Object is aggregated within the FCB and is therefore
 *      pre-allocated prior to opening the file. The File System Driver
 *      specific to that file system, will fill in and allocate the 
 *      extension areas and buffers for the file system.
 */

struct _FCB
{
    struct _FCB* pNextFCB;      /* Pointer to the next FCB on this Key  */
    DEV_STRING   strPathname;   /* The Pathname (Null terminated)       */
    DEV_INT      nRefCount;     /* Reference Count, fixed at "1"        */

    /* The FILE Object used by the I/O      */

#ifdef _FILES_MUTUAL_EXCLUSION
    FILE_OBJ     FileObj;
#else
    PFILE_OBJ   pFileObj;
#endif

};

typedef struct _FCB         FCB;

/*
 *  Used by the SYSTEM level to Create and Release the FCB for a given file
 *  descriptor.
 */

FCB* IoManager_CreateFCB( DEV_STRING strName );
DEV_INT IoManager_RemoveFCB( FCB* pFcb );

/*
 *  Size of the Table is dependent upon the resources a user wishes to 
 *  to allocate. It is best to use a table size that is a prime number:
 *
 *      1,2,3,5,7,9,11,13... 
 */

#define FCB_TBLLEN      13
#define DEV_STRLEN      8

/*
 *  The IO Device Table
 */

struct _IOEntry
{
    DEV_CHAR    szDevName[DEV_STRLEN];  /*  Logical Name of the Device      */
    DEV_TYPE    nDevId;                 /*  Device Number                   */
    DEV_BOOL    bAuto;                  /*  Auto Loading/Mounting Enabled   */

    /*
     *  Table of FCBs for this device (always fixed for now), but this table
     *  uses Hashing to store information. See below
     */

    FCB*        tblFCB[FCB_TBLLEN];
};

typedef struct _IOEntry     IOENTRY;

/*
 *  Setup and Shutdown of the I/O Subsystem
 */

DEV_INT IoManager_Initialize( void );
DEV_INT IoManager_Shutdown( void );

/*
 *  The File Control Block Entries are kept in a Hash Array, that uses'
 *  Open Hashing (since Keys, i.e. strings, may not be unique):
 *
 *          +----------+        +----+----+      +----+----+
 *        0 |     -----+------->|    |  --+----->|    |  --+-----> ...
 *          +----------+        +----+----+      +----+----+
 *        1 |     -----+---+
 *          +----------+   |    +----+----+      +----+----+
 *          |          |   +--->|    |  --+----->|    |  --+-----> ...
 *          |          |        +----+----+      +----+----+
 *          |          |
 *          |          |
 *          |          |
 *          |          |
 *          +----------+        +----+----+      +----+----+
 *      B-1 |     -----+------->|    |  --+----->|    |  --+-----> ...
 *          +----------+        +----+----+      +----+----+
 *
 *
 *  An entry is inserted into the FCB Table whenever an operation is 
 *  requested on a file or directory. It does NOT imply the FILE is 
 *  actually opened by the I/O Manager (as some functions may use implicit
 *  open at the driver level).
 *
 *  In another words any ACCESS into the FILE SYSTEM REQUIRES a Device
 *  Descriptor, i.e. FILE OBJECT.
 *
 */

#ifdef __cplusplus
}
#endif

#endif

