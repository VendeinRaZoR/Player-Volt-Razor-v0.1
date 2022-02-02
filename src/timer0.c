#include <io.h>
#include <interrupt.h>
#include "timer0.h"

#define	TIMER0_FREQ			(1000)
#define	TIMER0_PRESCALER	(64)
#define	TIMER0_RELOAD_LO	((0xFFFF-(F_CPU/TIMER0_PRESCALER/TIMER0_FREQ)+1) & 0xFF)
#define	TIMER0_RELOAD_HI	((0xFFFF-(F_CPU/TIMER0_PRESCALER/TIMER0_FREQ)+1) >> 8)
#if (TIMER0_RELOAD_HI!=0xFF)
#error TIMER0_RELOAD_HI!=0xFF!
#endif

//#define LED_PIN		D, 7, L

volatile uint8_t ms_ticks_byte = 0;

void timer0_init(void)
{
	TCCR0 = _BV(CS01) | _BV(CS00);	//	prescaler = 8.
	TCNT0 = TIMER0_RELOAD_LO;
	TIMSK |= _BV(TOIE0);
	#ifdef LED_PIN
	direct(LED_PIN, O);
	#endif
}

void delay_ms(uint8_t ms)
{
	ms_ticks_byte = ms;
	while (ms_ticks_byte);
}


SIGNAL(SIG_OVERFLOW0)
{
	#ifdef LED_PIN
	static int led_counter = 1000;
	static char led_is_on = TRUE;
	#endif
	TCNT0 = TIMER0_RELOAD_LO;
	if (ms_ticks_byte) ms_ticks_byte--;
	#ifdef LED_PIN
	if (!--led_counter)
	{
		led_counter = 1000;
		if (led_is_on)
		{
			led_is_on = FALSE;
			off(LED_PIN);
		}
		else
		{
			led_is_on = TRUE;
			on(LED_PIN);
		}
	}
	#endif
}


