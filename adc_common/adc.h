#include <delay.h>

float adc_data;

void ADC_init()
{
//������������� ���������� ���������, ������������� �����
ADMUX = 0x00;
         ADMUX |= (0 << REFS1)|(1 << REFS0);
         ADCSRA = 0xCE;      
}


float ADC_result(unsigned char adc_input)
{
         ADMUX=adc_input | (ADMUX & 0xF0);    
         ADMUX |= (0 << REFS1)|(1 << REFS0);
//�������� ��� ������������ �������� ����������
         delay_us(10);
//�������� �������������� (ADSC = 1)
         ADCSRA |= 0x40;
         while((ADCSRA & 0x10)==0); //����, ���� ��� �������� �������������� (ADIF = 0)
        ADCSRA|=0x10;//������������� ADIF
        return ADCW;//ADCW - �������� ADCH � ADCL ��� ��� �����
}

interrupt [ADC_INT] void adc_isr(void)
{
adc_data=ADCW;

ADCSRA|=0x40;
}

