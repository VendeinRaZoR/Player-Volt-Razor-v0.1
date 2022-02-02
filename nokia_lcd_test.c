
//***************************************************************************
//  File........: Nokia6610_1.c
//  Author(s)...: Goncharenko Valery and Chiper
//  URL(s)......: http://digitalchip.ru
//  Device(s)...: ATMega8
//  Compiler....: Winavr-20100110
//  Description.: Demo LCD Nokia6610
//  Data........: 08.06.12
//  Version.....: 1.0 
//***************************************************************************
#include "menu.c"
#include <sleep.h>

unsigned int vcc = 0;//variable to hold the value of Vcc 



void ADC_Init(){
ADCSRA=(1<<ADEN) | (0<<ADSC) | (0<<ADATE) | (0<<ADIF) | (0<<ADIE) | (1<<ADPS2) | (1<<ADPS1) | (0<<ADPS0);
ADCSRB=(0<<ADTS2) | (0<<ADTS1) | (0<<ADTS0);
ADMUX = (0 << REFS1)|(0 << REFS0) |(1 << MUX0)|(1 << MUX1)|(1 << MUX2)|(0 << MUX3); 
}


unsigned int ReadADC(unsigned char ref_channel){
  //ADMUX = ref_channel; //выбираем канал и источник опорного напряжения. Из соображений качества кода лучше бы разделить их на две переменные, но из соображений оптимизации и простоты оставим как есть
 int i;
 for(i = 0;i<8;i++)
 {
 ADCSRA |= (1<<ADSC); //запускаем преобразование
  while(! (ADCSRA & (1<<ADIF)) ){} //ждем пока преобразование не закончится      
  }
  ADCSRA |= (1<<ADIF); //сбрасываем флаг прерывания
  return ADCW;
}

void main(void) //При использовании буффера (RAM памяти) и 12-битной графики двигать графические объекты и рисовать отдельгый пиксели можно только в паре
{               // т.е. 1 пиксель = 2 пикселям идущим подряд
int i = 0;
unsigned char bCardCheck = 0;
unsigned char str1[32];
unsigned int adc_data;
unsigned char adcstr[32];
unsigned char pBuffer[10]; 
unsigned char pBufferstr[10];
unsigned char adstr[32];
unsigned int adc_data2;
uint8_t timebuf[8];
uint8_t hour;
uint8_t min;
uint8_t sec;
unsigned char timestr[32];
CS_LCD_SET;
CS_SRAM_SET;
SRAM_HOLD_SET;
DDRC = 0xFF;
PORTC = 0xFF;
DDRD = 0xFF;
DDRD.2 = 0;
PORTD.0 = 0;
nlcd_InitSPI(); 
nlcd_InitPixelBuffer(1); 
nlcd_Init();
delay_ms(20);
TWI_MasterInit(100);
   /*подготавливаем сообщение*/
  timebuf[0] = (DS1307_ADR<<1)|0;  //адресный пакет
  timebuf[1] = 0;                  //адрес регистра
  timebuf[2] = (5<<4)|5;           //значение секунд 
  timebuf[3] = (5<<4)|9;           //значение минут 
  timebuf[4] = 0;                  //значение часов  
  TWI_SendData(timebuf, 5);
//смонтировать диск 
//df_Memory_Erase();  
/*pBuffer[0] = 10; 
pBuffer[1] = 2;
pBuffer[2] = 3;
pBuffer[3] = 4;
pBuffer[4] = 5;  
//df_Memory_Write_Buffer(0xA74,0x0E,&pBuffer[0],4,1); 
pBuffer[0] = 0; 
pBuffer[1] = 0;
pBuffer[2] = 0;
pBuffer[3] = 0;
pBuffer[4] = 0;
df_Memory_Read_Buffer(0xA74,0x0E,&pBuffer[0],4,1); 
sprintf(pBufferstr,"%i,%i,%i,%i",pBuffer[0],pBuffer[1],pBuffer[2],pBuffer[3]);  */ 
ADC_Init();
DDRD.2 = 0;
EICRA=(0<<ISC11) | (0<<ISC10) | (1<<ISC01) | (0<<ISC00);
EIMSK=(0<<INT1) | (1<<INT0);
EIFR=(0<<INTF1) | (1<<INTF0);
PCICR=(0<<PCIE2) | (0<<PCIE1) | (0<<PCIE0);
KEYS_INIT;
CS_KEYS_SET;
#asm("sei"); 
while(1)
    {   
nlcd_Clear(WHITE);
//nlcd_String(&pBufferstr[0],90,52,MAGENTA,WHITE); 
CS_LCD_SET;
CS_SRAM_SET;       
browser_init();
PORTD.0 = 0;                 
///ADC Vref 1.1V
adc_data = ReadADC(14);
vcc = 110 * 1024 / adc_data/3.3;     //// Для точности откалибровать !!! 1.2 - 1.3В бандгап
sprintf(&adcstr[0],"B:%i", vcc); 
strcat(&adcstr[0],"%");
nlcd_String(&adcstr[0],122,2,GREEN,WHITE);  
       /*устанавливаем указатель DS1307 
       на нулевой адрес*/
      timebuf[0] = (DS1307_ADR<<1)|0; //адресный пакет
      timebuf[1] = 0;                 //адрес регистра   
      TWI_SendData(timebuf, 2); 
      /*считываем время с DS1307*/
      timebuf[0] = (DS1307_ADR<<1)|1;
      TWI_SendData(timebuf, 5);   
      /*переписываем данные буфера 
      драйвера в свой буфер*/
      TWI_GetData(timebuf, 5);  
      sec = timebuf[1];
      min  = timebuf[2];
      hour = timebuf[3];   
sprintf(&timestr[0],"%i%i:%i%i:%i%i",(hour>>4),(hour&0xf),(min>>4),(min&0xf),(sec>>4),(sec&0xf));
nlcd_String(&timestr[0],122,52,MAGENTA,WHITE);  
nlcd_RenderPixelBuffer();  
   }  
}
