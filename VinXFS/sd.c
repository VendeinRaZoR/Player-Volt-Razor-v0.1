/*
It is an open source software to implement SD routines to
small embedded systems. This is a free software and is opened for education,
research and commercial developments under license policy of following trems.

(C) 2013 vinxru (aleksey.f.morozov@gmail.com)

It is a free software and there is NO WARRANTY.
No restriction on use. You can use, modify and redistribute it for
personal, non-profit or commercial use UNDER YOUR RESPONSIBILITY.
Redistributions of source code must retain the above copyright notice.

Version 0.99 5-05-2013
*/

#include "common.h"
#include <delay.h>
#include "sd.h"
#include "fs.h"
#include "PetitFATFS/spi_2.c"

#define SELECT()    SPI_EnableSS_m(SPI_SS)	/* CS = L */
#define DESELECT()	SPI_DisableSS_m(SPI_SS)	/* CS = H */
#define MMC_SEL	    SPI_StatSS_m(SPI_SS)   	/* CS status (true:CS == L) */
#define FORWARD(d)	         		/* Data forwarding function (Console out in this example) */

#define init_spi(hs)  SPI_Init(hs)    	/* Initialize SPI port (usi.S) */
#define release_spi() SPI_Release()
#define dly_100us() delay_us(100)	/* Delay 100 microseconds (usi.S) */
#define xmit_spi(d) SPI_WriteByte_m(d) /* Send a byte to the MMC (usi.S) */
#define rcv_spi()	SPI_ReadByte_i()   /* Send a 0xFF to the MMC and get the received byte (usi.S) */

BYTE sd_sdhc; /* Используется SDHC карта */

/**************************************************************************
*  Протокол SPI для ATMega8                                               *
*  Может отличаться для разных МК.                                        *
**************************************************************************/

/* Куда подключена линия CS карты */
#define SD_CS_ENABLE   PORTC &= ~(1<<3);
#define SD_CS_DISABLE   PORTC |= (1<<3);

/* Совместимость с разными версиями CodeVisionAVR */
#ifndef SPI2X
#define SPI2X 0
#endif

#define CT_MMC				0x01	/* MMC ver 3 */
#define CT_SD1				0x02	/* SD ver 1 */
#define CT_SD2				0x04	/* SD ver 2 */
#define CT_BLOCK			0x08	/* Block addressing */

#define SPI_INIT      { SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(1<<SPR0); SPSR = (0<<SPI2X); }    
#define SPI_HIGHSPEED { SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0); SPSR = (1<<SPI2X); delay_ms(1); }
#define SPI_RELEASE  {SPCR = 0; SPSR = 0;}

static void spi_transmit(BYTE data) {
  SPDR = data;  
  while(!(SPSR & (1<<SPIF)));
}

static BYTE spi_receive() {        
  SPDR = 0xFF;
  while(!(SPSR & (1<<SPIF)));
  return SPDR;
}

/**************************************************************************
*  Отправка команды                                                       *
**************************************************************************/

/* Используемые каманды SD карты */

#define GO_IDLE_STATE      (0x40 | 0 )
#define SEND_OP_COND_MMC	(0x40|1)
#define SEND_IF_COND       (0x40 | 8 )
#define SET_BLOCKLEN       (0x40 | 16)
#define READ_SINGLE_BLOCK  (0x40 | 17)
#define WRITE_SINGLE_BLOCK (0x40 | 24)
#define SD_SEND_OP_COND    (0x40 | 41)
#define APP_CMD            (0x40 | 55)
#define READ_OCR           (0x40 | 58)

#define CMD0	(0x40+0)	/* GO_IDLE_STATE */
#define CMD1	(0x40+1)	/* SEND_OP_COND (MMC) */
#define	ACMD41	(0xC0+41)	/* SEND_OP_COND (SDC) */
#define CMD8	(0x40+8)	/* SEND_IF_COND */
#define CMD16	(0x40+16)	/* SET_BLOCKLEN */
#define CMD17	(0x40+17)	/* READ_SINGLE_BLOCK */
#define CMD24	(0x40+24)	/* WRITE_BLOCK */
#define CMD55	(0x40+55)	/* APP_CMD */
#define CMD58	(0x40+58)	/* READ_OCR */

static BYTE sd_sendCommand(BYTE cmd, DWORD arg) { 
	BYTE n, res;   
	if (cmd & 0x80) {	/* ACMD<n> is the command sequense of CMD55-CMD<n> */
		cmd &= 0x7F;
		res = sd_sendCommand(CMD55, 0);
		if (res > 1) return res;
	}

	/* Select the card */
	SD_CS_DISABLE
	spi_receive(); 
	SD_CS_ENABLE  
    
	spi_receive();

	/* Send a command packet */
	spi_transmit(cmd);					/* Start + Command index */
	spi_transmit((BYTE)(arg >> 24));		        /* Argument[31..24] */
	spi_transmit((BYTE)(arg >> 16));		        /* Argument[23..16] */
	spi_transmit((BYTE)(arg >> 8));			/* Argument[15..8] */
	spi_transmit((BYTE)arg);				/* Argument[7..0] */
	n = 0x01;							/* Dummy CRC + Stop */
	if (cmd == CMD0) n = 0x95;			/* Valid CRC for CMD0(0) */
	if (cmd == CMD8) n = 0x87;			/* Valid CRC for CMD8(0x1AA) */
	spi_transmit(n);

	/* Receive a command response */
	n = 10;								/* Wait for a valid response in timeout of 10 attempts */
	do {
		res = spi_receive();  
	} while ((res & 0x80) && --n);    
	return res;			/* Return with the response value */
}

/**************************************************************************
*  Проверка готовности/наличия карты                                      *
**************************************************************************/

BYTE sd_check() {
  unsigned int i = 0;     
  do { 
    sd_sendCommand(APP_CMD, 0);
    if(sd_sendCommand(SD_SEND_OP_COND, 0x40000000) == 0) return 0;
  } while(--i);

  return 1;
}

/**************************************************************************
*  Инициализация карты (эта функция вызывается функцией sd_init)          *
**************************************************************************/

static BYTE sd_init_int()
 {
BYTE n, cmd, ty, ocr[4];
	unsigned int tmr;

//#if _USE_WRITE
//	if (CardType && MMC_SEL) disk_writep(0, 0);	/* Finalize write process if it is in progress */
//#endif     
	init_spi(0);		/* Initialize ports to control MMC */  
	SD_CS_DISABLE   
    
	for (n = 10; n; n--)
    {
		spi_receive();	/* 80 dummy clocks with CS=H */
	}        
	ty = 0;
	if (sd_sendCommand(CMD0, 0) == 1) {			/* Enter Idle state */     
		if (sd_sendCommand(CMD8, 0x1AA) == 1) {	/* SDv2 */
			for (n = 0; n < 4; n++)
            {
             ocr[n] = spi_receive();
             }		/* Get trailing return value of R7 resp */
			if (ocr[2] == 0x01 && ocr[3] == 0xAA) {			/* The card can work at vdd range of 2.7-3.6V */
				for (tmr = 10000; tmr && sd_sendCommand(ACMD41, 1UL << 30); tmr--) dly_100us();	/* Wait for leaving idle state (ACMD41 with HCS bit) */
				if (tmr && sd_sendCommand(CMD58, 0) == 0) {		/* Check CCS bit in the OCR */
					for (n = 0; n < 4; n++)  
                    {
                    ocr[n] = spi_receive();
                    }
					ty = (ocr[0] & 0x40) ? CT_SD2 | CT_BLOCK : CT_SD2;	/* SDv2 (HC or SC) */
				}
			}
		} else {							/* SDv1 or MMCv3 */
			if (sd_sendCommand(ACMD41, 0) <= 1) 	{
				ty = CT_SD1; cmd = ACMD41;	/* SDv1 */
			} else {
				ty = CT_MMC; cmd = CMD1;	/* MMCv3 */
			}
			for (tmr = 10000; tmr && sd_sendCommand(cmd, 0); tmr--) dly_100us();	/* Wait for leaving idle state */
			if (!tmr || sd_sendCommand(CMD16, 512) != 0)			/* Set R/W block length to 512 */
				ty = 0;
		}
	}
	//CardType = ty;
	SD_CS_DISABLE
	spi_receive();  

	return ty ? 0 : 1;
}                            

/**************************************************************************
*  Инициализация карты                                                    *
**************************************************************************/

BYTE sd_init() {  
  BYTE tries;

  /* Освобождаем CS на всякий случай */
  SD_CS_DISABLE

  /* Включаем SPI */
  SPI_INIT
  /* Делаем несколько попыток инициализации */    
 // if(sd_init_int())
 // return 1;
  tries = 10; 
  while(sd_init_int()) 
    if(--tries == 0) {
     lastError = ERR_DISK_ERR;
     return 1;       
    }   
          
  /* Вклчюаем максимальную скорость */
  //SPI_HIGHSPEED  
  SPI_RELEASE
  // SPI_HIGHSPEED;
  return 0;
}

/**************************************************************************
*  Ожидание определенного байта на шине                                   *
**************************************************************************/

static BYTE sd_waitBus(BYTE byte) {
  WORD retry = 0;
  do {
    if(spi_receive() == byte) return 0;
  } while(++retry); 
  return 1;
}

/**************************************************************************
*  Чтение произвольного участка сектора                                   *
**************************************************************************/

BYTE sd_read(BYTE* buffer, DWORD sector, WORD offsetInSector, WORD length) {
  BYTE b;
  WORD i;
    
  /* Посылаем команду */
  if(sd_sendCommand(READ_SINGLE_BLOCK, sector)) goto abort;

  /* Сразу же возращаем CS, что бы принять ответ команды */
  SD_CS_ENABLE

  /* Ждем стартовый байт */
  if(sd_waitBus(0xFE)) goto abort;

  /* Принимаем 512 байт */
  for(i=512; i; --i) {
    b = spi_receive();
    if(offsetInSector) { offsetInSector--; continue; }
    if(length == 0) continue;
    length--;
    *buffer++ = b;
  }

  /* CRC игнорируем */
  spi_receive();
  spi_receive();

  /* отпускаем CS и пауза в 1 байт*/
  SD_CS_DISABLE
  spi_receive(); 

  /* Ок */
  return 0;

  /* Ошибка и отпускаем CS.*/
abort:
  SD_CS_DISABLE
  lastError = ERR_DISK_ERR;
  return 1;
}

/**************************************************************************
*  Запись сектора (512 байт)                                              *
**************************************************************************/

BYTE sd_write512(BYTE* buffer, DWORD sector) {
  WORD n;
  
  /* Посылаем команду */
  if(sd_sendCommand(WRITE_SINGLE_BLOCK, sector)) goto abort;

  /* Сразу же возращаем CS, что бы отправить блок данных */
  SD_CS_ENABLE

  /* Посылаем стартовый байт */
  spi_transmit(0xFE);
  
  /* Данные */
  for(n=512; n; --n)    
    spi_transmit(*buffer++);
      
  /* CRC игнорируется */
  spi_transmit(0xFF);
  spi_transmit(0xFF);

  /* Ответ МК */
  if((spi_receive() & 0x1F) != 0x05) goto abort;
                    
  /* Ждем окончания записи, т.е. пока не освободится шина */
  if(sd_waitBus(0xFF)) goto abort;
  
  /* отпускаем CS и пауза в 1 байт*/
  SD_CS_DISABLE
  spi_receive();

  /* Ок */
  return 0;
              
  /* Ошибка.*/
abort:  
  SD_CS_DISABLE 
  lastError = ERR_DISK_ERR;
  return 1;
}
