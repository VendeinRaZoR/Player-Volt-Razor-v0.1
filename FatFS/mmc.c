/*-----------------------------------------------------------------------*/
/* MMCv3/SDv1/SDv2 (in SPI mode) control module                          */
/*-----------------------------------------------------------------------*/
/*
/  Copyright (C) 2014, ChaN, all right reserved.
/
/ * This software is a free software and there is NO WARRANTY.
/ * No restriction on use. You can use, modify and redistribute it for
/   personal, non-profit or commercial products UNDER YOUR RESPONSIBILITY.
/ * Redistributions of source code must retain the above copyright notice.
/
/-------------------------------------------------------------------------*/

#include <io.h>
#include "diskio.h"
#include "spi_2.c"

#define CT_MMC				0x01	/* MMC ver 3 */
#define CT_SD1				0x02	/* SD ver 1 */
#define CT_SD2				0x04	/* SD ver 2 */
#define CT_SDC				(CT_SD1|CT_SD2)	/* SD */
#define CT_BLOCK			0x08	/* Block addressing */


/* Port controls  (Platform dependent) */
#define CS_LOW()	SPI_EnableSS_m(SPI_SS)		/* CS=low */
#define	CS_HIGH()	SPI_DisableSS_m(SPI_SS)			/* CS=high */
//#define MMC_CD		(!(PINB & 0x10))	/* Card detected.   yes:true, no:false, default:true */
//#define MMC_WP		(PINB & 0x20)		/* Write protected. yes:true, no:false, default:false */
#define	FCLK_SLOW()	SPCR = 0x52		/* Set slow clock (F_CPU / 64) */
#define	FCLK_FAST()	SPCR = 0x50		/* Set fast clock (F_CPU / 2) */
#define	FCLK_STOP()	SPCR = 0		/* Set fast clock (F_CPU / 2) */

#define SELECT()	SPI_EnableSS_m(SPI_SS)	/* CS = L */
#define DESELECT()	SPI_DisableSS_m(SPI_SS)	/* CS = H */
#define MMC_SEL	    SPI_StatSS_m(SPI_SS)   	/* CS status (true:CS == L) */
#define FORWARD(d)	         		/* Data forwarding function (Console out in this example) */

#define init_spi(hs)  SPI_Init(hs)    	/* Initialize SPI port (usi.S) */
#define release_spi() SPI_Release()
#define dly_100us() delay_us(100)	/* Delay 100 microseconds (usi.S) */
#define xmit_spi(d) SPI_WriteByte_m(d) /* Send a byte to the MMC (usi.S) */
#define rcv_spi()	SPI_ReadByte_i()   /* Send a 0xFF to the MMC and get the received byte (usi.S) */


/*--------------------------------------------------------------------------

   Module Private Functions

---------------------------------------------------------------------------*/

/* Definitions for MMC/SDC command */
#define CMD0	(0x40+0)			/* GO_IDLE_STATE */
#define CMD1	(0x40+1)			/* SEND_OP_COND (MMC) */
#define	ACMD41	(0x40+0x80+41)	/* SEND_OP_COND (SDC) */
#define CMD8	(0x40+8)			/* SEND_IF_COND */
#define CMD9	(0x40+9)			/* SEND_CSD */
#define CMD10	(0x40+10)		/* SEND_CID */
#define CMD12	(0x40+12)		/* STOP_TRANSMISSION */
#define ACMD13	(0x40+0x80+13)	/* SD_STATUS (SDC) */
#define CMD16	(0x40+16)		/* SET_BLOCKLEN */
#define CMD17	(0x40+17)		/* READ_SINGLE_BLOCK */
#define CMD18	(0x40+18)		/* READ_MULTIPLE_BLOCK */
#define CMD23	(0x40+23)		/* SET_BLOCK_COUNT (MMC) */
#define	ACMD23	(0x40+0x80+23)	/* SET_WR_BLK_ERASE_COUNT (SDC) */
#define CMD24	(0x40+24)		/* WRITE_BLOCK */
#define CMD25	(0x40+25)		/* WRITE_MULTIPLE_BLOCK */
#define CMD32	(0x40+32)		/* ERASE_ER_BLK_START */
#define CMD33	(0x40+33)		/* ERASE_ER_BLK_END */
#define CMD38	(0x40+38)		/* ERASE */
#define CMD55	(0x40+55)		/* APP_CMD */
#define CMD58	(0x40+58)		/* READ_OCR */


static volatile
DSTATUS Stat = STA_NOINIT;	/* Disk status */

static volatile
BYTE Timer1, Timer2;	/* 100Hz decrement timer */

static
BYTE CardType;			/* Card type flags */






/*-----------------------------------------------------------------------*/
/* Transmit/Receive data from/to MMC via SPI  (Platform dependent)       */
/*-----------------------------------------------------------------------*/

/* Exchange a byte */
static
BYTE xchg_spi (		/* Returns received data */
	BYTE dat		/* Data to be sent */
)
{
	SPDR = dat;
while(!(SPSR & (1<<SPIF)));
	return SPDR;
}

/* Send a data block fast */
static
void xmit_spi_multi (
	const BYTE *p,	/* Data block to be sent */
	UINT cnt		/* Size of data block (must be multiple of 2) */
)
{
	do {
		SPDR = *p++; while(!(SPSR & (1<<SPIF)));
		SPDR = *p++; while(!(SPSR & (1<<SPIF)));
	} while (cnt -= 2);
}

/* Receive a data block fast */
static
void rcvr_spi_multi (
	BYTE *p,	/* Data buffer */
	UINT cnt	/* Size of data block (must be multiple of 2) */
)
{
	do {
		SPDR = 0xFF; while(!(SPSR & (1<<SPIF))); *p++ = SPDR;
		SPDR = 0xFF; while(!(SPSR & (1<<SPIF))); *p++ = SPDR;
	} while (cnt -= 2);
}



/*-----------------------------------------------------------------------*/
/* Wait for card ready                                                   */
/*-----------------------------------------------------------------------*/

static
int wait_ready (	/* 1:Ready, 0:Timeout */
	UINT wt			/* Timeout [ms] */
)
{
	BYTE d;


	WORD n = wt;
	do   
    {
	    d = xchg_spi(0xFF); 
    }
	while (d != 0xFF && --wt);

	return (d == 0xFF) ? 1 : 0;
}



/*-----------------------------------------------------------------------*/
/* Deselect the card and release SPI bus                                 */
/*-----------------------------------------------------------------------*/

static
void deselect (void)
{
	CS_HIGH();		
	xchg_spi(0xFF);	
}



/*-----------------------------------------------------------------------*/
/* Select the card and wait for ready                                    */
/*-----------------------------------------------------------------------*/

static
int select (void)	/* 1:Successful, 0:Timeout */
{
	CS_LOW();		/* Set CS# low */
	xchg_spi(0xFF);	/* Dummy clock (force DO enabled) */ 
    delay_ms(10); 
    wait_ready(500);
     return 1;	/* Wait for card ready */
   // PORTD.0 = 1;  
	deselect();
	return 0;	/* Timeout */
}



/*-----------------------------------------------------------------------*/
/* Receive a data packet from MMC                                        */
/*-----------------------------------------------------------------------*/

static
int rcvr_datablock (
	BYTE *buff,			/* Data buffer to store received data */
	UINT btr			/* Byte count (must be multiple of 4) */
)
{
	BYTE token; 
    WORD n = 20;
  //  release_spi();
  //  init_spi(1);

	do {							/* Wait for data packet in timeout of 200ms */
		token = rcv_spi();  
        sprintf(terror,"error: %x",token); 
	} while ((token == 0xFF) && --n);
	if (token != 0xFE) return 0;	/* If not valid data token, retutn with error */

	rcvr_spi_multi(buff, btr);		/* Receive the data block into buffer */
	xchg_spi(0xFF);					/* Discard CRC */
	xchg_spi(0xFF);

	return 1;						/* Return with success */
}



/*-----------------------------------------------------------------------*/
/* Send a data packet to MMC                                             */
/*-----------------------------------------------------------------------*/

#if	_USE_WRITE
static
int xmit_datablock (
	const BYTE *buff,	/* 512 byte data block to be transmitted */
	BYTE token			/* Data/Stop token */
)
{
	BYTE resp;


	if (!wait_ready(500)) return 0;

	xchg_spi(token);					/* Xmit data token */
	if (token != 0xFD) {	/* Is data token */
		xmit_spi_multi(buff, 512);		/* Xmit the data block to the MMC */
		xchg_spi(0xFF);					/* CRC (Dummy) */
		xchg_spi(0xFF);
		resp = xchg_spi(0xFF);			/* Reveive data response */
		if ((resp & 0x1F) != 0x05)		/* If not accepted, return with error */
			return 0;
	}

	return 1;
}
#endif



/*-----------------------------------------------------------------------*/
/* Send a command packet to MMC                                          */
/*-----------------------------------------------------------------------*/

static
BYTE send_cmd (		/* Returns R1 resp (bit7==1:Send failed) */
	BYTE cmd,		/* Command index */
	DWORD arg		/* Argument */
)
{
	BYTE n, res;  
	if (cmd & 0x80) {	/* ACMD<n> is the command sequense of CMD55-CMD<n> */
		cmd &= 0x7F;
		res = send_cmd(CMD55, 0);
		if (res > 1) return res;
	}

	/* Select the card */
	if (cmd != CMD12) {
		deselect();
		if (!select()) return 0xFF;
	}

/* Send command packet */
	xchg_spi(cmd);				/* Start + Command index */
	xchg_spi((BYTE)(arg >> 24));		/* Argument[31..24] */
	xchg_spi((BYTE)(arg >> 16));		/* Argument[23..16] */
	xchg_spi((BYTE)(arg >> 8));			/* Argument[15..8] */
	xchg_spi((BYTE)arg);				/* Argument[7..0] */
	n = 0x01;							/* Dummy CRC + Stop */
	if (cmd == CMD0) n = 0x95;			/* Valid CRC for CMD0(0) + Stop */
	if (cmd == CMD8) n = 0x87;			/* Valid CRC for CMD8(0x1AA) Stop */
	xchg_spi(n);

	/* Receive command response */
	if (cmd == CMD12) xchg_spi(0xFF);		/* Skip a stuff byte when stop reading */
	n = 10;								/* Wait for a valid response in timeout of 10 attempts */  
	do
		res = xchg_spi(0xFF);
	while ((res & 0x80) && --n);     
	return res;			/* Return with the response value */
}



/*--------------------------------------------------------------------------

   Public Functions

---------------------------------------------------------------------------*/


/*-----------------------------------------------------------------------*/
/* Initialize Disk Drive                                                 */
/*-----------------------------------------------------------------------*/

DSTATUS disk_initialize (
	BYTE pdrv		/* Physical drive nmuber (0) */
)
{
		BYTE n, cmd, ty, ocr[4];
	UINT tmr;


	if (pdrv) return STA_NOINIT;		/* Supports only single drive */
	//power_off();						/* Turn off the socket power to reset the card */
	//if (Stat & STA_NODISK) return Stat;	/* No card in the socket */
	//power_on();							/* Turn on the socket power */
	//FCLK_SLOW();  
    init_spi(0);
	for (n = 10; n; n--) xchg_spi(0xFF);	/* 80 dummy clocks */

	ty = 0;
		if (send_cmd(CMD0, 0) == 1) {			/* Enter Idle state */     
		if (send_cmd(CMD8, 0x1AA) == 1) {	/* SDv2 */
			for (n = 0; n < 4; n++)
            {
             ocr[n] = rcv_spi();
             }		/* Get trailing return value of R7 resp */
			if (ocr[2] == 0x01 && ocr[3] == 0xAA) {			/* The card can work at vdd range of 2.7-3.6V */
				for (tmr = 10000; tmr && send_cmd(ACMD41, 1UL << 30); tmr--) dly_100us();	/* Wait for leaving idle state (ACMD41 with HCS bit) */
				if (tmr && send_cmd(CMD58, 0) == 0) {		/* Check CCS bit in the OCR */
					for (n = 0; n < 4; n++)  
                    {
                    ocr[n] = rcv_spi();
                    }
					ty = (ocr[0] & 0x40) ? CT_SD2 | CT_BLOCK : CT_SD2;	/* SDv2 (HC or SC) */
				}
			}
		} else {							/* SDv1 or MMCv3 */
			if (send_cmd(ACMD41, 0) <= 1) 	{
				ty = CT_SD1; cmd = ACMD41;	/* SDv1 */
			} else {
				ty = CT_MMC; cmd = CMD1;	/* MMCv3 */
			}
			for (tmr = 10000; tmr && send_cmd(cmd, 0); tmr--) dly_100us();	/* Wait for leaving idle state */
			if (!tmr || send_cmd(CMD16, 512) != 0)			/* Set R/W block length to 512 */
				ty = 0;
		}
	}
	CardType = ty;
	deselect();

	if (ty) {			/* Initialization succeded */
		Stat &= ~STA_NOINIT;		/* Clear STA_NOINIT */
		release_spi();
	} else {			/* Initialization failed */
		//power_off();
	}

	return Stat;
}



/*-----------------------------------------------------------------------*/
/* Get Disk Status                                                       */
/*-----------------------------------------------------------------------*/

DSTATUS disk_status (
	BYTE pdrv		/* Physical drive nmuber (0) */
)
{
	if (pdrv) return STA_NOINIT;	/* Supports only single drive */
	return Stat;
}



/*-----------------------------------------------------------------------*/
/* Read Sector(s)                                                        */
/*-----------------------------------------------------------------------*/

DRESULT disk_read (
	BYTE pdrv,			/* Physical drive nmuber (0) */
	BYTE *buff,			/* Pointer to the data buffer to store read data */
	DWORD sector,		/* Start sector number (LBA) */
	UINT count			/* Sector count (1..128) */
)
{
		BYTE cmd;
    init_spi(1); 

	if (pdrv || !count) return RES_PARERR;
	if (Stat & STA_NOINIT) return RES_NOTRDY;

	if (!(CardType & CT_BLOCK)) sector *= 512;	/* Convert to byte address if needed */

	cmd = count > 1 ? CMD18 : CMD17;			/*  READ_MULTIPLE_BLOCK : READ_SINGLE_BLOCK */
	if (send_cmd(cmd, sector) == 0) {
		do {
			if (!rcvr_datablock(buff, 512)) break;
			buff += 512;
		} while (--count);
		if (cmd == CMD18) send_cmd(CMD12, 0);	/* STOP_TRANSMISSION */
	}
	deselect();
    release_spi();
	return count ? RES_ERROR : RES_OK;
}



/*-----------------------------------------------------------------------*/
/* Write Sector(s)                                                       */
/*-----------------------------------------------------------------------*/

#if _USE_WRITE
DRESULT disk_write (
	BYTE pdrv,			/* Physical drive nmuber (0) */
	const BYTE *buff,	/* Pointer to the data to be written */
	DWORD sector,		/* Start sector number (LBA) */
	UINT count			/* Sector count (1..128) */
)
{
    init_spi(1);
	if (pdrv || !count) return RES_PARERR;
	if (Stat & STA_NOINIT) return RES_NOTRDY;
	if (Stat & STA_PROTECT) return RES_WRPRT;

	if (!(CardType & CT_BLOCK)) sector *= 512;	/* Convert to byte address if needed */

	if (count == 1) {	/* Single block write */    
		if ((send_cmd(CMD24, sector) == 0)	/* WRITE_BLOCK */
           && xmit_datablock(buff, 0xFE))
			count = 0;
	}
	else {				/* Multiple block write */
		if (CardType & CT_SDC) send_cmd(ACMD23, count);
		if (send_cmd(CMD25, sector) == 0) {	/* WRITE_MULTIPLE_BLOCK */
			do {
				if (!xmit_datablock(buff, 0xFC)) break;
				buff += 512;
			} while (--count);
			if (!xmit_datablock(0, 0xFD))	/* STOP_TRAN token */
				count = 1;
		}
	}
	deselect();
    release_spi();
	return count ? RES_ERROR : RES_OK;
}
#endif


/*-----------------------------------------------------------------------*/
/* Miscellaneous Functions                                               */
/*-----------------------------------------------------------------------*/

#if _USE_IOCTL
DRESULT disk_ioctl (
	BYTE pdrv,		/* Physical drive nmuber (0) */
	BYTE cmd,		/* Control code */
	void *buff		/* Buffer to send/receive control data */
)
{
	DRESULT res;
	BYTE n, csd[16], *ptr = buff;
	DWORD csize;

    init_spi(1);
	if (pdrv) return RES_PARERR;

	res = RES_ERROR;

	if (Stat & STA_NOINIT) return RES_NOTRDY;

	switch (cmd) {
	case CTRL_SYNC :		/* Make sure that no pending write process. Do not remove this or written sector might not left updated. */
		if (select()) res = RES_OK;
		break;

	case GET_SECTOR_COUNT :	/* Get number of sectors on the disk (DWORD) */
		if ((send_cmd(CMD9, 0) == 0) && rcvr_datablock(csd, 16)) {
			if ((csd[0] >> 6) == 1) {	/* SDC ver 2.00 */
				csize = csd[9] + ((WORD)csd[8] << 8) + ((DWORD)(csd[7] & 63) << 16) + 1;
				*(DWORD*)buff = csize << 10;
			} else {					/* SDC ver 1.XX or MMC*/
				n = (csd[5] & 15) + ((csd[10] & 128) >> 7) + ((csd[9] & 3) << 1) + 2;
				csize = (csd[8] >> 6) + ((WORD)csd[7] << 2) + ((WORD)(csd[6] & 3) << 10) + 1;
				*(DWORD*)buff = csize << (n - 9);
			}
			res = RES_OK;
		}
		break;

	case GET_BLOCK_SIZE :	/* Get erase block size in unit of sector (DWORD) */
		if (CardType & CT_SD2) {	/* SDv2? */
			if (send_cmd(ACMD13, 0) == 0) {	/* Read SD status */
				xchg_spi(0xFF);
				if (rcvr_datablock(csd, 16)) {				/* Read partial block */
					for (n = 64 - 16; n; n--) xchg_spi(0xFF);	/* Purge trailing data */
					*(DWORD*)buff = 16UL << (csd[10] >> 4);
					res = RES_OK;
				}
			}
		} else {					/* SDv1 or MMCv3 */
			if ((send_cmd(CMD9, 0) == 0) && rcvr_datablock(csd, 16)) {	/* Read CSD */
				if (CardType & CT_SD1) {	/* SDv1 */
					*(DWORD*)buff = (((csd[10] & 63) << 1) + ((WORD)(csd[11] & 128) >> 7) + 1) << ((csd[13] >> 6) - 1);
				} else {					/* MMCv3 */
					*(DWORD*)buff = ((WORD)((csd[10] & 124) >> 2) + 1) * (((csd[11] & 3) << 3) + ((csd[11] & 224) >> 5) + 1);
				}
				res = RES_OK;
			}
		}
		break;

	/* Following commands are never used by FatFs module */

	case MMC_GET_TYPE :		/* Get card type flags (1 byte) */
		*ptr = CardType;
		res = RES_OK;
		break;

	case MMC_GET_CSD :		/* Receive CSD as a data block (16 bytes) */
		if (send_cmd(CMD9, 0) == 0		/* READ_CSD */
			&& rcvr_datablock(ptr, 16))
			res = RES_OK;
		break;

	case MMC_GET_CID :		/* Receive CID as a data block (16 bytes) */
		if (send_cmd(CMD10, 0) == 0		/* READ_CID */
			&& rcvr_datablock(ptr, 16))
			res = RES_OK;
		break;

	case MMC_GET_OCR :		/* Receive OCR as an R3 resp (4 bytes) */
		if (send_cmd(CMD58, 0) == 0) {	/* READ_OCR */
			for (n = 4; n; n--) *ptr++ = xchg_spi(0xFF);
			res = RES_OK;
		}
		break;

	case MMC_GET_SDSTAT :	/* Receive SD statsu as a data block (64 bytes) */
		if (send_cmd(ACMD13, 0) == 0) {	/* SD_STATUS */
			xchg_spi(0xFF);
			if (rcvr_datablock(ptr, 64))
				res = RES_OK;
		}
		break;

	//case CTRL_POWER_OFF :	/* Power off */
	//	power_off();
	//	Stat |= STA_NOINIT;
	//	res = RES_OK;
	//	break;

	default:
		res = RES_PARERR;
	}

	deselect();
    release_spi();
	return res;
}
#endif


/*-----------------------------------------------------------------------*/
/* Device Timer Interrupt Procedure                                      */
/*-----------------------------------------------------------------------*/
/* This function must be called in period of 10ms                        */

void disk_timerproc (void)
{
	BYTE n, s;


	n = Timer1;				/* 100Hz decrement timer */
	if (n) Timer1 = --n;
	n = Timer2;
	if (n) Timer2 = --n;

	s = Stat;

	//if (MMC_WP)				/* Write protected */
	//	s |= STA_PROTECT;
	//else					/* Write enabled */
		s &= ~STA_PROTECT;

	//if (MMC_CD)				/* Card inserted */
	//	s &= ~STA_NODISK;
	//else					/* Socket empty */
		s |= (STA_NODISK | STA_NOINIT);

	Stat = s;				/* Update MMC status */
}
