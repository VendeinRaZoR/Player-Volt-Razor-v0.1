/*
 * attiny_usb.c
 *
 * Created: 05.09.2016 23:56:04
 * Author: Vendein_RaZoR
 */

#include <io.h>
#include <tiny85.h>
#include "usb.c"

byte_t		usb_setup ( byte_t data[8] )
{
}

void		usb_out ( byte_t* data, byte_t len )
{
}

byte_t		usb_in ( byte_t* data, byte_t len )
{

}

void		crc ( byte_t* data, byte_t len )
{
#asm
{
; ----------------------------------------------------------------------
; void crc(unsigned char *data, unsigned char len);
; ----------------------------------------------------------------------
#define    data    r24
#define    len    r22

#define    b    r18
#define    con_01    r19
#define    con_a0    r20
#define    crc_l    r24
#define    crc_h    r25

   // .text
    //.global    crc
   // .type    crc, @function
crc:
    movw    r26, r24
    ldi    crc_h, 0xff
	ldi	crc_l, 0xff
	tst	len
	breq	done1
	ldi	con_a0, 0xa0
	ldi	con_01, 0x01
next_byte:
	ld	b, X+
	eor	crc_l, b
	ldi	b, 8
next_bit:
	lsr	crc_h
	ror	crc_l
	brcc	noxor
	eor	crc_h, con_a0
	eor	crc_l, con_01
noxor:
	dec	b
	brne	next_bit
	dec	len
	brne	next_byte
done1:
	com	crc_l
	com	crc_h
	st	X+, crc_l
	st	X+, crc_h
	ret
}
#endasm
}

void main(void)
{
usb_init();
while (1)
    {
    // Please write your application code here
  usb_poll();
    }
}
