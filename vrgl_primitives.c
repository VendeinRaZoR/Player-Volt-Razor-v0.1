#include "Nokia6610_lcd_lib.h"
#include "vrgl_primitives.h"
#include <delay.h>


void VRGL_CreateBox(unsigned char nX,unsigned char nY, unsigned char sX,unsigned char sY,int nColor,unsigned char bFill)
{
nlcd_Box(nX,nY,nX+sX,nY+sY,bFill,nColor,0);
}

void VRGL_CreateLine(unsigned char nX0,unsigned char nY0, unsigned char nX1,unsigned char nY1,int nColor)
{
//nlcd_Line(nX0,nY0,nX1,nY1,nColor);
}

