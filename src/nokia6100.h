/**
*  @file nokia6100.h
*
*  Graphical Primitives for NOKIA-6100 display
*  (with EPSON S1D15G10 controller)
*
*  Created on: 24.07.2008
*  Modified: 39.01.2011
*  Copyright (c) Anton Gusev aka AHTOXA (http://AHTOXA.NET)
**/
#ifndef NOKIA6100_H_INCLUDED
#define NOKIA6100_H_INCLUDED
#include "common.h"

/**
 * Color type definition
 */
typedef uint8_t color_t;

/**
 * Rotation enum
 */
typedef enum
{
	rot0deg,
	rot90deg,
	rot180deg,
	rot270deg
}Rotation;

/**
 * Some color definition
 */
#define DarkBlue	0x02
#define LightBlue	0x03
#define DarkGreen	0x14
#define LightGreen	0x1C
#define DarkRed		0x60
#define LightRed	0xE0
#define White		0xFF
#define Black		0x00
#define Yellow		0xDD
#define Purple		0x62
#define None		0x80


/**
 * Driver initialization
 */
extern void nokia6100_init(void);

/**
 * Graphical Primitives
 */
extern void nokia6100_cls(void);
extern void nokia6100_goto(uint8_t x, uint8_t y);
extern void nokia6100_point_at(uint8_t x, uint8_t y);
extern void nokia6100_point();
extern void nokia6100_box(uint8_t x1, uint8_t y1, uint8_t x2, uint8_t y2, uint8_t color);

/**
 * Color functions
 */
extern void nokia6100_set_bg_color(color_t color);
extern void nokia6100_set_fg_color(color_t color);

/**
 * Screen rotation
 */
extern void nokia6100_set_rotation(Rotation rot);
extern Rotation nokia6100_get_rotation(void);
extern uint8_t nokia6100_get_max_x(void);
extern uint8_t nokia6100_get_max_y(void);

/**
 * Text stuff
 */
extern void nokia6100_select_font(void * font);
extern uint8_t nokia6100_putch(char ch);
extern void nokia6100_puts(const char *s);
extern void nokia6100_puts_progmem(char *s);

#define nokia6100_puts_p(s)	nokia6100_puts_progmem(PSTR(s))

/**
 * Extra stuff
 */
extern void nokia6100_circle(uint8_t xcenter, uint8_t ycenter, uint8_t radius);
extern void nokia6100_rectangle(uint8_t x1, uint8_t y1, uint8_t x2, uint8_t y2);
extern void nokia6100_line(uint8_t x1, uint8_t y1, uint8_t x2, uint8_t y2);

#endif  // NOKIA6100_H_INCLUDED

