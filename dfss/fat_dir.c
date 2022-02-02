
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
 *  fat_dir.c
 *
 *      Operations specific to Directories.
 */

#define _FAT_INCLUDE_CORE
#include "fat.h"

/* --------------------------------------------------------------------------
 *
 *  Fat_CreateDir
 *
 *      Creates a subdirectory
 *
 *  Parameters:
 *      pFileObj    - Pointer to the file object descriptor
 *      strPath     - Pathname of new directory to create
 *
 *  Returns:
 *      Result of Directory creation
 *
 *  Notes:
 *      This function will only create a subdirectory and not the entire
 *      path specified. The pathname up to and excluding the directory name
 *      must exist else the operation fail.
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_CreateDir(
    PFILE_OBJ pFileObj,
    DEV_STRING strPath
)
{
    DEV_IOSTATUS _nIoStatus;

    /*
     *  DEBUG
     */

    DEVOBJ_ASSERT( pFileObj != 0 );
    DEVOBJ_ASSERT( strPath != 0 );

    /*
     *  To create a directory, call FILE Open with the Attributes setup.
     *  The File Object Pointer will contain information about the newly
     *  created directory.
     */

    _nIoStatus = 
        Fat_FileOpen(
            pFileObj,
            strPath,
            FSD_FLAGS(
                _OPEN_WRONLY | _OPEN_CREAT | _OPEN_EXCL,
                _PMODE_READ | _PMODE_WRITE
            )
        );

    /*
     *  Was the directory entry created successfully?
     */

    if ( _DEV_IOSTATUS_SUCCEEDED(_nIoStatus) )
    {
        FAT_DIRENTRY _dirEntry;
        PFAT_FILEOBJ _pFatFileObj;

        _pFatFileObj = FAT_FILEOBJ_EXT(pFileObj);

        /*
         *  Set Attributes to reflect a DIRECTORY
         */

        _pFatFileObj->theEntry.DIR_Attr |= FAT_ATTR_DIRECTORY;

        /*
         *  A little cheating is provided to ensure a faster execution (NO 
         *  Need) - INITIALIZE the CLUSTER, with the exception of the first 
         *  entry.
         */

        DEVOBJ_MEMSET( pFileObj->pBuffer, 0, pFileObj->nBufferLen );

        /*
         *  Create the FIRST Two Entries "dot" and "dotdot"
         */
        
        DEVOBJ_MEMCPY(
                &_dirEntry,
                &_pFatFileObj->theEntry,
                sizeof(FAT_DIRENTRY)
        );

        DEVOBJ_STRNCPY(
                _dirEntry.DIR_Name,
                DIRENTRY_EMPTYNAME,
                DIRENTRY_FULLNAMELEN
        );
        DEVOBJ_STRNCPY( &_dirEntry.DIR_Name[0], _CURDIR, _CURDIR_LEN );
        DEVOBJ_MEMCPY(
                pFileObj->pBuffer,
                &_dirEntry,
                sizeof(FAT_DIRENTRY)
        );

        /*
         *  Previous Directory
         */

        DEVOBJ_STRNCPY( &_dirEntry.DIR_Name[0], _PREVDIR, _PREVDIR_LEN );
        _dirEntry.DIR_FstClusLO = 
                _pFatFileObj->theParentEntry.DIR_FstClusLO;

        DEVOBJ_MEMCPY(
                pFileObj->pBuffer + sizeof(FAT_DIRENTRY),
                &_dirEntry,
                sizeof(FAT_DIRENTRY)
        );

        /*
         *  Modify handler that the buffer was updated so it is commited
         */

        pFileObj->nFlags |= _FileOpt_Updated;

        /*
         *  Close the Directory (this will write the BUFFER automatically)
         */

        Fat_FileClose( pFileObj );
    }

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_RemoveDir
 *
 *      Removes a directory from the file system
 *
 *  Parameters:
 *      pFileObj    - Pointer to the file object descriptor
 *      strPath     - Pathname of directory to remove
 *
 *  Returns:
 *      Result of Directory destruction
 *
 *  Notes:
 *      None.
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_RemoveDir(
    PFILE_OBJ pFileObj,
    DEV_STRING strPath
)
{
    DEV_IOSTATUS _nIoStatus;
    PFAT_FILEOBJ _pFatFileObj;
    PFAT_DEVOBJ _pFatDevObj;

    /*
     *  DEBUG
     */

    DEVOBJ_ASSERT( pFileObj != 0 );
    DEVOBJ_ASSERT( strPath != 0 );

    /*
     *  Open the directory
     */

    _nIoStatus = 
        Fat_FileOpen(
            pFileObj,
            strPath,
            FSD_FLAGS( _OPEN_RDONLY, 0 )
        );

    /*
     *  Does the file exist?
     */

    if ( _DEV_IOSTATUS_SUCCEEDED(_nIoStatus) )
    {
        PFAT_DIRENTRY _pDirEntry;

        do
        {
            /*
             *  Open the requested directory
             */

            _pFatFileObj = FAT_FILEOBJ_EXT(pFileObj);

            /*
             *  IDIOT TEST: Validate that this is a directory
             */

            if ( !DirEntry_IsDirectory(&_pFatFileObj->theEntry) )
            {
                _nIoStatus = FSD_IOSTATUS_NOT_DIRECTORY;
                break;
            }

            /*
             *  And make sure it is not the ROOT directory
             */

            if ( _pFatFileObj->theEntry.DIR_Name[0] == DIRENTRY_ROOT )
            {
                _nIoStatus = FSD_IOSTATUS_ACCESS_DENIED;
                break;
            }

            _pFatDevObj = FAT_DEVOBJ_EXT(pFileObj->pDeviceObj);

            /*
             *  Read the FIRST SECTOR of the FILE, i.e. Directory, since
             *  the next test is that the directory is empty (no recursion
             *  supported here)
             */

            _nIoStatus = 
                Fat_ReadSector( 
                    pFileObj->pDeviceObj,
                    pFileObj->pBuffer,
                    FAT_FIRSTSECTOROFCLUSTER(
                        _pFatDevObj,
                        _pFatFileObj->theEntry.DIR_FstClusLO 
                    )
                );
            if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
            {
                break;
            }

            /*
             *  Validate the Directory is empty
             */

            _pDirEntry = (PFAT_DIRENTRY)pFileObj->pBuffer;
            _pDirEntry += 2;
            if ( _pDirEntry->DIR_Name[0] != DIRENTRY_END )
            {
                _nIoStatus = FSD_IOSTATUS_DIRECTORY_NOT_EMPTY;
                break;
            }

            /*
             *  To TRUNCATE, simply set the DELETE FLAG on CLOSE 
             */

            pFileObj->nFlags |= _FileOpt_OpenDelete;
        }
        while (0);

        /*
         *  Close the FILE (Deletes on close if every above ran to 
         *  perfection.
         */

        Fat_FileClose( pFileObj );
    }

    /*
     *  Return the status
     */

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_ReadDir
 *
 *      Reads a Directory Entry, based upon the current Position and places
 *      the FILE NAME into the DIRECT structure passed.
 *
 *  Parameters:
 *      pFileObj    - Pointer to the initialized file object descriptor
 *      pDirect     - Pointer to a Directory structure to fill
 *
 *  Returns:
 *      Returns the result of the Directory Read
 *
 *  Notes:
 *      Implementation for reading directories is safer using this method
 *      than doing byte-wise reads.
 *
 *      The concept of i-numbers, i-list, and i-nodes are not used within
 *      this driver model, but some discussion is needed, since the i-node
 *      number is a field within the DIRECT structure.
 *
 *          IN FAT:
 *
 *              i-node: 
 *                  Is the directory entry for FAT (32 byte struct)
 *
 *              i-list: Is the directory file, which contains a list of
 *                      i-nodes.
 *
 *              i-number:
 *                  The i-number for a file could basically be the ORing of 
 *                  the Cluster Number and the Cluster Offset of the entry.
 *                  This is how it is handled within FAT, but this may not
 *                  be compatible with other Unix interfaces to FAT.
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_ReadDir(
    PFILE_OBJ pFileObj,
    PDIRECT pDirect
)
{
    FAT_DIRENTRY _dirEntry;
    DEV_LONG _nCharsRead;
    DEV_IOSTATUS _nIoStatus;

    /*
     *  DEBUG
     */

    DEVOBJ_ASSERT( pFileObj != 0 );
    DEVOBJ_ASSERT( pDirect != 0 );

    /*
     *  Read the DIRECTORY Entry
     *
     *      Root has to be handled differently for FAT12/16, because it is
     *      at a fixed location and does not abide by the traditional CLUSTER
     *      as other more dynamic directories are.
     */

    _nIoStatus = 
        Fat_FileRead(
            pFileObj, 
            (DEV_PVOID)&_dirEntry, 
            sizeof(FAT_DIRENTRY), 
            &_nCharsRead 
        );

    /*
     *  Read SUCCESS?
     */

    if ( _DEV_IOSTATUS_SUCCEEDED(_nIoStatus) )
    {
        DEV_INT _nIdx;
        DEV_STRING _strName = &( pDirect->d_name[0] );

        do
        {
            /*
             *  End of directory?
             */

            if ( _dirEntry.DIR_Name[0] == DIRENTRY_END )
            {
                _nIoStatus = FSD_IOSTATUS_END_OF_FILE;
                Fat_FileSeek( 
                    pFileObj,
                    -_nCharsRead, 
                    _SEEK_CUR, 
                    &_nCharsRead 
                );
                break;
            }

            /* 
             *  Free Entry? Return as a valid entry, but still exit
             */

            if ( _dirEntry.DIR_Name[0] == DIRENTRY_FREE )
            {
                pDirect->d_name[0] = DEVOBJ_EOS;
                pDirect->d_ino = 0;

                break;
            }

            /*
             *  INODE numbers calculated here is the ORing of the Cluster and
             *  Offset of the directory entry.
             */

            else
            {
                pDirect->d_ino = 
                    Fat_GetINumber(
                        FAT_DEVOBJ_EXT(pFileObj->pDeviceObj),
                        FAT_FILEOBJ_EXT(pFileObj)
                    );
            }

            /*
             *  To expedite there is no reason to Unpack since the character 
             *  string is not affected by byte order.
             */

            for ( _nIdx = 0; _nIdx < DIRENTRY_NAMELEN; _nIdx++ )
            {
                if ( _dirEntry.DIR_Name[_nIdx] == ' ' )
                {
                    break;
                }

                *_strName++ = _dirEntry.DIR_Name[_nIdx];
            }

            /*
             *  Add the extension delimeter (we may remove it later)
             */

            *_strName++ = '.';

            /*
             *  Skip to the Extension
             */

            for ( _nIdx = DIRENTRY_NAMELEN; _nIdx < DIRENTRY_FULLNAMELEN; _nIdx++ )
            {
                if ( _dirEntry.DIR_Name[_nIdx] == ' ' )
                {
                    _strName--;
                    break;
                }

                *_strName++ =  _dirEntry.DIR_Name[_nIdx];
            }

            *_strName = DEVOBJ_EOS;
        }
        while (0);
    }

    /*
     *  Return the result
     */

    return _nIoStatus;
}

/* 
 *  End of fat_dir.c
 */

