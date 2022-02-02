//***************************************************************************
//
//  Author(s)...: Pashgan    http://ChipEnable.Ru   
//
//  Target(s)...: Mega
//
//  Compiler....: 
//
//  Description.: Драйвер SPI
//
//  Data........: 26.07.13
//
//***************************************************************************
#include "spi_2.h"


/*инициализация SPI*/
void SPI_Init(BYTE hs)
{
  /*настройка портов ввода-вывода
  все выводы, кроме MISO выходы*/
// SPI_DDRXX |= (1<<SPI_MOSI)|(1<<SPI_SCK);
 // SPI_DDRXX &= ~(1<<SPI_MISO);  
 SPI_DDRX |= (1<<SPI_SS);
  
 // SPI_PORTXX |= (1<<SPI_MOSI)|(1<<SPI_SCK)|(1<<SPI_MISO);
  SPI_PORTX |= (1<<SPI_SS);         
   
  /*разрешение spi,старший бит вперед,мастер, режим 0*/ 
 if(!hs)
 {
 SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(1<<SPR0);
 SPSR = (0<<SPI2X);           
 }
 else     
 {
 SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
 SPSR = (1<<SPI2X);    
 }
}

void SPI_Release(void)
{
  SPCR = 0;
  SPSR = 0;
}

/*отослать байт данных по SPI*/
void SPI_WriteByte(uint8_t data)
{
   SPDR = data; 
   while(!(SPSR & (1<<SPIF)));
}

/*получить байт данных по SPI*/
uint8_t SPI_ReadByte(void)
{  
   SPDR = 0xff;
   while(!(SPSR & (1<<SPIF)));
   return SPDR; 
}

/*отослать и получить байт данных по SPI*/
uint8_t SPI_WriteReadByte(uint8_t data)
{  
   SPDR = data;
   while(!(SPSR & (1<<SPIF)));
   return SPDR; 
}

/*отправить несколько байт данных по SPI*/
void SPI_WriteArray(uint8_t num, uint8_t *data)
{
   while(num--){
      SPDR = *data++;
      while(!(SPSR & (1<<SPIF)));
   }
}

/*отправить и получить несколько байт данных по SPI*/
void SPI_WriteReadArray(uint8_t num, uint8_t *data)
{
   while(num--){
      SPDR = *data;
      while(!(SPSR & (1<<SPIF)));
      *data++ = SPDR; 
   }
}