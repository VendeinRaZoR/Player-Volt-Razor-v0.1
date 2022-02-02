/*
 * IncFile1.h
 *
 * Created: 05.02.2016 14:33:46
 *  Author: ilya
 */ 

#ifndef INCFILE1_H_
#define INCFILE1_H_

uint16_t IMM(void);
uint16_t Battery(uint8_t value);
void FAST_charge(void);
void TRICKLE_charge(void);
//ISR(TIMER0_COMPA_vect);
//ISR(ADC_vect);
void Stop_PWM(void);
void Stable_ADC(void);

typedef struct 
{
	int t_count;
	char sec;                    // global seconds
	char min;                    // global minutes
	char hour;                   // global hour
} time_struct;


#define SETBIT(x,y) (x |= (y))   // Set bit y in byte x
#define CLRBIT(x,y) (x &= (~(y)))// Clear bit y in byte x
#define CHKBIT(x,y) (x & (y))    // Check bit y in byte x


#define FAST    0x01   			// bit 0 : FAST charge status bit
#define TRICKLE 0x02   			// bit 1 : TRICKLE charge status bit
#define ERROR   0x04   			// bit 2 : ERROR before or while charging
#define CONST_V 0x08   			// bit 3 : charged with constant VOLTAGE
#define CONST_C 0x10   			// bit 4 : charged with constant CURRENT
#define DELAY   0x20   			// bit 5 : FAST charge DELAY for LiIon after CURRENT threshold detection
#define READY   0x40   			// bit 6 : Trickle charge is terminated and the battery is fully charged
#define FREE2   0x80   			// bit 7 : Not Currently used

// PORT Connections
//************************************************************************************
#define IBAT2   0x42    			//CURRENT measurement on ADC channel #2
#define VBAT2   0x43    			//VOLTAGE measurement on ADC channel #3
#define IMAX	0x41    			//POTENCIOMETR measurement on ADC channel #1

// ADC measurement definitions
//********************************************************************************************

#define VOLTAGE                   3
#define VOLTAGE_WITH_PWM_TURNOFF  33
#define CURRENT                   1
// #define control		= r21 // Charge control register
// #define tick_cnt		= r18 // Tick Counter
// #define last_t_min	= r14 // Last minute tick counter
// #define t_sec		= r19 // Time_seconds
// #define t_min		= r20 // Time_minutes
// #define temp		= r16 // Temporary Storage Register 1

#endif //INCFILE1_H_