/**
*  @file main.c
*
*  Test project for NOKIA6100 display (with EPSON S1D15G10 controller)
*
*  Created on: 24.07.2008
*  Modified: 39.01.2011
*  Copyright (c) Anton Gusev aka AHTOXA (http://AHTOXA.NET)
**/

#include "src/common.h"
//#include "src/timer0.c"
#include "src/nokia6100.c"
#include "src/util.h"
#include "src/fonts.h"
#include <mega8.h>

void main (void)
{
    int color;
    Rotation rot = rot0deg;

    // Initialize timer first (for delays)
    //timer0_init();
    sei();

    // Initialize display
    nokia6100_init();

    for (;;)
    {
        // Change display orientation
        nokia6100_set_rotation(rot);
        nokia6100_cls();
        if (rot != rot270deg) rot++;
        else rot = rot0deg;

        // Draw framed box on top
        nokia6100_set_bg_color(LightRed);
        nokia6100_box(0, 0, nokia6100_get_max_x(), 23, White);
        nokia6100_set_fg_color(LightBlue);
        nokia6100_rectangle(0, 0, nokia6100_get_max_x(), 23);

      /*  // Draw text in this box
        nokia6100_goto(2, 7);
        nokia6100_set_fg_color(Black);
        nokia6100_select_font(verdana16);
      //  nokia6100_puts_p("Nokia6100 display");

        // Draw text in bottom
        nokia6100_set_fg_color(White);
        nokia6100_select_font(comic_18);
        nokia6100_goto(20, 98);
      //  nokia6100_puts_p("??????!!!");

        // Draw box in middle of screen
        nokia6100_select_font(verdana16);
        nokia6100_set_fg_color(DarkBlue);
        nokia6100_rectangle(0, 24, nokia6100_get_max_x(), 96);

        // Fill the box with different colors and display
        // color number in circle.
        for (color = 0; color <= 255; color++)
        {
            nokia6100_box(1, 25, nokia6100_get_max_x()-1, 95, color);

            nokia6100_set_fg_color(color ^ 255);        //
            nokia6100_circle(64, 58, 28);
            nokia6100_goto(52,52);
            nokia6100_puts(small_itoa(color));
            delay_ms(250);
            delay_ms(250);       
        }    */ 
    }         
    }

