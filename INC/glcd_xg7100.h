#ifndef _GLCD_XG7100_INCLUDED_
#define _GLCD_XG7100_INCLUDED_

/******************************************************************************
    © Copyright DELCOMp 2003-2012, All Rights Reserved
    DELCOMp bvba, Technologielaan 3, B-3001 Leuven, Belgium
    http://www.xgraph.be ©

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    1. The binary code, with or without modification, can only be installed
    on hardware manufactured and distributed by © DELCOMp or its approved
    distributors and subcontractors.

    2. Redistributions of source code must retain the above copyright notice,
    including the full address and URL, this list of conditions and the following
    disclaimer.

    3. Redistributions in binary form must reproduce the above copyright notice,
    including the full address and URL, this list of conditions and the following
    disclaimer in the documentation and/or other materials provided with the
    distribution.

    4. The name of © DELCOMp may not be used to endorse or promote products
    derived from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY DELCOMP "AS IS" AND ANY EXPRESS OR IMPLIED
    WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
    MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE EXPRESSLY AND
    SPECIFICALLY DISCLAIMED. IN NO EVENT SHALL DELCOMP BE LIABLE FOR ANY DIRECT,
    INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES
    LOSS OF USE, DATA, OR PROFITS OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
    THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
******************************************************************************/

/* START LIBRARY DESCRIPTION **************************************************
    glcd_xg7100.lib
    Library functions for X-Graph XG7100 4.3 Type B, 5.6" and 7.0" LCD
    
    © Copyright DELCOMp 2003-2012, All Rights Reserved
    DELCOMp bvba, Technologielaan 3, B-3001 Leuven, Belgium
    http://www.xgraph.be ©

    CHANGE HISTORY:
    Date: 1.0, 19 Mar 2012

    I/O PORTS:
    If no I/O port allocation are pre-defined the XG7100 defaults are used:
    PortJ = EBI address/databus
    PortH = VPORT0
    PH0 = WE = 21
    PH1 = OE = 20 = not used (reserved for readback functionality)
    PH2 = ALE1 = 19 = ALE
    PH3 = ALE2 = 17 = not used
    PH4 = A16 = 16 = RESET
    PH5 = A17 = 15 = READY (input)
    PH6 = A18 = 14 = CS1
    PH7 = A19 = 12 = CS0
    
    HARDWARE DESCRIPTION:
    - RESET = high -> reset all internal logic, stop LCD timing outputs
    - EBI required: 2-port LPC mode with 256 byte pages (ALE2 not used)
    - CS3 -> CS0 = data CS
    - CS2 -> CS1 = address CS
    - CS1:
      - Address: not used
      - Data: latched in internal address latch
    - CS0:
      - access to 8 16-bit registers
      - a register is selected with the CS1 address latch
      - 16-bit data is written with one CS0 pulse
        - ALE pulse: writes low-byte (ALE is not used for adresses)
        - WE pulse: writes high-byte
      - the adresss latch auto-increments when the high-byte is received
      - the address latch auto-locks at address 7 (highest)  
    - Registers:
      0: not used
      1: not used
      2: not used
      3: Y counter = nr of vertical lines to write (1 is minimum, 0 is not allowed)
      4: X end = last horizontal dot (can be equal to X start)
      5: Y = start line
      6: X = start column
      7: color 
      (coordinates go from 0 to MAX-1)
    - How to use the registers?
      A. Write one pixel
      - CS1: 5
      - CS0: Y coordinate
      - CS0: X coortinate
      - CS0: color
      B. Fill a window with same color pixels
      - CS1: 3
      - CS0: all above mentioned registers
      The hardware will fill the block with 'color'.
      A block can be a rectangle, but also a horizontal or vertical line.
      C. Write a window
      - CS1: 11
      - CS0: all above mentioned registers
      Continue to write color data until all pixels are written.
    - READY line
      The ready line must be checked before writing CS1 and starting a new command.
      The line must be HIGH. If it is low, just wait until it becomes HIGH.
      The waittime is very short (usecs).

END DESCRIPTION *************************************************************/

#include <xgraph.h>
#include <glcd_types.h>

#ifdef _GLCD_VPORT_
    // READY
    #define _GLCD_READY_IN_ _GLCD_XG_READY_IN_
    #define _GLCD_READY_DIR_IN_ {_GLCD_XG_READY_DIR_ = 0;}

    // RESET
    #define _GLCD_RESET_LOW_ {_GLCD_XG_RESET_OUT_ = 0;}
    #define _GLCD_RESET_HIGH_ {_GLCD_XG_RESET_OUT_ = 1;}
    #define _GLCD_RESET_DIR_OUT_ {_GLCD_XG_RESET_DIR_ = 1;}
#else
    // READY
    #define _GLCD_READY_IN_ GETBIT(_GLCD_XG_READY_IN, _GLCD_XG_READFY_BIT_)
    #define _GLCD_ALE_DIR_IN_ {CLRBIT(_GLCD_XG_READY_DIR_,_GLCD_XG_READY_BIT_);}

    // RESET
    #define _GLCD_RESET_LOW_ {CLRBIT(_GLCD_XG_RESET_OUT_,_GLCD_XG_RESET_BIT_);}
    #define _GLCD_RESET_HIGH_ {SETBIT(_GLCD_XG_RESET_OUT_,_GLCD_XG_RESET_BIT_);}
    #define _GLCD_RESET_DIR_OUT_ {SETBIT(_GLCD_XG_RESET_DIR_,_GLCD_XG_RESET_BIT_);}
#endif

// Color definitions for 64k color mode
// Bits 0..4 -> Blue 0..4
// Bits 5..10 -> Green 0..5
// Bits 11..15 -> Red 0..4
#define GLCD_CL_BLACK 0x0000 
#define GLCD_CL_WHITE 0xFFFF 
#define GLCD_CL_GRAY 0x7BEF
#define GLCD_CL_LIGHT_GRAY 0xC618      
#define GLCD_CL_GREEN 0x07E0      
#define GLCD_CL_LIME 0x87E0 
#define GLCD_CL_BLUE 0x001F 
#define GLCD_CL_RED 0xF800 
#define GLCD_CL_AQUA 0x5D1C 
#define GLCD_CL_YELLOW 0xFFE0 
#define GLCD_CL_MAGENTA 0xF81F
#define GLCD_CL_CYAN 0x07FF
#define GLCD_CL_DARK_CYAN 0x03EF      
#define GLCD_CL_ORANGE 0xFCA0 
#define GLCD_CL_PINK 0xF97F
#define GLCD_CL_BROWN 0x8200
#define GLCD_CL_VIOLET 0x9199
#define GLCD_CL_SILVER 0xA510
#define GLCD_CL_GOLD 0xA508
#define GLCD_CL_NAVY 0x000F      
#define GLCD_CL_MAROON 0x7800      
#define GLCD_CL_PURPLE 0x780F      
#define GLCD_CL_OLIVE 0x7BE0      

// Structure that contains controller specific graphic LCD initialization data
typedef struct 
        {
        flash unsigned char *font; // default font after initialization
        // pointer to the function used for reading a byte from external memory
        unsigned char (*readxmem) (GLCDMEMADDR_t addr); 
        // pointer to the function used for writing a byte to external memory
        void (*writexmem) (GLCDMEMADDR_t addr, unsigned char data);
        unsigned char reverse_x:1; // reverse display horizontally
        unsigned char reverse_y:1; // reverse display vertically
        } GLCDINIT_t;

// Initialization values for reverse_x
#define XG_REVX_NORM 0  // No horizontal reverse
#define XG_REVX_REV 1   // Horizontal reverse

// Initialization values for reverse_y
#define XG_REVY_NORM 0  // No vertical reverse
#define XG_REVY_REV 1   // Vertical reverse
        
// Initializes the graphic controller and clears the LCD.
bool glcd_init(GLCDINIT_t *init_data);
// Turns LCD on/off.
void glcd_display(bool on);
// Clears the LCD by setting it's color to the background color.
void glcd_clear(void);
// Sets the color of the pixel at coordinates x, y.
void glcd_putpixel(GLCDX_t x, GLCDY_t y, GLCDCOL_t color);
// Fills a block with color
void glcd_putblock(GLCDX_t x, GLCDY_t y, GLCDX_t w, GLCDY_t h, GLCDCOL_t color);
// Prepares a block for data
void glcd_prepblock(GLCDX_t x, GLCDY_t y, GLCDX_t w, GLCDY_t h);
// Sets the color of the pixel in a block.
void glcd_putdata(GLCDCOL_t color);
// Skips a byte in a block
void glcd_skipdata(void);
// Returns the color of the pixel at coordinates x, y.
GLCDCOL_t glcd_getpixel(GLCDX_t x, GLCDY_t y);

// Writes/reads a block of bytes as a bitmap image
// at/from specified coordinates.
void glcd_block(GLCDX_t left, GLCDY_t top, GLCDX_t width, GLCDY_t height,
     GLCDMEM_t memt, GLCDMEMADDR_t addr, GLCDBLOCKMODE_t mode);

#pragma library glcd_xg7100.lib

#endif




