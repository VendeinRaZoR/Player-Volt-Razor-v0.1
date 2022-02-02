
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
 *  support.c
 *
 *      These are support functions that...
 */

#include "devobj.h"

/* --------------------------------------------------------------------------
 *
 *  StringCaseLower
 *
 *      Function to allow a Transpose of one buffer to another. Commonly
 *      used in converting Integral Types from one Architecture (Little or
 *      Big Endian) to the other.
 *
 *  Parameters:
 *      pSource     - Pointer to the source buffer
 *      pDest       -
 *      nLen        -
 *
 *  Returns:
 *      Nothing
 *
 *  Notes:
 *      Use the MACROS LittleEndianToBigEndian or BigEndianToLittleEndian
 *      when converting integral types.
 *
 * --------------------------------------------------------------------------
 */

void StringCaseLower(
    DEV_STRING strBuf,
    DEV_INT nLen
)
{
    DEV_INT _nIdx;

    DEVOBJ_ASSERT( strBuf != DEVOBJ_NULL );
    DEVOBJ_ASSERT( nLen != 0 );

    for ( _nIdx = 0; _nIdx < nLen; _nIdx++ )
    {
        strBuf[_nIdx] = DEVOBJ_TOLOWER( strBuf[_nIdx] );
    }

    return;
}

/* --------------------------------------------------------------------------
 *
 *  StringCaseUpper
 *
 *      Function to allow a Transpose of one buffer to another. Commonly
 *      used in converting Integral Types from one Architecture (Little or
 *      Big Endian) to the other.
 *
 *  Parameters:
 *      pSource     - Pointer to the source buffer
 *      pDest       -
 *      nLen        -
 *
 *  Returns:
 *      Nothing
 *
 *  Notes:
 *      Use the MACROS LittleEndianToBigEndian or BigEndianToLittleEndian
 *      when converting integral types.
 *
 * --------------------------------------------------------------------------
 */

void StringCaseUpper(
    DEV_STRING strBuf,
    DEV_INT nLen
)
{
    DEV_INT _nIdx;

    DEVOBJ_ASSERT( strBuf != DEVOBJ_NULL );
    DEVOBJ_ASSERT( nLen != 0 );

    for ( _nIdx = 0; _nIdx < nLen; _nIdx++ )
    {
        strBuf[_nIdx] = DEVOBJ_TOUPPER( strBuf[_nIdx] );
    }

    return;
}

/* --------------------------------------------------------------------------
 *
 *  StringParse
 *
 *      Parses a TOKEN from the STRING, without altering the contents of the
 *      string. STRTOK is not used, because of how it corrupts the string 
 *      by replacing delimiters with NULL.
 *
 *  Parameters:
 *      strSource    - Source String to PARSE
 *      strToken     - Token String to parse into
 *      strDelimiter - Delimiter
 *
 *  Returns:
 *      Pointer to the next position in the source string OR NULL if no 
 *      delimiter is found
 *
 *  Notes:
 *      The DESTINATION sting is always returned NULL terminated.
 *
 * --------------------------------------------------------------------------
 */

DEV_STRING StringParse(
    DEV_STRING strSource,
    DEV_STRING strToken,
    DEV_STRING strDelimiter
)
{
    DEV_STRING _strTmp;
    DEV_LONG _nLen;

    DEVOBJ_ASSERT( strSource != DEVOBJ_NULL );
    DEVOBJ_ASSERT( strToken != DEVOBJ_NULL );
    DEVOBJ_ASSERT( strDelimiter != DEVOBJ_NULL );

    _strTmp = DEVOBJ_STRSTR( strSource, strDelimiter );
    if ( _strTmp == 0 )
    {
        _nLen = DEVOBJ_STRLEN( strSource );
    }

    else
    {
        _nLen = _strTmp - strSource;
        _strTmp++;
    }

    DEVOBJ_STRNCPY( strToken, strSource, _nLen );
    *( strToken + _nLen ) = DEVOBJ_EOS;

    return _strTmp;
}

/* --------------------------------------------------------------------------
 *  This method is only required if the TARGET architecture is Big Endian
 */

#if ( _DEV_ARCHITECTURE == _DEV_BIG_ENDIAN )

/* --------------------------------------------------------------------------
 *
 *  TransposeToBuffer
 *
 *      Function to allow a Transpose of one buffer to another. Commonly
 *      used in converting Integral Types from one Architecture (Little or
 *      Big Endian) to the other.
 *
 *  Parameters:
 *      pSource     - Pointer to the source buffer
 *      pDest       - Pointer to the destination buffer (transpose of source)
 *      nLen        - The length of number of entries in the source buffer to
 *                    transpose.
 *
 *  Returns:
 *      Nothing
 *
 *  Notes:
 *      Use the MACROS LittleEndianToBigEndian or BigEndianToLittleEndian
 *      when converting integral types.
 *
 * --------------------------------------------------------------------------
 */

void TransposeToBuffer(
    DEV_PVOID pSource,
    DEV_PVOID pDest,
    DEV_INT nLen
)
{
    register DEV_USTRING _pSource = (DEV_USTRING)pSource;
    register DEV_USTRING _pDest = ( (DEV_USTRING)pDest + (nLen-1) );

    /*
     *  Debug
     */

    DEVOBJ_ASSERT( pSource != DEVOBJ_NULL );
    DEVOBJ_ASSERT( pDest != DEVOBJ_NULL );

    while( nLen-- )
    {
        *_pDest = *_pSource;

        _pDest--;
        _pSource++;
    }

    return;
}

#endif

/* --------------------------------------------------------------------------
 *  Example functions that can be used IF no support for either is available
 *  on the target environment. For now, base the build on WINDOWS just to 
 *  test their usage
 *
 */

#ifdef WINDOWS

/* --------------------------------------------------------------------------
 *
 *  LocalTime
 *
 *      Converts a time stored as a time_t value and stores the result in a 
 *      structure of type DEV_LOCALTIME. The long value timer represents the 
 *      seconds elapsed since midnight (00:00:00), January 1, 1970, UTC. This 
 *      value is usually obtained from the time function.
 *
 *
 *  Parameters:
 *      pTimer      - Number of seconds elapsed since midnight Jan 1st, 1970
 *      ptmTime     - Pointer to unitialized structure to fill
 *
 *  Returns:
 *      Returns the pointer
 *
 *  Notes:
 *      LocalTime does not correct for the local time zone. The return 
 *      value is always UTC and the user must adjust accordingly based
 *      on this.
 *
 *      DEV_LOCALTIME structure
 *      =======================
 *
 *      tm_sec      - Seconds after minute (0-59).
 *
 *      tm_min      - Minutes after hour (0-59). 
 *
 *      tm_hour     - Hours after midnight (0-23). 
 *
 *      tm_mday     - Day of month (1-31). 
 *
 *      tm_mon      - Month (0-11; January = 0). 
 *
 *      tm_year     - Year (current year minus 1900). 
 *
 *      tm_wday     - Day of week (0-6; Sunday = 0). 
 *
 *      tm_yday     - Day of year (0-365; January 1 = 0). 
 *
 *      tm_isdst    - Positive value if daylight saving time is in effect; 
 *                    0 if daylight saving time is not in effect; negative 
 *                    value if status of daylight saving time is unknown. 
 *
 *  IMPORTANT: If localtime exist for the development environment then this 
 *  code should be removed 
 * --------------------------------------------------------------------------
 */

DEV_LOCALTIME* LocalTime( DEV_TIME* pTimer )
{
    static DEV_LOCALTIME s_tmLocal;

    static DEV_UINT s_nMonthDay[] = {
        31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
    };
    register DEV_INT _nIdx;
    DEV_TIME _lTimer = *pTimer;

    /*
     *  Debug
     */

    DEVOBJ_ASSERT( pTimer != 0 );

    /*
     *  The time is based on the UNIX time, which is seconds since
     *  January 1, 1970
     *
     *      Get seconds offset within minute (covert to minutes)
     *      Get minutes offset within hour (convert to hours)
     *      Get hours offset within day (convert to days)
     */

    s_tmLocal.tm_sec = DEVOBJ_REM(_lTimer,_SECONDSPERMINUTE);
    _lTimer /= _SECONDSPERMINUTE;

    s_tmLocal.tm_min = DEVOBJ_REM(_lTimer,_MINUTESPERHOUR);
    _lTimer /= _MINUTESPERHOUR;

    s_tmLocal.tm_hour = DEVOBJ_REM(_lTimer,_HOURSPERDAY);
    _lTimer /= _HOURSPERDAY;

    /*
     *  _lTimer is now set to the number of days (calculate the day of the 
     *  week, since Jan 1, 1970 was on a "Thursday (day 4)"
     */

    s_tmLocal.tm_wday = DEVOBJ_REM(( _lTimer + eThursday ), _DAYSPERWEEK);

    /*
     *  Now for the DATE Part, adjust to days and remember to calculate
     *  leap years.
     */

    s_tmLocal.tm_year = _lTimer / _DAYSPERYEAR;
    _lTimer = DEVOBJ_REM(_lTimer,_DAYSPERYEAR);

    /*
     *  NOW adjust the time based on Leap Year information
     */

    _lTimer -= (( s_tmLocal.tm_year + 2 ) / 4 );

    /*
     *  Is current year a Leap Year?
     *
     *      Adjust year since it is year since 1900 (i.e. add 70)
     *      and set the YEAR Day
     */
     
    s_tmLocal.tm_year += 70;
    s_tmLocal.tm_yday = _lTimer;

    if ( DEVOBJ_REM(s_tmLocal.tm_year,4) == 0 )
    {
        s_nMonthDay[ eFebruary ] = 29;        
    }
    else
    {
        s_nMonthDay[ eFebruary ] = 28;
    }

    /*
     *  Calculate Month/Day
     */

    _nIdx = 0;
    while (1)
    {
        if ( _lTimer < (DEV_TIME)s_nMonthDay[_nIdx] )
        {
            s_tmLocal.tm_mday = _lTimer + 1;
            break;
        }

        _lTimer -= s_nMonthDay[_nIdx];
        s_tmLocal.tm_mon;

        /*
         *  Next Month
         */

        _nIdx++;
    }

    /*
     *  The Month is wherever the Index currently is (Will never reach 
     *  _MONTHSPERYEAR or shouldn't)
     */

    s_tmLocal.tm_mon = _nIdx;
    s_tmLocal.tm_isdst = -1;

    return &s_tmLocal;
}

/* --------------------------------------------------------------------------
 *
 *  ListDir
 *
 *      Implements the UNIX/Linux "ls" command line function.
 *
 *
 *  Parameters:
 *      strPath     - Pathname of the Directory to list
 *      ptmTime     - Pointer to unitialized structure to fill
 *
 *  Returns:
 *      Returns the number of entries in the directory as well as the 
 *      initialized BUFFER, which the caller must free up!
 *
 *  Notes:
 *      The listing is written to a string allocated by this function, but
 *      the caller/client must free this memory when finished.
 * --------------------------------------------------------------------------
 */

#include "file_api.h"

#define LIST_LINELEN        80
#define LIST_CRLF           "\x0d\x0a"

DEV_LONG ListDir( 
    DEV_STRING strPath, 
    DEV_STRING* pstrListing 
)
{
    DIRDESC _hDir;
    DIRECT _direct;
    DEV_STRING _strFile;
    DEV_STRING _strCur;
    DEV_LONG _nEntries = 0;

    /*
     *  Debug
     */
    
    DEVOBJ_ASSERT( strPath != 0 );
    DEVOBJ_ASSERT( pstrListing != 0 );

    /*
     *  Open the directory
     */

    do
    {
        _hDir = sys_opendir( strPath );
        if ( _ISERROR(_hDir) )
        {
            break;
        }

        /*
         *  Count the number of Entries
         */

        while ( sys_readdir( _hDir, &_direct ) == ESUCCESS )
        {
            if ( _direct.d_ino != 0 )
            {
                _nEntries++;
            }
        }

        if ( _nEntries == 0 )
        {
            *pstrListing = 0;
            break;
        }
        sys_rewinddir(_hDir);

        /*
         *  Allocate the buffer
         */

        *pstrListing = (DEV_STRING)DEVOBJ_MALLOC(LIST_LINELEN * _nEntries );
        if ( *pstrListing == 0 )
        {
            break;
        }
        *pstrListing[0] = '\0';
        _strCur = *pstrListing;

        /*
         *  Now for each entry
         */

        _strFile = DEVOBJ_MALLOC( DEVOBJ_STRLEN(strPath) + DIRSIZE );
        if ( _strFile == 0 )
        {
            break;
        }

        while ( sys_readdir( _hDir, &_direct ) == ESUCCESS )
        {
            STAT _stat;

            /* 
             *  Valid Entry?
             */

            if ( _direct.d_ino != 0 )
            {
                DEVOBJ_STRCPY( _strFile, strPath );
                DEVOBJ_STRCAT( _strFile, "\\" );
                DEVOBJ_STRCAT( _strFile, _direct.d_name );

                /*
                 *  Format the DATE and TIME
                 */

                if ( !_ISERROR( sys_stat( _strFile, &_stat ) ) )
                {
                    register DEV_LONG _nLen;
                    DEV_LOCALTIME* _pLocalTime;
                     
                    DEVOBJ_LOCALTIME( &_stat.st_mtime, _pLocalTime );

                    /*
                     *  Concatenate Date
                     */

                    DEVOBJ_STRCPY( _strCur, "00" );
                    DEVOBJ_LTOA( _pLocalTime->tm_mon + 1, _strFile, 10 );
                    _nLen = DEVOBJ_STRLEN(_strFile);
                    if ( _nLen < 2 )
                    {
                        *( ++_strCur ) = *_strFile;
                    }
                    else
                    {
                        DEVOBJ_STRCPY( _strCur, _strFile );
                    }
                    _strCur += _nLen;
                    *_strCur++ = '/';

                    DEVOBJ_STRCPY( _strCur, "00" );
                    DEVOBJ_LTOA( _pLocalTime->tm_mday, _strFile, 10 );
                    _nLen = DEVOBJ_STRLEN(_strFile);
                    if ( _nLen < 2 )
                    {
                        *( ++_strCur ) = *_strFile;
                    }
                    else
                    {
                        DEVOBJ_STRCPY( _strCur, _strFile );
                    }
                    _strCur += _nLen;
                    *_strCur++ = '/';

                    DEVOBJ_LTOA( _pLocalTime->tm_year + 1900, _strFile, 10 );
                    DEVOBJ_STRCPY( _strCur, _strFile );
                    _strCur += DEVOBJ_STRLEN(_strFile );
                    DEVOBJ_STRCPY( _strCur, "  " );
                    _strCur += 2;

                    /*
                     *  Concatenate Time
                     */

                    DEVOBJ_STRCPY( _strCur, "00" );
                    DEVOBJ_LTOA( _pLocalTime->tm_hour + 1, _strFile, 10 );
                    _nLen = DEVOBJ_STRLEN(_strFile);
                    if ( _nLen < 2 )
                    {
                        *( ++_strCur ) = *_strFile;
                    }
                    else
                    {
                        DEVOBJ_STRCPY( _strCur, _strFile );
                    }
                    _strCur += _nLen;
                    *_strCur++ = ':';

                    DEVOBJ_STRCPY( _strCur, "00" );
                    DEVOBJ_LTOA( _pLocalTime->tm_min + 1, _strFile, 10 );
                    _nLen = DEVOBJ_STRLEN(_strFile);
                    if ( _nLen < 2 )
                    {
                        *( ++_strCur ) = *_strFile;
                    }
                    else
                    {
                        DEVOBJ_STRCPY( _strCur, _strFile );
                    }
                    _strCur += _nLen;
                    *_strCur++ = ':';

                    DEVOBJ_STRCPY( _strCur, "00" );
                    DEVOBJ_LTOA( _pLocalTime->tm_sec + 1, _strFile, 10 );
                    _nLen = DEVOBJ_STRLEN(_strFile);
                    if ( _nLen < 2 )
                    {
                        *( ++_strCur ) = *_strFile;
                    }
                    else
                    {
                        DEVOBJ_STRCPY( _strCur, _strFile );
                    }
                    _strCur += _nLen;

                    /*
                     *  Type of FILE and Size
                     */

                    if ( (_stat.st_mode & _SMODE_IFMT) == _SMODE_IFDIR )
                    {
                        DEVOBJ_STRCPY( _strCur, "     <DIR>          " );              
                        _strCur += 20;
                    }
                    else
                    {
                        DEVOBJ_LTOA( _stat.st_size, _strFile, 10 );
                        DEVOBJ_STRCPY( _strCur, "                    " );

                        _nLen = DEVOBJ_STRLEN(_strFile);
                        _strCur += ( 19 - _nLen );
                        DEVOBJ_STRNCPY( _strCur, _strFile, _nLen++ );
                        _strCur += _nLen;
                    }
                }

                /*
                 *  Finally the FILE NAME 
                 */

                DEVOBJ_STRCPY( _strCur, _direct.d_name );
                _strCur += DEVOBJ_STRLEN( _direct.d_name );
                DEVOBJ_STRCPY( _strCur, LIST_CRLF );
                _strCur += DEVOBJ_STRLEN( LIST_CRLF );
            }
        }

        DEVOBJ_FREE( _strFile );
    }
    while(0);

    /*
     *  And CLOSE OUT
     */

    sys_close( _hDir );

    /*
     *  Return the total number of valid entries
     */

    return _nEntries;
}

#endif

/*
 *  End of 
 */

