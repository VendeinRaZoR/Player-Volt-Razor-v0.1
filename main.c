#include <tiny13a.h>
#include <interrupt.h>
#include <delay.h>
#asm
.equ __lcd_port=0x18 ;PORTB
#endasm
#include <lcd.h> 

void main(void)
{
    DDRB = 0b00000101;  
    PORTB = 0b00000010;
      TCNT0 = 0x60;
  	TCCR0A |= (1<<COM0A0)|(1<<COM0A1)|(1<<WGM01)|(1<<WGM00);	 
	TCCR0B |= (0<<WGM02)|(0<<CS02)|(0<<CS01)|(1<<CS00);                                    
    GIMSK=(1<<INT0);
    MCUCR=(1<<ISC01) | (1<<ISC00);               
     OCR0A =  127;       
    sei();                          
    while(1)
    {     
    while(OCR0A<0xff)
      {
          OCR0A=OCR0A+0x01;
      }
    while(OCR0A>0x00)
      {
          OCR0A=OCR0A-0x01;
      }
    }     
}

interrupt [EXT_INT0] void ext_int0_isr(void)
{
 OCR0A += 0x01;  

}
