// CodeVisionAVR C Compiler V3.0
// (C) 2012 Pavel Haiduc, HP InfoTech S.R.L.

#ifdef __CODEVISIONAVR__

#include <stdint.h>

/**
 * \brief Write to a CCP-protected 8-bit I/O register
 *
 * \param addr Address of the I/O register
 * \param value Value to be written
 *
 */
 
#pragma warn-

void ccp_write_io(void *addr, uint8_t value)
{
#asm
    .equ    CCP_IOREG=0xd8
     
    ldi     r22,0
    out     RAMPZ,r22               ; Reset bits 23:16 of Z
    ld      r22,y                   ; r22=value
	ldd     r30,y+1                 ; Load addr into Z
    ldd     r31,y+2
	ldi     r23,CCP_IOREG           ; Load magic CCP value
	out     CCP,r23                 ; Start CCP handshake
	st      z,r22                   ; Write value to I/O register
#endasm
}

#ifdef _WARNINGS_ON_
#pragma warn+
#endif

#endif

