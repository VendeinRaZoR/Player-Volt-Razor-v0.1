#include <mega328p.h>
#include <io.h>              // Библиотека ввода-вывода
#include <delay.h>          // Библиотека задержек
#include <pgmspace.h>
#include <stdio.h>
#include <stdlib.h>
#include "Nokia6610_lcd_lib.c"   // Подключаем драйвер LCD Nokia6610 ( ONLY PCF8833 )
#include "FatFS/mmc.c"
#include "vrgl_primitives.c"
#include "twi/twim.c"
#include "FatFS/ff.c"
#include "menu.h"
//#include "dataflash/df.c"

#define DS1307_ADR    104

#define MAX_FN_STR    320

#define CS_KEYS_SET  PORTC.0 = 1;
#define CS_KEYS_RESET  PORTC.0 = 0;
#define CLK_KEYS_SET  PORTC.2 = 1;
#define CLK_KEYS_RESET  PORTC.2 = 0;
#define KEYS_INIT   DDRC.0 = 1; DDRC.2 = 1; DDRD.7 = 0;

///KEYBOARD KEYS
#define FORWARD  247
#define BACKWARD 251   
#define PAUSE    253
#define PLAY     254

#define PWM_PORT PORTB
#define PWM_DIR DDRB
#define PWM_PIN 3

#define BUF_SIZE 256
#define HALF_BUF ((BUF_SIZE)/2)

struct CFileInfo
{
unsigned char * szFileName;
int nFileDate;
int nFileSize;
}g_FileInfo[32];
 
 DWORD get_fattime ()
{
    /* Pack date and time into a DWORD variable */
   return    ((DWORD)(/*rtc.year*/2010 - 1980) << 25)
         | ((DWORD)/*rtc.month*/10 << 21)
         | ((DWORD)/*rtc.mday*/7 << 16)
          | ((DWORD)/*rtc.hour*/1 << 11)
          | ((DWORD)/*rtc.min*/26 << 5)
          | ((DWORD)/*rtc.sec*/6 >> 1);
}      

//******************************************************************************
// Функции браузера плеера
//******************************************************************************
FIL file;  
FIL simple_file; 
    BYTE bIsfOpened = 0;  
    unsigned char fn16_str[13];    // ТОЛЬКО ДЛЯ ФОРМАТА 8.3 !!!   
    unsigned char rootpath[32]; 
    unsigned char tempstr[32];    
    unsigned char audiobuf[64];              
    int select_file_index = 0;  
    int select_file_option_index = 0; 
    unsigned int nNofDirFiles = 0;  
    int nKey;    
    int nAudioBufferIndex = 0;   
    BYTE bSelect = 0;    
    BYTE bFileInfoWindow = 0;  
    BYTE bFormatAlert = 0;      
    BYTE bTextReader = 0;
    BYTE bMusicPlayer = 0;
    BYTE bImageViever = 0;   
    int scroll_index = 0;    
    UINT state = 0;  
    BYTE bMusicFOpened = 0;
    
enum FILE_OPTION_MENU {OPEN=0,DELETE,INFO}fOption;
    
BYTE GetKeysStatus()      //функция чтения данных   74HC165
{
  unsigned int i=0;   
  BYTE keydata;
    
     CS_KEYS_RESET;         //защёлкиваем входные данные
     //delay_us(1);
     CS_KEYS_SET;  
      CLK_KEYS_SET;
     
   for( i=0; i<7; i++ )  
   {
     keydata |= PIND.7;    
     keydata <<= 1;            
      CLK_KEYS_RESET;            //сдвигаем данные
      //delay_us(1);   
      CLK_KEYS_SET;   
   }   
  keydata |= PIND.7;      
   return keydata;
}   

ISR(TIM0_OVF)
{
  OCR0A = audiobuf[nAudioBufferIndex];
  nAudioBufferIndex++;
}

ISR(EXT_INT0)
{
delay_ms(100);
nKey = GetKeysStatus();
}


FRESULT browser_scan_files (char* path) // Scan Files in the root directory
{
    FRESULT res;    
    FILINFO fno; 
    DIR dir;        
    unsigned char * szFileMenuList[3] = {"Open","Delete","Info"};
    int pos_index = 0;
    int i = 0,nf_index = 0;  
    int j = 0;
    int tempselindex = 0; 
    nlcd_Clear(WHITE);   
    if(!bIsfOpened)  
    {
    res = f_opendir(&dir, path);    
    }  
    if (res == FR_OK) 
    {      
    if(!bIsfOpened)   
    {
    f_open(&file, "0:LOG/SPISOKF.txt", FA_OPEN_ALWAYS  | FA_WRITE);   
    f_lseek(&file,0); 
    f_puts("Это список текущих файлов, просто лог, менять и удалять смысла нет\n\n",&file); 
    select_file_index = 0;
    }        
       for (nf_index = 0;;nf_index++) {  
            if(!bIsfOpened)  
            {
            res = f_readdir(&dir, &fno);   
            if (res != FR_OK || fno.fname[0] == 0) break;    
            g_FileInfo[nf_index].szFileName = (unsigned char*)malloc(strlen(fno.fname)+1);
            sprintf(g_FileInfo[nf_index].szFileName,"%s", fno.fname);
            g_FileInfo[nf_index].nFileSize = fno.fsize;
            g_FileInfo[nf_index].nFileDate = fno.fdate;   
            strcpy(fn16_str,fno.fname);
            strcat(fn16_str,"\n"); 
            f_puts(fn16_str,&file);  
            nNofDirFiles = nf_index+1;  
            }   
            if(g_FileInfo[nf_index].szFileName[0] == 0)break;    
            if((select_file_index+1 > nNofDirFiles) && (select_file_index+1 > 0))select_file_index = 0;      
            if(select_file_index+1 <= 0)select_file_index = nNofDirFiles-1;
                if(nf_index == select_file_index)  
                {    
                nlcd_Box(0,29+i,132,34+i,1,GREEN,0);
                nlcd_String(g_FileInfo[nf_index].szFileName,30+i,10,WHITE,GREEN);      
                pos_index = i;    
                } 
                else
                {
                nlcd_String(g_FileInfo[nf_index].szFileName,30+i,10,BLACK,WHITE);    
                }   
            i+=10;   
        }     
        if(bSelect)
        {                
        nlcd_Box(10,32+pos_index,58,90+pos_index,2,WHITE,GREEN); 
        for(i = 0;i<3;i++)
        {               
        if(select_file_option_index > 2) select_file_option_index = 0;
        if(select_file_option_index < 0) select_file_option_index = 2;
        if(i == select_file_option_index)  
        {
        nlcd_String(szFileMenuList[i],36+j+pos_index,25,WHITE,GREEN);       
        }
        else
        {
        nlcd_String(szFileMenuList[i],36+j+pos_index,25,BLACK,WHITE);       
        } 
        j+=10;
        } 
        }      
        if(!bIsfOpened) 
        f_close(&file);
    }   
    if((path[0] == '') || (path[0] == ' '))   
    { 
    nlcd_String("Root",18,5,BLACK,WHITE);    
    }     
    else   
    {          
    sprintf(&rootpath[0],"Root/%s", &path[0]); 
    nlcd_String(&rootpath[0],18,5,BLACK,WHITE);   
    }
    return res;
}     


void fileinfo_window(int nFileInfoIndex)
{
unsigned char szfinfo[10];
nlcd_Clear(WHITE);
nlcd_String("***File Info***",5,5,RED,WHITE);  
nlcd_String(g_FileInfo[nFileInfoIndex].szFileName,15,10,BLUE,WHITE);
nlcd_String("File Size",25,20,GREEN,WHITE);  
sprintf(&szfinfo[0],"%i B", g_FileInfo[nFileInfoIndex].nFileSize); 
nlcd_String(szfinfo,35,20,BLACK,WHITE);
nlcd_String("Changing Date",45,20,GREEN,WHITE);  
sprintf(&szfinfo[0],"%i", g_FileInfo[nFileInfoIndex].nFileDate); 
nlcd_String(szfinfo,55,20,BLACK,WHITE);
} 

unsigned char error[10];
void browser_init()
{
FRESULT res;
FATFS fs;
UINT br, bw,i; 
if(!f_mount(&fs,"0",1))
{  
//PORTD.0 = 1;    
if(bFileInfoWindow && !bTextReader && !bMusicPlayer)
{
fileinfo_window(select_file_index); 
}
if(!bFileInfoWindow && !bTextReader && bMusicPlayer)
{
music_player_init(select_file_index);
}
if(!bFileInfoWindow && bTextReader)
{
text_reader_init(select_file_index);
}
else
{
bMusicFOpened = 0;
browser_scan_files(""); 
}
switch(nKey)
{
case FORWARD:
if(bTextReader)
scroll_index+=16;
if(bSelect)
select_file_option_index++;
else
select_file_index++;
break;
case BACKWARD:
if(bTextReader)
scroll_index-=16;
if(bSelect)
select_file_option_index--;
else
select_file_index--;
break;
case PAUSE:
bTextReader = 0;
bMusicPlayer = 0;
bSelect = 0;
bFileInfoWindow = 0;
break;
case PLAY:
if(bSelect)
{
switch(select_file_option_index)
{
case OPEN:
if(!strcmp(&g_FileInfo[select_file_index].szFileName[8],".TXT") || !strcmp(&g_FileInfo[select_file_index].szFileName[8],".txt"))
{
bTextReader = 1;
}
if(!strcmp(&g_FileInfo[select_file_index].szFileName[8],".WAV") || !strcmp(&g_FileInfo[select_file_index].szFileName[8],".wav"))
{
bMusicPlayer = 1;
}
else
{
bFormatAlert = 1;
}
break;
case DELETE: 
if(!f_unlink(g_FileInfo[select_file_index].szFileName))
{
bSelect = 0;
bIsfOpened = 0;
select_file_option_index = 0;
select_file_index = 0;
for(i = 0;i<nNofDirFiles;i++)
{
if(g_FileInfo[i].szFileName)
memset((void*)g_FileInfo[i].szFileName,0,32);
free(g_FileInfo[i].szFileName);
g_FileInfo[i].szFileName = 0;
}
nKey = 0;
}
break;
case INFO:
bFileInfoWindow = 1;
break;
}
}
bSelect = 1;
break;
}                                      
if(!bIsfOpened)
f_mkdir("LOG");
if(bFormatAlert)
{
nlcd_Box(10,32,58,80,2,WHITE,GREEN); 
nlcd_String("Not Supported",45,20,RED,WHITE); 
delay_ms(1000);
bFormatAlert = 0;
} 
     // надо проверять готовность порта с помощью wait_ready, чтобы на MISO было 0xFF, иначе придется отрубать питание SD карты
bIsfOpened = 1;
nKey = 0;
}
else //if(res == FR_NOT_READY)
{ 
//bBrowserInit = 1;
f_mount(0,"0",1);
bIsfOpened = 0;
bSelect = 0;
select_file_index = 0;
select_file_option_index = 0;
for(i = 0;i<nNofDirFiles;i++)
{
if(g_FileInfo[i].szFileName)
memset((void*)g_FileInfo[i].szFileName,0,32);
free(g_FileInfo[i].szFileName);
}
nlcd_String("<Slot Empty>",30,20,BLACK,WHITE);
nlcd_String("No Card",18,5,BLACK,WHITE); 
}  
if(!bFileInfoWindow && !bTextReader)
{
nlcd_String("Browser",5,40,WHITE,BLUE);  
nlcd_HorizontalLine(27,BLACK); 
nlcd_HorizontalLine(15,BLACK); 
for(i = 0;i<15;i++)
{
nlcd_PixelLine2x1(30,i,WHITE,BLACK);
nlcd_PixelLine2x1(100,i,WHITE,BLACK);
}
}
nlcd_HorizontalLine(120,BLACK);  
for(i = 121;i<131;i++)
{
nlcd_PixelLine2x1(50,i,WHITE,BLACK);
nlcd_PixelLine2x1(95,i,WHITE,BLACK);
}
}

///////////////////////////////IMAGE VIEWER////////////////////////////////////////
void image_viewer_init()
{

}

///////////////////////////////TEXT READER/////////////////////////////////////////
void text_reader_init(int nFileIndex)
{
/*unsigned char sznotestring[16];
UINT bw;
int i;
   nlcd_String("***Note Pad***",5,5,RED,WHITE);   
   if(!f_open(&file,g_FileInfo[nFileIndex].szFileName,FA_OPEN_ALWAYS | FA_READ))
   {  
   f_lseek(&file,scroll_index);
   memset((void*)sznotestring,0,16); 
   for(i = 0;i<12;i++)
   {     
   f_read(&file,sznotestring,16,&bw);    
   nlcd_String(sznotestring,15 + i*10,5,BLACK,WHITE);       
   f_lseek(&file,scroll_index+(i+1)*16);   
   memset((void*)sznotestring,0,16);
   }  
   }      */      
}

////////////////////////////////////MUSIC PLAYER//////////////////////////////////
void music_player_init(int nFileIndex)
{
UINT bw;
unsigned char sznotestring[8];
int nNumChannels = 0;
nlcd_String("***Music Player***",5,1,RED,WHITE);   
nlcd_String(g_FileInfo[nFileIndex].szFileName,15,1,RED,WHITE); 
//f_lseek(&file,22);         
//f_read(&file,sznotestring,2,&bw);
//nNumChannels = atoi(sznotestring);
if(!bMusicFOpened)
{
   if(!f_open(&file,g_FileInfo[nFileIndex].szFileName,FA_OPEN_ALWAYS | FA_READ))
   { 
TCCR0A=(0<<COM0A1) | (1<<COM0A0) | (0<<COM0B1) | (0<<COM0B0) | (1<<WGM01) | (1<<WGM00);
TCCR0B=(0<<WGM02) | (0<<CS02) | (0<<CS01) | (1<<CS00);
TCNT0=0x00;
OCR0A=0x00;
OCR0B=0x00;
bMusicFOpened = 1;
f_lseek(&file,44);   
}
}      
switch (state)
{
 case 0:
 if (nAudioBufferIndex >= HALF_BUF) 
 {
   f_read(&file,sznotestring, HALF_BUF, &bw);
   if (bw > HALF_BUF)
   {
      state = 1;
   }
 }
 break;
 
 case 1:
 if (nAudioBufferIndex < HALF_BUF) 
 {
   f_read(&file,&sznotestring[HALF_BUF], HALF_BUF, &bw);
   if (bw > HALF_BUF)
   {
      state = 0;
   }
 }
 break;
 }
}
