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
  #include <stdio.h>
 
 #include <lcd_common/lcd_com.h>                 
 
 #include <adc_common/adc.h>       
 

char lcd_buffer[31];
float result=0;
int i=0;

void main(void)
{
PORTB=0x00;
DDRB=0xFF;
ADC_init();
lcd_init_parallel();
//lcd_puts_parallel("MAGADAN!!");
lcd_gotoxy_parallel(0, 1); // Выводим строки на LCD
lcd_puts_parallel("KOKOKO!!");
//lcd_gotoxy_parallel(0, 1); // Выводим строки на LCD
//#asm("sei")

while (1)
    {     
result = 0;    
lcd_gotoxy_parallel(0, 0);
for(i=0;i<100;i++)
{
result += (((5*ADC_result(0))/1024));
delay_us(10);
}
result /= 100;
sprintf(lcd_buffer,"%.2f V",result);
lcd_puts_parallel(lcd_buffer);
delay_ms(2000);
    }
}
