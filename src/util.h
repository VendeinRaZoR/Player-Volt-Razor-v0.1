#ifndef UTIL_H_INCLUDED
#define UTIL_H_INCLUDED
#include "common.h"

extern unsigned long small_atoh(char * s);
extern uint8_t small_isxdigit (uint8_t c);
extern char * small_uitoa(uint16_t value);
extern char * small_itoa(int16_t value);

#endif


