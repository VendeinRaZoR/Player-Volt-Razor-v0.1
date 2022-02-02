#ifndef __DEVTBL_H
#define __DEVTBL_H

/* #define RAM_VOLUME */  
 #define ATMEL_DATA_FLASH_VOLUME 


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
 *  devtbl.h
 *
 *      This is a STATIC IMPLEMENTION In which all the Device IDs and their
 *      corresponding DRIVER classes are defined. Follow the directions on
 *      how this table is laid out, when porting the implementation to another
 *      platform.
 */


/*
 *  Driver Defines
 *
 *      The DEVICE CLASS (Major Number) should be defined first
 *
 *      FOLLOWED BY the DRIVER Exports
 *
 *          1) Driver Initialization Method
 *          2) Driver Unload Method
 *          3) I/O Dispatch Handler for the Driver
 *
 *      FOLLOWED BY the Device List (Minor Numbers)
 */

/* --------------------------------------------------------------------------
 *  CLASS: RAM MEMORY
 */
#ifdef RAM_VOLUME

#define DEVICE_RAM_MEM               0x0100

extern DEV_IOSTATUS ffsRamDriverInit( void );
extern DEV_IOSTATUS ffsRamDriverUnload( void );
extern DEV_IOSTATUS ffsRamIoDispatch( PDEV_IOPACKET pIoPacket );

#define DEVICE_RAM_MEM_DEV0          0x0001
#define DEVICE_RAM_MEM_DEV1          0x0002

#endif
 



/* --------------------------------------------------------------------------
 *  CLASS: FLASH MEMORY
 */

/*
 *  FLASH EEPROM
 */
#ifdef ATMEL_DATA_FLASH_VOLUME

#define DEVICE_ATMEL_FLASHMEM               0x0100

extern DEV_IOSTATUS AtmelFlash_DriverInit( void );
extern DEV_IOSTATUS AtmelFlash_DriverUnload( void );
extern DEV_IOSTATUS AtmelFlash_IoDispatch( PDEV_IOPACKET pIoPacket );

#define DEVICE_ATMEL_FLASHMEM_DEV0          0x0001
#define DEVICE_ATMEL_FLASHMEM_DEV1          0x0002

#endif

/* --------------------------------------------------------------------------
 *  CLASS: FILE SYSTEMS
 */

/*
 *  FAT File System
 *
 */

#define DEVICE_FAT_FILE_SYSTEM              0x0200

extern DEV_IOSTATUS Fat_DriverInit( void );
extern DEV_IOSTATUS Fat_DriverUnload( void );
extern DEV_IOSTATUS Fat_IoDispatch( PDEV_IOPACKET pIoPacket );

#define DEVICE_FAT_FILE_SYSTEM_DEV0         0x0001
#define DEVICE_FAT_FILE_SYSTEM_DEV1         0x0002

/*
 *  DRIVER TABLE
 *
 *      By default a Master Table has been defined here, which is a place-
 *      holder for all Device Drivers in the system. It is very important
 *      to note that lower level drivers that bind with higher level drivers
 *      must be in the table first. On startup the lower driver init functions
 *      must run before the higher level functions.
 */

#if defined(DEFINE_DRIVER_TABLE)

BEGIN_DRIVER_TABLE(Master)

    /*
     *  RAM media
     */
#ifdef RAM_VOLUME
    DEFINE_DEVICE_DRIVER(
        MAKE_DEVNO(
            DEVICE_TYPE_UNKNOWN,
            DEVICE_CLASS_GENERIC,
            DEVICE_RAM_MEM),
        ffsRamIoDispatch,
        ffsRamDriverInit,
        ffsRamDriverUnload
    ),
#endif
    /*
     *  ATMEL Flash EEPROM
     */
#ifdef ATMEL_DATA_FLASH_VOLUME
    DEFINE_DEVICE_DRIVER(
        MAKE_DEVNO(
            DEVICE_TYPE_UNKNOWN,
            DEVICE_CLASS_FLASH_MEMORY,
            DEVICE_ATMEL_FLASHMEM),
        AtmelFlash_IoDispatch,
        AtmelFlash_DriverInit,
        AtmelFlash_DriverUnload
    ),
#endif

    /*
     *  FAT File System Driver
     */

    DEFINE_DEVICE_DRIVER(
        MAKE_DEVNO(
            DEVICE_TYPE_UNKNOWN,
            DEVICE_CLASS_FILE_SYSTEM,
            DEVICE_FAT_FILE_SYSTEM),
        Fat_IoDispatch,
        Fat_DriverInit,
        Fat_DriverUnload
    )

END_DRIVER_TABLE(Master)

#endif

#endif

