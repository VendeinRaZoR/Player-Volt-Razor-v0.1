
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
 *  File System Driver Master Header File
 *
 *      This encapsulates drivers which are file systems or sub-systems of
 *      a file system.
 *
 *
 *      +-----------------------------------------------------------+
 *      |           I/O Application Programming Interface           |
 *      +-----------------------------------------------------------+
 *
 *      +-----------------------------------------------------------+
 *      |          +----------------------------------------------+ |
 *      |          |               File System Manager            | |
 *      |          +----------------------------------------------+ |
 *      |         +-------------------------------------------------+
 *      |         |
 *      |         |   +----------------------------+
 *      |         |   |     File System Driver     |
 *      |         |   +----------------------------+
 *      |   I/O   |                 ^
 *      |         |                 |
 *      |         |                 |
 *      | Manager |   +----------------------------+
 *      |         |   |    Filter Driver (opt)     |
 *      |         |   +----------------------------+
 *      |         |                 ^
 *      |         |                 |
 *      |         |                 |
 *      |         |   +----------------------------+
 *      |         |   |       Storage Device       |
 *      +---------+   +----------------------------+
 *
 *      +-----------------------------------------------------------+
 *      |                      Hardware Layer                       |
 *      +-----------------------------------------------------------+
 *
 *
 *  The File System is typically initialized after the I/O manager completes
 *  Device Initialization and setup. The File System WILL MOUNT Devices that
 *  Host File Systems typically, unless, the target environment allows 
 *  user mounting, dismounting explicitely.
 */

#ifndef __FSD_H
#define __FSD_H

#include "devobj.h"

#ifdef __cplusplus
extern "C" {
#endif

/*
 *  Types Specific TO FSD
 */

typedef struct _FileObj     FILE_OBJ;
typedef struct _FileObj*    PFILE_OBJ;

typedef struct _FileObj     DIR_OBJ;
typedef struct _FileObj*    PDIR_OBJ;

/*
 *  UNIX Compatible Objects
 */

typedef unsigned long DEV_ID;
typedef unsigned long DEV_INODE;

/*
 *  Directory Specific Information (UNIX Compatible)
 *
 *      For more detailed information on the Directory, USE the STAT Function
 *      on the entry name.
 */

#define DIRSIZE         32

struct _direct
{
    DEV_INODE   d_ino;              /* Inode number of file (optional)      */
    char        d_name[DIRSIZE];    /* Name of the file                     */
};

typedef struct _direct  DIRECT;
typedef struct _direct* PDIRECT;

/*
 *  STAT structure, mimics that of Unix, but MAY not use all fields
 */

struct _stat
{
    DEV_ID      st_dev;         /* Device ID or Drive the file resides on   */
    DEV_INODE   st_ino;         /* Inode number of file (optional)          */
    short       st_mode;        /* Bit mask for file-mode information       */
    short       st_nlink;       /* Number of linkes to the file (optional)  */
    short       st_uid;         /* User ID of the file                      */
    short       st_gid;         /* Group ID of the file                     */
    DEV_ID      st_rdev;        /* Not used, for compatibility only         */
    long        st_size;        /* Size of the File                         */
    DEV_TIME    st_atime;       /* Time file was last accessed              */
    DEV_TIME    st_mtime;       /* Time file was last modified              */
    DEV_TIME    st_ctime;       /* Time file was created                    */
};

typedef struct _stat    STAT;
typedef struct _stat*   PSTAT;

/*
 *  Directory Delimiters/Tokens
 */

#define _CURDIR                 "."
#define _CURDIR_LEN             (sizeof(_CURDIR) - 1)

#define _PREVDIR                ".."
#define _PREVDIR_LEN            (sizeof(_PREVDIR) - 1)

#define _PATH_DELIMITER         "\\"
#define _PATH_DELIMITER_LEN     (sizeof(_PATH_DELIMITER) - 1)

/*
 *  File Object
 *
 *      The File Object is a driver level view (generic) of the Open 
 *      File. It contains information specific to an open file on that 
 *      device. It is always the first argument to any of the calls into
 *      the FSD, thus it must be allocated by a higher level in which case
 *      is indexed via a descriptor of some sort.
 *
 *      +-------------------+
 *      |  File Descriptor  |
 *      +-------------------+
 *                |
 *                |          +-------------------+
 *                +--------->|    File Object    |
 *                           +-------------------+
 *                                       |
 *                                       |          +-------------------+
 *                                       +--------->|  File Extension   |
 *                                                  +-------------------+
 *
 *      The FILE Descriptor may be a pointer directly to the FILE Object
 *      wrapping calls to it. Or it may have additional and/or duplicate
 *      information that is more Application Accessible. 
 */

struct _FileObj
{

#ifndef _FILES_MUTUAL_EXCLUSION

    /*
     *  The next FILE Object for this file (only if NON-MUTUAL EXCLUSION)
     */

    PFILE_OBJ       pNextFileObj;

#endif

    /*
     *  Device that the file object is binded to
     */

    PDEVICE_OBJ     pDeviceObj;

    /*
     *  Status Flags of the File object
     */
    
    DEV_ULONG       nFlags;

    /*
     *  Position within the FILE
     */

    DEV_ULONG       nPos;

    /*
     *  This part of the file object is specific to the FSD Driver.
     */
    
    DEV_PVOID       pFileExt;

    /*
     *  The FILE BUFFER
     */

    DEV_INT         nBufferLen;
    DEV_USTRING     pBuffer;
};

enum _FileOpt
{
    /*
     *  Open Options
     */

    _FileOpt_OpenRead       = 0x0001,
    _FileOpt_OpenWrite      = 0x0002,
    _FileOpt_OpenText       = 0x0004,
    _FileOpt_OpenDelete     = 0x0008,

    /*
     *  Miscellaneous Settings
     */

    _FileOpt_Directory      = 0x0100,
    _FileOpt_Locked         = 0x0200,

    /*
     *  Dynamic Statuses
     */

    _FileOpt_Updated        = 0x1000,
    _FileOpt_Eof            = 0x2000
};

#define File_IsOpen(fobj) \
    (((fobj) != 0) && ((fobj)->nFlags & (_FileOpt_OpenRead | _FileOpt_OpenWrite)))

#define File_IsReadable(fobj) \
    ((fobj)->nFlags & _FileOpt_OpenRead)

#define File_IsWritable(fobj) \
    ((fobj)->nFlags & _FileOpt_OpenWrite)

#define File_IsTextMode(fobj) \
    ((fobj)->nFlags & _FileOpt_OpenText)

#define File_DeleteOnClose(fobj) \
    ((fobj)->nFlags & _FileOpt_OpenDelete)

#define File_IsDirectory(fobj) \
    ((fobj)->nFlags & _FileOpt_Directory)

#define File_IsLocked(fobj) \
    ((fobj)->nFlags & _FileOpt_Locked)

/*
 *  File Attributes
 *
 *      Mapping of Attributes to the files system, is a file system dependent 
 *      operation. These are set on creation of a file and can be changed 
 *      using a set or get attribute.
 */

/*
 *  PERMISSION FLAGS
 */

enum _PMODE
{
    _PMODE_NONE         = 0x0000,
    _PMODE_READ         = 0x0001,
    _PMODE_WRITE        = 0x0002,
    _PMODE_EXECUTE      = 0x0004
};

#define _PMODE_RDWR     ( _PMODE_READ | _PMODE_WRITE )

/*
 *  MODE Flags of the FILE
 */

#define _SMODE_IFMT         0xF000

#define _SMODE_IFREG        0x0000
#define _SMODE_IFBLK        0x1000
#define _SMODE_IFCHR        0x2000
#define _SMODE_IFDIR        0x3000
#define _SMODE_IFIFO        0x4000

#define _SMODE_ISUID        0x0800
#define _SMODE_ISGID        0x0400
#define _SMODE_IREAD        0x0100
#define _SMODE_IWRITE       0x0080
#define _SMODE_IEXEC        0x0040

#define _SMODE_IRDWR        ( _SMODE_IREAD | _SMODE_IWRITE )

/*
 *  Open Flags
 *  
 *      Determines how the file is open or created.
 */

enum _OPEN
{
    _OPEN_RDONLY        = 0x0000,
    _OPEN_WRONLY        = 0x0001,
    _OPEN_RDWR          = 0x0002,
    _OPEN_APPEND        = 0x0008,
    _OPEN_RANDOM        = 0x0010,
    _OPEN_SEQUENTIAL    = 0x0020,
    _OPEN_CREAT         = 0x0100,
    _OPEN_TRUNC         = 0x0200,
    _OPEN_EXCL          = 0x0400,
    _OPEN_DELETE        = 0x1000,
    _OPEN_TEXT          = 0x4000,
    _OPEN_BINARY        = 0x8000,
};

#define FSD_FLAGS(oflag,pmode) \
    ((DEV_ULONG)oflag | ((DEV_ULONG)pmode << 16))

#define FSD_OFLAGS(f) \
    ((f) & 0x0000FFFF)

#define FSD_PMODE(f) \
    ((f) >> 16)

/*
 *  Seek Flags
 */

enum _SEEK
{
    _SEEK_BEG =     0,
    _SEEK_CUR =     1,
    _SEEK_END =     2
};

/*
 *  Semantic Redefs...
 */

#define Fsd_IsMounted(fsd) \
    Device_IsOnline(fsd)

#define Fsd_IsFormatted(fsd) \
    Device_IsInitialized(fsd)

/*
 *  FSD Codes (generally applied to all File System Drivers
 */

#define _FSD_IOSTATUS_MAKE( Error, Severity ) \
    _DEV_IOSTATUS_MAKE(DEVICE_CLASS_FILE_SYSTEM,Error,Severity)


#define FSD_IOSTATUS_SUCCESS \
    _FSD_IOSTATUS_MAKE(_DEV_IOSTATUS_SUCCESS,_DEV_IOSTATUS_SEVERITY_NONE)

#define FSD_IOSTATUS_OUT_OF_MEMORY \
    _FSD_IOSTATUS_MAKE(_DEV_IOSTATUS_NO_MEMORY,_DEV_IOSTATUS_SEVERITY_ERROR)

#define FSD_IOSTATUS_FILE_NOT_FOUND \
    _FSD_IOSTATUS_MAKE(_DEV_IOSTATUS_FILE_NOT_FOUND,_DEV_IOSTATUS_SEVERITY_ERROR)

#define FSD_IOSTATUS_PATH_NOT_FOUND \
    FSD_IOSTATUS_FILE_NOT_FOUND

#define FSD_IOSTATUS_ACCESS_DENIED \
    _FSD_IOSTATUS_MAKE(_DEV_IOSTATUS_ACCESS_DENIED,_DEV_IOSTATUS_SEVERITY_ERROR)

#define FSD_IOSTATUS_NOT_FORMATTED \
    _FSD_IOSTATUS_MAKE(_DEV_IOSTATUS_FORMAT,_DEV_IOSTATUS_SEVERITY_ERROR)

#define FSD_IOSTATUS_INVALID_FORMATTED \
    _FSD_IOSTATUS_MAKE(_DEV_IOSTATUS_MEDIUM_TYPE,_DEV_IOSTATUS_SEVERITY_ERROR)

#define FSD_IOSTATUS_DIRECTORY_NOT_EMPTY \
    _FSD_IOSTATUS_MAKE(_DEV_IOSTATUS_NOT_EMPTY,_DEV_IOSTATUS_SEVERITY_ERROR)

#define FSD_IOSTATUS_SEEK_INVALID \
    _FSD_IOSTATUS_MAKE(_DEV_IOSTATUS_SEEK,_DEV_IOSTATUS_SEVERITY_ERROR)

#define FSD_IOSTATUS_READ_FAULT \
    _FSD_IOSTATUS_MAKE(_DEV_IOSTATUS_IOERROR,_DEV_IOSTATUS_SEVERITY_ERROR)

#define FSD_IOSTATUS_WRITE_FAULT \
    FSD_IOSTATUS_READ_FAULT

#define FSD_IOSTATUS_END_OF_FILE \
    FSD_IOSTATUS_READ_FAULT

#define FSD_IOSTATUS_WRITE_PROTECT \
    _FSD_IOSTATUS_MAKE(_DEV_IOSTATUS_ACCESS_DENIED,_DEV_IOSTATUS_SEVERITY_ERROR)

#define FSD_IOSTATUS_SYSTEM_FULL \
    _FSD_IOSTATUS_MAKE(_DEV_IOSTATUS_SPACE,_DEV_IOSTATUS_SEVERITY_ERROR)

#define FSD_IOSTATUS_DIRECTORY_FULL \
    _FSD_IOSTATUS_MAKE(_DEV_IOSTATUS_FILE_TABLE,_DEV_IOSTATUS_SEVERITY_ERROR)

#define FSD_IOSTATUS_FILE_EXISTS \
    _FSD_IOSTATUS_MAKE(_DEV_IOSTATUS_FILE_EXISTS,_DEV_IOSTATUS_SEVERITY_ERROR)

#define FSD_IOSTATUS_FILE_EMPTY \
    _FSD_IOSTATUS_MAKE(_DEV_IOSTATUS_NO_DATA,_DEV_IOSTATUS_SEVERITY_ERROR)

#define FSD_IOSTATUS_NOT_MOUNTED \
    _FSD_IOSTATUS_MAKE(_DEV_IOSTATUS_NOT_MOUNTED,_DEV_IOSTATUS_SEVERITY_ERROR)
    
#define FSD_IOSTATUS_INVALID_FUNCTION \
    _FSD_IOSTATUS_MAKE(_DEV_IOSTATUS_INVALID_FUNCTION,_DEV_IOSTATUS_SEVERITY_ERROR)

#define FSD_IOSTATUS_SECTOR_FAULT \
    _FSD_IOSTATUS_MAKE(_DEV_IOSTATUS_BAD_ADDRESS,_DEV_IOSTATUS_SEVERITY_ERROR)

#define FSD_IOSTATUS_NOT_DIRECTORY \
    _FSD_IOSTATUS_MAKE(_DEV_IOSTATUS_NOT_DIRECTORY,_DEV_IOSTATUS_SEVERITY_ERROR) 

#define FSD_IOSTATUS_IS_DIRECTORY \
    _FSD_IOSTATUS_MAKE(_DEV_IOSTATUS_DIRECTORY,_DEV_IOSTATUS_SEVERITY_ERROR) 

/*
 *  IOCTL DEF
 */

enum _FSD_IOCTL
{
    /*
     *  Volume Specifics
     */

    _FSD_IOCTL_MOUNT    = DEVICE_IOCTL_END,
    _FSD_IOCTL_UNMOUNT,
    _FSD_IOCTL_FORMAT,

    /*
     *  File Specific
     */

    _FSD_IOCTL_LSEEK,
    _FSD_IOCTL_RENAME,
    _FSD_IOCTL_REMOVE,
    _FSD_IOCTL_MKDIR,
    _FSD_IOCTL_RMDIR,
    _FSD_IOCTL_FILESIZE,
    _FSD_IOCTL_OPENDIR,
    _FSD_IOCTL_READDIR,
    _FSD_IOCTL_SEEKDIR,
    _FSD_IOCTL_FILESTAT,
    _FSD_IOCTL_EOF
};

#ifdef __cplusplus
}
#endif

#endif
