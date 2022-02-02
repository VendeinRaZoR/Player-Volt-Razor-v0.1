
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
 *  atml_drv.c
 *
 *      The ATMEL Flashport Device Driver
 */

#include "atmel.h"
#include "devtbl.h"
#include "fs_flash.h"
#include "fs_driver.h"
#include "fs_hal.h"
/*
 *  Device INITIALIZATION
 */

extern DEV_IOSTATUS Atmel_FlashInit( PDEVICE_OBJ pDevObj );
static DEV_IOSTATUS AtmelFlash_CloseHandler( PDEV_IOPACKET pIoPacket );
/*
 *  Devices for the Atmel Flash Drivers are defined here.
 */

static ATMEL_FLASH_DEVOBJ s_AtmelFlashDevobj[] = {

	{ "AT45DB011B",   1,  256, 512 },
	{ "AT45DB021B",   2,  256, 512 },
	{ "AT45DB041B",   4,  256, 512 },
	{ "AT45DB081B",   8,  256, 512 },
	{ "AT45DB161B",  16,  512, 512 },
	{ "AT45DB321B",  32,  512, 512 },
	{  "AT45DB642",  64, 1024, 512 },
	{ "AT45DB1282", 128, 1024, 512 },
	{ "AT45DB2562", 256, 2048, 512 }
};


static struct _DeviceObj s_AtmelFlashDeviceList[] = {

    {
        MAKE_DEVNO(
            DEVICE_TYPE_BLOCK,              /* Block Read/Writes Only       */
            DEVICE_ATMEL_FLASHMEM,
            DEVICE_ATMEL_FLASHMEM_DEV0 ),	/* Device Number                */
        0L,                                 /* Flags                        */
        0L,                                 /* Reference Count              */
        (PDRIVER_OBJ)0,                     /* The Parent Driver            */
        (PDEVICE_OBJ)0,                     /* Next Device (DRV Assigned)   */
        (PDEVICE_OBJ)0,                     /* Binded Device                */
        Atmel_FlashInit,                    /* Initialization for Flash Dev */
        (DEV_PVOID)&s_AtmelFlashDevobj[8]              /* Device Extension             */
    }
};

static DEV_TYPE s_AtmelFlashBindList[] = {
    DEVICE_UNKNOWN
};

/*
 *  IOCTL List for ATMEL
 *
 */

#define ATMELFLASH_IOCTL_RESET \
    _IOCTL_MAKECODE(DEVICE_ATMEL_FLASHMEM,DEVICE_IOCTL_RESET,0)

#define ATMELFLASH_IOCTL_STAT \
    _IOCTL_MAKECODE(DEVICE_ATMEL_FLASHMEM,DEVICE_IOCTL_STAT,0)

#define ATMELFLASH_IOCTL_READ \
    _IOCTL_MAKECODE(DEVICE_ATMEL_FLASHMEM,DEVICE_IOCTL_READ,0)

#define ATMELFLASH_IOCTL_WRITE \
    _IOCTL_MAKECODE(DEVICE_ATMEL_FLASHMEM,DEVICE_IOCTL_WRITE,0)


/* --------------------------------------------------------------------------
 *      Private Handlers
 * -------------------------------------------------------------------------- */

 /* --------------------------------------------------------------------------
 *
 *  AtmelFlash_CloseHandler
 *
 *      Commits the parameters for the Atmel driver.
 *
 *  Parameters:     PDEV_IOPACKET pIoPacket
 *
 *
 *  Returns:
 *
 *
 *
 *  Notes:
 *
 *
 * --------------------------------------------------------------------------
 */
static DEV_IOSTATUS AtmelFlash_CloseHandler( PDEV_IOPACKET pIoPacket )
{
    uint32 count;
#ifdef WEAR_LEVEL_ENABLED
    count = Write_Flash_Data(FLASH_FILE.file_system_start,16,
                            (uint8 *)&FLASH_STORAGE,sizeof( FLASH_STORAGE));
#endif
    return FLASH_IOSTATUS_SUCCESS;
}
/* --------------------------------------------------------------------------
 *
 *  AtmelFlash_ReadHandler
 *
 *      Reads a BLOCK of data from the Flashpart
 *
 *  Parameters:
 *
 *
 *  Returns:
 *
 *
 *
 *  Notes:
 *
 *
 * --------------------------------------------------------------------------
 */

static DEV_IOSTATUS AtmelFlash_ReadHandler( PDEV_IOPACKET pIoPacket )
{

    PDEVICE_OBJ pDevObj;
    DEV_ADDRESS nAddress;
    DEV_PVOID pBuffer;
    PATMEL_FLASH_DEVOBJ _pFlashDev;
    uint16 page_number,start_address;

    /*
     *  Pull off information for the write
     *
     */
    pDevObj = pIoPacket->pDevice;
    nAddress = *(DEV_ADDRESS*)pIoPacket->pDescriptor;
    pBuffer = pIoPacket->pInBuffer;


    DEVOBJ_ASSERT( pDevObj != DEVOBJ_NULL );
    DEVOBJ_ASSERT( pBuffer != DEVOBJ_NULL );

    /*
     *  Read the Data
     */

    page_number = Translate_Block_Number((uint16) nAddress.nBlockAddress.nBlock,&start_address);
    if (FLASH_FILE.buffer < 512)
    {
        Read_Flash(page_number,16,(uint8 *) pBuffer,264 - 16);
        Read_Flash(page_number + 1,0,((uint8 *) pBuffer + 264 - 16),264);
    }
    else
    {
        Read_Flash( page_number, start_address, (uint8 *) pBuffer, 512);
    }
    return FLASH_IOSTATUS_SUCCESS;
}

/* --------------------------------------------------------------------------
 *
 *  AtmelFlash_IoctlHandler
 *
 *      Writes a BLOCK of data to the Flashpart
 *
 *  Parameters:
 *
 *
 *  Returns:
 *
 *
 *
 *  Notes:
 *   A PERFORMANCE IMPROVEMENT WOULD BE TO TRACK THE ACTIVE PAGE FOR THE LARGER
 *   PAGE SIZE DEVICES. USE THE INTERNAL RAM BUFFER AS A CACHE. WHEN A CACHE MISS HAPPENS
 *   THEN PROGRAM THE FLASH, TRANSFER THE PAGE FROM FLASH TO BUFFER AND WRITE THE
 *   NEW 512 BYTE CHUNK INTO THE BUFFER. THE RISK IN THIS IS SOMEONE OUTSIDE OF THE DRIVER
 *   NEEDS TO PERFORM SOME KIND OF A FORCE COMMAND TO FORCE THE BUFFER BACK INTO THE
 *   FLASH. THERE IS A RISK OF LOST DATA DUE TO A POWER SHUTDOWN, USER OR FILE SYSTEM ERROR.
 *   THE 256 MEG PARTS WOULD BE ALMOST 4 TIMES FASTER AND WEAR WOULD BE REDUCED BY 4.
 *
 *
 * --------------------------------------------------------------------------
 */

static DEV_IOSTATUS AtmelFlash_WriteHandler( PDEV_IOPACKET pIoPacket )
{

    uint16 status;
    PDEVICE_OBJ pDevObj;
    DEV_ADDRESS nAddress;
    DEV_PVOID pBuffer;
    uint16 page_number;
    uint16 start_address;
    uint32 count;

    /*
     *  Pull off information for the write
     *
     */
    pDevObj = pIoPacket->pDevice;
    nAddress = *(DEV_ADDRESS*)pIoPacket->pDescriptor;
    pBuffer = pIoPacket->pOutBuffer;
    /*  THIS IS A POINTER TO THE ATMEL DEVICE OBJECT EXTENSION STRUCTURE */
    //_AtmelFlashDevObj* _pFlashDev;

    /* ASSERT IF ANY OF THESE FAIL */
    DEVOBJ_ASSERT( pDevObj != DEVOBJ_NULL );
    DEVOBJ_ASSERT( pBuffer != DEVOBJ_NULL );

    /*
     *  Write the Data
     */
    page_number = Translate_Block_Number((uint16) nAddress.nBlockAddress.nBlock,&start_address);

    if (FLASH_FILE.buffer < 512)
    {
        count = Write_Flash_Data( page_number , start_address, (uint8 *)pBuffer, 248);
        status =  FlashCompare(page_number);
        if (status != DEVICE_SUCCESS)
        {
            return _DEV_IOSTATUS_IOERROR;
        }
        Write_Flash_Data( (page_number +1), 0, ((uint8 *)pBuffer + 248), 264);
        status =  FlashCompare(page_number);
    }
    else
    {
        count = Write_Flash_Data( page_number,  start_address, (uint8 *)pBuffer, 512);
        status =  FlashCompare(page_number);
    }

    if (status != DEVICE_SUCCESS)
    {
        return FLASH_IOSTATUS_IOERROR;
    }
#ifdef WEAR_LEVEL_ENABLED
    if (count > (WEAR_THRESHOLD*FLASH_STORAGE.wearCount + WEAR_THRESHOLD))
    {
        return FLASH_IOSTATUS_RETRY;
    }
#endif
    return FLASH_IOSTATUS_SUCCESS;

}

/* --------------------------------------------------------------------------
 *
 *  AtmelFlash_IoctlHandler
 *
 *
 *
 *  Parameters:
 *
 *
 *  Returns:
 *
 *
 *
 *  Notes:
 *
 *
 * --------------------------------------------------------------------------
 */

static DEV_IOSTATUS AtmelFlash_IoctlHandler( PDEV_IOPACKET pIoPacket )
{
    DEV_IOSTATUS _nIoStatus;
    PDEVSTATS pStats;
    PDEVICE_OBJ pDevObj;
    PATMEL_FLASH_DEVOBJ _pFlashDev;

    /*
     *  Device-specific Operations (The upper TWO BITS are ignored for now)
     */

    switch ( pIoPacket->nFunction & ~_IOCTL_RESERVEDMASK )
    {

    /*
     *  Common Operations
     */

    case ATMELFLASH_IOCTL_RESET:
        UpdateWearCount();
        _nIoStatus = FLASH_IOSTATUS_SUCCESS;
        break;

    case ATMELFLASH_IOCTL_STAT:

        pDevObj = pIoPacket->pDevice;
        pStats = (PDEVSTATS)( pIoPacket->pInBuffer );

        /*  THIS IS A POINTER TO THE ATMEL DEVICE OBJECT EXTENSION STRUCTURE */
        //PATMEL_FLASH_DEVOBJ _pFlashDev;

        DEVOBJ_ASSERT( pDevObj != DEVOBJ_NULL );
        DEVOBJ_ASSERT( pStats != DEVOBJ_NULL );

        _pFlashDev = pDevObj->pDevice_Ext;

       /*
        *  Return statistics
        */

        pStats->nType = (DEV_USHORT)ACCESS_TYPE(pDevObj->nDeviceNo); /* BLOCK DEVICE */
        pStats->blkStats.nBlockSiz = _pFlashDev->nBufferSize;  /*  ALWAYS 512    */

        pStats->blkStats.nTotBlocks = (uint16)(((uint32)FLASH_FILE.file_system_size *
                                    ((uint32)FLASH_FILE.buffer - (uint32)FLASH_FILE.buffer_overhead))>>9);
        _nIoStatus = FLASH_IOSTATUS_SUCCESS;
        break;

    default:
        _nIoStatus = _DEV_IOSTATUS_INVALID_FUNCTION;
    }

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *      Public Members
 * --------------------------------------------------------------------------

/* --------------------------------------------------------------------------
 *
 *  AtmelFlash_DriverInit
 *
 *      Initializes the FAT File Devices above.
 *
 *  Parameters:
 *      None
 *
 *  Returns:
 *      Status of Initialization - Either it Fails or Succeeds.
 *
 *
 *  Notes:
 *      None.
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS AtmelFlash_DriverInit( void )
{
    DEV_IOSTATUS _nIoStatus;
    register int _nIdx;
    DEV_INT  _nTotalDevObjs =
        sizeof( s_AtmelFlashDeviceList ) / sizeof( DEVICE_OBJ );

    /*
     *  Ok, add the devices to the driver
     */

    for ( _nIdx = 0; _nIdx < _nTotalDevObjs; _nIdx++ )
    {
        PDEVICE_OBJ _pDevObj = &s_AtmelFlashDeviceList[_nIdx];

        /*
         *  BIND Device (if available)
         */

        _pDevObj->pDevBinded = GetDeviceObject( s_AtmelFlashBindList[_nIdx] );

        /*
         *  Add the device to the Driver List
         */

        _nIoStatus = AddDeviceObject( _pDevObj );
        if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
        {
            break;
        }
    }

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  AtmelFlash_DriverUnload
 *
 *      Unloads a driver.
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
 *      Not supported.
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS AtmelFlash_DriverUnload( void )
{
    return FLASH_IOSTATUS_SUCCESS;
}

/* --------------------------------------------------------------------------
 *
 *  AtmelFlash_IoDispatch
 *
 *      TODO:
 *
 *  Parameters:
 *      pIoPacket       - The I/O Packet
 *
 *  Returns:
 *      The result of the Dispatch.
 *
 *  Notes:
 *      None.
 *
 * --------------------------------------------------------------------------
 */

static PIODISPATCH theIODispatcher[DEVICE_IO_END] =
{
    IO_NULLHANDLER,                         /* Open     */
    AtmelFlash_CloseHandler,                /* Close    */
    AtmelFlash_ReadHandler,                 /* Read     */
    AtmelFlash_WriteHandler,                /* Write    */
    AtmelFlash_IoctlHandler                 /* Ioctl    */
};

DEV_IOSTATUS AtmelFlash_IoDispatch( PDEV_IOPACKET pIoPacket )
{
    DEVOBJ_ASSERT( pIoPacket != DEVOBJ_NULL );

    return (*theIODispatcher[ pIoPacket->nIoOperation ])( pIoPacket );
}

/* --------------------------------------------------------------------------
 *
 *  Translate_Block_Number
 *
 *      Converts the block and address to the correct format for the Atmel
 *      serial data flash parts.
 *
 *  Parameters:
 *      uint16 block, uint16 * start_address
 *
 *  Returns:
 *      Returns the correct page number
 *
 *  Notes:
 *
 *
 * --------------------------------------------------------------------------
 */

uint16 Translate_Block_Number(uint16 block, uint16 * start_address)
{
    uint16 block_offset,page;

    block_offset = 0;
    page = block<<1;
    switch (FLASH_FILE.flash_size)
    {
        /*case SIZE_1_MEG:
        case SIZE_2_MEG:
        case SIZE_4_MEG:
        case SIZE_8_MEG:
            block = block<<1;
            break; */

        case SIZE_16_MEG:
        case SIZE_32_MEG:
            page = block;
            break;

        case SIZE_64_MEG:
        case SIZE_128_MEG:
            block_offset = (block&0x1);
            page = block>>1;
            break;

        case SIZE_256_MEG:
            block_offset = (block&0x3);
            page = block>>2;
            break;
    }
    * start_address = (FLASH_FILE.buffer_overhead + (block_offset<<9)); /* MULT BY 512 */
    page = (page + FLASH_FILE.file_system_start+1);  /* 1ST BLOCK IS SAVED DRIVER INFO */
    return page;
}


/* --------------------------------------------------------------------------
 *
 *  Atmel_FlashInit
 *
 *      Initializes the FLASH Device
 *
 *  Parameters:
 *      pDevObj         - Pointer to the Device Object
 *
 *  Returns:
 *      Returns result of Initialization.
 *
 *  Notes:
 *
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Atmel_FlashInit( PDEVICE_OBJ pDevObj )
{
    PATMEL_FLASH_DEVOBJ _pFlashDev;

    /* TEST IF THERE IS AN AVAILABLE DEVICE OBJECT FOR THIS DRIVER */
    DEVOBJ_ASSERT( pDevObj != DEVOBJ_NULL );

    Config_Spi();
    File_System_Init();

    _pFlashDev = pDevObj->pDevice_Ext;
    return _DEV_IOSTATUS_SUCCESS;
}