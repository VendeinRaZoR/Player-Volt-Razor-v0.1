
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
 *  atmel.h
 *
 *      Header File for ATMEL Devices
 *
 *
 */

#ifndef __ATMEL_H
#define __ATMEL_H

#include "devobj.h"

/*
 *  Forward Reference
 */

typedef struct _AtmelFlashDevObj  ATMEL_FLASH_DEVOBJ;
typedef struct _AtmelFlashDevObj* PATMEL_FLASH_DEVOBJ;

/*
 *  This is the Extension part for Atmel Flash Devices
 *
 *
 */

struct _AtmelFlashDevObj
{
    char szName[12];                /* Name of the Flash Part       */
    int nDensity;                   /* Density in Megabits          */
    unsigned nBlockSize;            /* Size of each Page in Bytes   */
    unsigned nBufferSize;           /* Size of the Buffering        */
};


/*
 *  ERROR Codes for Flash Device
 */

#define _ATMELFLASH_IOSTATUS_MAKE( Error, Severity ) \
    _DEV_IOSTATUS_MAKE(DEVICE_CLASS_FLASH_MEMORY,Error,Severity)




#define FLASH_IOSTATUS_SUCCESS \
    _ATMELFLASH_IOSTATUS_MAKE(_DEV_IOSTATUS_SUCCESS,_DEV_IOSTATUS_SEVERITY_NONE)

#define FLASH_IOSTATUS_RETRY \
    _ATMELFLASH_IOSTATUS_MAKE(_DEV_IOSTATUS_RETRY,_DEV_IOSTATUS_SEVERITY_ERROR)

#define FLASH_IOSTATUS_IOERROR \
    _ATMELFLASH_IOSTATUS_MAKE(_DEV_IOSTATUS_IOERROR,_DEV_IOSTATUS_SEVERITY_ERROR)

#define FLASH_IOSTATUS_INVALID_FUNCTION \
    _ATMELFLASH_IOSTATUS_MAKE(_DEV_IOSTATUS_INVALID_FUNCTION,_DEV_IOSTATUS_SEVERITY_ERROR)

/*
 *  API
 */

DEV_IOSTATUS Atmel_FlashRead(
    PDEVICE_OBJ pDevObj,
    DEV_ADDRESS nAddress,
    DEV_PVOID pBuffer
);

DEV_IOSTATUS Atmel_FlashWrite(
    PDEVICE_OBJ pDevObj,
    DEV_ADDRESS nAddress,
    DEV_PVOID pBuffer
);

DEV_IOSTATUS Atmel_FlashStat(
    PDEVICE_OBJ pDevObj,
    PDEVSTATS pStats
);
DEV_IOSTATUS Atmel_FlashInit( PDEVICE_OBJ pDevObj );
#endif