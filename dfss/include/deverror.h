
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
 *  deverror.h
 */

#ifndef __DEVERROR_H
#define __DEVERROR_H

/*
 *  Traditional UNIX codes
 */

#ifdef __cplusplus
extern "C" {
#endif

#define EFAIL           0x7FFF      /* General Failure Error                */
#define ESUCCESS        0           /* Success on operation                 */
#define ESUCC           ESUCCESS

/*
 *  Compatibility Error Codes
 */

#define EPERM           1           /* Operation Not Permitted              */
#define ENOENT          2           /* No such file or directory            */
#define ESRCH           3           /* No such Process                      */
#define EINTR           4           /* Interrupted System Call              */
#define EIO             5           /* I/O Error                            */
#define ENXIO           6           /* No such device or address            */
#define E2BIG           7           /* Argument list too long               */
#define ENOEXEC         8           /* Exec format error                    */
#define EBADF           9           /* Bad file number                      */
#define ECHILD          10          /* No spawned processes                 */
#define EAGAIN          11          /* Try again                            */
#define ENOMEM          12          /* Not enough memory                    */
#define EACCES          13          /* Permission denied                    */
#define EFAULT          14          /* Bad address                          */
#define ENOTBLK         15          /* Block device required                */
#define EBUSY           16          /* Device or resource is busy           */
#define EEXIST          17          /* File exists                          */
#define EXDEV           18          /* Cross-device link                    */
#define ENODEV          19          /* No such device                       */
#define ENOTDIR         20          /* Not a directory                      */
#define EISDIR          21          /* Is a directory                       */
#define EINVAL          22          /* Invalid argument                     */
#define ENFILE          23          /* File table overflow                  */
#define EMFILE          24          /* Too many open files                  */
#define ENOTTY          25          /* Not a typewriter                     */
#define ETXTBSY         26          /* Text file busy                       */
#define EFBIG           27          /* File too large                       */
#define ENOSPC          28          /* No space left on device              */
#define ESPIPE          29          /* Illegal seek                         */
#define EROFS           30          /* Read-only file system                */
#define EMLINK          31          /* Too many links                       */
#define EPIPE           32          /* Broken PIPE                          */
#define EDOM            33          /* Math argument                        */
#define ERANGE          34          /* Result too large                     */
#define EDEADLK         35          /* Resource deadlock would occur        */
#define ENAMETOOLONG    36          /* File name is too long                */
#define ENOLCK          37          /* No record locks available            */
#define ENOSYS          38          /* Function not implemented             */
#define ENOTEMPTY       39          /* Directory not empty                  */
#define ELOOP           40          /* Too many symbolic links encountered  */

#define EWOULDBLOCK     EAGAIN      /* Operation would block                */
#define EDEADLOCK       EDEADLK

#define ENOSTR          60          /* Device is not a stream               */
#define ENODATA         61          /* No data available                    */
#define ETIME           62          /* Timer Expired                        */

#define ENOMEDIUM       123         /* No medium found (not mounted)        */
#define EMEDIUMTYPE     124         /* Invalid medium type                  */

/*
 *  DEV_IOSTATUS
 *
 *      Functionality of the Driver is performed using something similar to
 *      a UNIX/Linux ioctl call.
 *
 *           31 30 29              16 15               0
 *          +-----+------------------+------------------+
 *          | Sev |   Device Type    |    Error Code    |
 *          +-----+------------------+------------------+
 *
 *
 *      The Device Type is also known as the Device Class or Facility
 */

typedef unsigned long       DEV_IOSTATUS;

/*
 *  Error Severity Levels
 *
 *      0   - Operation was Successful
 *      1   - Operation was Successful, but with Warnings
 *      2   - Operation was Unsuccessful (failed)
 *      3   - Operation caused a Catastrophic Failure
 */

#define _DEV_IOSTATUS_SEVERITY_NONE         0
#define _DEV_IOSTATUS_SEVERITY_WARNING      1
#define _DEV_IOSTATUS_SEVERITY_ERROR        2
#define _DEV_IOSTATUS_SEVERITY_FAILURE      3

#define _DEV_IOSTATUS_MAKE( DevClass, Error, Severity ) \
    ( ((DEV_IOSTATUS)(Severity) << 30) | \
        (((DEV_IOSTATUS)(DevClass) & 0x3FFF) << 16) | \
        (DEV_IOSTATUS)(Error & 0x0000FFFF) )

#define _DEV_IOSTATUS_CODE(err)             ( (err) & 0x0000FFFF )
#define _DEV_IOSTATUS_CLASS(err)            ( ((err) >> 16) & 0x3FFF )
#define _DEV_IOSTATUS_SEVERITY(err)         ( (err) >> 30 )

/*
 *  Queries
 */

#define _DEV_IOSTATUS_SUCCEEDED(err) \
    !( _DEV_IOSTATUS_SEVERITY(err) & _DEV_IOSTATUS_SEVERITY_ERROR )

#define _DEV_IOSTATUS_FAILED(err) \
    ( _DEV_IOSTATUS_SEVERITY(err) & _DEV_IOSTATUS_SEVERITY_ERROR )

/*
 *  Standard Codes (lower 16 bits)
 */

/* 
 *
 */

#define _DEV_IOSTATUS_FAILURE               0x00007fffL

/* 
 *
 */

#define _DEV_IOSTATUS_SUCCESS               0L

/* 
 *
 */

#define _DEV_IOSTATUS_OPERATION             1L

/* 
 *
 */

#define _DEV_IOSTATUS_FILE_NOT_FOUND        2L

/* 
 *
 */

#define _DEV_IOSTATUS_PROCESS               3L

/* 
 *
 */

#define _DEV_IOSTATUS_IOERROR               5L

/* 
 *
 */

#define _DEV_IOSTATUS_FORMAT                8L

/* 
 *
 */

#define _DEV_IOSTATUS_BAD_DESCRIPTOR        9L

/* 
 *
 */

#define _DEV_IOSTATUS_RETRY                 11L

/* 
 *
 */

#define _DEV_IOSTATUS_NO_MEMORY             12L

/* 
 *
 */

#define _DEV_IOSTATUS_ACCESS_DENIED         13L

/* 
 *
 */

#define _DEV_IOSTATUS_BAD_ADDRESS           14L

/* 
 *
 */

#define _DEV_IOSTATUS_BUSY                  16L

/* 
 *
 */

#define _DEV_IOSTATUS_FILE_EXISTS           17L

/* 
 *
 */

#define _DEV_IOSTATUS_NO_DEVICE             19L

/* 
 *
 */

#define _DEV_IOSTATUS_NOT_DIRECTORY         20L

/* 
 *
 */

#define _DEV_IOSTATUS_DIRECTORY             21L

/* 
 *
 */

#define _DEV_IOSTATUS_ARGUMENT              22L

/* 
 *
 */

#define _DEV_IOSTATUS_FILE_TABLE            23L

/* 
 *
 */

#define _DEV_IOSTATUS_TOO_MANY_FILES        24L

/* 
 *
 */

#define _DEV_IOSTATUS_FILE_BIG              27L

/* 
 *
 */

#define _DEV_IOSTATUS_SPACE                 28L

/* 
 *
 */

#define _DEV_IOSTATUS_SEEK                  29L

/* 
 *
 */

#define _DEV_IOSTATUS_FILENAME_BIG          36L

/* 
 *
 */

#define _DEV_IOSTATUS_INVALID_FUNCTION      38L

/* 
 *
 */

#define _DEV_IOSTATUS_NOT_EMPTY             39L

/* 
 *
 */

#define _DEV_IOSTATUS_NOT_STREAM            60L

/* 
 *
 */

#define _DEV_IOSTATUS_NO_DATA               61L

/* 
 *
 */

#define _DEV_IOSTATUS_TIMER                 62L

/* 
 *
 */

#define _DEV_IOSTATUS_NOT_MOUNTED           123L

/* 
 *
 */

#define _DEV_IOSTATUS_MEDIUM_TYPE           124L

#ifdef __cplusplus
}
#endif

#endif

