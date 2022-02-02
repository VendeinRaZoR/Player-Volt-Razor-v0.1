/*
port bits access macros. Original written by Ascold Volkov. Rewritten by Andy Mozzevilov

examples

#define Pin1 D,2,H
#define Pin2 C,3,L
             ^ ^ ^
          port | |
             bit \active level

void main(void)
{
  direct(Pin1,O); //as output
  direct(Pin2,I); //as input
  driver(Pin2,PullUp); //driver(Pin2,HiZ);
  on(Pin1);
  if (signal(Pin2)) cpl(Pin1);
  if (latch(Pin1)) { //if active level presents on Pin1 for drive something
    //do something
  }
}
*/

#define _setL(port,bit) port&=~(1<<bit)
#define _setH(port,bit) port|=(1<<bit)
#define _set(port,bit,val) _set##val(PORT##port,bit)
#define on(x) _set (x)
#define SET _setH

#define _clrL(port,bit) port|=(1<<bit)
#define _clrH(port,bit) port&=~(1<<bit)
#define _clr(port,bit,val) _clr##val(PORT##port,bit)
#define off(x) _clr (x)
#define CLR _clrH

#define _bitL(port,bit) (!(port&(1<<bit)))
#define _bitH(port,bit) (port&(1<<bit))
#define _bit(port,bit,val) _bit##val(PIN##port,bit)
#define _latch(port,bit,val) _bit##val(PORT##port,bit)
#define signal(x) _bit (x)
#define latch(x) _latch (x)
#define BIT _bitH

#define _cpl(port,bit,val) port^=(1<<bit)
#define __cpl(port,bit,val) PORT##port^=(1<<bit)
#define cpl(x) __cpl (x)
#define CPL _cpl

#define _bitnum(port,bit,val) bit
#define BITNUM(x) _bitnum(x)

#define _setO(port,bit) port|=(1<<bit)
#define _setI(port,bit) port&=~(1<<bit)
#define _setPullUp(port,bit) port|=(1<<bit)
#define _setHiZ(port,bit) port&=~(1<<bit)
#define _mode(port,bit,val,mode) _set##mode(DDR##port,bit)
#define _dmode(port,bit,val,dmode) _set##dmode(PORT##port,bit)
#define DIR(port,bit,mode) _set##mode(DDR##port,bit)
#define DRIVER(port,bit,mode) _set##mode(PORT##port,bit)
//mode = O or I
#define direct(x,mode) _mode(x,mode)
//dmode = PullUp or HiZ
#define driver(x,dmode) _dmode(x,dmode)


/*original macros by Ascold Volkov begin here

#define _setL(port,bit) port&=~(1<<bit)
#define _setH(port,bit) port|=(1<<bit)
#define _set(port,bit,val) _set##val(port,bit)
#define on(x) _set (x)
#define SET _setH

#define _clrL(port,bit) port|=(1<<bit)
#define _clrH(port,bit) port&=~(1<<bit)
#define _clr(port,bit,val) _clr##val(port,bit)
#define off(x) _clr (x)
#define CLR _clrH

#define _bitL(port,bit) (!(port&(1<<bit)))
#define _bitH(port,bit) (port&(1<<bit))
#define _bit(port,bit,val) _bit##val(port,bit)
#define signal(x) _bit (x)
#define BIT _bitH

#define _cpl(port,bit,val) port^=(1<<bit)
#define cpl(x) _cpl (x)
#define CPL _cpl
*/




