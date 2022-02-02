//***************************************************************************
//  File........: Nokia6610_lcd_lib.h
//  Author(s)...: Goncharenko Valery and Chiper
//  URL(s)......: http://digitalchip.ru
//  Device(s)...: ATMega8
//  Compiler....: Winavr-20100110
//  Description.: Драйвер LCD Nokia6610 ( ONLY PCF8833 )
//  Data........: 08.06.12
//  Version.....: 1.0 
//***************************************************************************

//#include <avr/io.h>   // Библиотека ввода-вывода

//***************************************************************************
// Настройка библиотеки
//***************************************************************************
// Notice: Все управляющие контакты LCD-контроллера должны быть подключены к
// одному и тому же порту на микроконтроллере
//***************************************************************************
// Порт к которому подключен LCD контроллер Nokia6610

#define RES_X 132
#define RES_Y 132

#define RESRAM_X 66 // Display resolution with 2-byte pixels & RAM
#define RESRAM_Y 66

#define PORT_LCD PORTB
#define PORT_LCD_RESERVE PORTC
#define PIN_LCD  PINB
#define DDR_LCD  DDRB

// Номера выводов порта в SPI режиме, к которым подключены выводы LCD-контроллера, буффера LCD и FLASH
 
#define SCLK_LCD_PIN    5
#define SDA_LCD_PIN     3
#define CS_LCD_PIN      2
#define RST_LCD_PIN     1
#define CS_SRAM_PIN     0
#define HOLD_SRAM_PIN   1

/*#define SCLK_LCD_PIN    3
#define SDA_LCD_PIN     2
#define CS_LCD_PIN      1
#define RST_LCD_PIN     0
*/

#define LCD_PHILLIPS_NOP        0x00   // nop        
#define LCD_PHILLIPS_SWRESET    0x01   // software reset           
#define LCD_PHILLIPS_BSTROFF    0x02   // booster voltage OFF       
#define LCD_PHILLIPS_BSTRON     0x03   // booster voltage ON 
#define LCD_PHILLIPS_RDDIDIF    0x04   // read display identification
#define LCD_PHILLIPS_RDDST      0x09   // read display status         
#define LCD_PHILLIPS_SLEEPIN    0x10   // sleep in           
#define LCD_PHILLIPS_SLEEPOUT   0x11   // sleep out
#define LCD_PHILLIPS_PTLON      0x12   // partial display mode         
#define LCD_PHILLIPS_NORON      0x13   // display normal mode        
#define LCD_PHILLIPS_INVOFF     0x20   // inversion OFF           
#define LCD_PHILLIPS_INVON      0x21   // inversion ON 
#define LCD_PHILLIPS_DALO       0x22   // all pixel OFF
#define LCD_PHILLIPS_DAL        0x23   // all pixel ON   
#define LCD_PHILLIPS_SETCON     0x25   // write contrast              1-byte  
#define LCD_PHILLIPS_DISPOFF    0x28   // display OFF
#define LCD_PHILLIPS_DISPON     0x29   // display ON
#define LCD_PHILLIPS_CASET      0x2A   // column address set          2-byte
#define LCD_PHILLIPS_PASET      0x2B   // page address set            2-byte
#define LCD_PHILLIPS_RAMWR      0x2C   // memory write
#define LCD_PHILLIPS_RGBSET     0x2D   // colour set                  20-byte
#define LCD_PHILLIPS_PTLAR      0x30   // partial area 
#define LCD_PHILLIPS_VSCRDEF    0x33   // vertical scrolling definition 
#define LCD_PHILLIPS_TEOFF      0x34   // test mode OFF
#define LCD_PHILLIPS_TEON       0x35   // test mode ON
#define LCD_PHILLIPS_MADCTL     0x36   // memory access control       1-byte
#define LCD_PHILLIPS_SEP        0x37   // vertical scrolling start address 
#define LCD_PHILLIPS_IDMOFF     0x38   // idle mode OFF 
#define LCD_PHILLIPS_IDMON      0x39   // idle mode ON 
#define LCD_PHILLIPS_COLMOD     0x3A   // interface pixel format      1-byte     
#define LCD_PHILLIPS_SETVOP     0xB0   // set Vop   
#define LCD_PHILLIPS_BRS        0xB4   // bottom row swap 
#define LCD_PHILLIPS_TRS        0xB6   // top row swap 
#define LCD_PHILLIPS_DISCTR     0xB9   // display control 
#define LCD_PHILLIPS_DOR        0xBA   // data order 
#define LCD_PHILLIPS_TCDFE      0xBD   // enable/disable DF temperature compensation 
#define LCD_PHILLIPS_TCVOPE     0xBF   // enable/disable Vop temp comp 
#define LCD_PHILLIPS_EC         0xC0   // internal or external  oscillator 
#define LCD_PHILLIPS_SETMUL     0xC2   // set multiplication factor 
#define LCD_PHILLIPS_TCVOPAB    0xC3   // set TCVOP slopes A and B 
#define LCD_PHILLIPS_TCVOPCD    0xC4   // set TCVOP slopes c and d 
#define LCD_PHILLIPS_TCDF       0xC5   // set divider frequency 
#define LCD_PHILLIPS_DF8COLOR   0xC6   // set divider frequency 8-color mode 
#define LCD_PHILLIPS_SETBS      0xC7   // set bias system 
#define LCD_PHILLIPS_RDTEMP     0xC8   // temperature read back 
#define LCD_PHILLIPS_NLI        0xC9   // n-line inversion 
#define LCD_PHILLIPS_RDID1      0xDA   // read ID1 
#define LCD_PHILLIPS_RDID2      0xDB   // read ID2 
#define LCD_PHILLIPS_RDID3      0xDC   // read ID3  

//   **********************************************************************************************
//   *   ! Минимальная задержка, при которой работает мой LCD-контроллер 0                        *
//   *   ! В параметрах проекта частота 8МГц, Atmega работает на 8МГц  RC-генератор               *
//   *   ! Подбирается под конкретный контроллер - сплошь и рядом LCD изготовленные дядюшкой Ли   *
//   *                                                                                            *
//   **********************************************************************************************

#define NLCD_MIN_DELAY 1
  
// Макросы и определения

#define SCLK_LCD_SET  PORT_LCD |= (1<<SCLK_LCD_PIN) 
#define SDA_LCD_SET     PORT_LCD |= (1<<SDA_LCD_PIN)
#define CS_LCD_SET      PORT_LCD |= (1<<CS_LCD_PIN)
#define CS_SRAM_SET     PORT_LCD |= (1<<CS_SRAM_PIN) 
#define SRAM_HOLD_SET   PORT_LCD_RESERVE |= (1<<HOLD_SRAM_PIN)
#define RST_LCD_SET     PORT_LCD |= (1<<RST_LCD_PIN)

#define SCLK_LCD_RESET  PORT_LCD &= ~(1<<SCLK_LCD_PIN)
#define SDA_LCD_RESET   PORT_LCD &= ~(1<<SDA_LCD_PIN)
#define CS_LCD_RESET    PORT_LCD &= ~(1<<CS_LCD_PIN)
#define CS_SRAM_RESET   PORT_LCD &= ~(1<<CS_SRAM_PIN) 
#define SRAM_HOLD_RESET   PORT_LCD_RESERVE &= ~(1<<HOLD_SRAM_PIN)
#define RST_LCD_RESET   PORT_LCD &= ~(1<<RST_LCD_PIN)

#define CMD_LCD_MODE	0
#define DATA_LCD_MODE	1
#define NOFILL	        0
#define FILL            1
#define BORDERFILL      2

//******************************************************************************
// Базовые цвета

#define WHITE      0xFFF       // Белый
#define BLACK      0x000       // Черный
#define RED        0xF00       // Красный
#define GREEN      0x0F0       // Зеленый
#define BLUE       0x00F       // Синий 
#define CYAN       0x1FF       // Бирюзовый
#define MAGENTA    0xF0F       // Фиолетовый
#define YELLOW     0xFF0       // Желтый
#define GRAY	   0x222       // Серый
#define LIGHTBLUE  0xADE       // Светло-голубой
#define PINK       0xF6A       // Розовый

//******************************************************************************
// FOR SRAM 
#define __WRITE_INST  0b00000010; //write to memory
#define __READ_INST   0b00000011; //read from memory
#define __WRSR_INST   0b00000001; //write STATUS register
#define __RDSR_INST   0b00000101; //read STATUS register
#define __NULL_INST   0b11111111; //invalid/do nothing instruction
//modes of operation
#define __MODE_MASK  0b11000000;
#define __MODE_BITS  6; //mode bits start at bit 6
//hold pin
#define __HOLD_MASK   0b00000001;

// Прототипы функций

// Инициализация дисплея + заливка фона
void nlcd_Init(void);

// Передача байта (команды или данных) на LCD-контроллер
void nlcd_SendCmd(unsigned char c);
void nlcd_SendDataByte(unsigned char c);
void nlcd_SendDataByte2(unsigned char a,unsigned char b);
void nlcd_SendDataByte3(unsigned char a,unsigned char b,unsigned char c);

// Устанавливает текущие координаты x, y в знакоместах
void nlcd_GotoXY(unsigned char x, unsigned char y);

// Устанавливает Pixel в позицию x, y, цветом color
//void nlcd_Pixel(unsigned char x, unsigned char y, int color); // не работает с буффером RAM, нужно искать аналогию пикселю (например 2 пикселя подряд
//или квадрат 2х2 пикселя
void nlcd_PixelLine2x1(unsigned char x, unsigned char y, int P1_color, int P2_color);

void nlcd_PixelBox2x2(unsigned char x, unsigned char y, int P1_color, int P2_color, int P3_color, int P4_color); 


// Рисует линию из координаты x0, y0 в координату x1, y1 цветом color
//void nlcd_Line(unsigned char x0, unsigned char y0, unsigned char x1, unsigned char y1, int color);

// Рисует прямоугольник из координаты x0, y0 в координату x1, y1 с заливкой или нет, цветом color
void nlcd_Box(unsigned char x0, unsigned char y0, unsigned char x1, unsigned char y1, unsigned char fill, int color,int colorborder);

// Рисует круг из координаты x0, y0, с радиусом (в Pixel), без заливки цветом color                          
//void nlcd_Circle(unsigned char x0, unsigned char y0, unsigned char radius, int color);

void nlcd_Clear(int color);

void nlcd_InitPixelBuffer(int mode);

void nlcd_RenderPixelBuffer();

void nlcd_ReadPixelBuffer(int startaddr, unsigned char* data, int length);

void nlcd_WritePixelBuffer(int startaddr, unsigned char* data, int length);

// Устанавливает курсор в координаты x, y, цветом fColor, и фоном bColor
void nlcd_Char(char c, unsigned char y, unsigned char x, int fColor, int bColor);

// Выводит текст с координат x, y,цветом текста fColor, и фоном bColor
void nlcd_String(char *the_string, unsigned char x, unsigned char  y,  int fColor, int bColor);

void nlcd_HorizontalLine(unsigned char y, int color);


