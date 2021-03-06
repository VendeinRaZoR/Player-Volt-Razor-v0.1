//***************************************************************************
//  File........: Nokia6610_lcd_lib.c
//  Author(s)...: Goncharenko Valery and Chiper
//  URL(s)......: http://digitalchip.ru
//  Device(s)...: ATMega8
//  Compiler....: Winavr-20100110
//  Description.: ??????? LCD Nokia6610 ( ONLY PCF8833 )
//  Data........: 08.06.12
//  Version.....: 1.0 
//***************************************************************************
//  Notice: ??? ??????????? ???????? LCD-??????????? ?????? ???? ?????????? ?
//  ?????? ? ???? ?? ????? ?? ????????????????
//***************************************************************************
#include "Nokia6610_lcd_lib.h"
#include <delay.h>
#include <pgmspace.h> //?? ?????? ??????
#include "Nokia6610_fnt8x8.h"

//******************************************************************************
//  ????????????? ??????????? PCF8833
void nlcd_Init(void)
{	

	CS_LCD_RESET;
	SDA_LCD_RESET;
	SCLK_LCD_SET;
	
	RST_LCD_SET;    //     ********************************************** 
	RST_LCD_RESET;  //     *                                             *
	delay_ms(1);   //     *  ???????? ??? ????????? ?????????? ??????   *
	RST_LCD_SET;    //     *                                             *
                    //     **********************************************
  //  SCLK_LCD_SET;
    SDA_LCD_SET;
  //  SCLK_LCD_SET;    
     delay_ms(1);   
    nlcd_SendCmd(LCD_PHILLIPS_SWRESET);   //    ??????????? ?????   
    delay_ms(1);   
	nlcd_SendCmd(LCD_PHILLIPS_SLEEPOUT);  //    ????? ?? ?????? ???
     delay_ms(1);   
    nlcd_SendCmd(LCD_PHILLIPS_BSTRON);    //    ???. ?????????? ??????????????? ??????????
    delay_ms(1);                     //    ???????? ??? ????????? ??????? ? ???????????? ??????????
	nlcd_SendCmd(LCD_PHILLIPS_DISPON);    //    ??????? ???.  
     delay_ms(1);   
    nlcd_SendCmd(LCD_PHILLIPS_NORON);     //    ??????? ?????????? - ???.                        
    delay_ms(1);   
    nlcd_SendCmd(LCD_PHILLIPS_SETCON);    //            ?????????????                                  
     delay_ms(1);   
    nlcd_SendDataByte(0x3F);     //         0x00-min   0x3F-max                                
      delay_ms(1);   
    nlcd_SendCmd(LCD_PHILLIPS_CASET);     //    ????????? ?????????? ? ????????? ?????? ???????     
	nlcd_SendDataByte(0);        //                                                         
	nlcd_SendDataByte(131);      //                                                         
	nlcd_SendCmd(LCD_PHILLIPS_PASET);     //     ????????? ?????????? ? ????????? ?????? ????????   
	nlcd_SendDataByte(0);        //                                                        
	nlcd_SendDataByte(131);      //                                                       
                                           //    ******************************************************
    nlcd_SendCmd(LCD_PHILLIPS_COLMOD);    //   *               ????? ?????:                          *
 // nlcd_SendByte(DATA_LCD_MODE,0x02);     //   *     8 ??? ?? ???????- 256 ?????? RGB 4:4:4           * 
	nlcd_SendDataByte(0x03);     //  *     12 ??? ?? ???????- 4096 ?????? RGB 3:3:2  (??????? ? ???????????????)         * 
//  nlcd_SendByte(DATA_LCD_MODE,0x05);     //  *     16 ??? ?? ???????-65535 ?????? RGB 5:6:5           *
	                                       //  **********************************************************
	delay_ms(1);
 // nlcd_SendByte(CMD_LCD_MODE,MADCTL);    //    ??????? ??????? ? ???????? ??????????? ?????? RAM 
//  nlcd_SendByte(DATA_LCD_MODE,0x30);     //   1-byte, ?? ????????? 0?00 - ????? ??????????? ??????? 
	                                       //                ?? ???. 43								 
	nlcd_SendCmd(LCD_PHILLIPS_RAMWR);     //    ?????? ?????? ? RAM ???????	
	delay_ms(1);                          //    ??????? ????
	nlcd_SendCmd(LCD_PHILLIPS_DISPOFF);   //    ????????? ??????? ????? ?? ????????? ????? ?? ??????        
	nlcd_Clear(WHITE);// ??????? ?? ?????, ??? ??? ???? ?????? //nlcd_Clear(BLACK);   //    ???????? ???? ??????? ??????? ????? - ????? ??????? ?????   
    nlcd_RenderPixelBuffer();      
    nlcd_SendCmd(LCD_PHILLIPS_DISPON);    //    ??????? ???.               
}

//#if HARDWARE SPI
void nlcd_InitSPI()
{
DDR_LCD |= (1<<SCLK_LCD_PIN)|(1<<SDA_LCD_PIN)|(1<<CS_LCD_PIN)|(1<<RST_LCD_PIN)|(1<<CS_SRAM_PIN);
DDRC |= (1<<HOLD_SRAM_PIN);
}

//******************************************************************************
//  ???????? ????? (??????? ??? ??????) ?? LCD-??????????
//  mode: CMD_LCD_MODE  - ???????? ???????
//		  DATA_LCD_MODE - ???????? ??????
//  c:    ???????? ????????????? ?????

/*void nlcd_SendByte(char mode,unsigned char c)
{
unsigned char i=0;
   CS_LCD_RESET;   
   SCLK_LCD_RESET;   
 if(mode) SDA_LCD_SET;
	 else	 SDA_LCD_RESET;   
     SCLK_LCD_SET;    
// SPCR |= (1<<SPE);
//   SPDR = c;
 //  while(!(SPSR & (1<<SPIF)));
//   SPCR |= (0<<SPE);
    for(i=0;i<8;i++)
    {
    	SCLK_LCD_RESET;
        if(c & 0x80) SDA_LCD_SET;
        else	     SDA_LCD_RESET;
        SCLK_LCD_SET;
        c <<= 1;
        delay_us(NLCD_MIN_DELAY);
    }
   CS_LCD_SET;    
}      */

void nlcd_SendCmd(unsigned char c)
{
#asm
{
	CBI  0x5,2
    CBI  0x5,5
    CBI  0x5,3
    SBI  0x5,5
}  
#endasm   
SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
SPSR = (1<<SPI2X);
SPDR = c;
while(!(SPSR & (1<<SPIF)));
SPCR = 0;
SPSR = 0;
#asm
{
SBI  0x5,2 
CBI  0x5,5 
}
#endasm  
}

void nlcd_SendDataByte(unsigned char c)
{
#asm
{
	CBI  0x5,2
    CBI  0x5,5
    SBI  0x5,3
    SBI  0x5,5
}       
#endasm  
SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
SPSR = (1<<SPI2X);
SPDR = c;
while(!(SPSR & (1<<SPIF)));
SPCR = 0;
SPSR = 0;
#asm
{
SBI  0x5,2 
}
#endasm  
}
   /*
void nlcd_SendDataByte2(unsigned char a,unsigned char b)
{
#asm
{
	CBI  0x5,2 
    CBI  0x5,5 
}  
#endasm
//First byte
#asm
{
    CBI  0x5,5
    SBI  0x5,3
    SBI  0x5,5 
}  
#endasm    
SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(1<<CPOL)|(1<<CPHA)|(0<<SPR1)|(0<<SPR0);
SPSR = (1<<SPI2X);
SPDR = a;
while(!(SPSR & (1<<SPIF)));
SPCR = 0;
SPSR = 0;
//Second byte
#asm
{
    CBI  0x5,5
    SBI  0x5,3
    SBI  0x5,5 
}  
#endasm    
SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(1<<CPOL)|(1<<CPHA)|(0<<SPR1)|(0<<SPR0);
SPSR = (1<<SPI2X);
SPDR = b;
while(!(SPSR & (1<<SPIF)));
SPCR = 0;
SPSR = 0;
#asm
{
SBI  0x18,2 
}
#endasm
}

void nlcd_SendDataByte3(unsigned char a,unsigned char b,unsigned char c)
{
#asm
{
	CBI  0x18,2
}  
#endasm
//First byte
#asm
{
    CBI  0x18,5
    SBI  0x18,3
    SBI  0x18,5 
}  
#endasm    
SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(1<<CPOL)|(1<<CPHA)|(0<<SPR1)|(0<<SPR0);
SPSR = (1<<SPI2X);
SPDR = a;
while(!(SPSR & (1<<SPIF)));
SPCR = 0;
SPSR = 0;
//Second byte
#asm
{
    CBI  0x18,5
    SBI  0x18,3
    SBI  0x18,5 
}  
#endasm    
SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(1<<CPOL)|(1<<CPHA)|(0<<SPR1)|(0<<SPR0);
SPSR = (1<<SPI2X);
SPDR = b;
while(!(SPSR & (1<<SPIF)));
SPCR = 0;
SPSR = 0;
//Third byte
#asm
{
    CBI  0x18,5
    SBI  0x18,3
    SBI  0x18,5 
}  
#endasm    
SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(1<<CPOL)|(1<<CPHA)|(0<<SPR1)|(0<<SPR0);
SPSR = (1<<SPI2X);
SPDR = c;
while(!(SPSR & (1<<SPIF)));
SPCR = 0;
SPSR = 0;
#asm
{
SBI  0x18,2 
}
#endasm
} */

//******************************************************************************
//	???: 		 GotoXY(unsigned char x, unsigned char y)	 
// 	????????:    ??????? ? ??????? x, y
//           	 GotoXY( x, y)
//	?????????:   x: ??????? 0-131
//			     y: ??????? 0-131
//  ??????:		 GotoXY(32,17);        
//******************************************************************************
void nlcd_GotoXY(unsigned char x, unsigned char y)
{
  /// Useful Anymore with buffer
}

//******************************************************************************
//	???: 		 nlcd_Pixel(unsigned char x, unsigned char y, int color)	 
// 	????????:    ????????????? Pixel ? ??????? x, y, ?????? color
//           	 nlcd_Pixel( x, y,color)
//	?????????:   x:     ??????? 0-131
//			     y:     ??????? 0-131
//               color: ???? (12-bit ??. #define) 
//  ??????:		 nlcd_Pixel(21,45,BLACK);
//******************************************************************************
void nlcd_PixelBox2x2(unsigned char x, unsigned char y, int P1_color,int P2_color, int P3_color, int P4_color)   ///R ????????? ??????? = 0
{
    unsigned char a = (P1_color >> 4);
    unsigned char b = ((P1_color ) << 4) | ((P2_color >> 8) );
    unsigned char c = P2_color;     
    unsigned char e = (P3_color >> 4);
    unsigned char f = ((P3_color ) << 4) | ((P4_color >> 8) );
    unsigned char g = P4_color;   
    unsigned char pBufferSlice[6];
    pBufferSlice[0] = a;
    pBufferSlice[1] = b;  
    pBufferSlice[2] = c;  
    pBufferSlice[3] = e;
    pBufferSlice[4] = f;  
    pBufferSlice[5] = g;     
    x /= 2;                                       
  // ????? ? RAM       
   nlcd_WritePixelBuffer((y*3*(RESRAM_X) + 3*(x)),&pBufferSlice[0],3);      
   nlcd_WritePixelBuffer(((y+1)*3*(RESRAM_X) + 3*(x)),&pBufferSlice[3],3); 
}

//******************************************************************************
//	???: 		 nlcd_Pixel(unsigned char x, unsigned char y, int color)	 
// 	????????:    ????????????? Pixel ? ??????? x, y, ?????? color
//           	 nlcd_Pixel( x, y,color)
//	?????????:   x:     ??????? 0-131
//			     y:     ??????? 0-131
//               color: ???? (12-bit ??. #define) 
//  ??????:		 nlcd_Pixel(21,45,BLACK);
//******************************************************************************
void nlcd_PixelLine2x1(unsigned char x, unsigned char y, int P1_color, int P2_color)   ///R ????????? ??????? = 0
{
    unsigned char a = (P1_color >> 4);
    unsigned char b = ((P1_color ) << 4) | ((P2_color >> 8) );
    unsigned char c = P2_color;   
    unsigned char pBufferSlice[3];
    pBufferSlice[0] = a;
    pBufferSlice[1] = b;  
    pBufferSlice[2] = c; 
    x /= 2;  
   // iff(x%2)x/=2;                                      
  // ????? ? RAM       
   nlcd_WritePixelBuffer((y*3*(RESRAM_X) + 3*(x)),&pBufferSlice[0],3);     
}

void nlcd_HorizontalLine(unsigned char y, int color)
{
int i = 0;
for(i=0;i<131;i++)
nlcd_PixelLine2x1(i,y,color,color);
}

//******************************************************************************
//	???: 		 nlcd_Line(unsigned char x0, unsigned char y0, unsigned char x1, unsigned char y1, int color)	 
// 	????????:    ?????? ????? ?? ?????????? x0, y0 ? ?????????? x1, y1 ?????? color
//           	 nlcd_Line(x0, y0, x1, y1, color)
//	?????????:   x:     ??????? 0-131
//			     y:     ??????? 0-131
//               color: ???? (12-bit ??. #define) 
//  ??????:		 nlcd_Pixel(25,60,25,80,RED);
//******************************************************************************
/*void nlcd_Line(unsigned char x0, unsigned char y0, unsigned char x1, unsigned char y1, int color)
{ 
 
   int dy = y1 - y0; 
   int dx = x1 - x0; 
   int stepx, stepy; 
   if (dy < 0) { dy = -dy;  stepy = -1; } else { stepy = 1; } 
   if (dx < 0) { dx = -dx;  stepx = -1; } else { stepx = 1; } 
 
   dy <<= 1;                              // dy is now 2*dy 
   dx <<= 1;                              // dx is now 2*dx 
 
 
   nlcd_Pixel(x0, y0, color); 
 
   if (dx > dy) 
   { 
       int fraction = dy - (dx >> 1);     // same as 2*dy - dx 
       while (x0 != x1) 
	   { 
 	       if (fraction >= 0) 
		   { 
 		       y0 += stepy; 
               fraction -= dx;            // same as fraction -= 2*dx 
 		   } 
 		x0 += stepx; 
        fraction += dy;                   // same as fraction -= 2*dy 
        nlcd_Pixel(x0, y0, color); 
       } 
   } 
 	else
    { 
 	    int fraction = dx - (dy >> 1); 
        while (y0 != y1) 
		{ 
 		    if (fraction >= 0) 
		    { 
 		        x0 += stepx; 
 				fraction -= dy; 
            } 
        y0 += stepy; 
 	    fraction += dx; 
        nlcd_Pixel(x0, y0, color); 
        } 
 	} 
 
}    */

//******************************************************************************
//	???: 		 nlcd_InitPixelBuffer(int mode)	 
// 	????????:    ????????????? ??????????? ???????, ????? mode - ? ??????? ??????? ???????
//           	 nlcd_Lnlcd_InitPixelBufferine(mode)
//	?????????:   
//  ??????:		 nlcd_InitPixelBuffer(mode);
//******************************************************************************
// ?????? ? SRAM 23X256
void nlcd_InitPixelBuffer(int mode)
{
unsigned char inst = mode<<__MODE_BITS;
CS_SRAM_RESET;
SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
SPSR = (1<<SPI2X);
SPDR = __WRSR_INST;
while(!(SPSR & (1<<SPIF)));
SPDR = inst & __MODE_MASK;
while(!(SPSR & (1<<SPIF)));
SPCR = 0;
SPSR = 0; 
CS_SRAM_SET;
}
//******************************************************************************
//	???: 		 nlcd_WritePixelBuffer(int startaddr, unsigned char* data, int length) 
// 	????????:    ?????? ? ?????????? ??????, ????? ?????? - ???????????, ?????? (Stquently, array)
//           	 nlcd_WritePixelBuffer(startaddr,&data[0],length)
//	?????????:   
//  ??????:		 nlcd_WritePixelBuffer(startaddr,&data[0],length);
//******************************************************************************
// ?????? ? SRAM 23X256
void nlcd_WritePixelBuffer(int startaddr, unsigned char* data, int length)
{
int i;
CS_SRAM_RESET;
SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
SPSR = (1<<SPI2X);
SPDR = __WRITE_INST;
while(!(SPSR & (1<<SPIF)));
SPDR = startaddr>>8;
while(!(SPSR & (1<<SPIF)));
SPDR = startaddr;
while(!(SPSR & (1<<SPIF)));
  for(i=0; i<length; i++)
  {
SPDR = data[i];
while(!(SPSR & (1<<SPIF)));
  }      
SPCR = 0;
SPSR = 0;
 
CS_SRAM_SET;
}

//******************************************************************************
//	???: 		 nlcd_ReadPixelBuffer(int startaddr, unsigned char* data, int length) 
// 	????????:    ?????? ? ?????????? ??????, ????? ?????? - ???????????, ?????? (Stquently, array)
//           	 nlcd_ReadPixelBuffer(startaddr,&data[0],length)
//	?????????:   
//  ??????:		 nlcd_ReadPixelBuffer(startaddr,&data[0],length);
//******************************************************************************
// ?????? ? SRAM 23X256
void nlcd_ReadPixelBuffer(int startaddr, unsigned char* data, int length)
{
int i;
CS_SRAM_RESET;
SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
SPSR = (1<<SPI2X);
SPDR = __READ_INST;
while(!(SPSR & (1<<SPIF)));
SPDR = (startaddr)>>8;
while(!(SPSR & (1<<SPIF)));
SPDR = startaddr;
while(!(SPSR & (1<<SPIF)));
  for(i=0; i<3; i++)
  {    
  SPDR = __NULL_INST;    
  while(!(SPSR & (1<<SPIF)));
  data[i] = SPDR;
  }
SPCR = 0;
SPSR = 0;    
CS_SRAM_SET;
}

//******************************************************************************
//	???: 		 nlcd_RenderPixelBuffer() 
// 	????????:    ?????? ???????????? ???????
//           	 nlcd_RenderPixelBuffer()
//	?????????:   
//  ??????:		 nlcd_RenderPixelBuffer();
//******************************************************************************

void nlcd_RenderPixelBuffer()
{
int i=0;
int k=0; 
unsigned char ppBufferSlice[3];
CS_SRAM_SET;
CS_LCD_RESET;  
 nlcd_SendCmd(LCD_PHILLIPS_PASET);   // ??????? ?????? ???????? RAM
   nlcd_SendDataByte(0);      // ?????  
   nlcd_SendDataByte(131);
   nlcd_SendCmd(LCD_PHILLIPS_CASET);   
   nlcd_SendDataByte(0);
   nlcd_SendDataByte(131);      //       
nlcd_SendCmd(LCD_PHILLIPS_RAMWR);       
for(i=0;i < 8712;i++)
{     
//First Read Pixel Buffer Slice (slice for 3 pixels)
CS_LCD_SET; 
CS_SRAM_RESET;
SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
SPSR = (1<<SPI2X);
SPDR = __READ_INST;
while(!(SPSR & (1<<SPIF)));
SPDR = (i*3)>>8;
while(!(SPSR & (1<<SPIF)));
SPDR = i*3;
while(!(SPSR & (1<<SPIF)));
  for(k=0; k<3; k++)
  {    
  SPDR = __NULL_INST;    
  while(!(SPSR & (1<<SPIF)));
  ppBufferSlice[k] = SPDR;
  }
SPCR = 0;
SPSR = 0;    
CS_SRAM_SET;
CS_LCD_RESET; 
//First byte
#asm
{
ldi r20,0b1001011
out 0x5,r20
SBI  0x5,5 
CBI  0x5,5 
}  
#endasm    
SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
SPSR = (1<<SPI2X);
SPDR = ppBufferSlice[0];
while(!(SPSR & (1<<SPIF)));
SPCR = 0;
SPSR = 0; 
//Second byte
#asm
{
ldi r20,0b1001011
out 0x5,r20
SBI  0x5,5 
CBI  0x5,5
}  
#endasm    
SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
SPSR = (1<<SPI2X);
SPDR = ppBufferSlice[1];
while(!(SPSR & (1<<SPIF)));
SPCR = 0;
SPSR = 0;
//Third byte
#asm
{
ldi r20,0b1001011
out 0x5,r20
SBI  0x5,5 
CBI  0x5,5
}  
#endasm    
SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
SPSR = (1<<SPI2X);
SPDR = ppBufferSlice[2];
while(!(SPSR & (1<<SPIF)));
SPCR = 0;
SPSR = 0;   
        }  
CS_LCD_SET;
}

void nlcd_Clear(int color)
{
int i,j=0;
unsigned char ppBufferSlice[3]; 
ppBufferSlice[0] = color >> 4;
ppBufferSlice[1] = ((color ) << 4) | ((color >> 8));
ppBufferSlice[2] = color;
        for(i=0;i < 8713;i++)
		{            
CS_SRAM_RESET;
SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
SPSR = (1<<SPI2X);
SPDR = __WRITE_INST;
while(!(SPSR & (1<<SPIF)));
SPDR = (i*3)>>8;
while(!(SPSR & (1<<SPIF)));
SPDR = i*3;
while(!(SPSR & (1<<SPIF)));
  for(j=0; j<3; j++)
  {
SPDR = ppBufferSlice[j];
while(!(SPSR & (1<<SPIF)));
  }      
SPCR = 0;
SPSR = 0;
 
CS_SRAM_SET;
        }             
}

//*******************************************************************************************************
//	???: 		 nlcd_Box(unsigned char x0, unsigned char y0, unsigned char x1, unsigned char y1, unsigned char fill, int color) 
// 	????????:    ?????? ????????????? ?? ?????????? x0, y0 ? ?????????? x1, y1 ? ???????? ??? ???, ?????? color
//           	 nlcd_Line(x0, y0, x1, y1, fill, color)
//	?????????:   x:     ??????? 0-131
//			     y:     ??????? 0-131
//               fill:  1-? ????????, 0-??? ???????
//               color: ???? (12-bit ??. #define) 
//  ??????:		 nlcd_Box(20,30,40,50,1,RED);  // ? ????????
//*******************************************************************************************************

void nlcd_Box(unsigned char x0, unsigned char y0, unsigned char x1, unsigned char y1, unsigned char fill, int color,int colorborder)
{ 
    unsigned char   xmin, xmax, ymin, ymax; 
    int   i = 0,j = 0;                   
    unsigned char a = (color >> 4);
    unsigned char b = ((color ) << 4) | ((color >> 8) );
    unsigned char c = color;       
    unsigned char ab = (colorborder >> 4);
    unsigned char bb = ((colorborder ) << 4) | ((colorborder >> 8) );
    unsigned char cb = colorborder;   
    unsigned char pBufferSlice[3];     
    unsigned char pBufferSliceBorder[3];
    pBufferSlice[0] = a;
    pBufferSlice[1] = b;
    pBufferSlice[2] = c; 
    pBufferSliceBorder[0] = ab;
    pBufferSliceBorder[1] = bb;
    pBufferSliceBorder[2] = cb;               
    if (fill == FILL)                          //  ******************************************************
    {                                          //  * ????????? - ????? ????????????? ? ???????? ??? ???  *              *
        xmin = (x0 <= x1) ? x0 : x1;          //  *                                                     *
 		xmax = (x0 > x1) ? x0 : x1;           //  *    ??????????? ???????? ? ??????? ??? X ? Y         *
		ymin = (y0 <= y1) ? y0 : y1;          //  ******************************************************* 
		ymax = (y0 > y1) ? y0 : y1; 
                                              //    *****************************************************
  // ????? ? RAM                                 
  for( i = (((ymin)*RESRAM_X + xmin)*3);i < (((ymax)*RESRAM_X + xmax + 1)*3); i+=3*(RES_X)/2)
  {        
     for(j = i; j < i + 3*(xmax-xmin+1);j+=3)                       
     {
        nlcd_WritePixelBuffer(j,&pBufferSlice[0],3);     
     }
  }
        
    } 
    if(fill == BORDERFILL)
    {
        xmin = (x0 <= x1) ? x0 : x1;    
 		xmax = (x0 > x1) ? x0 : x1;          
		ymin = (y0 <= y1) ? y0 : y1;        
		ymax = (y0 > y1) ? y0 : y1;  
        // ????? ? RAM    
    for(i = (((ymin)*RESRAM_X + xmin)*3);i < (((ymin)*RESRAM_X + xmin)*3) + 3*(xmax-xmin+1);i+=3)                       
     {
        nlcd_WritePixelBuffer(i,&pBufferSliceBorder[0],3);     
     }                             
  for( i = (((ymin)*RESRAM_X + xmin)*3) + 3*(RES_X)/2;i < (((ymax)*RESRAM_X + xmax + 1)*3)-3*(RES_X)/2; i+=3*(RES_X)/2)
  {        
     for(j = i; j < i + 3*(xmax-xmin+1);j+=3)                       
     {         
        if(j == i || j == i + 3*(xmax-xmin+1) - 3)
        {
        nlcd_WritePixelBuffer(j,&pBufferSliceBorder[0],3);
        }  
        else
        {
        nlcd_WritePixelBuffer(j,&pBufferSlice[0],3);   
        }  
     }
  }      
  for(i = (((ymin)*RESRAM_X + xmin)*3) + (ymax-ymin)*3*(RES_X)/2; i < (((ymin)*RESRAM_X + xmin)*3) + (ymax-ymin)*3*(RES_X)/2 + 3*(xmax-xmin+1); i+=3)                       
     {
        nlcd_WritePixelBuffer(i,&pBufferSliceBorder[0],3);     
     } 
    
    }                                     
}

//******************************************************************************
//	???: 		 nlcd_Circle(unsigned char x0, unsigned char y0, unsigned char radius, int color)	 
// 	????????:    ?????? ???? ?? ?????????? x0, y0, ? ???????? ? ?????? color
//           	 nlcd_Circle(x0, y0, radius, color)
//	?????????:   x:       ??????? 0-131
//			     y:       ??????? 0-131
//               radius:  ? ???????? 
//               color: ???? (12-bit ??. #define) 
//  ??????:		 nlcd_Circle(10,55,2,BLUE);
//******************************************************************************
/*void nlcd_Circle(unsigned char x0, unsigned char y0, unsigned char radius, int color) 
{ 
    int f = 1 - radius; 
	int ddF_x = 0; 
    int ddF_y = -2 * radius; 
    unsigned char x = 0; 
    unsigned char y = radius; 
 
    nlcd_Pixel(x0, y0 + radius, color); 
    nlcd_Pixel(x0, y0 - radius, color); 
    nlcd_Pixel(x0 + radius, y0, color); 
    nlcd_Pixel(x0 - radius, y0, color); 
  
    while (x < y) 
	{ 
        if (f >= 0) 
		{ 
 
            y--; 
            ddF_y += 2; 
            f += ddF_y; 
        } 
		
    x++; 
    ddF_x += 2; 
    f += ddF_x + 1;
	
    nlcd_Pixel(x0 + x, y0 + y, color); 
    nlcd_Pixel(x0 - x, y0 + y, color); 
    nlcd_Pixel(x0 + x, y0 - y, color); 
    nlcd_Pixel(x0 - x, y0 - y, color); 
    nlcd_Pixel(x0 + y, y0 + x, color); 
    nlcd_Pixel(x0 - y, y0 + x, color); 
    nlcd_Pixel(x0 + y, y0 - x, color); 
    nlcd_Pixel(x0 - y, y0 - x, color); 

    } 
}      */

//******************************************************************************
//	???: 		nlcd_Char(char c, unsigned char x, unsigned char y, int fColor, int bColor)  	 
// 	????????:    	 
//	?????????:        
//  ??????:		 
//******************************************************************************  
void nlcd_Char(char c, unsigned char y, unsigned char x, int fColor, int bColor) 
{ 
   int    i; 
   int    j; 
   unsigned char   nCols; 
   unsigned char  nRows; 
   unsigned char  nBytes; 
   unsigned char   PixelRow; 
   unsigned char   Mask; 
   unsigned int   Word0, Word1; 
   unsigned char *pFont,   *pChar;  
   unsigned char a;
    unsigned char b;
    unsigned char d;   
    unsigned char pBufferSlice[3];
  
   pFont = (unsigned char *)Nokia6610_fnt8x8;   
 
   nCols = pgm_read_byte(pFont); 
 
   nRows = pgm_read_byte(pFont + 1); 
 
   nBytes = pgm_read_byte(pFont + 2); 
   
   pChar = pFont + (nBytes * (c - 0x1F)); 
 
   for (i = 0; i<nRows; i++) // for 2x2 Box-Pixels !!!
   {  
      PixelRow = pgm_read_byte(pChar++); 
      Mask = 0x80; 
      for (j = 0; j < nCols/2; j++) 
	  { 
         if ((PixelRow & Mask) == 0) 
         Word0 = bColor; 
         else 
         Word0 = fColor; 
         Mask = Mask >> 1;  
         if ((PixelRow & Mask) == 0) 
         Word1 = bColor; 
         else 
         Word1 = fColor;  
    a = (Word0 >> 4);
    b = ((Word0 ) << 4) | ((Word1 >> 8) );
    d = Word1;  
    pBufferSlice[0] = a;
    pBufferSlice[1] = b;  
    pBufferSlice[2] = d;                                                
  // ????? ? RAM       
   nlcd_WritePixelBuffer(((y+i)*3*(RESRAM_X) + 3*(j + x/2)),&pBufferSlice[0],3);     
         Mask = Mask >> 1; 
      }   
   } 
} 
 
//******************************************************************************
//	???: 		nlcd_String(char *pString, unsigned char x, unsigned char  y,  int fColor, int bColor)  	 
// 	????????:    	 
//	?????????:  x:       ??????? 0-131
//			    y:       ??????? 0-131
//              fColor:  ???? (12-bit ??. #define)
//              bColor:  ???? (12-bit ??. #define)
//  ??????:		nlcd_String("Hello",40,12,WHITE,BLACK);
//****************************************************************************** 
void nlcd_String(char *pString, unsigned char x, unsigned char  y,  int fColor, int bColor) 
{ 
   while (*pString != 0x00) 
   { 
      nlcd_Char(*pString++, x, y, fColor, bColor); 
      y=y+8;
      if (x > 131) break; 
   } 
} 

