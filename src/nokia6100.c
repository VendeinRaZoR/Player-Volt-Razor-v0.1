/**
*  @file nokia6100.c
*
*  Graphical Primitives implementation for NOKIA-6100 display
*  (with EPSON S1D15G10 controller)
*
*  Created on: 24.07.2008
*  Modified: 39.01.2011
*  Copyright (c) Anton Gusev aka AHTOXA (http://AHTOXA.NET)
**/
#include "nokia6100.h"
#include "timer0.h"		// for delay_ms()

#define USE_SOFT_SPI	(1)

#ifdef USE_SOFT_SPI
	#define  NOKIA_RESET	C, 0, H
	#define  NOKIA_DOUT		C, 1, H
	#define  NOKIA_SCK		C, 2, H
	#define  NOKIA_CS		C, 3, L
#else
	#define  NOKIA_RESET	C, 0, H
	#define  NOKIA_DOUT		B, 5, H
	#define  NOKIA_SCK		B, 7, H
	#define  NOKIA_CS		B, 4, L
#endif

// Note: if pin SS is not used as NOKIA_CS, it should be configured as output
// or tied high to allow hardware SPI master work properly.

/**
 *  LCD info
 */
#define MAX_X				(129)
#define MAX_Y				(129)

/**
 * EPSON S1D15G10 commands
 */
#define DISON    0xAF
#define DISOFF   0xAE
#define DISNOR   0xA6
#define DISINV   0xA7
#define COMSCN   0xBB
#define DISCTL   0xCA
#define SLPIN    0x95
#define SLPOUT   0x94
#define PASET    0x75
#define CASET    0x15
#define DATCTL   0xBC
#define INV_Y    0x01
#define INV_X    0x02
#define WR_DIR   0x04
#define RGBSET8  0xCE
#define RAMWR    0x5C
#define RAMRD    0x5D
#define PTLIN    0xA8
#define PTLOUT   0xA9
#define RMWIN    0xE0
#define RMWOUT   0xEE
#define ASCSET   0xAA
#define SCSTART  0xAB
#define OSCON    0xD1
#define OSC_OFF  0xD2
#define PWRCTR   0x20
#define VOLCTR   0x81
#define VOLUP    0xD6
#define VOLDOWN  0xD7
#define TMPGRD   0x82
#define EPCTIN   0xCD
#define EPCOUT   0xCC
#define EPMWR    0xFC
#define EPMRD    0xFD
#define EPSRRD1  0x7C
#define EPSRRD2  0x7D
#define NOP      0x25

// selected font
static uint8_t * gfont;

// selected foreground and background colors
static color_t fcolor = White;
static color_t bcolor = Black;

// current coordinates
static uint8_t coord_x;
static uint8_t coord_y;

static Rotation rotation = rot0deg;

#ifdef USE_SOFT_SPI
static void nokia6100_spi(uint8_t data)
{
	off(NOKIA_DOUT);
	if (data & 0x80)	on(NOKIA_DOUT);
	off(NOKIA_SCK);
	on(NOKIA_SCK);

	off(NOKIA_DOUT);
	if (data & 0x40)	on(NOKIA_DOUT);
	off(NOKIA_SCK);
	on(NOKIA_SCK);

	off(NOKIA_DOUT);
	if (data & 0x20)	on(NOKIA_DOUT);
	off(NOKIA_SCK);
	on(NOKIA_SCK);

	off(NOKIA_DOUT);
	if (data & 0x10)	on(NOKIA_DOUT);
	off(NOKIA_SCK);
	on(NOKIA_SCK);

	off(NOKIA_DOUT);
	if (data & 0x08)	on(NOKIA_DOUT);
	off(NOKIA_SCK);
	on(NOKIA_SCK);

	off(NOKIA_DOUT);
	if (data & 0x04)	on(NOKIA_DOUT);
	off(NOKIA_SCK);
	on(NOKIA_SCK);

	off(NOKIA_DOUT);
	if (data & 0x02)	on(NOKIA_DOUT);
	off(NOKIA_SCK);
	on(NOKIA_SCK);

	off(NOKIA_DOUT);
	if (data & 0x01)	on(NOKIA_DOUT);
	off(NOKIA_SCK);
	on(NOKIA_SCK);
}

#else // USE_SOFT_SPI

static inline __attribute__((__always_inline__)) void nokia6100_spi(uint8_t data)
{
	SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(1<<CPOL)|(1<<CPHA)|(0<<SPR1)|(0<<SPR0);	// Enable Hardware SPI
    SPDR = data;
    while(!(SPSR & (1<<SPIF)));
    SPCR = 0;
}

#endif // USE_SOFT_SPI

/**
 * Send command byte to display.
 */
static void nokia6100_cmd(uint8_t cmd)
{
	off(NOKIA_DOUT);
	on(NOKIA_CS);
	off(NOKIA_SCK);
	on(NOKIA_SCK);

	nokia6100_spi(cmd);

	off(NOKIA_CS);
}

/**
 * Send data byte to display.
 */
static void nokia6100_data(uint8_t data)
{
	on(NOKIA_DOUT);
	on(NOKIA_CS);
	off(NOKIA_SCK);
	on(NOKIA_SCK);

	nokia6100_spi(data);

	off(NOKIA_CS);
}

void nokia6100_set_rotation(Rotation rot)
{
	rotation = rot;
}

Rotation nokia6100_get_rotation(void)
{
	return rotation;
}

uint8_t nokia6100_get_max_x(void)
{
	if (rotation == rot90deg || rotation == rot270deg)
		return MAX_Y;
	return MAX_X;
}

uint8_t nokia6100_get_max_y(void)
{
	if (rotation == rot90deg || rotation == rot270deg)
		return MAX_X;
	return MAX_Y;
}

static void set_window(uint8_t x1, uint8_t y1, uint8_t x2, uint8_t y2)
{
	uint8_t new_x1, new_x2, new_y1, new_y2;

	switch (rotation)
	{
	/**
	 * 90 degree: Xnew = MAX_X - Y, Ynew = X
	 */
	case rot90deg :
		new_x1 = MAX_Y - y1;
		new_y1 = x1;
		new_x2 = MAX_Y - y2;
		new_y2 = x2;
		break;

	/**
	 * 180 degree: Xnew = MAX_X - X, Ynew = MAX_Y - Y
	 */
	case rot180deg :
		new_x1 = MAX_X - x1;
		new_y1 = MAX_Y - y1;
		new_x2 = MAX_X - x2;
		new_y2 = MAX_Y - y2;
		break;

	/**
	 * 270 degree: Xnew = Y, Ynew = MAX_X - X
	 */
	case rot270deg :
		new_x1 = y1;
		new_y1 = MAX_X - x1;
		new_x2 = y2;
		new_y2 = MAX_X - x2;
		break;

	case rot0deg :
	default :
		new_x1 = x1;
		new_y1 = y1;
		new_x2 = x2;
		new_y2 = y2;
		break;
	}

	// ensure that x1<=x2 and y1<=y2
	if (new_x1 > new_x2)
	{
		x1 = new_x1;
		new_x1 = new_x2;
		new_x2  = x1;
	}

	if (new_y1 > new_y2)
	{
		x1 = new_y1;
		new_y1 = new_y2;
		new_y2  = x1;
	}

	// set page start/end (x range)
	nokia6100_cmd(PASET);
	nokia6100_data(new_x1);
	nokia6100_data(new_x2);

	// set column start/end (y range)
	nokia6100_cmd(CASET);
	nokia6100_data(new_y1);
	nokia6100_data(new_y2);
}

/**
 * Move display writing position to point with coordinates (x ,y)
 */
void nokia6100_goto(uint8_t x, uint8_t y)
{
	coord_x = x;
	coord_y = y;
	set_window(x, y, x, y);
}

/**
 * Display point at (x, y) with given color
 */
void nokia6100_point_at(uint8_t x, uint8_t y)
{
	nokia6100_goto(x, y);
	nokia6100_cmd(RAMWR);		// write to display
	nokia6100_data(fcolor);
}

void nokia6100_point()
{
	nokia6100_point_at(coord_x, coord_y);
}


/**
 * Display filled rectangle with given coordinates and color
 */
void nokia6100_box(uint8_t x1, uint8_t y1, uint8_t x2, uint8_t y2, uint8_t color)
{
	uint8_t i, j;
	set_window(x1, y1, x2, y2);
	nokia6100_cmd(RAMWR);		// write to display
	for (i = x1; i <= x2; i++)
		for (j = y1; j <= y2; j++)
			nokia6100_data(color);
	nokia6100_cmd(NOP);
}

void nokia6100_select_font(void * font)
{
	gfont = font;
}

void nokia6100_set_bg_color(color_t color)
{
	bcolor = color;
}

void nokia6100_set_fg_color(color_t color)
{
	fcolor = color;
}

uint8_t nokia6100_putch(char ch)
{
    uint8_t height=0;
    uint8_t first=0;
    uint8_t last=0;
	uint32_t offset = 0;
	uint8_t width = 0;
	uint8_t mask;
	uint8_t b;
	uint8_t * ptr = gfont;
	ptr += 3;								// skip 3 bytes
	height = pgm_read_byte(ptr++);	// read font height
	ptr++;									// skip one byte
	first = pgm_read_byte(ptr++);	// read first char code
	last = pgm_read_byte(ptr++);	// read last char code

	// check bounds...
	if (ch < first && ch > last) return 0;

	// calculate sum of widths of preceding chars...
	while (first++ < ch)
		offset += pgm_read_byte(ptr++);

	// make offset in bits
	offset *= height;

	// read the width of ch...
	width = pgm_read_byte(ptr);

	ptr += last - ch + 1;
	ptr += offset / 8;

	first = width;

	if (bcolor != None)
		nokia6100_box(coord_x, coord_y, coord_x + width, coord_y + height, bcolor);

//	nokia6100_goto(coord_x, coord_y);

	b = pgm_read_byte(ptr++);
	mask = 1<<(offset % 8);

	while (width--)
	{
		last = height;
		while (last--)
		{
			if (!mask)
			{
				b = pgm_read_byte(ptr++);
				mask = 0x01;
			}
			if (b & mask)
				nokia6100_point();
			coord_y++;
			mask <<= 1;
		}
		coord_y -= height;
		coord_x++;
	}
	coord_x++;

	return first + 1;
}

void nokia6100_puts(const char *s)
{
	while (*s)
		nokia6100_putch(*s++);
}

void nokia6100_puts_progmem(char *s)
{
	uint8_t c;
	if (!s) return;
	while((c = pgm_read_byte(s++)))
		nokia6100_putch(c);
}

void nokia6100_circle(uint8_t xcenter, uint8_t ycenter, uint8_t radius)
{
	int16_t tswitch, y, x = 0;
	uint8_t d;

	d = ycenter - xcenter;
	y = radius;
	tswitch = 3 - 2 * radius;
	while (x <= y)
	{
		nokia6100_point_at(xcenter + x, ycenter + y);     nokia6100_point_at(xcenter + x, ycenter - y);
		nokia6100_point_at(xcenter - x, ycenter + y);     nokia6100_point_at(xcenter - x, ycenter - y);
		nokia6100_point_at(ycenter + y - d, ycenter + x); nokia6100_point_at(ycenter + y - d, ycenter - x);
		nokia6100_point_at(ycenter - y - d, ycenter + x); nokia6100_point_at(ycenter - y - d, ycenter - x);

		if (tswitch < 0)
			tswitch += (4 * x + 6);
		else
		{
			tswitch += (4 * (x - y) + 10);
			y--;
		}
		x++;
	}
}


void nokia6100_rectangle(uint8_t x1, uint8_t y1, uint8_t x2, uint8_t y2)
{
	nokia6100_box(x1, y1, x2, y1, fcolor);
	nokia6100_box(x1, y1, x1, y2, fcolor);
	nokia6100_box(x1, y2, x2, y2, fcolor);
	nokia6100_box(x2, y1, x2, y2, fcolor);
}

void nokia6100_line(uint8_t x1, uint8_t y1, uint8_t x2, uint8_t y2)
{
	uint8_t dy;
	uint8_t dx;

	if (y1 > y2)	dy = y1 - y2;
	else			dy = y2 - y1;

	if (x1 > x2)	dx = x1 - x2;
	else			dx = x2 - x1;

	dy <<= 1;				// dy is now 2*dy
	dx <<= 1;				// dx is now 2*dx

	nokia6100_point_at(x1, y1);

	if (dx > dy)
	{
		int16_t fraction = dy - (dx >> 1);	// same as 2*dy - dx
		while (x1 != x2)
		{
			if (fraction >= 0)
			{
				if (y1 < y2)	y1++;
				else			y1--;
				fraction -= dx;			// same as fraction -= 2*dx
			}
			if (x1 < x2)	x1++;
			else			x1--;
			fraction += dy; 			// same as fraction -= 2*dy
			nokia6100_point_at(x1, y1);
		}
	}
	else
	{
		int16_t fraction = dx - (dy >> 1);
		while (y1 != y2)
		{
			if (fraction >= 0)
			{
				if (x1 < x2)	x1++;
				else			x1--;
				fraction -= dy;
			}
			if (y1 < y2)	y1++;
			else			y1--;
			fraction += dx;
			nokia6100_point_at(x1, y1);
		}
	}
}

void nokia6100_cls(void)
{
	nokia6100_box(0, 0, nokia6100_get_max_x(), nokia6100_get_max_y(), 0); // clear display memory
}

void nokia6100_init(void)
{
	off(NOKIA_CS);
	direct(NOKIA_CS, O);

	off(NOKIA_SCK);
	direct(NOKIA_SCK, O);

	off(NOKIA_DOUT);
	direct(NOKIA_DOUT, O);

	on(NOKIA_RESET);
	direct(NOKIA_RESET, O);

#ifndef USE_SOFT_SPI
	SPSR = (1 << SPI2X);
#endif

	delay_ms(10);

	// Reset Lcd
	off(NOKIA_RESET);
	delay_ms(5);
	on(NOKIA_RESET);
	delay_ms(50);

	nokia6100_cmd(DISCTL);		// display control
	nokia6100_data(0x0C);		// 1100 - CL dividing ratio [don't divide] switching period 8H (default)
	nokia6100_data(0x20);		// 32 = (128/4)-1 (round up) number of display lines for scanning
	nokia6100_data(0x0C);		// 12 = 1100 - number of lines to be inversely highlighted
	nokia6100_data(0x00);

	nokia6100_cmd(COMSCN);		// common scanning direction
	nokia6100_data(0x01);		// Scan 1-80
    // 0 0 0 =   1 -> 80   81 -> 160
    // 0 0 1 =   1 -> 80   81 <- 160
    // 0 1 0 =   1 <- 80   81 -> 160
    // 0 1 1 =   1 <- 80   81 <- 160

	nokia6100_cmd(OSCON);		// internal oscillator ON
	nokia6100_cmd(SLPOUT);		// sleep out
	nokia6100_cmd(VOLCTR);		// electronic volume, this is contrast/brightness
	nokia6100_data(0x23);		// volume (contrast) setting - fine tuning
	nokia6100_data(0x03);		// internal resistor ratio - coarse adjustment

	nokia6100_cmd(PWRCTR);		// power ctrl
	nokia6100_data(0x0f);		//everything on, no external reference resistors
	delay_ms(100);

	nokia6100_cmd(DISINV);		// display mode
//	nokia6100_cmd(DISNOR);

	nokia6100_cmd(DATCTL);		// set low resolution
	nokia6100_data(0x01);		// Param 1  Inv Page address, Normal column, Scan Column dir.
	nokia6100_data(0x00);		// param 2  Set for R-G-B order
	nokia6100_data(0x01);		// param 3  8-bit or 16 bit ?


	nokia6100_cmd(RGBSET8);   // setup color lookup table
    // color table
    //RED
    nokia6100_data(0);
    nokia6100_data(2);
    nokia6100_data(4);
    nokia6100_data(6);
    nokia6100_data(8);
    nokia6100_data(10);
    nokia6100_data(12);
    nokia6100_data(15);
    // GREEN
    nokia6100_data(0);
    nokia6100_data(2);
    nokia6100_data(4);
    nokia6100_data(6);
    nokia6100_data(8);
    nokia6100_data(10);
    nokia6100_data(12);
    nokia6100_data(15);
    //BLUE
    nokia6100_data(0);
    nokia6100_data(4);
    nokia6100_data(9);
    nokia6100_data(15);

	nokia6100_cmd(NOP);

	nokia6100_cls();

	delay_ms(100);

	nokia6100_cmd(NOP);
	nokia6100_cmd(DISON);   // display on
}

