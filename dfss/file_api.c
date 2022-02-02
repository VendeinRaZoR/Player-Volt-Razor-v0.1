
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
 *  file_api.c
 *
 *      This is the system-level, environment-agnostic, Unix-style API into
 *      the file system. By not adhering to an environment, the user must
 *      include a fully qualified pathname to file(s) it wishes to open.
 */

#include "file_api.h"
#include "iomgr.h"

typedef struct _FILE    FILE;

/*
 *  FILE Descriptors
 *
 *      The Number of FILE DESCRIPTORS shown here are system wide, but many
 *      implementations may use these as the maximum number opened per process
 *      or task. To this would require process information and a list of
 *      descriptors within that process block.
 *
 *      The MAXIMUM number of File Descriptors is not bounded by the number of
 *      File Systems. This is the maximum number of open files allowed across
 *      all file systems.
 */

#define FILEDESC_MAX            32

static FCB* s_aryFileDesc[ FILEDESC_MAX ] =
{
    (FCB*)0, (FCB*)0, (FCB*)0, (FCB*)0,
    (FCB*)0, (FCB*)0, (FCB*)0, (FCB*)0,
    (FCB*)0, (FCB*)0, (FCB*)0, (FCB*)0,
    (FCB*)0, (FCB*)0, (FCB*)0, (FCB*)0,
    (FCB*)0, (FCB*)0, (FCB*)0, (FCB*)0,
    (FCB*)0, (FCB*)0, (FCB*)0, (FCB*)0,
    (FCB*)0, (FCB*)0, (FCB*)0, (FCB*)0,
    (FCB*)0, (FCB*)0, (FCB*)0, (FCB*)0
};

static
DEVOBJ_DECLARE_CRITICAL_SECTION(s_csFileDesc);

/* --------------------------------------------------------------------------
 *  Private (Local) Methods
 * --------------------------------------------------------------------------
 */

/* --------------------------------------------------------------------------
 *  Private (Local) Methods
 * --------------------------------------------------------------------------
 */

/* --------------------------------------------------------------------------
 *
 *  sys_initialize
 *
 *      Tests the file descriptor for validity
 *
 *  Parameters:
 *      fd          - File descriptor for the directory
 *
 *  Returns:
 *      Non-zero if the file descriptor is valid, zero if not.
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

void sys_initialize( DEV_BOOL func )
{
    if ( func == DEVOBJ_TRUE )
    {
        DEVOBJ_INIT_CRITICAL_SECTION(s_csFileDesc);
        IoManager_Initialize();
    }
    else
    {
        IoManager_Shutdown();
        DEVOBJ_DESTROY_CRITICAL_SECTION(s_csFileDesc);
    }
}

/* --------------------------------------------------------------------------
 *
 *  sys_valid_fd
 *
 *      Tests the file descriptor for validity
 *
 *  Parameters:
 *      fd          - File descriptor for the directory
 *
 *  Returns:
 *      Non-zero if the file descriptor is valid, zero if not.
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

#define sys_valid_fd(fd) \
    ( (fd < FILEDESC_MAX) && (fd >= 0) && (s_aryFileDesc[fd] != (FCB*)0) )

/* --------------------------------------------------------------------------
 *
 *  sys_stat_to_errno
 *
 *      Convert the Device Error Codes to "errno" equivalent
 *
 *  Parameters:
 *      iostat  - Error code as returned from the device.
 *
 *  Returns:
 *      Converts the Device Error Code into it's Error Number equivalent
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

#define sys_stat_to_errno( iostat ) \
    -( (int)_DEV_IOSTATUS_CODE(iostat) )

/* --------------------------------------------------------------------------
 *
 *  sys_alloc_fd
 *
 *      Allocates a FILE Descriptor
 *
 *  Parameters:
 *      name    - Pathname to which the File Descriptor is assigned.
 *
 *  Returns:
 *      Returns a valid file descriptor 0 thru N-1, where N is the number of
 *      maximum allowable open descriptors. On error it returns a -1 which
 *      is an invalid file descriptor
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

static
FILEDESC sys_alloc_fd( DEV_STRING name )
{
    FILEDESC _fd;

    DEVOBJ_ENTER_CRITICAL_SECTION(s_csFileDesc);

    /*
     *  Available Descriptor Slot?
     */

    for ( _fd = 0; _fd < FILEDESC_MAX; _fd++ )
    {
        if ( s_aryFileDesc[_fd] == (FCB*)0 )
        {
            break;
        }
    }

    /*
     *  Valid File Descriptor Index?
     */

    if ( _fd == FILEDESC_MAX )
    {
        _fd = UNDEFINED_FILEDESC;
    }

    /*
     *  Allocate the FCB for the descriptor index
     */

    else
    {
        s_aryFileDesc[_fd] = IoManager_CreateFCB( name );
        if ( s_aryFileDesc[_fd] == 0 )
        {
            _fd = UNDEFINED_FILEDESC;
        }
    }

    DEVOBJ_LEAVE_CRITICAL_SECTION(s_csFileDesc);

    return _fd;
}

/* --------------------------------------------------------------------------
 *
 *  sys_free_fd
 *
 *      Frees a FILE Descriptor
 *
 *  Parameters:
 *      pfd     - Pointer to the file descriptor (by reference)
 *
 *  Returns:
 *      Nothing, but the File Descriptor is set to Undefined.
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

static
void sys_free_fd( FILEDESC* pfd )
{
    DEVOBJ_ENTER_CRITICAL_SECTION(s_csFileDesc);

    if ( *pfd != UNDEFINED_FILEDESC )
    {
        IoManager_RemoveFCB( s_aryFileDesc[*pfd] );
        s_aryFileDesc[*pfd] = (FCB*)0;
        *pfd = UNDEFINED_FILEDESC;
    }

    DEVOBJ_LEAVE_CRITICAL_SECTION(s_csFileDesc);

    return;
}

/* --------------------------------------------------------------------------
 *  Volume specific operations
 * --------------------------------------------------------------------------
 */

/* --------------------------------------------------------------------------
 *
 *  sys_volume
 *
 *      Mounts or Unmounts a File System (Volume) given by the Assigned
 *      Device Name.
 *
 *  Parameters:
 *      devname     - System Name of device to unmount
 *
 *  Returns:
 *      Success or Error.
 *
 *  Notes:
 *      The string passed in will have the device name parsed if a delimiter
 *      is found, leaving a "NULL" in the name. Clients should buffer the
 *      original string unless it is a one time use thing.
 *
 * --------------------------------------------------------------------------
 */

int sys_volume( char* devname, DEV_IOCODE func )
{
    DEV_IOSTATUS _nIoStatus;
    DEV_IOPACKET _iop;
    DEV_STRING _strDevname = devname;

    /*
     *  Parse the device name out...not worried about the result
     */

    StringParse( devname, _strDevname, DEVNAME_DELIMETER );

    /*
     *  Get the device object
     */

    _iop.pDevice = IoManager_GetDeviceObject( _strDevname );
    if ( _iop.pDevice == 0 )
    {
        _nIoStatus = _DEV_IOSTATUS_NO_DEVICE;
    }

    /*
     *  Device exists - Dispatch
     */

    else
    {
        _iop.nIoOperation = DEVICE_IO_CONTROL;
        _iop.pInBuffer = DEVOBJ_NULL;
        _iop.nInBufferLen = 0;
        _iop.nFunction =
            _IOCTL_MAKECODE(
                MAJOR_DEVNO( _iop.pDevice->nDeviceNo ),
                func, 0
            );

        _nIoStatus = IO_DISPATCH(&_iop);
    }

    /*
     *  Return the result
     */

    return sys_stat_to_errno(_nIoStatus);
}

/* --------------------------------------------------------------------------
 *
 *  sys_umount
 *
 *      Unmounts a File System (Volume) given by the Assigned Device Name.
 *
 *  Parameters:
 *      devname     - System Name of device to unmount
 *
 *  Returns:
 *      Success or Error.
 *
 *  Notes:
 *      Before the FILE System can be unmounted a FORCE CLOSE on all files
 *      must be performed.
 *
 * --------------------------------------------------------------------------
 */

int sys_umount( char* devname )
{
    int _fd;
    DEV_STRING _strDevname = devname;
    PDEVICE_OBJ _pDevObj;

    /*
     *  Parse the device name out...not worried about the result
     */

    StringParse( devname, _strDevname, DEVNAME_DELIMETER );

    /*
     *  Get the device object
     */

    _pDevObj = IoManager_GetDeviceObject( _strDevname );

    /*
     *  Available Descriptor Slot?
     */

    for ( _fd = 0; _fd < FILEDESC_MAX; _fd++ )
    {
        DEVOBJ_ENTER_CRITICAL_SECTION(s_csFileDesc);

        if ( s_aryFileDesc[_fd] != (FCB*)0 )
        {
            FCB* _pFcb = s_aryFileDesc[_fd];

            /*
             *  On the device targeted for SHUTDOWN?
             */

            if ( _pFcb->FileObj.pDeviceObj->nDeviceNo == _pDevObj->nDeviceNo )
            {
                int _nErr;

                DEVOBJ_LEAVE_CRITICAL_SECTION(s_csFileDesc);
                _nErr = sys_close( _fd );

                /*
                 *  On ERROR, we cannot continue and MUST fail
                 */

                if ( _ISERROR( _nErr ) )
                {
                    return _nErr;
                }
                continue;
            }
        }

        DEVOBJ_LEAVE_CRITICAL_SECTION(s_csFileDesc);
    }

    /*
     *  Shut the VOLUME DOWN
     */

    return sys_volume( devname, _FSD_IOCTL_UNMOUNT );
}

/* --------------------------------------------------------------------------
 *
 *  sys_devstats
 *
 *      Gets the device statistics for a given volume
 *
 *  Parameters:
 *      devname     - Device name
 *      stats       - Structure the stats are placed in
 *
 *  Returns:
 *      Fails it the device does not exist or is not mounted.
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

int sys_devstats( char* devname, PDEVSTATS stats )
{
    DEV_IOSTATUS _nIoStatus;
    DEV_IOPACKET _iop;
    DEV_STRING _strDevname = devname;

    /*
     *  Parse the device name out...not worried about the result
     */

    StringParse( devname, _strDevname, DEVNAME_DELIMETER );

    /*
     *  Get the device object
     */

    _iop.pDevice = IoManager_GetDeviceObject( _strDevname );
    if ( _iop.pDevice == 0 )
    {
        _nIoStatus = _DEV_IOSTATUS_NO_DEVICE;
    }

    /*
     *  Device exists - Dispatch
     */

    else
    {
        _iop.nIoOperation = DEVICE_IO_CONTROL;
        _iop.pInBuffer = (DEV_PVOID)stats;
        _iop.nInBufferLen = sizeof(DEVSTATS);
        _iop.nFunction =
            _IOCTL_MAKECODE(
                MAJOR_DEVNO( _iop.pDevice->nDeviceNo ),
                DEVICE_IOCTL_STAT, 0
            );

        _nIoStatus = IO_DISPATCH(&_iop);
    }

    /*
     *  Return the result
     */

    return sys_stat_to_errno(_nIoStatus);
}

/* --------------------------------------------------------------------------
 *
 *  sys_format
 *
 *      Formats a volume
 *
 *  Parameters:
 *      devname     - Device name of
 *      volname     - Name applied to the Volume
 *
 *  Returns:
 *      Fails it the device does not exist or is not mounted.
 *
 *  Notes:
 *      Use this function with caution as all the data on the volume will
 *      be erased.
 *
 *      The string passed in will have the device name parsed if a delimiter
 *      is found, leaving a "NULL" in the name. Clients should buffer the
 *      original string unless it is a one time use thing.
 *
 * --------------------------------------------------------------------------
 */

int sys_format( char* devname, char* volname )
{
    DEV_IOSTATUS _nIoStatus;
    DEV_IOPACKET _iop;
    DEV_STRING _strDevname = devname;

    /*
     *  Parse the device name out...not worried about the result
     */

    StringParse( devname, _strDevname, DEVNAME_DELIMETER );

    /*
     *  The device must exist first...get the device object
     */

    _iop.pDevice = IoManager_GetDeviceObject( _strDevname );
    if ( _iop.pDevice == DEVICE_NULL )
    {
        _nIoStatus = _DEV_IOSTATUS_NO_DEVICE;
    }

    /*
     *  Device exists - Dispatch
     */

    else
    {
        _iop.nIoOperation = DEVICE_IO_CONTROL;
        _iop.pOutBuffer = (DEV_PVOID)volname;
        _iop.nOutBufferLen = DEVOBJ_STRLEN(volname);
        _iop.nFunction =
            _IOCTL_MAKECODE(
                MAJOR_DEVNO( Device_GetId(_iop.pDevice) ),
                _FSD_IOCTL_FORMAT, 0
            );

        _nIoStatus = IO_DISPATCH(&_iop);
    }

    /*
     *  Return the result
     */

    return sys_stat_to_errno(_nIoStatus);
}

/* --------------------------------------------------------------------------
 *
 *  sys_dir
 *
 *      Makes or Removes a directory from the File System
 *
 *  Parameters:
 *      dirname - Name of directory to make or remove
 *      func    - Identifier specifying whether to mkdir or rmdir
 *
 *  Returns:
 *      Result of operation.
 *
 *  Notes:
 *      There is no concept of doing a Change Directory (chdir), since the
 *      system API is environment agnostic. The FSD does not support a CHDIR
 *      I/O Control, so since changing of directory is for the environment
 *      in which the task/process is running, simply using the "stat"
 *      function to verify the path is all that is required.
 *
 * --------------------------------------------------------------------------
 */

int sys_dir( char* dirname, DEV_IOCODE func )
{
    DEV_IOSTATUS _nIoStatus = _DEV_IOSTATUS_BAD_DESCRIPTOR;
    DEV_IOPACKET _iop;

    int _fd = sys_alloc_fd(dirname);

    /*
     *  Valid file descriptor?
     */

    if ( _fd != UNDEFINED_FILEDESC )
    {
        FCB* _pFcb = s_aryFileDesc[_fd];

        /*
         *  Dispatch
         */

        _iop.nIoOperation = DEVICE_IO_CONTROL;
        _iop.pDevice = _pFcb->FileObj.pDeviceObj;
        _iop.pDescriptor = (DEV_PVOID)&_pFcb->FileObj;
        _iop.pOutBuffer = (DEV_PVOID)_pFcb->strPathname;
        _iop.nOutBufferLen = DEVOBJ_STRLEN(dirname);
        _iop.nFunction =
            _IOCTL_MAKECODE(
                MAJOR_DEVNO( _pFcb->FileObj.pDeviceObj->nDeviceNo ),
                func, 0
            );

        _nIoStatus = IO_DISPATCH(&_iop);
        sys_free_fd(&_fd);
    }

    /*
     *  Return the result
     */

    return sys_stat_to_errno(_nIoStatus);
}

/* --------------------------------------------------------------------------
 *
 *  sys_opendir
 *
 *      Opens the directory specified by dirname
 *
 *  Parameters:
 *      dirname     - String pointer to the directory name
 *
 *  Returns:
 *      Returns a file handle for the opened directory if successful, other-
 *      wise -1.
 *
 *  Notes:
 *      Will fail if dirname is not a directory.
 *
 * --------------------------------------------------------------------------
 */

DIRDESC sys_opendir( char* dirname )
{
    /*
     *  Reroute to "sys_open", but as readonly
     */

    DIRDESC _fdir = sys_open( dirname, _OPEN_RDONLY, 0 );

    /*
     *  Valid file?
     */

    if ( !_ISERROR(_fdir) )
    {
        if ( !File_IsDirectory( &(s_aryFileDesc[_fdir])->FileObj ) )
        {
            sys_close( _fdir );
            return -ENOTDIR;
        }
    }

    /*
     *  Return the descriptor to the directory
     */

    return _fdir;
}

/* --------------------------------------------------------------------------
 *
 *  sys_readdir
 *
 *      Reads the next directory entry into structure pointed to by "dir".
 *
 *  Parameters:
 *      fd          - File descriptor referring to open directory
 *      dir         - Pointer to the directory structure to fill
 *
 *  Returns:
 *      Unlike read, this function does not return the number of bytes read
 *      since it reads only one entry at a time. A "success" is returned if
 *      no errors were encountered.
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

int sys_readdir( DIRDESC fd, PDIRECT dir )
{
    DEV_IOPACKET _iop;
    DEV_IOSTATUS _nIoStatus;

    /*
     *  Verify descriptor
     */

    if ( !sys_valid_fd(fd) )
    {
        return -EBADF;
    }

    /*
     *  Dispatch
     */

    _iop.nIoOperation = DEVICE_IO_CONTROL;
    _iop.pDevice = (s_aryFileDesc[fd])->FileObj.pDeviceObj;
    _iop.pDescriptor = (DEV_PVOID)( &(s_aryFileDesc[fd])->FileObj );
    _iop.pInBuffer = (DEV_PVOID)dir;
    _iop.nInBufferLen = sizeof(DIRECT);
    _iop.nFunction =
        _IOCTL_MAKECODE(
        MAJOR_DEVNO( Device_GetId(_iop.pDevice) ),
        _FSD_IOCTL_READDIR, 0
    );

    _nIoStatus = IO_DISPATCH(&_iop);

    /*
     *  Return the result
     */

    return sys_stat_to_errno(_nIoStatus);
}

/*
 *  File I/O operations
 */

/* --------------------------------------------------------------------------
 *
 *  sys_creat
 *
 *      Creates a new file or opens and truncates an existing one.
 *
 *  Parameters:
 *      name    - Name of new file
 *      perm    - Permission setting
 *
 *  Returns:
 *      Returns a file handle for the opened directory if successful, other-
 *      wise -1.
 *
 *  Notes:
 *      If the file specified by filename does not exist, a new file is
 *      created with the given permission setting and is opened for writing.
 *      If the file already exists and its permission setting allows
 *      writing, _creat truncates the file to length 0, destroying the
 *      previous contents, and opens it for writing. The permission setting,
 *      pmode, applies to newly created files only.
 *
 * --------------------------------------------------------------------------
 */

FILEDESC sys_creat( char* name, int perm )
{
    int _nFlags = _OPEN_CREAT | _OPEN_TRUNC;

    if ( perm == _SMODE_IWRITE )
    {
        if ( perm == _SMODE_IREAD )
        {
            _nFlags += _OPEN_RDWR;
        }
        else
        {
            _nFlags += _OPEN_WRONLY;
        }
    }
    return sys_open( name, _nFlags, perm );
}

/* --------------------------------------------------------------------------
 *
 *  sys_open
 *
 *      The _open function opens the file specified by filename and
 *      prepares the file for reading or writing, as specified by flags
 *
 *  Parameters:
 *      name        - The fully qualified name of the file to open, which
 *                    includes the DEVICE Name and Path
 *      flags       - Types of operations allowed for this File Descriptor
 *      perm        - Permissions on a newly created file
 *
 *  Returns:
 *      Returns a file handle for the opened directory if successful, other-
 *      wise -1.
 *
 *  Notes:
 *      If file to OPEN is a directory, then special precautions should be
 *      noted and a familiarity of the directory structure used by the
 *      target file system is required. Otherwise, the directory could
 *      become corrupted, rendering it and all files and subdirectories
 *      within it useless.
 *
 * --------------------------------------------------------------------------
 */

FILEDESC sys_open( char* name, int flags, int perm )
{
    DEV_IOSTATUS _nIoStatus;

    FILEDESC _fd;
    FCB* _pFcb;

    /*
     *  Allocate the FCB for this file
     */

    _fd = sys_alloc_fd(name);
    if ( _fd != UNDEFINED_FILEDESC )
    {
        DEV_IOPACKET _iop;

        _pFcb = s_aryFileDesc[_fd];

        /*
         *  Dispatch
         */

        _iop.nIoOperation = DEVICE_IO_OPEN;
        _iop.pDevice = _pFcb->FileObj.pDeviceObj;
        _iop.pDescriptor = (DEV_PVOID)( &_pFcb->FileObj );
        _iop.pOutBuffer = (DEV_PVOID)( _pFcb->strPathname );
        _iop.nOutBufferLen = DEVOBJ_STRLEN(_pFcb->strPathname);
        _iop.nFunction = FSD_FLAGS(flags,perm);

        _nIoStatus = IO_DISPATCH(&_iop);

        /*
         *  On failure, release the File Descriptor and FCB
         */

        if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
        {
            sys_free_fd(&_fd);

            return sys_stat_to_errno(_nIoStatus);
        }
    }
    else
    {
        return -EBADF;
    }

    /*
     *  Return the file descriptor
     */

    return _fd;
}

/* --------------------------------------------------------------------------
 *
 *  sys_close
 *
 *      Closes a file specified with the file descriptor, fd
 *
 *  Parameters:
 *      fd          - File descriptor referring to open file
 *
 *  Returns:
 *      Returns result the result of the close (typically no failure unless
 *      the file descriptor is bad).
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

int sys_close( FILEDESC fd )
{
    DEV_IOPACKET _iop;
    DEV_IOSTATUS _nIoStatus;
    FCB* _pFcb;

    /*
     *  Valid File Descriptor?
     */

    if ( !sys_valid_fd(fd) )
    {
        return -EBADF;
    }

    _pFcb = s_aryFileDesc[fd];

    /*
     *  Dispatch
     */

    _iop.nIoOperation = DEVICE_IO_CLOSE;
    _iop.pDevice = _pFcb->FileObj.pDeviceObj;
    _iop.pDescriptor = (DEV_PVOID)( &_pFcb->FileObj );
    _iop.nFunction = 0;

    _nIoStatus = IO_DISPATCH(&_iop);

    /*
     *  On success, release the descriptor
     */

    if ( _DEV_IOSTATUS_SUCCEEDED(_nIoStatus) )
    {
        sys_free_fd(&fd);
    }

    /*
     *  Return the result
     */

    return sys_stat_to_errno(_nIoStatus);
}

/* --------------------------------------------------------------------------
 *
 *  sys_read
 *
 *      Reads a maximum of count bytes into buffer from the file associated
 *      with handle.
 *
 *  Parameters:
 *      fd          - File descriptor referring to open file
 *      buf         - Data buffer to read into
 *      count       - Number of bytes to read
 *
 *
 *  Returns:
 *      returns the number of bytes read, which may be less than count if
 *      there are fewer than count bytes left in the file. Returns a -1 on
 *      any other error.
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

int sys_read( FILEDESC fd, void* buf, unsigned int count )
{
    DEV_IOPACKET _iop;
    DEV_IOSTATUS _nIoStatus;
    FCB* _pFcb;

    /*
     *  Valid File Descriptor?
     */

    if ( !sys_valid_fd(fd) )
    {
        return -EBADF;
    }

    _pFcb = s_aryFileDesc[fd];

    /*
     *  Dispatch
     */

    _iop.nIoOperation = DEVICE_IO_READ;
    _iop.pDevice = _pFcb->FileObj.pDeviceObj;
    _iop.pDescriptor = (DEV_PVOID)( &_pFcb->FileObj );
    _iop.pInBuffer = buf;
    _iop.nInBufferLen = count;
    _iop.nFunction = 0;

    _nIoStatus = IO_DISPATCH(&_iop);
    if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
    {
        return sys_stat_to_errno(_nIoStatus);
    }

    /*
     *  Return the number of bytes read
     */

    return _iop.nInBufferLen;
}

/* --------------------------------------------------------------------------
 *
 *  sys_write
 *
 *      <Description>
 *
 *  Parameters:
 *      fd          - File descriptor referring to open file
 *      buf         - Data buffer to write from
 *      count       - Number of bytes to write
 *
 *  Returns:
 *      Returns the number of bytes actually written. If the actual space
 *      remaining on the disk is less than the size of the buffer the function
 *      is trying to write to the disk, write fails.
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

int sys_write( FILEDESC fd, void* buf, unsigned int count )
{
    DEV_IOPACKET _iop;
    DEV_IOSTATUS _nIoStatus;
    FCB* _pFcb;

    /*
     *  Valid File Descriptor?
     */

    if ( !sys_valid_fd(fd) )
    {
        return -EBADF;
    }

    _pFcb = s_aryFileDesc[fd];

    /*
     *  Dispatch
     */

    _iop.nIoOperation = DEVICE_IO_WRITE;
    _iop.pDevice = _pFcb->FileObj.pDeviceObj;
    _iop.pDescriptor = (DEV_PVOID)( &_pFcb->FileObj );
    _iop.pOutBuffer = buf;
    _iop.nOutBufferLen = count;
    _iop.nFunction = 0;

    _nIoStatus = IO_DISPATCH(&_iop);
    if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
    {
        return sys_stat_to_errno(_nIoStatus);
    }

    /*
     *  Return the number of bytes written
     */

    return _iop.nOutBufferLen;
}

/*
 *  Support functionality
 */

/* --------------------------------------------------------------------------
 *
 *  sys_tell
 *
 *      Gets the current position of the file pointer.
 *
 *  Parameters:
 *      fd          - File descriptor referring to open file
 *
 *  Returns:
 *      Returns the current position of the file pointer in the file. If a
 *      bad handle is passed in, then a -1 is returned.
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

FILEPOS sys_tell( FILEDESC fd )
{
    FCB* _pFcb;

    /*
     *  Valid File Descriptor?
     */

    if ( !sys_valid_fd(fd) )
    {
        return -EBADF;
    }

    _pFcb = s_aryFileDesc[fd];

    /*
     *  Return the current position
     */

    return _pFcb->FileObj.nPos;
}

/* --------------------------------------------------------------------------
 *
 *  sys_lseek
 *
 *      moves the file pointer associated with handle to a new location that
 *      is "offset" bytes from "origin"
 *
 *  Parameters:
 *      fd          - File descriptor referring to open file
 *      offset      - offset from the orign description
 *      origin      - 0 = beginning, 1 = current, 2 = end
 *
 *  Returns:
 *      Result of operation.
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

FILEPOS sys_lseek( FILEDESC fd, FILEPOS offset, int origin )
{
    DEV_IOPACKET _iop;
    DEV_IOSTATUS _nIoStatus;

    FILEPOS _nPos;
    FCB* _pFcb;

    /*
     *  Valid File Descriptor?
     */

    if ( !sys_valid_fd(fd) )
    {
        return -EBADF;
    }

    _pFcb = s_aryFileDesc[fd];

    /*
     *  Dispatch
     */

    _iop.nIoOperation = DEVICE_IO_CONTROL;
    _iop.pDevice = _pFcb->FileObj.pDeviceObj;
    _iop.pDescriptor = (DEV_PVOID)( &_pFcb->FileObj );
    _iop.pOutBuffer = (DEV_PVOID)&offset;
    _iop.nOutBufferLen = origin;
    _iop.pInBuffer = (DEV_PVOID)&_nPos;
    _iop.nFunction =
        _IOCTL_MAKECODE(
            MAJOR_DEVNO( _pFcb->FileObj.pDeviceObj->nDeviceNo ),
            _FSD_IOCTL_LSEEK, 0
        );

    _nIoStatus = IO_DISPATCH(&_iop);
    if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
    {
        return sys_stat_to_errno( _nIoStatus );
    }

    /*
     *  Return the current position
     */

    return _nPos;
}

/* --------------------------------------------------------------------------
 *
 *  sys_eof
 *
 *      Query to indicate whether the file pointer is at the end of the file
 *      or not.
 *
 *  Parameters:
 *      fd          - File Descriptor
 *
 *  Returns:
 *      Returns 1 if the current position is at the end of the file, 0
 *      otherwise. If a bad handle is passed in, then an error < 0 is
 *      returned.
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

int sys_eof( FILEDESC fd )
{
    FCB* _pFcb;
    DEV_INT _nEof;

    DEV_IOPACKET _iop;
    DEV_IOSTATUS _nIoStatus;

    /*
     *  Valid File Descriptor?
     */

    if ( !sys_valid_fd(fd) )
    {
        return -EBADF;
    }

    _pFcb = s_aryFileDesc[fd];

    /*
     *  Dispatch
     */

    _iop.nIoOperation = DEVICE_IO_CONTROL;
    _iop.pDevice = _pFcb->FileObj.pDeviceObj;
    _iop.pDescriptor = (DEV_PVOID)( &_pFcb->FileObj );
    _iop.pInBuffer = (DEV_PVOID)&_nEof;
    _iop.nFunction =
        _IOCTL_MAKECODE(
            MAJOR_DEVNO( _pFcb->FileObj.pDeviceObj->nDeviceNo ),
            _FSD_IOCTL_EOF, 0
        );

    _nIoStatus = IO_DISPATCH(&_iop);
    if ( _DEV_IOSTATUS_FAILED(_nIoStatus) )
    {
        return sys_stat_to_errno( _nIoStatus );
    }

    return _nEof;
}

/* --------------------------------------------------------------------------
 *
 *  sys_stat
 *
 *      Retrievs information about the file or directory specified and stores
 *      it in the structure, referenced via a pointer passed in.
 *
 *  Parameters:
 *      path    - Fully qualified pathname of the file or directory
 *      pstat   - Pointer to STAT structure in which the information is
 *                written to.
 *
 *  Returns:
 *      Result of operation.
 *
 *  Notes:
 *      No FCB is required when performing this operation.
 *
 *      The string passed in will have the device name parsed if a delimiter
 *      is found, leaving a "NULL" in the name. Clients should buffer the
 *      original string unless it is a one time use thing.
 *
 * --------------------------------------------------------------------------
 */

int sys_stat( char* name, PSTAT pstat )
{
    DEV_IOPACKET _iop;
    PFILE_OBJ _pFileObj;

    DEV_IOSTATUS _nIoStatus;
    DEV_STRING _strDevname = DEVOBJ_MALLOC( DEVOBJ_STRLEN(name)+1 );


    /*
     *  Dummy Loop
     */

    do
    {
        if ( _strDevname == 0 )
        {
            _nIoStatus = _DEV_IOSTATUS_NO_MEMORY;
            break;
        }

        DEVOBJ_STRCPY( _strDevname, name );

        /*
         *  Parse the device name out
         */

        name = StringParse( name, _strDevname, DEVNAME_DELIMETER );

        _iop.pDevice = IoManager_GetDeviceObject( _strDevname );
        DEVOBJ_FREE( _strDevname );

        if ( _iop.pDevice == 0 )
        {
            _nIoStatus = _DEV_IOSTATUS_NO_DEVICE;
            break;
        }

        /*
         *  Create a temporary FILE Object
         */

        _pFileObj = (PFILE_OBJ)DEVOBJ_MALLOC( sizeof(FILE_OBJ) );
        if ( _pFileObj == 0 )
        {
            _nIoStatus = _DEV_IOSTATUS_NO_MEMORY;
            break;
        }

        /*
         *  Assign the Device Object
         */

        _pFileObj->pDeviceObj = _iop.pDevice;

        /*
         *  Dispatch
         */

        _iop.nIoOperation = DEVICE_IO_CONTROL;
        _iop.pDevice = _pFileObj->pDeviceObj;
        _iop.nFunction =
            _IOCTL_MAKECODE(
                MAJOR_DEVNO( Device_GetId(_iop.pDevice) ),
                _FSD_IOCTL_FILESTAT, 0
            );

        _iop.pDescriptor = (DEV_PVOID)_pFileObj;
        _iop.pOutBuffer = (DEV_PVOID)name;
        _iop.nOutBufferLen = DEVOBJ_STRLEN(name);
        _iop.pInBuffer = (DEV_PVOID)pstat;
        _iop.nInBufferLen = sizeof(STAT);

        _nIoStatus = IO_DISPATCH(&_iop);
        DEVOBJ_FREE(_pFileObj);
    }
    while(0);

    /*
     *  Return the result
     */

    return sys_stat_to_errno(_nIoStatus);
}

/* --------------------------------------------------------------------------
 *
 *  sys_rename
 *
 *      The rename function renames the file or directory specified by
 *      "oldname" to the name given by "newname". The "oldname" must be the
 *      path of an existing file or directory.
 *
 *  Parameters:
 *      oldname     - String pointer to old name
 *      newname     - String pointer to new name
 *
 *  Returns:
 *      Result of operation.
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

int sys_rename( char* oldname, char* newname )
{
    DEV_IOPACKET _iop;
    DEV_IOSTATUS _nIoStatus;

    FILEDESC _fd = sys_alloc_fd(oldname);

    /*
     *  Valid file descriptor?
     */

    if ( _fd != UNDEFINED_FILEDESC )
    {
        /*
         *  Dispatch
         */

        _iop.nIoOperation = DEVICE_IO_CONTROL;
        _iop.pDevice = (s_aryFileDesc[_fd])->FileObj.pDeviceObj;
        _iop.nFunction =
            _IOCTL_MAKECODE(
                MAJOR_DEVNO( Device_GetId(_iop.pDevice) ),
                _FSD_IOCTL_RENAME, 0
            );

        _iop.pDescriptor = (DEV_PVOID)&(s_aryFileDesc[_fd])->FileObj;
        _iop.pOutBuffer = (DEV_PVOID)newname;
        _iop.nOutBufferLen = DEVOBJ_STRLEN(newname);
        _iop.pInBuffer = (DEV_PVOID)oldname;
        _iop.nInBufferLen = DEVOBJ_STRLEN(oldname);

        _nIoStatus = IO_DISPATCH(&_iop);
        sys_free_fd(&_fd);
    }

    /*
     *  Return the result
     */

    return sys_stat_to_errno(_nIoStatus);
}

/* --------------------------------------------------------------------------
 *
 *  sys_remove
 *
 *      Deletes the file specified by path.
 *
 *  Parameters:
 *      path        - Path of file to be removed
 *
 *  Returns:
 *      Returns 0 if the file is successfully deleted, otherwise.
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

int sys_remove( char* name )
{
    int _errno;
    STAT fs;

    do
    {
        /*
         *  Get statistics on the file, as if it is a directory, then the call
         *  is routed to "sys_rmdir".
         */

        _errno = sys_stat( name, &fs );
        if ( _ISERROR( _errno ) )
        {
            break;
        }

        /*
         *  Directory?
         */

        if ( ( fs.st_mode & _SMODE_IFMT ) == _SMODE_IFDIR )
        {
            _errno = sys_rmdir( name );
            break;
        }

        /*
         *  Regular File
         */

        else
        {
            int _fd = sys_open( name, _OPEN_DELETE, 0 );

            /*
             *  Error opening FILE?
             */

            if ( _ISERROR(_fd) )
            {
                _errno = _fd;
                break;
            }

            /*
             *  FILE will delete on CLOSE
             */

            _errno = sys_close( _fd );
        }
    }
    while (0);

    /*
     *  Return the result
     */

    return _errno;
}

/*
 *  End of file_api.c
 */

