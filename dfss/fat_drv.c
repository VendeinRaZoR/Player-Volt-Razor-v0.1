
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
 *  fat_drv.c
 *
 *      The FAT Device Drivers handles all instances of FAT Devices in the
 *      system. FAT Device Objects correspond to one and only one Underlying
 *      device and there is one for each Device that has FAT as it's logical
 *      layer.
 *
 *      A single device may support multiple FAT Device Object instances if
 *      that capability exist. This is a form of partioning and a Partition
 *      Management link between the I/O Manager and the Physical Device must
 *      be supported.
 */

#include "platform.h"
#include "fat.h"

/*
 *  A FAT File System, must have a Storage Device Object (or an optional
 *  Filter) binded to it.
 *
 *              +------------------------+
 *              | FAT File System Driver |
 *              +------------------------+
 *                          ^
 *                          |
 *                          |
 *              +------------------------+
 *              |  Filter Driver (opt)   |
 *              +------------------------+
 *                          ^
 *                          |
 *                          |
 *              +------------------------+
 *              |     Storage Device     |
 *              +------------------------+
 */

#include "devtbl.h"

/*
 *  Devices for the FAT are defined here. There may be several devices the
 *  FAT sits atop of and therefore this table is an example of how to define
 *  the File Systems.
 */

static FAT_DEVOBJ s_FatDevice0_Ext;
static FAT_DEVOBJ s_FatDevice1_Ext;

static DEVICE_OBJ s_FatDeviceList[] = {

    {
        MAKE_DEVNO(
            DEVICE_TYPE_BLOCK,
            DEVICE_FAT_FILE_SYSTEM,
            DEVICE_FAT_FILE_SYSTEM_DEV0 ),  /* Device Number                */
        0L,                                 /* Flags                        */
        0L,                                 /* Reference Count              */
        (PDRIVER_OBJ)0,                     /* The Parent Driver            */
        (PDEVICE_OBJ)0,                     /* Next Device (DRV Assigned)   */
        (PDEVICE_OBJ)0,                     /* Binded Device                */
        (FPDEVICEOBJ_INIT)0,                /* No Init for FAT (call MOUNT) */
        (DEV_PVOID)&s_FatDevice0_Ext        /* FAT Device Extension         */
    },

    {
        MAKE_DEVNO(
            DEVICE_TYPE_BLOCK,
            DEVICE_FAT_FILE_SYSTEM,
            DEVICE_FAT_FILE_SYSTEM_DEV1 ),  /* Device Number                */
        0L,                                 /* Flags                        */
        0L,                                 /* Reference Count              */
        (PDRIVER_OBJ)0,                     /* The Parent Driver            */
        (PDEVICE_OBJ)0,                     /* Next Device (DRV Assigned)   */
        (PDEVICE_OBJ)0,                     /* Binded Device                */
        (FPDEVICEOBJ_INIT)0,                /* No Init for FAT (call MOUNT) */
        (DEV_PVOID)&s_FatDevice1_Ext        /* FAT Device Extension         */
    }

};
#ifdef ATMEL_DATA_FLASH_VOLUME
static DEV_TYPE s_FatBindList[] = {
    MAKE_DEVNO(
        DEVICE_TYPE_UNKNOWN,
        DEVICE_ATMEL_FLASHMEM,
        DEVICE_ATMEL_FLASHMEM_DEV0
    ),

    MAKE_DEVNO(
        DEVICE_TYPE_UNKNOWN,
        DEVICE_ATMEL_FLASHMEM,
        DEVICE_ATMEL_FLASHMEM_DEV1
    )
};
#endif

#ifdef RAM_VOLUME
static DEV_TYPE s_FatBindList[] = {
    MAKE_DEVNO(
        DEVICE_TYPE_UNKNOWN,
        DEVICE_RAM_MEM,
        DEVICE_RAM_MEM_DEV0
    ),

    MAKE_DEVNO(
        DEVICE_TYPE_UNKNOWN,
        DEVICE_RAM_MEM,
        DEVICE_RAM_MEM_DEV1
    )
};
#endif
/*
 *  The IOCTL Subsystem Definitions (BASE Definitions)
 */

#define FAT_IOCTL_RESET \
    _IOCTL_MAKECODE(DEVICE_FAT_FILE_SYSTEM,DEVICE_IOCTL_RESET,0)

#define FAT_IOCTL_STAT \
    _IOCTL_MAKECODE(DEVICE_FAT_FILE_SYSTEM,DEVICE_IOCTL_STAT,0)

#define FAT_IOCTL_READ \
    _IOCTL_MAKECODE(DEVICE_FAT_FILE_SYSTEM,DEVICE_IOCTL_READ,0)

#define FAT_IOCTL_WRITE \
    _IOCTL_MAKECODE(DEVICE_FAT_FILE_SYSTEM,DEVICE_IOCTL_WRITE,0)

/*
 *  File Driver Specific
 */

#define FAT_IOCTL_MOUNT \
    _IOCTL_MAKECODE(DEVICE_FAT_FILE_SYSTEM,_FSD_IOCTL_MOUNT,0)

#define FAT_IOCTL_UNMOUNT \
    _IOCTL_MAKECODE(DEVICE_FAT_FILE_SYSTEM,_FSD_IOCTL_UNMOUNT,0)

#define FAT_IOCTL_FORMAT \
    _IOCTL_MAKECODE(DEVICE_FAT_FILE_SYSTEM,_FSD_IOCTL_FORMAT,0)

#define FAT_IOCTL_LSEEK \
    _IOCTL_MAKECODE(DEVICE_FAT_FILE_SYSTEM,_FSD_IOCTL_LSEEK,0)

#define FAT_IOCTL_RENAME \
    _IOCTL_MAKECODE(DEVICE_FAT_FILE_SYSTEM,_FSD_IOCTL_RENAME,0)

#define FAT_IOCTL_REMOVE \
    _IOCTL_MAKECODE(DEVICE_FAT_FILE_SYSTEM,_FSD_IOCTL_REMOVE,0)

#define FAT_IOCTL_MKDIR \
    _IOCTL_MAKECODE(DEVICE_FAT_FILE_SYSTEM,_FSD_IOCTL_MKDIR,0)

#define FAT_IOCTL_RMDIR \
    _IOCTL_MAKECODE(DEVICE_FAT_FILE_SYSTEM,_FSD_IOCTL_RMDIR,0)

#define FAT_IOCTL_OPENDIR \
    _IOCTL_MAKECODE(DEVICE_FAT_FILE_SYSTEM,_FSD_IOCTL_OPENDIR,0)

#define FAT_IOCTL_READDIR \
    _IOCTL_MAKECODE(DEVICE_FAT_FILE_SYSTEM,_FSD_IOCTL_READDIR,0)

#define FAT_IOCTL_FILESTAT \
    _IOCTL_MAKECODE(DEVICE_FAT_FILE_SYSTEM,_FSD_IOCTL_FILESTAT,0)

#define FAT_IOCTL_EOF \
    _IOCTL_MAKECODE(DEVICE_FAT_FILE_SYSTEM,_FSD_IOCTL_EOF,0)


/* --------------------------------------------------------------------------
 *  HANDLERS
 * --------------------------------------------------------------------------
 */

/* --------------------------------------------------------------------------
 *
 *  Fat_OpenHandler
 *
 * --------------------------------------------------------------------------
 */

static DEV_IOSTATUS Fat_OpenHandler( PDEV_IOPACKET pIoPacket )
{
    DEV_IOSTATUS _nIoStatus = 
            Fat_FileOpen(
                (PFILE_OBJ)( pIoPacket->pDescriptor ),
                (DEV_STRING)( pIoPacket->pOutBuffer ),
                pIoPacket->nFunction
             );

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_CloseHandler
 *
 * --------------------------------------------------------------------------
 */

static DEV_IOSTATUS Fat_CloseHandler( PDEV_IOPACKET pIoPacket )
{
    return 
        Fat_FileClose(
            (PFILE_OBJ)( pIoPacket->pDescriptor )
        );
}

/* --------------------------------------------------------------------------
 *
 *  Fat_ReadHandler
 *
 * --------------------------------------------------------------------------
 */

static DEV_IOSTATUS Fat_ReadHandler( PDEV_IOPACKET pIoPacket )
{
    return Fat_FileRead(
                (PFILE_OBJ)( pIoPacket->pDescriptor ),
                pIoPacket->pInBuffer,
                pIoPacket->nInBufferLen,
                &( pIoPacket->nInBufferLen )
           );
}

/* --------------------------------------------------------------------------
 *
 *  Fat_WriteHandler
 *
 * --------------------------------------------------------------------------
 */

static DEV_IOSTATUS Fat_WriteHandler( PDEV_IOPACKET pIoPacket )
{
    return Fat_FileWrite(
                (PFILE_OBJ)( pIoPacket->pDescriptor ),
                pIoPacket->pOutBuffer,
                pIoPacket->nOutBufferLen,
                &( pIoPacket->nOutBufferLen )
           );
}

/* --------------------------------------------------------------------------
 *
 *  Fat_IoctlHandler
 *
 * --------------------------------------------------------------------------
 */

static DEV_IOSTATUS Fat_IoctlHandler( PDEV_IOPACKET pIoPacket )
{
    DEV_IOSTATUS _nIoStatus;

    /*
     *  Device-specific Operations
     */

    switch ( pIoPacket->nFunction & ~_IOCTL_RESERVEDMASK )
    {

    /*
     *  Volume or DEVICE Statistics
     */

    case FAT_IOCTL_STAT:
        _nIoStatus =
            Fat_VolumeStat(
                pIoPacket->pDevice,
                (PDEVSTATS)( pIoPacket->pInBuffer )
            );
        break;

    /*
     *  Volume Operations
     *
     *      The Device Object is always the Input Buffer
     */

    case FAT_IOCTL_MOUNT:
        _nIoStatus =
            Fat_MountVolume( pIoPacket->pDevice );
        break;

    case FAT_IOCTL_UNMOUNT:
        _nIoStatus =
            Fat_UnmountVolume( pIoPacket->pDevice );
        break;

    case FAT_IOCTL_FORMAT:
        _nIoStatus =
            Fat_FormatVolume( 
                pIoPacket->pDevice,
                (DEV_STRING)pIoPacket->pOutBuffer
            );
        break;

    /*
     *  File Operation
     */

    case FAT_IOCTL_LSEEK:
        _nIoStatus = 
            Fat_FileSeek( 
                (PFILE_OBJ)( pIoPacket->pDescriptor ),
                *(DEV_INT*)( pIoPacket->pOutBuffer ),
                pIoPacket->nOutBufferLen,
                (DEV_LONG*)( pIoPacket->pInBuffer )
            );
        break;

    case FAT_IOCTL_RENAME:
        _nIoStatus = 
            Fat_FileRename( 
                (PFILE_OBJ)( pIoPacket->pDescriptor ), 
                (DEV_STRING)pIoPacket->pInBuffer,
                (DEV_STRING)pIoPacket->pOutBuffer
            );
        break;

    case FAT_IOCTL_FILESTAT:
        _nIoStatus = 
            Fat_FileStat(
                (PFILE_OBJ)( pIoPacket->pDescriptor ),
                (DEV_STRING)pIoPacket->pOutBuffer,
                (PSTAT)pIoPacket->pInBuffer
            );
        break;

    case FAT_IOCTL_EOF:
    {
        PFILE_OBJ _pFileObj = (PFILE_OBJ)pIoPacket->pDescriptor;
        PFAT_FILEOBJ _pFatFileObj = FAT_FILEOBJ_EXT(_pFileObj);

        *(DEV_INT*)(pIoPacket->pInBuffer) = 
            ( _pFileObj->nPos == _pFatFileObj->theEntry.DIR_FileSize );

        _nIoStatus = FSD_IOSTATUS_SUCCESS;
    }
    break;

    /*
     *  Directory Operations
     */

    case FAT_IOCTL_MKDIR:
        _nIoStatus = 
            Fat_CreateDir(
                (PFILE_OBJ)( pIoPacket->pDescriptor ), 
                (DEV_STRING)pIoPacket->pOutBuffer
           );        
        break;

    case FAT_IOCTL_RMDIR:
        _nIoStatus = 
            Fat_RemoveDir(
                (PFILE_OBJ)( pIoPacket->pDescriptor ), 
                (DEV_STRING)pIoPacket->pOutBuffer
           );
        break;

    case FAT_IOCTL_READDIR:
        _nIoStatus = 
            Fat_ReadDir(
                (PFILE_OBJ)( pIoPacket->pDescriptor ),
                (PDIRECT)pIoPacket->pInBuffer
            );
        break;

    /*
     *  Unsupported Functions
     */

    default:
        _nIoStatus = FSD_IOSTATUS_INVALID_FUNCTION;

    }

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_DriverInit
 *
 *      Initializes the FAT File Devices above. Since everything is defined
 *      statically, no need to do anything else, except add the devices to
 *      the table.
 *
 *  Parameters:
 *      None
 *
 *  Returns:
 *      Status of Initialization - Either it Fails or Succeeds.
 *
 *  Notes:
 *      None.
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_DriverInit( void )
{
    DEV_IOSTATUS _nIoStatus;
    register DEV_INT _nIdx;
    DEV_INT  _nTotalDevObjs =
        sizeof( s_FatDeviceList ) / sizeof( DEVICE_OBJ );

    /*
     *  Ok, add the devices to the driver
     */

    for ( _nIdx = 0; _nIdx < _nTotalDevObjs; _nIdx++ )
    {
        s_FatDeviceList[_nIdx].pDevBinded =
                GetDeviceObject( s_FatBindList[_nIdx] );

        /*
         *  Add the Device to the DRIVER
         */

        _nIoStatus = AddDeviceObject( &s_FatDeviceList[_nIdx] );
        if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
        {
            break;
        } 
    }

    /*
     *  Format the CODE
     */

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_DriverUnload
 *
 *      Removes the FAT devices from the system (forcing an UNMOUNT on each
 *      device.
 *
 *  Parameters:
 *      None
 *
 *  Returns:
 *      Always returns success for now
 *
 *  Notes:
 *      Any open FILE Handles will be lost and their data corrupted when 
 *      this function is called. It's best to 
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_DriverUnload( void )
{
    register DEV_INT _nIdx;
    DEV_INT  _nTotalDevObjs =
        sizeof( s_FatDeviceList ) / sizeof( DEVICE_OBJ );

    /*
     *  Remove the devices to the driver
     */

    for ( _nIdx = 0; _nIdx < _nTotalDevObjs; _nIdx++ )
    {
        RemoveDeviceObject( &s_FatDeviceList[_nIdx] );
    }

    /*
     *  Format the CODE
     */

    return FSD_IOSTATUS_SUCCESS;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_IoDispatch
 *
 *      MUST be the first call when initializing a FAT Volume on a particular
 *      device. A pointer to the FAT Device Object is necessary as well as
 *      the underlying device object. This in turns binds the FAT FSD to the
 *      device or virtual device through which it communicates.
 *
 *  Parameters:
 *      Fat     - The FAT Object
 *
 *  Returns:
 *      Returns "0" if the Volume was mounted and binded. If a -1 is returned
 *      then any one of the following could be the reason.
 *
 *
 *  Notes:
 *      Initialization of drivers are such that, the lowest level driver or
 *      Physical Device Driver is usually the first loaded and initialized
 *      and the stack is built up from there. Typically the FAT FSD attached
 *      directly to some Block Device.
 *
 *      At this time the FAT is allocated and SHOULD already be binded to
 *      the device it attaches to.
 *
 * --------------------------------------------------------------------------
 */

static PIODISPATCH theIODispatcher[DEVICE_IO_END] =
{
    Fat_OpenHandler,
    Fat_CloseHandler,
    Fat_ReadHandler,
    Fat_WriteHandler,
    Fat_IoctlHandler
};

DEV_IOSTATUS Fat_IoDispatch( PDEV_IOPACKET pIoPacket )
{
    DEVOBJ_ASSERT( pIoPacket != DEVOBJ_NULL );

    return (*theIODispatcher[ pIoPacket->nIoOperation ])( pIoPacket );
}

