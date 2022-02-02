
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
 *  fat.h
 *
 *      Somethings to NOTE, since this FAT Driver is typically going to be
 *      wrapped
 *
 *      FATS are PACKED in Little-Endian Format.
 *
 */

#ifndef __FAT_H
#define __FAT_H

/*
 *  Very important header file that describes the driver layer that FAT
 */

#include "fsd.h"

#ifdef __cplusplus
extern "C" {
#endif

/*
 *  Object Types for the FAT Driver Layer
 */

typedef struct _FatDeviceObj    FAT_DEVOBJ;
typedef struct _FatFileObj      FAT_FILEOBJ;
typedef struct _FatBootSector   FAT_BOOTSECTOR;
typedef struct _DirEntry_s      FAT_DIRENTRY;

typedef struct _FatDeviceObj*   PFAT_DEVOBJ;
typedef struct _FatFileObj*     PFAT_FILEOBJ;
typedef struct _FatBootSector*  PFAT_BOOTSECTOR;
typedef struct _DirEntry_s*     PFAT_DIRENTRY;

/*
 *  Used in BLOCK to SECTOR translations
 */

/*
 *  Directory Specific constants
 */

#define FAT_FILENAME_DELIMITER  "."

#define FAT_ILLEGALCHAR_LIST \
    "\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F \
     \x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F \
     \x22\x2A\x2B\x2C\x2E\x2F\x3A\x3B\x3C\x3D\x3E\x3F\x5B\x5C\x5D\x7C"

/*
 *  Conversions for Architectures that use Big Endian, since FAT is stored
 *  in Little Endian. Be sure that ARCHITECTURE_BIG_ENDIAN is defined to
 *  ensure these conversions. These two Macros are for the FAT Boot Sector
 *  information only.
 */

#if ( _DEV_ARCHITECTURE == _DEV_BIG_ENDIAN )

    #define _FATTOBIGENDIAN(_fat) { \
        DEV_ULONG _nTmp; \
        LittleEndianToBigEndian( _fat->BPB_BytesPerSec, &nTmp, DEV_USHORT ); \
        _fat->BPB_BytesPerSec = nTmp; \
        LittleEndianToBigEndian( _fat->BPB_RsvdSecCnt, &nTmp, DEV_USHORT ); \
        _fat->BPB_RsvdSecCnt = nTmp; \
        LittleEndianToBigEndian( _fat->BPB_RootEntCnt, &nTmp, DEV_USHORT ); \
        _fat->BPB_RootEntCnt = nTmp; \
        LittleEndianToBigEndian( _fat->BPB_TotSec16, &nTmp, DEV_USHORT ); \
        _fat->BPB_TotSec16 = nTmp; \
        LittleEndianToBigEndian( _fat->BPB_FATSz16, &nTmp, DEV_USHORT ); \
        _fat->BPB_FATSz16 = nTmp; \
        LittleEndianToBigEndian( _fat->BPB_TotSec32, &nTmp, DEV_ULONG ); \
        _fat->BPB_TotSec32 = nTmp; \
    }

    #define _BIGENDIANTOFAT(_fat) { \
        DEV_ULONG _nTmp; \
        nTmp = _fat->BPB_BytesPerSec; \
        BigEndianToLittleEndian( _fat->BPB_BytesPerSec, &nTmp, DEV_USHORT ); \
        nTmp = _fat->BPB_RsvdSecCnt; \
        BigEndianToLittleEndian( _fat->BPB_RsvdSecCnt, &nTmp, DEV_USHORT ); \
        nTmp = _fat->BPB_RootEntCnt; \
        BigEndianToLittleEndian( _fat->BPB_RootEntCnt, &nTmp, DEV_USHORT ); \
        nTmp = _fat->BPB_TotSec16; \
        BigEndianToLittleEndian( _fat->BPB_TotSec16, &nTmp, DEV_USHORT ); \
        nTmp = _fat->BPB_FATSz16; \
        BigEndianToLittleEndian( _fat->BPB_FATSz16, &nTmp, DEV_USHORT ); \
        nTmp = _fat->BPB_TotSec32; \
        BigEndianToLittleEndian( _fat->BPB_TotSec32, &nTmp, DEV_ULONG ); \
    }

    #define _DIRENTRY_TOBIGENDIAN(_dir) { \
        DEV_ULONG _nTmp; \
        LittleEndianToBigEndian( _dir->DIR_CrtTime, &nTmp, DEV_USHORT ); \
        _dir->DIR_CrtTime = nTmp; \
        LittleEndianToBigEndian( _dir->DIR_CrtDate, &nTmp, DEV_USHORT ); \
        _dir->DIR_CrtDate = nTmp; \
        LittleEndianToBigEndian( _dir->DIR_LstAccDate, &nTmp, DEV_USHORT ); \
        _dir->DIR_LstAccDate = nTmp; \
        LittleEndianToBigEndian( _dir->DIR_WrtTime, &nTmp, DEV_USHORT ); \
        _dir->DIR_WrtTime = nTmp; \
        LittleEndianToBigEndian( _dir->DIR_WrtDate, &nTmp, DEV_USHORT ); \
        _dir->DIR_WrtDate = nTmp; \
        LittleEndianToBigEndian( _dir->DIR_FstClusLO, &nTmp, DEV_USHORT ); \
        _dir->DIR_FstClusLO = nTmp; \
        LittleEndianToBigEndian( _dir->DIR_FileSize, &nTmp, DEV_ULONG ); \
        _dir->DIR_FileSize = nTmp; \
    }

    #define _BIGENDIANTO_DIRENTRY(_dir) { \
        DEV_ULONG _nTmp; \
        nTmp = _dir->DIR_CrtTime; \
        BigEndianToLittleEndian( _dir->DIR_CrtTime, &nTmp, DEV_USHORT ); \
        nTmp = _dir->DIR_CrtDate; \
        BigEndianToLittleEndian( _dir->DIR_CrtDate, &nTmp, DEV_USHORT ); \
        nTmp = _dir->DIR_LstAccDate; \
        BigEndianToLittleEndian( _dir->DIR_LstAccDate, &nTmp, DEV_USHORT ); \
        nTmp = _dir->DIR_WrtTime; \
        BigEndianToLittleEndian( _dir->DIR_WrtTime, &nTmp, DEV_USHORT ); \
        nTmp = _dir->DIR_WrtDate; \
        BigEndianToLittleEndian( _dir->DIR_WrtDate, &nTmp, DEV_USHORT ); \
        nTmp = _dir->DIR_FstClusLO; \
        BigEndianToLittleEndian( _dir->DIR_FstClusLO, &nTmp, DEV_USHORT ); \
        nTmp = _dir->DIR_FileSize; \
        BigEndianToLittleEndian( _dir->DIR_FileSize, &nTmp, DEV_ULONG ); \
    }

#else

    #define _FATTOBIGENDIAN(_fat)
    #define _BIGENDIANTOFAT(_fat)
    #define _DIRENTRY_TOBIGENDIAN(_dir)
    #define _BIGENDIANTO_DIRENTRY(_dir)

#endif


/*
 *  Flags specific to FAT Devices
 */

enum FatDevice_
{
    FatDevice_CacheChange   = 0x0001000
};

#define FatDevice_IsCacheChanged(dev) \
    ( (dev)->nFlags & FatDevice_CacheChange )

/*
 *  Volume Information
 */

enum _FatFormat
{
    eFatFormatNone      = -1,
    eFatFormat12,
    eFatFormat16,
    eFatFormat32
};

enum SectorSize
{
    eSectorSizeDef      =  512U,

    eSectorSize512      =  512U,
    eSectorSize1K       = 1024U,
    eSectorSize2K       = 2048U,
    eSectorSize4K       = 4096U,

    /*
     *  Large Sectors - these are not supported by MS Compliant OS
     */

    eSectorSize8K       = 8192U,
    eSectorSize16K      = 16384U,

    eSectorSizeInvalid
};

enum ClusterState
{
    eClusterFree        = 0x00000000,       /* Cluster is Free      */
    eClusterReserved    = 0x0FFFFFF0,       /* Cluster is Reserved  */
    eClusterCheck       = 0x0FFFFFF6,       /* Cluster is in Check  */ 
    eClusterBad         = 0x0FFFFFF7,       /* Cluster is Bad       */
    eClusterEOF         = 0x0FFFFFF8        /* Cluster is EOF       */
};

#define CLUSTERSTATE_FAT12(c) \
    ( (c) & 0x00000FFF )

#define CLUSTERSTATE_FAT16(c) \
    ( (c) & 0x0000FFFF )

#define CLUSTERSTATE_FAT32(c) \
    (c)

/*
 *  This information is for the Two Reserved Clusters in the VOLUME
 */

enum VolumeState
{
    eHrdErrBitMask      = 0x4000,
    eClnShutBitMask     = 0x8000,
};

enum MediaType
{
    eMediaFixed         = 0xF8,
    eMediaUnknown       = 0xFF
};

/*
 *  Types
 *
 *      Reserved    - Boot Sector
 *      Data        - FAT Region, the Table itself
 *      Root        - Root Directory Region, non-existent in FAT32
 *      Storage     - Referred to as teh File and Directory Data Ragion
 */

enum _FatRegion
{
    eFatRegionReserved    = 0,
    eFatRegionData,
    eFatRegionRoot,
    eFatRegionStorage
};

/*
 *  RESERVED or BOOT SECTOR
 *
 *  This is the first sector of the volume (Sector 0) and contains both the
 *  Boot Sector information (if required) and the BPB which is the Bios
 *  Parameter Block, carried over from MS-DOS days.
 *
 *  NOTE: By Volume, it means Partition. Some devices may have multiple
 *  partitions formatted in different ways. For FAT, this Record occupies the
 *  first sector of that Partition.
 *
 *        Field Name       Offset Size  Description
 *      +-----------------+------+----+-------------------------------------+
 *      | BS_jmpBoot      |   0  |  3 | Jump instruction to boot code. This
 *      |                 |      |    | is unused for this version.
 *      +-----------------+------+----+-------------------------------------+
 *      | BS_OEMName      |   3  |  8 | Always set to MSWIN4.1, although it
 *      |                 |      |    | has no significance except with
 *      |                 |      |    | compatibility with older drivers.
 *      +-----------------+------+----+-------------------------------------+
 *      | BPB_BytesPerSec |  11  |  2 | Bytes per Sector. Only the following
 *      |                 |      |    | values are valid: 512, 1024, 2048,
 *      |                 |      |    | or 4096. For maximum backwards
 *      |                 |      |    | compatibility, 512 should be used.
 *      +-----------------+------+----+-------------------------------------+
 *      | BPB_SecPerClus  |  13  |  1 | Number of Sectors per Allocation
 *      |                 |      |    | Unit. The value must be a power of
 *      |                 |      |    | 2, but cannot be 0. Legal values
 *      |                 |      |    | are 1, 2, 4, 8, 16, 32, 64, and
 *      |                 |      |    | 128.
 *      +-----------------+------+----+-------------------------------------+
 *      | BPB_RsvdSecCnt  |  14  |  2 | Number of reserved sectors in the
 *      |                 |      |    | reserved region of the volume. This
 *      |                 |      |    | field MUST not be 0. For FAT12 and
 *      |                 |      |    | FAT16 this value is fixed at 1. For
 *      |                 |      |    | FAT32 it is typically 32.
 *      +-----------------+------+----+-------------------------------------+
 *      | BPB_NumFATs     |  16  |  1 | The count of FAT data structures on
 *      |                 |      |    | the volume. This field is typically
 *      |                 |      |    | 2, since a backup copy of the Table
 *      |                 |      |    | is necessary on most media. For
 *      |                 |      |    | devices such as a Flash Memory Card
 *      |                 |      |    | it is not necessary but some FAT
 *      |                 |      |    | file system drivers may not
 *      |                 |      |    | recognize the volume properly.
 *      +-----------------+------+----+-------------------------------------+
 *      | BPB_RootEntCnt  |  17  |  2 | Contains the count of 32-byte
 *      |                 |      |    | directory entries in the root. For
 *      |                 |      |    | FAT32 this field is "0".
 *      +-----------------+------+----+-------------------------------------+
 *      | BPB_TotSec16    |  19  |  2 | Unused and should be set to "0".
 *      |                 |      |    | Use BPB_TotSec32 instead.
 *      +-----------------+------+----+-------------------------------------+
 *      | BPB_Media       |  21  |  1 | Media type the file resides on. For
 *      |                 |      |    | non-removable (fixed) media this
 *      |                 |      |    | value is 0xF8. For removable media
 *      |                 |      |    | this value is typically 0xF0. For
 *      |                 |      |    | an unformatted drive it should 0x00.
 *      +-----------------+------+----+-------------------------------------+
 *      | BPB_FATSz16     |  22  |  2 | This field is the FAT12/FAT16 count
 *      |                 |      |    | of sectors
 *      +-----------------+------+----+-------------------------------------+
 *      | BPB_SecPerTrk   |  24  |  2 | Sectors per track for interrupt 
 *      |                 |      |    | 0x13. (NOT USED CURRENTLY)
 *      |                 |      |    |
 *      +-----------------+------+----+-------------------------------------+
 *      | BPB_NumHeads    |  26  |  2 | Number of heads on the device for 
 *      |                 |      |    | interrupt 0x13. (NOT USED CURRENTLY)
 *      +-----------------+------+----+-------------------------------------+
 *      | BPB_HiddSec     |  28  |  4 | Count of hidden sectors preceding the 
 *      |                 |      |    | partition that contains this FAT 
 *      |                 |      |    | volume. NOT USED (since Partitioning
 *      |                 |      |    | supported currently.
 *      +-----------------+------+----+-------------------------------------+
 *      | BPB_TotSec32    |  32  |  4 | This field is the new 32-bit total 
 *      |                 |      |    | count of sectors on the volume. This 
 *      |                 |      |    | count includes the count of all 
 *      |                 |      |    | sectors in all four regions of the 
 *      |                 |      |    | volume. 
 *      +-----------------+------+----+-------------------------------------+
 *
 *  This is the extension area which depending on the Volume Format Type can
 *  differ.
 *
 *  FAT12 and FAT16 only
 *
 *        Field Name       Offset Size  Description
 *      +-----------------+------+----+-------------------------------------+
 *      | BS_DrvNum       |  36  |  1 | This is the Drive Number and was
 *      |                 |      |    | for MS-DOS Bootstrap. It was set to
 *      |                 |      |    | 0x00 for floppy and 0x80 for hard
 *      |                 |      |    | disks.
 *      +-----------------+------+----+-------------------------------------+
 *      | BS_Reserved1    |  37  |  1 | Reserved and should be set to "0".
 *      |                 |      |    |
 *      +-----------------+------+----+-------------------------------------+
 *      | BS_BootSig      |  38  |  1 | Extended Boot Signature and if set
 *      |                 |      |    | to 0x29, indicates that the next
 *      |                 |      |    | three fields are present and set.
 *      +-----------------+------+----+-------------------------------------+
 *      | BS_VolID        |  39  |  4 | Volume Serial Number.
 *      |                 |      |    |
 *      +-----------------+------+----+-------------------------------------+
 *      | BS_VolLab       |  43  | 11 | Volume Label. By default it is set
 *      |                 |      |    | to "NO NAME    ", but should match
 *      |                 |      |    | the 11-byte volume label in the
 *      |                 |      |    | root directory.
 *      +-----------------+------+----+-------------------------------------+
 *      | BS_FilSysType   |  54  |  8 | Set to "FAT12   " or "FAT16   " or
 *      |                 |      |    | "FAT     ". It serves no purpose
 *      |                 |      |    | other than informational.
 *      +-----------------+------+----+-------------------------------------+
 *
 *  FAT32 (NOT SUPPORTED CURRENTLY)
 *
 *        Field Name       Offset Size  Description
 *      +-----------------+------+----+-------------------------------------+
 *      | BPB_FATSz32     |  36  |  4 |
 *      +-----------------+------+----+-------------------------------------+
 *      | BPB_ExtFlags    |  40  |  2 |
 *      +-----------------+------+----+-------------------------------------+
 *      | BPB_FSVer       |  42  |  2 |
 *      +-----------------+------+----+-------------------------------------+
 *      | BPB_RootClus    |  44  |  4 |
 *      +-----------------+------+----+-------------------------------------+
 *      | BPB_FSInfo      |  48  |  2 |
 *      +-----------------+------+----+-------------------------------------+
 *      | BPB_BkBootSec   |  50  |  2 |
 *      +-----------------+------+----+-------------------------------------+
 *      | BPB_Reserved    |  52  | 12 |
 *      +-----------------+------+----+-------------------------------------+
 *      | BS_DrvNum       |  64  |  1 |
 *      +-----------------+------+----+-------------------------------------+
 *      | BS_Reserved1    |  65  |  1 |
 *      +-----------------+------+----+-------------------------------------+
 *      | BS_BootSig      |  66  |  1 | 
 *      +-----------------+------+----+-------------------------------------+
 *      | BS_VolID        |  67  |  4 | 
 *      +-----------------+------+----+-------------------------------------+
 *      | BS_VolLab       |  71  | 11 | 
 *      +-----------------+------+----+-------------------------------------+
 *      | BS_FilSysType   |  82  |  8 | 
 *      +-----------------+------+----+-------------------------------------+
 *
 */

struct _FatBootSector
{
    DEV_UINT8   BS_jmpBoot[3];
    DEV_UINT8   BS_OEMName[8];
    DEV_UINT16  BPB_BytesPerSec;
    DEV_UINT8   BPB_SecPerClus;
    DEV_UINT16  BPB_RsvdSecCnt;
    DEV_UINT8   BPB_NumFATs;
    DEV_UINT16  BPB_RootEntCnt;
    DEV_UINT16  BPB_TotSec16;
    DEV_UINT8   BPB_Media;
    DEV_UINT16  BPB_FATSz16;

    /*
     *  The FLASH System uses these values for
     */

    DEV_UINT16  BPB_SecPerTrk;
    DEV_UINT16  BPB_NumHeads;

	/*
	 *	
	 */

    DEV_UINT32  BPB_HiddSec;
    DEV_UINT32  BPB_TotSec32;

    /*
     *  End of the COMMON Section - this is where FAT12/16 and FAT32 differ
     */

    union
    {
        /*
         *  FAT12/16
         */

        struct
        {
            DEV_UINT8   BS_DrvNum;
            DEV_UINT8   BS_Reserved1;
            DEV_UINT8   BS_BootSig;
            DEV_UINT8   BS_VolID[4];
            DEV_UINT8   BS_VolLab[11];
            DEV_UINT8   BS_FilSysType[8];
        }
        _Fat16;

        /*
         *  Placeholder only until FAT32 is supported
         */

        struct
        {
            DEV_UINT32  BPB_FATSz32;
            DEV_UINT8   BPB_ExtFlags[2];
            DEV_UINT8   BPB_FSVer[2];
            DEV_UINT32  BPB_RootClus;
            DEV_UINT16  BPB_FSInfo;
            DEV_UINT16  BPB_BkBootSec;
            DEV_UINT8   BPB_Reserved[12];
            DEV_UINT8   BS_DrvNum[1];
            DEV_UINT8   BS_Reserved1[1];
            DEV_UINT8   BS_BootSig[1];
            DEV_UINT8   BS_VolID[4];
            DEV_UINT8   BS_VolLab[11];
            DEV_UINT8   BS_FilSysType[8];
        }
        _Fat32;
    }
    Ext;
};

typedef struct _FatBootSector FatBootSector_t;

/*
 *  FAT Region
 *
 *      This is the FAT Data STructure and some MACROS to
 */

/*
 *  Directory Entry Region
 *
 *
 *
 *        Field Name       Offset Size  Description
 *      +-----------------+------+----+-------------------------------------+
 *      | DIR_Name        |   0  |  8 | Short name of the file or director
 *      |                 |      |    |
 *      +-----------------+------+----+-------------------------------------+
 *      | DIR_Ext         |   8  |  3 | File Attributes (see enums)
 *      |                 |      |    |
 *      +-----------------+------+----+-------------------------------------+
 *      | DIR_Attr        |  11  |  1 | File Attributes (see enums)
 *      |                 |      |    |
 *      +-----------------+------+----+-------------------------------------+
 *      | DIR_NTRes       |  12  |  1 | NT-Only (set to 0 by default)
 *      |                 |      |    |
 *      +-----------------+------+----+-------------------------------------+
 *      | DIR_CrtTimeTenth|  13  |  1 | Millisecond stamp at file creation
 *      |                 |      |    | time.
 *      +-----------------+------+----+-------------------------------------+
 *      | DIR_CrtTime     |  14  |  2 | Time file was created
 *      |                 |      |    |
 *      +-----------------+------+----+-------------------------------------+
 *      | DIR_CrtDate     |  16  |  2 | Date file was created
 *      |                 |      |    |
 *      +-----------------+------+----+-------------------------------------+
 *      | DIR_LstAccDate  |  18  |  2 | Last access date
 *      |                 |      |    |
 *      +-----------------+------+----+-------------------------------------+
 *      | DIR_FstClusHI   |  20  |  2 | High Word of this entry's first
 *      |                 |      |    | cluster number.
 *      +-----------------+------+----+-------------------------------------+
 *      | DIR_WrtTime     |  22  |  2 | Time of the last write
 *      |                 |      |    |
 *      +-----------------+------+----+-------------------------------------+
 *      | DIR_WrtDate     |  24  |  2 | Date of the last write
 *      |                 |      |    |
 *      +-----------------+------+----+-------------------------------------+
 *      | DIR_FstClusLO   |  26  |  2 | Low Word of this entry's first
 *      |                 |      |    | cluster number.
 *      +-----------------+------+----+-------------------------------------+
 *      | DIR_FileSize    |  28  |  4 | Size of file (32 bit WORD)
 *      |                 |      |    |
 *      +-----------------+------+----+-------------------------------------+
 */

#define DIRENTRY_NAMELEN        8
#define DIRENTRY_EXTLEN         3
#define DIRENTRY_FULLNAMELEN    (DIRENTRY_NAMELEN+DIRENTRY_EXTLEN)
#define DIRENTRY_EMPTYNAME      "           "

union _DirEntryName_s
{
    DEV_CHAR strName[DIRENTRY_FULLNAMELEN];

    struct
    {
        DEV_CHAR    strName[DIRENTRY_NAMELEN];
        DEV_CHAR    strExt[DIRENTRY_EXTLEN];

    } part;
};

/*
 *  Special File Names
 */

#define DIRENTRY_END                '\x00'
#define DIRENTRY_KANJI              '\x05'
#define DIRENTRY_FREE               '\xE5'
#define DIRENTRY_ROOT               '\xFF'

typedef union _DirEntryName_s DirEntryName_t;

struct _DirEntry_s
{
    DEV_CHAR    DIR_Name[DIRENTRY_FULLNAMELEN];
    DEV_UINT8   DIR_Attr;
    DEV_UINT8   DIR_NTRes;
    DEV_UINT8   DIR_CrtTimeTenth;
    DEV_UINT16  DIR_CrtTime;
    DEV_UINT16  DIR_CrtDate;
    DEV_UINT16  DIR_LstAccDate;
    DEV_UINT16  DIR_FstClusHI;
    DEV_UINT16  DIR_WrtTime;
    DEV_UINT16  DIR_WrtDate;
    DEV_UINT16  DIR_FstClusLO;
    DEV_UINT32  DIR_FileSize;
};

/*
 *  Attributes for FILES on the device
 */

enum FAT_ATTR
{
    FAT_ATTR_READ_ONLY  = 0x01,
    FAT_ATTR_HIDDEN     = 0x02,
    FAT_ATTR_SYSTEM     = 0x04,
    FAT_ATTR_VOLUME_ID  = 0x08,
    FAT_ATTR_DIRECTORY  = 0x10,
    FAT_ATTR_ARCHIVE    = 0x20,
    FAT_ATTR_LONG_NAME  = FAT_ATTR_READ_ONLY |
                          FAT_ATTR_HIDDEN |
                          FAT_ATTR_SYSTEM |
                          FAT_ATTR_VOLUME_ID,

    FAT_ATTR_RESERVED   = 0xC0
};


#define DirEntry_IsReadOnly(dir) \
    ( (dir)->DIR_Attr & FAT_ATTR_READ_ONLY )

#define DirEntry_IsHidden(dir) \
    ( (dir)->DIR_Attr & FAT_ATTR_HIDDEN )

#define DirEntry_IsSystem(dir) \
    ( (dir)->DIR_Attr & FAT_ATTR_HIDDEN )

#define DirEntry_IsDirectory(dir) \
    ( (dir)->DIR_Attr & FAT_ATTR_DIRECTORY )

/*
 *  Date and Time information
 */

struct _FatDate
{
    DEV_UINT16 nDay   : 5;      /* Day of Month, 1-31                       */
    DEV_UINT16 nMonth : 4;      /* Month of Year, 1-12                      */
    DEV_UINT16 nYear  : 7;      /* Count of Years from 1980, 0-127          */
};

struct _FatTime
{
    DEV_UINT16 nSeconds : 5;    /* 2 second increments, 0-29 (0-58 secs)    */
    DEV_UINT16 nMinutes : 6;    /* Minutes, 0-59                            */
    DEV_UINT16 nHours   : 5;    /* Hours, 0-23                              */
};

typedef struct _FatDate     FAT_DATE;
typedef struct _FatTime     FAT_TIME;

/*
 *  The FAT File System Object
 *
 *      The FAT File System Object allows upper level applications to view
 *      the file system logically as a compatible file system. The underlying
 *      device characteristics are abstracted to the FAT through a set of
 *      standard I/O interfaces for reading and writing to the device.
 *
 *      The device itself must maintain the physical aspects of the target
 *      device the File System resides in.
 *
 *          +-------------------+
 *          |   Device Object   |
 *          |                   |
 *          | +---------------+ |    +-------------------+
 *          | |  Device Ext   |-+--->| FAT Device Object |
 *          | +---------------+ |    +-------------------+
 *          +-------------------+
 */

struct _FatDeviceObj
{
    /*
     *  Data Cluster Information for statistics
     *
     *      DataClusters     - The Count of the Total Number of Data Clusters
     *      AvailClusters    - The Count of the Available Number of Clusters 
     *      FreeClusters     - The Count of the Total Number of Free Clusters
     *      FirstFreeCluster - The Index of the First Free Cluster in the FAT
     */

    DEV_ULONG           FAT_DataClusters;
    DEV_ULONG           FAT_AvailClusters;
    DEV_ULONG           FAT_FreeClusters;
    DEV_ULONG           FAT_FirstFreeCluster;

    /*
     *  Information for Sector mapping
     *
     *      RootDirSectors  - Count of Sectors occupied by the ROOT directory
     *      FirstDataSector - First Data Sector of Cluster 2, the Data region
     */

    DEV_USHORT          FAT_RootDirSectors;
    DEV_USHORT          FAT_FirstRootDirSector;

    /*
     *  Since traversing the FAT we need to store this to make it readily
     *  available instead of doing a calculation each time to figure it
     */

    enum _FatFormat     FAT_Format;

    /*
     *  End of FILE Marker...YES this differs due to size of FAT File System
     */

    DEV_ULONG           FAT_Eof;

    /*
     *  FILE ALLOCATION TABLE Caching
     *
     *      FAT_WriteCache
     *
     *          This is the CACHE Responsible for holding the latest updated
     *          Clusters in the FAT. It is used to help reduce the write 
     *          cycles for whenever multiple READs are Requested that would
     *          cause a SINGLE Cache to fault
     *
     *      FAT_ReadCache
     *
     *          Read CACHE is specifically for entries walking the FAT, which
     *          happens much more often than 
     */

    DEV_USTRING         FAT_WriteCache;
    DEV_USHORT          FAT_WriteCacheBlock;

    DEV_USTRING         FAT_ReadCache;
    DEV_USHORT          FAT_ReadCacheBlock;

    DEVOBJ_DECLARE_CRITICAL_SECTION(FAT_CriticalSection);

    /*
     *  Critical SECTION for CREATING/REMOVING/UPDATING directory entries.
     */

    DEVOBJ_DECLARE_CRITICAL_SECTION(FAT_DirectoryMutex);

    /*
     *  Cache the Boot Sector information
     */

    FatBootSector_t     FAT_BootSector;
};

#define FAT_DEVOBJ_EXT(dev) \
    ((PFAT_DEVOBJ)((dev)->pDevice_Ext))

#define FAT_BOOTSECTOR(dev) \
    (&(((PFAT_DEVOBJ)((dev)->pDevice_Ext))->FAT_BootSector))

#define FAT_FIRSTDATASECTOR(fatdev) \
    ((fatdev)->FAT_FirstRootDirSector + (fatdev)->FAT_RootDirSectors)

#define FAT_FIRSTSECTOROFCLUSTER(fatdev,clus) \
    ((((clus)-2)*(fatdev)->FAT_BootSector.BPB_SecPerClus) + \
        FAT_FIRSTDATASECTOR(fatdev))

#define FAT_GETCLUSTEROFSECTOR(fatdev,sec) \
    (((sec) - FAT_FIRSTDATASECTOR(fatdev)) / \
        ((fatdev)->FAT_BootSector.BPB_SecPerClus) + 2)

#define FAT_BYTESPERCLUSTER(fatdev) \
    ((fatdev)->FAT_BootSector.BPB_SecPerClus * \
        (fatdev)->FAT_BootSector.BPB_BytesPerSec)

#define FAT_EOF(fatdev) \
    (fatdev)->FAT_Eof

/*
 *  This is the FAT File Descriptor. It's importance is needed for
 *  accessing the volume and the File within the volume.
 *
 *      The File Descriptor at the Application level is an index to a table
 *      which contains a pointer to information about the file and where it
 *      is located.
 *
 *          +-------------------+
 *          |    File Object    |
 *          |                   |
 *          | +---------------+ |    +-------------------+
 *          | |   File Ext    |-+--->|  FAT File Object  |
 *          | +---------------+ |    +-------------------+
 *          +-------------------+
 *
 *  The FILE Object is also used for Directory Lookups.
 */

struct _FatFileObj
{
    /*
     *  Directory Entry information for the file and the path.
     *
     *      theEntry        - The File or Directory opened
     *      theParentEntry  - The path the File or Directory exists in
     *
     *  The Entry contains information about where the file starts in the file
     *  system.
     */

    FAT_DIRENTRY    theEntry;
    FAT_DIRENTRY    theParentEntry;

    /*
     *  Information about where the Dir Entry Resides IN the PARENT (allows
     *  for quicker access without doing a search on each close). For ROOT
     *  Directory this has no meaning...
     */

    DEV_UINT32      nDirSector;
    DEV_UINT16      nDirOffset;

    /*
     *  Contains information about where in the file the next access is to
     *  occur.
     *
     *      Cluster - The current Cluster Index (Root Directory ignores 
     *                this field).
     *      nSector - The current Sector Offset with the cluster [0..m-1],
     *                where m is the Number of Sectors per Cluster. If the
     *                FileObject is for the ROOT directory then this is the
     *                Offset within the ROOT Directory (FAT12 and FAT16 only)
     *      Offset  - The current Byte Offset within the Sector [0..n-1],
     *                where n is the Number of Bytes per Sector
     */

    DEV_ULONG       nCluster;
    DEV_ULONG       nSector;
    DEV_ULONG       nOffset;
};

#define FAT_FILEOBJ_EXT(fobj) \
    ((PFAT_FILEOBJ)((fobj)->pFileExt))

/*
 *  The following are the Specific Functionality that FAT.
 *
 *      All functions take the DEVICE OBJECT as an argument, since a request
 *      to the underlying device may be necessary. The most important part of
 *      the Device Object though is specific to the Extension which is the
 *      FAT Device Object.
 */

/*
 *  FAT Volume Operations
 */

DEV_IOSTATUS Fat_MountVolume(
    PDEVICE_OBJ pDevObj
);

DEV_IOSTATUS Fat_UnmountVolume(
    PDEVICE_OBJ pDevObj
);

DEV_IOSTATUS Fat_FormatVolume(
    PDEVICE_OBJ pDevObj,
    DEV_STRING strName
);

DEV_IOSTATUS Fat_VolumeStat(
    PDEVICE_OBJ pDevObj,
    PDEVSTATS pStats
);

/*
 *  FAT Directory Operations
 */

DEV_IOSTATUS Fat_CreateDir(
    PFILE_OBJ pFileObj,
    DEV_STRING strPath
);

DEV_IOSTATUS Fat_RemoveDir(
    PFILE_OBJ pFileObj,
    DEV_STRING strPath
);

DEV_IOSTATUS Fat_ReadDir(
    PFILE_OBJ pFileObj,
    PDIRECT pDirect
);

/*
 *  FAT File Operations (PUBLIC)
 */

DEV_IOSTATUS Fat_FileWriteSector(
    PFILE_OBJ pFileObj
);

DEV_IOSTATUS Fat_FileOpen(
    PFILE_OBJ pFileObj,
    DEV_STRING strPath,
    DEV_ULONG nFlags
);

DEV_IOSTATUS Fat_FileClose(
    PFILE_OBJ pFileObj
);

DEV_IOSTATUS Fat_FileRead(
    PFILE_OBJ pFileObj,
    DEV_PVOID nBuffer,
    DEV_LONG nCharsToRead,
    DEV_LONG* pnCharsRead
);

DEV_IOSTATUS Fat_FileWrite(
    PFILE_OBJ pFileObj,
    DEV_PVOID nBuffer,
    DEV_LONG nCharsToWrite,
    DEV_LONG* pnCharsWritten
);

DEV_IOSTATUS Fat_FileSeek(
    PFILE_OBJ pFileObj,
    DEV_LONG nOffset,
    DEV_INT nOrigin,
    DEV_LONG* pnPos
);

DEV_IOSTATUS Fat_FileRename(
    PFILE_OBJ pFileObj,
    DEV_STRING strPath,
    DEV_STRING strName
);

DEV_IOSTATUS Fat_FileStat(
    PFILE_OBJ pFileObj,
    DEV_STRING strPath,
    PSTAT pStat
);

/*
 *  FAT Core Functionality (INTERNAL USE ONLY)
 */

#ifdef _FAT_INCLUDE_CORE

    /*
     *  FAT Specific
     */

    DEV_IOSTATUS Fat_SetClusterEntry(
        PDEVICE_OBJ pDevObj,
        DEV_UINT32 nClusterIdx,
        DEV_UINT32 nClusterEntry
    );

    DEV_IOSTATUS Fat_GetClusterEntry(
        PDEVICE_OBJ pDevObj,
        DEV_UINT32 nClusterIdx,
        DEV_UINT32* pClusterEntry
    );

    DEV_IOSTATUS Fat_FindNextFreeCluster(
        PDEVICE_OBJ pDevObj,
        DEV_ULONG* pnClusterIdx
    );

    DEV_IOSTATUS Fat_ReleaseCluster(
        PDEVICE_OBJ pDevObj,
        DEV_ULONG nClusterIdx
    );

    DEV_IOSTATUS Fat_InvalidateCluster(
        PDEVICE_OBJ pDevObj,
        DEV_ULONG nClusterIdx,
        DEV_IOSTATUS nStatus
    );

    /*
     *  Directory Specific
     */

    DEV_IOSTATUS Fat_DirFindEntry(
        PFILE_OBJ pFileObj,
        DEV_STRING strEntry
    );

    DEV_IOSTATUS Fat_DirCreateEntry(
        PFILE_OBJ pFileObj
    );

    DEV_IOSTATUS Fat_DirRemoveEntry(
        PFILE_OBJ pFileObj
    );

    DEV_IOSTATUS Fat_DirUpdateEntry(
        PFILE_OBJ pFileObj
    );

    DEV_IOSTATUS Fat_DirPathWalk(
        PFILE_OBJ pFileObj,
        DEV_STRING strPath
    );

    DEV_IOSTATUS Fat_GetSetSector(
        PDEVICE_OBJ pDevObj,
        DEV_SHORT nOperation,
        DEV_USTRING pSector,
        DEV_UINT32 nSector
    );

    #define Fat_ReadSector(dev,buf,sec) \
        Fat_GetSetSector(dev,DEVICE_IO_READ,buf,sec)

    #define Fat_WriteSector(dev,buf,sec) \
        Fat_GetSetSector(dev,DEVICE_IO_WRITE,buf,sec)

    #define Fat_FileSize( fobj ) \
        FAT_FILEOBJ_EXT(fobj)->theEntry.DIR_FileSize

    /*
     *  Entry (i-node) Functions
     */

    DEV_TIME Fat_ConvertToDiskTime(    
        FAT_TIME* pDirTime,
        FAT_DATE* pDirDate
    );

    DEV_TIME Fat_ConvertFromDiskTime( 
        FAT_TIME* pDirTime,
        FAT_DATE* pDirDate
    );

    #define Fat_GetINumber(fatdev,fatfile)          1

#endif      /* #ifdef _FAT_INCLUDE_CORE */

#ifdef __cplusplus
}
#endif

#endif      /* #ifdef __FAT_H           */

