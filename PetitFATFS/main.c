//***************************************************************************
//
//  Author(s)...: Pashgan    http://ChipEnable.Ru   
//
//  Target(s)...: Mega16
//
//  Compiler....: CodeVision AVR
//
//  Description.: ��������������� wav ����� � SD �����
//
//  Data........: 16.03.14
//
//***************************************************************************

#include "compilers_4.h"
#include "diskio.h"
#include "pff.h"

/* ������ ���������������� */

#define LED_PORT   PORTD
#define LED_DIR    DDRD
#define LED_PIN    4

#define PWM_PORT   PORTB
#define PWM_DIR    DDRB
#define PWM_PIN    3

/* ����� */

#define BUF_SIZE    256UL
#define HALF_BUF   ((BUF_SIZE)/2)

uint8_t buf[BUF_SIZE];

/*���������� ��� ������� � SD*/

FATFS fs;
WORD s1;
FRESULT res;


static volatile uint8_t i;
static uint8_t st;
static char f[] = "1.wav";

void main( void )
{
  st = 0;
  i = 0;

  /*��������� ��� ������*/
  PWM_DIR |= (1<<PWM_PIN);
  PWM_PORT &= ~(1<<PWM_PIN);
  
  /*��������� ���������*/
  LED_DIR |= (1<<LED_PIN);
  LED_PORT &= ~(1<<LED_PIN);
  
  /*��������� ����, ��������� ���� � ��������� ���� �����*/
  res = pf_mount(&fs);
  if (res == FR_OK){
     res = pf_open(f);
     if (res == FR_OK){
	    res = pf_read(buf, BUF_SIZE, &s1);  
     }
  }
  
  /*���� ���� ����������, �� ��������� ������*/
  if (res == FR_OK){
     TCCR0 = 0;
     TCNT0 = 0;
     TIMSK |= (1<<TOIE0);
     TIFR = (1<<TOV0);
     TCCR0 = (1<<COM01)|(0<<COM00)|(1<<WGM01)|(1<<WGM00)|(0<<CS02)|(0<<CS01)|(1<<CS00);
  
     LED_PORT |= (1<<LED_PIN);
  }
  else{
  /*� ��������� ������ �������������
    � ������ ����������� */
     while(1){
	    LED_PORT ^= (1<<LED_PIN);
	    delay_ms(300);
	 }
   
  }
    
	
  __enable_interrupt();
  while(1){
	
    /*���������� ������ �������*/
     switch (st){
     case 0:

	   /*���� ������ ��������� �� ������� ��������
	   ������, �� ��������� ������ ��������*/ 
       if (i >= HALF_BUF) {
          pf_read(buf, HALF_BUF, &s1);
          st = 1;
       }
     break;
     
     case 1:
	   /*���� ������ ��������� �� ������ ��������
	   ������, �� ��������� ������� ��������*/ 
        if (i < HALF_BUF) {
          pf_read(&buf[HALF_BUF], HALF_BUF, &s1);
          st = 0;
        }
        break;
      
     default:
       break;
     }
     
  }
}

/*���, ������� ��������� ��� ���������� ������*/
ISR(TIM0_OVF)
{
  uint8_t tmp = i;
  
  OCR0 = buf[tmp];
  tmp++;
  
  i = tmp;
}