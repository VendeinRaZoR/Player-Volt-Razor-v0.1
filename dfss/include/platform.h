
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
 *  platform.h
 */

#ifndef __PLATFORM_H
#define __PLATFORM_H

#ifdef __cplusplus
extern "C" {
#endif

/*
 *  Force WINDOWS definition
 */

#ifdef WIN32
    #define WINDOWS
#endif

/*
 *  Force DSP OS definition
 */

#ifndef WIN32
    #define DSP_OS
#endif

/*
 *  Windows
 */

#ifdef WINDOWS

    /*
     *  Debugging Information for Windows
     */

    #define _CRTDBG_MAP_ALLOC
    #include <stdlib.h>
    #include <crtdbg.h>

    #include <assert.h>
    #include <time.h>
    #include <windows.h>

    /*
     *  Debug
     */

    #define DEVOBJ_ASSERT(cond) \
        assert( cond )

    #define DEVOBJ_DUMPMEMORY() \
        _CrtDumpMemoryLeaks()

    /*
     *  Memory Management
     */

    #define DEVOBJ_MALLOC(count) \
        malloc((count))

    #define DEVOBJ_FREE(mem) \
        free((mem))

    #define DEVOBJ_MEMSET(dest,ch,count) \
        memset((dest),(ch),(count))

    #define DEVOBJ_MEMCPY(dest,src,count) \
        memcpy((dest),(src),(count))

    #define DEVOBJ_MEMCMP(buf1,buf2,count) \
        memcpy((buf1),(buf2),(count))

    /*
     *  Synchronization Objects
     *
     *      Developers must define what objects are used, based on operating
     *      system constraints, to provide synchronization.
     */

    #define DEVOBJ_DECLARE_CRITICAL_SECTION(cs) \
        CRITICAL_SECTION cs

    #define DEVOBJ_INIT_CRITICAL_SECTION(cs) \
        InitializeCriticalSection(&(cs))

    #define DEVOBJ_DESTROY_CRITICAL_SECTION(cs) \
        DeleteCriticalSection(&(cs))

    #define DEVOBJ_ENTER_CRITICAL_SECTION(cs) \
        EnterCriticalSection(&(cs))

    #define DEVOBJ_LEAVE_CRITICAL_SECTION(cs) \
        LeaveCriticalSection(&(cs))

    /*
     *  Characters
     *
     */

    #define DEVOBJ_ISLOWER \
        islower

    #define DEVOBJ_ISUPPER \
        isupper

    #define DEVOBJ_TOLOWER \
        tolower

    #define DEVOBJ_TOUPPER \
        toupper

    /*
     *  Strings
     *
     */

    #define DEVOBJ_STRLEN(str) \
        strlen((str))

    #define DEVOBJ_STRCPY(dest,src) \
        strcpy((dest),(src))

    #define DEVOBJ_STRCAT(dest,src) \
        strcat((dest),(src))

    #define DEVOBJ_STRCMP(str1,str2) \
        strcmp((str1),(str2))

    #define DEVOBJ_STRNCPY(dest,src,cnt) \
        strncpy((dest),(src),(cnt))

    #define DEVOBJ_STRNCAT(dest,src,cnt) \
        strncat((dest),(src),(cnt))

    #define DEVOBJ_STRNCMP(str1,str2,cnt) \
        strncmp((str1),(str2),(cnt))

    #define DEVOBJ_STRCHR(str,ch) \
        strchr((str),(ch))

    #define DEVOBJ_STRSTR(str,strset) \
        strstr((str),(strset))

    /*
     *  Date and Time
     */

    typedef time_t      DEV_TIME;
    typedef struct tm   DEV_LOCALTIME;

    #define DEVOBJ_TIME(timer) \
        time((timer))

    /*
     *  Use the defined version
     *
     *      ( tmstruct = localtime( timer ) )
     */

    #define DEVOBJ_LOCALTIME(timer,tmstruct) \
        ((tmstruct) = LocalTime( (timer) ))

    /*
     *  CONVERSIONS (not required unless a List Directory function is used)
     *
     *      LTOA and ITOA are not ANSI specific and on some platforms may not
     *      be supported by the "C" runtime library. 
     */

    #define DEVOBJ_ATOI(str) \
        atoi(str)

    #define DEVOBJ_ATOL(str) \
        atol(str)

    #define DEVOBJ_ITOA(val,str,radix) \
        _itoa((val),(str),(radix))

    #define DEVOBJ_LTOA(val,str,radix) \
        _ltoa((val),(str),(radix))

/*
 *  Other OS defs go here
 */

#else

    /*#ifdef DSP_OS
        #define USE_FUSION_STRINGLIB
       // #include "dsp_os.h"
        #include "fns_str.h"
        #include "fns_mem.h"
        #include "dspos_port.h"
        #include "os_time.h"
      */
        /*
         *  Debug
         */

        #define DEVOBJ_ASSERT(cond) \
           if ( !(cond) ) OS_ASSERT

        #define DEVOBJ_DUMPMEMORY()

        /*
         *  Memory Management Functions
         */

        #define DEVOBJ_MALLOC(count) \
            Dsp_Os_Malloc((count))

	    #define DEVOBJ_FREE(mem) \
            Dsp_Os_Free((mem))

	    #define DEVOBJ_MEMSET(dest,ch,count) \
            Os_Byte_Memset((ch),(void *)(dest),(count))

	    #define DEVOBJ_MEMCPY(dest,src,count) \
            Os_Byte_Memcpy((uint8 *)(src),(uint8 *)(dest),(count))

	    #define DEVOBJ_MEMCMP(buf1,buf2,count) \
            fns_memcmp ((buf1),(buf2),(count))

        /*
         *  Synchronization Objects
         */

	    #define DEVOBJ_DECLARE_CRITICAL_SECTION(cs) \
    	    uint16 cs

	    #define DEVOBJ_INIT_CRITICAL_SECTION(cs) \
            File_System_Init_Critical(&(cs))

	    #define DEVOBJ_DESTROY_CRITICAL_SECTION(cs) \
            File_System_Destroy_Critical((cs))

	    #define DEVOBJ_ENTER_CRITICAL_SECTION(cs) \
        ((Obtain_Semaphore((cs), TRUE, 0) == OS_SUCCESS)? 0 : -1)

	    #define DEVOBJ_LEAVE_CRITICAL_SECTION(cs) \
        ((Release_Semaphore((cs))== OS_SUCCESS)? 0 : -1)

        /*
         *  Characters
         *
         */

	    #define DEVOBJ_ISLOWER \
    	    OS_ISLOWER

	    #define DEVOBJ_ISUPPER \
    	    OS_ISUPPER

	    #define DEVOBJ_TOLOWER \
    	    OS_TOLOWER

	    #define DEVOBJ_TOUPPER \
    	    OS_TOUPPER

        /*
         *  Strings
         *
         */

	    #define DEVOBJ_STRLEN(str) \
    	    OS_STRLEN((str))

	    #define DEVOBJ_STRCPY(dest,src)  \
    	    OS_STRCPY((dest),(src))

	    #define DEVOBJ_STRCAT(dest,src) \
    	    OS_STRCAT((dest),(src))

	    #define DEVOBJ_STRCMP(str1,str2) \
    	    OS_STRCMP((str1),(str2))

	    #define DEVOBJ_STRNCPY(dest,src,cnt) \
    	    OS_STRNCPY((dest),(src),(cnt))

	    #define DEVOBJ_STRNCAT(dest,src,cnt) \
    	    OS_STRNCAT((dest),(src),(cnt))

	    #define DEVOBJ_STRNCMP(str1,str2,cnt) \
    	    OS_STRNCMP((str1),(str2),(cnt))

        #define DEVOBJ_STRCHR(str,ch) \
            OS_STRCHR((str),(ch))

        #define DEVOBJ_STRSTR(str,strset) \
            OS_STRSTR((str),(strset))

        /*
         *  Date and Time
         */

       // typedef time_t      DEV_TIME;
        typedef struct tm   DEV_LOCALTIME;

        #define DEVOBJ_TIME(timer) \
            os_time((timer))


        #define DEVOBJ_LOCALTIME(timer,tmstruct) \
            ( (tmstruct) = os_localtime( (timer) ) )

    #endif

#endif

/*
 *  Define REMAINDER Function (not all Microprocessors nor Compilers support
 *  the Modulo concept so this may need to be redefined to a direct function
 *  call that does remainder through an iterative process).
 */

#define DEVOBJ_REM(n,d)         ( (n) % (d) )

/*
 *  For Time and Date INFORMATION
 */

#define _SECONDSPERMINUTE       60L
#define _MINUTESPERHOUR         60L
#define _HOURSPERDAY            24L

#define _SECONDSPERHOUR         ( _MINUTESPERHOUR * _SECONDSPERMINUTE )
#define _SECONDSPERDAY          ( _SECONDSPERHOUR * _HOURSPERDAY )

#define _DAYSPERWEEK            7L
#define _DAYSPERYEAR            365L
#define _MONTHSPERYEAR          12L

#ifndef DSP_OS
enum _MONTHSOFYEAR {

    eJanuary = 0,
    eFebruary,
    eMarch,
    eApril,
    eMay,
    eJune,
    eJuly,
    eAugust,
    eSeptember,
    eOctober,
    eNovember,
    eDecember
};
#endif

enum _DAYSOFWEEK {

    eSunday = 0,
    eMonday,
    eTuesday,
    eWednesday,
    eThursday,
    eFriday,
    eSaturday
};

/*
 *  Exception Handling
 *
 *
 *      TRY - This block implements
 */

/*
 *  LOCAL Exception Handling
 *
 *      No implementation of NON-LOCAL exception handling is performed at
 *      this time, since typically at a driver level, this is not recommended
 *      as the RUNNING OS is typically in a high risk mode to provide adequate
 *      stack unwinding.
 *
 *      TWO METHODS are displayed here
 */

#undef _TRY
#undef _CATCH
#undef _AND_CATCH
#undef _END_CATCH
#undef _THROW
#undef _THROW_NULL

/*
 *  Exception Types (although the user can define more, these are the basic
 *  ones defined)
 */

enum Exception_
{
    /*
     *  Pre-defined exceptions
     */

    Exception_None          = 0,
    Exception_Default,
    Exception_Memory,
    Exception_Dispatch,
    Exception_File,
    Exception_Device,

    /*
     *  Modules can define additional
     */

    Exception_End
};

typedef enum Exception_     Exception_t;

#define BEGIN_EXCEPTION_TABLE(nam) \
    enum nam##_ { \
        nam##_Begin = Exception_End,

#define END_EXCEPTION_TABLE(nam) \
    }; \
    typedef enum nam##_ nam##_t;

/*
 *  Implementation
 *
 *      METHOD 1: SETJMP / LONGJMP pair
 *
 *          Traditionally, the ANSI-C method of doing exception handling by
 *          method of non-local gotos.
 *
 *      METHOD 2: GOTO
 *
 *
 */

#ifdef _USE_SETJMP

    #include <setjmp.h>

    #define _TRY \
        { \
            static jmp_buf env; \
            int _nException = setjmp( env ); \
            if ( _nException == Exception_None )

    #define _CATCH(e) \
        else if ( _nException != Exception_None ) \
        { \
            if ( _nException == e )

    #define _AND_CATCH(e) \
        else if ( _nException == e )

    #define _ENDCATCH \
            } \
        }

    #define _THROW(e) \
        longjmp( env, e )

    #define _THROW_NONE() \
        longjmp( env, Exception_None )

#else

    #define _TRY \

    #define _CATCH(e) \
        goto Exception_None; \
        while (0) e##:

    #define _AND_CATCH(e) \
        goto Exception_None; \
        while (0) e##:

    #define _END_CATCH \
        Exception_None: ;

    #define _THROW(e) \
        goto e

    #define _THROW_NONE() \
        goto Exception_None

#endif

/*
 *  ALTERNATIVE METHOD
 *
 *      Also only performs local exception handling by implementing,
 *      a dummy do-while(0) construct. This removes the implied ugliness of
 *      that many fear with the "goto" statement, but has some drawbacks as
 *      well.
 *
 *      First it uses an exception variable that is tested after the TRY
 *      BLOCK for any occurrence of an error. It also uses the enumerated
 *      types described above.
 *
 *      DRAWBACKS: Implementing nested loops within the TRY block pose a
 *      a problem as the THROW is handled using a break statement. If a throw
 *      is done within a loop, then control is only passed outside that loop.
 *      In that case, a TRY block would need to WRAP the loop, and the CATCH
 *      clause would simply THROW the exception to the next level.
 *
 *
 *          #define _TRY \
 *          { \
 *              int _nException = Exception_None; \
 *              do
 *
 *          #define _CATCH(e) \
 *              while ( 0 ); \
 *              if ( _nException > Exception_None ) \
 *              { \
 *                  if ( _nException == e )
 *
 *          #define _AND_CATCH(e) \
 *              else if ( _nException == e )
 *
 *          #define _END_CATCH \
 *                  } \
 *              }
 *
 *          #define _THROW(e) \
 *              _nException = e; \
 *              break
 *
 *          #define _THROW_NULL() \
 *              THROW(Exception_Unhandled)
 *
 */

#ifdef __cplusplus
}
#endif

#endif

