
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
 *  devobj.h
 *
 *      To make a generic interface to drivers, an approach similar to that of
 *      Microsoft's Driver Model in Windows is used. Although it's not a direct
 *      implementation of the Microsoft Approach, it does have some familiar
 *      concepts but simplifies it for use in an embedded platform.
 *
 *      Devices are a many to one configuration in which there may be more than
 *      one upper level driver to a single driver at a lower level. This is an
 *      inverted tree approach. For example a particular file system may reside
 *      on three physical devices, but with partitioning, there may be five of
 *      these File System Device objects:
 *
 *              +-----+  +-----+  +-----+  +-----+  +-----+
 *              |     |  |     |  |     |  |     |  |     |
 *              +-----+  +-----+  +-----+  +-----+  +-----+
 *                 |        |        |        |        |
 *                 +--------+        |        +--------+
 *                      |            |            |
 *                   +-----+      +-----+      +-----+
 *                   |     |      |     |      |     |
 *                   +-----+      +-----+      +-----+
 *
 *
 *      OBJECTS in the Device Model
 *      ---------------------------
 *
 *      DRIVER OBJECT - The Driver Object hosts the API for a device or class
 *                      of devices, if it manages more than a single device.
 *                      The driver class is denoted by a 16 bit ID and all
 *                      devices within that Driver are prefaced with the 16
 *                      bit value along with their assigned 16 bit ID.
 *
 *      DEVICE OBJECT - The Device Object describes a specific device, logical
 *                      or physical. Eventually a device in a chain must
 *                      correspond to a physical device, which populate the
 *                      bottom level of the tree.
 *
 *      A "Driver" object may have one or more "Device" objects, but a
 *      A "Device" object may only be assigned to one Driver. A "Device" object
 *      may only bind to one "Device" object below it, but a "Device" object
 *      may have more than one "Device" objects binded to it from above.
 *
 *      What is not covered here is the link between the I/O Application or
 *      Manager and the driver. This is usually the repository for File
 *      Descriptors. Somehow the File Descriptor in question must have a
 *      provide a means, via a pointer to the Device Object at the Highest
 *      Level.
 *
 *      When an application opens a device, the device name it uses pertains
 *      to a pointer to a specific DeviceObject. This device object, describes
 *      the specifics of that particular device and points to a driver object
 *      that contains the API of it.
 *
 *      The application file descriptor, usually managed by the Application
 *      I/O Layer or Manager, must contain a pointer or a method by which to
 *      obtain a pointer to the Device it refers to.
 *
 *  NOTE:
 *
 *      All Device Objects, ALL OF THEM, MUST use a 0 based offset when doing
 *      addressing. Even if the device reserves the first part of a device for
 *      internal use, the client device that binds to it, uses addressing
 *      beginning at "0".
 */

#ifndef __DEVOBJ_H
#define __DEVOBJ_H

#include "devbuild.h"
#include "platform.h"

#include "deverror.h"

#ifdef __cplusplus
extern "C" {
#endif

/*
 *  Generic types in the DEVOBJ Model
 */

typedef char                    DEV_CHAR;
typedef unsigned char           DEV_UCHAR;
typedef unsigned char           DEV_BYTE;

typedef int                     DEV_INT;
typedef short int               DEV_SHORT;
typedef long int                DEV_LONG;

typedef unsigned int            DEV_UINT;
typedef unsigned short int      DEV_USHORT;
typedef unsigned long int       DEV_ULONG;

typedef void*                   DEV_PVOID;
typedef char*                   DEV_STRING;
typedef unsigned char*          DEV_USTRING;
typedef int                     DEV_BOOL;

typedef DEV_ULONG               DEV_IOCODE;
typedef DEV_ULONG               DEV_TYPE;

/*
 *  Size types
 */

typedef unsigned char           DEV_UINT8;
typedef unsigned short int      DEV_UINT16;
typedef unsigned long int       DEV_UINT32;

/*
 *  Objects
 */

typedef struct _DeviceObj       DEVICE_OBJ;
typedef struct _DriverObj       DRIVER_OBJ;

typedef struct _DeviceObj*      PDEVICE_OBJ;
typedef struct _DriverObj*      PDRIVER_OBJ;

/*
 *  Device functionality
 */

typedef union _DevAddress       DEV_ADDRESS;
typedef struct _DeviceIoPacket  DEV_IOPACKET;
typedef DEV_IOPACKET*           PDEV_IOPACKET;

/*
 *  Dispatch Operation
 */

typedef DEV_IOSTATUS (*PIODISPATCH)( PDEV_IOPACKET pIoPacket );

/*
 *  Compiler Specifics
 */

#define DEVOBJ_CONST
#define DEVOBJ_PRIVATE          static
#define DEVOBJ_PROTECTED
#define DEVOBJ_PUBLIC           
#define DEVOBJ_NULL             0
#define DEVOBJ_EOS              '\0'

enum
{
    DEVOBJ_FALSE   = 0,
    DEVOBJ_TRUE
};

/*
 *  DEVICE IDs or Numbers are similar to the Unix, where the device is a 
 *  special type of file, stored in the path \dev. Since this method was 
 *  relatively a simple interpretation of the device it is carried over to 
 *  the implementation of the Device Object.
 *
 *      MAJOR_DEVNO     - This indicates the Classification of the Device. It
 *                        is 14 bits in length.
 *
 *      MINOR_DEVNO     - This is the identification of exactly which device
 *                        in the device class is to be accessed. This is a 16
 *                        bit value.
 *
 *
 *      The upper 2 bits of the ID contains special information such as if the
 *      device supports Block I/O.
 *
 *           31    29             15                   0
 *          +-----+---------------+---------------------+
 *          | TYP |   Major NO.   |      Minor NO.      |
 *          +-----+---------------+---------------------+
 */

#define MAKE_DEVNO(type,major,minor) \
    (((DEV_TYPE)(type) << 30) | (((DEV_TYPE)(major) & 0x00003FFFL) << 16) \
        | ((DEV_TYPE)(minor) & 0x0000FFFFL))

/*
 *  Extracting device information
 */

#define MAJOR_DEVNO(dev)        (((DEV_TYPE)(dev) >> 16) & 0x00003FFFL)
#define MINOR_DEVNO(dev)        ((DEV_TYPE)(dev) & 0x0000FFFFL)
#define ACCESS_TYPE(dev)        ((DEV_TYPE)(dev) >> 30)

/*
 *  Type of Device
 *
 *      Bits 30 and 31 specify characteristics of the device, such as if the
 *      the device is character or block.
 *
 *      A Block Device that supports both Character and Block should define
 *      itself as Character and use Smart Read/Writes depending on buffer
 *      size passed.
 *
 *          CHAR        - Device supports Character Read and Writes
 *          BLOCKREAD   - Device supports Block Reads (very rarely will this
 *                        be set to this only, unless it's a read only
 *                        device.
 *          BLOCKWRITE  - Device supports Block Writes
 *          BLOCKONLY   - Device supports only Block Read and Writes
 *
 *      Typically for binding purposes the TYPE is left as Unknown, until the
 *      Bind occurs at which time a STAT call will reveal the Binded Devices
 *      Read/Write capability.
 */

#define DEVICE_TYPE_CHAR        0x00000000
#define DEVICE_TYPE_BLOCKREAD   0x00000004
#define DEVICE_TYPE_BLOCKWRITE  0x00000008
#define DEVICE_TYPE_BLOCK       0x0000000C

#define DEVICE_TYPE_UNKNOWN     DEVICE_TYPE_CHAR

#define DEVICE_TYPE_ISBLOCK(dev_id) \
    ( ACCESS_TYPE(dev_id) & DEVICE_TYPE_BLOCK )

/*
 *  Device CLASSES - Drivers can also use the CLASS ID as the MAJOR Number
 *  in the Device Type. Typically this is OK for generic or class drivers
 *  but in most cases, the Driver shall have a distinguishable MAJOR Number
 *  Specifying the Driver alliance and a sequentially incrementing MINOR
 *  Number for each Device managed by the Driver to simplify things some.
 */

#define DEVICE_CLASS_UNKNOWN            0x0000
#define DEVICE_CLASS_GENERIC            0x0001
#define DEVICE_CLASS_CDROM              0x0002
#define DEVICE_CLASS_DISK               0x0003
#define DEVICE_CLASS_DVD                0x0004
#define DEVICE_CLASS_FILE_SYSTEM        0x0005
#define DEVICE_CLASS_FLASH_MEMORY       0x0006
#define DEVICE_CLASS_IEEE1394           0x0007
#define DEVICE_CLASS_INPORT             0x0008
#define DEVICE_CLASS_KEYBOARD           0x0009
#define DEVICE_CLASS_NETWORK            0x000A
#define DEVICE_CLASS_OUTPORT            0x000B
#define DEVICE_CLASS_PARALLEL_PORT      0x000C
#define DEVICE_CLASS_PCI                0x000D
#define DEVICE_CLASS_PRINTER            0x000E
#define DEVICE_CLASS_SERIAL_PORT        0x000F
#define DEVICE_CLASS_SCSI               0x0010
#define DEVICE_CLASS_TAPE               0x0011
#define DEVICE_CLASS_USB                0x0012
#define DEVICE_CLASS_VIDEO              0x0013
#define DEVICE_CLASS_SOUND              0x0014
#define DEVICE_CLASS_FLOPPY             0x0015
#define DEVICE_CLASS_MASS_STORAGE       0x0016

/*
 *  Special Devices...
 */

#define DEVICE_NULL             0
#define DEVICE_UNKNOWN          (DEV_TYPE)-1

/*
 *  Addressing within the device
 */

union _DevAddress
{
    /*
     *  Character Device
     */

    DEV_ULONG   nOffset;

    /*
     *  Block Device
     */

    struct
    {
        DEV_ULONG   nOffset;
        DEV_ULONG   nBlock;
    }
    nBlockAddress;
};

#define MAKE_DEVADDR(addr,blk,off) \
    (addr)->nBlockAddress.nOffset = (off); \
    (addr)->nBlockAddress.nBlock = (blk)

/*
 *  Device Functionality
 *
 *      Two approaches were considered for use here: Linux and WDM.
 *
 *      The one used by Microsoft was preferred, since it provides an
 *      extensible interface down the road as more methods are added. This
 *      method then uses a IoPacket to do it's request with similar to the
 *      IRP (I/O Request Packet), but much simplier.
 *
 *      The problem with the Linux approach is that a structure of pointers
 *      will change over time and requires versioning of interfaces. Or
 *      some special compiler support such as "tagged" format of structures,
 *      which GCC does in fact support but does not provide for a portable
 *      code base.
 *
 *      Currently the Device Operations are as follows:
 *
 *          OPEN    - Open a device or a file on a device.
 *          CLOSE   - Close a device or file on a device.
 *          READ    - Read from the device
 *          WRITE   - Write to the device
 *          IOCTL   - Perform a special operation on the device
 *
 *      The I/O Packet is straight forward. THe contents of the input and out-
 *      put buffers in the packet are device specific and the I/O Manager
 *      calling should have some knowledge.
 *
 */

enum _DEVICE_IO
{
    DEVICE_IO_OPEN      = 0x0000,
    DEVICE_IO_CLOSE,
    DEVICE_IO_READ,
    DEVICE_IO_WRITE,
    DEVICE_IO_CONTROL,

    DEVICE_IO_END
};

#define DEVICE_IO_NUMOPS        DEVICE_IO_END

struct _DeviceIoPacket
{
    /*
     *  The Target Device Object the packet is intended for
     */

    PDEVICE_OBJ     pDevice;

    /*
     *  One of the "5" I/O Operations listed above...
     */

    DEV_SHORT       nIoOperation;

    /*
     *  The function to perform for that I/O operation. Although this only
     *  seems to make sense for IO CONTROL type calls, other operations may
     *  themselves have sub-functionality built in.
     *
     *  This can also be used as an ATTRIBUTE FIELD as Well
     */

    DEV_IOCODE      nFunction;

    /*
     *  The Descriptor for the device, which contains at the very least
     *  address information for the target.
     */

    DEV_PVOID       pDescriptor;

    /*
     *  The data sent out to the device by the caller
     *
     *      This buffer contains Outgoing Data to the Device. In another words
     *      for WRITE ACCESS operations. The buffer length specifies the
     *      number of bytes to write in the buffer (usually the buffer length
     *      itself, but not greater than) on input to the device. On output,
     *      it specifies the number actually written. On bytes to write not
     *      equal to bytes written, an error is also returned.
     */

    DEV_PVOID       pOutBuffer;
    DEV_LONG        nOutBufferLen;

    /*
     *  The data returned to the caller from the device.
     *
     *      This buffer contains Incoming Data from the Device. In another
     *      words for READ ACCESS operations. The buffer length typically
     *      specifies the length of data to read on input to the device, but
     *      return value is the data actually read. In the case data requested
     *      not equal to data actually read, an error code is returend as
     *      well.
     */

    DEV_PVOID       pInBuffer;
    DEV_LONG        nInBufferLen;
};

/*
 *  Device interaction
 */

#define IO_DISPATCH(piop) \
    (*(piop)->pDevice->pDrvParent->pIoDispatch)(piop)

extern DEV_IOSTATUS DevObj_NullHandler( PDEV_IOPACKET pIoPacket );

#define IO_NULLHANDLER \
    DevObj_NullHandler

/*
 *  IOCTL
 *
 *      Functionality of the Driver is performed using something similar to
 *      a UNIX/Linux ioctl call.
 *
 *           31    29             15       13            0
 *          +-----+--------------+--------+---------------+
 *          | N/A | Device Type  | Access | Function Code |
 *          +-----+--------------+--------+---------------+
 *
 */

/*
 *  Access Parameters
 */

#define _IOCTL_ACCESS_NEITHER           0U
#define _IOCTL_ACCESS_WRITE             1U
#define _IOCTL_ACCESS_READ              2U
#define _IOCTL_ACCESS_BOTH              3U

/*
 *  Bit Definitions
 */

#define _IOCTL_FUNCTIONBITS             14
#define _IOCTL_ACCESSBITS               2
#define _IOCTL_DEVICEBITS               14
#define _IOCTL_RESERVEDBITS             2

/*
 *  Masks
 */

#define _IOCTL_FUNCTIONMASK             0x00003FFF
#define _IOCTL_ACCESSMASK               0x0000C000
#define _IOCTL_DEVICEMASK               0x3FFF0000
#define _IOCTL_RESERVEDMASK             0xC0000000

#define _IOCTL_MAKECODE( DevMajor, Function, Access ) \
    ( ((DEV_IOCODE)(DevMajor) << 16) | ((DEV_IOCODE)(Access) << 14) | \
        (DEV_IOCODE)(Function) )

/*
 *  DEVICE STATISTICS
 *
 *      Gives Volume Stats on the File System
 */

struct _BlockDevStats
{

    DEV_USHORT  nType;
    DEV_USHORT  nClass;

    /*
     *  Information on the Block
     */

    DEV_USHORT  nBlockSiz;
    DEV_ULONG   nTotBlocks;
    DEV_ULONG   nFreeBlocks;
};

typedef struct _BlockDevStats   BLOCK_DEVSTATS;
typedef struct _BlockDevStats*  PBLOCK_DEVSTATS;

/*
 *  Character Only-based devices
 */

struct _CharDevStats
{
    DEV_USHORT  nType;
    DEV_USHORT  nClass;

    /*
     *  Character information (size, etc)
     */

    DEV_ULONG   nTotalChars;
    DEV_ULONG   nAvailChars;
};

typedef struct _CharDevStats    CHAR_DEVSTATS;
typedef struct _CharDevStats*   PCHAR_DEVSTATS;

union _DevStats
{
    DEV_USHORT      nType;
    BLOCK_DEVSTATS  blkStats;
    CHAR_DEVSTATS   chrStats;
};

typedef union _DevStats         DEVSTATS;
typedef union _DevStats*        PDEVSTATS;

/*
 *  These are the PRIMARY I/O Control Calls that are common to all drivers
 *
 *      RESET   - Resets a device, which is either done at startup or manually
 *                by a client (binded device)
 *
 *      STAT    - Statistics about the device (see DEVSTATS above)
 *      ERASE   - Erases the data in the device. An Address object is usually
 *                attached, when this is performed if the device supports 
 *                block addressing, otherwise the erase is device-wide
 *      READ    - This READ is implemented in a different fashion that the 
 *                READ operation. This function is typically used to read
 *                registers or other memory that is not directly associated
 *                with a file or buffering. However on devices that only have
 *                registers in their address base, this and the READ operation
 *                may perform the same task, therefore making them synonymous.
 *      WRITE   - Same as READ only a WRITE (see above)
 */

enum DEVICE_IOCTL
{
    DEVICE_IOCTL_RESET =        0x0001,
    DEVICE_IOCTL_STAT,
    DEVICE_IOCTL_ERASE,
    DEVICE_IOCTL_READ,
    DEVICE_IOCTL_WRITE,


    DEVICE_IOCTL_END
};

/*
 *  Driver Object
 *
 *
 *        Field Name          Description
 *      +------------------+------------------------------------------------+
 *      | nFlags           | Flags for this Driver
 *      +------------------+------------------------------------------------+
 *      | nDeviceClass     | The Major Device Number that this Driver Obj
 *      |                  |
 *      +------------------+------------------------------------------------+
 *      | pDeviceList      | Start of the list of devices supported by this
 *      |                  | driver.
 *      +------------------+------------------------------------------------+
 *      | pIoDispatch      | Dispatcher address for devices supported by
 *      |                  | driver.
 *      +------------------+------------------------------------------------+
 *      | pDevice_Ext      |
 *      +------------------+------------------------------------------------+
 *
 */

struct _DriverObj
{
    /*
     *  Driver specific flags
     */

    DEV_ULONG       nFlags;

    /*
     *  The Number that identifies the Class and Subclass of this Driver.
     *
     *      THE MAJOR PART is one of the CLASSES defined above
     *      THE MINOR PART is a personal identification of the SUBCLASS
     *          of Devices maintained by the driver.
     *
     *  NOTE: The MINOR Number in the Driver Number is UNIQUE. In another
     *  WORDS, it cannot exist across multiple classes and is what makes
     *  it unique from all others.
     *
     */

    DEV_TYPE        nDriverNo;

    /*
     *  The list of devices this driver manages. Typically there is only
     *  one driver per device. This LIST is built LIFO style, so the last
     *  driver added is the first in the list.
     */

    PDEVICE_OBJ     pDeviceList;

    /*
     *  I/O Dispatcher for Driver
     */

    PIODISPATCH pIoDispatch;

    /*
     *  Driver Operations - Drivers are initialized and they are
     *  uninitialized, unloaded.
     */

    DEV_IOSTATUS (*pDriverInit)( void );
    DEV_IOSTATUS (*pDriverUnload)( void );
};

#define DEFINE_DEVICE_DRIVER(devclass,disp,init,unload) \
    { 0, devclass, (PDEVICE_OBJ)0, disp, init, unload }

#define DEFINE_NULL_DEVICE_DRIVER() \
    { 0, DEVICE_NULL, (PDEVICE_OBJ)0, 0, 0, 0 }

/*
 *  Device Object
 *
 *      The Device object contains information about the device to which the
 *      driver manages. Devices have an Identification in which the Major
 *      Device Number portion refers to a common set of devices upon which it
 *      belongs, typically managed by a single driver.
 *
 *      When a request to open a file on a device is requested, the I/O
 *      Manager performs a lookup to find the physical device object in the
 *      system. Once it has this, the Driver for that device can be accessed
 *      and I/O operations performed accordingly.
 *
 */

typedef DEV_IOSTATUS (*FPDEVICEOBJ_INIT)( PDEVICE_OBJ );

struct _DeviceObj
{
    /*
     *  The Major and Minor number that identifies the Device.
     */

    DEV_TYPE        nDeviceNo;

    /*
     *  Current operational Status and Flags for the Device
     */

    DEV_ULONG       nFlags;

    /*
     *  Count of the number of descriptors open on this device
     */

    DEV_LONG        nRefCount;

    /*
     *  Binded Device (NULL) if bottom device
     */

    PDRIVER_OBJ     pDrvParent;

    /*
     *  The Driver Object maintains a Device List (if more than one device is
     *  managed by the same driver).
     */

    PDEVICE_OBJ     pDevNext;

    /*
     *  The Device may be binded to another device, in a stack fashion.
     */

    PDEVICE_OBJ     pDevBinded;

    /*
     *  The Initialization Handler for the Device
     */

    FPDEVICEOBJ_INIT pfnDeviceInit;

    /*
     *  Device Specific - Extended area for additional information that ONLY
     *  the Device knows about
     */

    DEV_PVOID       pDevice_Ext;
};

/*
 *  Flags
 *
 *      Online       - The device is loaded or mounted
 *      Initialized  - The device is initialized (formatted)
 *      Busy         - The device is currently busy
 *      WriteProtect - The device is write protected or not writable
 *      BlockOnly    = The device supports only BLOCK Reads and Writes
 *                     A device may be labeled as a BLOCK ONLY device
 *                     on it's Device ID, but this may only mean for
 *
 */

enum Device_
{
    Device_Online       = 0x00000001,
    Device_Initialized  = 0x00000002,
    Device_Busy         = 0x00000004,
    Device_WriteProtect = 0x00000008,

    /*
     *  The upper 16 bits are reserved for Device Specific Flags
     */

    Device_Reserved     = 0xFFFF0000
};

#define Device_Enable(dev,flag) \
    (dev)->nFlags |= (DEV_ULONG)(flag)

#define Device_Disable(dev,flag) \
    (dev)->nFlags &= ~(DEV_ULONG)(flag)

/*
 *  Status Queries
 */

#define Device_IsOnline(dev) \
    ( (dev)->nFlags & Device_Online )

#define Device_IsInitialized(dev) \
    ( (dev)->nFlags & Device_Initialized )

#define Device_IsBusy(dev) \
    ( (dev)->nFlags & Device_Busy )

#define Device_IsWriteProtected(dev) \
    ( (dev)->nFlags & Device_WriteProtect )

/*
 *  Miscellaneous Queries
 */

#define Device_IsTypeBlock(dev) \
    ( DEVICE_TYPE_ISBLOCK(dev_id) )

/*
 *  Member Access
 */

#define Device_GetId(dev) \
    (dev)->nDeviceNo

#define Device_GetNextDevice(dev) \
    (dev)->pDevNext

#define Device_GetParent(dev) \
    (dev)->pDrvParent

#define Device_GetBindDev(dev) \
    (dev)->pDevBinded

/*
 *  The DEVICE DRIVER TABLE
 *
 *      The Device Driver Table is a global region in which all the drivers
 *      are placed, either statically at boot time or run time if the user
 *      desires.
 *
 *      For now, they can only be installed Statically in a Global File
 *      Provided.
 */

typedef void (*PDRIVERINIT_CALLBACK)(DEV_TYPE);

#define BEGIN_DRIVERINIT_CALLBACK(nam) \
    void nam( DEV_TYPE nDevType ) {

#define END_DRIVERINIT_CALLBACK \
        return; \
    }

#define BEGIN_DRIVER_TABLE(nam) \
    static struct _DriverObj s_##nam##DrvTable[] = {

#define END_DRIVER_TABLE(nam) \
    }; \
    static int s_n##nam##Siz = \
        ( sizeof(s_##nam##DrvTable) / sizeof(struct _DriverObj) ); \
    static PDRIVER_OBJ GetDriverObject( DEV_TYPE nDriverNo ) { \
        int _nIdx = 0; \
        while ( _nIdx <  s_n##nam##Siz ) { \
            if ( nDriverNo == \
                    MINOR_DEVNO(s_MasterDrvTable[_nIdx].nDriverNo) ) { \
                return &s_MasterDrvTable[_nIdx]; \
            } \
            _nIdx++; \
        } \
        return (PDRIVER_OBJ)0; \
    } \
    int InitializeDevices( PDRIVERINIT_CALLBACK pDriverInitFailCallback ) { \
        int _nIdx; \
        int _nTotalInit = 0; \
        for ( _nIdx = 0; _nIdx < s_n##nam##Siz; _nIdx++ ) { \
            if ( s_MasterDrvTable[_nIdx].pDriverInit != 0 ) { \
                DEV_IOSTATUS _nStatus = \
                    (*s_MasterDrvTable[_nIdx].pDriverInit)(); \
                if ( _DEV_IOSTATUS_SUCCEEDED(_nStatus) ) { \
                    _nTotalInit++; \
                } \
                else if ( pDriverInitFailCallback != 0 ) { \
                    (*pDriverInitFailCallback)( \
                        s_MasterDrvTable[_nIdx].nDriverNo \
                    ); \
                } \
            } \
        } \
        return _nTotalInit; \
    } \
    void ShutdownDevices( PDRIVERINIT_CALLBACK pDriverInitFailCallback ) { \
        int _nIdx; \
        for ( _nIdx = s_nMasterSiz-1; _nIdx >= 0; _nIdx-- ) { \
            if ( s_MasterDrvTable[_nIdx].pDriverUnload != 0 ) { \
                DEV_IOSTATUS _nStatus = \
                    (*s_MasterDrvTable[_nIdx].pDriverUnload)(); \
                if ( _DEV_IOSTATUS_FAILED(_nStatus) && \
                    ( pDriverInitFailCallback != 0 ) ) { \
                        (*pDriverInitFailCallback)( \
                            s_MasterDrvTable[_nIdx].nDriverNo \
                        ); \
                } \
            } \
        } \
    }

/*
 *  Device Object API for getting and adding devices. This is only used
 *  for initialization purposes and DOES NOT imply dynamic loading and
 *  unloading of device objects.
 */

PDEVICE_OBJ GetDeviceObject( DEV_TYPE nDeviceNo );
DEV_IOSTATUS AddDeviceObject( PDEVICE_OBJ pDeviceObj );
DEV_IOSTATUS RemoveDeviceObject( PDEVICE_OBJ pDeviceObj );

/*
 *  Master METHOD in which the I/O Manager MUST call when initializing
 *  devices. This will recurvisely create the DEVICE SUBSYSTEM, typically
 *  bottom up to ensure valid initialization.
 */

int InitializeDevices( PDRIVERINIT_CALLBACK pDriverInitFailCallback );
void ShutdownDevices( PDRIVERINIT_CALLBACK pDriverInitFailCallback );

/*
 *  Support Methods - DEFINED IN "support.c"
 */

#if ( _DEV_ARCHITECTURE == _DEV_BIG_ENDIAN )

    void TransposeToBuffer(
        DEV_PVOID pSource,
        DEV_PVOID pDest,
        DEV_INT nLen
    );

    #define LittleEndianToBigEndian(_little,_big,_type) \
        TransposeToBuffer( _little, _big, sizeof(_type) )

    #define BigEndianToLittleEndian(_little,_big,_type) \
        TransposeToBuffer( _big, _little, sizeof(_type) )

#endif

void StringCaseUpper(
    DEV_STRING strBuf,
    DEV_INT nLen
);

void StringCaseLower(
    DEV_STRING strBuf,
    DEV_INT nLen
);

#define StringCaseToUpper(str,len) \
    StringCaseUpper(str,len)

#define StringCaseToLower(str,len) \
    StringCaseLower(str,len)

DEV_STRING StringParse(
    DEV_STRING strSource,
    DEV_STRING strDest,
    DEV_STRING strDelimiter
);

DEV_LOCALTIME* LocalTime(
    int* pTimer
);

#ifdef __cplusplus
}
#endif

#endif

