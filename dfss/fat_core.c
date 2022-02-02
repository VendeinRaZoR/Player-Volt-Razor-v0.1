
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
 *  fat_core.c
 *
 *      Core Support Methods for FAT.
 *
 *  These methods manage the DIRECTORY Scaling, as well as FAT updates.
 *  THE FAT is protected by a CRITICAL SECTION as are any access to modifying
 *  directory entries.
 *
 */

#define _FAT_INCLUDE_CORE
#include "include/fat.h"  

/*
 *  LOCAL Exceptions
 */

BEGIN_EXCEPTION_TABLE(Exception_Fat)

    Exception_Fat_Full,
    Exception_Fat_EndOfDirectory

END_EXCEPTION_TABLE(Exception_Fat)

/*
 *  Special Data Structures (no global usage as these are specific to Directory)
 */

#define _DIRLIST_DECLARE(name,siz) \
    struct _s_##name { \
        struct _s_##name * next; \
        struct _s_##name * prev; \
        char data[siz]; \
    } * name = 0

#define _DIRLIST_COPY(name,newname) \
    struct _s_##name * newname = name

#define _DIRLIST_CREATE(name,copy) \
    name = (struct _s_##name *)DEVOBJ_MALLOC( sizeof(struct _s_##name) ); \
    if ( name != 0 ) { \
        DEVOBJ_MEMCPY( name->data, &(copy), sizeof(copy) ); \
        name->prev = name->next = 0; \
    }

#define _DIRLIST_ISVALID(name) \
    ( name != 0 )

#define _DIRLIST_DESTROY(name) \
    while ( name != 0 ) { \
        struct _s_##name * _next; \
        _next = name->next; \
        DEVOBJ_FREE(name); \
        name = _next; \
    }

#define _DIRLIST_PUSH(name,copy) \
    { \
        struct _s_##name * _temp = \
            (struct _s_##name *)DEVOBJ_MALLOC(sizeof(struct _s_##name) ); \
        if ( _temp != 0 ) \
        { \
            DEVOBJ_MEMCPY( _temp->data, &(copy), sizeof(copy) ); \
            _temp->next = name; \
            _temp->prev = 0; \
            name->prev = _temp; \
            name = _temp; \
        } \
    }

#define _DIRLIST_POP(name,copy) \
    { \
        struct _s_##name * _temp = name->next; \
        DEVOBJ_MEMCPY( &(copy), name->data, sizeof(copy) ); \
        DEVOBJ_FREE(name); \
        name = _temp; \
    }

/*
 *  This is a list of illegal characters in a Filename for FAT.
 */

#define OFFSET_DIR_NAME             0
#define OFFSET_DIR_ATTR             DIRENTRY_FULLNAMELEN
#define OFFSET_DIR_NTRES            DIRENTRY_FULLNAMELEN+1
#define OFFSET_DIR_CRTTIMETENTH     DIRENTRY_FULLNAMELEN+2
#define OFFSET_DIR_CRTTIME          DIRENTRY_FULLNAMELEN+3
#define OFFSET_DIR_CRTDATE          DIRENTRY_FULLNAMELEN+5
#define OFFSET_DIR_LSTACCDATE       DIRENTRY_FULLNAMELEN+7
#define OFFSET_DIR_FSTCLUSHI        DIRENTRY_FULLNAMELEN+9
#define OFFSET_DIR_WRTTIME          DIRENTRY_FULLNAMELEN+11
#define OFFSET_DIR_WRTDATE          DIRENTRY_FULLNAMELEN+13
#define OFFSET_DIR_FSTCLUSLO        DIRENTRY_FULLNAMELEN+15
#define OFFSET_DIR_FILESIZE         DIRENTRY_FULLNAMELEN+17

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
 */

#if defined( _NO_COMPILER_STRUCT_PACKING )

static
void Fat_DirEntryUnpack(
    PFAT_DIRENTRY pFatDirEntry,
    DEV_USTRING pFatDirEntryBuf
)
{
    DEVOBJ_MEMCPY(
        pFatDirEntry->DIR_Name,
        pFatDirEntryBuf,
        DIRENTRY_FULLNAMELEN
    );

    pFatDirEntry->DIR_Attr =
        *(DEV_UINT8*)( pFatDirEntryBuf + OFFSET_DIR_ATTR );
    pFatDirEntry->DIR_NTRes =
        *(DEV_UINT8*)( pFatDirEntryBuf + OFFSET_DIR_NTRES );
    pFatDirEntry->DIR_CrtTimeTenth =
        *(DEV_UINT8*)( pFatDirEntryBuf + OFFSET_DIR_CRTTIMETENTH );
    pFatDirEntry->DIR_CrtTime =
        *(DEV_UINT16*)( pFatDirEntryBuf + OFFSET_DIR_CRTTIME );
    pFatDirEntry->DIR_CrtDate =
        *(DEV_UINT16*)( pFatDirEntryBuf + OFFSET_DIR_CRTDATE );
    pFatDirEntry->DIR_LstAccDate =
        *(DEV_UINT16*)( pFatDirEntryBuf + OFFSET_DIR_LSTACCDATE );
    pFatDirEntry->DIR_FstClusHI =
        *(DEV_UINT16*)( pFatDirEntryBuf + OFFSET_DIR_FSTCLUSHI );
    pFatDirEntry->DIR_WrtTime =
        *(DEV_UINT16*)( pFatDirEntryBuf + OFFSET_DIR_WRTTIME );
    pFatDirEntry->DIR_WrtDate =
        *(DEV_UINT16*)( pFatDirEntryBuf + OFFSET_DIR_WRTDATE );
    pFatDirEntry->DIR_FstClusLO =
        *(DEV_UINT16*)( pFatDirEntryBuf + OFFSET_DIR_FSTCLUSLO );
    pFatDirEntry->DIR_FileSize =
        ((DEV_UINT32)*(DEV_UINT16*)( pFatDirEntryBuf + OFFSET_DIR_FILESIZE ));
    pFatDirEntry->DIR_FileSize +=
        (((DEV_UINT32)(*(DEV_UINT16*)( pFatDirEntryBuf + OFFSET_DIR_FILESIZE + 2 )))<<16);
}

static
void Fat_DirEntryPack(
    PFAT_DIRENTRY pFatDirEntry,
    DEV_USTRING pFatDirEntryBuf
)
{
    DEVOBJ_MEMCPY(
        pFatDirEntryBuf,
        pFatDirEntry->DIR_Name,
        DIRENTRY_FULLNAMELEN
    );

    *( pFatDirEntryBuf + OFFSET_DIR_ATTR ) =
        pFatDirEntry->DIR_Attr;
    *( pFatDirEntryBuf + OFFSET_DIR_NTRES ) =
        pFatDirEntry->DIR_NTRes;
    *( pFatDirEntryBuf + OFFSET_DIR_CRTTIMETENTH ) =
        pFatDirEntry->DIR_CrtTimeTenth;

    DEVOBJ_MEMCPY(
        ( pFatDirEntryBuf + OFFSET_DIR_CRTTIME ),
        &( pFatDirEntry->DIR_CrtTime ), 2
    );
    DEVOBJ_MEMCPY(
        ( pFatDirEntryBuf + OFFSET_DIR_CRTDATE ),
        &( pFatDirEntry->DIR_CrtDate ), 2
    );
    DEVOBJ_MEMCPY(
        ( pFatDirEntryBuf + OFFSET_DIR_LSTACCDATE ),
        &( pFatDirEntry->DIR_LstAccDate ), 2
    );
    DEVOBJ_MEMCPY(
        ( pFatDirEntryBuf + OFFSET_DIR_FSTCLUSHI ),
        &( pFatDirEntry->DIR_FstClusHI ), 2
    );
    DEVOBJ_MEMCPY(
        ( pFatDirEntryBuf + OFFSET_DIR_WRTTIME ),
        &( pFatDirEntry->DIR_WrtTime ), 2
    );
    DEVOBJ_MEMCPY(
        ( pFatDirEntryBuf + OFFSET_DIR_WRTDATE ),
        &( pFatDirEntry->DIR_WrtDate ), 2
    );
    DEVOBJ_MEMCPY(
        ( pFatDirEntryBuf + OFFSET_DIR_FSTCLUSLO ),
        &( pFatDirEntry->DIR_FstClusLO ), 2
    );
    DEVOBJ_MEMCPY(
        ( pFatDirEntryBuf + OFFSET_DIR_FILESIZE ),
        &( pFatDirEntry->DIR_FileSize ) , 4
    );
}

#else

#define Fat_DirPack(pFatDirEntry,pFatDirEntryBuf) \
    DEVOBJ_MEMCPY( pFatDirEntryBuf, pFatDirEntry, sizeof( FAT_DIRENTRY ) )

#define Fat_DirEntryUnpack(pFatDirEntry,pFatDirEntryBuf) \
    DEVOBJ_MEMCPY( pFatDirEntry, pFatDirEntryBuf, sizeof( FAT_DIRENTRY ) )

#endif

/* --------------------------------------------------------------------------
 *
 *  FAT METHODS
 *
 * --------------------------------------------------------------------------
 */

/* --------------------------------------------------------------------------
 *  Private Methods
 * --------------------------------------------------------------------------
 */

/* --------------------------------------------------------------------------
 *
 *  Fat_PackRootDirectory
 *
 *      Same as Fat_PackDirectory, except the ROOT is traversed.
 *
 *  Parameters:
 *      pDevObj         - The Device Object
 *      nSector         - Sector in the Table being Cached
 *
 *  Returns:
 *      Result of the pack
 *
 *  Notes:
 *      Must be called for Directory Entries
 *
 *      ROOT Directory Failures are critical with no recovery.
 * --------------------------------------------------------------------------
 */

static
DEV_IOSTATUS Fat_PackRootDirectory(
    PFILE_OBJ pFileObj,
    PFAT_DEVOBJ pFatDevObj
)
{
    DEV_IOSTATUS _nIoStatus;
    PFAT_FILEOBJ _pFatFileObj = FAT_FILEOBJ_EXT(pFileObj);

    do
    {
        while ( _pFatFileObj->nDirOffset > 0 )
        {
            _pFatFileObj->nDirOffset -= sizeof(FAT_DIRENTRY);
            if ( pFileObj->pBuffer[_pFatFileObj->nDirOffset] ==
                    (DEV_UCHAR)DIRENTRY_FREE )
            {
                pFileObj->pBuffer[_pFatFileObj->nDirOffset] = DIRENTRY_END;
            }

            /*
             *  Otherwise finished
             */

            else
            {
                break;
            }
        }

        /*
         *  Update the Sector
         */

        _nIoStatus =
            Fat_WriteSector(
                pFileObj->pDeviceObj,
                pFileObj->pBuffer,
                _pFatFileObj->nDirSector
            );

        /*
         *  Critical Error?
         */

        if ( _DEV_IOSTATUS_FAILED(_nIoStatus) ) 
        {
            if ( _DEV_IOSTATUS_CODE(_nIoStatus) != _DEV_IOSTATUS_RETRY )
            {
                break;
            }

            _nIoStatus = FSD_IOSTATUS_SUCCESS;
        }

        /*
         *  More of the Sectors to go?
         */

        if ( _pFatFileObj->nDirOffset == 0 )
        {
            /*
             *  Are we at the beginning???
             */

            if ( --_pFatFileObj->nDirSector <
                    pFatDevObj->FAT_FirstRootDirSector )
            {
                break;
            }

            /*
             *  Read the next ROOT Sector (ignore the status)
             */

            Fat_ReadSector(
                pFileObj->pDeviceObj,
                pFileObj->pBuffer,
                _pFatFileObj->nDirSector
            );
            _pFatFileObj->nDirOffset =
                pFatDevObj->FAT_BootSector.BPB_BytesPerSec;
        }
    }
    while (1);

    /*
     *  Return the result
     */

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_PackDirectory
 *
 *      This is called, when the last entry of a directory is removed. The
 *      problem is that the cluster chain must be traversed and compressed
 *      for any directory entries that are tagged as FREE. In another words
 *      any entries previous and continguous to the last entry being removed
 *      are also set to End of Directory if they are currently marked as
 *      free. This is performed until a valid entry is found.
 *
 *  Parameters:
 *      pDevObj         - The Device Object
 *      nSector         - Sector in the Table being Cached
 *
 *  Returns:
 *      Result of the pack.
 *
 *  Notes:
 *      This is only executed for subdirectories, not the ROOT (see previous
 *      function)
 *
 * --------------------------------------------------------------------------
 */

static
DEV_IOSTATUS Fat_PackDirectory(
    PFILE_OBJ pFileObj,
    PFAT_DEVOBJ pFatDevObj
)
{
    PFAT_FILEOBJ _pFatFileObj = FAT_FILEOBJ_EXT(pFileObj);
    DEV_UINT32 _nDirCluster;

    DEV_IOSTATUS _nIoStatus;

    /*
     *  A cluster chain is needed - for the ROOT the space is
     *  contiguous. Therefore a different approach is implemented.
     */

    _DIRLIST_DECLARE( _ClusterChain, sizeof(DEV_UINT32) );

    _TRY
    {
        /*
         *  Build the Cluster Chain, starting with the beginning of the
         *  directory chain. This is done so that the cluster chain can
         *  be traversed in the reverse direction.
         *
         *  The chain is built starting with the first cluster in the
         *  directory chain, which has the "." and ".." entry.
         */

        _nDirCluster = _pFatFileObj->theEntry.DIR_FstClusLO;
        _DIRLIST_CREATE( _ClusterChain, _nDirCluster );

        while ( _nDirCluster != _pFatFileObj->nCluster )
        {
            _nIoStatus =
                Fat_GetClusterEntry(
                    pFileObj->pDeviceObj,
                    _nDirCluster,
                    &_nDirCluster
                );
            if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
            {
                _THROW(Exception_File);
            }

            _DIRLIST_PUSH( _ClusterChain, _nDirCluster );
        }

        _DIRLIST_POP( _ClusterChain, _pFatFileObj->nCluster );

        /*
         *  Set the assignments for CLUSTER, Sector Offset in Cluster and Offset
         *  in Sector
         */

        /*
         *  Traverse the LIST in REVERSE
         */

        do
        {
            /*
             *  OK, work through the Sector
             */

            while ( _pFatFileObj->nOffset > 0 )
            {
                _pFatFileObj->nOffset -= sizeof(FAT_DIRENTRY);
                if ( pFileObj->pBuffer[_pFatFileObj->nOffset] ==
                        (DEV_UCHAR)DIRENTRY_FREE )
                {
                    pFileObj->pBuffer[_pFatFileObj->nOffset] = DIRENTRY_END;
                }

                /*
                 *  Otherwise finished
                 */

                else
                {
                    break;
                }
            }

            /*
             *  Update the Sector 
             */

            _nIoStatus =
                Fat_WriteSector(
                    pFileObj->pDeviceObj,
                    pFileObj->pBuffer,
                    _pFatFileObj->nDirSector
                );

            /*
             *  Critical Error
             */

            if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
            {
                _THROW(Exception_File);
            }

            /*
             *  Sector Emptied?
             */

            if ( _pFatFileObj->nOffset == 0 )
            {
                _pFatFileObj->nOffset = 
                    pFatDevObj->FAT_BootSector.BPB_BytesPerSec;
                if ( _pFatFileObj->nSector == 0 )
                {
                    _DIRLIST_POP( _ClusterChain, _pFatFileObj->nCluster );
                    _pFatFileObj->nSector = 
                        pFatDevObj->FAT_BootSector.BPB_SecPerClus;
                }

                _pFatFileObj->nSector--;
                _pFatFileObj->nDirSector = 
                    FAT_FIRSTSECTOROFCLUSTER(
                        pFatDevObj,
                        _pFatFileObj->nCluster
                    ) + _pFatFileObj->nSector;

                /*
                 *  Get the previous Sector
                 */

                Fat_ReadSector(
                    pFileObj->pDeviceObj,
                    pFileObj->pBuffer,
                    _pFatFileObj->nDirSector
                );
            }

            /*
             *  Finished...
             */

            else
            {
                break;
            }
        }
        while (1);
    }
    _CATCH(Exception_File)
    {
        /*
         *  FAILURE
         */
    }
    _END_CATCH

    /*
     *  Clean up the list
     */

    _DIRLIST_DESTROY( _ClusterChain );

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_CacheTableSector
 *
 *      Cache's a Sector in the FAT.
 *
 *  Parameters:
 *      pDevObj         - The Device Object
 *      nSector         - Sector in the Table being Cached
 *
 *  Returns:
 *      IF A FAILURE to WRITE occurs, then this is CRITICAL in that the 
 *      FAT Table is corrupt and therefore not usuable (invalid file 
 *      system).
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

static
DEV_IOSTATUS Fat_CacheTableSector(
    PDEVICE_OBJ pDevObj,
    DEV_ULONG nSector,
    DEV_USHORT nOffset
)
{
    DEV_IOSTATUS _nIoStatus;
    PFAT_DEVOBJ _pFatDev = FAT_DEVOBJ_EXT(pDevObj);

    /*
     *  Sector already Cached?
     */

    if ( _pFatDev->FAT_WriteCacheBlock == nSector )
    {
        return FSD_IOSTATUS_SUCCESS;
    }

    /*
     *  Cache a new Sector
     */

    _TRY
    {
        /*
         *  Swap FAT Sectors
         *
         *      First Write the current Sector, if it has been updated
         */

        if ( FatDevice_IsCacheChanged(pDevObj) )
        {
            _nIoStatus = 
                Fat_WriteSector(
                    pDevObj,
                    _pFatDev->FAT_WriteCache,
                    _pFatDev->FAT_WriteCacheBlock
                );

            /*
             *  Problem on WRITE?
             */

            if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
            {
                /*
                 *  IGNORE Wear Leveling
                 */

                if ( _DEV_IOSTATUS_CODE(_nIoStatus) != _DEV_IOSTATUS_RETRY )
                {
                    _THROW(Exception_File);
                }
            }
        }

        /*
         *  Read the new FAT Sector
         */

        _pFatDev->FAT_WriteCacheBlock = (DEV_USHORT)nSector;        
        _nIoStatus = 
            Fat_ReadSector(
                pDevObj,
                _pFatDev->FAT_WriteCache,
                _pFatDev->FAT_WriteCacheBlock
            );

        Device_Disable(pDevObj,FatDevice_CacheChange);
    }
    _CATCH(Exception_File)
    {
        /*
         *  Critical Error in which case the FILE SYSTEM is corrupt.
         */
    }
    _END_CATCH

    /*
     *  Return the result
     */

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_GetClusterIndex
 *
 *      Gets the Cluster Entry in the File Allocation Table (FAT)
 *
 *  Parameters:
 *      pDevObj         - The Device Object
 *      nClusterIdx     - The Index for the Cluster
 *      pClusterEntry   - Buffer (small one) that
 *
 *  Returns:
 *      Returns result of the
 *
 *  Notes:
 *      FAT12 -
 *
 *      For Even Indexes
 *
 *      +-------+-------+-------+-------+-------+-------+-------+-------+
 *      |xxx|xxx|   |xxx|   |   |   |   |   |   |   |   |   |   |   |   |
 *      +-------+-------+-------+-------+-------+-------+-------+-------+
 *          0       1       2       3       4       5       6       7
 *
 *
 *      For Odd Indexes
 *
 *      +-------+-------+-------+-------+-------+-------+-------+-------+
 *      |   |   |xxx|   |xxx|xxx|   |   |   |   |   |   |   |   |   |   |
 *      +-------+-------+-------+-------+-------+-------+-------+-------+
 *          0       1       2       3       4       5       6       7
 *
 *      Occupies on a 1.5 Byte Boundary, but since the formatting is Little
 *      Endian, it is not contiguous as shown for Cluster Entry marked by
 *      "x" above. For Little Endian this is not a big TODO, but for
 *      BIG Endian, because there is a break a simple Little To Big
 *      conversion cannot be used.
 *
 *
 * --------------------------------------------------------------------------
 */

static
DEV_IOSTATUS Fat_GetClusterIndex(
    PDEVICE_OBJ pDevObj,
    DEV_UINT32 nClusterIdx,
    DEV_UINT32* pClusterEntry
)
{
    DEV_UINT32 _nFATSecNum;
    DEV_UINT32 _nFATOffset;
    PFAT_DEVOBJ _pFatDev = FAT_DEVOBJ_EXT(pDevObj);

    DEVOBJ_ASSERT( nClusterIdx >= 2 );

    /*
     *  Calculate Offset into the Table
     *
     *  Offset must be adjusted to compensate for the entry size
     *
     *      NOTE: FAT12 causes all kinds of interesting problems if
     *      the entry happens to cross over a SECTOR boundary.
     */

#ifndef _FILESYSTEM_FAT16_ONLY
  #ifndef _FILESYSTEM_FAT12_ONLY
    if ( _pFatDev->FAT_Format == eFatFormat12 )
  #endif
    {
        _nFATOffset = nClusterIdx + ( nClusterIdx / 2 );
    }
#endif

#ifndef _FILESYSTEM_FAT12_ONLY
  #ifndef _FILESYSTEM_FAT16_ONLY
        else
  #endif
    {
        _nFATOffset = nClusterIdx << 1;
    }
#endif

    /*
     *  Calculate the Sector Number and Offset in the table
     */

    _nFATSecNum = FAT_BOOTSECTOR(pDevObj)->BPB_RsvdSecCnt +
        ( _nFATOffset / FAT_BOOTSECTOR(pDevObj)->BPB_BytesPerSec );

    _nFATOffset =
        DEVOBJ_REM(_nFATOffset,FAT_BOOTSECTOR(pDevObj)->BPB_BytesPerSec);

    /*
     *  Is that FAT cluster cached.
     *
     *      This makes the operation faster when cached. And since this
     *      is a Get operation, even if it is not there is no since in
     *      reading in a new one sector, because that would require
     *      writing this one first.
     */

    /*
     *  Is the entry currently cached in this sector?
     */

    if ( _nFATSecNum != _pFatDev->FAT_ReadCacheBlock )
    {
        /*
         *  Is it cached on the WRITE side?
         */

        if ( _nFATSecNum == _pFatDev->FAT_WriteCacheBlock )
        {
            DEVOBJ_MEMCPY( 
                _pFatDev->FAT_ReadCache,
                _pFatDev->FAT_WriteCache,
                _pFatDev->FAT_BootSector.BPB_BytesPerSec
            );
        }

        /*
         *  Read from the device
         */

        else
        {
            Fat_ReadSector( 
                pDevObj, 
                _pFatDev->FAT_ReadCache, 
                _nFATSecNum 
            );
        }
    }

    /*
     *  Read the Entry (Handles both Little and Big Endian architectures)
     */

    /*
     *  Unfortunately FAT12 requires more processing. Because it does not
     *  end on a Byte Boundary and in very special cases can cross Sectors
     *  creating another problem in itself.
     */

#ifndef _FILESYSTEM_FAT16_ONLY
  #ifndef _FILESYSTEM_FAT12_ONLY
    if ( _pFatDev->FAT_Format == eFatFormat12 )
  #endif
    {
        *pClusterEntry = _pFatDev->FAT_ReadCache[_nFATOffset];
        if ( nClusterIdx & 0x0001 )
        {
            *pClusterEntry >>= 4;
        }

        /*
         *  Check for Sector Boundary (ADDED Overhead of course)
         */

        if ( ++_nFATOffset == _pFatDev->FAT_BootSector.BPB_BytesPerSec )
        {
            _nFATOffset = 0;

            /*
             *  Next Sector in the TABLE
             */

            Fat_ReadSector( 
                pDevObj, 
                _pFatDev->FAT_ReadCache, 
                ++_nFATSecNum 
            );
        }

        /*
         *  More masking is required unfortunately
         */

        if ( nClusterIdx & 0x0001 )
        {
            *pClusterEntry |= 
                (DEV_USHORT)_pFatDev->FAT_ReadCache[_nFATOffset] << 4;
        }
        else
        {
            *pClusterEntry |= 
                (DEV_USHORT)_pFatDev->FAT_ReadCache[_nFATOffset] << 8;
            *pClusterEntry &= 0x0FFF;
        }
    }
#endif

#ifndef _FILESYSTEM_FAT12_ONLY
  #ifndef _FILESYSTEM_FAT16_ONLY
    else if ( _pFatDev->FAT_Format == eFatFormat16 )
  #endif
    {
        *pClusterEntry = _pFatDev->FAT_ReadCache[_nFATOffset+1];
        *pClusterEntry <<= 8;
        *pClusterEntry |= _pFatDev->FAT_ReadCache[_nFATOffset];
    }
#endif
    
    _pFatDev->FAT_ReadCacheBlock = (DEV_USHORT)_nFATSecNum;

    return FSD_IOSTATUS_SUCCESS;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_SetClusterIndex
 *
 *      Gets or Sets the Cluster Entry in the File Allocation Table (FAT)
 *
 *  Parameters:
 *      pDevObj         - The device object
 *      nClusterIdx     - The Cluster Index   
 *      pClusterEntry   -
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

static
DEV_IOSTATUS Fat_SetClusterIndex(
    PDEVICE_OBJ pDevObj,
    DEV_UINT32 nClusterIdx,
    DEV_UINT32 nClusterEntry
)
{
    DEV_IOSTATUS _nIoStatus;
    DEV_UINT32 _nFATSecNum;
    DEV_UINT32 _nFATOffset;

    _TRY
    {
        PFAT_DEVOBJ _pFatDev = FAT_DEVOBJ_EXT(pDevObj);

        /*
         *  Calculate Offset into the Table
         *
         *  Offset must be adjust to compensate for the entry size
         */

#ifndef _FILESYSTEM_FAT16_ONLY
    #ifndef _FILESYSTEM_FAT12_ONLY
        if ( _pFatDev->FAT_Format == eFatFormat12 )
    #endif
        {
            _nFATOffset = nClusterIdx + ( nClusterIdx / 2 );
        }
#endif

#ifndef _FILESYSTEM_FAT12_ONLY
    #ifndef _FILESYSTEM_FAT16_ONLY
        else
    #endif
        {
            _nFATOffset = nClusterIdx << 1;
        }
#endif

        /*
         *  Calculate the Sector Number and Offset in the table
         */

        _nFATSecNum = _pFatDev->FAT_BootSector.BPB_RsvdSecCnt +
            ( _nFATOffset / _pFatDev->FAT_BootSector.BPB_BytesPerSec );

        _nFATOffset =
            DEVOBJ_REM(
                _nFATOffset,
                _pFatDev->FAT_BootSector.BPB_BytesPerSec
            );

        /*
         *  Is this FAT cluster cached????
         */

        _nIoStatus = 
            Fat_CacheTableSector( 
                pDevObj, 
                _nFATSecNum, 
                (DEV_USHORT)_nFATOffset 
            );
        if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
        {
            _THROW(Exception_File);
        }

        /*
         *  FAT16?
         */

#ifndef _FILESYSTEM_FAT12_ONLY
    #ifndef _FILESYSTEM_FAT16_ONLY
        if ( _pFatDev->FAT_Format == eFatFormat16 )
    #endif
        {
            _pFatDev->FAT_WriteCache[_nFATOffset] =
                (DEV_UINT8)nClusterEntry;
            _pFatDev->FAT_WriteCache[_nFATOffset+1] =
                (DEV_UINT8)( nClusterEntry >> 8 );

            /*
             *  Update the READ Cache, if pointing to same region
             */

            if ( _pFatDev->FAT_ReadCacheBlock == 
                _pFatDev->FAT_WriteCacheBlock )
            {
                _pFatDev->FAT_ReadCache[_nFATOffset] =
                    _pFatDev->FAT_WriteCache[_nFATOffset];
                _pFatDev->FAT_ReadCache[_nFATOffset+1] =
                    _pFatDev->FAT_WriteCache[_nFATOffset+1];

            }
        }
#endif

        /*
         *  FAT12 is a bit more complicated since it can cross Sector 
         *  Boundaries.
         */

#ifndef _FILESYSTEM_FAT16_ONLY
    #ifndef _FILESYSTEM_FAT12_ONLY
        else
    #endif
        {
            /*
             *  Odd Cluster?
             */

            if ( nClusterIdx & 0x0001 )
            {
                nClusterEntry <<= 4;
                _pFatDev->FAT_WriteCache[_nFATOffset] &= 0x0F;
            }

            /*
             *  Even Cluster
             */

            else
            {
                nClusterEntry &= 0x0FFF;
                _pFatDev->FAT_WriteCache[_nFATOffset] = 0x00;
            }

            /*
             *  STORE the first part
             */

            _pFatDev->FAT_WriteCache[_nFATOffset] |= (DEV_UINT8)nClusterEntry;
            if ( _pFatDev->FAT_ReadCacheBlock == 
                        _pFatDev->FAT_WriteCacheBlock )
            {
                _pFatDev->FAT_ReadCache[_nFATOffset] = 
                    _pFatDev->FAT_WriteCache[_nFATOffset];
            }

            /*
             *  Test for End of Sector (Potential BUG by the way...)
             *
             *      IF the second write fails...how to preserve the
             *      contents of the byte before.
             */

            if ( ++_nFATOffset == _pFatDev->FAT_BootSector.BPB_BytesPerSec )
            {
                Device_Enable(pDevObj,FatDevice_CacheChange);

                _nFATOffset = 0;
                _nIoStatus = 
                    Fat_CacheTableSector( 
                        pDevObj, 
                        ++_nFATSecNum, 
                        (DEV_USHORT)_nFATOffset 
                    );
                if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
                {
                    _THROW(Exception_File);
                }
            }

            /*
             *  For the next BYTE...Test for ODD/EVEN again
             */

            if ( nClusterIdx & 0x0001 )
            {
                _pFatDev->FAT_WriteCache[_nFATOffset] = 0x00;
            }

            /*
             *  Even Cluster
             */

            else
            {
                _pFatDev->FAT_WriteCache[_nFATOffset] &= 0xF0;
            }

            _pFatDev->FAT_WriteCache[_nFATOffset] |= 
                (DEV_UINT8)( nClusterEntry >> 8 );
            if ( _pFatDev->FAT_WriteCacheBlock ==
                        _pFatDev->FAT_ReadCacheBlock )
            {
                _pFatDev->FAT_ReadCache[_nFATOffset] = 
                    _pFatDev->FAT_WriteCache[_nFATOffset];
            }
        }
#endif

        /*
         *  Cache Was updated
         */

        Device_Enable(pDevObj,FatDevice_CacheChange);
    }
    _CATCH(Exception_File)
    {
        /*
         *  Currently THERE is no recovery mechanism on a failure that 
         *  involves the File Allocation Table. These errors are critical.
         */
    }
    _END_CATCH

    /*
     *  Return the result
     */

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_AllocClusterIndex
 *
 *      Allocates a FREE Cluster
 *
 *  Parameters:
 *      pDevObj         - The Device Object
 *      pnClusterIdx    - Pointer to the cluster index
 *
 *  Returns:
 *
 *
 *  Notes:
 *      If no Free Clusters exist, then the FAT is walked from the start to
 *      look for special set clusters (if wear leveling is enabled) and
 *      toggles them back to their free state (then it calls the device to
 *      reset it)
 *
 * --------------------------------------------------------------------------
 */

static
DEV_IOSTATUS Fat_AllocClusterIndex(
    PDEVICE_OBJ pDevObj,
    DEV_ULONG*  pnClusterIdx
)
{
    DEV_IOSTATUS _nIoStatus;
    DEV_UINT32 _nIdx;
    DEV_UINT32 _nCluster;

    PFAT_DEVOBJ _pFatDev = FAT_DEVOBJ_EXT(pDevObj);

    /*
     *  Any available clusters?
     */
    
    if ( _pFatDev->FAT_AvailClusters == 0 )
    {
        return FSD_IOSTATUS_SYSTEM_FULL;
    }

    _TRY
    {
        /*
         *  Clusters available, but are there any free?
         */

        if ( _pFatDev->FAT_FreeClusters == 0 )
        {
            DEV_UINT32 _nClusterCheck;
            DEV_IOPACKET _iop;

            /*
             *  If we enter here, then wear leveling has many of the clusters
             *  still in check and now they must be freed. 
             */

    #ifndef _FILESYSTEM_FAT16_ONLY
        #ifndef _FILESYSTEM_FAT12_ONLY
            if ( _pFatDev->FAT_Format == eFatFormat12 )
        #endif
            {
                _nClusterCheck = CLUSTERSTATE_FAT12(eClusterCheck);
            }
    #endif

    #ifndef _FILESYSTEM_FAT12_ONLY
        #ifndef _FILESYSTEM_FAT16_ONLY
            else
        #endif
            {
                _nClusterCheck = CLUSTERSTATE_FAT16(eClusterCheck);
            }
    #endif

            /*
             *  Walk the TABLE
             */

            for ( _nIdx = _pFatDev->FAT_DataClusters-1; _nIdx >= 2 ; _nIdx-- )
            {
                _nIoStatus = 
                    Fat_GetClusterIndex( pDevObj, _nIdx, &_nCluster );
                if ( _DEV_IOSTATUS_FAILED(_nIoStatus) && 
                    ( _DEV_IOSTATUS_CODE(_nIoStatus) != _DEV_IOSTATUS_RETRY ) )
                {
                    _THROW(Exception_File);
                }

                if ( _nCluster == _nClusterCheck )
                {
                    _nCluster = eClusterFree;
                    _nIoStatus = 
                        Fat_SetClusterIndex( pDevObj, _nIdx, _nCluster );

                    /*
                     *  Write FAILURE?
                     */

                    if ( _DEV_IOSTATUS_FAILED(_nIoStatus) && 
                    ( _DEV_IOSTATUS_CODE(_nIoStatus) != _DEV_IOSTATUS_RETRY ) )
                    {
                        _THROW(Exception_File);
                    }

                    /*
                     *  Update FREE Cluster List
                     */

                    _pFatDev->FAT_FreeClusters++;
                    _pFatDev->FAT_FirstFreeCluster = _nIdx;
                }
            }

            /*
             *  Reset the DEVICE
             */

            _iop.pDevice = Device_GetBindDev(pDevObj);
            _iop.nIoOperation = DEVICE_IO_CONTROL;
            _iop.nFunction =
                _IOCTL_MAKECODE(
                    MAJOR_DEVNO( _iop.pDevice->nDeviceNo ),
                    DEVICE_IOCTL_RESET,
                    _IOCTL_ACCESS_NEITHER
                );
            IO_DISPATCH(&_iop);
        }

        /*
         *  Assign Free Cluster and update counts
         */

        *pnClusterIdx = _pFatDev->FAT_FirstFreeCluster;

        _pFatDev->FAT_FreeClusters--;
        _pFatDev->FAT_AvailClusters--;

        /*
         *  Find the next free one
         */

        for (
            _nIdx = _pFatDev->FAT_FirstFreeCluster+1;
            _nIdx < _pFatDev->FAT_DataClusters + 2;
            _nIdx++ )
        {
            _nIoStatus = Fat_GetClusterIndex( pDevObj, _nIdx, &_nCluster );
            if ( _DEV_IOSTATUS_FAILED(_nIoStatus) && 
                ( _DEV_IOSTATUS_CODE(_nIoStatus) != _DEV_IOSTATUS_RETRY ))
            {
                _THROW(Exception_File);
            }

            /*
             *  FREE Cluster Found?
             */

            if ( _nCluster == eClusterFree )
            {
                _pFatDev->FAT_FirstFreeCluster = _nIdx;
                break;
            }
        }
    }
    _CATCH(Exception_File)
    {
        /*
         *  TODO:
         */
    }
    _END_CATCH

    /*
     *  Return the result
     */

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_FreeClusterIndex
 *
 *      Releases a cluster into the Free list
 *
 *  Parameters:
 *      pDevObj         - The Device Object
 *      nClusterIdx     - The cluster index
 *
 *  Returns:
 *      Result of the operation
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

static
DEV_IOSTATUS Fat_FreeClusterIndex(
    PDEVICE_OBJ pDevObj,
    DEV_ULONG nClusterIdx
)
{
    DEV_IOSTATUS _nIoStatus;
    PFAT_DEVOBJ _pFatDev = FAT_DEVOBJ_EXT(pDevObj);

    /*
     *  Test for VALID Cluster
     */

    _nIoStatus = Fat_SetClusterIndex( pDevObj, nClusterIdx, eClusterFree );
    if (  _DEV_IOSTATUS_SUCCEEDED(_nIoStatus)  )
    {
        if ( nClusterIdx < _pFatDev->FAT_FirstFreeCluster )
        {
            _pFatDev->FAT_FirstFreeCluster = nClusterIdx;
        }

        _pFatDev->FAT_FreeClusters++;
        _pFatDev->FAT_AvailClusters++;
    }

    /*
     *  Return the STATUS
     */

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *  Public Methods
 * --------------------------------------------------------------------------
 */

/* --------------------------------------------------------------------------
 *
 *  Fat_ConvertToDiskTime
 *
 *      Converts the CURRENT system Time to the Disk Compatible for FAT
 *
 *  Parameters:
 *      pDirTime    - Pointer to a directory Time Structure
 *      pDirDate    - Pointer to a Directory Date Structure
 *
 *  Returns:
 *      Returns the number of seconds elapsed since midnight (00:00:00),
 *      January 1, 1970, coordinated universal time (UTC), according to the
 *      system clock.
 *
 *  Notes:
 *      Time stored on the FAT Device is based upon midnight January 1, 1980
 *      since this is a Microsoft Based File System.
 *
 * --------------------------------------------------------------------------
 */

DEV_TIME Fat_ConvertToDiskTime(
    FAT_TIME* pDirTime,
    FAT_DATE* pDirDate
)
{
    DEV_LOCALTIME* _pLocalTime;
    DEV_TIME    _ltime;

    /*
     *  Get the Current TIME information
     */

    DEVOBJ_TIME( &_ltime );
    DEVOBJ_LOCALTIME( &_ltime, _pLocalTime );

    /*
     *  Convert
     */

    pDirTime->nSeconds = _pLocalTime->tm_sec >> 1;
    pDirTime->nMinutes = _pLocalTime->tm_min;
    pDirTime->nHours = _pLocalTime->tm_hour;

    /*
     *  Date Information
     */

    pDirDate->nMonth = _pLocalTime->tm_mon + 1;
    pDirDate->nDay = _pLocalTime->tm_mday;
    pDirDate->nYear = _pLocalTime->tm_year - 80;

    return _ltime;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_ConvertFromDiskTime
 *
 *      Converts the Disk Time to the compatible system time
 *
 *  Parameters:
 *      pDirTime    - Pointer to a directory Time Structure
 *      pDirDate    - Pointer to a Directory Date Structure
 *
 *  Returns:
 *
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

DEV_TIME Fat_ConvertFromDiskTime(
    FAT_TIME* pDirTime,
    FAT_DATE* pDirDate
)
{
    static DEV_UINT s_nMonthDay[] = {
        31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
    };

    /*
     *  Initialize a decade forward (see NOTES)
     */

    DEV_TIME _lTime = 0;
    DEV_LONG _nDays = pDirDate->nDay - 1;
    DEV_INT _nMonth = eJanuary;

    /*
     *  Convert Time first...
     */

    if ( pDirTime != (FAT_TIME*)0 )
    {
        _lTime = pDirTime->nSeconds << 1;
        _lTime += ( pDirTime->nMinutes * 60L );
        _lTime += ( pDirTime->nHours * 3600L );
    }

    /*
     *  Convert Date
     */

    _nDays += ( pDirDate->nYear + 10 ) * _DAYSPERYEAR;
    while ( _nMonth < ( pDirDate->nMonth - 1 ) )
    {
        _nDays += s_nMonthDay[_nMonth];
        _nMonth++;
    }

    /*
     *  Adjust for Leap Year
     */

    _nDays += ( ( pDirDate->nYear + 10 ) / 4 );

    /*
     *  Given Days (add to TIME and return)
     */

    return  _lTime + ( _nDays * _SECONDSPERDAY );
}

/* --------------------------------------------------------------------------
 *  DIRECTORY ENTRY METHODS
 *
 *      File Directory Accesses require a FILE Object Pointer since a Cache
 *      is required and this is less costly than allocating and deallocating
 *      the cache each time a call is made.
 * --------------------------------------------------------------------------
 */

/* --------------------------------------------------------------------------
 *
 *  Fat_DirFindEntry
 *
 *      This function finds an entry in the directory list given a valid
 *      directory and file name. If found, it updates the File Object with
 *      information on the entry, otherwise only the name is filled in.
 *
 *              +---------------------------------------+
 *          0   |           Entry (32 bytes)            |
 *              +---------------------------------------+
 *          1   |           Entry (32 bytes)            |
 *              +---------------------------------------+
 *                                  .
 *                                  .
 *                                  .
 *              +---------------------------------------+
 *         n-1  |           Entry (32 bytes)            |
 *              +---------------------------------------+
 *
 *      Entries are sequentially stored in N clusters, preallocated when a
 *      directory is created (dynamic allocation as directories grow or
 *      shrink is not supported in this release). Each directory entry is
 *      32 bytes in length (see fat.h for a description).
 *
 *  Parameters:
 *      pFileObj        - The File Object (see Notes)
 *      strEntry        - The string containing the entry being searched
 *
 *  Returns:
 *      Returns Successful if the entry is found otherwise an error is
 *      returned. In either case, the entry to search for is placed in it's
 *      correct 8.3 format in the File Object Extension area for FAT.
 *
 *  Notes:
 *      FILE OBJECT:
 *
 *          On Input:   The directory information for the parent should be
 *                      filled in, as this is where the search will occur.
 *
 *          On Output:  The directory information for the file/directory
 *                      to search for will be filled in. If not found, then
 *                      the file name, and the location of the first free
 *                      entry.
 *
 *                      Also the FILE Object will be set the Cluster, Sector
 *                      Offset, and Byte Offset that the entry was found. If
 *                      not found, the values will indicate the end of the
 *                      entry table.
 *
 *      Special Case Entries: "dot" and "dotdot"
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_DirFindEntry(
    PFILE_OBJ pFileObj,
    DEV_STRING strEntry
)
{
    DEV_IOSTATUS _nIoStatus = FSD_IOSTATUS_SUCCESS;
    DirEntryName_t _dirName;

    register DEV_UINT _nOffset;     /*  Offset in Sector            */

    /*
     *  Aliases
     */

    PFAT_FILEOBJ _pFatFileObj;
    PFAT_DEVOBJ _pFatDev;

    /*
     *  Cache Pointers
     */

    _pFatFileObj = FAT_FILEOBJ_EXT(pFileObj);
    _pFatDev  = FAT_DEVOBJ_EXT(pFileObj->pDeviceObj);

    /*
     *  Root Directory?
     */

    if ( DEVOBJ_STRLEN(strEntry) == 0 )
    {
        DEVOBJ_MEMCPY(
            &_pFatFileObj->theEntry,
            &_pFatFileObj->theParentEntry,
            sizeof(FAT_DIRENTRY)
        );

        return _nIoStatus;
    }

    /*
     *  OK, the Name needs to be put in it's correct form (8.3)
     */

    if ( strEntry[0] != DIRENTRY_FREE )
    {

        /*
         *  Copy EMPTY STring
         */

        DEVOBJ_STRNCPY(
            _dirName.strName,
            DIRENTRY_EMPTYNAME,
            DIRENTRY_FULLNAMELEN
        );

        /*
         *  Have to setup the string name in it's proper format. STRTOK
         *  is not used, since it is additional overhead not needed and
         *  there is no need to corrupt the string with it.
         *
         *  NO VALIDATION IS PERFORMED, Names and Extensions are Truncated
         *  if they exceed legal limits. (This loop is built for speed and
         *  not for structured programming styles)
         */

        for ( _nOffset = 0; _nOffset <= DIRENTRY_NAMELEN; _nOffset++ )
        {
            /*
             *  Delimiter found
             */

            if ( ( *strEntry == '.' ) || ( *strEntry == DEVOBJ_EOS ) )
            {
                /*
                 *  FILENAMES cannot start with " ", so a "." at the start
                 *  is invalid. For "dot" and "dotdot", the caller must handle
                 *  those cases (Therefore test for INVALID FILENAME) and then
                 *  check the string.
                 */

                if ( _nOffset == 0 )
                {
                    /*
                     *  Go ahead and get the string size and copy the first
                     *  part (this could be the special cases "." and ".."
                     */

                    _nOffset = DEVOBJ_STRLEN(strEntry);
                    _dirName.part.strName[0] = *strEntry++;

                    /*
                     *  Current Directory?
                     */

                    if ( _nOffset == 1 )
                    {
                        break;
                    }

                    /*
                     *  Previous Directory?
                     */

                    else if ( ( _nOffset == 2 ) && ( *strEntry == '.' ) )
                    {
                        _dirName.part.strName[1] = *strEntry;
                        break;
                    }

                    /*
                     *  Filename is invalid then
                     */

                    _nIoStatus = FSD_IOSTATUS_PATH_NOT_FOUND;
                    break;
                }

                /*
                 *  OK, something other than Current and Previous Directory
                 */

                else
                {
                    _nOffset= 0;

                    /*
                     *  Get the extension now
                     */

                    while ( ( *strEntry != DEVOBJ_EOS ) &&
                                            ( _nOffset < DIRENTRY_EXTLEN ) )
                    {
                        _dirName.part.strExt[_nOffset++] = *( ++strEntry );
                    }
                    break;
                }
            }

            /*
             *  Character over
             */

            _dirName.part.strName[_nOffset] = *strEntry++;
        }

        /*
         *  Valid Filename?
         */

        if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
        {
            return _nIoStatus;
        }

        /*
         *  Names are always CASE Insensitive, but are stored Uppercase
         *  regardless (save as Entry)
         */

        StringCaseToUpper(_dirName.strName, DIRENTRY_FULLNAMELEN);
    }

    /*
     *  Looking for a FREE Entry
     */

    else
    {
        DEVOBJ_MEMSET(
            _dirName.strName,
            DIRENTRY_END,
            DIRENTRY_FULLNAMELEN
        );
        _dirName.strName[0] = DIRENTRY_FREE;
    }

    DEVOBJ_STRNCPY(
        _pFatFileObj->theEntry.DIR_Name,
        _dirName.strName,
        DIRENTRY_FULLNAMELEN
    );

    /*
     *  Initialize to the Starting Sector and OFFSET
     *
     *      ROOT Entries don't require Cluster information since CLUSTERS
     *      ARE not defined outside the DATA region.
     */

    if ( _pFatFileObj->theParentEntry.DIR_Name[0] == DIRENTRY_ROOT )
    {
        _pFatFileObj->nDirSector = _pFatDev->FAT_FirstRootDirSector;

        /*
         *  Are we testing for "." AND/OR "..", since these entries do not
         *  show up in the ROOT, then copy Parent and return immediately
         *  Kind of Hacky, but the special case for ROOT in a FAT12/16 system.
         */

        if ( _dirName.strName[0] == '.' )
        {
            DEVOBJ_MEMCPY(
                &( _pFatFileObj->theEntry ),
                &( _pFatFileObj->theParentEntry ),
                sizeof( FAT_DIRENTRY )
            );

            return _nIoStatus;
        }
    }
    else
    {
        _pFatFileObj->nDirSector =
            FAT_FIRSTSECTOROFCLUSTER(
                _pFatDev,
                _pFatFileObj->theParentEntry.DIR_FstClusLO
            );

        _pFatFileObj->nCluster = _pFatFileObj->theParentEntry.DIR_FstClusLO;
        _pFatFileObj->nSector = 0;
    }

    /*
     *  Loop until a match is found or the end of the directory is reached
     */

    while (1)
    {
        PFAT_DIRENTRY _pdirTmpEntry;

        /*
         *  Read the Sector
         */

        _nIoStatus = 
            Fat_ReadSector(
                pFileObj->pDeviceObj,
                pFileObj->pBuffer,
                _pFatFileObj->nDirSector
            );

        /*
         *  Loop all the entries in the Sector
         *
         *      The following does not follow strict rules of structured
         *      programming, but for performance reasons, local return
         *      statements were added once an entry was determined to be
         *      present or not, otherwise an additional test would be required
         *      each time a sector was
         */

        _pdirTmpEntry = (PFAT_DIRENTRY)pFileObj->pBuffer;
        for (
            _nOffset = 0;
            _nOffset < _pFatDev->FAT_BootSector.BPB_BytesPerSec;
            _nOffset += sizeof(FAT_DIRENTRY)
        )
        {
            /*
             *  Is this the end of the list?
             *
             *  To save processing time, the name of the file is copied into
             *  the structure in it's proper format. (See Notes why this is
             *  done)
             */

            if ( _pdirTmpEntry->DIR_Name[0] == DIRENTRY_END )
            {
                _nIoStatus = FSD_IOSTATUS_FILE_NOT_FOUND;
                break;
            }

            /*
             *  Did we find the entry?
             *
             *      The IOSTATUS will already be set to Successful so no need
             *      to waste CPU cycles assigning it again.
             */

            else if ( 
                DEVOBJ_STRNCMP(
                    _dirName.strName,
                    _pdirTmpEntry->DIR_Name,
                    DIRENTRY_FULLNAMELEN ) == 0 )
            {
                Fat_DirEntryUnpack(
                    &(_pFatFileObj->theEntry),
                    (DEV_USTRING)_pdirTmpEntry
                );

                _pFatFileObj->nOffset = 0;
                _pFatFileObj->nCluster = _pFatFileObj->theEntry.DIR_FstClusLO;

                break;
            }

            /*
             *  Next Entry
             */

            _pdirTmpEntry++;
        }

        /*
         *  Was there a terminating condition in the previous loop?
         */

        if ( _nOffset < _pFatDev->FAT_BootSector.BPB_BytesPerSec )
        {
            _pFatFileObj->nDirOffset = _nOffset;
            break;
        }

        /*
         *  Next SECTOR
         *
         *      For ROOT nothing is done, but accept the increment
         */

        _pFatFileObj->nDirSector++;
        if ( _pFatFileObj->theParentEntry.DIR_Name[0] != DIRENTRY_ROOT )
        {
            /*
             *  End of the cluster?
             */

            if ( ++_pFatFileObj->nSector == 
                _pFatDev->FAT_BootSector.BPB_SecPerClus )
            {
                _nIoStatus =
                    Fat_GetClusterEntry(
                        pFileObj->pDeviceObj,
                        _pFatFileObj->nCluster,
                        &(_pFatFileObj->nCluster)
                    );

                if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
                {
                    break;
                }

                /*
                 *  Get the new Sector (we don't check for boundary conditions
                 *  as an end marker will always occupy the last entry in the
                 *  directory).
                 */

                _pFatFileObj->nDirSector =
                    FAT_FIRSTSECTOROFCLUSTER(
                        _pFatDev,
                        _pFatFileObj->nCluster
                    );
                _pFatFileObj->nSector = 0;
            }
        }

        /*
         *  Continue looping
         */
    }

    /*
     *  An error indicates a complete trace was not possible, due to a 
     *  catastrophic error in the FAT
     */

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_DirCreateEntry
 *
 *      Inserts an entry into the directory and allocates a Cluster for it.
 *      The ENTRY within the Allocated Cluster is set to
 *
 *  Parameters:
 *      pFileObj        - The File Object (see Notes)
 *
 *  Returns:
 *      Returns Successful if the entry is inserted otherwise an error is
 *      returned (either on Directory being FULL or File Already exist).
 *
 *  Notes:
 *      No validation of whether the entry already exists is performed.
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_DirCreateEntry(
    PFILE_OBJ pFileObj
)
{
    static DEV_CHAR s_strFreeEntry[] = { DIRENTRY_FREE, '\0' };
    register DEV_UINT _nSector;

    DEV_IOSTATUS _nIoStatus;
    FAT_DIRENTRY _dirInsertEntry;

    /*
     *  Aliases
     */

    PFAT_FILEOBJ _pFatFileObj = FAT_FILEOBJ_EXT(pFileObj);
    PFAT_DEVOBJ _pFatDev = FAT_DEVOBJ_EXT(pFileObj->pDeviceObj);

    /*
     *  DIRECTORY ENTRY MODIFICATIONS are guarded
     */

    DEVOBJ_ENTER_CRITICAL_SECTION(_pFatDev->FAT_DirectoryMutex);

    /*
     *  Backup the Directory Entry
     */

    DEVOBJ_MEMCPY(
        &_dirInsertEntry,
        &(_pFatFileObj->theEntry),
        sizeof(FAT_DIRENTRY)
    );

    _TRY
    {
        /*
         *  File system FULL?
         */

        if ( _pFatDev->FAT_AvailClusters == 0 )
        {
            _nIoStatus = FSD_IOSTATUS_SYSTEM_FULL;
            _THROW(Exception_File);
        }

        /*
         *  Test to see if there is a FREE String available
         */

        _nIoStatus = Fat_DirFindEntry( pFileObj, &s_strFreeEntry[0] );
        if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
        {
            /*
             *  Some other error???
             */

            if ( _nIoStatus != FSD_IOSTATUS_FILE_NOT_FOUND )
            {
                _THROW(Exception_File);
            }

            _nSector = _pFatFileObj->nDirSector;
            if ( _pFatFileObj->theParentEntry.DIR_Name[0] != DIRENTRY_ROOT )
            {
                _nSector -=
                    FAT_FIRSTSECTOROFCLUSTER(
                        _pFatDev,
                        _pFatFileObj->nCluster
                    );
            }

            /*
             *  Entry has to be appended to the end, CHECK for Boundary
             *  Conditions
             */

            _pFatFileObj->nDirOffset += sizeof(FAT_DIRENTRY);
            if ( _pFatFileObj->nDirOffset ==
                    _pFatDev->FAT_BootSector.BPB_BytesPerSec )
            {
                /*
                 *  Test for ROOT Directory
                 */

                if ( _pFatFileObj->theParentEntry.DIR_Name[0] !=
                                                        DIRENTRY_ROOT )
                {
                    /*
                     *  Increment the Sector Offset
                     */

                    _nSector++;

                    /*
                     *  Test for Cluster Boundary First
                     */

                    if ( _nSector ==
                             _pFatDev->FAT_BootSector.BPB_SecPerClus )
                    {
                        DEV_UINT32 _nCluster;

                        _nIoStatus =
                            Fat_GetClusterEntry(
                                pFileObj->pDeviceObj,
                                _pFatFileObj->nCluster,
                                &_nCluster
                            );

                        /*
                         *  End of File?
                         *
                         *      On END of FILE 
                         */

                        if ( _nCluster >= FAT_EOF(_pFatDev) )
                        {
                            /*
                             *  Get a new cluster
                             */

                            _nIoStatus =
                                Fat_FindNextFreeCluster(
                                    pFileObj->pDeviceObj,
                                    &_nCluster
                                );
                            if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
                            {
                                _THROW(Exception_File);
                            }

                            /*
                             *  Assign Next Cluster
                             */

                            _nIoStatus =
                                Fat_SetClusterEntry(
                                    pFileObj->pDeviceObj,
                                    _pFatFileObj->nCluster,
                                    _nCluster
                                );
                            if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
                            {
                                _THROW(Exception_File);
                            }

                            /*
                             *  Initialize the Cluster
                             */

                            _nIoStatus =
                                Fat_SetClusterEntry(
                                    pFileObj->pDeviceObj,
                                    _nCluster,
                                    eClusterEOF
                                );
                            if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
                            {
                                _THROW(Exception_File);
                            }

                            /*
                             *  ZAP the current Cluster
                             */

                            _nSector = 0;
                            _nCluster =
                                FAT_FIRSTSECTOROFCLUSTER(
                                    _pFatDev,
                                    _nCluster
                                );
                            DEVOBJ_MEMSET(
                                pFileObj->pBuffer,
                                0, pFileObj->nBufferLen
                            );

                            while ( _nSector <
                                _pFatDev->FAT_BootSector.BPB_SecPerClus  )
                            {
                                _nIoStatus = 
                                    Fat_WriteSector(
                                        pFileObj->pDeviceObj,
                                        pFileObj->pBuffer,
                                        _nCluster
                                    );
                                if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
                                {
                                    _THROW(Exception_File);
                                }

                                /*
                                 *  
                                 */

                                _nSector++;
                                _nCluster++;
                            }

                            /*
                             *  Restore original
                             */

                            Fat_ReadSector(
                                pFileObj->pDeviceObj,
                                pFileObj->pBuffer,
                                _pFatFileObj->nDirSector
                            );
                        }
                    }
                }

                /*
                 *  Root Directory FULL?
                 */

                else if ( ( _pFatFileObj->nDirSector + 1 ) ==
                                (DEV_USHORT)FAT_FIRSTDATASECTOR(_pFatDev) )
                {
                    _nIoStatus = FSD_IOSTATUS_DIRECTORY_FULL;
                    _THROW(Exception_File);
                }
            }

            /*
             *  Adjust back
             */

            _pFatFileObj->nDirOffset -= sizeof(FAT_DIRENTRY);
        }

        /*
         *  Convert Time into FAT compatible
         */

        Fat_ConvertToDiskTime(
            (FAT_TIME*)&_dirInsertEntry.DIR_CrtTime,
            (FAT_DATE*)&_dirInsertEntry.DIR_CrtDate
        );

        _dirInsertEntry.DIR_WrtTime = _dirInsertEntry.DIR_CrtTime;
        _dirInsertEntry.DIR_WrtDate = _dirInsertEntry.DIR_CrtDate;
        _dirInsertEntry.DIR_LstAccDate = _dirInsertEntry.DIR_CrtDate;

        /*
         *  Data that is set otherwise (Cluster is actually set by the caller)
         */

        _dirInsertEntry.DIR_Attr =
        _dirInsertEntry.DIR_CrtTimeTenth =
        _dirInsertEntry.DIR_NTRes = 0;
        _dirInsertEntry.DIR_FstClusHI = 0;
        _dirInsertEntry.DIR_FileSize = 0L;

        /*
         *  Pack and Write
         */

        Fat_DirEntryPack(
            &_dirInsertEntry,
            &( pFileObj->pBuffer[_pFatFileObj->nDirOffset] )
        );

        /*
         *  
         */

        _pFatFileObj->nCluster = 
            FAT_GETCLUSTEROFSECTOR( _pFatDev, _pFatFileObj->nDirSector );

        _pFatFileObj->nSector = _pFatFileObj->nDirSector - 
            FAT_FIRSTSECTOROFCLUSTER( _pFatDev, _pFatFileObj->nCluster );

        /*
         *  Update the directory (result is returned by the user
         */

        _nIoStatus = Fat_FileWriteSector( pFileObj );
    }
    _CATCH(Exception_File)
    {
        /*
         *  Critical Errors handled here
         */
    }
    _END_CATCH

    /*
     *  Restore the NAME
     */

    DEVOBJ_MEMCPY(
        &(_pFatFileObj->theEntry),
        &_dirInsertEntry,
        sizeof(FAT_DIRENTRY)
    );

    DEVOBJ_LEAVE_CRITICAL_SECTION(_pFatDev->FAT_DirectoryMutex);

    /*
     *  Return Result
     */

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_DirRemoveEntry
 *
 *      Removes an entry from the Directory table
 *
 *  Parameters:
 *      pFileObj        - The File Object (see Notes)
 *
 *  Returns:
 *      Returns Successful if the entry is inserted otherwise an error is
 *      returned (either on Directory being FULL or File Already exist).
 *
 *  Notes:
 *      This is the worst part about the FAT Design is the fact that SINCE
 *      the FILE SIZE IS NOT KEPT of the directory, if an entry is deleted
 *      at the end of the directory, then a RECURSIVE CHECK IN THE OPPOSITE
 *      DIRECTION is required, just in case a block of FREE Entries preceed
 *      the EOD marker. Real genius to pull that off!
 *
 *      BECAUSE all of the information dealing with the FILE has been re-
 *      moved, physically, the File Object here is reused for the DIRECTORY
 *      so that the entry can be removed.
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_DirRemoveEntry(
    PFILE_OBJ pFileObj
)
{
    DEV_IOSTATUS _nIoStatus;
    PFAT_FILEOBJ _pFatFileObj;
    PFAT_DEVOBJ _pFatDev;

    DEV_BOOL _bRootEntry;

    _pFatFileObj = FAT_FILEOBJ_EXT(pFileObj);
    _pFatDev = FAT_DEVOBJ_EXT(pFileObj->pDeviceObj);

    /*
     *  DIRECTORY ENTRY MODIFICATIONS are guarded
     */

    DEVOBJ_ENTER_CRITICAL_SECTION(_pFatDev->FAT_DirectoryMutex);

    /*
     *  Resides in the Root Directory?
     */

    if ( _pFatFileObj->theParentEntry.DIR_Name[0] == DIRENTRY_ROOT )
    {
        _bRootEntry = DEVOBJ_TRUE;
    }
    else
    {
        _bRootEntry = DEVOBJ_FALSE;
    }

    /*
     *  Clear the Entry
     */

    DEVOBJ_MEMSET(
        _pFatFileObj->theEntry.DIR_Name,
        DIRENTRY_END,
        sizeof(FAT_DIRENTRY)
    );

    _TRY
    {
        /*
         *  Test the Next Entry
         */

        DEV_UINT32 _nDirSector = _pFatFileObj->nDirSector;
        DEV_UINT16 _nDirOffset =
            _pFatFileObj->nDirOffset + sizeof(FAT_DIRENTRY);

        /*
         *  Is the next entry in the next Sector?
         */

        if ( _nDirOffset >= _pFatDev->FAT_BootSector.BPB_BytesPerSec )
        {
            _nDirOffset = 0;

            /*
             *  Is this entry in the ROOT?
             *
             *  IF NOT, no further testing for the ROOT is required because
             *  the last entry in the ROOT is ALWAYS "0". So if this is the
             *  last entry in a Root Sector it is impossible for it to be the
             *  last sector.
             */

            if ( _bRootEntry == DEVOBJ_FALSE )
            {
                /*
                 *  Find the Cluster for the given sector
                 */

                DEV_UINT32 _nDirCluster =
                    FAT_GETCLUSTEROFSECTOR(
                        _pFatDev,
                        _pFatFileObj->nDirSector
                    );

                /*
                 *  Next Sector and TEST if a Cluster Boundary is crossed
                 */

                ++_nDirSector;

                if ( _nDirCluster !=
                        FAT_GETCLUSTEROFSECTOR(_pFatDev,_nDirSector) )
                {
                    _nIoStatus =
                        Fat_GetClusterEntry(
                            pFileObj->pDeviceObj,
                            _nDirCluster,
                            &_nDirCluster
                        );
                    if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
                    {
                        _THROW(Exception_Default);
                    }

                    _nDirSector =
                        FAT_FIRSTSECTOROFCLUSTER(_pFatDev,_nDirCluster);
                }
            }

            /*
             *  For the ROOT we just increment
             */

            else
            {
                _nDirSector++;
            }
        }

        /*
         *  Read the SECTOR
         */

        _nIoStatus = 
            Fat_ReadSector( 
                pFileObj->pDeviceObj,    
                pFileObj->pBuffer,
                _nDirSector
            );

        /*
         *  Still more entries to follow?
         */

        if (
            ((PFAT_DIRENTRY)&pFileObj->pBuffer[_nDirOffset])->DIR_Name[0] !=
                DIRENTRY_END )
        {
            _pFatFileObj->theEntry.DIR_Name[0] = DIRENTRY_FREE;

            /*
             *  Basically no more work to do beyond this
             */
        }

        /*
         *  Nope, this is the End of Directory and will require more work
         */

        else
        {
            _pFatFileObj->theEntry.DIR_Name[0] = DIRENTRY_END;
        }

        /*
         *  Is the Buffer Cached?
         */

        if ( _nDirSector != _pFatFileObj->nDirSector )
        {
            Fat_ReadSector(
                pFileObj->pDeviceObj,
                pFileObj->pBuffer,
                _pFatFileObj->nDirSector
            );
        }

        /*
         *  Update the Entry and WRITE IT
         */

        DEVOBJ_MEMCPY(
            &pFileObj->pBuffer[_pFatFileObj->nDirOffset],
            &_pFatFileObj->theEntry,
            sizeof(FAT_DIRENTRY)
        );

        /*
         *  Copy the PARENT Over (Cluster/Sector/Offset)
         */

        DEVOBJ_MEMCPY(
            &_pFatFileObj->theEntry,
            &_pFatFileObj->theParentEntry,
            sizeof(FAT_DIRENTRY)
        );

        _pFatFileObj->nCluster = 
            FAT_GETCLUSTEROFSECTOR(
                _pFatDev,
                _pFatFileObj->nDirSector
            );
        _pFatFileObj->nSector = _pFatFileObj->nDirSector - 
            FAT_FIRSTSECTOROFCLUSTER(_pFatDev,_pFatFileObj->nCluster);
        _pFatFileObj->nOffset = _pFatFileObj->nDirOffset;

        /*
         *  End of Directory?
         *
         *      This is the worst case scenario when removing a directory
         *      entry that is on the END.
         */

        if ( pFileObj->pBuffer[_pFatFileObj->nDirOffset] == DIRENTRY_END )
        {
            /*
             *  Root Directoty?
             */

            if ( _bRootEntry )
            {
                _nIoStatus = Fat_PackRootDirectory( pFileObj, _pFatDev );
            }

            /*
             *  Sub-directories are handled here
             */

            else
            {
                _nIoStatus = Fat_PackDirectory( pFileObj, _pFatDev );
            }

        }
        else
        {
            _nIoStatus = Fat_FileWriteSector( pFileObj );
        }
    }
    _CATCH(Exception_Default)
    {
    }
    _END_CATCH

    DEVOBJ_LEAVE_CRITICAL_SECTION(_pFatDev->FAT_DirectoryMutex);

    /*
     *  Return the result
     */

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_DirUpdateEntry
 *
 *      Updates an entry due to a file being closed after modification to
 *      it on the volume
 *
 *  Parameters:
 *      pFileObj        - The File Object (see Notes)
 *
 *  Returns:
 *      Result of UPDATE
 *
 *  Notes:
 *      No validation of whether the entry already exists is performed.
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_DirUpdateEntry(
    PFILE_OBJ pFileObj
)
{
    PFAT_DIRENTRY _pDirEntry;
    DEV_IOSTATUS _nIoStatus;

    PFAT_FILEOBJ _pFatFileObj = FAT_FILEOBJ_EXT(pFileObj);
    PFAT_DEVOBJ _pFatDev = FAT_DEVOBJ_EXT(pFileObj->pDeviceObj);

    /*
     *  DIRECTORY ENTRY MODIFICATIONS are guarded
     */

    DEVOBJ_ENTER_CRITICAL_SECTION( _pFatDev->FAT_DirectoryMutex );

    Fat_ReadSector(
        pFileObj->pDeviceObj,
        pFileObj->pBuffer,
        _pFatFileObj->nDirSector
    );

    _pDirEntry = 
        (PFAT_DIRENTRY)(pFileObj->pBuffer + _pFatFileObj->nDirOffset);

    /*
     *  Update File Size and Cluster information
     */

    _pDirEntry->DIR_Attr = _pFatFileObj->theEntry.DIR_Attr;
    _pDirEntry->DIR_FileSize = _pFatFileObj->theEntry.DIR_FileSize;
    _pDirEntry->DIR_FstClusLO = _pFatFileObj->theEntry.DIR_FstClusLO;

    /*
     *  Tag with WRITE time
     */

    Fat_ConvertToDiskTime(
        (FAT_TIME*)&(_pDirEntry->DIR_WrtTime),
        (FAT_DATE*)&(_pDirEntry->DIR_WrtDate)
    );

    /*
     *  Write back to the drive
     */

    DEVOBJ_MEMCPY(
        &_pFatFileObj->theEntry,
        &_pFatFileObj->theParentEntry,
        sizeof(FAT_DIRENTRY)
    );

    _pFatFileObj->nCluster = 
        FAT_GETCLUSTEROFSECTOR(
            _pFatDev,
            _pFatFileObj->nDirSector
        );
    _pFatFileObj->nSector = _pFatFileObj->nDirSector - 
        FAT_FIRSTSECTOROFCLUSTER(_pFatDev,_pFatFileObj->nCluster);
    _pFatFileObj->nOffset = _pFatFileObj->nDirOffset;

    /*
     *  Write the DIRECTORY Entry (result is returned to caller)
     */

    _nIoStatus = Fat_FileWriteSector( pFileObj );

    DEVOBJ_LEAVE_CRITICAL_SECTION( _pFatDev->FAT_DirectoryMutex );

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_PathWalk
 *
 *      On any call to open a file or directory or set to a file or directory
 *      PathWalk will find the start Cluster and fill the pointer to the Dir
 *      Entry structure.
 *
 *  Parameters:
 *      pFileObj        - The File Object
 *      strPath         - The string containing the Pathname
 *      pDirEntry       - Pointer of the Directory Entry structure to
 *                        fill. This could be pointer into the Directory
 *                        Structure encapsulated within the File Object
 *                        itself.
 *
 *  Returns:
 *      Returns result of the walking the path. The Directory Entry is
 *      filled with a valid entry if found, otherwise if the Entry references
 *      the root, then DIRENTRY_ROOT is set in the name and a success value
 *      is returned.
 *
 *      The Entry returned could be an entry for another sub-directory or
 *      a file. For NEW files or any type of directory operation, THIS should
 *      be a Directory type entry.
 *
 *  Notes:
 *      This method does not evaluate if any of the characters within
 *      pathname passed are legal. This is only done, when creating a new
 *      file or directory.
 *
 *      The caller must be aware that the pathname (string) passed in is
 *      going to be parsed and therefore will be altered upon return.
 *
 *      The Directory Entry pointer can subsequently point into the DirEntry
 *      part of the File Object, which sometimes may be the case.
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_DirPathWalk(
    PFILE_OBJ pFileObj,
    DEV_STRING strPath
)
{
    DEV_IOSTATUS _nIoStatus = FSD_IOSTATUS_SUCCESS;
    DEV_STRING _strToken;

    PFAT_DEVOBJ _pFatDev;
    PFAT_FILEOBJ _pFatFileObj;

    /*
     *  Debug
     */

    DEVOBJ_ASSERT( pFileObj != 0 );
    DEVOBJ_ASSERT( strPath != 0 );

    _pFatFileObj = FAT_FILEOBJ_EXT(pFileObj);
    _pFatDev  = FAT_DEVOBJ_EXT(pFileObj->pDeviceObj);

    /*
     *  Test for leading "\"
     */

    if ( *strPath == _PATH_DELIMITER[0] )
    {
        strPath++;
    }

    /*
     *  Initialization of the Parent (Root Directory is first)
     */

    _pFatFileObj->theParentEntry.DIR_Name[0] = DIRENTRY_ROOT;
    _pFatFileObj->theParentEntry.DIR_FileSize = 0;
    _pFatFileObj->theParentEntry.DIR_FstClusLO =
        _pFatDev->FAT_FirstRootDirSector;
    _pFatFileObj->theParentEntry.DIR_Attr = FAT_ATTR_DIRECTORY;

    /*
     *  Begin parsing the string
     */

    _TRY
    {
        /*
         *  Root Directory?
         */

        if ( DEVOBJ_STRLEN(strPath) == 0 )
        {
            _THROW(Exception_Default);
        }

        /*
         *  Walk the Path then
         */

        do
        {
            _strToken = strPath;
            strPath = DEVOBJ_STRSTR( _strToken, _PATH_DELIMITER );
            if ( strPath != 0 )
            {
                *strPath = DEVOBJ_EOS;
            }

            /*
             *  Check for Path validity (subpath)
             */

            _nIoStatus = Fat_DirFindEntry( pFileObj, _strToken );
            if ( strPath != 0 )
            {
                *strPath++ = _PATH_DELIMITER[0];
            }

            /*
             *  Current Path Valid so far?
             */

            if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
            {
                _THROW(Exception_Default);
            }

            /*
             *  Sanity Test...This is important as we cannot continue to parse
             *  unless the entry is a directory (a validity test is done out-
             *  side the loop)
             */

            if ( !DirEntry_IsDirectory( &(_pFatFileObj->theEntry) ) )
            {
                break;
            }

            /*
             *  Copy into the Parent
             */

            DEVOBJ_MEMCPY(
                &(_pFatFileObj->theParentEntry),
                &(_pFatFileObj->theEntry),
                sizeof(FAT_DIRENTRY)
            );

            /*
             *  Parse next directory...
             */

        }
        while ( strPath != 0 );

        /*
         *  If there is still part of the string left...then this is a invalid
         *  search path (in case the loop broke prematurely)
         */

        if ( strPath != 0 )
        {
            _nIoStatus = FSD_IOSTATUS_PATH_NOT_FOUND;
        }
    }

    /*
     *  Exception Handling
     */ 

    _CATCH(Exception_Default)
    {
    }
    _END_CATCH

    /*
     *  Return the RESULT
     */

    return _nIoStatus;
}

/*---------------------------------------------------------------------------
 *  FAT ACCESS METHODS
 *
 *      Protected region that allows getting and setting of clusters in the
 *      File Allocation Table. These are REDIRECTED to the Calls above as
 *      they are protected/public interfaces to clients outside, therefore
 *      a CRITICAL SECTION SURROUNDS ACCESS to the FAT (only one client
 *      allowed at any one time).
 *---------------------------------------------------------------------------
 */

/* --------------------------------------------------------------------------
 *
 *  Fat_SetClusterEntry
 *
 *      See Fat_SetClusterIndex.
 *
 *  Parameters:
 *      pDevObj     - Pointer to the device object
 *
 *  Returns:
 *      Result of Fat_SetClusterIndex
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_SetClusterEntry(
    PDEVICE_OBJ pDevObj,
    DEV_UINT32 nClusterIdx,
    DEV_UINT32 nClusterEntry
)
{
    DEV_IOSTATUS _nIoStatus;

    DEVOBJ_ENTER_CRITICAL_SECTION(
        FAT_DEVOBJ_EXT(pDevObj)->FAT_CriticalSection
    );

    _nIoStatus = Fat_SetClusterIndex( pDevObj, nClusterIdx, nClusterEntry );

    DEVOBJ_LEAVE_CRITICAL_SECTION(
        FAT_DEVOBJ_EXT(pDevObj)->FAT_CriticalSection
    );

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_GetClusterEntry
 *
 *      See Fat_GetClusterIndex.
 *
 *  Parameters:
 *      pDevObj     - Pointer to the device object
 *
 *  Returns:
 *      Result of Fat_GetClusterIndex
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_GetClusterEntry(
    PDEVICE_OBJ pDevObj,
    DEV_UINT32 nClusterIdx,
    DEV_UINT32* pClusterEntry
)
{
    DEV_IOSTATUS _nIoStatus;

    DEVOBJ_ENTER_CRITICAL_SECTION(
        FAT_DEVOBJ_EXT(pDevObj)->FAT_CriticalSection
    );

    _nIoStatus = Fat_GetClusterIndex( pDevObj, nClusterIdx, pClusterEntry );

    DEVOBJ_LEAVE_CRITICAL_SECTION(
        FAT_DEVOBJ_EXT(pDevObj)->FAT_CriticalSection
    );

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_FindNextFreeCluster
 *
 *      This is the MUTUAL Exclusion entry for tasks.
 *
 *  Parameters:
 *      pDevObj     - Pointer to the device object
 *      nOperation  - Read or Write
 *
 *  Returns:
 *      Result of Fat_AllocClusterIndex (see Fat_AllocClusterIndex)
 *
 *  Notes:
 *      Blocks callers if another task or thread is currently accessing the
 *      FAT.
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_FindNextFreeCluster(
    PDEVICE_OBJ pDevObj,
    DEV_ULONG* pnClusterIdx
)
{
    DEV_IOSTATUS _nIoStatus;

    DEVOBJ_ENTER_CRITICAL_SECTION(
        FAT_DEVOBJ_EXT(pDevObj)->FAT_CriticalSection
    );

    _nIoStatus = Fat_AllocClusterIndex( pDevObj, pnClusterIdx );

    DEVOBJ_LEAVE_CRITICAL_SECTION(
        FAT_DEVOBJ_EXT(pDevObj)->FAT_CriticalSection
    );

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_ReleaseCluster
 *
 *      This is the MUTUAL Exclusion entry for tasks.
 *
 *  Parameters:
 *      pDevObj     - Pointer to the device object
 *      nOperation  - Read or Write
 *
 *  Returns:
 *      Result of Fat_FreeClusterIndex (see Fat_AllocClusterIndex)
 *
 *  Notes:
 *      Blocks callers if another task or thread is currently accessing the
 *      FAT.
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_ReleaseCluster(
    PDEVICE_OBJ pDevObj,
    DEV_ULONG nClusterIdx
)
{
    DEV_IOSTATUS _nIoStatus;

    DEVOBJ_ENTER_CRITICAL_SECTION(
        FAT_DEVOBJ_EXT(pDevObj)->FAT_CriticalSection
    );

    _nIoStatus = Fat_FreeClusterIndex( pDevObj, nClusterIdx );

    DEVOBJ_LEAVE_CRITICAL_SECTION(
        FAT_DEVOBJ_EXT(pDevObj)->FAT_CriticalSection
    );

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_ReleaseCluster
 *
 *      This is the MUTUAL Exclusion entry for tasks.
 *
 *  Parameters:
 *      pDevObj     - Pointer to the device object
 *      nOperation  - Read or Write
 *
 *  Returns:
 *      Result of Fat_FreeClusterIndex (see Fat_AllocClusterIndex)
 *
 *  Notes:
 *      Blocks callers if another task or thread is currently accessing the
 *      FAT.
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_InvalidateCluster(
    PDEVICE_OBJ pDevObj,
    DEV_ULONG nClusterIdx,
    DEV_IOSTATUS nStatus
)
{
    DEV_IOSTATUS _nIoStatus;
    DEV_UINT32 _nBadClusterVal = 
        ( _DEV_IOSTATUS_CODE(nStatus) == _DEV_IOSTATUS_RETRY ) ? 
            eClusterCheck : eClusterBad;

    DEVOBJ_ENTER_CRITICAL_SECTION(
        FAT_DEVOBJ_EXT(pDevObj)->FAT_CriticalSection
    );

    _nIoStatus = 
        Fat_SetClusterIndex( pDevObj, nClusterIdx, _nBadClusterVal );

    /*
     *  The FREE List is not updated as this count is critical internally, but
     *  the Cluster availability is necessary.
     */ 

    if ( _nBadClusterVal == eClusterCheck )
    {
        FAT_DEVOBJ_EXT(pDevObj)->FAT_AvailClusters++;
    }

    /*
     *  Decrement FREE Cluster Count
     */

    FAT_DEVOBJ_EXT(pDevObj)->FAT_FreeClusters--;
    
    DEVOBJ_LEAVE_CRITICAL_SECTION(
        FAT_DEVOBJ_EXT(pDevObj)->FAT_CriticalSection
    );

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_GetSetSector
 *
 *      Read/writes a single Sector from/to the FAT File System.
 *
 *  Parameters:
 *      pDevObj     - The Device Object for this Fat Device
 *      nOperation  - Read or Write Operation
 *      pSector     - Pointer to the buffer to read/write sector from/to
 *      nSector     - The Sector number
 *
 *  Returns:
 *      Result of the Read/Write operation
 *
 *  Notes:
 *      None.
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_GetSetSector(
    PDEVICE_OBJ pDevObj,
    DEV_SHORT nOperation,
    DEV_USTRING pSector,
    DEV_UINT32 nSector
)
{
    DEV_IOPACKET _iop;
    DEV_ADDRESS _addr;

    /*
     *  Cache the requested Sector
     */

    _addr.nBlockAddress.nBlock = nSector;
    _addr.nBlockAddress.nOffset = 0;

    _iop.pDevice = Device_GetBindDev(pDevObj);
    _iop.nIoOperation = nOperation;
    _iop.pDescriptor = (DEV_PVOID)&_addr;

    /*
     *  Write or...
     */

    if ( nOperation == DEVICE_IO_WRITE )
    {
        _iop.pOutBuffer = (DEV_PVOID)pSector;
        _iop.nOutBufferLen = FAT_BOOTSECTOR(pDevObj)->BPB_BytesPerSec;
    }

    /*
     *  ...Read
     */

    else
    {
        _iop.pInBuffer = (DEV_PVOID)pSector;
        _iop.nInBufferLen = FAT_BOOTSECTOR(pDevObj)->BPB_BytesPerSec;
    }

    /*
     *  Dispatch to the device
     */

    return IO_DISPATCH(&_iop);
}

/*
 *  End of fat_core.c
 */

