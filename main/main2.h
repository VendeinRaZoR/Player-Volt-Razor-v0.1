/*
 * main2.h
 *
 * Created: 05.02.2016 18:01:23
 *  Author: ilya
 */ 

#include "main.h"

#ifndef MAIN2_H_
#define MAIN2_H_

// Battery Characteristics: General charge TERMINATION
//***************************************************************************       
// Absolute Maximum Charge VOLTAGE = CELLS * cell VOLTAGE * scale factor
#define  MAX_VOLT_ABS    (unsigned int)((CELLS * LiIon_CELL_VOLT)/ VOLTAGE_STEP)  
     
// Battery Characteristics:FAST charge TERMINATION     
//***************************************************************************
// Minimum CURRENT threshold = 50mA per cell
#define  MIN_I_FAST  (unsigned int)((CELLS * 50)/ CURRENT_STEP)
// time DELAY after "MIN_I_FAST" is reached = 30min
#define  FAST_TIME_DELAY     0x1E

// Battery Characteristics:TRICKLE charge TERMINATION     
//***************************************************************************
// Maximum TRICKLE Charge Time = 1.5C = 90min    					
#define  MAX_TIME_TRICKLE  0x5A
  
// Battery Characteristics: FAST charge ERROR
//***************************************************************************
// Minimum FAST Charge TEMPERATURE 10C
#define  MIN_TEMP_FAST  0x0296          	
// Maximum FAST Charge Time = 1.5C = 90 min at 1C CURRENT  
#define  MAX_TIME_FAST  0x5A               
        
// Battery Characteristics: General Charge conditions
//***************************************************************************
// VOLTAGE tolerance = CELLS * 50mV * scale factor
#define  VOLT_TOLERANCE (unsigned int)((CELLS * 50)/ VOLTAGE_STEP)            
// FAST Charge CURRENT = 1C (in mA, with 1.966mA per bit)
#define  I_FAST      (unsigned int)(CAPACITY / CURRENT_STEP)               
// TRICKLE Charge CURRENT = 0.025C (in mA, with 1.966mA per bit)
#define  I_TRICKLE   (unsigned int)((CAPACITY * 0.025)/ CURRENT_STEP)
//FAST Charge voltage is defined in bc_def.h
#define  VOLT_FAST LiIon_CELL_VOLT
/* TRICKLE Charge voltage is defined in bc_def.h 
CURRENT = 0.025C (in mA, with 1.966mA per bit)*/
#define  VOLT_TRICKLE  LiIon_CELL_VOLT


#define	LiIon				  // Litium-Ion	battery	

// Number	of CELLS 
//***************************************************************************

#define	CELLS			1       	// Number of cells in the battery pack


// ADC step
//***************************************************************************
// ADC voltage step	according to resistors at ADC voltage measurement input
#define	VOLTAGE_STEP	11.8	 
// ADC current step	according to resistors on ADC current measurment input   
#define	CURRENT_STEP	1.95		
					 
//CAPACITY of	battery	pack
//***************************************************************************

#ifdef LiIon
#define	CAPACITY		2000	    // Battery pack	capasity in	mAh	 (LiIon)
#endif


// Cell	VOLTAGE	for	LiIon	Battery
//***************************************************************************

#define	LiIon_CELL_VOLT		4100	// Change	cell voltage between 4100	mV 



#endif  //MAIN2_H_ 