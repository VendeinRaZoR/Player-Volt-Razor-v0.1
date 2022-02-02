// ����������� LCD HD44780 � AVR ����� ������� ������
 
#include <lcd_com.h>
 
// ������� ��� ���������� ������� LCD
/* RS */
#define RS1_R registr(0x01, 1)
#define RS0_R registr(0x01, 0)
 
/* E */
#define E1_R registr(0x02, 1)
#define E0_R registr(0x02, 0)
 
/* D4 */
#define D41_R registr(0x04, 1)
#define D40_R registr(0x04, 0)
 
/* D5 */
#define D51_R registr(0x08, 1)
#define D50_R registr(0x08, 0)
 
/* D6 */
#define D61_R registr(0x10, 1)
#define D60_R registr(0x10, 0)
 
/* D7 */
#define D71_R registr(0x20, 1)
#define D70_R registr(0x20, 0)
 
// ������� ��������� ������� � ��������� �����
#define lcd_gotoxy(x, y) write_to_lcd(0x80|((x)+((y)*0x40)), 0)

void parallel_data(unsigned char data, unsigned char rs)
{
if(rs == 1)PORTB.4 = 1;
else PORTB.4 = 0;
static unsigned char tempdata = 0;
tempdata |= data;
PORTB.4  = 1;
if(tempdata & 0x80) PORTB.0  = 1;
else PORTB.0  = 0;
if(tempdata & 0x40) PORTB.1  = 1;
else PORTB.1  = 0;
if(tempdata & 0x20) PORTB.2  = 1;
else PORTB.2  = 0;
if(tempdata & 0x10) PORTB.3  = 1;
else PORTB.3  = 0;
PORTB.4  = 0;
delay_ms(2);
PORTB &= ~(PORTB);

if(rs == 1)PORTB.4 = 1;
else PORTB.4 = 0;
PORTB.4  = 1;
if(tempdata & 0x08) PORTB.0  = 1;
else PORTB.0  = 0;
if(tempdata & 0x04) PORTB.1  = 1;
else PORTB.1  = 0;
if(tempdata & 0x02) PORTB.2  = 1;
else PORTB.2  = 0;
if(tempdata & 0x01) PORTB.3  = 1;
else PORTB.3  = 0;
PORTB.4  = 0;
}
 
// ������� �������� ������ � �������
void registr(unsigned char data, unsigned char WriteOrErase)
{
static unsigned char tempdata = 0;
     
if(WriteOrErase == 1)
{
tempdata = (tempdata|data);
}
else
{
tempdata &= ~(data);
}
PORTB.1 = 0; // ST_CP 0 - ������� � ������� PORTB1
 
PORTB.2 = 0; // SH_CP 0 - ����� � ������� PORTB2

if(tempdata & 0x80)PORTB.0 = 1; 
else PORTB.0 = 0;
PORTB.2 = 1;  // SH_CP 1
PORTB.2 = 0;  // SH_CP 0
if(tempdata & 0x40)PORTB.0 = 1; 
else PORTB.0 = 0; 
PORTB.2 = 1; // SH_CP 1
PORTB.2 = 0; // SH_CP 0
if(tempdata & 0x20)PORTB.0 = 1; 
else PORTB.0 = 0; 
PORTB.2 = 1; // SH_CP 1
PORTB.2 = 0; // SH_CP 0
if(tempdata & 0x10)PORTB.0 = 1; 
else PORTB.0 = 0; 
PORTB.2 = 1; // SH_CP 1
PORTB.2 = 0; // SH_CP 0
if(tempdata & 0x08)PORTB.0 = 1; 
else PORTB.0 = 0; 
PORTB.2 = 1;// SH_CP 1
PORTB.2 = 0; // SH_CP 0
if(tempdata & 0x04)PORTB.0 = 1;  
else PORTB.0 = 0; 
PORTB.2 = 1;// SH_CP 1
PORTB.2 = 0; // SH_CP 0
if(tempdata & 0x02)PORTB.0 = 1;  
else PORTB.0 = 0; 
PORTB.2 = 1; // SH_CP 1
PORTB.2 = 0; // SH_CP 0
if(tempdata & 0x01)PORTB.0 = 1;  
else PORTB.0 = 0; 
PORTB.2 = 1; // SH_CP 1
PORTB.1 = 1; // ST_CP 1
}
 
// ������� �������� ������ ��� ������� � LCD � ������� ��������
void write_to_lcd_register(char p, unsigned char rs)
{
if(rs == 1) RS1_R; 
else RS0_R;
     
E1_R;
 
if(p&0x10) D41_R; else D40_R;
if(p&0x20) D51_R; else D50_R;
if(p&0x40) D61_R; else D60_R;
if(p&0x80) D71_R; else D70_R;
E0_R;  
delay_ms(2);
     
E1_R;
     
if(p&0x01) D41_R; else D40_R;
if(p&0x02) D51_R; else D50_R;
if(p&0x04) D61_R; else D60_R;
if(p&0x08) D71_R; else D70_R;
E0_R;
 
delay_ms(2);
}

// ������� �������� ������ ��� ������� � LCD ��� �������� (�� ����� � ���� � RESET ������)
void write_to_lcd(char p, unsigned char rs)
{
if(rs == 1) RS1_R; 
else RS0_R;
     
E1_R;
 
if(p&0x10) D41_R; else D40_R;
if(p&0x20) D51_R; else D50_R;
if(p&0x40) D61_R; else D60_R;
if(p&0x80) D71_R; else D70_R;
E0;  
delay_ms(2);
     
E1_R;
     
if(p&0x01) D41_R; else D40_R;
if(p&0x02) D51_R; else D50_R;
if(p&0x04) D61_R; else D60_R;
if(p&0x08) D71_R; else D70_R;
E0_R;
 
delay_ms(2);
}
 
// ������� ������������� LCD
void lcd_init(void)
{
write_to_lcd(0x02, 0); // ������ � ������� ����� �������
write_to_lcd(0x28, 0); // ���� 4 ���, LCD - 2 ������
write_to_lcd(0x0C, 0); // ��������� ����� �����������, ������ �� �����
write_to_lcd(0x01, 0); // ������� �������
}

// ������� ������������� LCD (������������ ������ + reset)
void lcd_init_parallel(void)
{
parallel_data(0x02, 0); // ������ � ������� ����� �������
parallel_data(0x28, 0); // ���� 4 ���, LCD - 2 ������
parallel_data(0x0C, 0); // ��������� ����� �����������, ������ �� �����
parallel_data(0x01, 0); // ������� �������
}
 
// ������� ������ ������
void lcd_puts(char *str)
{
unsigned char i = 0;
 
while(str[i])
write_to_lcd(str[i++], 1);
}
 
// ������� ������ ����������
void lcd_num_to_str(unsigned int value, unsigned char nDigit)
{
switch(nDigit)
{
case 4: write_to_lcd((value/1000)+'0', 1);
case 3: write_to_lcd(((value/100)%10)+'0', 1);
case 2: write_to_lcd(((value/10)%10)+'0', 1);
case 1: write_to_lcd((value%10)+'0', 1);
}
}