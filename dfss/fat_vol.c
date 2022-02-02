
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
 *  fat_vol.c
 *
 *      The methods provided within are Volume Specific operations on a target
 *      FAT Device.
 *
 *      The FAT Device Object caches information about the FAT and a Buffer
 *      Cache between upper level software and the hardware device.
 *
 */

#define _FAT_INCLUDE_CORE
#include "fat.h"

/*
 *  INITIALIZATION of unformatted volumes
 *
 *  The INFORMATION below is used to determine how a target device is split
 *  logically into Sector/Cluster arrangement.
 */

struct _DskSizToSecPerClus_s
{
    unsigned long nDevSize;
    unsigned int  nSecPerClus;
    unsigned int  nRootEntCnt;
};

#ifndef _FILESYSTEM_FAT16_ONLY

    /*
     *  The FAT12 Table can be altered by the user as far as the number of
     *  Root Directory entries allowed.
     */

    static struct _DskSizToSecPerClus_s s_DskTableFAT12[] =
    {
        {     256, 1,  64},     /* Volumes up to 128KB          */
        {     512, 1, 128},     /* Volumes up to 256KB          */
        {    1024, 2, 128},     /* Volumes up to 512KB          */
        {    2048, 2, 256},     /* Volumes up to 1.0MB          */
        {    4096, 2, 512},     /* Volumes up to 2.0MB          */
        {    8400, 4, 512}      /* Volumes up to 4.1MB          */
    };

    #define DSKTABLEFAT12_LEN   \
        (sizeof(s_DskTableFAT12)/sizeof(struct _DskSizToSecPerClus_s))

#endif

#ifndef _FILESYSTEM_FAT12_ONLY

    /*
     *  The FAT16 is defined by Microsoft and it's best to leave it as is
     *
     *      The ROOT Directory entries for FAT16 are always 512, with the
     *      exception of the latter two entries in order to stay within the
     *      parameters of a FAT16 maximum cluster count.
     */

    static struct _DskSizToSecPerClus_s s_DskTableFAT16[] =
    {
        {   8400,  0,  512},    /* Volumes up to 4.1MB, must use FAT12      */
        {  32680,  2,  512},    /* Volumes up to 16MB, 1k Cluster Size      */
        { 262144,  4,  512},    /* Volumes up to 128MB, 2k Cluster Size     */
        { 524288,  8,  512},    /* Volumes up to 256MB, 4k Cluster Size     */
        {1048576, 16,  512},    /* Volumes up to 512MB, 8k Cluster Size     */

        /*
         *  Entries after this are not used unless forced to FAT16
         */

        {2097152, 32, 1024},    /* Volumes up to 1GB, 16k Cluster Size      */
        {4194304, 64, 2048},    /* Volumes up to 2GB, 32k Cluster Size      */
    };

    #define DSKTABLEFAT16_LEN   \
        (sizeof(s_DskTableFAT16)/sizeof(struct _DskSizToSecPerClus_s))

#endif

/*
 *
 */

static char s_szOEMName[] = "MSWIN4.1";
static char* s_szFileSysName[] = {
    "FAT12   ",
    "FAT16   ",
    "FAT32   "
};

#define OFFSET_BS_JMPBOOT           0
#define OFFSET_BS_OEMNAME           3
#define OFFSET_BPB_BYTSPERSEC       11
#define OFFSET_BPB_SECPERCLUS       13
#define OFFSET_BPB_RSVDSECCNT       14
#define OFFSET_BPB_NUMFATS          16
#define OFFSET_BPB_ROOTENTCNT       17
#define OFFSET_BPB_TOTSEC16         19
#define OFFSET_BPB_MEDIA            21
#define OFFSET_BPB_FATSZ16          22
#define OFFSET_BPB_SECPERTRK        24
#define OFFSET_BPB_NUMHEADS         26
#define OFFSET_BPB_HIDDSEC          28
#define OFFSET_BPB_TOTSEC32         32

#define OFFSET_BPB_ENDCOMMON        36

/*
 *  FAT12/FAT16 Specific
 */

#define OFFSET_BS_DRVNUM            36
#define OFFSET_BS_RESERVED1         37
#define OFFSET_BS_BOOTSIG1          38
#define OFFSET_BS_VOLID             39
#define OFFSET_BS_VOLLAB            43
#define OFFSET_BS_FILSYSTYPE        54

#define OFFSET_BS_ENDFAT16          62

/* --------------------------------------------------------------------------
 *
 *  Exceptions Specific to VOLUME
 *
 * --------------------------------------------------------------------------------
 */

BEGIN_EXCEPTION_TABLE(Exception_Vol)

    Exception_Format

END_EXCEPTION_TABLE(Exception_Vol)

/* --------------------------------------------------------------------------
 *
 *  PRIVATE METHODS
 *
 * --------------------------------------------------------------------------------
 */

/*
 *  Packing may not be supported on all platforms and in some cases, packing
 *  the structures may reduce performance of the driver. In either case by
 *  defining _NO_COMPILER_PACK provides an explicit method of translating byte
 *  oriented date to it's stored data structure.
 *
 *  NOTE: Because problems could occur on ODD WORD Boundaries, these values
 *  must be unpacked BYTE by BYTE. This happens in four places.
 */

#if defined( _NO_COMPILER_STRUCT_PACKING )

static
void Fat_BootUnpack(
    PFAT_BOOTSECTOR pFatBoot,
    DEV_USTRING pFatBootBuf
)
{
    DEVOBJ_MEMCPY(
        pFatBoot->BS_jmpBoot,
        pFatBootBuf,
        OFFSET_BPB_BYTSPERSEC
    );

    pFatBoot->BPB_BytesPerSec =
        *(DEV_UINT8*)( pFatBootBuf + OFFSET_BPB_BYTSPERSEC );
    pFatBoot->BPB_BytesPerSec +=
        ((*(DEV_UINT8*)( pFatBootBuf + OFFSET_BPB_BYTSPERSEC + 1 )) << 8 );
    pFatBoot->BPB_SecPerClus =
        *(DEV_UINT8*)( pFatBootBuf + OFFSET_BPB_SECPERCLUS );
    pFatBoot->BPB_RsvdSecCnt =
        *(DEV_UINT8*)( pFatBootBuf + OFFSET_BPB_RSVDSECCNT );
    pFatBoot->BPB_RsvdSecCnt +=
        ((*(DEV_UINT8*)( pFatBootBuf + OFFSET_BPB_RSVDSECCNT + 1 )) << 8 );
    pFatBoot->BPB_NumFATs =
        *(DEV_UINT8*)( pFatBootBuf + OFFSET_BPB_NUMFATS );
    pFatBoot->BPB_RootEntCnt =
        *(DEV_UINT8*)( pFatBootBuf + OFFSET_BPB_ROOTENTCNT );
    pFatBoot->BPB_RootEntCnt +=
        ((*(DEV_UINT8*)( pFatBootBuf + OFFSET_BPB_ROOTENTCNT + 1 )) << 8 );
    pFatBoot->BPB_TotSec16 =
        *(DEV_UINT8*)( pFatBootBuf + OFFSET_BPB_TOTSEC16);
    pFatBoot->BPB_TotSec16 +=
        ((*(DEV_UINT8*)( pFatBootBuf + OFFSET_BPB_TOTSEC16 + 1 )) << 8 );
    pFatBoot->BPB_Media =
        *(DEV_UINT8*)( pFatBootBuf + OFFSET_BPB_MEDIA );
    pFatBoot->BPB_FATSz16 =
        *(DEV_UINT16*)( pFatBootBuf + OFFSET_BPB_FATSZ16 );
    pFatBoot->BPB_SecPerTrk =
        *(DEV_UINT16*)( pFatBootBuf + OFFSET_BPB_SECPERTRK );
    pFatBoot->BPB_NumHeads =
        *(DEV_UINT16*)( pFatBootBuf + OFFSET_BPB_NUMHEADS );
    pFatBoot->BPB_HiddSec =
        *(DEV_UINT32*)( pFatBootBuf + OFFSET_BPB_HIDDSEC );
    pFatBoot->BPB_TotSec32 =
        *(DEV_UINT32*)( pFatBootBuf + OFFSET_BPB_TOTSEC32 );

    /*
     *  Memcpy over the extension
     */

     DEVOBJ_MEMCPY(
        &(pFatBoot->Ext),
        pFatBootBuf + OFFSET_BPB_ENDCOMMON,
        OFFSET_BS_ENDFAT16 - OFFSET_BPB_ENDCOMMON
     );

}

static
void Fat_BootPack(
    PFAT_BOOTSECTOR pFatBoot,
    DEV_USTRING pFatBootBuf
)
{
    DEVOBJ_MEMCPY(
        pFatBootBuf,
        pFatBoot->BS_jmpBoot,
        OFFSET_BPB_BYTSPERSEC
    );

    DEVOBJ_MEMCPY(
        ( pFatBootBuf + OFFSET_BPB_BYTSPERSEC ),
        &( pFatBoot->BPB_BytesPerSec ), 2
    );
    *( pFatBootBuf + OFFSET_BPB_SECPERCLUS ) =
        pFatBoot->BPB_SecPerClus;
    DEVOBJ_MEMCPY(
        ( pFatBootBuf + OFFSET_BPB_RSVDSECCNT ),
        &( pFatBoot->BPB_RsvdSecCnt ), 2
    );
    *( pFatBootBuf + OFFSET_BPB_NUMFATS ) =
        pFatBoot->BPB_NumFATs;
    DEVOBJ_MEMCPY(
        ( pFatBootBuf + OFFSET_BPB_ROOTENTCNT ),
        &( pFatBoot->BPB_RootEntCnt ), 2
    );
    DEVOBJ_MEMCPY(
        ( pFatBootBuf + OFFSET_BPB_TOTSEC16 ),
        &( pFatBoot->BPB_TotSec16 ), 2
    );
    *( pFatBootBuf + OFFSET_BPB_MEDIA ) =
        pFatBoot->BPB_Media;
    DEVOBJ_MEMCPY(
        ( pFatBootBuf + OFFSET_BPB_FATSZ16 ),
        &( pFatBoot->BPB_FATSz16 ), 2
    );
    DEVOBJ_MEMCPY(
        ( pFatBootBuf + OFFSET_BPB_SECPERTRK ),
        &( pFatBoot->BPB_SecPerTrk ), 2
    );
    DEVOBJ_MEMCPY(
        ( pFatBootBuf + OFFSET_BPB_NUMHEADS ),
        &( pFatBoot->BPB_NumHeads ), 2
    );
    DEVOBJ_MEMCPY(
        ( pFatBootBuf + OFFSET_BPB_HIDDSEC ),
        &( pFatBoot->BPB_HiddSec ), 4
    );
    DEVOBJ_MEMCPY(
        ( pFatBootBuf + OFFSET_BPB_TOTSEC32 ),
        &( pFatBoot->BPB_TotSec32 ), 4
    );

    /*
     *  Memcpy over the extension
     */

     DEVOBJ_MEMCPY(
        (pFatBootBuf + OFFSET_BPB_ENDCOMMON),
        &(pFatBoot->Ext),
        OFFSET_BS_ENDFAT16 - OFFSET_BPB_ENDCOMMON
     );
}

#else

#define Fat_BootPack(pFatBoot,pFatBootBuf) \
        DEVOBJ_MEMCPY( pFatBootBuf, _pFatBoot, sizeof( FAT_BOOTSECTOR ) )

#define Fat_BootUnpack(pFatBoot,pFatBootBuf) \
        DEVOBJ_MEMCPY( _pFatBoot, pFatBootBuf, sizeof( FAT_BOOTSECTOR ) )

#endif

/* --------------------------------------------------------------------------
 *
 *  Fat_GetSetCluster
 *
 *      Reads OR Writes a Cluster to the FAT File System.
 *
 *  Parameters:
 *      pDevObj     - The Device Object for this Fat Device
 *      nOperation  - Read or Write
 *      pDevBlk     - The memory block to read/write the Sector(s) into
 *      nCluster    - The Cluster to read/write from
 *
 *  Returns:
 *      Result of the Read/Write operation
 *
 *  Notes:
 *      Generally does a loop to Fat_GetSetSector for BPB_SecPerClus (number
 *      of sectors per cluster).
 *
 * --------------------------------------------------------------------------
 */

#define Fat_ReadCluster(dev,buf,clus) \
    Fat_GetSetCluster( dev, DEVICE_IO_READ, buf, clus )

#define Fat_WriteCluster(dev,buf,clus) \
    Fat_GetSetCluster( dev, DEVICE_IO_WRITE, buf, clus )

static
DEV_IOSTATUS Fat_GetSetCluster(
    PDEVICE_OBJ pDevObj,
    DEV_SHORT nOperation,
    DEV_USTRING pCluster,
    DEV_UINT32 nCluster
)
{
    DEV_UINT32 _nSectorOffset;
    DEV_IOSTATUS _nIoStatus;
    PFAT_BOOTSECTOR _pFatBootSector = FAT_BOOTSECTOR(pDevObj);

    /*
     *  Write until the cluster write is complete or a failure occurs on
     *  one of the sectors.
     */

    for (
        _nSectorOffset = 0;
        _nSectorOffset < _pFatBootSector->BPB_SecPerClus;
        _nSectorOffset++
    )
    {
        /*
         *  Read/Write Sector "m" of Cluster "n"
         */

        _nIoStatus =
            Fat_GetSetSector(
                pDevObj,
                nOperation,
                (pCluster + (_pFatBootSector->BPB_BytesPerSec * _nSectorOffset)),
                FAT_FIRSTSECTOROFCLUSTER(
                    FAT_DEVOBJ_EXT(pDevObj),
                    nCluster) + _nSectorOffset
            );

        /*
         *  Failed?
         */

        if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
        {
            if ( _DEV_IOSTATUS_CODE(_nIoStatus) != _DEV_IOSTATUS_RETRY )
            {
                break;
            }

            _nIoStatus = _DEV_IOSTATUS_SUCCESS;
        }
    }

    /*
     *  Return the result
     */

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  PUBLIC METHODS
 *
 * --------------------------------------------------------------------
 */

/* --------------------------------------------------------------------------
 *
 *  Fat_MountVolume
 *
 *      MUST be the first call when initializing a FAT Volume on a particular
 *      device. A pointer to the FAT Device Object is necessary as well as
 *      the underlying device object. This in turns binds the FAT FSD to the
 *      device or virtual device through which it communicates.
 *
 *      One thing to note the target device may only be able to update blocks
 *      instead of byte by byte. Typical of Flash Devices that must first
 *      ERASE the block before performing a write.
 *
 *  Parameters:
 *      pDevObj		- Pointer to the device object
 *
 *  Returns:
 *      Returns "0" if the Volume was mounted and formatted. If the volume
 *      not formatted, then the mount still succeeds, but an error is still
 *      returned indicating that it has not been properly initialized or
 *      the current format scheme is unsupported by this device.
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

DEV_IOSTATUS Fat_MountVolume( PDEVICE_OBJ pDevObj )
{
    DEV_IOSTATUS _nIoStatus;
    PFAT_DEVOBJ _pFatDevObj;
    PFAT_BOOTSECTOR _pFatBoot;

    /*
     *  Debug
     */

    DEVOBJ_ASSERT( pDevObj != DEVOBJ_NULL );

    /*
     *  Is the volume already mounted?
     */

    if ( Fsd_IsMounted(pDevObj) )
    {
        return FSD_IOSTATUS_SUCCESS;
    }

    /*
     *  Begin Mounting
     */

    _TRY
    {
        BLOCK_DEVSTATS _devStats;

        DEV_IOPACKET _iop;
        DEV_UINT32 _nIdx;

        /*
         *  Get the statistics of the device the FAT Volume is binded to.
         */

        _iop.pDevice = Device_GetBindDev(pDevObj);
        _iop.nIoOperation = DEVICE_IO_CONTROL;
        _iop.nFunction =
            _IOCTL_MAKECODE(
                MAJOR_DEVNO( _iop.pDevice->nDeviceNo ),
                DEVICE_IOCTL_STAT,
                _IOCTL_ACCESS_NEITHER
            );
        _iop.pInBuffer = (DEV_PVOID)&_devStats;
        _iop.nInBufferLen = sizeof( BLOCK_DEVSTATS );

        /*
         *  Is the Device Online?
         */

        _nIoStatus = IO_DISPATCH(&_iop);
        if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
        {
            _THROW_NONE();
        }

        /*
         *  Allocate the FAT Extension for the Device Object
         */

        _pFatDevObj = (PFAT_DEVOBJ)DEVOBJ_MALLOC( sizeof(FAT_DEVOBJ) );
        if ( _pFatDevObj == (PFAT_DEVOBJ)0 )
        {
            _THROW(Exception_Memory);
        }

        /*
         *  Set assignments and initialize the Critical Section
         */

        pDevObj->pDevice_Ext = (DEV_PVOID)_pFatDevObj;
        _pFatBoot = &( _pFatDevObj->FAT_BootSector );

        /*
         *  The Sector should follow the size of the MINIMUM Blocksize
         *  allowed by the target device. For Hard disks this is almost
         *  always configured as 512, but other Mass Storage devices may
         *  vary.
         */

        if ( _devStats.nBlockSiz < eSectorSize512 )
        {
            _pFatBoot->BPB_BytesPerSec = eSectorSize512;
        }
        else
        {
            _pFatBoot->BPB_BytesPerSec = _devStats.nBlockSiz;
        }

        _pFatDevObj->FAT_WriteCache =
            (DEV_USTRING)DEVOBJ_MALLOC( _pFatBoot->BPB_BytesPerSec * 2 );
        if ( _pFatDevObj->FAT_WriteCache == (DEV_USTRING)0 )
        {
            _THROW(Exception_Memory);
        }
        _pFatDevObj->FAT_ReadCache = 
            _pFatDevObj->FAT_WriteCache + _pFatBoot->BPB_BytesPerSec;

        DEVOBJ_INIT_CRITICAL_SECTION(_pFatDevObj->FAT_CriticalSection);
        DEVOBJ_INIT_CRITICAL_SECTION(_pFatDevObj->FAT_DirectoryMutex);

        /*
         *  Read the first Sector/Block of the DEVICE (use the FAT Cache)
         */

        _nIoStatus = Fat_ReadSector( pDevObj, _pFatDevObj->FAT_ReadCache, 0);
        if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
        {
            _THROW(Exception_Device);
        }

        /*
         *  On a successful read of the Device the FAT FSD can be considered
         *  online. Now the block needs to be tested for proper format.
         */

        Device_Enable(pDevObj, Device_Online);

        /*
         *  Validate the FAT Block
         */

        if ( !(( _pFatDevObj->FAT_ReadCache[510] == 0x55 ) &&
                   ( _pFatDevObj->FAT_ReadCache[511] == 0xAA )) )
        {
            _nIoStatus = FSD_IOSTATUS_NOT_FORMATTED;

            /*
             *  Default here, preps formatting without having to read Device
             *  Stats again during Formatting.
             */

            _pFatBoot->BPB_BytesPerSec = _devStats.nBlockSiz;
            _pFatBoot->BPB_TotSec16 = 0;
            _pFatBoot->BPB_TotSec32 = _devStats.nTotBlocks;

            _THROW(Exception_File);
        }

        /*
         *  Copy the BOOT Sector. Since we are not supporting partitioning at
         *  currently, the BOOT is always at the first offset in the device and
         *  since we are not quite mounted yet, we do a Low-Level Read instead
         *  of a Mounted type read using ReadSector.
         */

        Fat_BootUnpack( _pFatBoot, _pFatDevObj->FAT_ReadCache );
        _FATTOBIGENDIAN(_pFatBoot);

        /*
         *  For compatibility reason with this FAT driver, on initialization
         *  the value of the number of Total Sectors is stored in one place
         */

        if ( _pFatBoot->BPB_TotSec16 != 0 )
        {
            _pFatBoot->BPB_TotSec32 = _pFatBoot->BPB_TotSec16;
        }

        /*
         *  Count of Sectors occupied by the root directory
         */

        _pFatDevObj->FAT_RootDirSectors = ((_pFatBoot->BPB_RootEntCnt * 32) +
             (_pFatBoot->BPB_BytesPerSec - 1)) / _pFatBoot->BPB_BytesPerSec;

        /*
         *  Calculate the First Sector of the Root Directory
         */

        _pFatDevObj->FAT_FirstRootDirSector = _pFatBoot->BPB_RsvdSecCnt +
            (_pFatBoot->BPB_NumFATs * _pFatBoot->BPB_FATSz16 );

        /*
         *  Calculate the number of Data Sectors (remember, no FAT32 support
         *  yet)
         */

        _pFatDevObj->FAT_DataClusters = _pFatBoot->BPB_TotSec32 - 
            FAT_FIRSTDATASECTOR(_pFatDevObj);
        _pFatDevObj->FAT_DataClusters /= _pFatBoot->BPB_SecPerClus;

        /*
         *  FAT12 or FAT16?
         */

#ifndef _FILESYSTEM_FAT16_ONLY
        if ( _pFatDevObj->FAT_DataClusters < 4085 )
        {
            _pFatDevObj->FAT_Format = eFatFormat12;
            _pFatDevObj->FAT_Eof = CLUSTERSTATE_FAT12(eClusterEOF);
        }
#endif

#ifndef _FILESYSTEM_FAT12_ONLY
    #ifdef _FILESYSTEM_FAT16_ONLY
        if ( _pFatDevObj->FAT_DataClusters < 65525 )
    #else
        else if ( _pFatDevObj->FAT_DataClusters < 65525 )
    #endif
        {
            _pFatDevObj->FAT_Format = eFatFormat16;
            _pFatDevObj->FAT_Eof = CLUSTERSTATE_FAT16(eClusterEOF);
        }
#endif

        /*
         *  Unsupported Format
         */

        else
        {
            _nIoStatus = FSD_IOSTATUS_INVALID_FORMATTED;
            _THROW(Exception_File);
        }

        /*
         *  Device is mounted and formatted
         */

        Device_Enable(pDevObj, Device_Initialized);

        _pFatDevObj->FAT_FreeClusters = 0;
        _pFatDevObj->FAT_AvailClusters = _pFatDevObj->FAT_DataClusters;
        _pFatDevObj->FAT_WriteCacheBlock = 0;
        _pFatDevObj->FAT_ReadCacheBlock = 0;

        /*
         *  Count Free Sectors...start with the last one and work towards
         *
         *  NOTE: Always add to the Data Clusters as 0 & 1 are reserved,
         *  another Microsoft Paradox, which man may never figure out!
         */

        for ( _nIdx = _pFatDevObj->FAT_DataClusters + 1; _nIdx > 1; _nIdx-- )
        {
            DEV_UINT32 _nCluster;

            /*
             *  Return VALUE is ignored since if a whole block is bad, then
             *  this part of the FAT Space become unusable.
             */

            _nIoStatus = Fat_GetClusterEntry( pDevObj, _nIdx, &_nCluster );
            if ( _DEV_IOSTATUS_SUCCEEDED(_nIoStatus) )
            {
                /*
                 *  Determine the Cluster State
                 */

                if ( _nCluster == eClusterFree )
                {
                    _pFatDevObj->FAT_FirstFreeCluster = _nIdx;
                    _pFatDevObj->FAT_FreeClusters++;
                }
                else if ( _nCluster != eClusterCheck )
                {
                    _pFatDevObj->FAT_AvailClusters--;
                }
            }
        }
    }

    /*
     *  The Exception Handlers
     */

    _CATCH(Exception_Memory)
    {
        _nIoStatus = FSD_IOSTATUS_OUT_OF_MEMORY;

        if ( _pFatDevObj ) { DEVOBJ_FREE(_pFatDevObj->FAT_WriteCache); }
    }
    _AND_CATCH(Exception_Device)
    {
        DEVOBJ_FREE(_pFatDevObj->FAT_WriteCache);
        DEVOBJ_FREE(_pFatDevObj);
    }
    _AND_CATCH(Exception_File)
    {
        _pFatDevObj->FAT_Format = eFatFormatNone;
    }
    _END_CATCH

    /*
     *  Return the result
     */

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_UnmountVolume
 *
 *      Unmounts a mounted volume.
 *
 *  Parameters:
 *      pDevObj		- Pointer to the device object
 *
 *  Returns:
 *      Only returns an error if the device is not currently mounted or
 *      a Cache write-error occurs.
 *
 *  Notes:
 *      Supports FAT12, FAT16, and FAT32 initialization.
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_UnmountVolume( PDEVICE_OBJ pDevObj )
{
    DEV_IOPACKET _iop;

    /*
     *  Debug
     */

    DEVOBJ_ASSERT( pDevObj != 0 );

    /*
     *  OK, are we already mounted
     */

    if ( !Fsd_IsMounted(pDevObj) )
    {
        return FSD_IOSTATUS_NOT_MOUNTED;
    }

    /*
     *  Has device been Formatted?
     */

    if ( Fsd_IsFormatted(pDevObj) )
    {
        PFAT_DEVOBJ _pFatDevObj = FAT_DEVOBJ_EXT(pDevObj);

        DEVOBJ_ASSERT( _pFatDevObj != 0 );

        /*
         *  Update CACHE
         */

        if ( _DEV_IOSTATUS_FAILED( 
                Fat_WriteSector( 
                    pDevObj, 
                    _pFatDevObj->FAT_WriteCache, 
                    _pFatDevObj->FAT_WriteCacheBlock ) )
        )
        {
            return FSD_IOSTATUS_WRITE_FAULT;
        }

        /*
         *  Clear Flags
         */

        DEVOBJ_DESTROY_CRITICAL_SECTION(_pFatDevObj->FAT_DirectoryMutex);
        DEVOBJ_DESTROY_CRITICAL_SECTION(_pFatDevObj->FAT_CriticalSection);

        /*
         *  FREE UP Device Objects
         */

        DEVOBJ_FREE(_pFatDevObj->FAT_WriteCache);
        DEVOBJ_FREE(_pFatDevObj);
    }

    /*
     *  Get the statistics of the device the FAT Volume is binded to.
     */

    _iop.pDevice = Device_GetBindDev(pDevObj);
    _iop.nIoOperation = DEVICE_IO_CLOSE;

    /*
     *  Is the Device Online?
     */

    IO_DISPATCH(&_iop);

    /*
     *  Disable and return
     */

    Device_Disable( 
        pDevObj, 
        Device_Online | Device_Initialized | FatDevice_CacheChange
    );

    return FSD_IOSTATUS_SUCCESS;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_FormatVolume
 *
 *      Formats a Volume on a given Mounted Fat (must be mounted), which
 *      means a device is binded to the FAT object.
 *
 *  Parameters:
 *      pDevObj     - The Device Object for the Device to FORMAT
 *      strName     - String name assigned to the VOLUME
 *
 *
 *  Returns:
 *      Nothing
 *
 *  Notes:
 *      Supports FAT12 and FAT16initialization. FAT32 is not supported at
 *      this time due to the limitations in part sizes being used.
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_FormatVolume(
    PDEVICE_OBJ pDevObj,
    DEV_STRING strName
)
{
    DEV_IOSTATUS _nIoStatus;

    PFAT_BOOTSECTOR _pFatBoot;
    PFAT_DEVOBJ _pFatDev;
    DEV_USTRING _pCluster;

    /*
     *  Setup
     */

    DEVOBJ_ASSERT( pDevObj != 0 );
    DEVOBJ_ASSERT( strName != 0 );

    _pFatDev = FAT_DEVOBJ_EXT(pDevObj);
    DEVOBJ_ASSERT( _pFatDev != 0 );

    _pFatBoot = FAT_BOOTSECTOR(pDevObj);

    /*
     *  Is the DEVICE ONLINE?
     */

    if ( !Fsd_IsMounted(pDevObj) )
    {
        return FSD_IOSTATUS_NOT_MOUNTED;
    }

    /*
     *  Start the Format
     *
     *      NOTE: Device is online if a successful read was performed, which
     *      means the first N sectors are cached in the FAT Cache, where N
     *      is the NUMBER of SECTORS per DEVICE BLOCK.
     */

    _TRY
    {
        struct _DskSizToSecPerClus_s*   _pFormatEntry;

        /*
         *  Temps used to expedite calculations
         */

        register DEV_ULONG _nTmpVal1;
        register DEV_ULONG _nTmpVal2;

        /*
         *  The Sector Size and Total Sectors were set or should have been
         *  setup during Mounting, therefore no need to read Device Stats
         *  and recalculate these.
         *
         *      _nTmpVal1 is used to adjust the tables above in case a 
         *      512 Sector is not used.
         */

        _pFatBoot->BPB_NumFATs     = 1;
        _pFatBoot->BPB_RsvdSecCnt  = 1;

        _nTmpVal1 = (_pFatBoot->BPB_BytesPerSec / eSectorSize512) - 1;

        /*
         *  Cluster Size is determined by the Blocksize
         *
         *      If the BLOCK size on the target device is equal to or smaller
         *      than the
         */

#ifdef _FILESYSTEM_FAT12_ONLY
        DEVOBJ_ASSERT(
            _pFatBoot->BPB_TotSec32 <=
                (s_DskTableFAT12[DSKTABLEFAT12_LEN-1].nDevSize >> _nTmpVal1)
        );

        _pFatDev->FAT_Format = eFatFormat12;
        _pFormatEntry = s_DskTableFAT12;
        _pFatDev->FAT_Eof = CLUSTERSTATE_FAT12(eClusterEOF);

#else
    #ifdef _FILESYSTEM_FAT16_ONLY
        DEVOBJ_ASSERT(
            _pFatBoot->BPB_TotSec32 > 
                (s_DskTableFAT16[0].nDevSize >> _nTmpVal1)
        );

        _pFatDev->FAT_Format = eFatFormat16;
        _pFormatEntry = s_DskTableFAT16;
        _pFatDev->FAT_Eof = CLUSTERSTATE_FAT16(eClusterEOF);
    #else
        if ( _pFatBoot->BPB_TotSec32 <= s_DskTableFAT16[0].nDevSize )
        {
            _pFatDev->FAT_Format = eFatFormat12;
            _pFormatEntry = s_DskTableFAT12;
            _pFatDev->FAT_Eof = CLUSTERSTATE_FAT12(eClusterEOF);
        }
        else
        {
            _pFatDev->FAT_Format = eFatFormat16;
            _pFormatEntry = s_DskTableFAT16;
            _pFatDev->FAT_Eof = CLUSTERSTATE_FAT16(eClusterEOF);
        }
    #endif
#endif

        /*
         *  Find the entry 
         *
         *  The tables are based on 512 byte sectors so adjust the size
         *
         *      For instance for devices supporting 1024 block sizes,
         *      translates into 1K Sector Size, then the device size needs
         *      be divided by 2 since there are only half as many 1024
         *      sectors for the same calculation.
         */

        while ( _pFatBoot->BPB_TotSec32 > 
            ( _pFormatEntry->nDevSize >> _nTmpVal1 ) )
        {
            _pFormatEntry++;
        }

        /*
         *  Copy the Information from table
         */

        _pFatBoot->BPB_RootEntCnt = _pFormatEntry->nRootEntCnt;
        _pFatBoot->BPB_SecPerClus = _pFormatEntry->nSecPerClus >> _nTmpVal1;
        if ( _pFatBoot->BPB_SecPerClus == 0 )
        {
            _pFatBoot->BPB_SecPerClus = 1;
        }

        /*
         *  Calculate the number of sectors required by the Root Directory
         */

        _pFatDev->FAT_RootDirSectors =
                (( _pFatBoot->BPB_RootEntCnt * 32 ) +
                ( _pFatBoot->BPB_BytesPerSec - 1 )) /
                _pFatBoot->BPB_BytesPerSec;

        _nTmpVal1 = _pFatBoot->BPB_TotSec32 -
            ( _pFatBoot->BPB_RsvdSecCnt + _pFatDev->FAT_RootDirSectors );
        _nTmpVal2 =
            ( 256 * _pFatBoot->BPB_SecPerClus ) + _pFatBoot->BPB_NumFATs;

        /*
         *  Calculate the number of Sectors occupied by the FAT (FAT12
         *  defaults algorithmically to the same as FAT16, although an extra
         *  unused Sector may result).
         */

        _pFatBoot->BPB_FATSz16 =
            (DEV_UINT16)((_nTmpVal1+(_nTmpVal2-1))/_nTmpVal2);

        _pFatBoot->BPB_Media = eMediaFixed;

        /*
         *  NOT USED: For now this driver does not work with devices that
         *  have Track/Heads
         */

        _pFatBoot->BPB_SecPerTrk = 0;
        _pFatBoot->BPB_NumHeads = 0;
        _pFatBoot->BPB_HiddSec = 0;

        /*
         *  Calculate the Root Directory Sector
         */

        _pFatDev->FAT_FirstRootDirSector =
            _pFatBoot->BPB_RsvdSecCnt +
            (_pFatBoot->BPB_NumFATs * _pFatBoot->BPB_FATSz16 );

        /*
         *  Calculate the number of Data Clusters (remember, no FAT32 support
         *  yet)
         */

        _pFatDev->FAT_DataClusters =
            _pFatBoot->BPB_TotSec32 - FAT_FIRSTDATASECTOR(_pFatDev);

        _pFatDev->FAT_DataClusters /= _pFatBoot->BPB_SecPerClus;
        _pFatDev->FAT_FreeClusters = _pFatDev->FAT_DataClusters;
        _pFatDev->FAT_AvailClusters = _pFatDev->FAT_DataClusters;

        /*
         *  OK Finish Formatting the Drive
         */

        /*
         *  Finish initialized FAT Data Structure
         *
         *      1) Write to the FAT Sector (remember signature)
         *      2) Create the FAT, both copies
         *      3) Initialize Root Dir Entry
         */

        DEVOBJ_MEMCPY(
            _pFatBoot->BS_OEMName,
            s_szOEMName,
            8
        );
        DEVOBJ_MEMCPY(
            _pFatBoot->Ext._Fat16.BS_FilSysType,
            s_szFileSysName[_pFatDev->FAT_Format],
            8
        );
        DEVOBJ_MEMSET( _pFatBoot->BS_jmpBoot, 0, 3 );

        /*
         *  Volume Identification (Volume ID is not used)
         */

        _pFatBoot->Ext._Fat16.BS_DrvNum = 0x80;
        _pFatBoot->Ext._Fat16.BS_Reserved1 = 0;
        _pFatBoot->Ext._Fat16.BS_BootSig = 0x29;
        DEVOBJ_STRNCPY(
            (char *) _pFatBoot->Ext._Fat16.BS_VolLab,
            strName,
            DIRENTRY_FULLNAMELEN
        );

        /*
         *  THE BOOT Sector IS NOT Written until the VERY END, since all other 
         *  parts of initialization must complete successfully before hand.
         */

        /*
         *  OK, clear the Allocation Table and the ROOT Directory
         *
         *      The loop progresses backwards since all these sectors are
         *      cleared with the exception of the first sector which the
         *      first two cluster entries are special.
         */

        _pCluster = DEVOBJ_MALLOC( FAT_BYTESPERCLUSTER(_pFatDev) );

        /*
         *  Get and initialize a buffer (don't use FAT Cache as it is
         *  will be used to validate clusters, just in case some bad
         *  ones are found.
         */

        if ( _pCluster == 0 )
        {
            _THROW(Exception_Memory);
        }
        DEVOBJ_MEMSET(
            _pCluster,
            0x00,
            FAT_BYTESPERCLUSTER(_pFatDev)
        );

        /*
         *  Clean out the ROOT Directory FIRST. An WRITE failure on the ROOT
         *  for FAT12 and FAT16 is not recoverable and shall result in 
         */

        for ( _nTmpVal1 = _pFatDev->FAT_FirstRootDirSector;
             _nTmpVal1 < (DEV_ULONG)FAT_FIRSTDATASECTOR(_pFatDev);
             _nTmpVal1++ )
        {
            _nIoStatus = Fat_WriteSector( pDevObj, _pCluster, _nTmpVal1 );

            /*
             *  IF a failure occurs, the ROOT has a few defenses in that
             *  even with BAD Sector writes, it can still be used to some
             *  degree as LONG as it's not the first Sector. This will limit
             *  however the number of files that can be created in the ROOT.
             */

            if ( _DEV_IOSTATUS_FAILED(_nIoStatus) && 
                    (_DEV_IOSTATUS_CODE(_nIoStatus) != _DEV_IOSTATUS_RETRY) )
            {
                if ( _nTmpVal1 == _pFatDev->FAT_FirstRootDirSector )
                {
                    _THROW(Exception_Format);
                }
            }
        }

        _pFatDev->FAT_WriteCacheBlock = 0;

        /*
         *  Now the File Allocation Table (the FAT)
         */

        for ( _nTmpVal1 = _pFatDev->FAT_DataClusters + 1; _nTmpVal1 > 1; )
        {
            /*
             *  Test WRITE the Cluster
             */

            _nIoStatus = Fat_WriteCluster( pDevObj, _pCluster, _nTmpVal1 );

            /* 
             *  Error? Test for Wear Level errors are done in the call to
             *  WriteCluster.
             */

            if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
            {
                _nTmpVal2 = eClusterBad;
                _pFatDev->FAT_FreeClusters--;
                _pFatDev->FAT_AvailClusters--;
            }

            /*
             *  Set the CLUSTER as FREE, a Reset of the part will occur
             *  once the formatting is complete
             */

            else
            {
                _nTmpVal2 = eClusterFree;
                _pFatDev->FAT_FirstFreeCluster = _nTmpVal1;
            }

            _nIoStatus = Fat_SetClusterEntry( pDevObj, _nTmpVal1, _nTmpVal2 );

            /*
             *  Any FAILURES to update the FAT are critical and thus cause
             *  a format ERROR
             */

            if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
            {
                _THROW(Exception_Format);
            } 

            /*
             * Descend down to previous cluster
             */

            _nTmpVal1--;
        }

        /*
         *  The FIRST Two are reserved Clusters. This driver currently does
         *  not support the Dirty Shutdown bits
         *
         *      It is assumed for this driver that the MEDIA is fixed and
         *      therefore uses the BPB_Media value of 0xF8.
         *
         *      The second reserved byte is always EOC on FORMAT and has an
         *      optional usage for FAT16 when the drive is mounted and
         *      unmounted (refer to Microsoft documentation on FAT32)
         */

        Fat_SetClusterEntry( pDevObj, 0, (0xFF00 | _pFatBoot->BPB_Media) );
        Fat_SetClusterEntry( pDevObj, 1, eClusterEOF );

        /*
         *  COMMIT the SECTOR
         */

        _nIoStatus = 
            Fat_WriteSector(
                pDevObj,
                _pFatDev->FAT_WriteCache,
                _pFatDev->FAT_WriteCacheBlock
            );
        if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
        {
            _THROW(Exception_Format);
        } 

        /*
         *  OK, FINALLY to finish, The BOOT Sector must be written
         */

        Fat_BootPack( _pFatBoot, _pCluster );
        _BIGENDIANTOFAT(_pCluster);

        /*
         *  BOOT Signature
         */

        _pCluster[510] = 0x55;
        _pCluster[511] = 0xAA;

        /*
         *  Write the BOOT Sector (IF A FAILURE to write the BOOT Sector
         *  Occurs, then the DEVICE CANNOT BE FORMATTED)...this is a critical
         *  error.
         */

        _nIoStatus = Fat_WriteSector( pDevObj, _pCluster, 0 );
        if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
        {
            /* 
             *  Wear level exceptions don't count as a Critical Failure
             */

            if ( _DEV_IOSTATUS_CODE(_nIoStatus) != _DEV_IOSTATUS_RETRY )
            {
                _THROW(Exception_Format);
            }
        }

        DEVOBJ_FREE( _pCluster );

        /*
         *  OK, force the FIRST Entries
         */

        _pFatDev->FAT_ReadCacheBlock = 0;


        /*
         *  Device is successfully MOUNTED and NOW FORMATTED
         */

        Device_Enable(pDevObj, Device_Initialized);
    }

    /*
     *  Exceptions
     */

    _CATCH(Exception_Memory)
    {
        _nIoStatus = FSD_IOSTATUS_OUT_OF_MEMORY;
    }
    _AND_CATCH(Exception_Format)
    {
        DEVOBJ_FREE(_pCluster);
    }
    _END_CATCH

    /*
     *  Finished
     */

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_VolumeStat
 *
 *      Returns information about the FAT File System (Volume). Typically a
 *      more sophisticated file system would be used, that would center
 *      around a file superblock, as in Unix.
 *
 *  Parameters:
 *      pDevObj      - The FAT Object
 *
 *  Returns:
 *      If the drive is not formatted or mounted, then an error is returned
 *      otherwise success.
 *
 *  Notes:
 *      At this time only FAT12 and FAT16 are supported.
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_VolumeStat(
    PDEVICE_OBJ pDevObj,
    PDEVSTATS pStats
)
{
    PFAT_DEVOBJ _pFatDev;

    /*
     *  Debug
     */

    DEVOBJ_ASSERT( pDevObj != 0 );
    DEVOBJ_ASSERT( pStats != 0 );

    /*
     *  Is the volume formatted?
     */

    if ( !Fsd_IsMounted(pDevObj) )
    {
        return FSD_IOSTATUS_NOT_MOUNTED;
    }

    else if ( !Fsd_IsFormatted(pDevObj) )
    {
        return FSD_IOSTATUS_NOT_FORMATTED;
    }

    _pFatDev = FAT_DEVOBJ_EXT(pDevObj);
    DEVOBJ_ASSERT( _pFatDev != 0 );

    /*
     *  Volume Type
     */

    pStats->blkStats.nType = _pFatDev->FAT_Format;

    /*
     *  Calculation of the Block Size
     */

    pStats->blkStats.nBlockSiz =
        _pFatDev->FAT_BootSector.BPB_BytesPerSec *
        _pFatDev->FAT_BootSector.BPB_SecPerClus;

    /*
     *  Stats on the number of total and free blocks left (Free Blocks are
     *  those marked as Available and not necessarily free if Level Wearing
     *  is enabled.
     */

    pStats->blkStats.nTotBlocks = _pFatDev->FAT_DataClusters;
    pStats->blkStats.nFreeBlocks = _pFatDev->FAT_AvailClusters;

    return FSD_IOSTATUS_SUCCESS;
}

/*
 *  End of fat_vol.c
 */

