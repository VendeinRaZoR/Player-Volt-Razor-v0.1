#include "util.h"

uint8_t small_isxdigit(uint8_t c)
{

  return (
    ( c >= '0' && c <= '9')  ||
    ( c >= 'a' && c <= 'f')  ||
    ( c >= 'A' && c <= 'F')
    );
}

unsigned long small_atoh(char * s)
{
  unsigned long rv = 0;

  /* skip till a digit */
  while (*s)
  {
    if (small_isxdigit(*s))
      break;
    s++;
  }

  while (*s && small_isxdigit(*s))
  {
    rv <<= 4; //*= 0x0F;
    if (*s > 'F') *s -= ('a'-'A');
    rv|=( (*s<='9') ? (*s-'0') : (*s-0x37) );
    s++;
  }

  return rv;
}

#define PRINT_BUF_SIZE	(16)
static char print_buffer[PRINT_BUF_SIZE];

#define NUMBER_OF_DIGITS (12)

char * internal_uitoa(uint16_t value, uint8_t start)
{
	uint8_t index, i;

	index = NUMBER_OF_DIGITS;
	i = start;

	do
	{
		print_buffer[--index] = '0' + (value % 10);
		value /= 10;
	}while (value != 0);

	do
	{
		print_buffer[i++] = print_buffer[index++];
	}while (index < NUMBER_OF_DIGITS);

	print_buffer[i] = 0;
	return print_buffer;
}

char * small_uitoa(uint16_t value)
{
	return internal_uitoa(value, 0);
}

char * small_itoa(int16_t value)
{
	if (value < 0)
	{
		print_buffer[0] = '-';
		value = -value;
		return internal_uitoa(value, 1);
	}
	else
	{
		return internal_uitoa(value, 0);
	}
}


