
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
 *  devobj.c
 *
 *      This is the global file
 */

#include "devobj.h"

/*
 *  DRIVER TABLE
 *
 *      By default a Master Table has been defined here, which is a place-
 *      holder for all Device Drivers in the system.
 */

#define DEFINE_DRIVER_TABLE
#include "devtbl.h"

/* --------------------------------------------------------------------------
 *  NULL Handler for IoPacket Handling
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS DevObj_NullHandler( PDEV_IOPACKET pIoPacket )
{
    return _DEV_IOSTATUS_OPERATION;
}

/* --------------------------------------------------------------------------
 *
 *  GetDeviceObject
 *
 *      Retrieves a Device Object.
 *
 *  Parameters:
 *      nDeviceNo   - The Device Number (MAJOR and MINOR)
 *
 *  Returns:
 *      Returns the Device Object associate with the Device Number. If the
 *      Driver or Device doesn't exist then a NULL or INVALID DEVICE OBJECT
 *      is returned.
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

PDEVICE_OBJ GetDeviceObject( DEV_TYPE nDeviceNo )
{
    PDRIVER_OBJ _pDriver;
    PDEVICE_OBJ _pDevice = (PDEVICE_OBJ)0;

    /*
     *  Valid Device?
     */

    if ( nDeviceNo == DEVICE_UNKNOWN )
    {
        return _pDevice;
    }

    /*
     *  Find a Driver Object associated with the DEVICE
     */

    _pDriver = GetDriverObject( MAJOR_DEVNO(nDeviceNo) );

    /*
     *  Was a valid Driver Object found?
     */

    if ( _pDriver != (PDRIVER_OBJ)0 )
    {
        _pDevice = _pDriver->pDeviceList;

        /*
         *  Only need the Minor Number associated with the Device on this
         *  driver.
         */

        nDeviceNo = MINOR_DEVNO( nDeviceNo );

        /*
         *  Find the device
         */

        while ( _pDevice != (PDEVICE_OBJ)0 )
        {
            if ( MINOR_DEVNO(_pDevice->nDeviceNo) == nDeviceNo )
            {
                break;
            }

            _pDevice = _pDevice->pDevNext;
        }
    }

    /*
     *  Return Device
     */

    return _pDevice;
}

/* --------------------------------------------------------------------------
 *
 *  AddDeviceObject
 *
 *      Retrieves a Device Object.
 *
 *  Parameters:
 *      Fat     - The FAT Object
 *
 *  Returns:
 *      Returns "0" if the Volume was mounted and binded. If a -1 is returned
 *      then any one of the following could be the reason.
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS AddDeviceObject( PDEVICE_OBJ pDeviceObj )
{
    PDEVICE_OBJ _pDeviceList;
    PDRIVER_OBJ _pDriver;

    DEVOBJ_ASSERT( pDeviceObj != DEVOBJ_NULL );

    /*
     *  Retrieve the Driver
     */

    _pDriver = GetDriverObject( MAJOR_DEVNO(pDeviceObj->nDeviceNo) );

    /*
     *  Valid Driver?
     */

    if ( _pDriver == (PDRIVER_OBJ)0 )
    {
        return 
            _DEV_IOSTATUS_MAKE( 
                DEVICE_CLASS_GENERIC, 
                _DEV_IOSTATUS_NO_DEVICE, 
                _DEV_IOSTATUS_SEVERITY_ERROR 
            );
    }

    /*
     *  Assign the Parent DRIVER
     */

    pDeviceObj->pDrvParent = _pDriver;

    /*
     *  Add the Device Object
     */

    _pDeviceList = _pDriver->pDeviceList;
    _pDriver->pDeviceList = pDeviceObj;
    pDeviceObj->pDevNext = _pDeviceList;

    /*
     *  Initialize Device?
     */

    if ( pDeviceObj->pfnDeviceInit != (FPDEVICEOBJ_INIT)0 )
    {
        return (*pDeviceObj->pfnDeviceInit)( pDeviceObj );
    }
    else
    {
        return
            _DEV_IOSTATUS_MAKE( 
                DEVICE_CLASS_GENERIC, 
                _DEV_IOSTATUS_SUCCESS, 
                _DEV_IOSTATUS_SEVERITY_NONE 
            );
    }
}

/* --------------------------------------------------------------------------
 *
 *  AddDeviceObject
 *
 *      Retrieves a Device Object.
 *
 *  Parameters:
 *      Fat     - The FAT Object
 *
 *  Returns:
 *      Returns "0" if the Volume was mounted and binded. If a -1 is returned
 *      then any one of the following could be the reason.
 *
 *  Notes:
 *      None
 *
 * --------------------------------------------------------------------------
 */

DEV_IOSTATUS RemoveDeviceObject( PDEVICE_OBJ pDeviceObj )
{
    PDEVICE_OBJ* _pPrevDevice;

    DEVOBJ_ASSERT( pDeviceObj != DEVOBJ_NULL );

    /*
     *  Retrieve the Driver
     */

    _pPrevDevice = &( pDeviceObj->pDrvParent->pDeviceList );

    while ( *_pPrevDevice != pDeviceObj )
    {
        _pPrevDevice = &(*_pPrevDevice)->pDevNext;
    }

    *_pPrevDevice = pDeviceObj->pDevNext;

    /*
     *  Return
     */

    return
        _DEV_IOSTATUS_MAKE( 
            DEVICE_CLASS_GENERIC, 
            _DEV_IOSTATUS_SUCCESS, 
            _DEV_IOSTATUS_SEVERITY_NONE 
        );
}

/*
 *  End of devobj.c
 */

