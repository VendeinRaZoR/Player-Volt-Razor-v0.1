/*
 * tiny13_lcd.c
 *
 * Created: 17.02.2016 21:43:57
 * Author: Vendein_RaZoR
 */

#include <io.h>
 //#include <tiny13a.h>   
 #include <mega8.h>
 #include <string.h>      
 #include <stdlib.h>
 
 #include <lcd_common/lcd_com.h>                 
 
 #include <adc_common/adc.h>

char * strAdc = 0; 

void main(void)
{
PORTB=0x00;
DDRB=0xFF;
ADC_init();
lcd_init_parallel();
//lcd_puts_parallel("MAGADAN!!");
lcd_gotoxy_parallel(0, 0); // ??????? ?????? ?? LCD
lcd_puts_parallel("KOKOKO!!");
lcd_gotoxy_parallel(0, 1); // ??????? ?????? ?? LCD

while (1)
    {    
    itoa(ADC_result(0),strAdc);
lcd_puts_parallel(strAdc);
lcd_puts_parallel("  "); 
delay_ms(50);
    }
}
