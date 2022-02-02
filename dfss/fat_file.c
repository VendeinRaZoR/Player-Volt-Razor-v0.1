
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
 *  fat_file.c
 *
 *      These are the operations specific to FILE operations. A Directory
 *      is a special file and is also accessed indirectly when making calls
 *      to create or remove directories.
 */

#define _FAT_INCLUDE_CORE
#include "fat.h"

/* --------------------------------------------------------------------------
 *
 *  Exceptions Specific to FILE
 *
 * --------------------------------------------------------------------------------
 */

BEGIN_EXCEPTION_TABLE(Exception_File)

    Exception_File_Write,
    Exception_File_Read,
    Exception_File_Fat

END_EXCEPTION_TABLE(Exception_File)

/* --------------------------------------------------------------------------
 *
 *  Fat_RootReadNextSector
 *
 *      Performs a Fault-Tolerant method of Reading the next Sector in the
 *      ROOT Directory.
 *
 *  Parameters:
 *      pFileObj    - Pointer to the current File Object
 *
 *  Returns:
 *      Result of the READ, typical failures occur if trying to read beyond
 *      the end of the ROOT directory.
 *
 *  Notes:
 *      Unfortunately the ROOT directory does not allocate itself on
 *      clusters in FAT12 and FAT16. FAT32 is different as the ROOT is not
 *      at a fixed location beyond the FAT.
 *
 *      nCluster is used to store the current sector of the ROOT directory.
 *
 * --------------------------------------------------------------------------
 */

static
DEV_IOSTATUS Fat_RootReadNextSector(
    PFILE_OBJ pFileObj
)
{
    DEV_IOSTATUS _nIoStatus;

    do
    {
        DEV_UINT32 _nFirstDataSector =
            (DEV_UINT32)FAT_FIRSTDATASECTOR(
                FAT_DEVOBJ_EXT(pFileObj->pDeviceObj)
            );

        /*
         *  Cache the NEXT Sector
         */

        if ( ++( FAT_FILEOBJ_EXT(pFileObj)->nSector ) >= _nFirstDataSector )
        {
            break;
        }

        _nIoStatus =
            Fat_ReadSector(
                pFileObj->pDeviceObj,
                pFileObj->pBuffer,
                FAT_FILEOBJ_EXT(pFileObj)->nSector
            );

        /*
         *  On READ Failures, QUIT Immediately
         */

        if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
        {
            break;
        }

        FAT_FILEOBJ_EXT(pFileObj)->nOffset = 0;
    }
    while (0);

    /*
     *  Return the result
     */

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_FileReadNextSector
 *
 *      Performs a Fault-Tolerant method of Reading the next Sector in the
 *      Data Region for an OPEN file.
 *
 *  Parameters:
 *      pFileObj    - Pointer to the current File Object
 *
 *  Returns:
 *      Result of the READ.
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

static
DEV_IOSTATUS Fat_FileReadNextSector(
    PFILE_OBJ pFileObj
)
{
    DEV_IOSTATUS _nIoStatus = FSD_IOSTATUS_SUCCESS;

    PFAT_FILEOBJ _pFatFileObj = FAT_FILEOBJ_EXT(pFileObj);
    PFAT_DEVOBJ _pFatDevObj = FAT_DEVOBJ_EXT(pFileObj->pDeviceObj);

    /*
     *  Next Sector (reset the OFFSET)
     */

    _pFatFileObj->nOffset = 0;

    do
    {
        DEV_UINT32 _nNextSector;

        if ( ++(_pFatFileObj->nSector) == 
                _pFatDevObj->FAT_BootSector.BPB_SecPerClus )
        {
            DEV_UINT32  _nNextClusterIdx;

            /*
             *  Cache the NEXT Cluster
             */

            _nIoStatus =
                Fat_GetClusterEntry(
                    pFileObj->pDeviceObj,
                    FAT_FILEOBJ_EXT(pFileObj)->nCluster,
                    &_nNextClusterIdx
                );

            /*
             *  End of File or other error (EOF can occur on files that end
             *  on a Cluster Boundary)?
             */

            if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
            {
                break;
            }

            if ( _nNextClusterIdx >= FAT_EOF(_pFatDevObj) )
            {
                _nIoStatus = FSD_IOSTATUS_END_OF_FILE;
                break;
            }

            _pFatFileObj->nCluster = _nNextClusterIdx;
            _pFatFileObj->nSector = 0;

            /*
             *  Absolute Sector
             */

            _nNextSector = 
                FAT_FIRSTSECTOROFCLUSTER(_pFatDevObj,_nNextClusterIdx);
        }

        /*
         *  Calculate the NEXT Sector
         */

        else
        {
            _nNextSector = 
                FAT_FIRSTSECTOROFCLUSTER(_pFatDevObj,_pFatFileObj->nCluster);
            _nNextSector += _pFatFileObj->nSector;
        }

        /*
         *  Read the NEXT Sector
         */

        _nIoStatus =
            Fat_ReadSector(
                pFileObj->pDeviceObj,
                pFileObj->pBuffer,
                _nNextSector
        );

    }
    while(0);

    /*
     *  Return the read result
     */

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_ParseFileName
 *
 *      Extracts the filename portion from the path
 *
 *  Parameters:
 *      strPath         - Fully qualified path (including file name)
 *
 *  Returns:
 *      Returns the pointer to the Filename in the string.
 *
 *  Notes:
 *      None
 * --------------------------------------------------------------------------
 */

static
DEV_STRING Fat_ParseFileName( DEV_STRING strPath )
{
    DEV_STRING _strFilename = &strPath[DEVOBJ_STRLEN( strPath )];

    while ( _strFilename != strPath )
    {
        --_strFilename;
        if ( *_strFilename == _PATH_DELIMITER[0] )
        {
            *_strFilename = DEVOBJ_EOS;
            *_strFilename++;

            break;
        }
    }

    return _strFilename;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_TruncateFile
 *
 *      Truncates the cluster chain on the file, freeing up all the clusters
 *      with exception to the last one. That task should be left when the
 *      file is closed.
 *
 *  Parameters:
 *      pFileObj    - Pointer to the file object
 *
 *  Returns:
 *      Returns the result.
 *
 *  Notes:
 *      None
 * --------------------------------------------------------------------------
 */

static
DEV_IOSTATUS Fat_TruncateFile( PFILE_OBJ pFileObj )
{
    DEV_UINT32 _nNextClusterIdx;
    DEV_IOSTATUS _nIoStatus = FSD_IOSTATUS_SUCCESS;

    PFAT_FILEOBJ _pFatFileObj = FAT_FILEOBJ_EXT(pFileObj);
    PFAT_DEVOBJ _pFatDevObj = FAT_DEVOBJ_EXT(pFileObj->pDeviceObj);

    /*
     *  For a zero length file we are already truncated.
     */

    if ( _pFatFileObj->theEntry.DIR_FstClusLO != _pFatDevObj->FAT_Eof )
    {
        /*
         *  Start the Exception Block
         */

        _TRY
        {
            /*
             *  Get the first one and save (Gets only fail if the
             *  Set fails due to caching)
             */

            _nIoStatus =
                Fat_GetClusterEntry(
                    pFileObj->pDeviceObj,
                    _pFatFileObj->theEntry.DIR_FstClusLO,
                    &_nNextClusterIdx
                );
            if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
            {
                _THROW(File_Exception);
            }

            /*
             *  Walk the chain releasing the links
             */

            while ( _nNextClusterIdx < _pFatDevObj->FAT_Eof )
            {
                _pFatFileObj->nCluster = _nNextClusterIdx;

                /*
                 *  Get the ENTRY
                 */

                _nIoStatus =
                    Fat_GetClusterEntry(
                        pFileObj->pDeviceObj,
                        _pFatFileObj->nCluster,
                        &_nNextClusterIdx
                    );

                if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
                {
                    _THROW(File_Exception);
                }

                /*
                 *  Free the Entry
                 */

                _nIoStatus =
                    Fat_ReleaseCluster(
                        pFileObj->pDeviceObj,
                        _pFatFileObj->nCluster
                    );
                if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
                {
                    _THROW(File_Exception);
                }

            }

            /*
             *  File is now empty
             */

            _pFatFileObj->theEntry.DIR_FileSize = 0L;
            _pFatFileObj->nCluster = _pFatFileObj->theEntry.DIR_FstClusLO;
        }
        _CATCH(File_Exception)
        {
            /*
             *  The CLUSTER chain is bad now FILE Is now INVALID
             */
        }
        _END_CATCH
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
 * --------------------------------------------------------------------------------
 */

/* --------------------------------------------------------------------------
 *
 *  Fat_FileWriteSector
 *
 *      Performs a Fault-Tolerant method of Writing a single Sector
 *
 *  Parameters:
 *      pFileObj    - Pointer to the current File Object
 *      nSector     - Sector Number to write
 *
 *  Returns:
 *      Either success OR failure. FAILURES will only occur, if there are
 *      no more FREE Clusters in existence on the volume.
 *
 *  Notes:
 *      The handling for a bad WRITE is different for a Sector than a 
 *      Cluster, since 
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_FileWriteSector(
    PFILE_OBJ pFileObj
)
{
    DEV_IOSTATUS _nIoStatus;
    PFAT_FILEOBJ _pFatFileObj = FAT_FILEOBJ_EXT(pFileObj);
    PFAT_DEVOBJ _pFatDevObj = FAT_DEVOBJ_EXT(pFileObj->pDeviceObj);

    DEV_UINT32 _nSector = 
        FAT_FIRSTSECTOROFCLUSTER( _pFatDevObj, _pFatFileObj->nCluster ) +
            _pFatFileObj->nSector;

    /*
     *  Write the buffered Sector
     */

    _nIoStatus =
        Fat_WriteSector(
            pFileObj->pDeviceObj,
            pFileObj->pBuffer,
            _nSector
        );

    /*
     *  Was there a failure on the Sector Write?
     */

    if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
    {
        DEV_UINT32 _nNewClusterIdx;
        DEV_UINT32 _nPrevClusterIdx;
        DEV_UINT32 _nNextClusterIdx = _pFatFileObj->nCluster;

        /*
         *  To insert a new cluster in the chain, need to find the 
         *  previous one. To do this the CHAIN must be walked from the
         *  beginning.
         */

        _nNextClusterIdx = _pFatFileObj->theEntry.DIR_FstClusLO;

        /*
         *  Find the Previous Cluster (Next cluster will be equal to the
         *  current cluster).
         */

        while ( _nNextClusterIdx != _pFatFileObj->nCluster )
        {
            _nPrevClusterIdx = _nNextClusterIdx;

            Fat_GetClusterEntry(
                pFileObj->pDeviceObj,
                _nPrevClusterIdx,
                &_nNextClusterIdx
            );
        }

        /*
         *  Get the NEXT one (now the Previous and Next Clusters are
         *  cached)
         */

        Fat_GetClusterEntry(
            pFileObj->pDeviceObj,
            _pFatFileObj->nCluster,
            &_nNextClusterIdx
        );

        _nNewClusterIdx = _pFatFileObj->nCluster;

        /*
         *  Continue until a SUCCESSFUL Write or an unrecoverable error
         *  occurs.
         *
         *      Upon entering the LOOP, the Previous and Next cluster(s)
         *      are known. Actually if the first cluster in the chain is
         *      the bad cluster, then only the NEXT cluster is known and
         *      the previous is set to "0".
         */

        while (1)
        {
            DEV_UINT16 _nOffset;
            DEV_UINT32 _nNewSector;

            /*
             *  Error Handling
             */

            _TRY
            {
                /*
                 *  Invalidate the CLUSTER
                 *
                 *      DO NOT update the nCluster field of the FAT File Object
                 *      because until a successful write occurs, this field is 
                 *      not updated.
                 */

                _nIoStatus = 
                    Fat_InvalidateCluster(
                        pFileObj->pDeviceObj,
                        _nNewClusterIdx,
                        _nIoStatus
                    );
                if ( _DEV_IOSTATUS_FAILED( _nIoStatus ) ) 
                {
                    _THROW(Exception_File_Fat);
                }

                /*
                 *  Get a FREE Cluster
                 */

                _nIoStatus =
                    Fat_FindNextFreeCluster(
                        pFileObj->pDeviceObj,
                        &_nNewClusterIdx
                    );

                /*
                 *  NO MORE Free Clusters???
                 */

                if ( _DEV_IOSTATUS_FAILED( _nIoStatus )  )
                {
                    _THROW(File_Exception);
                }

                /*
                 *  Write the CONTENTS of the Cached Sector first since data
                 *  may have changed and the contents within are not the same
                 *  as though currently in the old Sector.
                 */

                _nNewSector = 
                    FAT_FIRSTSECTOROFCLUSTER(_pFatDevObj,_nNewClusterIdx) + 
                        _pFatFileObj->nOffset;

                _nIoStatus =
                    Fat_WriteSector(
                        pFileObj->pDeviceObj,
                        pFileObj->pBuffer,
                        _nNewSector
                    );

                /*
                 *  If it fails, no need to THROW an exception as nothing 
                 *  changed statistically, so find another cluster
                 */

                if (  _DEV_IOSTATUS_FAILED(_nIoStatus) )
                {
                    continue;
                }

                /*
                 *  Now the SECTORS prior to and After the Sector that the 
                 *  Fault occurred on must be updated.
                 *
                 *      Update the Actual Sector by the Offset into the 
                 *      cluster for both the new and old entries.
                 */

                _nNewSector -= _pFatFileObj->nOffset;
                _nSector -= _pFatFileObj->nOffset;

                for ( 
                    _nOffset = 0; 
                    _nOffset < _pFatFileObj->nOffset; 
                    _nOffset++ )
                {
                    Fat_ReadSector( 
                        pFileObj->pDeviceObj,
                        pFileObj->pBuffer,
                        _nSector++
                    );

                    _nIoStatus = 
                        Fat_WriteSector(
                            pFileObj->pDeviceObj,
                            pFileObj->pBuffer,
                            _nNewSector++
                        );

                    if (  _DEV_IOSTATUS_FAILED(_nIoStatus) )
                    {
                        _THROW(File_Exception);
                    }
                }

                while ( ++_nOffset < 
                    _pFatDevObj->FAT_BootSector.BPB_SecPerClus )
                {
                    Fat_ReadSector( 
                        pFileObj->pDeviceObj,
                        pFileObj->pBuffer,
                        ++_nSector
                    );

                    _nIoStatus = Fat_WriteSector(
                        pFileObj->pDeviceObj,
                        pFileObj->pBuffer,
                        ++_nNewSector
                    );

                    if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
                    {
                        _THROW(File_Exception);
                    }
                }

                /* 
                 *  If loop gets here, then success on MOVE of cluster
                 */

                break;
            }

            /*
             *  Exception on Writing FILE...Reset and FIND a new Cluster
             */

            _CATCH(File_Exception)
            {
                _nSector = 
                    FAT_FIRSTSECTOROFCLUSTER(
                        _pFatDevObj,
                        _pFatFileObj->nCluster
                    ) + _pFatFileObj->nOffset;

                Fat_ReadSector(
                    pFileObj->pDeviceObj,
                    pFileObj->pBuffer,
                    _nSector
                );
            }

            /*
             * BAD Error, FAT Cannot be updated
             */

            _AND_CATCH(Exception_File_Fat)
            {
                break;
            }
            _END_CATCH
        }

        /* 
         *  OK, now the PREVIOUS Entry can point to the new 
         */

        _nIoStatus =
            Fat_SetClusterEntry(
                pFileObj->pDeviceObj,
                _nNewClusterIdx,
                _nNextClusterIdx
            );

        if ( _DEV_IOSTATUS_FAILED( _nIoStatus ) )
        {
            // _THROW(File_Exception);
        }

        /*
         *  Was the FIRST Cluster the Bad one?
         */

        if ( _pFatFileObj->nCluster == _pFatFileObj->theEntry.DIR_FstClusLO )
        {
            _pFatFileObj->theEntry.DIR_FstClusLO = (DEV_UINT16)_nNewClusterIdx;
        }

        /*
         *  Ok, it's in the chain and the previous cluster is known here
         */

        else
        {
            _nIoStatus =
                Fat_SetClusterEntry(
                    pFileObj->pDeviceObj,
                    _nPrevClusterIdx,
                    _nNewClusterIdx
                );

            if ( _DEV_IOSTATUS_FAILED( _nIoStatus ) )
            {
                // _THROW(File_Exception);
            }
        }

        /*
         *  Now ASSIGN the Cluster
         */

        _pFatFileObj->nCluster = _nNewClusterIdx;
    }

    /*
     *  Result is typically a success CODE, unless there are no more FREE
     *  Clusters
     */

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_FileOpen
 *
 *      This function creates, opens, or truncates a file. It fills in the
 *      passed Object Pointer specific for the file that is used to access
 *      the file while it is open. It can also open and return a handle to
 *      a directory.
 *
 *  Parameters:
 *      pDevObj         - Pointer to Device Object to open the file on
 *      strPath         - File to Open (path inclusive)
 *      nFlags          - Flags and Attributes (if creating) for the file
 *      ppFileObj       - Pointer to the File Object for this FILE
 *
 *  Returns:
 *      Returns a valid FILE Object and a Success status, otherwise the
 *      status will indicate the error encountered.
 *
 *  Notes:
 *      None
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_FileOpen(
    PFILE_OBJ pFileObj,
    DEV_STRING strPath,
    DEV_ULONG nFlags
)
{
    DEV_IOSTATUS _nIoStatus;
    DEV_STRING _strFilename;

    DEV_UINT _fOpen;

    /*
     *  Extract the "_OPEN" FLAGS
     */

    _fOpen = FSD_OFLAGS( nFlags );
    _strFilename = Fat_ParseFileName( strPath );

    /*
     *  Validate the FILE and OPEN accordingly
     */

    _TRY
    {
        PFAT_FILEOBJ _pFatFileObj;
        PFAT_DEVOBJ _pFatDevObj = FAT_DEVOBJ_EXT(pFileObj->pDeviceObj);

        /*
         *  Create the SECTOR Cache for the FILE.
         */

        pFileObj->nBufferLen = _pFatDevObj->FAT_BootSector.BPB_BytesPerSec;
        pFileObj->pBuffer = (DEV_UCHAR*)DEVOBJ_MALLOC( pFileObj->nBufferLen );
        if ( pFileObj->pBuffer == 0 )
        {
            _THROW(Exception_Memory);
        }

        /*
         *  Create the FAT-specific Extension area for the File Descriptor
         *  or Object.
         */

        pFileObj->pFileExt = DEVOBJ_MALLOC( sizeof(FAT_FILEOBJ) );
        if ( pFileObj->pFileExt == 0 )
        {
            _THROW(Exception_Memory);
        }
        _pFatFileObj = FAT_FILEOBJ_EXT(pFileObj);

        /*
         *  Need to NULL out the Path...the path will still verify even though
         *  it's the root, but the Pathwalk function will fill the structure
         *  for us.
         *
         *  Is this a request to open a file in the root?
         */

        if ( _strFilename == strPath )
        {
            _strFilename = &_strFilename[DEVOBJ_STRLEN(strPath)];
        }

        /*
         *  Validate the Path
         */

        _nIoStatus = Fat_DirPathWalk( pFileObj, strPath );
        if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
        {
            _THROW(Exception_File);
        }

        /*
         *  Positional Information and Flags
         */

        _pFatFileObj->nOffset = pFileObj->nPos = pFileObj->nFlags = 0;

        /*
         *  OK, now to verify the FILENAME in the Directory
         */

        _nIoStatus = Fat_DirFindEntry( pFileObj, _strFilename );

        /*
         *  CREATION FLAGS (was the FILE NOT FOUND)?
         */

        if ( _DEV_IOSTATUS_FAILED( _nIoStatus ) )
        {
            if ( _nIoStatus == FSD_IOSTATUS_FILE_NOT_FOUND )
            {
                /*
                 *  Is a new file being created?
                 */

                if ( !(_fOpen & _OPEN_CREAT) )
                {
                    _THROW(Exception_File);
                }

                /*
                 *  The FILE is being created, finish initializing the
                 *  structure (remember, the name is already part of this
                 *  as it's copied into the structure during a FIND of it).
                 */

                _nIoStatus = Fat_DirCreateEntry( pFileObj );
                if ( _DEV_IOSTATUS_FAILED( _nIoStatus ) )
                {
                    _THROW(Exception_File);
                }

                /*
                 *  Initialize Cluster
                 */

                _pFatFileObj->theEntry.DIR_FstClusLO =
                                        (DEV_UINT16)FAT_EOF(_pFatDevObj);
            }

            /*
             *  All other errors need to ABORT HERE
             */

            else
            {
                _THROW(Exception_File);
            }
        }

        /*
         *  File Already Exist?
         */

        else
        {
            /*
             *  Fails if a CREATE was implemented, but the FILE EXCLUSIVE
             */

            if ( ( _fOpen & _OPEN_CREAT ) && ( _fOpen & _OPEN_EXCL ) )
            {
                _nIoStatus = FSD_IOSTATUS_FILE_EXISTS;
                _THROW(Exception_File);
            }

        }

        /*
         *  Sector and Cluster offset
         */

        _pFatFileObj->nCluster = 
            (DEV_UINT32)_pFatFileObj->theEntry.DIR_FstClusLO;
        _pFatFileObj->nSector = 0;

        /*
         *  Regular File?
         */

        if ( !DirEntry_IsDirectory(&_pFatFileObj->theEntry) )
        {
            /*
             *  Schedule the FILE for deletion? FORCE TRUNCATE OPTION
             */

            if ( _fOpen & _OPEN_DELETE )
            {
                pFileObj->nFlags = _FileOpt_OpenDelete;
            }

            /*
             *  FOR FILES NOT OPENED AS READ ONLYS, it can be opened and
             *  truncated or append to the end. If opened as TRUNCATE the
             *  APPEND option is ignored (think hard about that one).
             *
             *  For a FILE Of ZERO LENGTH, doing either of these is useless and
             *  not allowed for directories.
             *
             */

            if ( _fOpen & (_OPEN_WRONLY | _OPEN_RDWR) )
            {
                /*
                 *  File Empty?
                 */

                if (  _pFatFileObj->nCluster == FAT_EOF(_pFatDevObj) )
                {
                    /*
                     *  Preallocate a cluster
                     */

                    _nIoStatus =
                        Fat_FindNextFreeCluster(
                            pFileObj->pDeviceObj,
                            &_pFatFileObj->nCluster
                        );
                    if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
                    {
                        _THROW(Exception_File);
                    }

                    /*
                     *  A cluster was successfully allocated
                     */

                    _nIoStatus =
                        Fat_SetClusterEntry(
                            pFileObj->pDeviceObj,
                            _pFatFileObj->nCluster,
                            FAT_EOF(_pFatDevObj)
                        );
                    if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
                    {
                        _THROW(Exception_File);
                    }

                    /*
                     *  Assign start cluster
                     */

                    _pFatFileObj->theEntry.DIR_FstClusLO =
                                    (DEV_UINT16)_pFatFileObj->nCluster;
                }

                /*
                 *  Truncate the FILE on open?
                 *
                 *      Free the Cluster Chain, then set the first cluster
                 *      entry to EOF.
                 */

                else if ( _fOpen & _OPEN_TRUNC )
                {
                    Fat_TruncateFile( pFileObj );
                    _nIoStatus =
                        Fat_SetClusterEntry(
                            pFileObj->pDeviceObj,
                            _pFatFileObj->theEntry.DIR_FstClusLO,
                            FAT_EOF(_pFatDevObj)
                        );
                    if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
                    {
                        _THROW(Exception_File);
                    }
                }

                /*
                 *  Appending to the End of File?
                 */

                else if ( _fOpen & _OPEN_APPEND )
                {
                    DEV_UINT32 _nNextClusterIdx;

                    /*
                     *  Walk the chain
                     */

                    while ( 1 )
                    {
                        Fat_GetClusterEntry(
                            pFileObj->pDeviceObj,
                            _pFatFileObj->nCluster,
                                &_nNextClusterIdx
                        );

                        if ( _nNextClusterIdx >= FAT_EOF(_pFatDevObj) )
                        {
                            break;
                        }

                        _pFatFileObj->nCluster = _nNextClusterIdx;
                    }

                    /*
                     *  Now determine the Offsets within the Cluster
                     *
                     *      The quickest and most efficient way to perform
                     *      this is to get the number of bytes leftover in
                     *      the cluster. Then divide this out to get the 
                     *      Sector offset, then modulo itself to get the
                     *      offset within the sector.
                     */

                    _pFatFileObj->nOffset =
                        DEVOBJ_REM(
                            _pFatFileObj->theEntry.DIR_FileSize,
                            FAT_BYTESPERCLUSTER(_pFatDevObj)
                        );

                    _pFatFileObj->nSector = 
                        _pFatFileObj->nOffset / 
                            _pFatDevObj->FAT_BootSector.BPB_BytesPerSec;
                    _pFatFileObj->nOffset = 
                        DEVOBJ_REM(
                            _pFatFileObj->theEntry.DIR_FileSize,
                            _pFatDevObj->FAT_BootSector.BPB_BytesPerSec
                        );

                    pFileObj->nPos = _pFatFileObj->theEntry.DIR_FileSize;
                }
            }

            /*
             *  Set the Status FLAGS (Directories can only be opened as READ
             *  except when creating them and typically the DIR flag is not
             *  set until after the Directory is created, since it's nothing
             *  more than a special file type.
             */

            if ( _fOpen & _OPEN_RDWR )
            {
                pFileObj->nFlags |= ( _FileOpt_OpenWrite | _FileOpt_OpenRead );
            }
            else if ( _fOpen & _OPEN_WRONLY )
            {
                pFileObj->nFlags |= _FileOpt_OpenWrite;
            }
            else
            {
                pFileObj->nFlags |= _FileOpt_OpenRead;
            }
        }

        /*
         *  Directories can only be OPEN'd as READ
         */

        else
        {
            pFileObj->nFlags |= _FileOpt_Directory | _FileOpt_OpenRead;

            /*
             *  Once again a snakebite...the ROOT DIRECTORY in Microsoft's
             *  ingenious scheme of File Management. The Cluster is interpreted
             *  as the Sector for reading of the ROOT Directory
             */

            if ( _pFatFileObj->theEntry.DIR_Name[0] == DIRENTRY_ROOT )
            {
                _pFatFileObj->nSector = _pFatFileObj->nCluster;

                Fat_ReadSector(
                    pFileObj->pDeviceObj,
                    pFileObj->pBuffer,
                    _pFatFileObj->nCluster
                );
                _THROW_NONE();
            }
        }

        /*
         *  Cache the Sector (if there is a CLUSTER to Cache)
         */

        if ( _pFatFileObj->nCluster != FAT_EOF(_pFatDevObj) )
        {
            Fat_ReadSector(
                pFileObj->pDeviceObj,
                pFileObj->pBuffer,
                 (FAT_FIRSTSECTOROFCLUSTER(_pFatDevObj,_pFatFileObj->nCluster) +
                    _pFatFileObj->nSector)
            );
        }
    }
    _AND_CATCH(Exception_Memory)
    {
        if ( pFileObj->pBuffer != 0 ) { DEVOBJ_FREE( pFileObj->pBuffer ); }
        _nIoStatus = FSD_IOSTATUS_OUT_OF_MEMORY;
    }
    _AND_CATCH(Exception_File)
    {
        DEVOBJ_FREE( FAT_FILEOBJ_EXT(pFileObj) );
        DEVOBJ_FREE( pFileObj->pBuffer );
    }
    _END_CATCH

    /*
     *  Restore the FILENAME
     */

    if ( _strFilename != strPath )
    {
        *(_strFilename - 1) = _PATH_DELIMITER[0];
    }

    /*
     *  Return the STATUS
     */

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_FileClose
 *
 *
 *
 *  Parameters:
 *      pFileObj        - Point to the File Object for this FILE
 *
 *  Returns:
 *      Returns result of Open.
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_FileClose(
    PFILE_OBJ pFileObj
)
{
    DEV_IOSTATUS _nIoStatus = FSD_IOSTATUS_SUCCESS;
    PFAT_FILEOBJ _pFatFileObj;
    PFAT_DEVOBJ _pFatDevObj;

    DEVOBJ_ASSERT( pFileObj != 0 );

    _pFatFileObj = FAT_FILEOBJ_EXT(pFileObj);
    _pFatDevObj = FAT_DEVOBJ_EXT(pFileObj->pDeviceObj);

    /*
     *  Always test for delete first
     */

    if ( File_DeleteOnClose(pFileObj) )
    {
        /*
         *  Special test as we don't want to go through this nonsense if the
         *  pointer to the FILE is EOF (prevents some major malfunctions from
         *  occurring).
         */

        if ( _pFatFileObj->theEntry.DIR_FstClusLO != FAT_EOF(_pFatDevObj) )
        {
            /*
             *  Truncate the FILE, then release the first cluster (Truncate
             *  does not perform this test)
             */

            _nIoStatus = Fat_TruncateFile(pFileObj);

            Fat_ReleaseCluster(
                pFileObj->pDeviceObj,
                _pFatFileObj->theEntry.DIR_FstClusLO
            );

        }

        /*
         *  Remove the directory entry
         */

        _nIoStatus = Fat_DirRemoveEntry(pFileObj);
    }

    /*
     *  FLUSH Buffers and UPDATE Size
     */

    else if ( File_IsWritable( pFileObj ) )
    {
        /*
         *  File Sizes of ZERO occupy no space, other than their 32 byte entry
         *  in the Directory Table, UNLESS of course this is a Directory, then
         *  ignore this - YOU think Microsoft would have come up with a better
         *  scheme, but then again who knows how much beer they were drinking
         *  that night!
         */

        if ( _pFatFileObj->theEntry.DIR_FileSize == 0 &&
            !( _pFatFileObj->theEntry.DIR_Attr & FAT_ATTR_DIRECTORY ) )
        {
            /*
             *  Clear out the Cluster Entry
             */

            _nIoStatus =
                Fat_ReleaseCluster(
                    pFileObj->pDeviceObj,
                    _pFatFileObj->theEntry.DIR_FstClusLO
                );

            _pFatFileObj->theEntry.DIR_FstClusLO =
                (DEV_UINT16)FAT_EOF(_pFatDevObj);
        }

        /*
         *  Commit this buffer?
         */

        else if ( pFileObj->nFlags & _FileOpt_Updated )
        {
            /*
             *  Flush and Write
             */

            _nIoStatus = Fat_FileWriteSector( pFileObj );
        }

        /*
         *  Update the Entry
         */

        _nIoStatus = Fat_DirUpdateEntry( pFileObj );
    }

    /*
     *  Release the Objects from Memory
     */

    DEVOBJ_FREE( _pFatFileObj );
    DEVOBJ_FREE( pFileObj->pBuffer );

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_FileRead
 *
 *
 *
 *  Parameters:
 *      pFileObj        - Point to the File Object for this FILE
 *
 *  Returns:
 *      Returns result of Open.
 *
 *  Notes:
 *
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_FileRead(
    PFILE_OBJ pFileObj,
    DEV_PVOID pBuffer,
    DEV_LONG nCharsToRead,
    DEV_LONG* pnCharsRead
)
{
    DEV_IOSTATUS _nIoStatus;
    DEV_LONG _nCharsLeft;

    PFAT_FILEOBJ _pFatFileObj;
    PFAT_DEVOBJ _pFatDevObj;

    DEV_IOSTATUS (*_pfnReadNext)(PFILE_OBJ);

    _pFatFileObj = FAT_FILEOBJ_EXT(pFileObj);
    _pFatDevObj = FAT_DEVOBJ_EXT(pFileObj->pDeviceObj);

    *pnCharsRead = 0;

    /*
     *  Boundary Conditions
     */

    if ( !File_IsReadable(pFileObj) )
    {
        return FSD_IOSTATUS_ACCESS_DENIED;
    }

    /*
     *  Accessing the ROOT is performed slightly differently than accessing
     *  the Data Region
     */

    _pfnReadNext = Fat_FileReadNextSector;

    /*
     *  This is determine the number of CHARS left to read
     */

    _nCharsLeft =
        (DEV_LONG)( _pFatFileObj->theEntry.DIR_FileSize - pFileObj->nPos );
    if ( _nCharsLeft <= 0 )
    {
        if ( !File_IsDirectory( pFileObj ) )
        {
            return FSD_IOSTATUS_END_OF_FILE;
        }

        /*
         *  ROOT Directories must be read a bit differently
         */

        if ( _pFatFileObj->theEntry.DIR_Name[0] == DIRENTRY_ROOT )
        {
            _pfnReadNext = Fat_RootReadNextSector;
        }

        /*
         *  Directories are managed a bit differently
         */

        _nCharsLeft = nCharsToRead;
    }

    /*
     *  The number left to READ may need altering
     *
     *      How much more of the file is left until EOF? If this test does
     *      pass, then NO Error is returned, but the return count will not
     *      match the actual number requested. Basically the read is a
     *      Success, it's just the End of File was reached, in which case
     *      the caller can test for that condition.
     */

    if ( nCharsToRead > _nCharsLeft )
    {
        nCharsToRead = _nCharsLeft;
    }

    /*
     *  Begin the READ
     */

    do
    {
        /*
         *  Characters currently buffered
         */

        _nCharsLeft = pFileObj->nBufferLen - _pFatFileObj->nOffset;

        /*
         *  Is read past the end of the buffer? No need to test for End of
         *  File since that test was already performed and the request
         *  altered, thus preventing such an occurrence.
         */

        if ( nCharsToRead < _nCharsLeft )
        {
            DEVOBJ_MEMCPY(
                pBuffer,
                &( pFileObj->pBuffer[_pFatFileObj->nOffset] ),
                nCharsToRead
            );

            *pnCharsRead += nCharsToRead;
            _pFatFileObj->nOffset += nCharsToRead;
            pFileObj->nPos += nCharsToRead;

            nCharsToRead = 0;
            _nIoStatus = FSD_IOSTATUS_SUCCESS;
        }

        /*
         *  Adjust and get next Sector/Cluster?
         */

        else
        {
            DEVOBJ_MEMCPY(
                pBuffer,
                &( pFileObj->pBuffer[_pFatFileObj->nOffset] ),
                _nCharsLeft
            );

            /*
             *  Sanity CHECK to see if this buffer was changed and if so
             *  it needs to be committed.
             */

            if ( pFileObj->nFlags & _FileOpt_Updated )
            {
                _nIoStatus = Fat_FileWriteSector( pFileObj );
                if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
                {
                    break;
                }

                pFileObj->nFlags &= (~_FileOpt_Updated);
            }

            /*
             *  Update Counter Information
             */

            *pnCharsRead += _nCharsLeft;
            pFileObj->nPos += _nCharsLeft;
            nCharsToRead -= _nCharsLeft;
            pBuffer = (DEV_PVOID)( (DEV_USTRING)pBuffer + _nCharsLeft );

            _nIoStatus = (*_pfnReadNext)( pFileObj );
        }
    }
    while ( nCharsToRead > 0 );

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_FileWrite
 *
 *      Writes date out to the FILE described by the File Object. Writes are
 *      buffered and therefore no physical write to the device is required
 *      unless the WRITE exceeds the buffer limits (a write beyond the end
 *      of buffer). With this mechanism in place a user can pass in large
 *      buffers of data to write.
 *
 *  Parameters:
 *      pFileObj        - Point to the File Object for this FILE
 *      pBuffer         - Pointer to buffer with data to write from
 *      nCharsToWrite   - Number of bytes to write
 *      pnCharsWritten  - Number of bytes written
 *
 *  Returns:
 *      Returns result of the WRITE (A Critical Write Failure may mean a
 *      corrupted volume).
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_FileWrite(
    PFILE_OBJ pFileObj,
    DEV_PVOID pBuffer,
    DEV_LONG nCharsToWrite,
    DEV_LONG* pnCharsWritten
)
{
    DEV_IOSTATUS _nIoStatus;
    PFAT_FILEOBJ _pFatFileObj;
    PFAT_DEVOBJ _pFatDevObj;

    _pFatFileObj = FAT_FILEOBJ_EXT(pFileObj);
    _pFatDevObj = FAT_DEVOBJ_EXT(pFileObj->pDeviceObj);

    /*
     *  Writable?
     */

    if ( !File_IsWritable(pFileObj) )
    {
        return FSD_IOSTATUS_ACCESS_DENIED;
    }

    /*
     *  Ok, a buffering scheme is used and ONLY write out to the device IF
     *  and ONLY IF, the end of Buffer is exceeded.
     */

    *pnCharsWritten = 0;

    do
    {
        DEV_INT _nCharsLeft = pFileObj->nBufferLen - _pFatFileObj->nOffset;

        /*
         *  Still room in buffer to complete write?
         */

        if ( nCharsToWrite < _nCharsLeft )
        {
            DEVOBJ_MEMCPY(
                &( pFileObj->pBuffer[_pFatFileObj->nOffset] ),
                pBuffer,
                nCharsToWrite
            );

            /*
             *  Update file pointer and write statistics
             */

            pFileObj->nFlags |= _FileOpt_Updated;
            *pnCharsWritten += nCharsToWrite;
            _pFatFileObj->nOffset += nCharsToWrite;
            pFileObj->nPos += nCharsToWrite;

            nCharsToWrite = 0;
            _nIoStatus = FSD_IOSTATUS_SUCCESS;
        }

        /*
         *  Write exceeds current Buffer, so output buffer and continue
         *  looping until all is written.
         */

        else
        {
            DEV_UINT32 _nNextClusterIdx;

            /*
             *  Fill the buffer before copying
             */

            DEVOBJ_MEMCPY(
                &( pFileObj->pBuffer[_pFatFileObj->nOffset] ),
                pBuffer,
                _nCharsLeft
            );

            /*
             *  Write the Cluster Out (on a failure, then we have a Device
             *  problem, which may or may not be recoverable)
             */

            _nIoStatus = Fat_FileWriteSector( pFileObj );
            if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
            {
                break;
            }

            *pnCharsWritten += _nCharsLeft;
            pFileObj->nPos += _nCharsLeft;
            nCharsToWrite -= _nCharsLeft;
            pBuffer = (DEV_PVOID)( (DEV_USTRING)pBuffer + _nCharsLeft );

            /*
             *  Get the Next Sector
             */

            if ( ++_pFatFileObj->nSector == 
                    _pFatDevObj->FAT_BootSector.BPB_SecPerClus )
            {
                _nIoStatus =
                    Fat_GetClusterEntry(
                        pFileObj->pDeviceObj,
                        _pFatFileObj->nCluster,
                        &_nNextClusterIdx
                    );
                if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
                {
                    break;
                }

                /*
                 *  End of FILE?
                 */

                if ( _nNextClusterIdx >= FAT_EOF(_pFatDevObj) )
                {
                    _nIoStatus =
                        Fat_FindNextFreeCluster(
                            pFileObj->pDeviceObj,
                            &_nNextClusterIdx
                        );
                    if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
                    {
                        break;
                    }

                    /*
                     *  Assign Next Cluster
                     */

                    _nIoStatus =
                        Fat_SetClusterEntry(
                            pFileObj->pDeviceObj,
                            _pFatFileObj->nCluster,
                            _nNextClusterIdx
                        );
                    if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
                    {
                        break;
                    }

                    _nIoStatus =
                        Fat_SetClusterEntry(
                            pFileObj->pDeviceObj,
                            _nNextClusterIdx,
                            _pFatDevObj->FAT_Eof
                        );
                    if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
                    {
                        break;
                    }

                    _pFatFileObj->nCluster = _nNextClusterIdx;
                }
                else
                {
                    _pFatFileObj->nCluster = _nNextClusterIdx;
                }

                _pFatFileObj->nSector = 0;
            }

            /*
             *  Read the Next or NEW Sector
             */

            Fat_ReadSector(
                pFileObj->pDeviceObj,
                pFileObj->pBuffer,
                (FAT_FIRSTSECTOROFCLUSTER(_pFatDevObj,_pFatFileObj->nCluster) +
                    _pFatFileObj->nSector)
            );

            /*
             *  Reset OFFSET and set as NO UPDATE on this sector yet
             */

            _pFatFileObj->nOffset = 0;
            pFileObj->nFlags &= (~_FileOpt_Updated);
        }

        /*
         *  Has the size of the file changed?
         */

        if ( pFileObj->nPos > _pFatFileObj->theEntry.DIR_FileSize )
        {
            _pFatFileObj->theEntry.DIR_FileSize = pFileObj->nPos;
        }
    }
    while ( nCharsToWrite > 0 );

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_FileSeek
 *
 *      Low level seek for an opened file.
 *
 *  Parameters:
 *      pFileObj        - Point to the File Object for this FILE
 *      nOffset         - Signed number of bytes to seek (forward or back)
 *      nOrigin         - Origin to start seek from
 *      pnPos           - Pointer to the new position (returned to caller)
 *
 *  Returns:
 *      Returns result of Seek.
 *
 *  Notes:
 *      Seeks on directories will fail on all SEEKS, unless a reset to the
 *      beginning is invoked. This is because the FILE SIZE for directories
 *      is "0" and only a rewind is allowed, because a rewind sets the off-
 *      set to "0", which will not violate boundary conditions.
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_FileSeek(
    PFILE_OBJ pFileObj,
    DEV_LONG nOffset,
    DEV_INT nOrigin,
    DEV_LONG* pnPos
)
{
    PFAT_FILEOBJ _pFatFileObj;
    DEV_IOSTATUS _nIoStatus = FSD_IOSTATUS_SUCCESS;

    _pFatFileObj = FAT_FILEOBJ_EXT(pFileObj);

    /*
     *  Calculate where in the file to position
     */

    switch( nOrigin )
    {
        case _SEEK_BEG:
            *pnPos = nOffset;
            break;

        case _SEEK_CUR:
            *pnPos = pFileObj->nPos + nOffset;
            break;

        case _SEEK_END:
            *pnPos = (DEV_LONG)Fat_FileSize( pFileObj ) + nOffset;
            break;

        default:
            *pnPos = -1;
            break;
    }

    /*
     *  OK, walk the file
     *
     *      This tests to see if the offset is into the next Sector/Cluster
     *      in which case a new Read is required.
     */

    _TRY
    {
        register DEV_UINT32 _nOffset;
        DEV_UINT32 _nCluster;
        DEV_UINT16 _nSector;

        PFAT_DEVOBJ _pFatDevObj = FAT_DEVOBJ_EXT(pFileObj->pDeviceObj);

        /*
         *  Out of Range?
         */

        if ( *pnPos < 0 || *pnPos > (DEV_LONG)Fat_FileSize( pFileObj ) )
        {
            _nIoStatus = FSD_IOSTATUS_SEEK_INVALID;
            _THROW(Exception_File);
        }

        /*
         *  SPECIAL CASE...ROOT directory (of course)
         */

        if ( _pFatFileObj->theEntry.DIR_Name[0] == DIRENTRY_ROOT )
        {
            _pFatFileObj->nSector = _pFatFileObj->nCluster;
            _pFatFileObj->nOffset = 0;

            _nIoStatus =
                Fat_ReadSector(
                    pFileObj->pDeviceObj,
                    pFileObj->pBuffer,
                    _pFatFileObj->nSector
                );
            _THROW_NONE();
        }

        /*
         *  Generic OFFSET term used to calculate where in the file, cluster
         *  or sector, the pointer needs to move
         */

        _nOffset = *pnPos / FAT_BYTESPERCLUSTER(_pFatDevObj);
        _nCluster = _pFatFileObj->theEntry.DIR_FstClusLO;

        /*
         *  Find the CLUSTER
         */

        while ( _nOffset > 0 )
        {
            _nIoStatus =
                Fat_GetClusterEntry(
                    pFileObj->pDeviceObj,
                    _nCluster,
                    &_nCluster
                );

            if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
            {
                _THROW(Exception_File);
            }

            /*
             *  Get Next Cluster
             */

            _nOffset--;
        }

        /*
         *  Find the SECTOR offset
         */

        _nOffset = DEVOBJ_REM( *pnPos, FAT_BYTESPERCLUSTER(_pFatDevObj) );
        _nSector = 
            (DEV_UINT16)(_nOffset/_pFatDevObj->FAT_BootSector.BPB_BytesPerSec);
        
        /*
         *  Cache the Sector (but only if this is a new Sector)
         */

        if ( ( _nCluster != _pFatFileObj->nCluster ) || 
                                 (_nSector != _pFatFileObj->nSector ) )
        {
            /*
             *  File updated (only happens if opened for WRITE)?
             */

            if ( pFileObj->nFlags & _FileOpt_Updated )
            {
                /*
                 *  Write the previous Cluster if it changed
                 */

                _nIoStatus = Fat_FileWriteSector( pFileObj );
                if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
                {
                    _THROW(Exception_File);
                }
            }

            /*
             *  Cache the new Sector
             */

            _nIoStatus =
                Fat_ReadSector(
                    pFileObj->pDeviceObj,
                    pFileObj->pBuffer,
                    FAT_FIRSTSECTOROFCLUSTER(_pFatDevObj,_nCluster) + _nSector
                );

            if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
            {
                _THROW(Exception_File);
            }

            /*
             *  Update to new CLUSTER
             */

            _pFatFileObj->nCluster = _nCluster;
            _pFatFileObj->nSector = _nSector;
        }

        /*
         *  Here the OFFSET Within the Cluster can be determined
         */

        pFileObj->nPos = *pnPos;
        _pFatFileObj->nOffset =
            DEVOBJ_REM(*pnPos,_pFatDevObj->FAT_BootSector.BPB_BytesPerSec);
    }

    /*
     *  Catch Errors here
     */

    _CATCH(Exception_File)
    {
        *pnPos = pFileObj->nPos;
    }
    _END_CATCH

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_FileRename
 *
 *      Renames a file (or directory on the file system)
 *
 *  Parameters:
 *      pFileObj    - Pointer to the file object
 *      strPath     - Pointer to the pathname (null terminated)
 *      strName     - Pointer to the new name (null terminated)
 *
 *  Returns:
 *      Returns result of Rename.
 *
 *  Notes:
 *      Collision problems can occur with simultaneous clients open on the
 *      file. The upper I/O manager must handle access into this file so
 *      that this problem does not occur.
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_FileRename(
    PFILE_OBJ pFileObj,
    DEV_STRING strPath,
    DEV_STRING strName
)
{
    DEV_IOSTATUS _nIoStatus;

    FAT_DIRENTRY _dirRenameEntry;
    PFAT_FILEOBJ _pFatFileObj;

    DEV_UINT32 _nDirSector;
    DEV_UINT16 _nDirOffset;

    do
    {
        /*
         *  Open the file to test it's existence
         */

        _nIoStatus =
            Fat_FileOpen( pFileObj, strPath, _OPEN_WRONLY );
        if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
        {
            break;
        }

        /*
         *  Backup the Current Directory Entry
         */

        _pFatFileObj = FAT_FILEOBJ_EXT(pFileObj);

        DEVOBJ_MEMCPY(
            &_dirRenameEntry,
            &(_pFatFileObj->theEntry),
            sizeof(FAT_DIRENTRY)
        );
        _nDirSector = _pFatFileObj->nDirSector;
        _nDirOffset = _pFatFileObj->nDirOffset;

        /*
         *  File Exists, so verify no other FILE NAME in the Parent Directory
         *  Exist that matches, the file we are looking for.
         */

        _nIoStatus = Fat_DirFindEntry( pFileObj, strName );
        if ( _DEV_IOSTATUS_FAILED(_nIoStatus) &&
                ( _nIoStatus == FSD_IOSTATUS_FILE_NOT_FOUND ) )
        {
            /*
             *  Restore with NEW Name
             */

            DEVOBJ_MEMCPY(
                &( _pFatFileObj->theEntry.DIR_Attr ),
                &( _dirRenameEntry.DIR_Attr ),
                sizeof(FAT_DIRENTRY) - DIRENTRY_FULLNAMELEN
            );
            _pFatFileObj->nDirOffset = _nDirOffset;
            _pFatFileObj->nDirSector = _nDirSector;

            /*
             *  Close will UPDATE the entry since it was opened as WRITE
             */
        }

        Fat_FileClose( pFileObj );
    }
    while (0);

    return _nIoStatus;
}

/* --------------------------------------------------------------------------
 *
 *  Fat_FileStat
 *
 *      Gets information about a file stored on the device.
 *
 *  Parameters:
 *      pDevObj     - Device object the file resides on
 *      strPath     - String name of the file (path inclusive)
 *      pStat       - Pointer to the Stat structure to fill
 *
 *  Returns:
 *      Fails if the file does not exist or other general error, otherwise a
 *      success call is returned and the structure filled.
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS Fat_FileStat(
    PFILE_OBJ pFileObj,
    DEV_STRING strPath,
    PSTAT pStat
)
{
    DEV_IOSTATUS _nIoStatus;

    /*
     *  Issue an OPEN, although we are only opening it readonly, all the
     *  required information will be available when we do this.
     */

    _nIoStatus =
        Fat_FileOpen(
                pFileObj,
                strPath,
                FSD_FLAGS( _OPEN_RDONLY, 0 )
        );

    /*
     *  Was the directory entry created successfully?
     */

    if ( _DEV_IOSTATUS_SUCCEEDED(_nIoStatus) )
    {
        PFAT_FILEOBJ _pFatFileObj = FAT_FILEOBJ_EXT(pFileObj);

        /*
         *  OK, COPY information over
         */

        pStat->st_dev   = pFileObj->pDeviceObj->nDeviceNo;
        pStat->st_size  = _pFatFileObj->theEntry.DIR_FileSize;
        pStat->st_ino =
            Fat_GetINumber(
                FAT_DEVOBJ_EXT(pFileObj->pDeviceObj),
                pFatFileObj
            );

        /*
         *  Mode Flag
         */

        pStat->st_mode =
            DirEntry_IsDirectory(&_pFatFileObj->theEntry) ?
                _SMODE_IFDIR : _SMODE_IFREG;

        pStat->st_mode |=
            DirEntry_IsReadOnly(&_pFatFileObj->theEntry) ?
                _SMODE_IREAD : (_SMODE_IREAD | _SMODE_IWRITE);

        /*
         *  Hard links or shortcuts are not supported currently, nor is user
         *  and group identification.
         */

        pStat->st_nlink = 1;
        pStat->st_uid = pStat->st_gid = 0;
        pStat->st_rdev = pStat->st_dev;

        /*
         *  Time and Date
         *
         *      Access Time: Last Access (if enabled) only the Date is Stored
         *      Create Time: Time file was Created
         *      Modify Time: Time file was last Written
         */

        pStat->st_atime =
            Fat_ConvertFromDiskTime(
                (FAT_TIME*)0,
                (FAT_DATE*)&_pFatFileObj->theEntry.DIR_CrtDate
            );

        pStat->st_ctime =
            Fat_ConvertFromDiskTime(
                (FAT_TIME*)&_pFatFileObj->theEntry.DIR_CrtTime,
                (FAT_DATE*)&_pFatFileObj->theEntry.DIR_CrtDate
            );

        pStat->st_mtime =
            Fat_ConvertFromDiskTime(
                (FAT_TIME*)&_pFatFileObj->theEntry.DIR_WrtTime,
                (FAT_DATE*)&_pFatFileObj->theEntry.DIR_WrtDate
            );

        /*
         *  Close the File
         */

        Fat_FileClose( pFileObj );
    }

    return _nIoStatus;
}

/*
 *  End of fat_file.c
 */

