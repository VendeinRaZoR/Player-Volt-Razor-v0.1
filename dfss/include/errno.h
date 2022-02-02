

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
 *  errno.h
 *
 *      These are the compatible UNIX/LINUX error codes
 */

#ifndef __ERRNO_H
#define __ERRNO_H

#ifdef __cplusplus
extern "C" {
#endif

#define EFAIL           -1          /* General Failure Error                */
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

#ifdef __cplusplus
}
#endif

#endif
