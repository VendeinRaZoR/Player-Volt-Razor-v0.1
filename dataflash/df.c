#include "df.h"

#define DF_PORT PORTD
#define DF_SS     1
#define __NULL_INST   0b11111111;
#define DF_SS_SELECT do{DF_PORT &= ~(1<<(DF_SS)); }while(0)
#define DF_SS_DESELECT do{DF_PORT |= (1<<(DF_SS)); }while(0)

unsigned char df_Memory_Read_Status(void)
{
unsigned char temp;
DF_SS_SELECT;  
SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
SPSR = (1<<SPI2X);
SPDR = 0xD7;
while(!(SPSR & (1<<SPIF)));
SPDR = __NULL_INST;    
while(!(SPSR & (1<<SPIF)));
temp = SPDR;
SPCR = 0;
SPSR = 0;
DF_SS_DESELECT;
return temp;
}

void df_Memory_Erase()
{
unsigned char MEM_status = df_Memory_Read_Status();
DF_SS_SELECT;  
SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
SPSR = (1<<SPI2X);
SPDR = 0xC7;
while(!(SPSR & (1<<SPIF)));
SPDR = 0x94;
while(!(SPSR & (1<<SPIF)));
SPDR = 0x80;
while(!(SPSR & (1<<SPIF)));
SPDR = 0x9A;
while(!(SPSR & (1<<SPIF)));
DF_SS_DESELECT;
// Delay Tce = 7-22S  (Check Status.RDY)
SPCR = 0;
SPSR = 0;
//PORTD.0 = 1; 
do
{
MEM_status = df_Memory_Read_Status();
} while (!(MEM_status & 0x80));
}

void df_Memory_Read_Buffer(DWORD dwPageAddress,DWORD dwBufferAddress,unsigned char * pBuffer, unsigned int nBytes,unsigned char bBuffer)
{
unsigned char MEM_status = df_Memory_Read_Status();
int i = 0;
DF_SS_SELECT;  
SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
SPSR = (1<<SPI2X);
if(bBuffer == 1)
SPDR = 0x53; //Command
if(bBuffer == 2)
SPDR = 0x55; //Command
while(!(SPSR & (1<<SPIF)));
SPDR = (dwPageAddress&0xFF0000);
while(!(SPSR & (1<<SPIF)));
SPDR = (dwPageAddress&0xFF00);
while(!(SPSR & (1<<SPIF)));
SPDR = (dwPageAddress&0xFF);
while(!(SPSR & (1<<SPIF)));
DF_SS_DESELECT;
SPCR = 0;
SPSR = 0;
// Delay Txfr = 200uS  (Check Status.RDY)
do
{
   MEM_status = df_Memory_Read_Status();
} while (!(MEM_status & 0x80));
DF_SS_SELECT;  
SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
SPSR = (1<<SPI2X);
if(bBuffer == 1)// 2 buffers !!!
SPDR = 0xD1;  //Command
if(bBuffer == 2)
SPDR = 0xD2;
while(!(SPSR & (1<<SPIF)));
SPDR = (dwBufferAddress&0xFF0000);
while(!(SPSR & (1<<SPIF)));
SPDR = (dwBufferAddress&0xFF00);
while(!(SPSR & (1<<SPIF)));
SPDR = (dwBufferAddress&0xFF);
while(!(SPSR & (1<<SPIF)));
SPDR = 0x00;    //Dummy
while(!(SPSR & (1<<SPIF)));
for(i = 0;i<nBytes;i++)
{
SPDR = __NULL_INST;    
while(!(SPSR & (1<<SPIF)));
pBuffer[i] = SPDR;
}
SPCR = 0;
SPSR = 0;
DF_SS_DESELECT;
}

void df_Memory_Write_Buffer(DWORD dwPageAddress,DWORD dwBufferAddress,unsigned char * pBuffer, unsigned int nBytes,unsigned char bBuffer)
{   
unsigned char MEM_status = df_Memory_Read_Status();
int i = 0;
DF_SS_SELECT;  
SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
SPSR = (1<<SPI2X);
if(bBuffer == 1)
SPDR = 0x53; //Command
if(bBuffer == 2)
SPDR = 0x55; //Command
while(!(SPSR & (1<<SPIF)));
SPDR = (dwPageAddress&0xFF0000);
while(!(SPSR & (1<<SPIF)));
SPDR = (dwPageAddress&0xFF00);
while(!(SPSR & (1<<SPIF)));
SPDR = (dwPageAddress&0xFF);
while(!(SPSR & (1<<SPIF)));
DF_SS_DESELECT;
SPCR = 0;
SPSR = 0;
do
{
   MEM_status = df_Memory_Read_Status();
} while (!(MEM_status & 0x80));
DF_SS_SELECT;  
SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
SPSR = (1<<SPI2X);
if(bBuffer == 1)// 2 buffers !!!
SPDR = 0x84;  //Command
if(bBuffer == 2)
SPDR = 0x87;
while(!(SPSR & (1<<SPIF)));
SPDR = (dwBufferAddress&0xFF0000);
while(!(SPSR & (1<<SPIF)));
SPDR = (dwBufferAddress&0xFF00);
while(!(SPSR & (1<<SPIF)));
SPDR = (dwBufferAddress&0xFF);
while(!(SPSR & (1<<SPIF)));
SPDR = 0x00;    //Dummy
while(!(SPSR & (1<<SPIF)));
for(i = 0;i<nBytes;i++)
{
SPDR = pBuffer[i];    //Dummy
while(!(SPSR & (1<<SPIF)));
}
SPCR = 0;
SPSR = 0;
DF_SS_DESELECT;
delay_us(10);
DF_SS_SELECT;  
SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
SPSR = (1<<SPI2X);
if(bBuffer == 1)
SPDR = 0x83; //Command
if(bBuffer == 2)
SPDR = 0x84; //Command
while(!(SPSR & (1<<SPIF)));
SPDR = (dwPageAddress&0xFF0000);
while(!(SPSR & (1<<SPIF)));
SPDR = (dwPageAddress&0xFF00);
while(!(SPSR & (1<<SPIF)));
SPDR = (dwPageAddress&0xFF);
while(!(SPSR & (1<<SPIF)));
DF_SS_DESELECT;
SPCR = 0;
SPSR = 0;
do
{
   MEM_status = df_Memory_Read_Status();
} while (!(MEM_status & 0x80));
}