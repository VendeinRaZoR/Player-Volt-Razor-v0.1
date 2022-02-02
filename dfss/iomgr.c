
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
 *  iomgr.c
 *
 *      This is for EXAMPLE and DEMONSTRATION ONLY. It in no ways demonstrates
 *      the workings of the intended product, but a mechanism by providing a
 *      higher level interface to applications that access the file system.
 *
 *      It is simply just an approach to writing an I/O Manager around the
 *      File System.
 *
 *      The FCB Handling as written will not handle multiple handles open on
 *      a file. The reason is when a file is closed, the I/O Manager only
 *      knows of the FCB and not the File Object in particular, if multiple
 *      access on this file is occurring. A newer approach is the FCB is
 *      hidden within the I/O Manager and clients only access via the File
 *      Object Pointer, which would contain a loopback pointer to the
 *      FCB Entry, such as Devices have with their respective Driver objects.
 */

#include "fsd.h"
#include "devtbl.h"

#include "iomgr.h"
#include "file_api.h"

/*
 *  File SYSTEM Table for OUR Driver
 *
 *      This EXAMPLE shows two File Systems, labeled a "C" and "D"
 *
 *      IN This example no ENTRY has been entered for the FLASH MEMORY
 *      the File Systems sit atop, so they can only be accessed strictly
 *      through their Device ID and not named string.
 */

static IOENTRY s_IoTable[] = {

#ifdef WIN32

        { "C",
          MAKE_DEVNO(
            DEVICE_TYPE_BLOCK,
            DEVICE_FAT_FILE_SYSTEM,
            DEVICE_FAT_FILE_SYSTEM_DEV0 ),
          DEVOBJ_TRUE,
        },

        { "D",
          MAKE_DEVNO(
            DEVICE_TYPE_BLOCK,
            DEVICE_FAT_FILE_SYSTEM,
            DEVICE_FAT_FILE_SYSTEM_DEV1 ),
          DEVOBJ_TRUE,
        },

#else

        { "C",
          MAKE_DEVNO(
            DEVICE_TYPE_BLOCK,
            DEVICE_FAT_FILE_SYSTEM,
            DEVICE_FAT_FILE_SYSTEM_DEV0 ),
          DEVOBJ_TRUE,
        },

#endif

};

static DEV_LONG s_nIoDevices = sizeof(s_IoTable) / sizeof(IOENTRY);

/* --------------------------------------------------------------------------
 *
 *  IoManager_Hash
 *
 *      Simple Hashing Function the FCB Table. It takes the Key (string) and
 *      sums up the ordinal values of each character, then returns this sum
 *      modulo the size of the table.
 *
 *  Parameters:
 *      strKey  - Key to Hash, in string form
 *
 *  Returns:
 *      The Hash Index.
 *
 *  Notes:
 *      None.
 *
 * --------------------------------------------------------------------------
 */

static
DEV_SHORT IoManager_Hash( DEV_STRING strKey )
{
    DEV_ULONG _nSum = 0;
    DEV_UINT _nKeyLength = DEVOBJ_STRLEN( strKey );

    while ( _nKeyLength > 0 )
    {
        _nKeyLength--;
        if ( strKey[ _nKeyLength ] != '\\' )
        {
            _nSum += (DEV_ULONG)strKey[ _nKeyLength ];
        }
    }

    return (DEV_USHORT)DEVOBJ_REM(_nSum,FCB_TBLLEN);
}

/* --------------------------------------------------------------------------
 *
 *  IoManager_GetDevEntry
 *
 *      Retrieves a Device Entry from the IO Device Table. The entry is
 *      retrieved by a key, the Device Name, which is delimited by the ":"
 *      or other means (the delmiter can be redefined in iomgr.h). The dev
 *      name must be the first part of the path qualification and is usually
 *      prepended by the system calling into the file system.
 *
 *  Parameters:
 *      strName -   Pathname of the file, which has the device as the prefix
 *                  indicating which device it resides on.
 *
 *  Returns:
 *      Returns a pointer to the IOENTRY that is associated with the device
 *      name prefix, otherwise a NULL is returned.
 *
 *  Notes:
 *      None.
 *
 * --------------------------------------------------------------------------
 */

static
IOENTRY* IoManager_GetDevNameEntry( char* strName )
{
    if ( strName != 0 )
    {
        DEV_LONG _nIoEntry;
        IOENTRY* _pIoEntry = s_IoTable;

        /*
         *  Uppercase the Device Name (CASE-INSENSITIVE)
         */

        StringCaseUpper( strName, DEVOBJ_STRLEN(strName) );

        /*
         *  Find the matching DEVICE ID
         */

        for ( _nIoEntry = 0; _nIoEntry < s_nIoDevices; _nIoEntry++ )
        {
            /*
             *  Is this the device?
             */

            if ( DEVOBJ_STRCMP( strName, _pIoEntry->szDevName ) == 0 )
            {
                break;
            }

            _pIoEntry++;
        }

        /*
         *  Entry FOUND?
         */

        if ( _nIoEntry < s_nIoDevices )
        {
            return _pIoEntry;
        }
    }

    /*
     *  Error if function reaches here
     */

    return (IOENTRY*)0;
}

/* --------------------------------------------------------------------------
 *
 *  IoManager_GetDevEntry
 *
 *      Retrieves a Device Entry from the IO Device Table. The entry is
 *      retrieved by a key, the Device Name, which is delimited by the ":"
 *      or other means (the delmiter can be redefined in iomgr.h). The dev
 *      name must be the first part of the path qualification and is usually
 *      prepended by the system calling into the file system.
 *
 *  Parameters:
 *      strName -   Pathname of the file, which has the device as the prefix
 *                  indicating which device it resides on.
 *
 *  Returns:
 *      Returns a pointer to the IOENTRY that is associated with the device
 *      name prefix, otherwise a NULL is returned.
 *
 *  Notes:
 *      None.
 *
 * --------------------------------------------------------------------------
 */

static
IOENTRY* IoManager_GetDevNoEntry( DEV_TYPE nDevNo )
{
    DEV_LONG _nIoEntry;
    IOENTRY* _pIoEntry = s_IoTable;

    /*
     *  Find the matching DEVICE ID
     */

    for ( _nIoEntry = 0; _nIoEntry < s_nIoDevices; _nIoEntry++ )
    {
        /*
         *  Is this the device?
         */

        if ( nDevNo == _pIoEntry->nDevId )
        {
            break;
        }

        _pIoEntry++;
    }

    /*
     *  Entry FOUND?
     */

    if ( _nIoEntry < s_nIoDevices )
    {
        return _pIoEntry;
    }

    /*
     *  Error if function reaches here
     */

    return (IOENTRY*)0;
}

/*
 *  Public Members
 */

/* --------------------------------------------------------------------------
 *
 *  IoManager_RemoveFCB
 *
 *      Removes an FCB from the Table.
 *
 *  Parameters:
 *      pFcb -   Pointer to an FCB previously allocated
 *
 *  Returns:
 *      Always 0 for now.
 *
 *  Notes:
 *      None.
 *
 * --------------------------------------------------------------------------
 */

DEV_INT IoManager_RemoveFCB( FCB* pFcb )
{
    DEV_SHORT _nHash = IoManager_Hash( pFcb->strPathname );
    IOENTRY* _pIoEntry =
        IoManager_GetDevNoEntry( pFcb->FileObj.pDeviceObj->nDeviceNo );

    if ( _pIoEntry != 0 )
    {
        FCB** _ppFcbRemove = &_pIoEntry->tblFCB[ _nHash ];

        do
        {
            if ( *_ppFcbRemove == pFcb )
            {
                *_ppFcbRemove = pFcb->pNextFCB;

                #ifndef _FILES_MUTUAL_EXCLUSION

                /*
                 *  TODO: The File Object is a list in this scenario, instead
                 *  of directly aggregated within the FCB.
                 */

                #endif

                DEVOBJ_FREE( pFcb->strPathname );
                DEVOBJ_FREE( pFcb );
                break;
            }

            else
            {
                _ppFcbRemove = &(*_ppFcbRemove)->pNextFCB;
            }
        }
        while ( *_ppFcbRemove != 0 );

        return ESUCCESS;
    }

    /*
     *  Idiot Control
     */

    return EFAIL;
}

/* --------------------------------------------------------------------------
 *
 *  IoManager_CreateFCB
 *
 *      Creates an FCB specific for a file (device and pathname inclusive).
 *
 *  Parameters:
 *      strName -   Name of the file, path and device name inclusive.
 *
 *  Returns:
 *      .
 *
 *  Notes:
 *      FCBs must be allocated whenever a file is opened or an operation
 *      that changes characteristics, such as mode, or creation (mkdir and
 *      rmdir).
 *
 * --------------------------------------------------------------------------
 */

FCB* IoManager_CreateFCB( DEV_STRING strName )
{
    IOENTRY* _pIoEntry;
    FCB* _pFcb = 0;
    FCB** _ppFcbInsert;

    /*
     *  Dummy Loop
     */

    do
    {
        DEV_SHORT _nHash;
        DEV_STRING _strNormalized;
        DEV_STRING* _strStack;
        DEV_STRING _strToken;

        /*
         *  Count the number of directory changes in the pathname
         */

        _strNormalized = strName;
        _nHash = 0;

        do
        {
            _strNormalized += _PATH_DELIMITER_LEN;
            _strNormalized = DEVOBJ_STRSTR( _strNormalized, _PATH_DELIMITER );
            _nHash++;
        }
        while ( _strNormalized != 0 );

        /*
         *  Allocate a copy of the string name in it's normalized form
         */

        _strNormalized = (DEV_STRING)DEVOBJ_MALLOC( DEVOBJ_STRLEN(strName) );
        if ( _strNormalized == 0 )
        {
            break;
        }

        /*
         *  Valid Device Name?
         */

        strName = StringParse( strName, _strNormalized, DEVNAME_DELIMETER );

        _pIoEntry = IoManager_GetDevNameEntry( _strNormalized );
        if ( _pIoEntry == 0 )
        {
            DEVOBJ_FREE( _strNormalized );
            break;
        }

        /*
         *  Normalize the STRING
         *
         *      The STRING name is normalized, removing any "." and ".." from
         *      the name itself, as well as NULLs and the DEVICE Name.
         */

        /*
         *  Allocate the Stack (simulates a Pushdown Automata since we have to
         *  parse out the path
         */

        _strStack = DEVOBJ_MALLOC( sizeof(DEV_STRING) * _nHash );
        if ( _strStack == 0 )
        {
            DEVOBJ_FREE( _strNormalized );
            break;
        }

        /*
         *  Initialize
         */

        *_strNormalized = DEVOBJ_EOS;

        _nHash = 0;
        _strStack[0] = _strNormalized;
        _strToken = _strNormalized + _PATH_DELIMITER_LEN;

        while ( strName != 0 )
        {
            strName =
                StringParse( strName, _strToken, _PATH_DELIMITER );

            if ( DEVOBJ_STRLEN(_strToken) > 0 )
            {
                /*
                 *  Previous directory?
                 */

                if ( DEVOBJ_STRCMP( _strToken, _PREVDIR ) == 0 )
                {
                    if ( _nHash != 0 )
                    {
                        _nHash--;
                        *(_strStack[_nHash]) = DEVOBJ_EOS;
                        _strToken = _strStack[_nHash] + _PATH_DELIMITER_LEN;
                    }
                }

                /*
                 *  Current Directory
                 */

                else if ( DEVOBJ_STRCMP( _strToken, _CURDIR ) != 0 )
                {
                    DEVOBJ_STRNCPY(
                        _strStack[_nHash],
                        _PATH_DELIMITER,
                        _PATH_DELIMITER_LEN
                    );

                    _nHash++;
                    _strStack[_nHash] = _strToken + DEVOBJ_STRLEN(_strToken);
                    _strToken = _strStack[_nHash] + _PATH_DELIMITER_LEN;
                }
            }
        }

        DEVOBJ_FREE( _strStack );

        /*
         *  Perform the HASH and test for existing entry?
         */

        _nHash = IoManager_Hash( _strNormalized );

        /*
         *  Collision?
         */

        _ppFcbInsert = &_pIoEntry->tblFCB[ _nHash ];
        while ( *_ppFcbInsert != 0 )
        {
            /*
             *  Test for Matching FCB as File may already have an FCB
             *  assigned to it.
             */

            if (
                DEVOBJ_STRCMP(
                (*_ppFcbInsert)->strPathname,
                _strNormalized ) == 0 )
            {

                #ifndef _FILES_MUTUAL_EXCLUSION

                    /*
                     *  TODO: Support for Multiple Descriptors on a file
                     */

                #endif

                DEVOBJ_FREE( _strNormalized );
                break;
            }

            _ppFcbInsert = &(*_ppFcbInsert)->pNextFCB;
        }

        /*
         *  Empty entry?
         */

        if ( *_ppFcbInsert == 0 )
        {
            /*
             *  Allocate the FCB
             */

            *_ppFcbInsert = (FCB*)DEVOBJ_MALLOC( sizeof(FCB) );
            if ( *_ppFcbInsert == 0 )
            {
                DEVOBJ_FREE( _strNormalized );
                break;
            }

            _pFcb = *_ppFcbInsert;
            _pFcb->pNextFCB = 0;
            _pFcb->strPathname = _strNormalized;
            _pFcb->FileObj.pDeviceObj = GetDeviceObject( _pIoEntry->nDevId );

            #ifndef _FILES_MUTUAL_EXCLUSION

            /*
             *  TODO: The File Object is a list in this scenario, instead of
             *  directly aggregated within the FCB.
             */

            #endif
        }
    }
    while (0);


    return _pFcb;
}

/* --------------------------------------------------------------------------
 *
 *  IoManager_GetDeviceObject
 *
 *      Given a Name of a device, which is verified using the private
 *      function, GetDevNameEntry, a Device Object is returned to the
 *      caller.
 *
 *  Parameters:
 *      strName -   Name of the file, path and device name inclusive.
 *
 *  Returns:
 *      A pointer to the Device Object, or NULL if device name does not
 *      exist in the table.
 *
 *  Notes:
 *      None.
 *
 * --------------------------------------------------------------------------
 */

PDEVICE_OBJ IoManager_GetDeviceObject( DEV_STRING strName )
{
    IOENTRY* _pIoEntry;

    _pIoEntry = IoManager_GetDevNameEntry( strName );
    if ( _pIoEntry == 0 )
    {
        return (PDEVICE_OBJ)0;
    }

    else
    {
        return GetDeviceObject( _pIoEntry->nDevId );
    }
}

/* --------------------------------------------------------------------------
 *      SETUP and SHUTDOWN
 * --------------------------------------------------------------------------
 */

/* --------------------------------------------------------------------------
 *
 *  StartupFailHandler AND ShutdownFailHandler
 *
 *      Handlers for FAILURE on initialization or shutdown of devices in the
 *      system.
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

BEGIN_DRIVERINIT_CALLBACK(StartupFailHandler)

    /*
     *  Place specialized CODE here
     */

#ifdef WINDOWS

    /*
     *  For testing purposes only
     */

    exit(-1);

#endif

END_DRIVERINIT_CALLBACK


BEGIN_DRIVERINIT_CALLBACK(ShutdownFailHandler)

    /*
     *  Place specialized CODE here
     */

#ifdef WINDOWS

    /*
     *  For testing purposes only
     */

    exit(-1);

#endif

END_DRIVERINIT_CALLBACK

/* --------------------------------------------------------------------------
 *
 *  InitializeIoManager
 *
 *      This function initializes the I/O Subsystem.
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

DEV_INT IoManager_Initialize( void )
{
    DEV_LONG _nIoEntry;
    IOENTRY* _pIoEntry = s_IoTable;
    DEV_IOPACKET _iop;

    /*
     *  Initialize the DEVICE LAYER first, since the I/O Manager is dependent
     *  upon it.
     */

    InitializeDevices( StartupFailHandler );

    /*
     *  Time to MOUNT the devices in the I/O Table
     */

    _iop.nIoOperation = DEVICE_IO_CONTROL;
    _iop.pInBuffer = DEVOBJ_NULL;
    _iop.nInBufferLen = 0;

    /*
     *  For EACH Entry in the I/O Table
     */

    for ( _nIoEntry = 0; _nIoEntry < s_nIoDevices; _nIoEntry++ )
    {
        DEV_IOSTATUS _nIoStatus;

        /*
         *  Clear FCB
         */

        DEVOBJ_MEMSET( _pIoEntry->tblFCB, 0, sizeof(FCB*) * FCB_TBLLEN );

        do
        {
            /*
             *  AUTO Mount the Device?
             */

            if ( _pIoEntry->bAuto == DEVOBJ_FALSE )
            {
                break;
            }

            _iop.pDevice = GetDeviceObject( _pIoEntry->nDevId );
            if ( _iop.pDevice == 0 )
            {
                break;
            }

            _iop.nFunction =
                _IOCTL_MAKECODE(
                    MAJOR_DEVNO( _pIoEntry->nDevId ),
                    _FSD_IOCTL_MOUNT,
                    _IOCTL_ACCESS_NEITHER
                );

            _nIoStatus = IO_DISPATCH(&_iop);
            if ( _nIoStatus == FSD_IOSTATUS_NOT_FORMATTED )
            {
                _iop.nFunction =
                        _IOCTL_MAKECODE(
                            MAJOR_DEVNO( _pIoEntry->nDevId ),
                            _FSD_IOCTL_FORMAT,
                            _IOCTL_ACCESS_NEITHER
                        );
                _iop.pOutBuffer = (DEV_PVOID)_pIoEntry->szDevName;
                _iop.nOutBufferLen = 0;
                _nIoStatus = IO_DISPATCH(&_iop);
            }

            else if ( _DEV_IOSTATUS_FAILED( _nIoStatus ) )
            {
                /*
                 *  ERROR PROCESSING
                 */
            }
        }
        while (0);

        /*
         *  Next FSD
         */

        _pIoEntry++;
    }

    return ESUCCESS;
}

/* --------------------------------------------------------------------------
 *
 *  ShutdownIoManager
 *
 *      Shutsdown the I/O Manager, which in turns shuts down the File I/O
 *      system and removes the drivers in the system. The first thing that
 *      needs to be performed is unmounting each mounted filesystem. Since
 *      there is a system call to unmount (sys_umount), redirect the call
 *      to that for each entry in the I/O Table.
 *
 *  Parameters:
 *      None
 *
 *  Returns:
 *      Status of Initialization - Either it Fails or Succeeds. On FAILURE
 *      the Handler may be invoked, which in turn may do other cleanup
 *      activities like a FORCED SHUTDOWN.
 *
 *
 *  Notes:
 *      None.
 *
 * --------------------------------------------------------------------------
 */

DEV_INT IoManager_Shutdown( void )
{
    DEV_LONG _nIoEntry;
    IOENTRY* _pIoEntry = s_IoTable;

    /*
     *  Each device MUST be unmounted before a system wide shutdown can
     *  occur, else information may become fragmented
     */

    for ( _nIoEntry = 0; _nIoEntry < s_nIoDevices; _nIoEntry++ )
    {
        int _nErr;
        DEV_CHAR _strDevName[DEV_STRLEN+1];

        DEVOBJ_STRCPY( _strDevName, _pIoEntry->szDevName );
        _nErr = sys_umount( _strDevName );

        if ( _ISERROR(_nErr) && ( _nErr != ENOMEDIUM ))
        {
            return -EFAIL;
        }

        /*
         *  Next FSD
         */

        _pIoEntry++;
    }

    /*
     *  Shutdown the DRIVERS
     */

    ShutdownDevices( ShutdownFailHandler );

    /*
     *  Return
     */

    DEVOBJ_DUMPMEMORY();

    return ESUCCESS;
}
