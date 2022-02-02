/*
 * GccApplication2.c
 *
 * Created: 05.02.2016 13:55:36
 * Author : ilya
 */ 

#include <avr/io.h>
#include "main.h"
#include "main2.h"
#include <avr/interrupt.h>

#define F_CPU 8000000UL

uint8_t CHARGE_STATUS;

time_struct time;  

void timer0_init(void){
	TCCR0A |= 1<<WGM01;			//
	TCCR0B |= 1<<CS02 | 1<<CS00;// делитель 1024
	OCR0A = 252;				// стс от 0 до 252 ~ FC
	TIMSK |= 1<<OCIE0A;
}

void timer1_init(void){			// PWM 100kHz
	
	OCR1C = 79;
	TCCR1 |= 1<<PWM1A | 1<<COM1A0 | 1<<CS10;	// com1a0 выбрать в соотв со схемой, хот¤ тут все ок
//	OCR1A = 38;		// в норм проге надо убрать
	DDRB |= 0x02;	// com1a0 указывает на пин 1, поэтому настраиваем его на выход
}
	

void setup(void)
{
	cli();
	
	timer1_init();
	timer0_init();
	
	ADCSRA  = 0x96;
	
	time.sec = 0x00;
	time.min = 0x00;
	time.hour = 0x00;
	time.t_count = 0x00;
	
	sei(); 
}

int main(void)
{
	setup();
	
    while (1) 
    {
		SETBIT(CHARGE_STATUS,FAST);
		
		while (!(CHKBIT(CHARGE_STATUS,ERROR)))
        {
            if ((CHKBIT(CHARGE_STATUS,FAST)) && (!(CHKBIT(CHARGE_STATUS,ERROR))))
            {
                FAST_charge();
            }                   
            if ((CHKBIT(CHARGE_STATUS,TRICKLE)) && (!(CHKBIT(CHARGE_STATUS,ERROR))))
            {
                CHARGE_STATUS = 0x00;
				SETBIT(CHARGE_STATUS,CONST_C);
				SETBIT(CHARGE_STATUS,TRICKLE);
                //TRICKLE_charge();
                FAST_charge();
            }
        }
		if (CHKBIT(CHARGE_STATUS,ERROR))
        {
            for(;;);
        }   
		
    }
}

void FAST_charge(void)
{
    volatile uint16_t  temp = 0;
    unsigned char fast_finish_hour = 0;
    unsigned char fast_finish_min = 0;
    unsigned char delay_hour = 0;  
    unsigned char delay_min = 0;
    unsigned char last_min = 0;
	
	
	time.sec = 0x00;
  	time.min = 0x00;
  	time.hour = 0x00;
  	time.t_count = 0x1F;


    SETBIT(CHARGE_STATUS,CONST_C);
    CLRBIT(CHARGE_STATUS,DELAY); 
     

                OCR1A = 0x00; 

                // calculate FAST charge finish time
                fast_finish_min = (time.min + MAX_TIME_FAST);
                fast_finish_hour = time.hour;
                while (fast_finish_min > 60)
                {
                    fast_finish_min = fast_finish_min - 60;
                    fast_finish_hour++;
                }
                while ((CHKBIT(CHARGE_STATUS,FAST)) && (!(CHKBIT(CHARGE_STATUS,ERROR))))
                {
                    // Charge with constant current algorithme
                    if (CHKBIT(CHARGE_STATUS,CONST_C))
                    {
						 int  temp1 = IMM();
                        // set I_FAST1 (with "soft start")
                         do
                         {
                             temp	= Battery(CURRENT);
                             if ((temp < temp1)&&(OCR1A < 0xFF))
                                 OCR1A++;
 								temp1 = IMM();
                             if ((temp > temp1)&&(OCR1A > 0x00))
                                 OCR1A--;
 								temp1 = IMM();
                         }while (temp != temp1);        // I_FAST1 is set now
                 
                        /*if VOLTAGE within range change from constant 
                        CURRENT charge mode to constant VOLTAGE charge mode*/
                        temp = Battery(VOLTAGE_WITH_PWM_TURNOFF);            
                        if ((temp >= (VOLT_TRICKLE - VOLT_TOLERANCE)) && (temp <= (VOLT_TRICKLE + VOLT_TOLERANCE)))
                        {
                            CLRBIT(CHARGE_STATUS,CONST_C);
                            SETBIT(CHARGE_STATUS,CONST_V);
                        }            
                    }    

                    // Charge with constant voltage algorithm
                    else if (CHKBIT(CHARGE_STATUS,CONST_V))
                    {       
                        // set VOLT_FAST (with "soft start")
                        do                                              
                        {
                            temp = Battery(VOLTAGE);
                            if ((temp < VOLT_FAST)&&(OCR1A < 0xFF))
                                OCR1A++;
                            else if ((temp > VOLT_FAST)&&(OCR1A > 0x00))
                                OCR1A--;
                        }while ((temp <= (VOLT_FAST -(VOLT_TOLERANCE/4)))||(temp >= (VOLT_FAST+(VOLT_TOLERANCE/4))));                       
                        // VOLT_TRICKLE is set now
                    }

                    // Check for error and charge termination conditions
                    
                    //If above max charge time, flag error    
                    if ((time.hour == fast_finish_hour) && (time.min == fast_finish_min))                               
                    {
                    	/*Stop the PWM, flag max time charge termination and
                    	ERROR. Save the termination value and the max limit
                    	value for debug information*/
						Stop_PWM();
                        SETBIT(CHARGE_STATUS,ERROR);
                    }

                    /*Every min check if MIN_I_FAST1 is reached, if so 
                    calculate the delay time. 
                    Check every 60 seconds if delay time after reached 
                    MIN_I_FAST1 is over, if so change to trickle charge*/
                    if (time.min != last_min)   
                    {
                        last_min = time.min;
                        if (((CHKBIT(CHARGE_STATUS,CONST_V)) && (!(CHKBIT(CHARGE_STATUS,DELAY))) && (Battery(CURRENT) <= MIN_I_FAST)))
                        {
                            // calculate DELAY finish time
                            delay_min = (time.min + FAST_TIME_DELAY);
                            delay_hour = time.hour;
                            while (delay_min > 60)
                            {
                                delay_min = delay_min - 60;
                                delay_hour++;
                            }            
                            SETBIT(CHARGE_STATUS,DELAY);  
                        }

                        // Check if delay time after min_I_FAST1 is done, if so change to trickle charge
                        if ((time.hour == delay_hour)&&(time.min == delay_min)&&(CHKBIT(CHARGE_STATUS,DELAY)))
                        {
                            /*Stop PWM and change from constant VOLTAGE charge 
                            mode back to constant CURRENT charge mode. Change 
                            charge mode from "FAST" to "TRICKLE" Save the 
                            termination value and the max limit value for debug
                            information*/
						    Stop_PWM();
                            CLRBIT(CHARGE_STATUS,CONST_V);
                            SETBIT(CHARGE_STATUS,CONST_C);
                            CLRBIT(CHARGE_STATUS,FAST);               
                            SETBIT(CHARGE_STATUS,TRICKLE);            
                        }                         
                    }                        
                }
            
		 
        
		if(!(CHKBIT(CHARGE_STATUS,ERROR)))
		{
    		/*Flag max charge voltage charge termination and ERROR. Save 
    		the termination value and the max limit value for debug 
    		information*/
			SETBIT(CHARGE_STATUS,ERROR);
		}		 


	else if(!(CHKBIT(CHARGE_STATUS,ERROR)))
	{
	    //Flag ERROR and save the measured value causing the error for debug	
	    SETBIT(CHARGE_STATUS,ERROR);        
	}
}

void TRICKLE_charge(void)
{
    unsigned int temp = 0;
    unsigned char trickle_finish_min = 0;
    unsigned char trickle_finish_hour = 0;
      
	time.sec = 0x00;
  	time.min = 0x00;
  	time.hour = 0x00;
  	time.t_count = 0x1F;


    OCR1A = 0x00;   
     
     
    while ((CHKBIT(CHARGE_STATUS,TRICKLE)) && (!(CHKBIT(CHARGE_STATUS,ERROR))))  
    {    
             // if charge voltage lower than absolute max charge voltage
            if (Battery(VOLTAGE) <= (VOLT_TRICKLE + VOLT_TOLERANCE))
            {
                //Charge with constant current algorithme
                if (CHKBIT(CHARGE_STATUS,CONST_C))
                {
                    // set I_TRICKLE (with "soft start")
                    do
                    {
                        temp = Battery(CURRENT);
                        if ((temp < I_TRICKLE)&&(OCR1A < 0xFF))
                        {
                            OCR1A++;
                        }
                        if ((temp > I_TRICKLE)&&(OCR1A > 0x00))
                        {
                            OCR1A--;
                        }
                    }while (temp != I_TRICKLE); // I_TRICKLE is set now	
                    
                    /*if VOLTAGE within range change from constant 
                    CURRENT charge mode to constant VOLTAGE charge mode*/
                    temp = Battery(VOLTAGE_WITH_PWM_TURNOFF);            
                    if ((temp >= (VOLT_TRICKLE - VOLT_TOLERANCE)) && (temp <= (VOLT_TRICKLE + VOLT_TOLERANCE)))
                    {
                        CLRBIT(CHARGE_STATUS,CONST_C);
                        SETBIT(CHARGE_STATUS,CONST_V);
                    }            
                }
                
                //Charge with constant current algorithme                 
                if (CHKBIT(CHARGE_STATUS,CONST_V))
                {  
                    // set VOLT_TRICKLE (with "soft start")    
                    do                      // set VOLT_TRICKLE
                    {
                        temp = Battery(VOLTAGE);
                        if ((temp < VOLT_TRICKLE)&&(OCR1A < 0xFF))
                        {
                            OCR1A++;
                        }
                        if ((temp > VOLT_TRICKLE)&&(OCR1A > 0x00))
                        {
                            OCR1A--;
                        }
                    }while ((temp <= (VOLT_TRICKLE-(VOLT_TOLERANCE/4)))||(temp >= (VOLT_TRICKLE+(VOLT_TOLERANCE/4))));                       
                    // VOLT_TRICKLE is set now          }
                }


                // Check for error and charge termination conditions
                if ((time.hour == trickle_finish_hour) && (time.min == trickle_finish_min))                               
                {
                    /*Stop the PWM, flag max time charge termination and
                    ERROR. Save the termination value and the max limit
                    value for debug information*/
					Stop_PWM();
                    SETBIT(CHARGE_STATUS,ERROR);
                }        
			}

            else if(!(CHKBIT(CHARGE_STATUS,ERROR)))
	   		{
        		/*Flag max charge voltage charge termination and ERROR. Save 
    	    	the termination value and the max limit value for debug 
    		    information*/
	   			SETBIT(CHARGE_STATUS,ERROR);
    		}		 
	   			 
    	else if(!(CHKBIT(CHARGE_STATUS,ERROR)))
	    {   
	        //Flag ERROR and save the measured value causing the error for debug	
            SETBIT(CHARGE_STATUS,ERROR);        
    	}
    }
}

uint16_t Battery(uint8_t value)
{
  char i;
  uint32_t av = 0;
  uint16_t kADC = 0;

  switch (value)
  {
    case VOLTAGE_WITH_PWM_TURNOFF: 
        /*Stop PWM and select ADMUX ch. VOLTAGE_WITH_PWM_TURNOFF for battery
        voltage measurement. Wait until ADC value is stable*/   
        Stop_PWM();
        ADMUX = VBAT2 ;
        Stable_ADC();
		kADC = 1182;
        break;   
    case VOLTAGE: 
        /*Stop PWM and select ADMUX ch. VOLTAGE for charge voltage 
        measurement.*/   
        ADMUX = VBAT2;
		kADC = 1182;
        break;   
    case CURRENT: 
        /*Stop PWM and select ADMUX ch. CURRENT for charge current 
        measurement.*/   
        ADMUX = IBAT2;
		kADC = 195;
        break;
   }  

    //Calculate a average out of the next 8 A/D conversions
    for(i=8;i;--i)
    {
        ADCSRA |= 0x40;                      // start new A/D conversion
        while (!(ADCSRA & (1<<ADIF)))        // wait until ADC is ready
            ;      
        av += ADC;
    }
    av = av*kADC/800;

    TCCR1 = 0x51;							 // turn on PWM
    CLRBIT(ADCSRA,ADIF);                     // clear ADC interrupt flag

    return (uint16_t)av;  
}

ISR (TIMER0_COMPA_vect)
 {
 	if (0x00 == --time.t_count)
 	{
 		if ( 60 == ++time.sec )
 		{
 			if ( 60 == ++time.min )
 			{
 				if ( 24 == ++time.hour )
 				{
 					time.hour = 0x00;
 				}
 				time.min = 0x00;
 			}
 			time.sec = 0x00;
 		}
 		time.t_count = 0x1F;
 	}
 }

void Stop_PWM(void)                         // Stops the PWM in off pos.
{
	if (OCR1A != 0)							// <- tyt mojet byt' kosyak
	{
		if (OCR1A == 1)
		{
			while(TCNT1 > 2);                     // Wait for PWM == 1
			while(TCNT1 < 2);                     // Wait for PWM == 0
		}
		else
		{
			while(TCNT1 > OCR1A);                  // Wait for PWM == 1
			while(OCR1A > TCNT1);                  // Wait for PWM == 0
		}
		TCCR1 = 0x41;                          // Turn PWM off
	}
}

void Stable_ADC(void)                     // loop until you have a stable value
{
	int V[4];
	uint8_t i;
	int Vmax, Vmin;
	
	//Loop until the ADC value is stable. (Vmax <= (Vmin+1))
	for (Vmax=10,Vmin= 0;Vmax > (Vmin+10);)
	{
		V[3] = V[2];
		V[2] = V[1];
		V[1] = V[0];
		ADCSRA |= 0x40;                      // Start a new A/D conversion
		while (!(ADCSRA & (1<<ADIF)));        // wait until ADC is ready
		
		V[0] = ADC;
		Vmin = V[0];                          // Vmin is the lower VOLTAGE
		Vmax = V[0];                          // Vmax is the higher VOLTAGE
		/*Save the max and min voltage*/
		for (i=0;i<=3;i++)
		{
			if (V[i] > Vmax)
			Vmax=V[i];
			if (V[i] < Vmin)
			Vmin=V[i];
		}
	}
}

 uint16_t IMM(void)				// Imax measure
 {
 	uint32_t I_FAST1 = 0;
 	ADMUX   = IMAX;
 	ADCSRA |= 0x40;				// start new A/D conversion
	while (!(ADCSRA & (1<<ADIF)));
 	I_FAST1 = (ADC*195)/100;	// max charge current = 2000mA; Vref = 3.67V
 	if (I_FAST1 < 100){
 		I_FAST1 = 100;
 	}
 	CLRBIT(ADCSRA,ADIF);		// clear ADC interrupt flag	
 	return (uint16_t)I_FAST1;
 }