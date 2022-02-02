
;CodeVisionAVR C Compiler V3.12 Advanced
;(C) Copyright 1998-2014 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com

;Build configuration    : Debug
;Chip type              : ATmega328P
;Program type           : Application
;Clock frequency        : 8,000000 MHz
;Memory model           : Small
;Optimize for           : Speed
;(s)printf features     : float, width, precision
;(s)scanf features      : int, width
;External RAM size      : 0
;Data Stack size        : 1200 byte(s)
;Heap size              : 100 byte(s)
;Promote 'char' to 'int': Yes
;'char' is unsigned     : Yes
;8 bit enums            : Yes
;Global 'const' stored in FLASH: Yes
;Enhanced function parameter passing: Yes
;Enhanced core instructions: On
;Automatic register allocation for global variables: On
;Smart register allocation: On

	#define _MODEL_SMALL_

	#pragma AVRPART ADMIN PART_NAME ATmega328P
	#pragma AVRPART MEMORY PROG_FLASH 32768
	#pragma AVRPART MEMORY EEPROM 1024
	#pragma AVRPART MEMORY INT_SRAM SIZE 2048
	#pragma AVRPART MEMORY INT_SRAM START_ADDR 0x100

	#define CALL_SUPPORTED 1

	.LISTMAC
	.EQU EERE=0x0
	.EQU EEWE=0x1
	.EQU EEMWE=0x2
	.EQU UDRE=0x5
	.EQU RXC=0x7
	.EQU EECR=0x1F
	.EQU EEDR=0x20
	.EQU EEARL=0x21
	.EQU EEARH=0x22
	.EQU SPSR=0x2D
	.EQU SPDR=0x2E
	.EQU SMCR=0x33
	.EQU MCUSR=0x34
	.EQU MCUCR=0x35
	.EQU WDTCSR=0x60
	.EQU UCSR0A=0xC0
	.EQU UDR0=0xC6
	.EQU SPL=0x3D
	.EQU SPH=0x3E
	.EQU SREG=0x3F
	.EQU GPIOR0=0x1E

	.DEF R0X0=R0
	.DEF R0X1=R1
	.DEF R0X2=R2
	.DEF R0X3=R3
	.DEF R0X4=R4
	.DEF R0X5=R5
	.DEF R0X6=R6
	.DEF R0X7=R7
	.DEF R0X8=R8
	.DEF R0X9=R9
	.DEF R0XA=R10
	.DEF R0XB=R11
	.DEF R0XC=R12
	.DEF R0XD=R13
	.DEF R0XE=R14
	.DEF R0XF=R15
	.DEF R0X10=R16
	.DEF R0X11=R17
	.DEF R0X12=R18
	.DEF R0X13=R19
	.DEF R0X14=R20
	.DEF R0X15=R21
	.DEF R0X16=R22
	.DEF R0X17=R23
	.DEF R0X18=R24
	.DEF R0X19=R25
	.DEF R0X1A=R26
	.DEF R0X1B=R27
	.DEF R0X1C=R28
	.DEF R0X1D=R29
	.DEF R0X1E=R30
	.DEF R0X1F=R31

	.EQU __SRAM_START=0x0100
	.EQU __SRAM_END=0x08FF
	.EQU __DSTACK_SIZE=0x04B0
	.EQU __HEAP_SIZE=0x0064
	.EQU __CLEAR_SRAM_SIZE=__SRAM_END-__SRAM_START+1

	.MACRO __CPD1N
	CPI  R30,LOW(@0)
	LDI  R26,HIGH(@0)
	CPC  R31,R26
	LDI  R26,BYTE3(@0)
	CPC  R22,R26
	LDI  R26,BYTE4(@0)
	CPC  R23,R26
	.ENDM

	.MACRO __CPD2N
	CPI  R26,LOW(@0)
	LDI  R30,HIGH(@0)
	CPC  R27,R30
	LDI  R30,BYTE3(@0)
	CPC  R24,R30
	LDI  R30,BYTE4(@0)
	CPC  R25,R30
	.ENDM

	.MACRO __CPWRR
	CP   R@0,R@2
	CPC  R@1,R@3
	.ENDM

	.MACRO __CPWRN
	CPI  R@0,LOW(@2)
	LDI  R30,HIGH(@2)
	CPC  R@1,R30
	.ENDM

	.MACRO __ADDB1MN
	SUBI R30,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDB2MN
	SUBI R26,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDW1MN
	SUBI R30,LOW(-@0-(@1))
	SBCI R31,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW2MN
	SUBI R26,LOW(-@0-(@1))
	SBCI R27,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	SBCI R22,BYTE3(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1N
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	SBCI R22,BYTE3(-@0)
	SBCI R23,BYTE4(-@0)
	.ENDM

	.MACRO __ADDD2N
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	SBCI R24,BYTE3(-@0)
	SBCI R25,BYTE4(-@0)
	.ENDM

	.MACRO __SUBD1N
	SUBI R30,LOW(@0)
	SBCI R31,HIGH(@0)
	SBCI R22,BYTE3(@0)
	SBCI R23,BYTE4(@0)
	.ENDM

	.MACRO __SUBD2N
	SUBI R26,LOW(@0)
	SBCI R27,HIGH(@0)
	SBCI R24,BYTE3(@0)
	SBCI R25,BYTE4(@0)
	.ENDM

	.MACRO __ANDBMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ANDWMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ANDI R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ANDD1N
	ANDI R30,LOW(@0)
	ANDI R31,HIGH(@0)
	ANDI R22,BYTE3(@0)
	ANDI R23,BYTE4(@0)
	.ENDM

	.MACRO __ANDD2N
	ANDI R26,LOW(@0)
	ANDI R27,HIGH(@0)
	ANDI R24,BYTE3(@0)
	ANDI R25,BYTE4(@0)
	.ENDM

	.MACRO __ORBMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ORWMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ORI  R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ORD1N
	ORI  R30,LOW(@0)
	ORI  R31,HIGH(@0)
	ORI  R22,BYTE3(@0)
	ORI  R23,BYTE4(@0)
	.ENDM

	.MACRO __ORD2N
	ORI  R26,LOW(@0)
	ORI  R27,HIGH(@0)
	ORI  R24,BYTE3(@0)
	ORI  R25,BYTE4(@0)
	.ENDM

	.MACRO __DELAY_USB
	LDI  R24,LOW(@0)
__DELAY_USB_LOOP:
	DEC  R24
	BRNE __DELAY_USB_LOOP
	.ENDM

	.MACRO __DELAY_USW
	LDI  R24,LOW(@0)
	LDI  R25,HIGH(@0)
__DELAY_USW_LOOP:
	SBIW R24,1
	BRNE __DELAY_USW_LOOP
	.ENDM

	.MACRO __GETD1S
	LDD  R30,Y+@0
	LDD  R31,Y+@0+1
	LDD  R22,Y+@0+2
	LDD  R23,Y+@0+3
	.ENDM

	.MACRO __GETD2S
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	LDD  R24,Y+@0+2
	LDD  R25,Y+@0+3
	.ENDM

	.MACRO __PUTD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R31
	STD  Y+@0+2,R22
	STD  Y+@0+3,R23
	.ENDM

	.MACRO __PUTD2S
	STD  Y+@0,R26
	STD  Y+@0+1,R27
	STD  Y+@0+2,R24
	STD  Y+@0+3,R25
	.ENDM

	.MACRO __PUTDZ2
	STD  Z+@0,R26
	STD  Z+@0+1,R27
	STD  Z+@0+2,R24
	STD  Z+@0+3,R25
	.ENDM

	.MACRO __CLRD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R30
	STD  Y+@0+2,R30
	STD  Y+@0+3,R30
	.ENDM

	.MACRO __POINTB1MN
	LDI  R30,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW1MN
	LDI  R30,LOW(@0+(@1))
	LDI  R31,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTD1M
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __POINTW1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	LDI  R22,BYTE3(2*@0+(@1))
	LDI  R23,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTB2MN
	LDI  R26,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW2MN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTW2FN
	LDI  R26,LOW(2*@0+(@1))
	LDI  R27,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD2FN
	LDI  R26,LOW(2*@0+(@1))
	LDI  R27,HIGH(2*@0+(@1))
	LDI  R24,BYTE3(2*@0+(@1))
	LDI  R25,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTBRM
	LDI  R@0,LOW(@1)
	.ENDM

	.MACRO __POINTWRM
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __POINTBRMN
	LDI  R@0,LOW(@1+(@2))
	.ENDM

	.MACRO __POINTWRMN
	LDI  R@0,LOW(@2+(@3))
	LDI  R@1,HIGH(@2+(@3))
	.ENDM

	.MACRO __POINTWRFN
	LDI  R@0,LOW(@2*2+(@3))
	LDI  R@1,HIGH(@2*2+(@3))
	.ENDM

	.MACRO __GETD1N
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __GETD2N
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __GETB1MN
	LDS  R30,@0+(@1)
	.ENDM

	.MACRO __GETB1HMN
	LDS  R31,@0+(@1)
	.ENDM

	.MACRO __GETW1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	.ENDM

	.MACRO __GETD1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	LDS  R22,@0+(@1)+2
	LDS  R23,@0+(@1)+3
	.ENDM

	.MACRO __GETBRMN
	LDS  R@0,@1+(@2)
	.ENDM

	.MACRO __GETWRMN
	LDS  R@0,@2+(@3)
	LDS  R@1,@2+(@3)+1
	.ENDM

	.MACRO __GETWRZ
	LDD  R@0,Z+@2
	LDD  R@1,Z+@2+1
	.ENDM

	.MACRO __GETD2Z
	LDD  R26,Z+@0
	LDD  R27,Z+@0+1
	LDD  R24,Z+@0+2
	LDD  R25,Z+@0+3
	.ENDM

	.MACRO __GETB2MN
	LDS  R26,@0+(@1)
	.ENDM

	.MACRO __GETW2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	.ENDM

	.MACRO __GETD2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	LDS  R24,@0+(@1)+2
	LDS  R25,@0+(@1)+3
	.ENDM

	.MACRO __PUTB1MN
	STS  @0+(@1),R30
	.ENDM

	.MACRO __PUTW1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	.ENDM

	.MACRO __PUTD1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	STS  @0+(@1)+2,R22
	STS  @0+(@1)+3,R23
	.ENDM

	.MACRO __PUTB1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRB
	.ENDM

	.MACRO __PUTW1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRW
	.ENDM

	.MACRO __PUTD1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRD
	.ENDM

	.MACRO __PUTBR0MN
	STS  @0+(@1),R0
	.ENDM

	.MACRO __PUTBMRN
	STS  @0+(@1),R@2
	.ENDM

	.MACRO __PUTWMRN
	STS  @0+(@1),R@2
	STS  @0+(@1)+1,R@3
	.ENDM

	.MACRO __PUTBZR
	STD  Z+@1,R@0
	.ENDM

	.MACRO __PUTWZR
	STD  Z+@2,R@0
	STD  Z+@2+1,R@1
	.ENDM

	.MACRO __GETW1R
	MOV  R30,R@0
	MOV  R31,R@1
	.ENDM

	.MACRO __GETW2R
	MOV  R26,R@0
	MOV  R27,R@1
	.ENDM

	.MACRO __GETWRN
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __PUTW1R
	MOV  R@0,R30
	MOV  R@1,R31
	.ENDM

	.MACRO __PUTW2R
	MOV  R@0,R26
	MOV  R@1,R27
	.ENDM

	.MACRO __ADDWRN
	SUBI R@0,LOW(-@2)
	SBCI R@1,HIGH(-@2)
	.ENDM

	.MACRO __ADDWRR
	ADD  R@0,R@2
	ADC  R@1,R@3
	.ENDM

	.MACRO __SUBWRN
	SUBI R@0,LOW(@2)
	SBCI R@1,HIGH(@2)
	.ENDM

	.MACRO __SUBWRR
	SUB  R@0,R@2
	SBC  R@1,R@3
	.ENDM

	.MACRO __ANDWRN
	ANDI R@0,LOW(@2)
	ANDI R@1,HIGH(@2)
	.ENDM

	.MACRO __ANDWRR
	AND  R@0,R@2
	AND  R@1,R@3
	.ENDM

	.MACRO __ORWRN
	ORI  R@0,LOW(@2)
	ORI  R@1,HIGH(@2)
	.ENDM

	.MACRO __ORWRR
	OR   R@0,R@2
	OR   R@1,R@3
	.ENDM

	.MACRO __EORWRR
	EOR  R@0,R@2
	EOR  R@1,R@3
	.ENDM

	.MACRO __GETWRS
	LDD  R@0,Y+@2
	LDD  R@1,Y+@2+1
	.ENDM

	.MACRO __PUTBSR
	STD  Y+@1,R@0
	.ENDM

	.MACRO __PUTWSR
	STD  Y+@2,R@0
	STD  Y+@2+1,R@1
	.ENDM

	.MACRO __MOVEWRR
	MOV  R@0,R@2
	MOV  R@1,R@3
	.ENDM

	.MACRO __INWR
	IN   R@0,@2
	IN   R@1,@2+1
	.ENDM

	.MACRO __OUTWR
	OUT  @2+1,R@1
	OUT  @2,R@0
	.ENDM

	.MACRO __CALL1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	ICALL
	.ENDM

	.MACRO __CALL1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	CALL __GETW1PF
	ICALL
	.ENDM

	.MACRO __CALL2EN
	PUSH R26
	PUSH R27
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMRDW
	POP  R27
	POP  R26
	ICALL
	.ENDM

	.MACRO __CALL2EX
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	CALL __EEPROMRDD
	ICALL
	.ENDM

	.MACRO __GETW1STACK
	IN   R30,SPL
	IN   R31,SPH
	ADIW R30,@0+1
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1STACK
	IN   R30,SPL
	IN   R31,SPH
	ADIW R30,@0+1
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z
	MOVW R30,R0
	.ENDM

	.MACRO __NBST
	BST  R@0,@1
	IN   R30,SREG
	LDI  R31,0x40
	EOR  R30,R31
	OUT  SREG,R30
	.ENDM


	.MACRO __PUTB1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RNS
	MOVW R26,R@0
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	CALL __PUTDP1
	.ENDM


	.MACRO __GETB1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R30,Z
	.ENDM

	.MACRO __GETB1HSX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	.ENDM

	.MACRO __GETW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z+
	LD   R23,Z
	MOVW R30,R0
	.ENDM

	.MACRO __GETB2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R26,X
	.ENDM

	.MACRO __GETW2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	.ENDM

	.MACRO __GETD2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R1,X+
	LD   R24,X+
	LD   R25,X
	MOVW R26,R0
	.ENDM

	.MACRO __GETBRSX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	LD   R@0,Z
	.ENDM

	.MACRO __GETWRSX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	LD   R@0,Z+
	LD   R@1,Z
	.ENDM

	.MACRO __GETBRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	LD   R@0,X
	.ENDM

	.MACRO __GETWRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	LD   R@0,X+
	LD   R@1,X
	.ENDM

	.MACRO __LSLW8SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	CLR  R30
	.ENDM

	.MACRO __PUTB1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __CLRW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __CLRD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R30
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __PUTB2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R26
	.ENDM

	.MACRO __PUTW2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z,R27
	.ENDM

	.MACRO __PUTD2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z+,R27
	ST   Z+,R24
	ST   Z,R25
	.ENDM

	.MACRO __PUTBSRX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	ST   Z,R@0
	.ENDM

	.MACRO __PUTWSRX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	ST   Z+,R@0
	ST   Z,R@1
	.ENDM

	.MACRO __PUTB1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __MULBRR
	MULS R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRRU
	MUL  R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRR0
	MULS R@0,R@1
	.ENDM

	.MACRO __MULBRRU0
	MUL  R@0,R@1
	.ENDM

	.MACRO __MULBNWRU
	LDI  R26,@2
	MUL  R26,R@0
	MOVW R30,R0
	MUL  R26,R@1
	ADD  R31,R0
	.ENDM

;NAME DEFINITIONS FOR GLOBAL VARIABLES ALLOCATED TO REGISTERS
	.DEF _bIsfOpened=R4
	.DEF _select_file_index=R5
	.DEF _select_file_index_msb=R6
	.DEF _select_file_option_index=R7
	.DEF _select_file_option_index_msb=R8
	.DEF _nNofDirFiles=R9
	.DEF _nNofDirFiles_msb=R10
	.DEF _nKey=R11
	.DEF _nKey_msb=R12
	.DEF _nAudioBufferIndex=R13
	.DEF _nAudioBufferIndex_msb=R14
	.DEF _bSelect=R3

;GPIOR0 INITIALIZATION VALUE
	.EQU __GPIOR0_INIT=0x00

	.CSEG
	.ORG 0x00

;START OF CODE MARKER
__START_OF_CODE:

;INTERRUPT VECTORS
	JMP  __RESET
	JMP  _EXT_INT0_func
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _TIM0_OVF_func
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _TWI_Isr
	JMP  0x00

_Nokia6610_fnt8x8:
	.DB  0x8,0x8,0x8,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x30,0x78,0x78,0x30,0x30,0x0,0x30,0x0
	.DB  0x6C,0x6C,0x6C,0x0,0x0,0x0,0x0,0x0
	.DB  0x6C,0x6C,0xFE,0x6C,0xFE,0x6C,0x6C,0x0
	.DB  0x18,0x3E,0x60,0x3C,0x6,0x7C,0x18,0x0
	.DB  0x0,0x63,0x66,0xC,0x18,0x33,0x63,0x0
	.DB  0x1C,0x36,0x1C,0x3B,0x6E,0x66,0x3B,0x0
	.DB  0x30,0x30,0x60,0x0,0x0,0x0,0x0,0x0
	.DB  0xC,0x18,0x30,0x30,0x30,0x18,0xC,0x0
	.DB  0x30,0x18,0xC,0xC,0xC,0x18,0x30,0x0
	.DB  0x0,0x66,0x3C,0xFF,0x3C,0x66,0x0,0x0
	.DB  0x0,0x30,0x30,0xFC,0x30,0x30,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x18,0x18,0x30
	.DB  0x0,0x0,0x0,0x7E,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x18,0x18,0x0
	.DB  0x3,0x6,0xC,0x18,0x30,0x60,0x40,0x0
	.DB  0x3E,0x63,0x63,0x6B,0x63,0x63,0x3E,0x0
	.DB  0x18,0x38,0x58,0x18,0x18,0x18,0x7E,0x0
	.DB  0x3C,0x66,0x6,0x1C,0x30,0x66,0x7E,0x0
	.DB  0x3C,0x66,0x6,0x1C,0x6,0x66,0x3C,0x0
	.DB  0xE,0x1E,0x36,0x66,0x7F,0x6,0xF,0x0
	.DB  0x7E,0x60,0x7C,0x6,0x6,0x66,0x3C,0x0
	.DB  0x1C,0x30,0x60,0x7C,0x66,0x66,0x3C,0x0
	.DB  0x7E,0x66,0x6,0xC,0x18,0x18,0x18,0x0
	.DB  0x3C,0x66,0x66,0x3C,0x66,0x66,0x3C,0x0
	.DB  0x3C,0x66,0x66,0x3E,0x6,0xC,0x38,0x0
	.DB  0x0,0x18,0x18,0x0,0x0,0x18,0x18,0x0
	.DB  0x0,0x18,0x18,0x0,0x0,0x18,0x18,0x30
	.DB  0xC,0x18,0x30,0x60,0x30,0x18,0xC,0x0
	.DB  0x0,0x0,0x7E,0x0,0x0,0x7E,0x0,0x0
	.DB  0x30,0x18,0xC,0x6,0xC,0x18,0x30,0x0
	.DB  0x3C,0x66,0x6,0xC,0x18,0x0,0x18,0x0
	.DB  0x3E,0x63,0x6F,0x69,0x6F,0x60,0x3E,0x0
	.DB  0x18,0x3C,0x66,0x66,0x7E,0x66,0x66,0x0
	.DB  0x7E,0x33,0x33,0x3E,0x33,0x33,0x7E,0x0
	.DB  0x1E,0x33,0x60,0x60,0x60,0x33,0x1E,0x0
	.DB  0x7C,0x36,0x33,0x33,0x33,0x36,0x7C,0x0
	.DB  0x7F,0x31,0x34,0x3C,0x34,0x31,0x7F,0x0
	.DB  0x7F,0x31,0x34,0x3C,0x34,0x30,0x78,0x0
	.DB  0x1E,0x33,0x60,0x60,0x67,0x33,0x1F,0x0
	.DB  0x66,0x66,0x66,0x7E,0x66,0x66,0x66,0x0
	.DB  0x3C,0x18,0x18,0x18,0x18,0x18,0x3C,0x0
	.DB  0xF,0x6,0x6,0x6,0x66,0x66,0x3C,0x0
	.DB  0x73,0x33,0x36,0x3C,0x36,0x33,0x73,0x0
	.DB  0x78,0x30,0x30,0x30,0x31,0x33,0x7F,0x0
	.DB  0x63,0x77,0x7F,0x7F,0x6B,0x63,0x63,0x0
	.DB  0x63,0x73,0x7B,0x6F,0x67,0x63,0x63,0x0
	.DB  0x3E,0x63,0x63,0x63,0x63,0x63,0x3E,0x0
	.DB  0x7E,0x33,0x33,0x3E,0x30,0x30,0x78,0x0
	.DB  0x3C,0x66,0x66,0x66,0x6E,0x3C,0xE,0x0
	.DB  0x7E,0x33,0x33,0x3E,0x36,0x33,0x73,0x0
	.DB  0x3C,0x66,0x30,0x18,0xC,0x66,0x3C,0x0
	.DB  0x7E,0x5A,0x18,0x18,0x18,0x18,0x3C,0x0
	.DB  0x66,0x66,0x66,0x66,0x66,0x66,0x7E,0x0
	.DB  0x66,0x66,0x66,0x66,0x66,0x3C,0x18,0x0
	.DB  0x63,0x63,0x63,0x6B,0x7F,0x77,0x63,0x0
	.DB  0x63,0x63,0x36,0x1C,0x1C,0x36,0x63,0x0
	.DB  0x66,0x66,0x66,0x3C,0x18,0x18,0x3C,0x0
	.DB  0x7F,0x63,0x46,0xC,0x19,0x33,0x7F,0x0
	.DB  0x3C,0x30,0x30,0x30,0x30,0x30,0x3C,0x0
	.DB  0x60,0x30,0x18,0xC,0x6,0x3,0x1,0x0
	.DB  0x3C,0xC,0xC,0xC,0xC,0xC,0x3C,0x0
	.DB  0x8,0x1C,0x36,0x63,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0xFF
	.DB  0x18,0x18,0xC,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x3C,0x6,0x3E,0x66,0x3B,0x0
	.DB  0x70,0x30,0x3E,0x33,0x33,0x33,0x6E,0x0
	.DB  0x0,0x0,0x3C,0x66,0x60,0x66,0x3C,0x0
	.DB  0xE,0x6,0x3E,0x66,0x66,0x66,0x3B,0x0
	.DB  0x0,0x0,0x3C,0x66,0x7E,0x60,0x3C,0x0
	.DB  0x1C,0x36,0x30,0x78,0x30,0x30,0x78,0x0
	.DB  0x0,0x0,0x3B,0x66,0x66,0x3E,0x6,0x7C
	.DB  0x70,0x30,0x36,0x3B,0x33,0x33,0x73,0x0
	.DB  0x18,0x0,0x38,0x18,0x18,0x18,0x3C,0x0
	.DB  0x6,0x0,0x6,0x6,0x6,0x66,0x66,0x3C
	.DB  0x70,0x30,0x33,0x36,0x3C,0x36,0x73,0x0
	.DB  0x38,0x18,0x18,0x18,0x18,0x18,0x3C,0x0
	.DB  0x0,0x0,0x66,0x7F,0x7F,0x6B,0x63,0x0
	.DB  0x0,0x0,0x7C,0x66,0x66,0x66,0x66,0x0
	.DB  0x0,0x0,0x3C,0x66,0x66,0x66,0x3C,0x0
	.DB  0x0,0x0,0x6E,0x33,0x33,0x3E,0x30,0x78
	.DB  0x0,0x0,0x3B,0x66,0x66,0x3E,0x6,0xF
	.DB  0x0,0x0,0x6E,0x3B,0x33,0x30,0x78,0x0
	.DB  0x0,0x0,0x3E,0x60,0x3C,0x6,0x7C,0x0
	.DB  0x8,0x18,0x3E,0x18,0x18,0x1A,0xC,0x0
	.DB  0x0,0x0,0x66,0x66,0x66,0x66,0x3B,0x0
	.DB  0x0,0x0,0x66,0x66,0x66,0x3C,0x18,0x0
	.DB  0x0,0x0,0x63,0x6B,0x7F,0x7F,0x36,0x0
	.DB  0x0,0x0,0x63,0x36,0x1C,0x36,0x63,0x0
	.DB  0x0,0x0,0x66,0x66,0x66,0x3E,0x6,0x7C
	.DB  0x0,0x0,0x7E,0x4C,0x18,0x32,0x7E,0x0
	.DB  0xE,0x18,0x18,0x70,0x18,0x18,0xE,0x0
	.DB  0xC,0xC,0xC,0x0,0xC,0xC,0xC,0x0
	.DB  0x70,0x18,0x18,0xE,0x18,0x18,0x70,0x0
	.DB  0x3B,0x6E,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x1C,0x36,0x36,0x1C,0x0,0x0,0x0,0x0
_ExCvt_G000:
	.DB  0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87
	.DB  0x88,0x89,0x8A,0x8B,0x8C,0x8D,0x8E,0x8F
	.DB  0x90,0x91,0x92,0x93,0x94,0x95,0x96,0x97
	.DB  0x98,0x99,0xAD,0x9B,0x8C,0x9D,0xAE,0x9F
	.DB  0xA0,0x21,0xA2,0xA3,0xA4,0xA5,0xA6,0xA7
	.DB  0xA8,0xA9,0xAA,0xAB,0xAC,0xAD,0xAE,0xAF
	.DB  0xB0,0xB1,0xB2,0xB3,0xB4,0xB5,0xB6,0xB7
	.DB  0xB8,0xB9,0xBA,0xBB,0xBC,0xBD,0xBE,0xBF
	.DB  0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7
	.DB  0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF
	.DB  0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0xD7
	.DB  0xD8,0xD9,0xDA,0xDB,0xDC,0xDD,0xDE,0xDF
	.DB  0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7
	.DB  0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF
	.DB  0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0xF7
	.DB  0xD8,0xD9,0xDA,0xDB,0xDC,0xDD,0xDE,0x9F

;GLOBAL REGISTER VARIABLES INITIALIZATION
__REG_VARS:
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0

;HEAP START MARKER INITIALIZATION
__HEAP_START_MARKER:
	.DW  0,0

_0xB9:
	.DB  0x1
_0x168:
	.DB  0xF8
_0x169:
	.DB  0x2,0x8,0x20,0x80
_0x456:
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,LOW(_0x455),HIGH(_0x455)
	.DB  LOW(_0x455+5),HIGH(_0x455+5),LOW(_0x455+12),HIGH(_0x455+12)
_0x0:
	.DB  0x65,0x72,0x72,0x6F,0x72,0x3A,0x20,0x25
	.DB  0x78,0x0,0x22,0x2A,0x2B,0x2C,0x3A,0x3B
	.DB  0x3C,0x3D,0x3E,0x3F,0x5B,0x5D,0x7C,0x7F
	.DB  0x0,0x4F,0x70,0x65,0x6E,0x0,0x44,0x65
	.DB  0x6C,0x65,0x74,0x65,0x0,0x49,0x6E,0x66
	.DB  0x6F,0x0,0x30,0x3A,0x4C,0x4F,0x47,0x2F
	.DB  0x53,0x50,0x49,0x53,0x4F,0x4B,0x46,0x2E
	.DB  0x74,0x78,0x74,0x0,0xDD,0xF2,0xEE,0x20
	.DB  0xF1,0xEF,0xE8,0xF1,0xEE,0xEA,0x20,0xF2
	.DB  0xE5,0xEA,0xF3,0xF9,0xE8,0xF5,0x20,0xF4
	.DB  0xE0,0xE9,0xEB,0xEE,0xE2,0x2C,0x20,0xEF
	.DB  0xF0,0xEE,0xF1,0xF2,0xEE,0x20,0xEB,0xEE
	.DB  0xE3,0x2C,0x20,0xEC,0xE5,0xED,0xFF,0xF2
	.DB  0xFC,0x20,0xE8,0x20,0xF3,0xE4,0xE0,0xEB
	.DB  0xFF,0xF2,0xFC,0x20,0xF1,0xEC,0xFB,0xF1
	.DB  0xEB,0xE0,0x20,0xED,0xE5,0xF2,0xA,0xA
	.DB  0x0,0x25,0x73,0x0,0x52,0x6F,0x6F,0x74
	.DB  0x0,0x52,0x6F,0x6F,0x74,0x2F,0x25,0x73
	.DB  0x0,0x2A,0x2A,0x2A,0x46,0x69,0x6C,0x65
	.DB  0x20,0x49,0x6E,0x66,0x6F,0x2A,0x2A,0x2A
	.DB  0x0,0x46,0x69,0x6C,0x65,0x20,0x53,0x69
	.DB  0x7A,0x65,0x0,0x25,0x69,0x20,0x42,0x0
	.DB  0x43,0x68,0x61,0x6E,0x67,0x69,0x6E,0x67
	.DB  0x20,0x44,0x61,0x74,0x65,0x0,0x25,0x69
	.DB  0x0,0x30,0x0,0x2E,0x54,0x58,0x54,0x0
	.DB  0x2E,0x57,0x41,0x56,0x0,0x2E,0x77,0x61
	.DB  0x76,0x0,0x4C,0x4F,0x47,0x0,0x4E,0x6F
	.DB  0x74,0x20,0x53,0x75,0x70,0x70,0x6F,0x72
	.DB  0x74,0x65,0x64,0x0,0x3C,0x53,0x6C,0x6F
	.DB  0x74,0x20,0x45,0x6D,0x70,0x74,0x79,0x3E
	.DB  0x0,0x4E,0x6F,0x20,0x43,0x61,0x72,0x64
	.DB  0x0,0x42,0x72,0x6F,0x77,0x73,0x65,0x72
	.DB  0x0,0x2A,0x2A,0x2A,0x4D,0x75,0x73,0x69
	.DB  0x63,0x20,0x50,0x6C,0x61,0x79,0x65,0x72
	.DB  0x2A,0x2A,0x2A,0x0,0x42,0x3A,0x25,0x69
	.DB  0x0,0x25,0x0,0x25,0x69,0x25,0x69,0x3A
	.DB  0x25,0x69,0x25,0x69,0x3A,0x25,0x69,0x25
	.DB  0x69,0x0
_0x2020000:
	.DB  0x2D,0x4E,0x41,0x4E,0x0
_0x2040060:
	.DB  0x1
_0x2040000:
	.DB  0x2D,0x4E,0x41,0x4E,0x0,0x49,0x4E,0x46
	.DB  0x0

__GLOBAL_INI_TBL:
	.DW  0x0C
	.DW  0x03
	.DW  __REG_VARS*2

	.DW  0x04
	.DW  0x89C
	.DW  __HEAP_START_MARKER*2

	.DW  0x01
	.DW  _Stat_G000
	.DW  _0xB9*2

	.DW  0x01
	.DW  _twiState_G000
	.DW  _0x168*2

	.DW  0x04
	.DW  _pre
	.DW  _0x169*2

	.DW  0x0F
	.DW  _0x267
	.DW  _0x0*2+10

	.DW  0x05
	.DW  _0x455
	.DW  _0x0*2+25

	.DW  0x07
	.DW  _0x455+5
	.DW  _0x0*2+30

	.DW  0x05
	.DW  _0x455+12
	.DW  _0x0*2+37

	.DW  0x12
	.DW  _0x455+17
	.DW  _0x0*2+42

	.DW  0x45
	.DW  _0x455+35
	.DW  _0x0*2+60

	.DW  0x02
	.DW  _0x455+104
	.DW  _0x0*2+127

	.DW  0x05
	.DW  _0x455+106
	.DW  _0x0*2+132

	.DW  0x10
	.DW  _0x475
	.DW  _0x0*2+145

	.DW  0x0A
	.DW  _0x475+16
	.DW  _0x0*2+161

	.DW  0x0E
	.DW  _0x475+26
	.DW  _0x0*2+176

	.DW  0x02
	.DW  _0x477
	.DW  _0x0*2+193

	.DW  0x01
	.DW  _0x477+2
	.DW  _0x0*2+9

	.DW  0x05
	.DW  _0x477+3
	.DW  _0x0*2+195

	.DW  0x05
	.DW  _0x477+8
	.DW  _0x0*2+55

	.DW  0x05
	.DW  _0x477+13
	.DW  _0x0*2+200

	.DW  0x05
	.DW  _0x477+18
	.DW  _0x0*2+205

	.DW  0x04
	.DW  _0x477+23
	.DW  _0x0*2+210

	.DW  0x0E
	.DW  _0x477+27
	.DW  _0x0*2+214

	.DW  0x02
	.DW  _0x477+41
	.DW  _0x0*2+193

	.DW  0x0D
	.DW  _0x477+43
	.DW  _0x0*2+228

	.DW  0x08
	.DW  _0x477+56
	.DW  _0x0*2+241

	.DW  0x08
	.DW  _0x477+64
	.DW  _0x0*2+249

	.DW  0x13
	.DW  _0x4B2
	.DW  _0x0*2+257

	.DW  0x02
	.DW  _0x4D7
	.DW  _0x0*2+281

	.DW  0x01
	.DW  __seed_G102
	.DW  _0x2040060*2

_0xFFFFFFFF:
	.DW  0

#define __GLOBAL_INI_TBL_PRESENT 1

__RESET:
	CLI
	CLR  R30
	OUT  EECR,R30

;INTERRUPT VECTORS ARE PLACED
;AT THE START OF FLASH
	LDI  R31,1
	OUT  MCUCR,R31
	OUT  MCUCR,R30

;CLEAR R2-R14
	LDI  R24,(14-2)+1
	LDI  R26,2
	CLR  R27
__CLEAR_REG:
	ST   X+,R30
	DEC  R24
	BRNE __CLEAR_REG

;CLEAR SRAM
	LDI  R24,LOW(__CLEAR_SRAM_SIZE)
	LDI  R25,HIGH(__CLEAR_SRAM_SIZE)
	LDI  R26,LOW(__SRAM_START)
	LDI  R27,HIGH(__SRAM_START)
__CLEAR_SRAM:
	ST   X+,R30
	SBIW R24,1
	BRNE __CLEAR_SRAM

;GLOBAL VARIABLES INITIALIZATION
	LDI  R30,LOW(__GLOBAL_INI_TBL*2)
	LDI  R31,HIGH(__GLOBAL_INI_TBL*2)
__GLOBAL_INI_NEXT:
	LPM  R24,Z+
	LPM  R25,Z+
	SBIW R24,0
	BREQ __GLOBAL_INI_END
	LPM  R26,Z+
	LPM  R27,Z+
	LPM  R0,Z+
	LPM  R1,Z+
	MOVW R22,R30
	MOVW R30,R0
__GLOBAL_INI_LOOP:
	LPM  R0,Z+
	ST   X+,R0
	SBIW R24,1
	BRNE __GLOBAL_INI_LOOP
	MOVW R30,R22
	RJMP __GLOBAL_INI_NEXT
__GLOBAL_INI_END:

;GPIOR0 INITIALIZATION
	LDI  R30,__GPIOR0_INIT
	OUT  GPIOR0,R30

;HARDWARE STACK POINTER INITIALIZATION
	LDI  R30,LOW(__SRAM_END-__HEAP_SIZE)
	OUT  SPL,R30
	LDI  R30,HIGH(__SRAM_END-__HEAP_SIZE)
	OUT  SPH,R30

;DATA STACK POINTER INITIALIZATION
	LDI  R28,LOW(__SRAM_START+__DSTACK_SIZE)
	LDI  R29,HIGH(__SRAM_START+__DSTACK_SIZE)

	JMP  _main

	.ESEG
	.ORG 0

	.DSEG
	.ORG 0x5B0

	.CSEG
;
;//***************************************************************************
;//  File........: Nokia6610_1.c
;//  Author(s)...: Goncharenko Valery and Chiper
;//  URL(s)......: http://digitalchip.ru
;//  Device(s)...: ATMega8
;//  Compiler....: Winavr-20100110
;//  Description.: Demo LCD Nokia6610
;//  Data........: 08.06.12
;//  Version.....: 1.0
;//***************************************************************************
;#include "menu.c"
;#include <mega328p.h>
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x01
	.EQU __sm_mask=0x0E
	.EQU __sm_adc_noise_red=0x02
	.EQU __sm_powerdown=0x04
	.EQU __sm_powersave=0x06
	.EQU __sm_standby=0x0C
	.EQU __sm_ext_standby=0x0E
	.SET power_ctrl_reg=smcr
	#endif
;#include <io.h>              // Библиотека ввода-вывода
;#include <delay.h>          // Библиотека задержек
;#include <pgmspace.h>
;#include <stdio.h>
;#include <stdlib.h>
;#include "Nokia6610_lcd_lib.c"   // Подключаем драйвер LCD Nokia6610 ( ONLY PCF8833 )
;//***************************************************************************
;//  File........: Nokia6610_lcd_lib.c
;//  Author(s)...: Goncharenko Valery and Chiper
;//  URL(s)......: http://digitalchip.ru
;//  Device(s)...: ATMega8
;//  Compiler....: Winavr-20100110
;//  Description.: Драйвер LCD Nokia6610 ( ONLY PCF8833 )
;//  Data........: 08.06.12
;//  Version.....: 1.0
;//***************************************************************************
;//  Notice: Все управляющие контакты LCD-контроллера должны быть подключены к
;//  одному и тому же порту на микроконтроллере
;//***************************************************************************
;#include "Nokia6610_lcd_lib.h"
;#include <delay.h>
;#include <pgmspace.h> //на всякий случай
;#include "Nokia6610_fnt8x8.h"
;
;//******************************************************************************
;//  Инициализация контроллера PCF8833
;void nlcd_Init(void)
; 0000 000C {

	.CSEG
_nlcd_Init:
; .FSTART _nlcd_Init
;
;	CS_LCD_RESET;
	CBI  0x5,2
;	SDA_LCD_RESET;
	CBI  0x5,3
;	SCLK_LCD_SET;
	SBI  0x5,5
;
;	RST_LCD_SET;    //     **********************************************
	SBI  0x5,1
;	RST_LCD_RESET;  //     *                                             *
	CBI  0x5,1
;	delay_ms(1);   //     *  Задержка для отработки апаратного сброса   *
	LDI  R26,LOW(1)
	LDI  R27,0
	CALL _delay_ms
;	RST_LCD_SET;    //     *                                             *
	SBI  0x5,1
;                    //     **********************************************
;  //  SCLK_LCD_SET;
;    SDA_LCD_SET;
	SBI  0x5,3
;  //  SCLK_LCD_SET;
;     delay_ms(1);
	LDI  R26,LOW(1)
	LDI  R27,0
	CALL _delay_ms
;    nlcd_SendCmd(LCD_PHILLIPS_SWRESET);   //    Программный сброс
	LDI  R26,LOW(1)
	RCALL _nlcd_SendCmd
;    delay_ms(1);
	LDI  R26,LOW(1)
	LDI  R27,0
	CALL _delay_ms
;	nlcd_SendCmd(LCD_PHILLIPS_SLEEPOUT);  //    Выход из режима сна
	LDI  R26,LOW(17)
	RCALL _nlcd_SendCmd
;     delay_ms(1);
	LDI  R26,LOW(1)
	LDI  R27,0
	CALL _delay_ms
;    nlcd_SendCmd(LCD_PHILLIPS_BSTRON);    //    Вкл. повышающий преобразователь напряжения
	LDI  R26,LOW(3)
	RCALL _nlcd_SendCmd
;    delay_ms(1);                     //    Задержка для отработки команды и выравнивания напряжения
	LDI  R26,LOW(1)
	LDI  R27,0
	CALL _delay_ms
;	nlcd_SendCmd(LCD_PHILLIPS_DISPON);    //    Дисплей вкл.
	LDI  R26,LOW(41)
	RCALL _nlcd_SendCmd
;     delay_ms(1);
	LDI  R26,LOW(1)
	LDI  R27,0
	CALL _delay_ms
;    nlcd_SendCmd(LCD_PHILLIPS_NORON);     //    Дисплей нормальный - вкл.
	LDI  R26,LOW(19)
	RCALL _nlcd_SendCmd
;    delay_ms(1);
	LDI  R26,LOW(1)
	LDI  R27,0
	CALL _delay_ms
;    nlcd_SendCmd(LCD_PHILLIPS_SETCON);    //            Контрастность
	LDI  R26,LOW(37)
	RCALL _nlcd_SendCmd
;     delay_ms(1);
	LDI  R26,LOW(1)
	LDI  R27,0
	CALL _delay_ms
;    nlcd_SendDataByte(0x3F);     //         0x00-min   0x3F-max
	LDI  R26,LOW(63)
	RCALL _nlcd_SendDataByte
;      delay_ms(1);
	LDI  R26,LOW(1)
	LDI  R27,0
	CALL _delay_ms
;    nlcd_SendCmd(LCD_PHILLIPS_CASET);     //    Установка начального и конечного адреса колонки
	LDI  R26,LOW(42)
	RCALL _nlcd_SendCmd
;	nlcd_SendDataByte(0);        //
	LDI  R26,LOW(0)
	RCALL _nlcd_SendDataByte
;	nlcd_SendDataByte(131);      //
	LDI  R26,LOW(131)
	RCALL _nlcd_SendDataByte
;	nlcd_SendCmd(LCD_PHILLIPS_PASET);     //     Установка начального и конечного адреса страницы
	LDI  R26,LOW(43)
	RCALL _nlcd_SendCmd
;	nlcd_SendDataByte(0);        //
	LDI  R26,LOW(0)
	RCALL _nlcd_SendDataByte
;	nlcd_SendDataByte(131);      //
	LDI  R26,LOW(131)
	RCALL _nlcd_SendDataByte
;                                           //    ******************************************************
;    nlcd_SendCmd(LCD_PHILLIPS_COLMOD);    //   *               Вывод цвета:                          *
	LDI  R26,LOW(58)
	RCALL _nlcd_SendCmd
; // nlcd_SendByte(DATA_LCD_MODE,0x02);     //   *     8 бит на пиксель- 256 цветов RGB 4:4:4           *
;	nlcd_SendDataByte(0x03);     //  *     12 бит на пиксель- 4096 цветов RGB 3:3:2  (выигрыш в быстродекйствии)         *
	LDI  R26,LOW(3)
	RCALL _nlcd_SendDataByte
;//  nlcd_SendByte(DATA_LCD_MODE,0x05);     //  *     16 бит на пиксель-65535 цветов RGB 5:6:5           *
;	                                       //  **********************************************************
;	delay_ms(1);
	LDI  R26,LOW(1)
	LDI  R27,0
	CALL _delay_ms
; // nlcd_SendByte(CMD_LCD_MODE,MADCTL);    //    Команда доступа к условиям отображения памяти RAM
;//  nlcd_SendByte(DATA_LCD_MODE,0x30);     //   1-byte, по умолчанию 0х00 - курим внимательно даташит
;	                                       //                на стр. 43
;	nlcd_SendCmd(LCD_PHILLIPS_RAMWR);     //    Запись данных в RAM дисплея
	LDI  R26,LOW(44)
	RCALL _nlcd_SendCmd
;	delay_ms(1);                          //    Немного ждем
	LDI  R26,LOW(1)
	LDI  R27,0
	CALL _delay_ms
;	nlcd_SendCmd(LCD_PHILLIPS_DISPOFF);   //    Выключаем дисплей чтобы не наблюдать мусор на экране
	LDI  R26,LOW(40)
	RCALL _nlcd_SendCmd
;	nlcd_Clear(WHITE);// очистка не нужна, так как есть буффер //nlcd_Clear(BLACK);   //    Заливаем весь дисплей будущим ф ...
	LDI  R26,LOW(4095)
	LDI  R27,HIGH(4095)
	CALL _nlcd_Clear
;    nlcd_RenderPixelBuffer();
	CALL _nlcd_RenderPixelBuffer
;    nlcd_SendCmd(LCD_PHILLIPS_DISPON);    //    Дисплей вкл.
	LDI  R26,LOW(41)
	RCALL _nlcd_SendCmd
;}
	RET
; .FEND
;
;//#if HARDWARE SPI
;void nlcd_InitSPI()
;{
_nlcd_InitSPI:
; .FSTART _nlcd_InitSPI
;DDR_LCD |= (1<<SCLK_LCD_PIN)|(1<<SDA_LCD_PIN)|(1<<CS_LCD_PIN)|(1<<RST_LCD_PIN)|(1<<CS_SRAM_PIN);
	IN   R30,0x4
	ORI  R30,LOW(0x2F)
	OUT  0x4,R30
;DDRC |= (1<<HOLD_SRAM_PIN);
	SBI  0x7,1
;}
	RET
; .FEND
;
;//******************************************************************************
;//  Передача байта (команды или данных) на LCD-контроллер
;//  mode: CMD_LCD_MODE  - передаем команду
;//		  DATA_LCD_MODE - передаем данные
;//  c:    значение передаваемого байта
;
;/*void nlcd_SendByte(char mode,unsigned char c)
;{
;unsigned char i=0;
;   CS_LCD_RESET;
;   SCLK_LCD_RESET;
; if(mode) SDA_LCD_SET;
;	 else	 SDA_LCD_RESET;
;     SCLK_LCD_SET;
;// SPCR |= (1<<SPE);
;//   SPDR = c;
; //  while(!(SPSR & (1<<SPIF)));
;//   SPCR |= (0<<SPE);
;    for(i=0;i<8;i++)
;    {
;    	SCLK_LCD_RESET;
;        if(c & 0x80) SDA_LCD_SET;
;        else	     SDA_LCD_RESET;
;        SCLK_LCD_SET;
;        c <<= 1;
;        delay_us(NLCD_MIN_DELAY);
;    }
;   CS_LCD_SET;
;}      */
;
;void nlcd_SendCmd(unsigned char c)
;{
_nlcd_SendCmd:
; .FSTART _nlcd_SendCmd
;#asm
	ST   -Y,R26
;	c -> Y+0
{
	CBI  0x5,2
    CBI  0x5,5
    CBI  0x5,3
    SBI  0x5,5
}
;SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
	LDI  R30,LOW(80)
	OUT  0x2C,R30
;SPSR = (1<<SPI2X);
	LDI  R30,LOW(1)
	OUT  0x2D,R30
;SPDR = c;
	LD   R30,Y
	OUT  0x2E,R30
;while(!(SPSR & (1<<SPIF)));
_0x3:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0x3
;SPCR = 0;
	LDI  R30,LOW(0)
	OUT  0x2C,R30
;SPSR = 0;
	OUT  0x2D,R30
;#asm
{
SBI  0x5,2
CBI  0x5,5
}
;}
	JMP  _0x20C0026
; .FEND
;
;void nlcd_SendDataByte(unsigned char c)
;{
_nlcd_SendDataByte:
; .FSTART _nlcd_SendDataByte
;#asm
	ST   -Y,R26
;	c -> Y+0
{
	CBI  0x5,2
    CBI  0x5,5
    SBI  0x5,3
    SBI  0x5,5
}
;SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
	LDI  R30,LOW(80)
	OUT  0x2C,R30
;SPSR = (1<<SPI2X);
	LDI  R30,LOW(1)
	OUT  0x2D,R30
;SPDR = c;
	LD   R30,Y
	OUT  0x2E,R30
;while(!(SPSR & (1<<SPIF)));
_0x6:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0x6
;SPCR = 0;
	LDI  R30,LOW(0)
	OUT  0x2C,R30
;SPSR = 0;
	OUT  0x2D,R30
;#asm
{
SBI  0x5,2
}
;}
	JMP  _0x20C0026
; .FEND
;   /*
;void nlcd_SendDataByte2(unsigned char a,unsigned char b)
;{
;#asm
;{
;	CBI  0x5,2
;    CBI  0x5,5
;}
;#endasm
;//First byte
;#asm
;{
;    CBI  0x5,5
;    SBI  0x5,3
;    SBI  0x5,5
;}
;#endasm
;SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(1<<CPOL)|(1<<CPHA)|(0<<SPR1)|(0<<SPR0);
;SPSR = (1<<SPI2X);
;SPDR = a;
;while(!(SPSR & (1<<SPIF)));
;SPCR = 0;
;SPSR = 0;
;//Second byte
;#asm
;{
;    CBI  0x5,5
;    SBI  0x5,3
;    SBI  0x5,5
;}
;#endasm
;SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(1<<CPOL)|(1<<CPHA)|(0<<SPR1)|(0<<SPR0);
;SPSR = (1<<SPI2X);
;SPDR = b;
;while(!(SPSR & (1<<SPIF)));
;SPCR = 0;
;SPSR = 0;
;#asm
;{
;SBI  0x18,2
;}
;#endasm
;}
;
;void nlcd_SendDataByte3(unsigned char a,unsigned char b,unsigned char c)
;{
;#asm
;{
;	CBI  0x18,2
;}
;#endasm
;//First byte
;#asm
;{
;    CBI  0x18,5
;    SBI  0x18,3
;    SBI  0x18,5
;}
;#endasm
;SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(1<<CPOL)|(1<<CPHA)|(0<<SPR1)|(0<<SPR0);
;SPSR = (1<<SPI2X);
;SPDR = a;
;while(!(SPSR & (1<<SPIF)));
;SPCR = 0;
;SPSR = 0;
;//Second byte
;#asm
;{
;    CBI  0x18,5
;    SBI  0x18,3
;    SBI  0x18,5
;}
;#endasm
;SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(1<<CPOL)|(1<<CPHA)|(0<<SPR1)|(0<<SPR0);
;SPSR = (1<<SPI2X);
;SPDR = b;
;while(!(SPSR & (1<<SPIF)));
;SPCR = 0;
;SPSR = 0;
;//Third byte
;#asm
;{
;    CBI  0x18,5
;    SBI  0x18,3
;    SBI  0x18,5
;}
;#endasm
;SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(1<<CPOL)|(1<<CPHA)|(0<<SPR1)|(0<<SPR0);
;SPSR = (1<<SPI2X);
;SPDR = c;
;while(!(SPSR & (1<<SPIF)));
;SPCR = 0;
;SPSR = 0;
;#asm
;{
;SBI  0x18,2
;}
;#endasm
;} */
;
;//******************************************************************************
;//	Имя: 		 GotoXY(unsigned char x, unsigned char y)
;// 	Описание:    Переход в позицию x, y
;//           	 GotoXY( x, y)
;//	Параметры:   x: позиция 0-131
;//			     y: позиция 0-131
;//  Пример:		 GotoXY(32,17);
;//******************************************************************************
;void nlcd_GotoXY(unsigned char x, unsigned char y)
;{
;  /// Useful Anymore with buffer
;}
;
;//******************************************************************************
;//	Имя: 		 nlcd_Pixel(unsigned char x, unsigned char y, int color)
;// 	Описание:    Устанавливает Pixel в позицию x, y, цветом color
;//           	 nlcd_Pixel( x, y,color)
;//	Параметры:   x:     позиция 0-131
;//			     y:     позиция 0-131
;//               color: цвет (12-bit см. #define)
;//  Пример:		 nlcd_Pixel(21,45,BLACK);
;//******************************************************************************
;void nlcd_PixelBox2x2(unsigned char x, unsigned char y, int P1_color,int P2_color, int P3_color, int P4_color)   ///R сл ...
;{
;    unsigned char a = (P1_color >> 4);
;    unsigned char b = ((P1_color ) << 4) | ((P2_color >> 8) );
;    unsigned char c = P2_color;
;    unsigned char e = (P3_color >> 4);
;    unsigned char f = ((P3_color ) << 4) | ((P4_color >> 8) );
;    unsigned char g = P4_color;
;    unsigned char pBufferSlice[6];
;    pBufferSlice[0] = a;
;	x -> Y+21
;	y -> Y+20
;	P1_color -> Y+18
;	P2_color -> Y+16
;	P3_color -> Y+14
;	P4_color -> Y+12
;	a -> R17
;	b -> R16
;	c -> R19
;	e -> R18
;	f -> R21
;	g -> R20
;	pBufferSlice -> Y+6
;    pBufferSlice[1] = b;
;    pBufferSlice[2] = c;
;    pBufferSlice[3] = e;
;    pBufferSlice[4] = f;
;    pBufferSlice[5] = g;
;    x /= 2;
;  // Пишем в RAM
;   nlcd_WritePixelBuffer((y*3*(RESRAM_X) + 3*(x)),&pBufferSlice[0],3);
;   nlcd_WritePixelBuffer(((y+1)*3*(RESRAM_X) + 3*(x)),&pBufferSlice[3],3);
;}
;
;//******************************************************************************
;//	Имя: 		 nlcd_Pixel(unsigned char x, unsigned char y, int color)
;// 	Описание:    Устанавливает Pixel в позицию x, y, цветом color
;//           	 nlcd_Pixel( x, y,color)
;//	Параметры:   x:     позиция 0-131
;//			     y:     позиция 0-131
;//               color: цвет (12-bit см. #define)
;//  Пример:		 nlcd_Pixel(21,45,BLACK);
;//******************************************************************************
;void nlcd_PixelLine2x1(unsigned char x, unsigned char y, int P1_color, int P2_color)   ///R следующие пикселя = 0
;{
_nlcd_PixelLine2x1:
; .FSTART _nlcd_PixelLine2x1
;    unsigned char a = (P1_color >> 4);
;    unsigned char b = ((P1_color ) << 4) | ((P2_color >> 8) );
;    unsigned char c = P2_color;
;    unsigned char pBufferSlice[3];
;    pBufferSlice[0] = a;
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,3
	CALL __SAVELOCR4
;	x -> Y+12
;	y -> Y+11
;	P1_color -> Y+9
;	P2_color -> Y+7
;	a -> R17
;	b -> R16
;	c -> R19
;	pBufferSlice -> Y+4
	LDD  R30,Y+9
	LDD  R31,Y+9+1
	CALL __ASRW4
	MOV  R17,R30
	LDD  R30,Y+9
	SWAP R30
	ANDI R30,0xF0
	MOV  R26,R30
	LDD  R30,Y+7
	LDD  R31,Y+7+1
	CALL __ASRW8
	OR   R30,R26
	MOV  R16,R30
	LDD  R19,Y+7
	__PUTBSR 17,4
;    pBufferSlice[1] = b;
	MOVW R30,R28
	ADIW R30,5
	ST   Z,R16
;    pBufferSlice[2] = c;
	MOVW R30,R28
	ADIW R30,6
	ST   Z,R19
;    x /= 2;
	LDD  R26,Y+12
	LDI  R27,0
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	CALL __DIVW21
	STD  Y+12,R30
;   // iff(x%2)x/=2;
;  // Пишем в RAM
;   nlcd_WritePixelBuffer((y*3*(RESRAM_X) + 3*(x)),&pBufferSlice[0],3);
	LDD  R26,Y+11
	LDI  R30,LOW(3)
	MUL  R30,R26
	MOVW R30,R0
	LDI  R26,LOW(66)
	LDI  R27,HIGH(66)
	CALL __MULW12
	MOVW R22,R30
	LDD  R30,Y+12
	LDI  R26,LOW(3)
	MUL  R30,R26
	MOVW R30,R0
	ADD  R30,R22
	ADC  R31,R23
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,6
	ST   -Y,R31
	ST   -Y,R30
	LDI  R27,0
	RCALL _nlcd_WritePixelBuffer
;}
	CALL __LOADLOCR4
	ADIW R28,13
	RET
; .FEND
;
;void nlcd_HorizontalLine(unsigned char y, int color)
;{
_nlcd_HorizontalLine:
; .FSTART _nlcd_HorizontalLine
;int i = 0;
;for(i=0;i<131;i++)
	ST   -Y,R27
	ST   -Y,R26
	ST   -Y,R17
	ST   -Y,R16
;	y -> Y+4
;	color -> Y+2
;	i -> R16,R17
	__GETWRN 16,17,0
	__GETWRN 16,17,0
_0xA:
	__CPWRN 16,17,131
	BRGE _0xB
;nlcd_PixelLine2x1(i,y,color,color);
	ST   -Y,R16
	LDD  R30,Y+5
	ST   -Y,R30
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	RCALL _nlcd_PixelLine2x1
	__ADDWRN 16,17,1
	RJMP _0xA
_0xB:
	LDD  R17,Y+1
	LDD  R16,Y+0
	ADIW R28,5
	RET
; .FEND
;
;//******************************************************************************
;//	Имя: 		 nlcd_Line(unsigned char x0, unsigned char y0, unsigned char x1, unsigned char y1, int color)
;// 	Описание:    Рисует линию из координаты x0, y0 в координату x1, y1 цветом color
;//           	 nlcd_Line(x0, y0, x1, y1, color)
;//	Параметры:   x:     позиция 0-131
;//			     y:     позиция 0-131
;//               color: цвет (12-bit см. #define)
;//  Пример:		 nlcd_Pixel(25,60,25,80,RED);
;//******************************************************************************
;/*void nlcd_Line(unsigned char x0, unsigned char y0, unsigned char x1, unsigned char y1, int color)
;{
;
;   int dy = y1 - y0;
;   int dx = x1 - x0;
;   int stepx, stepy;
;   if (dy < 0) { dy = -dy;  stepy = -1; } else { stepy = 1; }
;   if (dx < 0) { dx = -dx;  stepx = -1; } else { stepx = 1; }
;
;   dy <<= 1;                              // dy is now 2*dy
;   dx <<= 1;                              // dx is now 2*dx
;
;
;   nlcd_Pixel(x0, y0, color);
;
;   if (dx > dy)
;   {
;       int fraction = dy - (dx >> 1);     // same as 2*dy - dx
;       while (x0 != x1)
;	   {
; 	       if (fraction >= 0)
;		   {
; 		       y0 += stepy;
;               fraction -= dx;            // same as fraction -= 2*dx
; 		   }
; 		x0 += stepx;
;        fraction += dy;                   // same as fraction -= 2*dy
;        nlcd_Pixel(x0, y0, color);
;       }
;   }
; 	else
;    {
; 	    int fraction = dx - (dy >> 1);
;        while (y0 != y1)
;		{
; 		    if (fraction >= 0)
;		    {
; 		        x0 += stepx;
; 				fraction -= dy;
;            }
;        y0 += stepy;
; 	    fraction += dx;
;        nlcd_Pixel(x0, y0, color);
;        }
; 	}
;
;}    */
;
;//******************************************************************************
;//	Имя: 		 nlcd_InitPixelBuffer(int mode)
;// 	Описание:    Инициализация пиксельного буффера, режим mode - в регистр статуса буффера
;//           	 nlcd_Lnlcd_InitPixelBufferine(mode)
;//	Параметры:
;//  Пример:		 nlcd_InitPixelBuffer(mode);
;//******************************************************************************
;// Работа с SRAM 23X256
;void nlcd_InitPixelBuffer(int mode)
;{
_nlcd_InitPixelBuffer:
; .FSTART _nlcd_InitPixelBuffer
;unsigned char inst = mode<<__MODE_BITS;
;CS_SRAM_RESET;
	ST   -Y,R27
	ST   -Y,R26
	ST   -Y,R17
;	mode -> Y+1
;	inst -> R17
	LDD  R30,Y+1
	SWAP R30
	ANDI R30,0xF0
	LSL  R30
	LSL  R30
	MOV  R17,R30
	CBI  0x5,0
;SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
	LDI  R30,LOW(80)
	OUT  0x2C,R30
;SPSR = (1<<SPI2X);
	LDI  R30,LOW(1)
	OUT  0x2D,R30
;SPDR = __WRSR_INST;
	OUT  0x2E,R30
;while(!(SPSR & (1<<SPIF)));
_0xC:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0xC
;SPDR = inst & __MODE_MASK;
	MOV  R30,R17
	ANDI R30,LOW(0xC0)
	OUT  0x2E,R30
;while(!(SPSR & (1<<SPIF)));
_0xF:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0xF
;SPCR = 0;
	LDI  R30,LOW(0)
	OUT  0x2C,R30
;SPSR = 0;
	OUT  0x2D,R30
;CS_SRAM_SET;
	SBI  0x5,0
;}
	LDD  R17,Y+0
	ADIW R28,3
	RET
; .FEND
;//******************************************************************************
;//	Имя: 		 nlcd_WritePixelBuffer(int startaddr, unsigned char* data, int length)
;// 	Описание:    Чтение в пиксельный буффер, режим чтения - непрерывный, массив (Stquently, array)
;//           	 nlcd_WritePixelBuffer(startaddr,&data[0],length)
;//	Параметры:
;//  Пример:		 nlcd_WritePixelBuffer(startaddr,&data[0],length);
;//******************************************************************************
;// Работа с SRAM 23X256
;void nlcd_WritePixelBuffer(int startaddr, unsigned char* data, int length)
;{
_nlcd_WritePixelBuffer:
; .FSTART _nlcd_WritePixelBuffer
;int i;
;CS_SRAM_RESET;
	ST   -Y,R27
	ST   -Y,R26
	ST   -Y,R17
	ST   -Y,R16
;	startaddr -> Y+6
;	*data -> Y+4
;	length -> Y+2
;	i -> R16,R17
	CBI  0x5,0
;SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
	LDI  R30,LOW(80)
	OUT  0x2C,R30
;SPSR = (1<<SPI2X);
	LDI  R30,LOW(1)
	OUT  0x2D,R30
;SPDR = __WRITE_INST;
	LDI  R30,LOW(2)
	OUT  0x2E,R30
;while(!(SPSR & (1<<SPIF)));
_0x12:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0x12
;SPDR = startaddr>>8;
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	CALL __ASRW8
	OUT  0x2E,R30
;while(!(SPSR & (1<<SPIF)));
_0x15:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0x15
;SPDR = startaddr;
	LDD  R30,Y+6
	OUT  0x2E,R30
;while(!(SPSR & (1<<SPIF)));
_0x18:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0x18
;  for(i=0; i<length; i++)
	__GETWRN 16,17,0
_0x1C:
	LDD  R30,Y+2
	LDD  R31,Y+2+1
	CP   R16,R30
	CPC  R17,R31
	BRGE _0x1D
;  {
;SPDR = data[i];
	MOVW R30,R16
	LDD  R26,Y+4
	LDD  R27,Y+4+1
	ADD  R26,R30
	ADC  R27,R31
	LD   R30,X
	OUT  0x2E,R30
;while(!(SPSR & (1<<SPIF)));
_0x1E:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0x1E
;  }
	__ADDWRN 16,17,1
	RJMP _0x1C
_0x1D:
;SPCR = 0;
	LDI  R30,LOW(0)
	OUT  0x2C,R30
;SPSR = 0;
	OUT  0x2D,R30
;
;CS_SRAM_SET;
	SBI  0x5,0
;}
	LDD  R17,Y+1
	LDD  R16,Y+0
	JMP  _0x20C002B
; .FEND
;
;//******************************************************************************
;//	Имя: 		 nlcd_ReadPixelBuffer(int startaddr, unsigned char* data, int length)
;// 	Описание:    Чтение в пиксельный буффер, режим чтения - непрерывный, массив (Stquently, array)
;//           	 nlcd_ReadPixelBuffer(startaddr,&data[0],length)
;//	Параметры:
;//  Пример:		 nlcd_ReadPixelBuffer(startaddr,&data[0],length);
;//******************************************************************************
;// Работа с SRAM 23X256
;void nlcd_ReadPixelBuffer(int startaddr, unsigned char* data, int length)
;{
;int i;
;CS_SRAM_RESET;
;	startaddr -> Y+6
;	*data -> Y+4
;	length -> Y+2
;	i -> R16,R17
;SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
;SPSR = (1<<SPI2X);
;SPDR = __READ_INST;
;while(!(SPSR & (1<<SPIF)));
;SPDR = (startaddr)>>8;
;while(!(SPSR & (1<<SPIF)));
;SPDR = startaddr;
;while(!(SPSR & (1<<SPIF)));
;  for(i=0; i<3; i++)
;  {
;  SPDR = __NULL_INST;
;  while(!(SPSR & (1<<SPIF)));
;  data[i] = SPDR;
;  }
;SPCR = 0;
;SPSR = 0;
;CS_SRAM_SET;
;}
;
;//******************************************************************************
;//	Имя: 		 nlcd_RenderPixelBuffer()
;// 	Описание:    Рендер графического буффера
;//           	 nlcd_RenderPixelBuffer()
;//	Параметры:
;//  Пример:		 nlcd_RenderPixelBuffer();
;//******************************************************************************
;
;void nlcd_RenderPixelBuffer()
;{
_nlcd_RenderPixelBuffer:
; .FSTART _nlcd_RenderPixelBuffer
;int i=0;
;int k=0;
;unsigned char ppBufferSlice[3];
;CS_SRAM_SET;
	SBIW R28,3
	CALL __SAVELOCR4
;	i -> R16,R17
;	k -> R18,R19
;	ppBufferSlice -> Y+4
	__GETWRN 16,17,0
	__GETWRN 18,19,0
	SBI  0x5,0
;CS_LCD_RESET;
	CBI  0x5,2
; nlcd_SendCmd(LCD_PHILLIPS_PASET);   // Команда адреса страницы RAM
	LDI  R26,LOW(43)
	CALL _nlcd_SendCmd
;   nlcd_SendDataByte(0);      // Старт
	LDI  R26,LOW(0)
	RCALL _nlcd_SendDataByte
;   nlcd_SendDataByte(131);
	LDI  R26,LOW(131)
	RCALL _nlcd_SendDataByte
;   nlcd_SendCmd(LCD_PHILLIPS_CASET);
	LDI  R26,LOW(42)
	CALL _nlcd_SendCmd
;   nlcd_SendDataByte(0);
	LDI  R26,LOW(0)
	RCALL _nlcd_SendDataByte
;   nlcd_SendDataByte(131);      //
	LDI  R26,LOW(131)
	RCALL _nlcd_SendDataByte
;nlcd_SendCmd(LCD_PHILLIPS_RAMWR);
	LDI  R26,LOW(44)
	CALL _nlcd_SendCmd
;for(i=0;i < 8712;i++)
	__GETWRN 16,17,0
_0x31:
	__CPWRN 16,17,8712
	BRLT PC+2
	RJMP _0x32
;{
;//First Read Pixel Buffer Slice (slice for 3 pixels)
;CS_LCD_SET;
	SBI  0x5,2
;CS_SRAM_RESET;
	CBI  0x5,0
;SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
	LDI  R30,LOW(80)
	OUT  0x2C,R30
;SPSR = (1<<SPI2X);
	LDI  R30,LOW(1)
	OUT  0x2D,R30
;SPDR = __READ_INST;
	LDI  R30,LOW(3)
	OUT  0x2E,R30
;while(!(SPSR & (1<<SPIF)));
_0x33:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0x33
;SPDR = (i*3)>>8;
	MOVW R30,R16
	LDI  R26,LOW(3)
	LDI  R27,HIGH(3)
	CALL __MULW12
	CALL __ASRW8
	OUT  0x2E,R30
;while(!(SPSR & (1<<SPIF)));
_0x36:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0x36
;SPDR = i*3;
	LDI  R26,LOW(3)
	MULS R16,R26
	MOVW R30,R0
	OUT  0x2E,R30
;while(!(SPSR & (1<<SPIF)));
_0x39:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0x39
;  for(k=0; k<3; k++)
	__GETWRN 18,19,0
_0x3D:
	__CPWRN 18,19,3
	BRGE _0x3E
;  {
;  SPDR = __NULL_INST;
	LDI  R30,LOW(255)
	OUT  0x2E,R30
;  while(!(SPSR & (1<<SPIF)));
_0x3F:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0x3F
;  ppBufferSlice[k] = SPDR;
	MOVW R26,R28
	ADIW R26,4
	ADD  R26,R18
	ADC  R27,R19
	IN   R30,0x2E
	ST   X,R30
;  }
	__ADDWRN 18,19,1
	RJMP _0x3D
_0x3E:
;SPCR = 0;
	LDI  R30,LOW(0)
	OUT  0x2C,R30
;SPSR = 0;
	OUT  0x2D,R30
;CS_SRAM_SET;
	SBI  0x5,0
;CS_LCD_RESET;
	CBI  0x5,2
;//First byte
;#asm
{
ldi r20,0b1001011
out 0x5,r20
SBI  0x5,5
CBI  0x5,5
}
;SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
	LDI  R30,LOW(80)
	OUT  0x2C,R30
;SPSR = (1<<SPI2X);
	LDI  R30,LOW(1)
	OUT  0x2D,R30
;SPDR = ppBufferSlice[0];
	LDD  R30,Y+4
	OUT  0x2E,R30
;while(!(SPSR & (1<<SPIF)));
_0x42:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0x42
;SPCR = 0;
	LDI  R30,LOW(0)
	OUT  0x2C,R30
;SPSR = 0;
	OUT  0x2D,R30
;//Second byte
;#asm
{
ldi r20,0b1001011
out 0x5,r20
SBI  0x5,5
CBI  0x5,5
}
;SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
	LDI  R30,LOW(80)
	OUT  0x2C,R30
;SPSR = (1<<SPI2X);
	LDI  R30,LOW(1)
	OUT  0x2D,R30
;SPDR = ppBufferSlice[1];
	LDD  R30,Y+5
	OUT  0x2E,R30
;while(!(SPSR & (1<<SPIF)));
_0x45:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0x45
;SPCR = 0;
	LDI  R30,LOW(0)
	OUT  0x2C,R30
;SPSR = 0;
	OUT  0x2D,R30
;//Third byte
;#asm
{
ldi r20,0b1001011
out 0x5,r20
SBI  0x5,5
CBI  0x5,5
}
;SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
	LDI  R30,LOW(80)
	OUT  0x2C,R30
;SPSR = (1<<SPI2X);
	LDI  R30,LOW(1)
	OUT  0x2D,R30
;SPDR = ppBufferSlice[2];
	LDD  R30,Y+6
	OUT  0x2E,R30
;while(!(SPSR & (1<<SPIF)));
_0x48:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0x48
;SPCR = 0;
	LDI  R30,LOW(0)
	OUT  0x2C,R30
;SPSR = 0;
	OUT  0x2D,R30
;        }
	__ADDWRN 16,17,1
	JMP  _0x31
_0x32:
;CS_LCD_SET;
	SBI  0x5,2
;}
	CALL __LOADLOCR4
	RJMP _0x20C002A
; .FEND
;
;void nlcd_Clear(int color)
;{
_nlcd_Clear:
; .FSTART _nlcd_Clear
;int i,j=0;
;unsigned char ppBufferSlice[3];
;ppBufferSlice[0] = color >> 4;
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,3
	CALL __SAVELOCR4
;	color -> Y+7
;	i -> R16,R17
;	j -> R18,R19
;	ppBufferSlice -> Y+4
	__GETWRN 18,19,0
	LDD  R30,Y+7
	LDD  R31,Y+7+1
	CALL __ASRW4
	STD  Y+4,R30
;ppBufferSlice[1] = ((color ) << 4) | ((color >> 8));
	LDD  R30,Y+7
	SWAP R30
	ANDI R30,0xF0
	MOV  R26,R30
	LDD  R30,Y+7
	LDD  R31,Y+7+1
	CALL __ASRW8
	OR   R30,R26
	STD  Y+5,R30
;ppBufferSlice[2] = color;
	LDD  R30,Y+7
	STD  Y+6,R30
;        for(i=0;i < 8713;i++)
	__GETWRN 16,17,0
_0x4C:
	__CPWRN 16,17,8713
	BRGE _0x4D
;		{
;CS_SRAM_RESET;
	CBI  0x5,0
;SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
	LDI  R30,LOW(80)
	OUT  0x2C,R30
;SPSR = (1<<SPI2X);
	LDI  R30,LOW(1)
	OUT  0x2D,R30
;SPDR = __WRITE_INST;
	LDI  R30,LOW(2)
	OUT  0x2E,R30
;while(!(SPSR & (1<<SPIF)));
_0x4E:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0x4E
;SPDR = (i*3)>>8;
	MOVW R30,R16
	LDI  R26,LOW(3)
	LDI  R27,HIGH(3)
	CALL __MULW12
	CALL __ASRW8
	OUT  0x2E,R30
;while(!(SPSR & (1<<SPIF)));
_0x51:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0x51
;SPDR = i*3;
	LDI  R26,LOW(3)
	MULS R16,R26
	MOVW R30,R0
	OUT  0x2E,R30
;while(!(SPSR & (1<<SPIF)));
_0x54:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0x54
;  for(j=0; j<3; j++)
	__GETWRN 18,19,0
_0x58:
	__CPWRN 18,19,3
	BRGE _0x59
;  {
;SPDR = ppBufferSlice[j];
	MOVW R26,R28
	ADIW R26,4
	ADD  R26,R18
	ADC  R27,R19
	LD   R30,X
	OUT  0x2E,R30
;while(!(SPSR & (1<<SPIF)));
_0x5A:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0x5A
;  }
	__ADDWRN 18,19,1
	RJMP _0x58
_0x59:
;SPCR = 0;
	LDI  R30,LOW(0)
	OUT  0x2C,R30
;SPSR = 0;
	OUT  0x2D,R30
;
;CS_SRAM_SET;
	SBI  0x5,0
;        }
	__ADDWRN 16,17,1
	RJMP _0x4C
_0x4D:
;}
	CALL __LOADLOCR4
	RJMP _0x20C0025
; .FEND
;
;//*******************************************************************************************************
;//	Имя: 		 nlcd_Box(unsigned char x0, unsigned char y0, unsigned char x1, unsigned char y1, unsigned char fill, int colo ...
;// 	Описание:    Рисует прямоугольник из координаты x0, y0 в координату x1, y1 с заливкой или нет, цветом color
;//           	 nlcd_Line(x0, y0, x1, y1, fill, color)
;//	Параметры:   x:     позиция 0-131
;//			     y:     позиция 0-131
;//               fill:  1-с заливкой, 0-без заливки
;//               color: цвет (12-bit см. #define)
;//  Пример:		 nlcd_Box(20,30,40,50,1,RED);  // С заливкой
;//*******************************************************************************************************
;
;void nlcd_Box(unsigned char x0, unsigned char y0, unsigned char x1, unsigned char y1, unsigned char fill, int color,int  ...
;{
_nlcd_Box:
; .FSTART _nlcd_Box
;    unsigned char   xmin, xmax, ymin, ymax;
;    int   i = 0,j = 0;
;    unsigned char a = (color >> 4);
;    unsigned char b = ((color ) << 4) | ((color >> 8) );
;    unsigned char c = color;
;    unsigned char ab = (colorborder >> 4);
;    unsigned char bb = ((colorborder ) << 4) | ((colorborder >> 8) );
;    unsigned char cb = colorborder;
;    unsigned char pBufferSlice[3];
;    unsigned char pBufferSliceBorder[3];
;    pBufferSlice[0] = a;
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,14
	LDI  R30,LOW(0)
	STD  Y+12,R30
	STD  Y+13,R30
	CALL __SAVELOCR6
;	x0 -> Y+28
;	y0 -> Y+27
;	x1 -> Y+26
;	y1 -> Y+25
;	fill -> Y+24
;	color -> Y+22
;	colorborder -> Y+20
;	xmin -> R17
;	xmax -> R16
;	ymin -> R19
;	ymax -> R18
;	i -> R20,R21
;	j -> Y+18
;	a -> Y+17
;	b -> Y+16
;	c -> Y+15
;	ab -> Y+14
;	bb -> Y+13
;	cb -> Y+12
;	pBufferSlice -> Y+9
;	pBufferSliceBorder -> Y+6
	__GETWRN 20,21,0
	LDD  R30,Y+22
	LDD  R31,Y+22+1
	CALL __ASRW4
	STD  Y+17,R30
	LDD  R30,Y+22
	SWAP R30
	ANDI R30,0xF0
	MOV  R26,R30
	LDD  R30,Y+22
	LDD  R31,Y+22+1
	CALL __ASRW8
	OR   R30,R26
	STD  Y+16,R30
	LDD  R30,Y+22
	STD  Y+15,R30
	LDD  R30,Y+20
	LDD  R31,Y+20+1
	CALL __ASRW4
	STD  Y+14,R30
	LDD  R30,Y+20
	SWAP R30
	ANDI R30,0xF0
	MOV  R26,R30
	LDD  R30,Y+20
	LDD  R31,Y+20+1
	CALL __ASRW8
	OR   R30,R26
	STD  Y+13,R30
	LDD  R30,Y+20
	STD  Y+12,R30
	LDD  R30,Y+17
	STD  Y+9,R30
;    pBufferSlice[1] = b;
	LDD  R30,Y+16
	STD  Y+10,R30
;    pBufferSlice[2] = c;
	LDD  R30,Y+15
	STD  Y+11,R30
;    pBufferSliceBorder[0] = ab;
	LDD  R30,Y+14
	STD  Y+6,R30
;    pBufferSliceBorder[1] = bb;
	LDD  R30,Y+13
	STD  Y+7,R30
;    pBufferSliceBorder[2] = cb;
	LDD  R30,Y+12
	STD  Y+8,R30
;    if (fill == FILL)                          //  ******************************************************
	LDD  R26,Y+24
	CPI  R26,LOW(0x1)
	BREQ PC+2
	RJMP _0x5D
;    {                                          //  * Проверяем - будет прямоугольник с заливкой или нет  *               ...
;        xmin = (x0 <= x1) ? x0 : x1;          //  *                                                     *
	LDD  R30,Y+26
	LDD  R26,Y+28
	CP   R30,R26
	BRLO _0x5E
	LDD  R30,Y+28
	RJMP _0x5F
_0x5E:
	LDD  R30,Y+26
_0x5F:
	MOV  R17,R30
; 		xmax = (x0 > x1) ? x0 : x1;           //  *    Расчитываем максимум и минимум для X и Y         *
	LDD  R30,Y+26
	LDD  R26,Y+28
	CP   R30,R26
	BRSH _0x61
	LDD  R30,Y+28
	RJMP _0x62
_0x61:
	LDD  R30,Y+26
_0x62:
	MOV  R16,R30
;		ymin = (y0 <= y1) ? y0 : y1;          //  *******************************************************
	LDD  R30,Y+25
	LDD  R26,Y+27
	CP   R30,R26
	BRLO _0x64
	LDD  R30,Y+27
	RJMP _0x65
_0x64:
	LDD  R30,Y+25
_0x65:
	MOV  R19,R30
;		ymax = (y0 > y1) ? y0 : y1;
	LDD  R30,Y+25
	LDD  R26,Y+27
	CP   R30,R26
	BRSH _0x67
	LDD  R30,Y+27
	RJMP _0x68
_0x67:
	LDD  R30,Y+25
_0x68:
	MOV  R18,R30
;                                              //    *****************************************************
;  // Пишем в RAM
;  for( i = (((ymin)*RESRAM_X + xmin)*3);i < (((ymax)*RESRAM_X + xmax + 1)*3); i+=3*(RES_X)/2)
	LDI  R30,LOW(66)
	MUL  R30,R19
	MOVW R30,R0
	MOVW R26,R30
	CLR  R30
	ADD  R26,R17
	ADC  R27,R30
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	CALL __MULW12
	MOVW R20,R30
_0x6B:
	LDI  R30,LOW(66)
	MUL  R30,R18
	MOVW R30,R0
	MOVW R26,R30
	MOV  R30,R16
	LDI  R31,0
	ADD  R30,R26
	ADC  R31,R27
	ADIW R30,1
	LDI  R26,LOW(3)
	LDI  R27,HIGH(3)
	CALL __MULW12
	CP   R20,R30
	CPC  R21,R31
	BRGE _0x6C
;  {
;     for(j = i; j < i + 3*(xmax-xmin+1);j+=3)
	__PUTWSR 20,21,18
_0x6E:
	MOV  R26,R16
	CLR  R27
	MOV  R30,R17
	LDI  R31,0
	CALL __SWAPW12
	SUB  R30,R26
	SBC  R31,R27
	ADIW R30,1
	LDI  R26,LOW(3)
	LDI  R27,HIGH(3)
	CALL __MULW12
	ADD  R30,R20
	ADC  R31,R21
	LDD  R26,Y+18
	LDD  R27,Y+18+1
	CP   R26,R30
	CPC  R27,R31
	BRGE _0x6F
;     {
;        nlcd_WritePixelBuffer(j,&pBufferSlice[0],3);
	LDD  R30,Y+18
	LDD  R31,Y+18+1
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,11
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(3)
	LDI  R27,0
	CALL _nlcd_WritePixelBuffer
;     }
	LDD  R30,Y+18
	LDD  R31,Y+18+1
	ADIW R30,3
	STD  Y+18,R30
	STD  Y+18+1,R31
	RJMP _0x6E
_0x6F:
;  }
	__ADDWRN 20,21,198
	RJMP _0x6B
_0x6C:
;
;    }
;    if(fill == BORDERFILL)
_0x5D:
	LDD  R26,Y+24
	CPI  R26,LOW(0x2)
	BREQ PC+2
	RJMP _0x70
;    {
;        xmin = (x0 <= x1) ? x0 : x1;
	LDD  R30,Y+26
	LDD  R26,Y+28
	CP   R30,R26
	BRLO _0x71
	LDD  R30,Y+28
	RJMP _0x72
_0x71:
	LDD  R30,Y+26
_0x72:
	MOV  R17,R30
; 		xmax = (x0 > x1) ? x0 : x1;
	LDD  R30,Y+26
	LDD  R26,Y+28
	CP   R30,R26
	BRSH _0x74
	LDD  R30,Y+28
	RJMP _0x75
_0x74:
	LDD  R30,Y+26
_0x75:
	MOV  R16,R30
;		ymin = (y0 <= y1) ? y0 : y1;
	LDD  R30,Y+25
	LDD  R26,Y+27
	CP   R30,R26
	BRLO _0x77
	LDD  R30,Y+27
	RJMP _0x78
_0x77:
	LDD  R30,Y+25
_0x78:
	MOV  R19,R30
;		ymax = (y0 > y1) ? y0 : y1;
	LDD  R30,Y+25
	LDD  R26,Y+27
	CP   R30,R26
	BRSH _0x7A
	LDD  R30,Y+27
	RJMP _0x7B
_0x7A:
	LDD  R30,Y+25
_0x7B:
	MOV  R18,R30
;        // Пишем в RAM
;    for(i = (((ymin)*RESRAM_X + xmin)*3);i < (((ymin)*RESRAM_X + xmin)*3) + 3*(xmax-xmin+1);i+=3)
	LDI  R30,LOW(66)
	MUL  R30,R19
	MOVW R30,R0
	MOVW R26,R30
	CLR  R30
	ADD  R26,R17
	ADC  R27,R30
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	CALL __MULW12
	MOVW R20,R30
_0x7E:
	LDI  R30,LOW(66)
	MUL  R30,R19
	MOVW R30,R0
	MOVW R26,R30
	CLR  R30
	ADD  R26,R17
	ADC  R27,R30
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	CALL __MULW12
	MOVW R22,R30
	MOV  R26,R16
	CLR  R27
	MOV  R30,R17
	LDI  R31,0
	CALL __SWAPW12
	SUB  R30,R26
	SBC  R31,R27
	ADIW R30,1
	LDI  R26,LOW(3)
	LDI  R27,HIGH(3)
	CALL __MULW12
	ADD  R30,R22
	ADC  R31,R23
	CP   R20,R30
	CPC  R21,R31
	BRGE _0x7F
;     {
;        nlcd_WritePixelBuffer(i,&pBufferSliceBorder[0],3);
	ST   -Y,R21
	ST   -Y,R20
	MOVW R30,R28
	ADIW R30,8
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(3)
	LDI  R27,0
	CALL _nlcd_WritePixelBuffer
;     }
	__ADDWRN 20,21,3
	RJMP _0x7E
_0x7F:
;  for( i = (((ymin)*RESRAM_X + xmin)*3) + 3*(RES_X)/2;i < (((ymax)*RESRAM_X + xmax + 1)*3)-3*(RES_X)/2; i+=3*(RES_X)/2)
	LDI  R30,LOW(66)
	MUL  R30,R19
	MOVW R30,R0
	MOVW R26,R30
	CLR  R30
	ADD  R26,R17
	ADC  R27,R30
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	CALL __MULW12
	SUBI R30,LOW(-198)
	SBCI R31,HIGH(-198)
	MOVW R20,R30
_0x81:
	LDI  R30,LOW(66)
	MUL  R30,R18
	MOVW R30,R0
	MOVW R26,R30
	MOV  R30,R16
	LDI  R31,0
	ADD  R30,R26
	ADC  R31,R27
	ADIW R30,1
	LDI  R26,LOW(3)
	LDI  R27,HIGH(3)
	CALL __MULW12
	SUBI R30,LOW(198)
	SBCI R31,HIGH(198)
	CP   R20,R30
	CPC  R21,R31
	BRLT PC+2
	RJMP _0x82
;  {
;     for(j = i; j < i + 3*(xmax-xmin+1);j+=3)
	__PUTWSR 20,21,18
_0x84:
	MOV  R26,R16
	CLR  R27
	MOV  R30,R17
	LDI  R31,0
	CALL __SWAPW12
	SUB  R30,R26
	SBC  R31,R27
	ADIW R30,1
	LDI  R26,LOW(3)
	LDI  R27,HIGH(3)
	CALL __MULW12
	ADD  R30,R20
	ADC  R31,R21
	LDD  R26,Y+18
	LDD  R27,Y+18+1
	CP   R26,R30
	CPC  R27,R31
	BRGE _0x85
;     {
;        if(j == i || j == i + 3*(xmax-xmin+1) - 3)
	CP   R20,R26
	CPC  R21,R27
	BREQ _0x87
	MOV  R26,R16
	CLR  R27
	MOV  R30,R17
	LDI  R31,0
	CALL __SWAPW12
	SUB  R30,R26
	SBC  R31,R27
	ADIW R30,1
	LDI  R26,LOW(3)
	LDI  R27,HIGH(3)
	CALL __MULW12
	ADD  R30,R20
	ADC  R31,R21
	SBIW R30,3
	LDD  R26,Y+18
	LDD  R27,Y+18+1
	CP   R30,R26
	CPC  R31,R27
	BRNE _0x86
_0x87:
;        {
;        nlcd_WritePixelBuffer(j,&pBufferSliceBorder[0],3);
	LDD  R30,Y+18
	LDD  R31,Y+18+1
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,8
	RJMP _0x4D9
;        }
;        else
_0x86:
;        {
;        nlcd_WritePixelBuffer(j,&pBufferSlice[0],3);
	LDD  R30,Y+18
	LDD  R31,Y+18+1
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,11
_0x4D9:
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(3)
	LDI  R27,0
	CALL _nlcd_WritePixelBuffer
;        }
;     }
	LDD  R30,Y+18
	LDD  R31,Y+18+1
	ADIW R30,3
	STD  Y+18,R30
	STD  Y+18+1,R31
	RJMP _0x84
_0x85:
;  }
	__ADDWRN 20,21,198
	RJMP _0x81
_0x82:
;  for(i = (((ymin)*RESRAM_X + xmin)*3) + (ymax-ymin)*3*(RES_X)/2; i < (((ymin)*RESRAM_X + xmin)*3) + (ymax-ymin)*3*(RES_ ...
	LDI  R30,LOW(66)
	MUL  R30,R19
	MOVW R30,R0
	MOVW R26,R30
	CLR  R30
	ADD  R26,R17
	ADC  R27,R30
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	CALL __MULW12
	MOVW R22,R30
	MOV  R26,R18
	CLR  R27
	MOV  R30,R19
	LDI  R31,0
	SUB  R26,R30
	SBC  R27,R31
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	CALL __MULW12
	LDI  R26,LOW(132)
	LDI  R27,HIGH(132)
	CALL __MULW12
	MOVW R26,R30
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	CALL __DIVW21
	ADD  R30,R22
	ADC  R31,R23
	MOVW R20,R30
_0x8B:
	LDI  R30,LOW(66)
	MUL  R30,R19
	MOVW R30,R0
	MOVW R26,R30
	CLR  R30
	ADD  R26,R17
	ADC  R27,R30
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	CALL __MULW12
	MOVW R22,R30
	MOV  R26,R18
	CLR  R27
	MOV  R30,R19
	LDI  R31,0
	SUB  R26,R30
	SBC  R27,R31
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	CALL __MULW12
	LDI  R26,LOW(132)
	LDI  R27,HIGH(132)
	CALL __MULW12
	MOVW R26,R30
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	CALL __DIVW21
	__ADDWRR 22,23,30,31
	MOV  R26,R16
	CLR  R27
	MOV  R30,R17
	LDI  R31,0
	CALL __SWAPW12
	SUB  R30,R26
	SBC  R31,R27
	ADIW R30,1
	LDI  R26,LOW(3)
	LDI  R27,HIGH(3)
	CALL __MULW12
	ADD  R30,R22
	ADC  R31,R23
	CP   R20,R30
	CPC  R21,R31
	BRGE _0x8C
;     {
;        nlcd_WritePixelBuffer(i,&pBufferSliceBorder[0],3);
	ST   -Y,R21
	ST   -Y,R20
	MOVW R30,R28
	ADIW R30,8
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(3)
	LDI  R27,0
	CALL _nlcd_WritePixelBuffer
;     }
	__ADDWRN 20,21,3
	RJMP _0x8B
_0x8C:
;
;    }
;}
_0x70:
	CALL __LOADLOCR6
	ADIW R28,29
	RET
; .FEND
;
;//******************************************************************************
;//	Имя: 		 nlcd_Circle(unsigned char x0, unsigned char y0, unsigned char radius, int color)
;// 	Описание:    Рисует круг из координаты x0, y0, с радиусом и цветом color
;//           	 nlcd_Circle(x0, y0, radius, color)
;//	Параметры:   x:       позиция 0-131
;//			     y:       позиция 0-131
;//               radius:  в пикселях
;//               color: цвет (12-bit см. #define)
;//  Пример:		 nlcd_Circle(10,55,2,BLUE);
;//******************************************************************************
;/*void nlcd_Circle(unsigned char x0, unsigned char y0, unsigned char radius, int color)
;{
;    int f = 1 - radius;
;	int ddF_x = 0;
;    int ddF_y = -2 * radius;
;    unsigned char x = 0;
;    unsigned char y = radius;
;
;    nlcd_Pixel(x0, y0 + radius, color);
;    nlcd_Pixel(x0, y0 - radius, color);
;    nlcd_Pixel(x0 + radius, y0, color);
;    nlcd_Pixel(x0 - radius, y0, color);
;
;    while (x < y)
;	{
;        if (f >= 0)
;		{
;
;            y--;
;            ddF_y += 2;
;            f += ddF_y;
;        }
;
;    x++;
;    ddF_x += 2;
;    f += ddF_x + 1;
;
;    nlcd_Pixel(x0 + x, y0 + y, color);
;    nlcd_Pixel(x0 - x, y0 + y, color);
;    nlcd_Pixel(x0 + x, y0 - y, color);
;    nlcd_Pixel(x0 - x, y0 - y, color);
;    nlcd_Pixel(x0 + y, y0 + x, color);
;    nlcd_Pixel(x0 - y, y0 + x, color);
;    nlcd_Pixel(x0 + y, y0 - x, color);
;    nlcd_Pixel(x0 - y, y0 - x, color);
;
;    }
;}      */
;
;//******************************************************************************
;//	Имя: 		nlcd_Char(char c, unsigned char x, unsigned char y, int fColor, int bColor)
;// 	Описание:
;//	Параметры:
;//  Пример:
;//******************************************************************************
;void nlcd_Char(char c, unsigned char y, unsigned char x, int fColor, int bColor)
;{
_nlcd_Char:
; .FSTART _nlcd_Char
;   int    i;
;   int    j;
;   unsigned char   nCols;
;   unsigned char  nRows;
;   unsigned char  nBytes;
;   unsigned char   PixelRow;
;   unsigned char   Mask;
;   unsigned int   Word0, Word1;
;   unsigned char *pFont,   *pChar;
;   unsigned char a;
;    unsigned char b;
;    unsigned char d;
;    unsigned char pBufferSlice[3];
;
;   pFont = (unsigned char *)Nokia6610_fnt8x8;
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,17
	CALL __SAVELOCR6
;	c -> Y+29
;	y -> Y+28
;	x -> Y+27
;	fColor -> Y+25
;	bColor -> Y+23
;	i -> R16,R17
;	j -> R18,R19
;	nCols -> R21
;	nRows -> R20
;	nBytes -> Y+22
;	PixelRow -> Y+21
;	Mask -> Y+20
;	Word0 -> Y+18
;	Word1 -> Y+16
;	*pFont -> Y+14
;	*pChar -> Y+12
;	a -> Y+11
;	b -> Y+10
;	d -> Y+9
;	pBufferSlice -> Y+6
	LDI  R30,LOW(_Nokia6610_fnt8x8*2)
	LDI  R31,HIGH(_Nokia6610_fnt8x8*2)
	STD  Y+14,R30
	STD  Y+14+1,R31
;
;   nCols = pgm_read_byte(pFont);
	LPM  R21,Z
;
;   nRows = pgm_read_byte(pFont + 1);
	ADIW R30,1
	LPM  R20,Z
;
;   nBytes = pgm_read_byte(pFont + 2);
	LDD  R30,Y+14
	LDD  R31,Y+14+1
	ADIW R30,2
	LPM  R0,Z
	STD  Y+22,R0
;
;   pChar = pFont + (nBytes * (c - 0x1F));
	LDD  R26,Y+22
	CLR  R27
	LDD  R30,Y+29
	LDI  R31,0
	SBIW R30,31
	CALL __MULW12
	LDD  R26,Y+14
	LDD  R27,Y+14+1
	ADD  R30,R26
	ADC  R31,R27
	STD  Y+12,R30
	STD  Y+12+1,R31
;
;   for (i = 0; i<nRows; i++) // for 2x2 Box-Pixels !!!
	__GETWRN 16,17,0
_0x8E:
	MOV  R30,R20
	MOVW R26,R16
	LDI  R31,0
	CP   R26,R30
	CPC  R27,R31
	BRLT PC+2
	RJMP _0x8F
;   {
;      PixelRow = pgm_read_byte(pChar++);
	LDD  R30,Y+12
	LDD  R31,Y+12+1
	LPM  R0,Z+
	STD  Y+12,R30
	STD  Y+12+1,R31
	STD  Y+21,R0
;      Mask = 0x80;
	LDI  R30,LOW(128)
	STD  Y+20,R30
;      for (j = 0; j < nCols/2; j++)
	__GETWRN 18,19,0
_0x91:
	MOV  R26,R21
	LDI  R27,0
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	CALL __DIVW21
	CP   R18,R30
	CPC  R19,R31
	BRLT PC+2
	RJMP _0x92
;	  {
;         if ((PixelRow & Mask) == 0)
	LDD  R30,Y+20
	LDD  R26,Y+21
	AND  R30,R26
	BRNE _0x93
;         Word0 = bColor;
	LDD  R30,Y+23
	LDD  R31,Y+23+1
	RJMP _0x4DA
;         else
_0x93:
;         Word0 = fColor;
	LDD  R30,Y+25
	LDD  R31,Y+25+1
_0x4DA:
	STD  Y+18,R30
	STD  Y+18+1,R31
;         Mask = Mask >> 1;
	LDD  R30,Y+20
	LSR  R30
	STD  Y+20,R30
;         if ((PixelRow & Mask) == 0)
	LDD  R26,Y+21
	AND  R30,R26
	BRNE _0x95
;         Word1 = bColor;
	LDD  R30,Y+23
	LDD  R31,Y+23+1
	RJMP _0x4DB
;         else
_0x95:
;         Word1 = fColor;
	LDD  R30,Y+25
	LDD  R31,Y+25+1
_0x4DB:
	STD  Y+16,R30
	STD  Y+16+1,R31
;    a = (Word0 >> 4);
	LDD  R30,Y+18
	LDD  R31,Y+18+1
	CALL __LSRW4
	STD  Y+11,R30
;    b = ((Word0 ) << 4) | ((Word1 >> 8) );
	LDD  R30,Y+18
	SWAP R30
	ANDI R30,0xF0
	MOV  R26,R30
	LDD  R30,Y+17
	ANDI R31,HIGH(0x0)
	OR   R30,R26
	STD  Y+10,R30
;    d = Word1;
	LDD  R30,Y+16
	STD  Y+9,R30
;    pBufferSlice[0] = a;
	LDD  R30,Y+11
	STD  Y+6,R30
;    pBufferSlice[1] = b;
	LDD  R30,Y+10
	STD  Y+7,R30
;    pBufferSlice[2] = d;
	LDD  R30,Y+9
	STD  Y+8,R30
;  // Пишем в RAM
;   nlcd_WritePixelBuffer(((y+i)*3*(RESRAM_X) + 3*(j + x/2)),&pBufferSlice[0],3);
	LDD  R30,Y+28
	LDI  R31,0
	ADD  R30,R16
	ADC  R31,R17
	LDI  R26,LOW(3)
	LDI  R27,HIGH(3)
	CALL __MULW12
	LDI  R26,LOW(66)
	LDI  R27,HIGH(66)
	CALL __MULW12
	MOVW R22,R30
	LDD  R26,Y+27
	LDI  R27,0
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	CALL __DIVW21
	ADD  R30,R18
	ADC  R31,R19
	LDI  R26,LOW(3)
	LDI  R27,HIGH(3)
	CALL __MULW12
	ADD  R30,R22
	ADC  R31,R23
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,8
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(3)
	LDI  R27,0
	CALL _nlcd_WritePixelBuffer
;         Mask = Mask >> 1;
	LDD  R30,Y+20
	LSR  R30
	STD  Y+20,R30
;      }
	__ADDWRN 18,19,1
	RJMP _0x91
_0x92:
;   }
	__ADDWRN 16,17,1
	RJMP _0x8E
_0x8F:
;}
	CALL __LOADLOCR6
	ADIW R28,30
	RET
; .FEND
;
;//******************************************************************************
;//	Имя: 		nlcd_String(char *pString, unsigned char x, unsigned char  y,  int fColor, int bColor)
;// 	Описание:
;//	Параметры:  x:       позиция 0-131
;//			    y:       позиция 0-131
;//              fColor:  цвет (12-bit см. #define)
;//              bColor:  цвет (12-bit см. #define)
;//  Пример:		nlcd_String("Hello",40,12,WHITE,BLACK);
;//******************************************************************************
;void nlcd_String(char *pString, unsigned char x, unsigned char  y,  int fColor, int bColor)
;{
_nlcd_String:
; .FSTART _nlcd_String
;   while (*pString != 0x00)
	ST   -Y,R27
	ST   -Y,R26
;	*pString -> Y+6
;	x -> Y+5
;	y -> Y+4
;	fColor -> Y+2
;	bColor -> Y+0
_0x97:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LD   R30,X
	CPI  R30,0
	BREQ _0x99
;   {
;      nlcd_Char(*pString++, x, y, fColor, bColor);
	LD   R30,X+
	STD  Y+6,R26
	STD  Y+6+1,R27
	ST   -Y,R30
	LDD  R30,Y+6
	ST   -Y,R30
	LDD  R30,Y+6
	ST   -Y,R30
	LDD  R30,Y+5
	LDD  R31,Y+5+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R26,Y+5
	LDD  R27,Y+5+1
	RCALL _nlcd_Char
;      y=y+8;
	LDD  R30,Y+4
	SUBI R30,-LOW(8)
	STD  Y+4,R30
;      if (x > 131) break;
	LDD  R26,Y+5
	CPI  R26,LOW(0x84)
	BRLO _0x97
;   }
_0x99:
;}
_0x20C002B:
	ADIW R28,8
	RET
; .FEND
;
;#include "FatFS/mmc.c"
;/*-----------------------------------------------------------------------*/
;/* MMCv3/SDv1/SDv2 (in SPI mode) control module                          */
;/*-----------------------------------------------------------------------*/
;/*
;/  Copyright (C) 2014, ChaN, all right reserved.
;/
;/ * This software is a free software and there is NO WARRANTY.
;/ * No restriction on use. You can use, modify and redistribute it for
;/   personal, non-profit or commercial products UNDER YOUR RESPONSIBILITY.
;/ * Redistributions of source code must retain the above copyright notice.
;/
;/-------------------------------------------------------------------------*/
;
;#include <io.h>
;#include "diskio.h"
;#include "spi_2.c"
;//***************************************************************************
;//
;//  Author(s)...: Pashgan    http://ChipEnable.Ru
;//
;//  Target(s)...: Mega
;//
;//  Compiler....:
;//
;//  Description.: Драйвер SPI
;//
;//  Data........: 26.07.13
;//
;//***************************************************************************
;#include "spi_2.h"
;	data -> Y+0
;
;
;/*инициализация SPI*/
;void SPI_Init(BYTE hs)
;{
_SPI_Init:
; .FSTART _SPI_Init
;  /*настройка портов ввода-вывода
;  все выводы, кроме MISO выходы*/
;// SPI_DDRXX |= (1<<SPI_MOSI)|(1<<SPI_SCK);
; // SPI_DDRXX &= ~(1<<SPI_MISO);
; SPI_DDRX |= (1<<SPI_SS);
	ST   -Y,R26
;	hs -> Y+0
	SBI  0x7,3
;
; // SPI_PORTXX |= (1<<SPI_MOSI)|(1<<SPI_SCK)|(1<<SPI_MISO);
;  SPI_PORTX |= (1<<SPI_SS);
	SBI  0x8,3
;
;  /*разрешение spi,старший бит вперед,мастер, режим 0*/
; if(!hs)
	LD   R30,Y
	CPI  R30,0
	BRNE _0xA2
; {
; SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(1<<SPR0);
	LDI  R30,LOW(81)
	OUT  0x2C,R30
; SPSR = (0<<SPI2X);
	LDI  R30,LOW(0)
	RJMP _0x4DC
; }
; else
_0xA2:
; {
; SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);
	LDI  R30,LOW(80)
	OUT  0x2C,R30
; SPSR = (1<<SPI2X);
	LDI  R30,LOW(1)
_0x4DC:
	OUT  0x2D,R30
; }
;}
	RJMP _0x20C0026
; .FEND
;
;void SPI_Release(void)
;{
_SPI_Release:
; .FSTART _SPI_Release
;  SPCR = 0;
	LDI  R30,LOW(0)
	OUT  0x2C,R30
;  SPSR = 0;
	OUT  0x2D,R30
;}
	RET
; .FEND
;
;/*отослать байт данных по SPI*/
;void SPI_WriteByte(uint8_t data)
;{
;   SPDR = data;
;	data -> Y+0
;   while(!(SPSR & (1<<SPIF)));
;}
;
;/*получить байт данных по SPI*/
;uint8_t SPI_ReadByte(void)
;{
;   SPDR = 0xff;
;   while(!(SPSR & (1<<SPIF)));
;   return SPDR;
;}
;
;/*отослать и получить байт данных по SPI*/
;uint8_t SPI_WriteReadByte(uint8_t data)
;{
;   SPDR = data;
;	data -> Y+0
;   while(!(SPSR & (1<<SPIF)));
;   return SPDR;
;}
;
;/*отправить несколько байт данных по SPI*/
;void SPI_WriteArray(uint8_t num, uint8_t *data)
;{
;   while(num--){
;	num -> Y+2
;	*data -> Y+0
;      SPDR = *data++;
;      while(!(SPSR & (1<<SPIF)));
;   }
;}
;
;/*отправить и получить несколько байт данных по SPI*/
;void SPI_WriteReadArray(uint8_t num, uint8_t *data)
;{
;   while(num--){
;	num -> Y+2
;	*data -> Y+0
;      SPDR = *data;
;      while(!(SPSR & (1<<SPIF)));
;      *data++ = SPDR;
;   }
;}
;
;#define CT_MMC				0x01	/* MMC ver 3 */
;#define CT_SD1				0x02	/* SD ver 1 */
;#define CT_SD2				0x04	/* SD ver 2 */
;#define CT_SDC				(CT_SD1|CT_SD2)	/* SD */
;#define CT_BLOCK			0x08	/* Block addressing */
;
;
;/* Port controls  (Platform dependent) */
;#define CS_LOW()	SPI_EnableSS_m(SPI_SS)		/* CS=low */
;#define	CS_HIGH()	SPI_DisableSS_m(SPI_SS)			/* CS=high */
;//#define MMC_CD		(!(PINB & 0x10))	/* Card detected.   yes:true, no:false, default:true */
;//#define MMC_WP		(PINB & 0x20)		/* Write protected. yes:true, no:false, default:false */
;#define	FCLK_SLOW()	SPCR = 0x52		/* Set slow clock (F_CPU / 64) */
;#define	FCLK_FAST()	SPCR = 0x50		/* Set fast clock (F_CPU / 2) */
;#define	FCLK_STOP()	SPCR = 0		/* Set fast clock (F_CPU / 2) */
;
;#define SELECT()	SPI_EnableSS_m(SPI_SS)	/* CS = L */
;#define DESELECT()	SPI_DisableSS_m(SPI_SS)	/* CS = H */
;#define MMC_SEL	    SPI_StatSS_m(SPI_SS)   	/* CS status (true:CS == L) */
;#define FORWARD(d)	         		/* Data forwarding function (Console out in this example) */
;
;#define init_spi(hs)  SPI_Init(hs)    	/* Initialize SPI port (usi.S) */
;#define release_spi() SPI_Release()
;#define dly_100us() delay_us(100)	/* Delay 100 microseconds (usi.S) */
;#define xmit_spi(d) SPI_WriteByte_m(d) /* Send a byte to the MMC (usi.S) */
;#define rcv_spi()	SPI_ReadByte_i()   /* Send a 0xFF to the MMC and get the received byte (usi.S) */
;
;
;/*--------------------------------------------------------------------------
;
;   Module Private Functions
;
;---------------------------------------------------------------------------*/
;
;/* Definitions for MMC/SDC command */
;#define CMD0	(0x40+0)			/* GO_IDLE_STATE */
;#define CMD1	(0x40+1)			/* SEND_OP_COND (MMC) */
;#define	ACMD41	(0x40+0x80+41)	/* SEND_OP_COND (SDC) */
;#define CMD8	(0x40+8)			/* SEND_IF_COND */
;#define CMD9	(0x40+9)			/* SEND_CSD */
;#define CMD10	(0x40+10)		/* SEND_CID */
;#define CMD12	(0x40+12)		/* STOP_TRANSMISSION */
;#define ACMD13	(0x40+0x80+13)	/* SD_STATUS (SDC) */
;#define CMD16	(0x40+16)		/* SET_BLOCKLEN */
;#define CMD17	(0x40+17)		/* READ_SINGLE_BLOCK */
;#define CMD18	(0x40+18)		/* READ_MULTIPLE_BLOCK */
;#define CMD23	(0x40+23)		/* SET_BLOCK_COUNT (MMC) */
;#define	ACMD23	(0x40+0x80+23)	/* SET_WR_BLK_ERASE_COUNT (SDC) */
;#define CMD24	(0x40+24)		/* WRITE_BLOCK */
;#define CMD25	(0x40+25)		/* WRITE_MULTIPLE_BLOCK */
;#define CMD32	(0x40+32)		/* ERASE_ER_BLK_START */
;#define CMD33	(0x40+33)		/* ERASE_ER_BLK_END */
;#define CMD38	(0x40+38)		/* ERASE */
;#define CMD55	(0x40+55)		/* APP_CMD */
;#define CMD58	(0x40+58)		/* READ_OCR */
;
;
;static volatile
;DSTATUS Stat = STA_NOINIT;	/* Disk status */

	.DSEG
;
;static volatile
;BYTE Timer1, Timer2;	/* 100Hz decrement timer */
;
;static
;BYTE CardType;			/* Card type flags */
;
;
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Transmit/Receive data from/to MMC via SPI  (Platform dependent)       */
;/*-----------------------------------------------------------------------*/
;
;/* Exchange a byte */
;static
;BYTE xchg_spi (		/* Returns received data */
;	BYTE dat		/* Data to be sent */
;)
;{

	.CSEG
_xchg_spi_G000:
; .FSTART _xchg_spi_G000
;	SPDR = dat;
	ST   -Y,R26
;	dat -> Y+0
	LD   R30,Y
	OUT  0x2E,R30
;while(!(SPSR & (1<<SPIF)));
_0xBA:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0xBA
;	return SPDR;
	IN   R30,0x2E
	RJMP _0x20C0026
;}
; .FEND
;
;/* Send a data block fast */
;static
;void xmit_spi_multi (
;	const BYTE *p,	/* Data block to be sent */
;	UINT cnt		/* Size of data block (must be multiple of 2) */
;)
;{
_xmit_spi_multi_G000:
; .FSTART _xmit_spi_multi_G000
;	do {
	ST   -Y,R27
	ST   -Y,R26
;	*p -> Y+2
;	cnt -> Y+0
_0xBE:
;		SPDR = *p++; while(!(SPSR & (1<<SPIF)));
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	LD   R30,X+
	STD  Y+2,R26
	STD  Y+2+1,R27
	OUT  0x2E,R30
_0xC0:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0xC0
;		SPDR = *p++; while(!(SPSR & (1<<SPIF)));
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	LD   R30,X+
	STD  Y+2,R26
	STD  Y+2+1,R27
	OUT  0x2E,R30
_0xC3:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0xC3
;	} while (cnt -= 2);
	LD   R30,Y
	LDD  R31,Y+1
	SBIW R30,2
	ST   Y,R30
	STD  Y+1,R31
	BRNE _0xBE
;}
	RJMP _0x20C0022
; .FEND
;
;/* Receive a data block fast */
;static
;void rcvr_spi_multi (
;	BYTE *p,	/* Data buffer */
;	UINT cnt	/* Size of data block (must be multiple of 2) */
;)
;{
_rcvr_spi_multi_G000:
; .FSTART _rcvr_spi_multi_G000
;	do {
	ST   -Y,R27
	ST   -Y,R26
;	*p -> Y+2
;	cnt -> Y+0
_0xC7:
;		SPDR = 0xFF; while(!(SPSR & (1<<SPIF))); *p++ = SPDR;
	LDI  R30,LOW(255)
	OUT  0x2E,R30
_0xC9:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0xC9
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	ADIW R26,1
	STD  Y+2,R26
	STD  Y+2+1,R27
	SBIW R26,1
	IN   R30,0x2E
	ST   X,R30
;		SPDR = 0xFF; while(!(SPSR & (1<<SPIF))); *p++ = SPDR;
	LDI  R30,LOW(255)
	OUT  0x2E,R30
_0xCC:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0xCC
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	ADIW R26,1
	STD  Y+2,R26
	STD  Y+2+1,R27
	SBIW R26,1
	IN   R30,0x2E
	ST   X,R30
;	} while (cnt -= 2);
	LD   R30,Y
	LDD  R31,Y+1
	SBIW R30,2
	ST   Y,R30
	STD  Y+1,R31
	BRNE _0xC7
;}
	RJMP _0x20C0022
; .FEND
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Wait for card ready                                                   */
;/*-----------------------------------------------------------------------*/
;
;static
;int wait_ready (	/* 1:Ready, 0:Timeout */
;	UINT wt			/* Timeout [ms] */
;)
;{
_wait_ready_G000:
; .FSTART _wait_ready_G000
;	BYTE d;
;
;
;	WORD n = wt;
;	do
	ST   -Y,R27
	ST   -Y,R26
	CALL __SAVELOCR4
;	wt -> Y+4
;	d -> R17
;	n -> R18,R19
	__GETWRS 18,19,4
_0xD0:
;    {
;	    d = xchg_spi(0xFF);
	LDI  R26,LOW(255)
	RCALL _xchg_spi_G000
	MOV  R17,R30
;    }
;	while (d != 0xFF && --wt);
	CPI  R17,255
	BREQ _0xD2
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	SBIW R30,1
	STD  Y+4,R30
	STD  Y+4+1,R31
	BRNE _0xD3
_0xD2:
	RJMP _0xD1
_0xD3:
	RJMP _0xD0
_0xD1:
;
;	return (d == 0xFF) ? 1 : 0;
	MOV  R26,R17
	LDI  R27,0
	CPI  R26,LOW(0xFF)
	LDI  R30,HIGH(0xFF)
	CPC  R27,R30
	BRNE _0xD4
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	RJMP _0xD5
_0xD4:
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
_0xD5:
	CALL __LOADLOCR4
	ADIW R28,6
	RET
;}
; .FEND
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Deselect the card and release SPI bus                                 */
;/*-----------------------------------------------------------------------*/
;
;static
;void deselect (void)
;{
_deselect_G000:
; .FSTART _deselect_G000
;	CS_HIGH();
	SBI  0x8,3
;	xchg_spi(0xFF);
	LDI  R26,LOW(255)
	RCALL _xchg_spi_G000
;}
	RET
; .FEND
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Select the card and wait for ready                                    */
;/*-----------------------------------------------------------------------*/
;
;static
;int select (void)	/* 1:Successful, 0:Timeout */
;{
_select_G000:
; .FSTART _select_G000
;	CS_LOW();		/* Set CS# low */
	CBI  0x8,3
;	xchg_spi(0xFF);	/* Dummy clock (force DO enabled) */
	LDI  R26,LOW(255)
	RCALL _xchg_spi_G000
;    delay_ms(10);
	LDI  R26,LOW(10)
	LDI  R27,0
	CALL _delay_ms
;    wait_ready(500);
	LDI  R26,LOW(500)
	LDI  R27,HIGH(500)
	RCALL _wait_ready_G000
;     return 1;	/* Wait for card ready */
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	RET
;   // PORTD.0 = 1;
;	deselect();
	RCALL _deselect_G000
;	return 0;	/* Timeout */
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	RET
;}
; .FEND
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Receive a data packet from MMC                                        */
;/*-----------------------------------------------------------------------*/
;
;static
;int rcvr_datablock (
;	BYTE *buff,			/* Data buffer to store received data */
;	UINT btr			/* Byte count (must be multiple of 4) */
;)
;{
_rcvr_datablock_G000:
; .FSTART _rcvr_datablock_G000
;	BYTE token;
;    WORD n = 20;
;  //  release_spi();
;  //  init_spi(1);
;
;	do {							/* Wait for data packet in timeout of 200ms */
	ST   -Y,R27
	ST   -Y,R26
	CALL __SAVELOCR4
;	*buff -> Y+6
;	btr -> Y+4
;	token -> R17
;	n -> R18,R19
	__GETWRN 18,19,20
_0xD8:
;		token = rcv_spi();
	LDI  R30,LOW(255)
	OUT  0x2E,R30
_0x401109F:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0x401109F
	IN   R30,0x2E
	MOV  R17,R30
;        sprintf(terror,"error: %x",token);
	LDI  R30,LOW(_terror)
	LDI  R31,HIGH(_terror)
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1FN _0x0,0
	ST   -Y,R31
	ST   -Y,R30
	MOV  R30,R17
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __PUTPARD1
	LDI  R24,4
	CALL _sprintf
	ADIW R28,8
;	} while ((token == 0xFF) && --n);
	CPI  R17,255
	BRNE _0xDA
	__SUBWRN 18,19,1
	BRNE _0xDB
_0xDA:
	RJMP _0xD9
_0xDB:
	RJMP _0xD8
_0xD9:
;	if (token != 0xFE) return 0;	/* If not valid data token, retutn with error */
	CPI  R17,254
	BREQ _0xDC
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	CALL __LOADLOCR4
	RJMP _0x20C0021
;
;	rcvr_spi_multi(buff, btr);		/* Receive the data block into buffer */
_0xDC:
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	RCALL _rcvr_spi_multi_G000
;	xchg_spi(0xFF);					/* Discard CRC */
	LDI  R26,LOW(255)
	RCALL _xchg_spi_G000
;	xchg_spi(0xFF);
	LDI  R26,LOW(255)
	RCALL _xchg_spi_G000
;
;	return 1;						/* Return with success */
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	CALL __LOADLOCR4
	RJMP _0x20C0021
;}
; .FEND
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Send a data packet to MMC                                             */
;/*-----------------------------------------------------------------------*/
;
;#if	_USE_WRITE
;static
;int xmit_datablock (
;	const BYTE *buff,	/* 512 byte data block to be transmitted */
;	BYTE token			/* Data/Stop token */
;)
;{
_xmit_datablock_G000:
; .FSTART _xmit_datablock_G000
;	BYTE resp;
;
;
;	if (!wait_ready(500)) return 0;
	ST   -Y,R26
	ST   -Y,R17
;	*buff -> Y+2
;	token -> Y+1
;	resp -> R17
	LDI  R26,LOW(500)
	LDI  R27,HIGH(500)
	RCALL _wait_ready_G000
	SBIW R30,0
	BRNE _0xDD
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	LDD  R17,Y+0
	RJMP _0x20C0022
;
;	xchg_spi(token);					/* Xmit data token */
_0xDD:
	LDD  R26,Y+1
	RCALL _xchg_spi_G000
;	if (token != 0xFD) {	/* Is data token */
	LDD  R26,Y+1
	CPI  R26,LOW(0xFD)
	BREQ _0xDE
;		xmit_spi_multi(buff, 512);		/* Xmit the data block to the MMC */
	LDD  R30,Y+2
	LDD  R31,Y+2+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(512)
	LDI  R27,HIGH(512)
	RCALL _xmit_spi_multi_G000
;		xchg_spi(0xFF);					/* CRC (Dummy) */
	LDI  R26,LOW(255)
	RCALL _xchg_spi_G000
;		xchg_spi(0xFF);
	LDI  R26,LOW(255)
	RCALL _xchg_spi_G000
;		resp = xchg_spi(0xFF);			/* Reveive data response */
	LDI  R26,LOW(255)
	RCALL _xchg_spi_G000
	MOV  R17,R30
;		if ((resp & 0x1F) != 0x05)		/* If not accepted, return with error */
	ANDI R30,LOW(0x1F)
	CPI  R30,LOW(0x5)
	BREQ _0xDF
;			return 0;
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	LDD  R17,Y+0
	RJMP _0x20C0022
;	}
_0xDF:
;
;	return 1;
_0xDE:
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	LDD  R17,Y+0
	RJMP _0x20C0022
;}
; .FEND
;#endif
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Send a command packet to MMC                                          */
;/*-----------------------------------------------------------------------*/
;
;static
;BYTE send_cmd (		/* Returns R1 resp (bit7==1:Send failed) */
;	BYTE cmd,		/* Command index */
;	DWORD arg		/* Argument */
;)
;{
_send_cmd_G000:
; .FSTART _send_cmd_G000
;	BYTE n, res;
;	if (cmd & 0x80) {	/* ACMD<n> is the command sequense of CMD55-CMD<n> */
	CALL __PUTPARD2
	ST   -Y,R17
	ST   -Y,R16
;	cmd -> Y+6
;	arg -> Y+2
;	n -> R17
;	res -> R16
	LDD  R30,Y+6
	ANDI R30,LOW(0x80)
	BREQ _0xE0
;		cmd &= 0x7F;
	LDD  R30,Y+6
	ANDI R30,0x7F
	STD  Y+6,R30
;		res = send_cmd(CMD55, 0);
	LDI  R30,LOW(119)
	ST   -Y,R30
	__GETD2N 0x0
	RCALL _send_cmd_G000
	MOV  R16,R30
;		if (res > 1) return res;
	CPI  R16,2
	BRLO _0xE1
	RJMP _0x20C0029
;	}
_0xE1:
;
;	/* Select the card */
;	if (cmd != CMD12) {
_0xE0:
	LDD  R26,Y+6
	CPI  R26,LOW(0x4C)
	BREQ _0xE2
;		deselect();
	RCALL _deselect_G000
;		if (!select()) return 0xFF;
	RCALL _select_G000
	SBIW R30,0
	BRNE _0xE3
	LDI  R30,LOW(255)
	RJMP _0x20C0028
;	}
_0xE3:
;
;/* Send command packet */
;	xchg_spi(cmd);				/* Start + Command index */
_0xE2:
	LDD  R26,Y+6
	RCALL _xchg_spi_G000
;	xchg_spi((BYTE)(arg >> 24));		/* Argument[31..24] */
	__GETD2S 2
	LDI  R30,LOW(24)
	CALL __LSRD12
	MOV  R26,R30
	RCALL _xchg_spi_G000
;	xchg_spi((BYTE)(arg >> 16));		/* Argument[23..16] */
	__GETD1S 2
	CALL __LSRD16
	MOV  R26,R30
	RCALL _xchg_spi_G000
;	xchg_spi((BYTE)(arg >> 8));			/* Argument[15..8] */
	__GETD2S 2
	LDI  R30,LOW(8)
	CALL __LSRD12
	MOV  R26,R30
	RCALL _xchg_spi_G000
;	xchg_spi((BYTE)arg);				/* Argument[7..0] */
	LDD  R26,Y+2
	RCALL _xchg_spi_G000
;	n = 0x01;							/* Dummy CRC + Stop */
	LDI  R17,LOW(1)
;	if (cmd == CMD0) n = 0x95;			/* Valid CRC for CMD0(0) + Stop */
	LDD  R26,Y+6
	CPI  R26,LOW(0x40)
	BRNE _0xE4
	LDI  R17,LOW(149)
;	if (cmd == CMD8) n = 0x87;			/* Valid CRC for CMD8(0x1AA) Stop */
_0xE4:
	LDD  R26,Y+6
	CPI  R26,LOW(0x48)
	BRNE _0xE5
	LDI  R17,LOW(135)
;	xchg_spi(n);
_0xE5:
	MOV  R26,R17
	RCALL _xchg_spi_G000
;
;	/* Receive command response */
;	if (cmd == CMD12) xchg_spi(0xFF);		/* Skip a stuff byte when stop reading */
	LDD  R26,Y+6
	CPI  R26,LOW(0x4C)
	BRNE _0xE6
	LDI  R26,LOW(255)
	RCALL _xchg_spi_G000
;	n = 10;								/* Wait for a valid response in timeout of 10 attempts */
_0xE6:
	LDI  R17,LOW(10)
;	do
_0xE8:
;		res = xchg_spi(0xFF);
	LDI  R26,LOW(255)
	RCALL _xchg_spi_G000
	MOV  R16,R30
;	while ((res & 0x80) && --n);
	SBRS R16,7
	RJMP _0xEA
	SUBI R17,LOW(1)
	BRNE _0xEB
_0xEA:
	RJMP _0xE9
_0xEB:
	RJMP _0xE8
_0xE9:
;	return res;			/* Return with the response value */
_0x20C0029:
	MOV  R30,R16
_0x20C0028:
	LDD  R17,Y+1
	LDD  R16,Y+0
_0x20C002A:
	ADIW R28,7
	RET
;}
; .FEND
;
;
;
;/*--------------------------------------------------------------------------
;
;   Public Functions
;
;---------------------------------------------------------------------------*/
;
;
;/*-----------------------------------------------------------------------*/
;/* Initialize Disk Drive                                                 */
;/*-----------------------------------------------------------------------*/
;
;DSTATUS disk_initialize (
;	BYTE pdrv		/* Physical drive nmuber (0) */
;)
;{
_disk_initialize:
; .FSTART _disk_initialize
;		BYTE n, cmd, ty, ocr[4];
;	UINT tmr;
;
;
;	if (pdrv) return STA_NOINIT;		/* Supports only single drive */
	ST   -Y,R26
	SBIW R28,4
	CALL __SAVELOCR6
;	pdrv -> Y+10
;	n -> R17
;	cmd -> R16
;	ty -> R19
;	ocr -> Y+6
;	tmr -> R20,R21
	LDD  R30,Y+10
	CPI  R30,0
	BREQ _0xEC
	LDI  R30,LOW(1)
	RJMP _0x20C0027
;	//power_off();						/* Turn off the socket power to reset the card */
;	//if (Stat & STA_NODISK) return Stat;	/* No card in the socket */
;	//power_on();							/* Turn on the socket power */
;	//FCLK_SLOW();
;    init_spi(0);
_0xEC:
	LDI  R26,LOW(0)
	RCALL _SPI_Init
;	for (n = 10; n; n--) xchg_spi(0xFF);	/* 80 dummy clocks */
	LDI  R17,LOW(10)
_0xEE:
	CPI  R17,0
	BREQ _0xEF
	LDI  R26,LOW(255)
	RCALL _xchg_spi_G000
	SUBI R17,1
	RJMP _0xEE
_0xEF:
	LDI  R19,LOW(0)
;		if (send_cmd(CMD0, 0) == 1) {			/* Enter Idle state */
	LDI  R30,LOW(64)
	ST   -Y,R30
	__GETD2N 0x0
	RCALL _send_cmd_G000
	CPI  R30,LOW(0x1)
	BREQ PC+2
	RJMP _0xF0
;		if (send_cmd(CMD8, 0x1AA) == 1) {	/* SDv2 */
	LDI  R30,LOW(72)
	ST   -Y,R30
	__GETD2N 0x1AA
	RCALL _send_cmd_G000
	CPI  R30,LOW(0x1)
	BREQ PC+2
	RJMP _0xF1
;			for (n = 0; n < 4; n++)
	LDI  R17,LOW(0)
_0xF3:
	CPI  R17,4
	BRSH _0xF4
;            {
;             ocr[n] = rcv_spi();
	MOV  R30,R17
	LDI  R31,0
	MOVW R26,R28
	ADIW R26,6
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(255)
	OUT  0x2E,R30
_0x801109F:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0x801109F
	IN   R30,0x2E
	ST   X,R30
;             }		/* Get trailing return value of R7 resp */
	SUBI R17,-1
	RJMP _0xF3
_0xF4:
;			if (ocr[2] == 0x01 && ocr[3] == 0xAA) {			/* The card can work at vdd range of 2.7-3.6V */
	LDD  R26,Y+8
	CPI  R26,LOW(0x1)
	BRNE _0xF6
	LDD  R26,Y+9
	CPI  R26,LOW(0xAA)
	BREQ _0xF7
_0xF6:
	RJMP _0xF5
_0xF7:
;				for (tmr = 10000; tmr && send_cmd(ACMD41, 1UL << 30); tmr--) dly_100us();	/* Wait for leaving idle state (ACMD41 wit ...
	__GETWRN 20,21,10000
_0xF9:
	MOV  R0,R20
	OR   R0,R21
	BREQ _0xFB
	LDI  R30,LOW(233)
	ST   -Y,R30
	__GETD2N 0x40000000
	RCALL _send_cmd_G000
	CPI  R30,0
	BRNE _0xFC
_0xFB:
	RJMP _0xFA
_0xFC:
	__DELAY_USW 200
	__SUBWRN 20,21,1
	RJMP _0xF9
_0xFA:
	MOV  R0,R20
	OR   R0,R21
	BREQ _0xFE
	LDI  R30,LOW(122)
	ST   -Y,R30
	__GETD2N 0x0
	RCALL _send_cmd_G000
	CPI  R30,0
	BREQ _0xFF
_0xFE:
	RJMP _0xFD
_0xFF:
;					for (n = 0; n < 4; n++)
	LDI  R17,LOW(0)
_0x101:
	CPI  R17,4
	BRSH _0x102
;                    {
;                    ocr[n] = rcv_spi();
	MOV  R30,R17
	LDI  R31,0
	MOVW R26,R28
	ADIW R26,6
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(255)
	OUT  0x2E,R30
_0xC01109F:
	IN   R30,0x2D
	ANDI R30,LOW(0x80)
	BREQ _0xC01109F
	IN   R30,0x2E
	ST   X,R30
;                    }
	SUBI R17,-1
	RJMP _0x101
_0x102:
;					ty = (ocr[0] & 0x40) ? CT_SD2 | CT_BLOCK : CT_SD2;	/* SDv2 (HC or SC) */
	LDD  R30,Y+6
	ANDI R30,LOW(0x40)
	BREQ _0x103
	LDI  R30,LOW(12)
	RJMP _0x104
_0x103:
	LDI  R30,LOW(4)
_0x104:
	MOV  R19,R30
;				}
;			}
_0xFD:
;		} else {							/* SDv1 or MMCv3 */
_0xF5:
	RJMP _0x106
_0xF1:
;			if (send_cmd(ACMD41, 0) <= 1) 	{
	LDI  R30,LOW(233)
	ST   -Y,R30
	__GETD2N 0x0
	RCALL _send_cmd_G000
	CPI  R30,LOW(0x2)
	BRSH _0x107
;				ty = CT_SD1; cmd = ACMD41;	/* SDv1 */
	LDI  R19,LOW(2)
	LDI  R16,LOW(233)
;			} else {
	RJMP _0x108
_0x107:
;				ty = CT_MMC; cmd = CMD1;	/* MMCv3 */
	LDI  R19,LOW(1)
	LDI  R16,LOW(65)
;			}
_0x108:
;			for (tmr = 10000; tmr && send_cmd(cmd, 0); tmr--) dly_100us();	/* Wait for leaving idle state */
	__GETWRN 20,21,10000
_0x10A:
	MOV  R0,R20
	OR   R0,R21
	BREQ _0x10C
	ST   -Y,R16
	__GETD2N 0x0
	RCALL _send_cmd_G000
	CPI  R30,0
	BRNE _0x10D
_0x10C:
	RJMP _0x10B
_0x10D:
	__DELAY_USW 200
	__SUBWRN 20,21,1
	RJMP _0x10A
_0x10B:
	MOV  R0,R20
	OR   R0,R21
	BREQ _0x10F
	LDI  R30,LOW(80)
	ST   -Y,R30
	__GETD2N 0x200
	RCALL _send_cmd_G000
	CPI  R30,0
	BREQ _0x10E
_0x10F:
;				ty = 0;
	LDI  R19,LOW(0)
;		}
_0x10E:
_0x106:
;	}
;	CardType = ty;
_0xF0:
	STS  _CardType_G000,R19
;	deselect();
	RCALL _deselect_G000
;
;	if (ty) {			/* Initialization succeded */
	CPI  R19,0
	BREQ _0x111
;		Stat &= ~STA_NOINIT;		/* Clear STA_NOINIT */
	LDS  R30,_Stat_G000
	ANDI R30,0xFE
	STS  _Stat_G000,R30
;		release_spi();
	RCALL _SPI_Release
;	} else {			/* Initialization failed */
_0x111:
;		//power_off();
;	}
;
;	return Stat;
	LDS  R30,_Stat_G000
_0x20C0027:
	CALL __LOADLOCR6
	ADIW R28,11
	RET
;}
; .FEND
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Get Disk Status                                                       */
;/*-----------------------------------------------------------------------*/
;
;DSTATUS disk_status (
;	BYTE pdrv		/* Physical drive nmuber (0) */
;)
;{
_disk_status:
; .FSTART _disk_status
;	if (pdrv) return STA_NOINIT;	/* Supports only single drive */
	ST   -Y,R26
;	pdrv -> Y+0
	LD   R30,Y
	CPI  R30,0
	BREQ _0x113
	LDI  R30,LOW(1)
	RJMP _0x20C0026
;	return Stat;
_0x113:
	LDS  R30,_Stat_G000
_0x20C0026:
	ADIW R28,1
	RET
;}
; .FEND
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Read Sector(s)                                                        */
;/*-----------------------------------------------------------------------*/
;
;DRESULT disk_read (
;	BYTE pdrv,			/* Physical drive nmuber (0) */
;	BYTE *buff,			/* Pointer to the data buffer to store read data */
;	DWORD sector,		/* Start sector number (LBA) */
;	UINT count			/* Sector count (1..128) */
;)
;{
_disk_read:
; .FSTART _disk_read
;		BYTE cmd;
;    init_spi(1);
	ST   -Y,R27
	ST   -Y,R26
	ST   -Y,R17
;	pdrv -> Y+9
;	*buff -> Y+7
;	sector -> Y+3
;	count -> Y+1
;	cmd -> R17
	LDI  R26,LOW(1)
	RCALL _SPI_Init
;
;	if (pdrv || !count) return RES_PARERR;
	LDD  R30,Y+9
	CPI  R30,0
	BRNE _0x115
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	SBIW R30,0
	BRNE _0x114
_0x115:
	LDI  R30,LOW(4)
	LDD  R17,Y+0
	RJMP _0x20C0023
;	if (Stat & STA_NOINIT) return RES_NOTRDY;
_0x114:
	LDS  R30,_Stat_G000
	ANDI R30,LOW(0x1)
	BREQ _0x117
	LDI  R30,LOW(3)
	LDD  R17,Y+0
	RJMP _0x20C0023
;
;	if (!(CardType & CT_BLOCK)) sector *= 512;	/* Convert to byte address if needed */
_0x117:
	LDS  R30,_CardType_G000
	ANDI R30,LOW(0x8)
	BRNE _0x118
	__GETD1S 3
	__GETD2N 0x200
	CALL __MULD12U
	__PUTD1S 3
;
;	cmd = count > 1 ? CMD18 : CMD17;			/*  READ_MULTIPLE_BLOCK : READ_SINGLE_BLOCK */
_0x118:
	LDD  R26,Y+1
	LDD  R27,Y+1+1
	SBIW R26,2
	BRLO _0x119
	LDI  R30,LOW(82)
	RJMP _0x11A
_0x119:
	LDI  R30,LOW(81)
_0x11A:
	MOV  R17,R30
;	if (send_cmd(cmd, sector) == 0) {
	ST   -Y,R17
	__GETD2S 4
	RCALL _send_cmd_G000
	CPI  R30,0
	BRNE _0x11C
;		do {
_0x11E:
;			if (!rcvr_datablock(buff, 512)) break;
	LDD  R30,Y+7
	LDD  R31,Y+7+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(512)
	LDI  R27,HIGH(512)
	RCALL _rcvr_datablock_G000
	SBIW R30,0
	BREQ _0x11F
;			buff += 512;
	LDD  R30,Y+7
	LDD  R31,Y+7+1
	SUBI R30,LOW(-512)
	SBCI R31,HIGH(-512)
	STD  Y+7,R30
	STD  Y+7+1,R31
;		} while (--count);
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	SBIW R30,1
	STD  Y+1,R30
	STD  Y+1+1,R31
	BRNE _0x11E
_0x11F:
;		if (cmd == CMD18) send_cmd(CMD12, 0);	/* STOP_TRANSMISSION */
	CPI  R17,82
	BRNE _0x121
	LDI  R30,LOW(76)
	ST   -Y,R30
	__GETD2N 0x0
	RCALL _send_cmd_G000
;	}
_0x121:
;	deselect();
_0x11C:
	RCALL _deselect_G000
;    release_spi();
	RCALL _SPI_Release
;	return count ? RES_ERROR : RES_OK;
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	SBIW R30,0
	BREQ _0x122
	LDI  R30,LOW(1)
	RJMP _0x123
_0x122:
	LDI  R30,LOW(0)
_0x123:
	LDD  R17,Y+0
	RJMP _0x20C0023
;}
; .FEND
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Write Sector(s)                                                       */
;/*-----------------------------------------------------------------------*/
;
;#if _USE_WRITE
;DRESULT disk_write (
;	BYTE pdrv,			/* Physical drive nmuber (0) */
;	const BYTE *buff,	/* Pointer to the data to be written */
;	DWORD sector,		/* Start sector number (LBA) */
;	UINT count			/* Sector count (1..128) */
;)
;{
_disk_write:
; .FSTART _disk_write
;    init_spi(1);
	ST   -Y,R27
	ST   -Y,R26
;	pdrv -> Y+8
;	*buff -> Y+6
;	sector -> Y+2
;	count -> Y+0
	LDI  R26,LOW(1)
	RCALL _SPI_Init
;	if (pdrv || !count) return RES_PARERR;
	LDD  R30,Y+8
	CPI  R30,0
	BRNE _0x126
	LD   R30,Y
	LDD  R31,Y+1
	SBIW R30,0
	BRNE _0x125
_0x126:
	LDI  R30,LOW(4)
	RJMP _0x20C0025
;	if (Stat & STA_NOINIT) return RES_NOTRDY;
_0x125:
	LDS  R30,_Stat_G000
	ANDI R30,LOW(0x1)
	BREQ _0x128
	LDI  R30,LOW(3)
	RJMP _0x20C0025
;	if (Stat & STA_PROTECT) return RES_WRPRT;
_0x128:
	LDS  R30,_Stat_G000
	ANDI R30,LOW(0x4)
	BREQ _0x129
	LDI  R30,LOW(2)
	RJMP _0x20C0025
;
;	if (!(CardType & CT_BLOCK)) sector *= 512;	/* Convert to byte address if needed */
_0x129:
	LDS  R30,_CardType_G000
	ANDI R30,LOW(0x8)
	BRNE _0x12A
	__GETD1S 2
	__GETD2N 0x200
	CALL __MULD12U
	__PUTD1S 2
;
;	if (count == 1) {	/* Single block write */
_0x12A:
	LD   R26,Y
	LDD  R27,Y+1
	SBIW R26,1
	BRNE _0x12B
;		if ((send_cmd(CMD24, sector) == 0)	/* WRITE_BLOCK */
;           && xmit_datablock(buff, 0xFE))
	LDI  R30,LOW(88)
	ST   -Y,R30
	__GETD2S 3
	RCALL _send_cmd_G000
	CPI  R30,0
	BRNE _0x12D
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(254)
	RCALL _xmit_datablock_G000
	SBIW R30,0
	BRNE _0x12E
_0x12D:
	RJMP _0x12C
_0x12E:
;			count = 0;
	LDI  R30,LOW(0)
	STD  Y+0,R30
	STD  Y+0+1,R30
;	}
_0x12C:
;	else {				/* Multiple block write */
	RJMP _0x12F
_0x12B:
;		if (CardType & CT_SDC) send_cmd(ACMD23, count);
	LDS  R30,_CardType_G000
	ANDI R30,LOW(0x6)
	BREQ _0x130
	LDI  R30,LOW(215)
	ST   -Y,R30
	LDD  R26,Y+1
	LDD  R27,Y+1+1
	CLR  R24
	CLR  R25
	RCALL _send_cmd_G000
;		if (send_cmd(CMD25, sector) == 0) {	/* WRITE_MULTIPLE_BLOCK */
_0x130:
	LDI  R30,LOW(89)
	ST   -Y,R30
	__GETD2S 3
	RCALL _send_cmd_G000
	CPI  R30,0
	BRNE _0x131
;			do {
_0x133:
;				if (!xmit_datablock(buff, 0xFC)) break;
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(252)
	RCALL _xmit_datablock_G000
	SBIW R30,0
	BREQ _0x134
;				buff += 512;
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	SUBI R30,LOW(-512)
	SBCI R31,HIGH(-512)
	STD  Y+6,R30
	STD  Y+6+1,R31
;			} while (--count);
	LD   R30,Y
	LDD  R31,Y+1
	SBIW R30,1
	ST   Y,R30
	STD  Y+1,R31
	BRNE _0x133
_0x134:
;			if (!xmit_datablock(0, 0xFD))	/* STOP_TRAN token */
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(253)
	RCALL _xmit_datablock_G000
	SBIW R30,0
	BRNE _0x136
;				count = 1;
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	ST   Y,R30
	STD  Y+1,R31
;		}
_0x136:
;	}
_0x131:
_0x12F:
;	deselect();
	RCALL _deselect_G000
;    release_spi();
	RCALL _SPI_Release
;	return count ? RES_ERROR : RES_OK;
	LD   R30,Y
	LDD  R31,Y+1
	SBIW R30,0
	BREQ _0x137
	LDI  R30,LOW(1)
	RJMP _0x138
_0x137:
	LDI  R30,LOW(0)
_0x138:
_0x20C0025:
	ADIW R28,9
	RET
;}
; .FEND
;#endif
;
;
;/*-----------------------------------------------------------------------*/
;/* Miscellaneous Functions                                               */
;/*-----------------------------------------------------------------------*/
;
;#if _USE_IOCTL
;DRESULT disk_ioctl (
;	BYTE pdrv,		/* Physical drive nmuber (0) */
;	BYTE cmd,		/* Control code */
;	void *buff		/* Buffer to send/receive control data */
;)
;{
_disk_ioctl:
; .FSTART _disk_ioctl
;	DRESULT res;
;	BYTE n, csd[16], *ptr = buff;
;	DWORD csize;
;
;    init_spi(1);
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,20
	CALL __SAVELOCR4
;	pdrv -> Y+27
;	cmd -> Y+26
;	*buff -> Y+24
;	res -> R17
;	n -> R16
;	csd -> Y+8
;	*ptr -> R18,R19
;	csize -> Y+4
	__GETWRS 18,19,24
	LDI  R26,LOW(1)
	RCALL _SPI_Init
;	if (pdrv) return RES_PARERR;
	LDD  R30,Y+27
	CPI  R30,0
	BREQ _0x13A
	LDI  R30,LOW(4)
	RJMP _0x20C0024
;
;	res = RES_ERROR;
_0x13A:
	LDI  R17,LOW(1)
;
;	if (Stat & STA_NOINIT) return RES_NOTRDY;
	LDS  R30,_Stat_G000
	ANDI R30,LOW(0x1)
	BREQ _0x13B
	LDI  R30,LOW(3)
	RJMP _0x20C0024
;
;	switch (cmd) {
_0x13B:
	LDD  R30,Y+26
	LDI  R31,0
;	case CTRL_SYNC :		/* Make sure that no pending write process. Do not remove this or written sector might not left updat ...
	SBIW R30,0
	BRNE _0x13F
;		if (select()) res = RES_OK;
	RCALL _select_G000
	SBIW R30,0
	BREQ _0x140
	LDI  R17,LOW(0)
;		break;
_0x140:
	RJMP _0x13E
;
;	case GET_SECTOR_COUNT :	/* Get number of sectors on the disk (DWORD) */
_0x13F:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BREQ PC+2
	RJMP _0x141
;		if ((send_cmd(CMD9, 0) == 0) && rcvr_datablock(csd, 16)) {
	LDI  R30,LOW(73)
	ST   -Y,R30
	__GETD2N 0x0
	RCALL _send_cmd_G000
	CPI  R30,0
	BRNE _0x143
	MOVW R30,R28
	ADIW R30,8
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(16)
	LDI  R27,0
	RCALL _rcvr_datablock_G000
	SBIW R30,0
	BRNE _0x144
_0x143:
	RJMP _0x142
_0x144:
;			if ((csd[0] >> 6) == 1) {	/* SDC ver 2.00 */
	LDD  R26,Y+8
	LDI  R27,0
	LDI  R30,LOW(6)
	CALL __ASRW12
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x145
;				csize = csd[9] + ((WORD)csd[8] << 8) + ((DWORD)(csd[7] & 63) << 16) + 1;
	LDD  R26,Y+17
	LDI  R27,0
	LDI  R30,0
	LDD  R31,Y+16
	ADD  R26,R30
	ADC  R27,R31
	LDD  R30,Y+15
	LDI  R31,0
	ANDI R30,LOW(0x3F)
	ANDI R31,HIGH(0x3F)
	CALL __CWD1
	CALL __LSLD16
	CLR  R24
	CLR  R25
	CALL __ADDD12
	__ADDD1N 1
	__PUTD1S 4
;				*(DWORD*)buff = csize << 10;
	__GETD2S 4
	LDI  R30,LOW(10)
	RJMP _0x4DD
;			} else {					/* SDC ver 1.XX or MMC*/
_0x145:
;				n = (csd[5] & 15) + ((csd[10] & 128) >> 7) + ((csd[9] & 3) << 1) + 2;
	LDD  R30,Y+13
	ANDI R30,LOW(0xF)
	MOV  R26,R30
	LDD  R30,Y+18
	ANDI R30,LOW(0x80)
	LDI  R31,0
	CALL __ASRW3
	CALL __ASRW4
	ADD  R26,R30
	LDD  R30,Y+17
	ANDI R30,LOW(0x3)
	LSL  R30
	ADD  R30,R26
	SUBI R30,-LOW(2)
	MOV  R16,R30
;				csize = (csd[8] >> 6) + ((WORD)csd[7] << 2) + ((WORD)(csd[6] & 3) << 10) + 1;
	LDD  R26,Y+16
	LDI  R27,0
	LDI  R30,LOW(6)
	CALL __ASRW12
	MOVW R26,R30
	LDD  R30,Y+15
	LDI  R31,0
	CALL __LSLW2
	ADD  R26,R30
	ADC  R27,R31
	LDD  R30,Y+14
	LDI  R31,0
	ANDI R30,LOW(0x3)
	ANDI R31,HIGH(0x3)
	LSL  R30
	LSL  R30
	MOV  R31,R30
	LDI  R30,0
	ADD  R30,R26
	ADC  R31,R27
	ADIW R30,1
	CLR  R22
	CLR  R23
	__PUTD1S 4
;				*(DWORD*)buff = csize << (n - 9);
	MOV  R30,R16
	SUBI R30,LOW(9)
	__GETD2S 4
_0x4DD:
	CALL __LSLD12
	LDD  R26,Y+24
	LDD  R27,Y+24+1
	CALL __PUTDP1
;			}
;			res = RES_OK;
	LDI  R17,LOW(0)
;		}
;		break;
_0x142:
	RJMP _0x13E
;
;	case GET_BLOCK_SIZE :	/* Get erase block size in unit of sector (DWORD) */
_0x141:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BREQ PC+2
	RJMP _0x147
;		if (CardType & CT_SD2) {	/* SDv2? */
	LDS  R30,_CardType_G000
	ANDI R30,LOW(0x4)
	BREQ _0x148
;			if (send_cmd(ACMD13, 0) == 0) {	/* Read SD status */
	LDI  R30,LOW(205)
	ST   -Y,R30
	__GETD2N 0x0
	RCALL _send_cmd_G000
	CPI  R30,0
	BRNE _0x149
;				xchg_spi(0xFF);
	LDI  R26,LOW(255)
	RCALL _xchg_spi_G000
;				if (rcvr_datablock(csd, 16)) {				/* Read partial block */
	MOVW R30,R28
	ADIW R30,8
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(16)
	LDI  R27,0
	RCALL _rcvr_datablock_G000
	SBIW R30,0
	BREQ _0x14A
;					for (n = 64 - 16; n; n--) xchg_spi(0xFF);	/* Purge trailing data */
	LDI  R16,LOW(48)
_0x14C:
	CPI  R16,0
	BREQ _0x14D
	LDI  R26,LOW(255)
	RCALL _xchg_spi_G000
	SUBI R16,1
	RJMP _0x14C
_0x14D:
	LDD  R30,Y+18
	SWAP R30
	ANDI R30,0xF
	__GETD2N 0x10
	CALL __LSLD12
	LDD  R26,Y+24
	LDD  R27,Y+24+1
	CALL __PUTDP1
;					res = RES_OK;
	LDI  R17,LOW(0)
;				}
;			}
_0x14A:
;		} else {					/* SDv1 or MMCv3 */
_0x149:
	RJMP _0x14E
_0x148:
;			if ((send_cmd(CMD9, 0) == 0) && rcvr_datablock(csd, 16)) {	/* Read CSD */
	LDI  R30,LOW(73)
	ST   -Y,R30
	__GETD2N 0x0
	RCALL _send_cmd_G000
	CPI  R30,0
	BRNE _0x150
	MOVW R30,R28
	ADIW R30,8
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(16)
	LDI  R27,0
	RCALL _rcvr_datablock_G000
	SBIW R30,0
	BRNE _0x151
_0x150:
	RJMP _0x14F
_0x151:
;				if (CardType & CT_SD1) {	/* SDv1 */
	LDS  R30,_CardType_G000
	ANDI R30,LOW(0x2)
	BREQ _0x152
;					*(DWORD*)buff = (((csd[10] & 63) << 1) + ((WORD)(csd[11] & 128) >> 7) + 1) << ((csd[13] >> 6) - 1);
	LDD  R30,Y+18
	LDI  R31,0
	ANDI R30,LOW(0x3F)
	ANDI R31,HIGH(0x3F)
	LSL  R30
	MOVW R26,R30
	LDD  R30,Y+19
	LDI  R31,0
	ANDI R30,LOW(0x80)
	ANDI R31,HIGH(0x80)
	CALL __LSRW3
	CALL __LSRW4
	ADD  R26,R30
	ADC  R27,R31
	ADIW R26,1
	LDD  R30,Y+21
	SWAP R30
	ANDI R30,0xF
	LSR  R30
	LSR  R30
	SUBI R30,LOW(1)
	CALL __LSLW12
	RJMP _0x4DE
;				} else {					/* MMCv3 */
_0x152:
;					*(DWORD*)buff = ((WORD)((csd[10] & 124) >> 2) + 1) * (((csd[11] & 3) << 3) + ((csd[11] & 224) >> 5) + 1);
	LDD  R30,Y+18
	LDI  R31,0
	ANDI R30,LOW(0x7C)
	ANDI R31,HIGH(0x7C)
	CALL __ASRW2
	ADIW R30,1
	MOVW R0,R30
	LDD  R30,Y+19
	LDI  R31,0
	ANDI R30,LOW(0x3)
	ANDI R31,HIGH(0x3)
	LSL  R30
	LSL  R30
	LSL  R30
	MOVW R26,R30
	LDD  R30,Y+19
	LDI  R31,0
	ANDI R30,LOW(0xE0)
	ANDI R31,HIGH(0xE0)
	ASR  R31
	ROR  R30
	CALL __ASRW4
	ADD  R30,R26
	ADC  R31,R27
	ADIW R30,1
	MOVW R26,R0
	CALL __MULW12U
_0x4DE:
	LDD  R26,Y+24
	LDD  R27,Y+24+1
	CLR  R22
	CLR  R23
	CALL __PUTDP1
;				}
;				res = RES_OK;
	LDI  R17,LOW(0)
;			}
;		}
_0x14F:
_0x14E:
;		break;
	RJMP _0x13E
;
;	/* Following commands are never used by FatFs module */
;
;	case MMC_GET_TYPE :		/* Get card type flags (1 byte) */
_0x147:
	CPI  R30,LOW(0xA)
	LDI  R26,HIGH(0xA)
	CPC  R31,R26
	BRNE _0x154
;		*ptr = CardType;
	LDS  R30,_CardType_G000
	MOVW R26,R18
	ST   X,R30
;		res = RES_OK;
	LDI  R17,LOW(0)
;		break;
	RJMP _0x13E
;
;	case MMC_GET_CSD :		/* Receive CSD as a data block (16 bytes) */
_0x154:
	CPI  R30,LOW(0xB)
	LDI  R26,HIGH(0xB)
	CPC  R31,R26
	BRNE _0x155
;		if (send_cmd(CMD9, 0) == 0		/* READ_CSD */
;			&& rcvr_datablock(ptr, 16))
	LDI  R30,LOW(73)
	ST   -Y,R30
	__GETD2N 0x0
	RCALL _send_cmd_G000
	CPI  R30,0
	BRNE _0x157
	ST   -Y,R19
	ST   -Y,R18
	LDI  R26,LOW(16)
	LDI  R27,0
	RCALL _rcvr_datablock_G000
	SBIW R30,0
	BRNE _0x158
_0x157:
	RJMP _0x156
_0x158:
;			res = RES_OK;
	LDI  R17,LOW(0)
;		break;
_0x156:
	RJMP _0x13E
;
;	case MMC_GET_CID :		/* Receive CID as a data block (16 bytes) */
_0x155:
	CPI  R30,LOW(0xC)
	LDI  R26,HIGH(0xC)
	CPC  R31,R26
	BRNE _0x159
;		if (send_cmd(CMD10, 0) == 0		/* READ_CID */
;			&& rcvr_datablock(ptr, 16))
	LDI  R30,LOW(74)
	ST   -Y,R30
	__GETD2N 0x0
	RCALL _send_cmd_G000
	CPI  R30,0
	BRNE _0x15B
	ST   -Y,R19
	ST   -Y,R18
	LDI  R26,LOW(16)
	LDI  R27,0
	RCALL _rcvr_datablock_G000
	SBIW R30,0
	BRNE _0x15C
_0x15B:
	RJMP _0x15A
_0x15C:
;			res = RES_OK;
	LDI  R17,LOW(0)
;		break;
_0x15A:
	RJMP _0x13E
;
;	case MMC_GET_OCR :		/* Receive OCR as an R3 resp (4 bytes) */
_0x159:
	CPI  R30,LOW(0xD)
	LDI  R26,HIGH(0xD)
	CPC  R31,R26
	BRNE _0x15D
;		if (send_cmd(CMD58, 0) == 0) {	/* READ_OCR */
	LDI  R30,LOW(122)
	ST   -Y,R30
	__GETD2N 0x0
	RCALL _send_cmd_G000
	CPI  R30,0
	BRNE _0x15E
;			for (n = 4; n; n--) *ptr++ = xchg_spi(0xFF);
	LDI  R16,LOW(4)
_0x160:
	CPI  R16,0
	BREQ _0x161
	PUSH R19
	PUSH R18
	__ADDWRN 18,19,1
	LDI  R26,LOW(255)
	RCALL _xchg_spi_G000
	POP  R26
	POP  R27
	ST   X,R30
	SUBI R16,1
	RJMP _0x160
_0x161:
	LDI  R17,LOW(0)
;		}
;		break;
_0x15E:
	RJMP _0x13E
;
;	case MMC_GET_SDSTAT :	/* Receive SD statsu as a data block (64 bytes) */
_0x15D:
	CPI  R30,LOW(0xE)
	LDI  R26,HIGH(0xE)
	CPC  R31,R26
	BRNE _0x165
;		if (send_cmd(ACMD13, 0) == 0) {	/* SD_STATUS */
	LDI  R30,LOW(205)
	ST   -Y,R30
	__GETD2N 0x0
	RCALL _send_cmd_G000
	CPI  R30,0
	BRNE _0x163
;			xchg_spi(0xFF);
	LDI  R26,LOW(255)
	RCALL _xchg_spi_G000
;			if (rcvr_datablock(ptr, 64))
	ST   -Y,R19
	ST   -Y,R18
	LDI  R26,LOW(64)
	LDI  R27,0
	RCALL _rcvr_datablock_G000
	SBIW R30,0
	BREQ _0x164
;				res = RES_OK;
	LDI  R17,LOW(0)
;		}
_0x164:
;		break;
_0x163:
	RJMP _0x13E
;
;	//case CTRL_POWER_OFF :	/* Power off */
;	//	power_off();
;	//	Stat |= STA_NOINIT;
;	//	res = RES_OK;
;	//	break;
;
;	default:
_0x165:
;		res = RES_PARERR;
	LDI  R17,LOW(4)
;	}
_0x13E:
;
;	deselect();
	RCALL _deselect_G000
;    release_spi();
	RCALL _SPI_Release
;	return res;
	MOV  R30,R17
_0x20C0024:
	CALL __LOADLOCR4
	ADIW R28,28
	RET
;}
; .FEND
;#endif
;
;
;/*-----------------------------------------------------------------------*/
;/* Device Timer Interrupt Procedure                                      */
;/*-----------------------------------------------------------------------*/
;/* This function must be called in period of 10ms                        */
;
;void disk_timerproc (void)
;{
;	BYTE n, s;
;
;
;	n = Timer1;				/* 100Hz decrement timer */
;	n -> R17
;	s -> R16
;	if (n) Timer1 = --n;
;	n = Timer2;
;	if (n) Timer2 = --n;
;
;	s = Stat;
;
;	//if (MMC_WP)				/* Write protected */
;	//	s |= STA_PROTECT;
;	//else					/* Write enabled */
;		s &= ~STA_PROTECT;
;
;	//if (MMC_CD)				/* Card inserted */
;	//	s &= ~STA_NODISK;
;	//else					/* Socket empty */
;		s |= (STA_NODISK | STA_NOINIT);
;
;	Stat = s;				/* Update MMC status */
;}
;#include "vrgl_primitives.c"
;#include "Nokia6610_lcd_lib.h"
;#include "vrgl_primitives.h"
;#include <delay.h>
;
;
;void VRGL_CreateBox(unsigned char nX,unsigned char nY, unsigned char sX,unsigned char sY,int nColor,unsigned char bFill)
;{
;nlcd_Box(nX,nY,nX+sX,nY+sY,bFill,nColor,0);
;	nX -> Y+6
;	nY -> Y+5
;	sX -> Y+4
;	sY -> Y+3
;	nColor -> Y+1
;	bFill -> Y+0
;}
;
;void VRGL_CreateLine(unsigned char nX0,unsigned char nY0, unsigned char nX1,unsigned char nY1,int nColor)
;{
;//nlcd_Line(nX0,nY0,nX1,nY1,nColor);
;}
;
;#include "twi/twim.c"
;//***************************************************************************
;//
;//  Author(s)...: Павел Бобков  http://ChipEnable.Ru
;//
;//  Target(s)...: mega16
;//
;//  Compiler....: CodeVision
;//
;//  Description.: Драйвер ведущего TWI устройства.
;//                Код основан на Atmel`овских доках - AVR315.
;//
;//  Data........: 13.11.13
;//
;//***************************************************************************
;#include "twim.h"
;
;#define TWSR_MASK     0xfc
;
;volatile static uint8_t twiBuf[TWI_BUFFER_SIZE];
;volatile static uint8_t twiState = TWI_NO_STATE;

	.DSEG
;volatile static uint8_t twiMsgSize;
;
;/*предделители для установки скорости обмена twi модуля*/
;uint8_t pre[4] = {2, 8, 32, 128};
;
;/****************************************************************************
; Инициализация и установка частоты SCL сигнала
;****************************************************************************/
;uint8_t TWI_MasterInit(uint16_t fr)
;{

	.CSEG
_TWI_MasterInit:
; .FSTART _TWI_MasterInit
;  uint8_t i;
;  uint16_t twbrValue;
;
;  for(i = 0; i<4; i++){
	ST   -Y,R27
	ST   -Y,R26
	CALL __SAVELOCR4
;	fr -> Y+4
;	i -> R17
;	twbrValue -> R18,R19
	LDI  R17,LOW(0)
_0x16B:
	CPI  R17,4
	BRSH _0x16C
;    twbrValue = ((((F_CPU)/1000UL)/fr)-16)/pre[i];
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	LDI  R26,LOW(8000)
	LDI  R27,HIGH(8000)
	CALL __DIVW21U
	SBIW R30,16
	MOVW R26,R30
	MOV  R30,R17
	LDI  R31,0
	SUBI R30,LOW(-_pre)
	SBCI R31,HIGH(-_pre)
	LD   R30,Z
	LDI  R31,0
	CALL __DIVW21U
	MOVW R18,R30
;    if ((twbrValue > 0)&& (twbrValue < 256)){
	CLR  R0
	CP   R0,R18
	CPC  R0,R19
	BRSH _0x16E
	__CPWRN 18,19,256
	BRLO _0x16F
_0x16E:
	RJMP _0x16D
_0x16F:
;       TWBR = (uint8_t)twbrValue;
	STS  184,R18
;       TWSR = i;
	STS  185,R17
;       TWDR = 0xFF;
	LDI  R30,LOW(255)
	STS  187,R30
;       TWCR = (1<<TWEN);
	LDI  R30,LOW(4)
	STS  188,R30
;       return TWI_SUCCESS;
	LDI  R30,LOW(255)
	CALL __LOADLOCR4
	RJMP _0x20C001F
;    }
;  }
_0x16D:
	SUBI R17,-1
	RJMP _0x16B
_0x16C:
;  return 0;
	LDI  R30,LOW(0)
	CALL __LOADLOCR4
	RJMP _0x20C001F
;}
; .FEND
;
;/****************************************************************************
; Проверка - не занят ли TWI модуль. Используется внутри модуля
;****************************************************************************/
;static uint8_t TWI_TransceiverBusy(void)
;{
_TWI_TransceiverBusy_G000:
; .FSTART _TWI_TransceiverBusy_G000
;  return (TWCR & (1<<TWIE));
	LDS  R30,188
	ANDI R30,LOW(0x1)
	RET
;}
; .FEND
;
;/****************************************************************************
; Взять статус TWI модуля
;****************************************************************************/
;uint8_t TWI_GetState(void)
;{
;  while (TWI_TransceiverBusy());
;  return twiState;
;}
;
;/****************************************************************************
; Передать сообщение msg из msgSize байтов на TWI шину
;****************************************************************************/
;void TWI_SendData(uint8_t *msg, uint8_t msgSize)
;{
_TWI_SendData:
; .FSTART _TWI_SendData
;  uint8_t i;
;
;  while(TWI_TransceiverBusy());   //ждем, когда TWI модуль освободится
	ST   -Y,R26
	ST   -Y,R17
;	*msg -> Y+2
;	msgSize -> Y+1
;	i -> R17
_0x173:
	RCALL _TWI_TransceiverBusy_G000
	CPI  R30,0
	BRNE _0x173
;
;  twiMsgSize = msgSize;           //сохряняем кол. байт для передачи
	LDD  R30,Y+1
	STS  _twiMsgSize_G000,R30
;  twiBuf[0]  = msg[0];            //и первый байт сообщения
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	LD   R30,X
	STS  _twiBuf_G000,R30
;
;  if (!(msg[0] & (TRUE<<TWI_READ_BIT))){   //если первый байт типа SLA+W
	ANDI R30,LOW(0x1)
	BRNE _0x176
;    for (i = 1; i < msgSize; i++){         //то сохряняем остальную часть сообщения
	LDI  R17,LOW(1)
_0x178:
	LDD  R30,Y+1
	CP   R17,R30
	BRSH _0x179
;      twiBuf[i] = msg[i];
	MOV  R30,R17
	LDI  R31,0
	SUBI R30,LOW(-_twiBuf_G000)
	SBCI R31,HIGH(-_twiBuf_G000)
	MOVW R0,R30
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	CLR  R30
	ADD  R26,R17
	ADC  R27,R30
	LD   R30,X
	MOVW R26,R0
	ST   X,R30
;    }
	SUBI R17,-1
	RJMP _0x178
_0x179:
;  }
;
;  twiState = TWI_NO_STATE ;
_0x176:
	LDI  R30,LOW(248)
	STS  _twiState_G000,R30
;  TWCR = (1<<TWEN)|(1<<TWIE)|(1<<TWINT)|(1<<TWSTA); //разрешаем прерывание и формируем состояние старт
	LDI  R30,LOW(165)
	STS  188,R30
;}
	LDD  R17,Y+0
	RJMP _0x20C0022
; .FEND
;
;/****************************************************************************
; Переписать полученные данные в буфер msg в количестве msgSize байт.
;****************************************************************************/
;uint8_t TWI_GetData(uint8_t *msg, uint8_t msgSize)
;{
_TWI_GetData:
; .FSTART _TWI_GetData
;  uint8_t i;
;
;  while(TWI_TransceiverBusy());    //ждем, когда TWI модуль освободится
	ST   -Y,R26
	ST   -Y,R17
;	*msg -> Y+2
;	msgSize -> Y+1
;	i -> R17
_0x17A:
	RCALL _TWI_TransceiverBusy_G000
	CPI  R30,0
	BRNE _0x17A
;
;  if(twiState == TWI_SUCCESS){     //если сообщение успешно принято,
	LDS  R26,_twiState_G000
	CPI  R26,LOW(0xFF)
	BRNE _0x17D
;    for(i = 0; i < msgSize; i++){  //то переписываем его из внутреннего буфера в переданный
	LDI  R17,LOW(0)
_0x17F:
	LDD  R30,Y+1
	CP   R17,R30
	BRSH _0x180
;      msg[i] = twiBuf[i];
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	CLR  R30
	ADD  R26,R17
	ADC  R27,R30
	MOV  R30,R17
	LDI  R31,0
	SUBI R30,LOW(-_twiBuf_G000)
	SBCI R31,HIGH(-_twiBuf_G000)
	LD   R30,Z
	ST   X,R30
;    }
	SUBI R17,-1
	RJMP _0x17F
_0x180:
;  }
;
;  return twiState;
_0x17D:
	LDS  R30,_twiState_G000
	LDD  R17,Y+0
	RJMP _0x20C0022
;}
; .FEND
;
;/****************************************************************************
; Обработчик прерывания TWI модуля
;****************************************************************************/
;interrupt [TWI] void TWI_Isr(void)
;{
_TWI_Isr:
; .FSTART _TWI_Isr
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
;  static uint8_t ptr;
;  uint8_t stat = TWSR & TWSR_MASK;
;
;  switch (stat){
	ST   -Y,R17
;	stat -> R17
	LDS  R30,185
	ANDI R30,LOW(0xFC)
	MOV  R17,R30
	LDI  R31,0
;
;    case TWI_START:                   // состояние START сформировано
	CPI  R30,LOW(0x8)
	LDI  R26,HIGH(0x8)
	CPC  R31,R26
	BREQ _0x185
;    case TWI_REP_START:               // состояние повторный START сформировано
	CPI  R30,LOW(0x10)
	LDI  R26,HIGH(0x10)
	CPC  R31,R26
	BRNE _0x186
_0x185:
;       ptr = 0;
	LDI  R30,LOW(0)
	STS  _ptr_S000002F000,R30
;
;    case TWI_MTX_ADR_ACK:             // был передан пакет SLA+W и получено подтверждение
	RJMP _0x187
_0x186:
	CPI  R30,LOW(0x18)
	LDI  R26,HIGH(0x18)
	CPC  R31,R26
	BRNE _0x188
_0x187:
;    case TWI_MTX_DATA_ACK:            // был передан байт данных и получено подтверждение
	RJMP _0x189
_0x188:
	CPI  R30,LOW(0x28)
	LDI  R26,HIGH(0x28)
	CPC  R31,R26
	BRNE _0x18A
_0x189:
;       if (ptr < twiMsgSize){
	LDS  R30,_twiMsgSize_G000
	LDS  R26,_ptr_S000002F000
	CP   R26,R30
	BRSH _0x18B
;          TWDR = twiBuf[ptr];                    //загружаем в регистр данных следующий байт
	LDS  R30,_ptr_S000002F000
	LDI  R31,0
	SUBI R30,LOW(-_twiBuf_G000)
	SBCI R31,HIGH(-_twiBuf_G000)
	LD   R30,Z
	STS  187,R30
;          TWCR = (1<<TWEN)|(1<<TWIE)|(1<<TWINT); //сбрасываем флаг TWINT
	LDI  R30,LOW(133)
	STS  188,R30
;          ptr++;
	LDS  R30,_ptr_S000002F000
	SUBI R30,-LOW(1)
	STS  _ptr_S000002F000,R30
;       }
;       else{
	RJMP _0x18C
_0x18B:
;          twiState = TWI_SUCCESS;
	LDI  R30,LOW(255)
	STS  _twiState_G000,R30
;          TWCR = (1<<TWEN)|(1<<TWINT)|(1<<TWSTO)|(0<<TWIE); //формируем состояние СТОП, сбрасываем флаг, запрещаем преры ...
	LDI  R30,LOW(148)
	STS  188,R30
;       }
_0x18C:
;       break;
	RJMP _0x183
;
;    case TWI_MRX_DATA_ACK:          //байт данных принят и передано подтверждение
_0x18A:
	CPI  R30,LOW(0x50)
	LDI  R26,HIGH(0x50)
	CPC  R31,R26
	BRNE _0x18D
;       twiBuf[ptr] = TWDR;
	LDS  R26,_ptr_S000002F000
	LDI  R27,0
	SUBI R26,LOW(-_twiBuf_G000)
	SBCI R27,HIGH(-_twiBuf_G000)
	LDS  R30,187
	ST   X,R30
;       ptr++;
	LDS  R30,_ptr_S000002F000
	SUBI R30,-LOW(1)
	STS  _ptr_S000002F000,R30
;
;    case TWI_MRX_ADR_ACK:           //был передан пакет SLA+R и получено подтвеждение
	RJMP _0x18E
_0x18D:
	CPI  R30,LOW(0x40)
	LDI  R26,HIGH(0x40)
	CPC  R31,R26
	BRNE _0x18F
_0x18E:
;      if (ptr < (twiMsgSize-1)){
	LDS  R30,_twiMsgSize_G000
	LDI  R31,0
	SBIW R30,1
	LDS  R26,_ptr_S000002F000
	LDI  R27,0
	CP   R26,R30
	CPC  R27,R31
	BRGE _0x190
;        TWCR = (1<<TWEN)|(1<<TWIE)|(1<<TWINT)|(1<<TWEA);  //если это не предпоследний принятый байт, формируем подтвержд ...
	LDI  R30,LOW(197)
	RJMP _0x4DF
;      }
;      else {
_0x190:
;        TWCR = (1<<TWEN)|(1<<TWIE)|(1<<TWINT);            //если приняли предпоследний байт, подтверждение не формируем
	LDI  R30,LOW(133)
_0x4DF:
	STS  188,R30
;      }
;      break;
	RJMP _0x183
;
;    case TWI_MRX_DATA_NACK:       //был принят байт данных без подтверждения
_0x18F:
	CPI  R30,LOW(0x58)
	LDI  R26,HIGH(0x58)
	CPC  R31,R26
	BRNE _0x192
;      twiBuf[ptr] = TWDR;
	LDS  R26,_ptr_S000002F000
	LDI  R27,0
	SUBI R26,LOW(-_twiBuf_G000)
	SBCI R27,HIGH(-_twiBuf_G000)
	LDS  R30,187
	ST   X,R30
;      twiState = TWI_SUCCESS;
	LDI  R30,LOW(255)
	STS  _twiState_G000,R30
;      TWCR = (1<<TWEN)|(1<<TWINT)|(1<<TWSTO); //формируем состояние стоп
	LDI  R30,LOW(148)
	RJMP _0x4E0
;      break;
;
;    case TWI_ARB_LOST:          //был потерян приоритет
_0x192:
	CPI  R30,LOW(0x38)
	LDI  R26,HIGH(0x38)
	CPC  R31,R26
	BRNE _0x193
;      TWCR = (1<<TWEN)|(1<<TWIE)|(1<<TWINT)|(1<<TWSTA); // сбрасываем флаг TWINT, формируем повторный СТАРТ
	LDI  R30,LOW(165)
	RJMP _0x4E0
;      break;
;
;    case TWI_MTX_ADR_NACK:      // был передан пает SLA+W и не получено подтверждение
_0x193:
;    case TWI_MRX_ADR_NACK:      // был передан пакет SLA+R и не получено подтверждение
_0x195:
;    case TWI_MTX_DATA_NACK:     // был передан байт данных и не получено подтверждение
;    case TWI_BUS_ERROR:         // ошибка на шине из-за некоректных состояний СТАРТ или СТОП
;    default:
;      twiState = stat;
	STS  _twiState_G000,R17
;      TWCR = (1<<TWEN)|(0<<TWIE)|(0<<TWINT)|(0<<TWEA)|(0<<TWSTA)|(0<<TWSTO)|(0<<TWWC); //запретить прерывание
	LDI  R30,LOW(4)
_0x4E0:
	STS  188,R30
;  }
_0x183:
;}
	LD   R17,Y+
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	RETI
; .FEND
;#include "FatFS/ff.c"
;/*----------------------------------------------------------------------------/
;/  FatFs - FAT file system module  R0.10                 (C)ChaN, 2013
;/-----------------------------------------------------------------------------/
;/ FatFs module is a generic FAT file system module for small embedded systems.
;/ This is a free software that opened for education, research and commercial
;/ developments under license policy of following terms.
;/
;/  Copyright (C) 2013, ChaN, all right reserved.
;/
;/ * The FatFs module is a free software and there is NO WARRANTY.
;/ * No restriction on use. You can use, modify and redistribute it for
;/   personal, non-profit or commercial products UNDER YOUR RESPONSIBILITY.
;/ * Redistributions of source code must retain the above copyright notice.
;/
;/-----------------------------------------------------------------------------/
;/ Feb 26,'06 R0.00  Prototype.
;/
;/ Apr 29,'06 R0.01  First stable version.
;/
;/ Jun 01,'06 R0.02  Added FAT12 support.
;/                   Removed unbuffered mode.
;/                   Fixed a problem on small (<32M) partition.
;/ Jun 10,'06 R0.02a Added a configuration option (_FS_MINIMUM).
;/
;/ Sep 22,'06 R0.03  Added f_rename().
;/                   Changed option _FS_MINIMUM to _FS_MINIMIZE.
;/ Dec 11,'06 R0.03a Improved cluster scan algorithm to write files fast.
;/                   Fixed f_mkdir() creates incorrect directory on FAT32.
;/
;/ Feb 04,'07 R0.04  Supported multiple drive system.
;/                   Changed some interfaces for multiple drive system.
;/                   Changed f_mountdrv() to f_mount().
;/                   Added f_mkfs().
;/ Apr 01,'07 R0.04a Supported multiple partitions on a physical drive.
;/                   Added a capability of extending file size to f_lseek().
;/                   Added minimization level 3.
;/                   Fixed an endian sensitive code in f_mkfs().
;/ May 05,'07 R0.04b Added a configuration option _USE_NTFLAG.
;/                   Added FSINFO support.
;/                   Fixed DBCS name can result FR_INVALID_NAME.
;/                   Fixed short seek (<= csize) collapses the file object.
;/
;/ Aug 25,'07 R0.05  Changed arguments of f_read(), f_write() and f_mkfs().
;/                   Fixed f_mkfs() on FAT32 creates incorrect FSINFO.
;/                   Fixed f_mkdir() on FAT32 creates incorrect directory.
;/ Feb 03,'08 R0.05a Added f_truncate() and f_utime().
;/                   Fixed off by one error at FAT sub-type determination.
;/                   Fixed btr in f_read() can be mistruncated.
;/                   Fixed cached sector is not flushed when create and close without write.
;/
;/ Apr 01,'08 R0.06  Added fputc(), fputs(), fprintf() and fgets().
;/                   Improved performance of f_lseek() on moving to the same or following cluster.
;/
;/ Apr 01,'09 R0.07  Merged Tiny-FatFs as a configuration option. (_FS_TINY)
;/                   Added long file name feature.
;/                   Added multiple code page feature.
;/                   Added re-entrancy for multitask operation.
;/                   Added auto cluster size selection to f_mkfs().
;/                   Added rewind option to f_readdir().
;/                   Changed result code of critical errors.
;/                   Renamed string functions to avoid name collision.
;/ Apr 14,'09 R0.07a Separated out OS dependent code on reentrant cfg.
;/                   Added multiple sector size feature.
;/ Jun 21,'09 R0.07c Fixed f_unlink() can return FR_OK on error.
;/                   Fixed wrong cache control in f_lseek().
;/                   Added relative path feature.
;/                   Added f_chdir() and f_chdrive().
;/                   Added proper case conversion to extended character.
;/ Nov 03,'09 R0.07e Separated out configuration options from ff.h to ffconf.h.
;/                   Fixed f_unlink() fails to remove a sub-directory on _FS_RPATH.
;/                   Fixed name matching error on the 13 character boundary.
;/                   Added a configuration option, _LFN_UNICODE.
;/                   Changed f_readdir() to return the SFN with always upper case on non-LFN cfg.
;/
;/ May 15,'10 R0.08  Added a memory configuration option. (_USE_LFN = 3)
;/                   Added file lock feature. (_FS_SHARE)
;/                   Added fast seek feature. (_USE_FASTSEEK)
;/                   Changed some types on the API, XCHAR->TCHAR.
;/                   Changed .fname in the FILINFO structure on Unicode cfg.
;/                   String functions support UTF-8 encoding files on Unicode cfg.
;/ Aug 16,'10 R0.08a Added f_getcwd().
;/                   Added sector erase feature. (_USE_ERASE)
;/                   Moved file lock semaphore table from fs object to the bss.
;/                   Fixed a wrong directory entry is created on non-LFN cfg when the given name contains ';'.
;/                   Fixed f_mkfs() creates wrong FAT32 volume.
;/ Jan 15,'11 R0.08b Fast seek feature is also applied to f_read() and f_write().
;/                   f_lseek() reports required table size on creating CLMP.
;/                   Extended format syntax of f_printf().
;/                   Ignores duplicated directory separators in given path name.
;/
;/ Sep 06,'11 R0.09  f_mkfs() supports multiple partition to complete the multiple partition feature.
;/                   Added f_fdisk().
;/ Aug 27,'12 R0.09a Changed f_open() and f_opendir() reject null object pointer to avoid crash.
;/                   Changed option name _FS_SHARE to _FS_LOCK.
;/                   Fixed assertion failure due to OS/2 EA on FAT12/16 volume.
;/ Jan 24,'13 R0.09b Added f_setlabel() and f_getlabel().
;/
;/ Oct 02,'13 R0.10  Added selection of character encoding on the file. (_STRF_ENCODE)
;/                   Added f_closedir().
;/                   Added forced full FAT scan for f_getfree(). (_FS_NOFSINFO)
;/                   Added forced mount feature with changes of f_mount().
;/                   Improved behavior of volume auto detection.
;/                   Improved write throughput of f_puts() and f_printf().
;/                   Changed argument of f_chdrive(), f_mkfs(), disk_read() and disk_write().
;/                   Fixed f_write() can be truncated when the file size is close to 4GB.
;/                   Fixed f_open(), f_mkdir() and f_setlabel() can return incorrect error code.
;/---------------------------------------------------------------------------*/
;
;#include "ff.h"			/* Declarations of FatFs API */
;#include "diskio.h"		/* Declarations of disk I/O functions */
;#include "option/unicode.c"
;#include "../ff.h"
;
;#if _USE_LFN != 0
;
;#if   _CODE_PAGE == 932
;#include "cc932.c"
;#elif _CODE_PAGE == 936
;#include "cc936.c"
;#elif _CODE_PAGE == 949
;#include "cc949.c"
;#elif _CODE_PAGE == 950
;#include "cc950.c"
;#else
;#include "ccsbcs.c"
;#endif
;
;#endif
;
;
;/*--------------------------------------------------------------------------
;
;   Module Private Definitions
;
;---------------------------------------------------------------------------*/
;
;#if _FATFS != 80960	/* Revision ID */
;#error Wrong include file (ff.h).
;#endif
;
;
;/* Definitions on sector size */
;#if _MAX_SS != 512 && _MAX_SS != 1024 && _MAX_SS != 2048 && _MAX_SS != 4096
;#error Wrong sector size.
;#endif
;#if _MAX_SS != 512
;#define	SS(fs)	((fs)->ssize)	/* Variable sector size */
;#else
;#define	SS(fs)	512U			/* Fixed sector size */
;#endif
;
;
;/* Reentrancy related */
;#if _FS_REENTRANT
;#if _USE_LFN == 1
;#error Static LFN work area cannot be used at thread-safe configuration.
;#endif
;#define	ENTER_FF(fs)		{ if (!lock_fs(fs)) return FR_TIMEOUT; }
;#define	LEAVE_FF(fs, res)	{ unlock_fs(fs, res); return res; }
;#else
;#define	ENTER_FF(fs)
;#define LEAVE_FF(fs, res)	return res
;#endif
;
;#define	ABORT(fs, res)		{ fp->err = (BYTE)(res); LEAVE_FF(fs, res); }
;
;
;/* File access control feature */
;#if _FS_LOCK
;#if _FS_READONLY
;#error _FS_LOCK must be 0 at read-only cfg.
;#endif
;typedef struct {
;	FATFS *fs;				/* Object ID 1, volume (NULL:blank entry) */
;	DWORD clu;				/* Object ID 2, directory */
;	WORD idx;				/* Object ID 3, directory index */
;	WORD ctr;				/* Object open counter, 0:none, 0x01..0xFF:read mode open count, 0x100:write mode */
;} FILESEM;
;#endif
;
;
;
;/* DBCS code ranges and SBCS extend character conversion table */
;
;#if _CODE_PAGE == 932	/* Japanese Shift-JIS */
;#define _DF1S	0x81	/* DBC 1st byte range 1 start */
;#define _DF1E	0x9F	/* DBC 1st byte range 1 end */
;#define _DF2S	0xE0	/* DBC 1st byte range 2 start */
;#define _DF2E	0xFC	/* DBC 1st byte range 2 end */
;#define _DS1S	0x40	/* DBC 2nd byte range 1 start */
;#define _DS1E	0x7E	/* DBC 2nd byte range 1 end */
;#define _DS2S	0x80	/* DBC 2nd byte range 2 start */
;#define _DS2E	0xFC	/* DBC 2nd byte range 2 end */
;
;#elif _CODE_PAGE == 936	/* Simplified Chinese GBK */
;#define _DF1S	0x81
;#define _DF1E	0xFE
;#define _DS1S	0x40
;#define _DS1E	0x7E
;#define _DS2S	0x80
;#define _DS2E	0xFE
;
;#elif _CODE_PAGE == 949	/* Korean */
;#define _DF1S	0x81
;#define _DF1E	0xFE
;#define _DS1S	0x41
;#define _DS1E	0x5A
;#define _DS2S	0x61
;#define _DS2E	0x7A
;#define _DS3S	0x81
;#define _DS3E	0xFE
;
;#elif _CODE_PAGE == 950	/* Traditional Chinese Big5 */
;#define _DF1S	0x81
;#define _DF1E	0xFE
;#define _DS1S	0x40
;#define _DS1E	0x7E
;#define _DS2S	0xA1
;#define _DS2E	0xFE
;
;#elif _CODE_PAGE == 437	/* U.S. (OEM) */
;#define _DF1S	0
;#define _EXCVT {0x80,0x9A,0x90,0x41,0x8E,0x41,0x8F,0x80,0x45,0x45,0x45,0x49,0x49,0x49,0x8E,0x8F,0x90,0x92,0x92,0x4F,0x99 ...
;				0x41,0x49,0x4F,0x55,0xA5,0xA5,0xA6,0xA7,0xA8,0xA9,0xAA,0xAB,0xAC,0x21,0xAE,0xAF,0xB0,0xB1,0xB2,0xB3,0xB4,0xB5,0xB6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0 ...
;				0xE0,0xE1,0xE2,0xE3,0xE4,0xE5,0xE6,0xE7,0xE8,0xE9,0xEA,0xEB,0xEC,0xED,0xEE,0xEF,0xF0,0xF1,0xF2,0xF3,0xF4,0xF5,0xF6,0 ...
;
;#elif _CODE_PAGE == 720	/* Arabic (OEM) */
;#define _DF1S	0
;#define _EXCVT {0x80,0x81,0x45,0x41,0x84,0x41,0x86,0x43,0x45,0x45,0x45,0x49,0x49,0x8D,0x8E,0x8F,0x90,0x92,0x92,0x93,0x94 ...
;				0xA0,0xA1,0xA2,0xA3,0xA4,0xA5,0xA6,0xA7,0xA8,0xA9,0xAA,0xAB,0xAC,0xAD,0xAE,0xAF,0xB0,0xB1,0xB2,0xB3,0xB4,0xB5,0xB6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0 ...
;				0xE0,0xE1,0xE2,0xE3,0xE4,0xE5,0xE6,0xE7,0xE8,0xE9,0xEA,0xEB,0xEC,0xED,0xEE,0xEF,0xF0,0xF1,0xF2,0xF3,0xF4,0xF5,0xF6,0 ...
;
;#elif _CODE_PAGE == 737	/* Greek (OEM) */
;#define _DF1S	0
;#define _EXCVT {0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8A,0x8B,0x8C,0x8D,0x8E,0x8F,0x90,0x92,0x92,0x93,0x94 ...
;				0x88,0x89,0x8A,0x8B,0x8C,0x8D,0x8E,0x8F,0x90,0x91,0xAA,0x92,0x93,0x94,0x95,0x96,0xB0,0xB1,0xB2,0xB3,0xB4,0xB5,0xB6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0 ...
;				0x97,0xEA,0xEB,0xEC,0xE4,0xED,0xEE,0xE7,0xE8,0xF1,0xEA,0xEB,0xEC,0xED,0xEE,0xEF,0xF0,0xF1,0xF2,0xF3,0xF4,0xF5,0xF6,0 ...
;
;#elif _CODE_PAGE == 775	/* Baltic (OEM) */
;#define _DF1S	0
;#define _EXCVT {0x80,0x9A,0x91,0xA0,0x8E,0x95,0x8F,0x80,0xAD,0xED,0x8A,0x8A,0xA1,0x8D,0x8E,0x8F,0x90,0x92,0x92,0xE2,0x99 ...
;				0xA0,0xA1,0xE0,0xA3,0xA3,0xA5,0xA6,0xA7,0xA8,0xA9,0xAA,0xAB,0xAC,0xAD,0xAE,0xAF,0xB0,0xB1,0xB2,0xB3,0xB4,0xB5,0xB6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xB5,0xB6,0xB7,0xB8,0xBD,0xBE,0xC6,0 ...
;				0xE0,0xE1,0xE2,0xE3,0xE5,0xE5,0xE6,0xE3,0xE8,0xE8,0xEA,0xEA,0xEE,0xED,0xEE,0xEF,0xF0,0xF1,0xF2,0xF3,0xF4,0xF5,0xF6,0 ...
;
;#elif _CODE_PAGE == 850	/* Multilingual Latin 1 (OEM) */
;#define _DF1S	0
;#define _EXCVT {0x80,0x9A,0x90,0xB6,0x8E,0xB7,0x8F,0x80,0xD2,0xD3,0xD4,0xD8,0xD7,0xDE,0x8E,0x8F,0x90,0x92,0x92,0xE2,0x99 ...
;				0xB5,0xD6,0xE0,0xE9,0xA5,0xA5,0xA6,0xA7,0xA8,0xA9,0xAA,0xAB,0xAC,0x21,0xAE,0xAF,0xB0,0xB1,0xB2,0xB3,0xB4,0xB5,0xB6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC7,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0 ...
;				0xE0,0xE1,0xE2,0xE3,0xE5,0xE5,0xE6,0xE7,0xE7,0xE9,0xEA,0xEB,0xED,0xED,0xEE,0xEF,0xF0,0xF1,0xF2,0xF3,0xF4,0xF5,0xF6,0 ...
;
;#elif _CODE_PAGE == 852	/* Latin 2 (OEM) */
;#define _DF1S	0
;#define _EXCVT {0x80,0x9A,0x90,0xB6,0x8E,0xDE,0x8F,0x80,0x9D,0xD3,0x8A,0x8A,0xD7,0x8D,0x8E,0x8F,0x90,0x91,0x91,0xE2,0x99 ...
;				0xB5,0xD6,0xE0,0xE9,0xA4,0xA4,0xA6,0xA6,0xA8,0xA8,0xAA,0x8D,0xAC,0xB8,0xAE,0xAF,0xB0,0xB1,0xB2,0xB3,0xB4,0xB5,0xB6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC6,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD1,0xD1,0xD2,0xD3,0xD2,0xD5,0xD6,0 ...
;				0xE0,0xE1,0xE2,0xE3,0xE3,0xD5,0xE6,0xE6,0xE8,0xE9,0xE8,0xEB,0xED,0xED,0xDD,0xEF,0xF0,0xF1,0xF2,0xF3,0xF4,0xF5,0xF6,0 ...
;
;#elif _CODE_PAGE == 855	/* Cyrillic (OEM) */
;#define _DF1S	0
;#define _EXCVT {0x81,0x81,0x83,0x83,0x85,0x85,0x87,0x87,0x89,0x89,0x8B,0x8B,0x8D,0x8D,0x8F,0x8F,0x91,0x91,0x93,0x93,0x95 ...
;				0xA1,0xA1,0xA3,0xA3,0xA5,0xA5,0xA7,0xA7,0xA9,0xA9,0xAB,0xAB,0xAD,0xAD,0xAE,0xAF,0xB0,0xB1,0xB2,0xB3,0xB4,0xB6,0xB6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC7,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD1,0xD1,0xD3,0xD3,0xD5,0xD5,0xD7,0 ...
;				0xE0,0xE2,0xE2,0xE4,0xE4,0xE6,0xE6,0xE8,0xE8,0xEA,0xEA,0xEC,0xEC,0xEE,0xEE,0xEF,0xF0,0xF2,0xF2,0xF4,0xF4,0xF6,0xF6,0 ...
;
;#elif _CODE_PAGE == 857	/* Turkish (OEM) */
;#define _DF1S	0
;#define _EXCVT {0x80,0x9A,0x90,0xB6,0x8E,0xB7,0x8F,0x80,0xD2,0xD3,0xD4,0xD8,0xD7,0x98,0x8E,0x8F,0x90,0x92,0x92,0xE2,0x99 ...
;				0xB5,0xD6,0xE0,0xE9,0xA5,0xA5,0xA6,0xA6,0xA8,0xA9,0xAA,0xAB,0xAC,0x21,0xAE,0xAF,0xB0,0xB1,0xB2,0xB3,0xB4,0xB5,0xB6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC7,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0 ...
;				0xE0,0xE1,0xE2,0xE3,0xE5,0xE5,0xE6,0xE7,0xE8,0xE9,0xEA,0xEB,0xDE,0x59,0xEE,0xEF,0xF0,0xF1,0xF2,0xF3,0xF4,0xF5,0xF6,0 ...
;
;#elif _CODE_PAGE == 858	/* Multilingual Latin 1 + Euro (OEM) */
;#define _DF1S	0
;#define _EXCVT {0x80,0x9A,0x90,0xB6,0x8E,0xB7,0x8F,0x80,0xD2,0xD3,0xD4,0xD8,0xD7,0xDE,0x8E,0x8F,0x90,0x92,0x92,0xE2,0x99 ...
;				0xB5,0xD6,0xE0,0xE9,0xA5,0xA5,0xA6,0xA7,0xA8,0xA9,0xAA,0xAB,0xAC,0x21,0xAE,0xAF,0xB0,0xB1,0xB2,0xB3,0xB4,0xB5,0xB6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC7,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD1,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0 ...
;				0xE0,0xE1,0xE2,0xE3,0xE5,0xE5,0xE6,0xE7,0xE7,0xE9,0xEA,0xEB,0xED,0xED,0xEE,0xEF,0xF0,0xF1,0xF2,0xF3,0xF4,0xF5,0xF6,0 ...
;
;#elif _CODE_PAGE == 862	/* Hebrew (OEM) */
;#define _DF1S	0
;#define _EXCVT {0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8A,0x8B,0x8C,0x8D,0x8E,0x8F,0x90,0x91,0x92,0x93,0x94 ...
;				0x41,0x49,0x4F,0x55,0xA5,0xA5,0xA6,0xA7,0xA8,0xA9,0xAA,0xAB,0xAC,0x21,0xAE,0xAF,0xB0,0xB1,0xB2,0xB3,0xB4,0xB5,0xB6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0 ...
;				0xE0,0xE1,0xE2,0xE3,0xE4,0xE5,0xE6,0xE7,0xE8,0xE9,0xEA,0xEB,0xEC,0xED,0xEE,0xEF,0xF0,0xF1,0xF2,0xF3,0xF4,0xF5,0xF6,0 ...
;
;#elif _CODE_PAGE == 866	/* Russian (OEM) */
;#define _DF1S	0
;#define _EXCVT {0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8A,0x8B,0x8C,0x8D,0x8E,0x8F,0x90,0x91,0x92,0x93,0x94 ...
;				0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8A,0x8B,0x8C,0x8D,0x8E,0x8F,0xB0,0xB1,0xB2,0xB3,0xB4,0xB5,0xB6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0 ...
;				0x90,0x91,0x92,0x93,0x9d,0x95,0x96,0x97,0x98,0x99,0x9A,0x9B,0x9C,0x9D,0x9E,0x9F,0xF0,0xF0,0xF2,0xF2,0xF4,0xF4,0xF6,0 ...
;
;#elif _CODE_PAGE == 874	/* Thai (OEM, Windows) */
;#define _DF1S	0
;#define _EXCVT {0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8A,0x8B,0x8C,0x8D,0x8E,0x8F,0x90,0x91,0x92,0x93,0x94 ...
;				0xA0,0xA1,0xA2,0xA3,0xA4,0xA5,0xA6,0xA7,0xA8,0xA9,0xAA,0xAB,0xAC,0xAD,0xAE,0xAF,0xB0,0xB1,0xB2,0xB3,0xB4,0xB5,0xB6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0 ...
;				0xE0,0xE1,0xE2,0xE3,0xE4,0xE5,0xE6,0xE7,0xE8,0xE9,0xEA,0xEB,0xEC,0xED,0xEE,0xEF,0xF0,0xF1,0xF2,0xF3,0xF4,0xF5,0xF6,0 ...
;
;#elif _CODE_PAGE == 1250 /* Central Europe (Windows) */
;#define _DF1S	0
;#define _EXCVT {0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8A,0x8B,0x8C,0x8D,0x8E,0x8F,0x90,0x91,0x92,0x93,0x94 ...
;				0xA0,0xA1,0xA2,0xA3,0xA4,0xA5,0xA6,0xA7,0xA8,0xA9,0xAA,0xAB,0xAC,0xAD,0xAE,0xAF,0xB0,0xB1,0xB2,0xA3,0xB4,0xB5,0xB6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0 ...
;
;#elif _CODE_PAGE == 1251 /* Cyrillic (Windows) */
;#define _DF1S	0
;#define _EXCVT {0x80,0x81,0x82,0x82,0x84,0x85,0x86,0x87,0x88,0x89,0x8A,0x8B,0x8C,0x8D,0x8E,0x8F,0x80,0x91,0x92,0x93,0x94 ...
;				0xA0,0xA2,0xA2,0xA3,0xA4,0xA5,0xA6,0xA7,0xA8,0xA9,0xAA,0xAB,0xAC,0xAD,0xAE,0xAF,0xB0,0xB1,0xB2,0xB2,0xA5,0xB5,0xB6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0 ...
;
;#elif _CODE_PAGE == 1252 /* Latin 1 (Windows) */
;#define _DF1S	0
;#define _EXCVT {0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8A,0x8B,0x8C,0x8D,0x8E,0x8F,0x90,0x91,0x92,0x93,0x94 ...
;				0xA0,0x21,0xA2,0xA3,0xA4,0xA5,0xA6,0xA7,0xA8,0xA9,0xAA,0xAB,0xAC,0xAD,0xAE,0xAF,0xB0,0xB1,0xB2,0xB3,0xB4,0xB5,0xB6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0 ...
;
;#elif _CODE_PAGE == 1253 /* Greek (Windows) */
;#define _DF1S	0
;#define _EXCVT {0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8A,0x8B,0x8C,0x8D,0x8E,0x8F,0x90,0x91,0x92,0x93,0x94 ...
;				0xA0,0xA1,0xA2,0xA3,0xA4,0xA5,0xA6,0xA7,0xA8,0xA9,0xAA,0xAB,0xAC,0xAD,0xAE,0xAF,0xB0,0xB1,0xB2,0xB3,0xB4,0xB5,0xB6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0 ...
;				0xE0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD1,0xF2,0xD3,0xD4,0xD5,0xD6,0 ...
;
;#elif _CODE_PAGE == 1254 /* Turkish (Windows) */
;#define _DF1S	0
;#define _EXCVT {0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8A,0x8B,0x8C,0x8D,0x8E,0x8F,0x90,0x91,0x92,0x93,0x94 ...
;				0xA0,0x21,0xA2,0xA3,0xA4,0xA5,0xA6,0xA7,0xA8,0xA9,0xAA,0xAB,0xAC,0xAD,0xAE,0xAF,0xB0,0xB1,0xB2,0xB3,0xB4,0xB5,0xB6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0 ...
;
;#elif _CODE_PAGE == 1255 /* Hebrew (Windows) */
;#define _DF1S	0
;#define _EXCVT {0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8A,0x8B,0x8C,0x8D,0x8E,0x8F,0x90,0x91,0x92,0x93,0x94 ...
;				0xA0,0x21,0xA2,0xA3,0xA4,0xA5,0xA6,0xA7,0xA8,0xA9,0xAA,0xAB,0xAC,0xAD,0xAE,0xAF,0xB0,0xB1,0xB2,0xB3,0xB4,0xB5,0xB6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0 ...
;				0xE0,0xE1,0xE2,0xE3,0xE4,0xE5,0xE6,0xE7,0xE8,0xE9,0xEA,0xEB,0xEC,0xED,0xEE,0xEF,0xF0,0xF1,0xF2,0xF3,0xF4,0xF5,0xF6,0 ...
;
;#elif _CODE_PAGE == 1256 /* Arabic (Windows) */
;#define _DF1S	0
;#define _EXCVT {0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8A,0x8B,0x8C,0x8D,0x8E,0x8F,0x90,0x91,0x92,0x93,0x94 ...
;				0xA0,0xA1,0xA2,0xA3,0xA4,0xA5,0xA6,0xA7,0xA8,0xA9,0xAA,0xAB,0xAC,0xAD,0xAE,0xAF,0xB0,0xB1,0xB2,0xB3,0xB4,0xB5,0xB6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0 ...
;				0x41,0xE1,0x41,0xE3,0xE4,0xE5,0xE6,0x43,0x45,0x45,0x45,0x45,0xEC,0xED,0x49,0x49,0xF0,0xF1,0xF2,0xF3,0x4F,0xF5,0xF6,0 ...
;
;#elif _CODE_PAGE == 1257 /* Baltic (Windows) */
;#define _DF1S	0
;#define _EXCVT {0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8A,0x8B,0x8C,0x8D,0x8E,0x8F,0x90,0x91,0x92,0x93,0x94 ...
;				0xA0,0xA1,0xA2,0xA3,0xA4,0xA5,0xA6,0xA7,0xA8,0xA9,0xAA,0xAB,0xAC,0xAD,0xAE,0xAF,0xB0,0xB1,0xB2,0xB3,0xB4,0xB5,0xB6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0 ...
;
;#elif _CODE_PAGE == 1258 /* Vietnam (OEM, Windows) */
;#define _DF1S	0
;#define _EXCVT {0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8A,0x8B,0x8C,0x8D,0x8E,0x8F,0x90,0x91,0x92,0x93,0x94 ...
;				0xA0,0x21,0xA2,0xA3,0xA4,0xA5,0xA6,0xA7,0xA8,0xA9,0xAA,0xAB,0xAC,0xAD,0xAE,0xAF,0xB0,0xB1,0xB2,0xB3,0xB4,0xB5,0xB6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0 ...
;				0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xEC,0xCD,0xCE,0xCF,0xD0,0xD1,0xF2,0xD3,0xD4,0xD5,0xD6,0 ...
;
;#elif _CODE_PAGE == 1	/* ASCII (for only non-LFN cfg) */
;#if _USE_LFN
;#error Cannot use LFN feature without valid code page.
;#endif
;#define _DF1S	0
;
;#else
;#error Unknown code page
;
;#endif
;
;
;/* Character code support macros */
;#define IsUpper(c)	(((c)>='A')&&((c)<='Z'))
;#define IsLower(c)	(((c)>='a')&&((c)<='z'))
;#define IsDigit(c)	(((c)>='0')&&((c)<='9'))
;
;#if _DF1S		/* Code page is DBCS */
;
;#ifdef _DF2S	/* Two 1st byte areas */
;#define IsDBCS1(c)	(((BYTE)(c) >= _DF1S && (BYTE)(c) <= _DF1E) || ((BYTE)(c) >= _DF2S && (BYTE)(c) <= _DF2E))
;#else			/* One 1st byte area */
;#define IsDBCS1(c)	((BYTE)(c) >= _DF1S && (BYTE)(c) <= _DF1E)
;#endif
;
;#ifdef _DS3S	/* Three 2nd byte areas */
;#define IsDBCS2(c)	(((BYTE)(c) >= _DS1S && (BYTE)(c) <= _DS1E) || ((BYTE)(c) >= _DS2S && (BYTE)(c) <= _DS2E) || ((BYTE)( ...
;#else			/* Two 2nd byte areas */
;#define IsDBCS2(c)	(((BYTE)(c) >= _DS1S && (BYTE)(c) <= _DS1E) || ((BYTE)(c) >= _DS2S && (BYTE)(c) <= _DS2E))
;#endif
;
;#else			/* Code page is SBCS */
;
;#define IsDBCS1(c)	0
;#define IsDBCS2(c)	0
;
;#endif /* _DF1S */
;
;
;/* Name status flags */
;#define NS			11		/* Index of name status byte in fn[] */
;#define NS_LOSS		0x01	/* Out of 8.3 format */
;#define NS_LFN		0x02	/* Force to create LFN entry */
;#define NS_LAST		0x04	/* Last segment */
;#define NS_BODY		0x08	/* Lower case flag (body) */
;#define NS_EXT		0x10	/* Lower case flag (ext) */
;#define NS_DOT		0x20	/* Dot entry */
;
;
;/* FAT sub-type boundaries */
;#define MIN_FAT16	4086U	/* Minimum number of clusters for FAT16 */
;#define	MIN_FAT32	65526U	/* Minimum number of clusters for FAT32 */
;
;
;/* FatFs refers the members in the FAT structures as byte array instead of
;/ structure member because the structure is not binary compatible between
;/ different platforms */
;
;#define BS_jmpBoot			0	/* Jump instruction (3) */
;#define BS_OEMName			3	/* OEM name (8) */
;#define BPB_BytsPerSec		11	/* Sector size [byte] (2) */
;#define BPB_SecPerClus		13	/* Cluster size [sector] (1) */
;#define BPB_RsvdSecCnt		14	/* Size of reserved area [sector] (2) */
;#define BPB_NumFATs			16	/* Number of FAT copies (1) */
;#define BPB_RootEntCnt		17	/* Number of root directory entries for FAT12/16 (2) */
;#define BPB_TotSec16		19	/* Volume size [sector] (2) */
;#define BPB_Media			21	/* Media descriptor (1) */
;#define BPB_FATSz16			22	/* FAT size [sector] (2) */
;#define BPB_SecPerTrk		24	/* Track size [sector] (2) */
;#define BPB_NumHeads		26	/* Number of heads (2) */
;#define BPB_HiddSec			28	/* Number of special hidden sectors (4) */
;#define BPB_TotSec32		32	/* Volume size [sector] (4) */
;#define BS_DrvNum			36	/* Physical drive number (2) */
;#define BS_BootSig			38	/* Extended boot signature (1) */
;#define BS_VolID			39	/* Volume serial number (4) */
;#define BS_VolLab			43	/* Volume label (8) */
;#define BS_FilSysType		54	/* File system type (1) */
;#define BPB_FATSz32			36	/* FAT size [sector] (4) */
;#define BPB_ExtFlags		40	/* Extended flags (2) */
;#define BPB_FSVer			42	/* File system version (2) */
;#define BPB_RootClus		44	/* Root directory first cluster (4) */
;#define BPB_FSInfo			48	/* Offset of FSINFO sector (2) */
;#define BPB_BkBootSec		50	/* Offset of backup boot sector (2) */
;#define BS_DrvNum32			64	/* Physical drive number (2) */
;#define BS_BootSig32		66	/* Extended boot signature (1) */
;#define BS_VolID32			67	/* Volume serial number (4) */
;#define BS_VolLab32			71	/* Volume label (8) */
;#define BS_FilSysType32		82	/* File system type (1) */
;#define	FSI_LeadSig			0	/* FSI: Leading signature (4) */
;#define	FSI_StrucSig		484	/* FSI: Structure signature (4) */
;#define	FSI_Free_Count		488	/* FSI: Number of free clusters (4) */
;#define	FSI_Nxt_Free		492	/* FSI: Last allocated cluster (4) */
;#define MBR_Table			446	/* MBR: Partition table offset (2) */
;#define	SZ_PTE				16	/* MBR: Size of a partition table entry */
;#define BS_55AA				510	/* Boot sector signature (2) */
;
;#define	DIR_Name			0	/* Short file name (11) */
;#define	DIR_Attr			11	/* Attribute (1) */
;#define	DIR_NTres			12	/* NT flag (1) */
;#define DIR_CrtTimeTenth	13	/* Created time sub-second (1) */
;#define	DIR_CrtTime			14	/* Created time (2) */
;#define	DIR_CrtDate			16	/* Created date (2) */
;#define DIR_LstAccDate		18	/* Last accessed date (2) */
;#define	DIR_FstClusHI		20	/* Higher 16-bit of first cluster (2) */
;#define	DIR_WrtTime			22	/* Modified time (2) */
;#define	DIR_WrtDate			24	/* Modified date (2) */
;#define	DIR_FstClusLO		26	/* Lower 16-bit of first cluster (2) */
;#define	DIR_FileSize		28	/* File size (4) */
;#define	LDIR_Ord			0	/* LFN entry order and LLE flag (1) */
;#define	LDIR_Attr			11	/* LFN attribute (1) */
;#define	LDIR_Type			12	/* LFN type (1) */
;#define	LDIR_Chksum			13	/* Sum of corresponding SFN entry */
;#define	LDIR_FstClusLO		26	/* Filled by zero (0) */
;#define	SZ_DIR				32		/* Size of a directory entry */
;#define	LLE					0x40	/* Last long entry flag in LDIR_Ord */
;#define	DDE					0xE5	/* Deleted directory entry mark in DIR_Name[0] */
;#define	NDDE				0x05	/* Replacement of the character collides with DDE */
;
;
;/*------------------------------------------------------------*/
;/* Module private work area                                   */
;/*------------------------------------------------------------*/
;/* Note that uninitialized variables with static duration are
;/  zeroed/nulled at start-up. If not, the compiler or start-up
;/  routine is out of ANSI-C standard.
;*/
;
;#if _VOLUMES
;static
;FATFS *FatFs[_VOLUMES];	/* Pointer to the file system objects (logical drives) */
;#else
;#error Number of volumes must not be 0.
;#endif
;
;static
;WORD Fsid;				/* File system mount ID */
;
;#if _FS_RPATH && _VOLUMES >= 2
;static
;BYTE CurrVol;			/* Current drive */
;#endif
;
;#if _FS_LOCK
;static
;FILESEM	Files[_FS_LOCK];	/* Open object lock semaphores */
;#endif
;
;#if _USE_LFN == 0			/* No LFN feature */
;#define	DEF_NAMEBUF			BYTE sfn[12]
;#define INIT_BUF(dobj)		(dobj).fn = sfn
;#define	FREE_BUF()
;
;#elif _USE_LFN == 1			/* LFN feature with static working buffer */
;static
;WCHAR LfnBuf[_MAX_LFN+1];
;#define	DEF_NAMEBUF			BYTE sfn[12]
;#define INIT_BUF(dobj)		{ (dobj).fn = sfn; (dobj).lfn = LfnBuf; }
;#define	FREE_BUF()
;
;#elif _USE_LFN == 2 		/* LFN feature with dynamic working buffer on the stack */
;#define	DEF_NAMEBUF			BYTE sfn[12]; WCHAR lbuf[_MAX_LFN+1]
;#define INIT_BUF(dobj)		{ (dobj).fn = sfn; (dobj).lfn = lbuf; }
;#define	FREE_BUF()
;
;#elif _USE_LFN == 3 		/* LFN feature with dynamic working buffer on the heap */
;#define	DEF_NAMEBUF			BYTE sfn[12]; WCHAR *lfn
;#define INIT_BUF(dobj)		{ lfn = ff_memalloc((_MAX_LFN + 1) * 2); \
;							  if (!lfn) LEAVE_FF((dobj).fs, FR_NOT_ENOUGH_CORE); \
;							  (dobj).lfn = lfn;	(dobj).fn = sfn; }
;#define	FREE_BUF()			ff_memfree(lfn)
;
;#else
;#error Wrong LFN configuration.
;#endif
;
;
;#ifdef _EXCVT
;static
;const BYTE ExCvt[] = _EXCVT;	/* Upper conversion table for extended characters */
;#endif
;
;
;
;
;
;
;/*--------------------------------------------------------------------------
;
;   Module Private Functions
;
;---------------------------------------------------------------------------*/
;
;
;/*-----------------------------------------------------------------------*/
;/* String functions                                                      */
;/*-----------------------------------------------------------------------*/
;
;/* Copy memory to memory */
;static
;void mem_cpy (void* dst, const void* src, UINT cnt) {
_mem_cpy_G000:
; .FSTART _mem_cpy_G000
;	BYTE *d = (BYTE*)dst;
;	const BYTE *s = (const BYTE*)src;
;
;#if _WORD_ACCESS == 1
;	while (cnt >= sizeof (int)) {
;		*(int*)d = *(int*)s;
;		d += sizeof (int); s += sizeof (int);
;		cnt -= sizeof (int);
;	}
;#endif
;	while (cnt--)
	ST   -Y,R27
	ST   -Y,R26
	CALL __SAVELOCR4
;	*dst -> Y+8
;	*src -> Y+6
;	cnt -> Y+4
;	*d -> R16,R17
;	*s -> R18,R19
	__GETWRS 16,17,8
	__GETWRS 18,19,6
_0x19C:
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	SBIW R30,1
	STD  Y+4,R30
	STD  Y+4+1,R31
	ADIW R30,1
	BREQ _0x19E
;		*d++ = *s++;
	PUSH R17
	PUSH R16
	__ADDWRN 16,17,1
	MOVW R26,R18
	__ADDWRN 18,19,1
	LD   R30,X
	POP  R26
	POP  R27
	ST   X,R30
	RJMP _0x19C
_0x19E:
	CALL __LOADLOCR4
_0x20C0023:
	ADIW R28,10
	RET
; .FEND
;
;/* Fill memory */
;static
;void mem_set (void* dst, int val, UINT cnt) {
_mem_set_G000:
; .FSTART _mem_set_G000
;	BYTE *d = (BYTE*)dst;
;
;	while (cnt--)
	ST   -Y,R27
	ST   -Y,R26
	ST   -Y,R17
	ST   -Y,R16
;	*dst -> Y+6
;	val -> Y+4
;	cnt -> Y+2
;	*d -> R16,R17
	__GETWRS 16,17,6
_0x19F:
	LDD  R30,Y+2
	LDD  R31,Y+2+1
	SBIW R30,1
	STD  Y+2,R30
	STD  Y+2+1,R31
	ADIW R30,1
	BREQ _0x1A1
;		*d++ = (BYTE)val;
	PUSH R17
	PUSH R16
	__ADDWRN 16,17,1
	LDD  R30,Y+4
	POP  R26
	POP  R27
	ST   X,R30
	RJMP _0x19F
_0x1A1:
	RJMP _0x20C0020
; .FEND
;
;/* Compare memory to memory */
;static
;int mem_cmp (const void* dst, const void* src, UINT cnt) {
_mem_cmp_G000:
; .FSTART _mem_cmp_G000
;	const BYTE *d = (const BYTE *)dst, *s = (const BYTE *)src;
;	int r = 0;
;
;	while (cnt-- && (r = *d++ - *s++) == 0) ;
	ST   -Y,R27
	ST   -Y,R26
	CALL __SAVELOCR6
;	*dst -> Y+10
;	*src -> Y+8
;	cnt -> Y+6
;	*d -> R16,R17
;	*s -> R18,R19
;	r -> R20,R21
	__GETWRS 16,17,10
	__GETWRS 18,19,8
	__GETWRN 20,21,0
_0x1A2:
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	SBIW R30,1
	STD  Y+6,R30
	STD  Y+6+1,R31
	ADIW R30,1
	BREQ _0x1A5
	MOVW R26,R16
	__ADDWRN 16,17,1
	LD   R0,X
	CLR  R1
	MOVW R26,R18
	__ADDWRN 18,19,1
	LD   R26,X
	CLR  R27
	MOVW R30,R0
	SUB  R30,R26
	SBC  R31,R27
	MOVW R20,R30
	SBIW R30,0
	BREQ _0x1A6
_0x1A5:
	RJMP _0x1A4
_0x1A6:
	RJMP _0x1A2
_0x1A4:
;	return r;
	MOVW R30,R20
	RJMP _0x20C001E
;}
; .FEND
;
;/* Check if chr is contained in the string */
;static
;int chk_chr (const char* str, int chr) {
_chk_chr_G000:
; .FSTART _chk_chr_G000
;	while (*str && *str != chr) str++;
	ST   -Y,R27
	ST   -Y,R26
;	*str -> Y+2
;	chr -> Y+0
_0x1A7:
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	LD   R30,X
	CPI  R30,0
	BREQ _0x1AA
	LD   R26,X
	LD   R30,Y
	LDD  R31,Y+1
	LDI  R27,0
	CP   R30,R26
	CPC  R31,R27
	BRNE _0x1AB
_0x1AA:
	RJMP _0x1A9
_0x1AB:
	LDD  R30,Y+2
	LDD  R31,Y+2+1
	ADIW R30,1
	STD  Y+2,R30
	STD  Y+2+1,R31
	RJMP _0x1A7
_0x1A9:
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	LD   R30,X
	LDI  R31,0
_0x20C0022:
	ADIW R28,4
	RET
;}
; .FEND
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Request/Release grant to access the volume                            */
;/*-----------------------------------------------------------------------*/
;#if _FS_REENTRANT
;static
;int lock_fs (
;	FATFS* fs		/* File system object */
;)
;{
;	return ff_req_grant(fs->sobj);
;}
;
;
;static
;void unlock_fs (
;	FATFS* fs,		/* File system object */
;	FRESULT res		/* Result code to be returned */
;)
;{
;	if (fs &&
;		res != FR_NOT_ENABLED &&
;		res != FR_INVALID_DRIVE &&
;		res != FR_INVALID_OBJECT &&
;		res != FR_TIMEOUT) {
;		ff_rel_grant(fs->sobj);
;	}
;}
;#endif
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* File lock control functions                                           */
;/*-----------------------------------------------------------------------*/
;#if _FS_LOCK
;
;static
;FRESULT chk_lock (	/* Check if the file can be accessed */
;	DIR* dp,		/* Directory object pointing the file to be checked */
;	int acc			/* Desired access (0:Read, 1:Write, 2:Delete/Rename) */
;)
;{
;	UINT i, be;
;
;	/* Search file semaphore table */
;	for (i = be = 0; i < _FS_LOCK; i++) {
;		if (Files[i].fs) {	/* Existing entry */
;			if (Files[i].fs == dp->fs &&	 	/* Check if the object matched with an open object */
;				Files[i].clu == dp->sclust &&
;				Files[i].idx == dp->index) break;
;		} else {			/* Blank entry */
;			be = 1;
;		}
;	}
;	if (i == _FS_LOCK)	/* The object is not opened */
;		return (be || acc == 2) ? FR_OK : FR_TOO_MANY_OPEN_FILES;	/* Is there a blank entry for new object? */
;
;	/* The object has been opened. Reject any open against writing file and all write mode open */
;	return (acc || Files[i].ctr == 0x100) ? FR_LOCKED : FR_OK;
;}
;
;
;static
;int enq_lock (void)	/* Check if an entry is available for a new object */
;{
;	UINT i;
;
;	for (i = 0; i < _FS_LOCK && Files[i].fs; i++) ;
;	return (i == _FS_LOCK) ? 0 : 1;
;}
;
;
;static
;UINT inc_lock (	/* Increment object open counter and returns its index (0:Internal error) */
;	DIR* dp,	/* Directory object pointing the file to register or increment */
;	int acc		/* Desired access (0:Read, 1:Write, 2:Delete/Rename) */
;)
;{
;	UINT i;
;
;
;	for (i = 0; i < _FS_LOCK; i++) {	/* Find the object */
;		if (Files[i].fs == dp->fs &&
;			Files[i].clu == dp->sclust &&
;			Files[i].idx == dp->index) break;
;	}
;
;	if (i == _FS_LOCK) {				/* Not opened. Register it as new. */
;		for (i = 0; i < _FS_LOCK && Files[i].fs; i++) ;
;		if (i == _FS_LOCK) return 0;	/* No free entry to register (int err) */
;		Files[i].fs = dp->fs;
;		Files[i].clu = dp->sclust;
;		Files[i].idx = dp->index;
;		Files[i].ctr = 0;
;	}
;
;	if (acc && Files[i].ctr) return 0;	/* Access violation (int err) */
;
;	Files[i].ctr = acc ? 0x100 : Files[i].ctr + 1;	/* Set semaphore value */
;
;	return i + 1;
;}
;
;
;static
;FRESULT dec_lock (	/* Decrement object open counter */
;	UINT i			/* Semaphore index (1..) */
;)
;{
;	WORD n;
;	FRESULT res;
;
;
;	if (--i < _FS_LOCK) {	/* Shift index number origin from 0 */
;		n = Files[i].ctr;
;		if (n == 0x100) n = 0;		/* If write mode open, delete the entry */
;		if (n) n--;					/* Decrement read mode open count */
;		Files[i].ctr = n;
;		if (!n) Files[i].fs = 0;	/* Delete the entry if open count gets zero */
;		res = FR_OK;
;	} else {
;		res = FR_INT_ERR;			/* Invalid index nunber */
;	}
;	return res;
;}
;
;
;static
;void clear_lock (	/* Clear lock entries of the volume */
;	FATFS *fs
;)
;{
;	UINT i;
;
;	for (i = 0; i < _FS_LOCK; i++) {
;		if (Files[i].fs == fs) Files[i].fs = 0;
;	}
;}
;#endif
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Move/Flush disk access window in the file system object               */
;/*-----------------------------------------------------------------------*/
;#if !_FS_READONLY
;static
;FRESULT sync_window (
;	FATFS* fs		/* File system object */
;)
;{
_sync_window_G000:
; .FSTART _sync_window_G000
;	DWORD wsect;
;	UINT nf;
;
;
;	if (fs->wflag) {	/* Write back the sector if it is dirty */
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,4
	ST   -Y,R17
	ST   -Y,R16
;	*fs -> Y+6
;	wsect -> Y+2
;	nf -> R16,R17
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LDD  R30,Z+4
	CPI  R30,0
	BRNE PC+2
	RJMP _0x1AC
;		wsect = fs->winsect;	/* Current sector number */
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADIW R26,42
	CALL __GETD1P
	__PUTD1S 2
;		if (disk_write(fs->drv, fs->win, wsect, 1))
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LDD  R26,Z+1
	ST   -Y,R26
	LDD  R30,Y+7
	LDD  R31,Y+7+1
	ADIW R30,46
	ST   -Y,R31
	ST   -Y,R30
	__GETD1S 5
	CALL __PUTPARD1
	LDI  R26,LOW(1)
	LDI  R27,0
	RCALL _disk_write
	CPI  R30,0
	BREQ _0x1AD
;			return FR_DISK_ERR;
	LDI  R30,LOW(1)
	RJMP _0x20C0020
;		fs->wflag = 0;
_0x1AD:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADIW R26,4
	LDI  R30,LOW(0)
	ST   X,R30
;		if (wsect - fs->fatbase < fs->fsize) {		/* Is it in the FAT area? */
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADIW R26,30
	CALL __GETD1P
	__GETD2S 2
	CALL __SWAPD12
	CALL __SUBD12
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADIW R26,22
	CALL __GETD1P
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __CPD21
	BRSH _0x1AE
;			for (nf = fs->n_fats; nf >= 2; nf--) {	/* Reflect the change to all FAT copies */
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LDD  R16,Z+3
	CLR  R17
_0x1B0:
	__CPWRN 16,17,2
	BRLO _0x1B1
;				wsect += fs->fsize;
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADIW R26,22
	CALL __GETD1P
	__GETD2S 2
	CALL __ADDD12
	__PUTD1S 2
;				disk_write(fs->drv, fs->win, wsect, 1);
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LDD  R26,Z+1
	ST   -Y,R26
	LDD  R30,Y+7
	LDD  R31,Y+7+1
	ADIW R30,46
	ST   -Y,R31
	ST   -Y,R30
	__GETD1S 5
	CALL __PUTPARD1
	LDI  R26,LOW(1)
	LDI  R27,0
	RCALL _disk_write
;			}
	__SUBWRN 16,17,1
	RJMP _0x1B0
_0x1B1:
;		}
;	}
_0x1AE:
;	return FR_OK;
_0x1AC:
	LDI  R30,LOW(0)
_0x20C0020:
	LDD  R17,Y+1
	LDD  R16,Y+0
_0x20C0021:
	ADIW R28,8
	RET
;}
; .FEND
;#endif
;
;
;static
;FRESULT move_window (
;	FATFS* fs,		/* File system object */
;	DWORD sector	/* Sector number to make appearance in the fs->win[] */
;)
;{
_move_window_G000:
; .FSTART _move_window_G000
;	if (sector != fs->winsect)
	CALL __PUTPARD2
;	*fs -> Y+4
;	sector -> Y+0
	LDD  R26,Y+4
	LDD  R27,Y+4+1
	ADIW R26,42
	CALL __GETD1P
	CALL __GETD2S0
	CALL __CPD12
	BREQ _0x1B2
;    {	/* Changed current window */
;#if !_FS_READONLY
;		if (sync_window(fs) != FR_OK)
	LDD  R26,Y+4
	LDD  R27,Y+4+1
	RCALL _sync_window_G000
	CPI  R30,0
	BREQ _0x1B3
;			return FR_DISK_ERR;
	LDI  R30,LOW(1)
	RJMP _0x20C001F
;#endif
;		if (disk_read(fs->drv, fs->win, sector, 1))
_0x1B3:
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	LDD  R26,Z+1
	ST   -Y,R26
	LDD  R30,Y+5
	LDD  R31,Y+5+1
	ADIW R30,46
	ST   -Y,R31
	ST   -Y,R30
	__GETD1S 3
	CALL __PUTPARD1
	LDI  R26,LOW(1)
	LDI  R27,0
	RCALL _disk_read
	CPI  R30,0
	BREQ _0x1B4
;        {
;            // PORTD.0 = 1;
;			return FR_DISK_ERR;
	LDI  R30,LOW(1)
	RJMP _0x20C001F
;        }
;		fs->winsect = sector;
_0x1B4:
	CALL __GETD1S0
	__PUTD1SNS 4,42
;	}
;
;	return FR_OK;
_0x1B2:
	LDI  R30,LOW(0)
	RJMP _0x20C001F
;}
; .FEND
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Synchronize file system and strage device                             */
;/*-----------------------------------------------------------------------*/
;#if !_FS_READONLY
;static
;FRESULT sync_fs (	/* FR_OK: successful, FR_DISK_ERR: failed */
;	FATFS* fs		/* File system object */
;)
;{
_sync_fs_G000:
; .FSTART _sync_fs_G000
;	FRESULT res;
;
;
;	res = sync_window(fs);
	ST   -Y,R27
	ST   -Y,R26
	ST   -Y,R17
;	*fs -> Y+1
;	res -> R17
	LDD  R26,Y+1
	LDD  R27,Y+1+1
	RCALL _sync_window_G000
	MOV  R17,R30
;	if (res == FR_OK) {
	CPI  R17,0
	BREQ PC+2
	RJMP _0x1B5
;		/* Update FSINFO sector if needed */
;		if (fs->fs_type == FS_FAT32 && fs->fsi_flag == 1) {
	LDD  R26,Y+1
	LDD  R27,Y+1+1
	LD   R26,X
	CPI  R26,LOW(0x3)
	BRNE _0x1B7
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	LDD  R26,Z+5
	CPI  R26,LOW(0x1)
	BREQ _0x1B8
_0x1B7:
	RJMP _0x1B6
_0x1B8:
;			/* Create FSINFO structure */
;			mem_set(fs->win, 0, SS(fs));
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	ADIW R30,46
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(512)
	LDI  R27,HIGH(512)
	RCALL _mem_set_G000
;			ST_WORD(fs->win+BS_55AA, 0xAA55);
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	ADIW R30,46
	SUBI R30,LOW(-510)
	SBCI R31,HIGH(-510)
	LDI  R26,LOW(85)
	STD  Z+0,R26
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	ADIW R30,46
	SUBI R30,LOW(-511)
	SBCI R31,HIGH(-511)
	LDI  R26,LOW(170)
	STD  Z+0,R26
;			ST_DWORD(fs->win+FSI_LeadSig, 0x41615252);
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	ADIW R30,46
	LDI  R26,LOW(82)
	STD  Z+0,R26
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	ADIW R30,47
	STD  Z+0,R26
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	ADIW R30,48
	LDI  R26,LOW(97)
	STD  Z+0,R26
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	ADIW R30,49
	LDI  R26,LOW(65)
	STD  Z+0,R26
;			ST_DWORD(fs->win+FSI_StrucSig, 0x61417272);
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	ADIW R30,46
	SUBI R30,LOW(-484)
	SBCI R31,HIGH(-484)
	LDI  R26,LOW(114)
	STD  Z+0,R26
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	ADIW R30,46
	SUBI R30,LOW(-485)
	SBCI R31,HIGH(-485)
	STD  Z+0,R26
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	ADIW R30,46
	SUBI R30,LOW(-486)
	SBCI R31,HIGH(-486)
	LDI  R26,LOW(65)
	STD  Z+0,R26
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	ADIW R30,46
	SUBI R30,LOW(-487)
	SBCI R31,HIGH(-487)
	LDI  R26,LOW(97)
	STD  Z+0,R26
;			ST_DWORD(fs->win+FSI_Free_Count, fs->free_clust);
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	ADIW R30,46
	SUBI R30,LOW(-488)
	SBCI R31,HIGH(-488)
	MOVW R26,R30
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	LDD  R30,Z+14
	ST   X,R30
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	ADIW R30,46
	SUBI R30,LOW(-489)
	SBCI R31,HIGH(-489)
	MOVW R0,R30
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	LDD  R26,Z+14
	LDD  R27,Z+15
	MOVW R30,R26
	MOV  R30,R31
	LDI  R31,0
	MOVW R26,R0
	ST   X,R30
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	ADIW R30,46
	SUBI R30,LOW(-490)
	SBCI R31,HIGH(-490)
	MOVW R0,R30
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	__GETD2Z 14
	MOVW R30,R26
	MOVW R22,R24
	CALL __LSRD16
	MOVW R26,R0
	ST   X,R30
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	ADIW R30,46
	SUBI R30,LOW(-491)
	SBCI R31,HIGH(-491)
	PUSH R31
	PUSH R30
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	__GETD2Z 14
	LDI  R30,LOW(24)
	CALL __LSRD12
	POP  R26
	POP  R27
	ST   X,R30
;			ST_DWORD(fs->win+FSI_Nxt_Free, fs->last_clust);
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	ADIW R30,46
	SUBI R30,LOW(-492)
	SBCI R31,HIGH(-492)
	MOVW R26,R30
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	LDD  R30,Z+10
	ST   X,R30
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	ADIW R30,46
	SUBI R30,LOW(-493)
	SBCI R31,HIGH(-493)
	MOVW R0,R30
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	LDD  R26,Z+10
	LDD  R27,Z+11
	MOVW R30,R26
	MOV  R30,R31
	LDI  R31,0
	MOVW R26,R0
	ST   X,R30
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	ADIW R30,46
	SUBI R30,LOW(-494)
	SBCI R31,HIGH(-494)
	MOVW R0,R30
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	__GETD2Z 10
	MOVW R30,R26
	MOVW R22,R24
	CALL __LSRD16
	MOVW R26,R0
	ST   X,R30
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	ADIW R30,46
	SUBI R30,LOW(-495)
	SBCI R31,HIGH(-495)
	PUSH R31
	PUSH R30
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	__GETD2Z 10
	LDI  R30,LOW(24)
	CALL __LSRD12
	POP  R26
	POP  R27
	ST   X,R30
;			/* Write it into the FSINFO sector */
;			fs->winsect = fs->volbase + 1;
	LDD  R26,Y+1
	LDD  R27,Y+1+1
	ADIW R26,26
	CALL __GETD1P
	__ADDD1N 1
	__PUTD1SNS 1,42
;			disk_write(fs->drv, fs->win, fs->winsect, 1);
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	LDD  R26,Z+1
	ST   -Y,R26
	LDD  R30,Y+2
	LDD  R31,Y+2+1
	ADIW R30,46
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	__GETD2Z 42
	CALL __PUTPARD2
	LDI  R26,LOW(1)
	LDI  R27,0
	RCALL _disk_write
;			fs->fsi_flag = 0;
	LDD  R26,Y+1
	LDD  R27,Y+1+1
	ADIW R26,5
	LDI  R30,LOW(0)
	ST   X,R30
;		}
;		/* Make sure that no pending write process in the physical drive */
;		if (disk_ioctl(fs->drv, CTRL_SYNC, 0) != RES_OK)
_0x1B6:
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	LDD  R26,Z+1
	ST   -Y,R26
	LDI  R30,LOW(0)
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	RCALL _disk_ioctl
	CPI  R30,0
	BREQ _0x1B9
;			res = FR_DISK_ERR;
	LDI  R17,LOW(1)
;	}
_0x1B9:
;
;	return res;
_0x1B5:
	MOV  R30,R17
	LDD  R17,Y+0
	ADIW R28,3
	RET
;}
; .FEND
;#endif
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Get sector# from cluster#                                             */
;/*-----------------------------------------------------------------------*/
;
;
;DWORD clust2sect (	/* !=0: Sector number, 0: Failed - invalid cluster# */
;	FATFS* fs,		/* File system object */
;	DWORD clst		/* Cluster# to be converted */
;)
;{
_clust2sect:
; .FSTART _clust2sect
;	clst -= 2;
	CALL __PUTPARD2
;	*fs -> Y+4
;	clst -> Y+0
	CALL __GETD1S0
	__SUBD1N 2
	CALL __PUTD1S0
;	if (clst >= (fs->n_fatent - 2)) return 0;		/* Invalid cluster# */
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	__GETD2Z 18
	__GETD1N 0x2
	CALL __SWAPD12
	CALL __SUBD12
	CALL __GETD2S0
	CALL __CPD21
	BRLO _0x1BA
	__GETD1N 0x0
	RJMP _0x20C001F
;	return clst * fs->csize + fs->database;
_0x1BA:
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	LDD  R30,Z+2
	LDI  R31,0
	CALL __GETD2S0
	CALL __CWD1
	CALL __MULD12U
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	LDD  R26,Y+4
	LDD  R27,Y+4+1
	ADIW R26,38
	CALL __GETD1P
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __ADDD12
_0x20C001F:
	ADIW R28,6
	RET
;}
; .FEND
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* FAT access - Read value of a FAT entry                                */
;/*-----------------------------------------------------------------------*/
;
;DWORD get_fat (	/* 0xFFFFFFFF:Disk error, 1:Internal error, Else:Cluster status */
;	FATFS* fs,	/* File system object */
;	DWORD clst	/* Cluster# to get the link information */
;)
;{
_get_fat:
; .FSTART _get_fat
;	UINT wc, bc;
;	BYTE *p;
;
;
;	if (clst < 2 || clst >= fs->n_fatent)	/* Check range */
	CALL __PUTPARD2
	CALL __SAVELOCR6
;	*fs -> Y+10
;	clst -> Y+6
;	wc -> R16,R17
;	bc -> R18,R19
;	*p -> R20,R21
	__GETD2S 6
	__CPD2N 0x2
	BRLO _0x1BC
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	ADIW R26,18
	CALL __GETD1P
	__GETD2S 6
	CALL __CPD21
	BRLO _0x1BB
_0x1BC:
;		return 1;
	__GETD1N 0x1
	RJMP _0x20C001E
;
;	switch (fs->fs_type) {
_0x1BB:
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	LD   R30,X
	LDI  R31,0
;	case FS_FAT12 :
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BREQ PC+2
	RJMP _0x1C1
;		bc = (UINT)clst; bc += bc / 2;
	__GETWRS 18,19,6
	MOVW R30,R18
	LSR  R31
	ROR  R30
	__ADDWRR 18,19,30,31
;		if (move_window(fs, fs->fatbase + (bc / SS(fs)))) break;
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+12
	LDD  R31,Y+12+1
	__GETD2Z 30
	PUSH R25
	PUSH R24
	PUSH R27
	PUSH R26
	MOVW R26,R18
	LDI  R30,LOW(512)
	LDI  R31,HIGH(512)
	CALL __DIVW21U
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CLR  R22
	CLR  R23
	CALL __ADDD21
	RCALL _move_window_G000
	CPI  R30,0
	BREQ _0x1C2
	RJMP _0x1C0
;		wc = fs->win[bc % SS(fs)]; bc++;
_0x1C2:
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	ADIW R26,46
	MOVW R30,R18
	ANDI R31,HIGH(0x1FF)
	ADD  R26,R30
	ADC  R27,R31
	LD   R16,X
	CLR  R17
	__ADDWRN 18,19,1
;		if (move_window(fs, fs->fatbase + (bc / SS(fs)))) break;
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+12
	LDD  R31,Y+12+1
	__GETD2Z 30
	PUSH R25
	PUSH R24
	PUSH R27
	PUSH R26
	MOVW R26,R18
	LDI  R30,LOW(512)
	LDI  R31,HIGH(512)
	CALL __DIVW21U
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CLR  R22
	CLR  R23
	CALL __ADDD21
	RCALL _move_window_G000
	CPI  R30,0
	BREQ _0x1C3
	RJMP _0x1C0
;		wc |= fs->win[bc % SS(fs)] << 8;
_0x1C3:
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	ADIW R26,46
	MOVW R30,R18
	ANDI R31,HIGH(0x1FF)
	ADD  R26,R30
	ADC  R27,R31
	LD   R30,X
	MOV  R31,R30
	LDI  R30,0
	__ORWRR 16,17,30,31
;		return clst & 1 ? wc >> 4 : (wc & 0xFFF);
	LDD  R30,Y+6
	ANDI R30,LOW(0x1)
	BREQ _0x1C4
	MOVW R30,R16
	CALL __LSRW4
	RJMP _0x4E1
_0x1C4:
	MOVW R30,R16
	ANDI R31,HIGH(0xFFF)
_0x4E1:
	CLR  R22
	CLR  R23
	RJMP _0x20C001E
;
;	case FS_FAT16 :
_0x1C1:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x1C7
;		if (move_window(fs, fs->fatbase + (clst / (SS(fs) / 2)))) break;
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+12
	LDD  R31,Y+12+1
	__GETD2Z 30
	PUSH R25
	PUSH R24
	PUSH R27
	PUSH R26
	__GETD2S 8
	__GETD1N 0x100
	CALL __DIVD21U
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __ADDD21
	RCALL _move_window_G000
	CPI  R30,0
	BREQ _0x1C8
	RJMP _0x1C0
;		p = &fs->win[clst * 2 % SS(fs)];
_0x1C8:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(2)
	CALL __MULB1W2U
	ANDI R31,HIGH(0x1FF)
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	ADIW R26,46
	ADD  R30,R26
	ADC  R31,R27
	MOVW R20,R30
;		return LD_WORD(p);
	LDD  R31,Z+1
	LDI  R30,LOW(0)
	MOVW R0,R30
	MOVW R26,R20
	LD   R30,X
	LDI  R31,0
	OR   R30,R0
	OR   R31,R1
	CLR  R22
	CLR  R23
	RJMP _0x20C001E
;
;	case FS_FAT32 :
_0x1C7:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BREQ PC+2
	RJMP _0x1C0
;		if (move_window(fs, fs->fatbase + (clst / (SS(fs) / 4))))
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+12
	LDD  R31,Y+12+1
	__GETD2Z 30
	PUSH R25
	PUSH R24
	PUSH R27
	PUSH R26
	__GETD2S 8
	__GETD1N 0x80
	CALL __DIVD21U
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __ADDD21
	RCALL _move_window_G000
	CPI  R30,0
	BRNE _0x1C0
;         {
;         break;
;         }
;		p = &fs->win[clst * 4 % SS(fs)];
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(4)
	CALL __MULB1W2U
	ANDI R31,HIGH(0x1FF)
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	ADIW R26,46
	ADD  R30,R26
	ADC  R31,R27
	MOVW R20,R30
;		return LD_DWORD(p) & 0x0FFFFFFF;
	LDD  R30,Z+3
	LDI  R31,0
	CALL __CWD1
	MOVW R26,R30
	MOVW R24,R22
	LDI  R30,LOW(24)
	CALL __LSLD12
	MOVW R26,R30
	MOVW R24,R22
	MOVW R30,R20
	LDD  R30,Z+2
	LDI  R31,0
	CALL __CWD1
	CALL __LSLD16
	CALL __ORD12
	MOVW R26,R30
	MOVW R24,R22
	MOVW R30,R20
	LDD  R31,Z+1
	LDI  R30,LOW(0)
	CLR  R22
	CLR  R23
	CALL __ORD12
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	MOVW R26,R20
	LD   R30,X
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __ORD12
	__ANDD1N 0xFFFFFFF
	RJMP _0x20C001E
;	}
_0x1C0:
;	return 0xFFFFFFFF;	/* An error occurred at the disk I/O layer */
	__GETD1N 0xFFFFFFFF
_0x20C001E:
	CALL __LOADLOCR6
	ADIW R28,12
	RET
;}
; .FEND
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* FAT access - Change value of a FAT entry                              */
;/*-----------------------------------------------------------------------*/
;#if !_FS_READONLY
;
;FRESULT put_fat (
;	FATFS* fs,	/* File system object */
;	DWORD clst,	/* Cluster# to be changed in range of 2 to fs->n_fatent - 1 */
;	DWORD val	/* New value to mark the cluster */
;)
;{
_put_fat:
; .FSTART _put_fat
;	UINT bc;
;	BYTE *p;
;	FRESULT res;
;
;
;	if (clst < 2 || clst >= fs->n_fatent) {	/* Check range */
	CALL __PUTPARD2
	CALL __SAVELOCR6
;	*fs -> Y+14
;	clst -> Y+10
;	val -> Y+6
;	bc -> R16,R17
;	*p -> R18,R19
;	res -> R21
	__GETD2S 10
	__CPD2N 0x2
	BRLO _0x1CC
	LDD  R26,Y+14
	LDD  R27,Y+14+1
	ADIW R26,18
	CALL __GETD1P
	__GETD2S 10
	CALL __CPD21
	BRLO _0x1CB
_0x1CC:
;		res = FR_INT_ERR;
	LDI  R21,LOW(2)
;
;	} else {
	RJMP _0x1CE
_0x1CB:
;		switch (fs->fs_type) {
	LDD  R26,Y+14
	LDD  R27,Y+14+1
	LD   R30,X
	LDI  R31,0
;		case FS_FAT12 :
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BREQ PC+2
	RJMP _0x1D2
;			bc = (UINT)clst; bc += bc / 2;
	__GETWRS 16,17,10
	MOVW R30,R16
	LSR  R31
	ROR  R30
	__ADDWRR 16,17,30,31
;			res = move_window(fs, fs->fatbase + (bc / SS(fs)));
	LDD  R30,Y+14
	LDD  R31,Y+14+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+16
	LDD  R31,Y+16+1
	__GETD2Z 30
	PUSH R25
	PUSH R24
	PUSH R27
	PUSH R26
	MOVW R26,R16
	LDI  R30,LOW(512)
	LDI  R31,HIGH(512)
	CALL __DIVW21U
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CLR  R22
	CLR  R23
	CALL __ADDD21
	RCALL _move_window_G000
	MOV  R21,R30
;			if (res != FR_OK) break;
	CPI  R21,0
	BREQ _0x1D3
	RJMP _0x1D1
;			p = &fs->win[bc % SS(fs)];
_0x1D3:
	LDD  R26,Y+14
	LDD  R27,Y+14+1
	ADIW R26,46
	MOVW R30,R16
	ANDI R31,HIGH(0x1FF)
	ADD  R30,R26
	ADC  R31,R27
	MOVW R18,R30
;			*p = (clst & 1) ? ((*p & 0x0F) | ((BYTE)val << 4)) : (BYTE)val;
	LDD  R30,Y+10
	ANDI R30,LOW(0x1)
	BREQ _0x1D4
	MOVW R26,R18
	LD   R30,X
	ANDI R30,LOW(0xF)
	MOV  R26,R30
	LDD  R30,Y+6
	LDI  R31,0
	CALL __LSLW4
	OR   R30,R26
	RJMP _0x1D5
_0x1D4:
	LDD  R30,Y+6
_0x1D5:
	MOVW R26,R18
	ST   X,R30
;			bc++;
	__ADDWRN 16,17,1
;			fs->wflag = 1;
	LDD  R26,Y+14
	LDD  R27,Y+14+1
	ADIW R26,4
	LDI  R30,LOW(1)
	ST   X,R30
;			res = move_window(fs, fs->fatbase + (bc / SS(fs)));
	LDD  R30,Y+14
	LDD  R31,Y+14+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+16
	LDD  R31,Y+16+1
	__GETD2Z 30
	PUSH R25
	PUSH R24
	PUSH R27
	PUSH R26
	MOVW R26,R16
	LDI  R30,LOW(512)
	LDI  R31,HIGH(512)
	CALL __DIVW21U
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CLR  R22
	CLR  R23
	CALL __ADDD21
	RCALL _move_window_G000
	MOV  R21,R30
;			if (res != FR_OK) break;
	CPI  R21,0
	BREQ _0x1D7
	RJMP _0x1D1
;			p = &fs->win[bc % SS(fs)];
_0x1D7:
	LDD  R26,Y+14
	LDD  R27,Y+14+1
	ADIW R26,46
	MOVW R30,R16
	ANDI R31,HIGH(0x1FF)
	ADD  R30,R26
	ADC  R31,R27
	MOVW R18,R30
;			*p = (clst & 1) ? (BYTE)(val >> 4) : ((*p & 0xF0) | ((BYTE)(val >> 8) & 0x0F));
	LDD  R30,Y+10
	ANDI R30,LOW(0x1)
	BREQ _0x1D8
	__GETD2S 6
	LDI  R30,LOW(4)
	CALL __LSRD12
	CLR  R31
	CLR  R22
	CLR  R23
	RJMP _0x1D9
_0x1D8:
	MOVW R26,R18
	LD   R30,X
	ANDI R30,LOW(0xF0)
	MOV  R1,R30
	__GETD2S 6
	LDI  R30,LOW(8)
	CALL __LSRD12
	CLR  R31
	CLR  R22
	CLR  R23
	ANDI R30,LOW(0xF)
	OR   R30,R1
_0x1D9:
	MOVW R26,R18
	ST   X,R30
;			break;
	RJMP _0x1D1
;
;		case FS_FAT16 :
_0x1D2:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x1DB
;			res = move_window(fs, fs->fatbase + (clst / (SS(fs) / 2)));
	LDD  R30,Y+14
	LDD  R31,Y+14+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+16
	LDD  R31,Y+16+1
	__GETD2Z 30
	PUSH R25
	PUSH R24
	PUSH R27
	PUSH R26
	__GETD2S 12
	__GETD1N 0x100
	CALL __DIVD21U
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __ADDD21
	RCALL _move_window_G000
	MOV  R21,R30
;			if (res != FR_OK) break;
	CPI  R21,0
	BREQ _0x1DC
	RJMP _0x1D1
;			p = &fs->win[clst * 2 % SS(fs)];
_0x1DC:
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	LDI  R30,LOW(2)
	CALL __MULB1W2U
	ANDI R31,HIGH(0x1FF)
	LDD  R26,Y+14
	LDD  R27,Y+14+1
	ADIW R26,46
	ADD  R30,R26
	ADC  R31,R27
	MOVW R18,R30
;			ST_WORD(p, (WORD)val);
	LDD  R30,Y+6
	MOVW R26,R18
	ST   X,R30
	LDD  R30,Y+7
	__PUTB1RNS 18,1
;			break;
	RJMP _0x1D1
;
;		case FS_FAT32 :
_0x1DB:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BREQ PC+2
	RJMP _0x1DF
;			res = move_window(fs, fs->fatbase + (clst / (SS(fs) / 4)));
	LDD  R30,Y+14
	LDD  R31,Y+14+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+16
	LDD  R31,Y+16+1
	__GETD2Z 30
	PUSH R25
	PUSH R24
	PUSH R27
	PUSH R26
	__GETD2S 12
	__GETD1N 0x80
	CALL __DIVD21U
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __ADDD21
	RCALL _move_window_G000
	MOV  R21,R30
;			if (res != FR_OK) break;
	CPI  R21,0
	BREQ _0x1DE
	RJMP _0x1D1
;			p = &fs->win[clst * 4 % SS(fs)];
_0x1DE:
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	LDI  R30,LOW(4)
	CALL __MULB1W2U
	ANDI R31,HIGH(0x1FF)
	LDD  R26,Y+14
	LDD  R27,Y+14+1
	ADIW R26,46
	ADD  R30,R26
	ADC  R31,R27
	MOVW R18,R30
;			val |= LD_DWORD(p) & 0xF0000000;
	LDD  R30,Z+3
	LDI  R31,0
	CALL __CWD1
	MOVW R26,R30
	MOVW R24,R22
	LDI  R30,LOW(24)
	CALL __LSLD12
	MOVW R26,R30
	MOVW R24,R22
	MOVW R30,R18
	LDD  R30,Z+2
	LDI  R31,0
	CALL __CWD1
	CALL __LSLD16
	CALL __ORD12
	MOVW R26,R30
	MOVW R24,R22
	MOVW R30,R18
	LDD  R31,Z+1
	LDI  R30,LOW(0)
	CLR  R22
	CLR  R23
	CALL __ORD12
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	MOVW R26,R18
	LD   R30,X
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __ORD12
	__ANDD1N 0xF0000000
	__GETD2S 6
	CALL __ORD12
	__PUTD1S 6
;			ST_DWORD(p, val);
	LDD  R30,Y+6
	MOVW R26,R18
	ST   X,R30
	LDD  R30,Y+7
	__PUTB1RNS 18,1
	__GETD1S 6
	CALL __LSRD16
	__PUTB1RNS 18,2
	__GETD2S 6
	LDI  R30,LOW(24)
	CALL __LSRD12
	__PUTB1RNS 18,3
;			break;
	RJMP _0x1D1
;
;		default :
_0x1DF:
;			res = FR_INT_ERR;
	LDI  R21,LOW(2)
;		}
_0x1D1:
;		fs->wflag = 1;
	LDD  R26,Y+14
	LDD  R27,Y+14+1
	ADIW R26,4
	LDI  R30,LOW(1)
	ST   X,R30
;	}
_0x1CE:
;
;	return res;
	MOV  R30,R21
	CALL __LOADLOCR6
	ADIW R28,16
	RET
;}
; .FEND
;#endif /* !_FS_READONLY */
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* FAT handling - Remove a cluster chain                                 */
;/*-----------------------------------------------------------------------*/
;#if !_FS_READONLY
;static
;FRESULT remove_chain (
;	FATFS* fs,			/* File system object */
;	DWORD clst			/* Cluster# to remove a chain from */
;)
;{
_remove_chain_G000:
; .FSTART _remove_chain_G000
;	FRESULT res;
;	DWORD nxt;
;#if _USE_ERASE
;	DWORD scl = clst, ecl = clst, rt[2];
;#endif
;
;	if (clst < 2 || clst >= fs->n_fatent) {	/* Check range */
	CALL __PUTPARD2
	SBIW R28,4
	ST   -Y,R17
;	*fs -> Y+9
;	clst -> Y+5
;	res -> R17
;	nxt -> Y+1
	__GETD2S 5
	__CPD2N 0x2
	BRLO _0x1E1
	LDD  R26,Y+9
	LDD  R27,Y+9+1
	ADIW R26,18
	CALL __GETD1P
	__GETD2S 5
	CALL __CPD21
	BRLO _0x1E0
_0x1E1:
;		res = FR_INT_ERR;
	LDI  R17,LOW(2)
;
;	} else {
	RJMP _0x1E3
_0x1E0:
;		res = FR_OK;
	LDI  R17,LOW(0)
;		while (clst < fs->n_fatent) {			/* Not a last link? */
_0x1E4:
	LDD  R26,Y+9
	LDD  R27,Y+9+1
	ADIW R26,18
	CALL __GETD1P
	__GETD2S 5
	CALL __CPD21
	BRLO PC+2
	RJMP _0x1E6
;			nxt = get_fat(fs, clst);			/* Get cluster status */
	LDD  R30,Y+9
	LDD  R31,Y+9+1
	ST   -Y,R31
	ST   -Y,R30
	__GETD2S 7
	RCALL _get_fat
	__PUTD1S 1
;			if (nxt == 0) break;				/* Empty cluster? */
	CALL __CPD10
	BRNE _0x1E7
	RJMP _0x1E6
;			if (nxt == 1) { res = FR_INT_ERR; break; }	/* Internal error? */
_0x1E7:
	__GETD2S 1
	__CPD2N 0x1
	BRNE _0x1E8
	LDI  R17,LOW(2)
	RJMP _0x1E6
;			if (nxt == 0xFFFFFFFF) { res = FR_DISK_ERR; break; }	/* Disk error? */
_0x1E8:
	__GETD2S 1
	__CPD2N 0xFFFFFFFF
	BRNE _0x1E9
	LDI  R17,LOW(1)
	RJMP _0x1E6
;			res = put_fat(fs, clst, 0);			/* Mark the cluster "empty" */
_0x1E9:
	LDD  R30,Y+9
	LDD  R31,Y+9+1
	ST   -Y,R31
	ST   -Y,R30
	__GETD1S 7
	CALL __PUTPARD1
	__GETD2N 0x0
	RCALL _put_fat
	MOV  R17,R30
;			if (res != FR_OK) break;
	CPI  R17,0
	BRNE _0x1E6
;			if (fs->free_clust != 0xFFFFFFFF) {	/* Update FSINFO */
	LDD  R30,Y+9
	LDD  R31,Y+9+1
	__GETD2Z 14
	__CPD2N 0xFFFFFFFF
	BREQ _0x1EB
;				fs->free_clust++;
	LDD  R26,Y+9
	LDD  R27,Y+9+1
	ADIW R26,14
	CALL __GETD1P_INC
	__SUBD1N -1
	CALL __PUTDP1_DEC
;				fs->fsi_flag |= 1;
	LDD  R26,Y+9
	LDD  R27,Y+9+1
	ADIW R26,5
	LD   R30,X
	ORI  R30,1
	ST   X,R30
;			}
;#if _USE_ERASE
;			if (ecl + 1 == nxt) {	/* Is next cluster contiguous? */
;				ecl = nxt;
;			} else {				/* End of contiguous clusters */
;				rt[0] = clust2sect(fs, scl);					/* Start sector */
;				rt[1] = clust2sect(fs, ecl) + fs->csize - 1;	/* End sector */
;				disk_ioctl(fs->drv, CTRL_ERASE_SECTOR, rt);		/* Erase the block */
;				scl = ecl = nxt;
;			}
;#endif
;			clst = nxt;	/* Next cluster */
_0x1EB:
	__GETD1S 1
	__PUTD1S 5
;		}
	RJMP _0x1E4
_0x1E6:
;	}
_0x1E3:
;
;	return res;
	MOV  R30,R17
	LDD  R17,Y+0
	ADIW R28,11
	RET
;}
; .FEND
;#endif
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* FAT handling - Stretch or Create a cluster chain                      */
;/*-----------------------------------------------------------------------*/
;#if !_FS_READONLY
;static
;DWORD create_chain (	/* 0:No free cluster, 1:Internal error, 0xFFFFFFFF:Disk error, >=2:New cluster# */
;	FATFS* fs,			/* File system object */
;	DWORD clst			/* Cluster# to stretch. 0 means create a new chain. */
;)
;{
_create_chain_G000:
; .FSTART _create_chain_G000
;	DWORD cs, ncl, scl;
;	FRESULT res;
;
;
;	if (clst == 0) {		/* Create a new chain */
	CALL __PUTPARD2
	SBIW R28,12
	ST   -Y,R17
;	*fs -> Y+17
;	clst -> Y+13
;	cs -> Y+9
;	ncl -> Y+5
;	scl -> Y+1
;	res -> R17
	__GETD1S 13
	CALL __CPD10
	BRNE _0x1EC
;		scl = fs->last_clust;			/* Get suggested start point */
	LDD  R26,Y+17
	LDD  R27,Y+17+1
	ADIW R26,10
	CALL __GETD1P
	__PUTD1S 1
;		if (!scl || scl >= fs->n_fatent) scl = 1;
	CALL __CPD10
	BREQ _0x1EE
	LDD  R26,Y+17
	LDD  R27,Y+17+1
	ADIW R26,18
	CALL __GETD1P
	__GETD2S 1
	CALL __CPD21
	BRLO _0x1ED
_0x1EE:
	__GETD1N 0x1
	__PUTD1S 1
;	}
_0x1ED:
;	else {					/* Stretch the current chain */
	RJMP _0x1F0
_0x1EC:
;		cs = get_fat(fs, clst);			/* Check the cluster status */
	LDD  R30,Y+17
	LDD  R31,Y+17+1
	ST   -Y,R31
	ST   -Y,R30
	__GETD2S 15
	RCALL _get_fat
	__PUTD1S 9
;		if (cs < 2) return 1;			/* It is an invalid cluster */
	__GETD2S 9
	__CPD2N 0x2
	BRSH _0x1F1
	__GETD1N 0x1
	RJMP _0x20C001D
;		if (cs < fs->n_fatent) return cs;	/* It is already followed by next cluster */
_0x1F1:
	LDD  R26,Y+17
	LDD  R27,Y+17+1
	ADIW R26,18
	CALL __GETD1P
	__GETD2S 9
	CALL __CPD21
	BRSH _0x1F2
	__GETD1S 9
	RJMP _0x20C001D
;		scl = clst;
_0x1F2:
	__GETD1S 13
	__PUTD1S 1
;	}
_0x1F0:
;
;	ncl = scl;				/* Start cluster */
	__GETD1S 1
	__PUTD1S 5
;	for (;;) {
_0x1F4:
;		ncl++;							/* Next cluster */
	__GETD1S 5
	__SUBD1N -1
	__PUTD1S 5
;		if (ncl >= fs->n_fatent) {		/* Wrap around */
	LDD  R26,Y+17
	LDD  R27,Y+17+1
	ADIW R26,18
	CALL __GETD1P
	__GETD2S 5
	CALL __CPD21
	BRLO _0x1F6
;			ncl = 2;
	__GETD1N 0x2
	__PUTD1S 5
;			if (ncl > scl) return 0;	/* No free cluster */
	__GETD1S 1
	__GETD2S 5
	CALL __CPD12
	BRSH _0x1F7
	__GETD1N 0x0
	RJMP _0x20C001D
;		}
_0x1F7:
;		cs = get_fat(fs, ncl);			/* Get the cluster status */
_0x1F6:
	LDD  R30,Y+17
	LDD  R31,Y+17+1
	ST   -Y,R31
	ST   -Y,R30
	__GETD2S 7
	RCALL _get_fat
	__PUTD1S 9
;		if (cs == 0) break;				/* Found a free cluster */
	CALL __CPD10
	BREQ _0x1F5
;		if (cs == 0xFFFFFFFF || cs == 1)/* An error occurred */
	__GETD2S 9
	__CPD2N 0xFFFFFFFF
	BREQ _0x1FA
	__CPD2N 0x1
	BRNE _0x1F9
_0x1FA:
;			return cs;
	__GETD1S 9
	RJMP _0x20C001D
;		if (ncl == scl) return 0;		/* No free cluster */
_0x1F9:
	__GETD1S 1
	__GETD2S 5
	CALL __CPD12
	BRNE _0x1FC
	__GETD1N 0x0
	RJMP _0x20C001D
;	}
_0x1FC:
	RJMP _0x1F4
_0x1F5:
;
;	res = put_fat(fs, ncl, 0x0FFFFFFF);	/* Mark the new cluster "last link" */
	LDD  R30,Y+17
	LDD  R31,Y+17+1
	ST   -Y,R31
	ST   -Y,R30
	__GETD1S 7
	CALL __PUTPARD1
	__GETD2N 0xFFFFFFF
	RCALL _put_fat
	MOV  R17,R30
;	if (res == FR_OK && clst != 0) {
	CPI  R17,0
	BRNE _0x1FE
	__GETD2S 13
	CALL __CPD02
	BRNE _0x1FF
_0x1FE:
	RJMP _0x1FD
_0x1FF:
;		res = put_fat(fs, clst, ncl);	/* Link it to the previous one if needed */
	LDD  R30,Y+17
	LDD  R31,Y+17+1
	ST   -Y,R31
	ST   -Y,R30
	__GETD1S 15
	CALL __PUTPARD1
	__GETD2S 11
	RCALL _put_fat
	MOV  R17,R30
;	}
;	if (res == FR_OK) {
_0x1FD:
	CPI  R17,0
	BRNE _0x200
;		fs->last_clust = ncl;			/* Update FSINFO */
	__GETD1S 5
	__PUTD1SNS 17,10
;		if (fs->free_clust != 0xFFFFFFFF) {
	LDD  R30,Y+17
	LDD  R31,Y+17+1
	__GETD2Z 14
	__CPD2N 0xFFFFFFFF
	BREQ _0x201
;			fs->free_clust--;
	LDD  R26,Y+17
	LDD  R27,Y+17+1
	ADIW R26,14
	CALL __GETD1P_INC
	SBIW R30,1
	SBCI R22,0
	SBCI R23,0
	CALL __PUTDP1_DEC
;			fs->fsi_flag |= 1;
	LDD  R26,Y+17
	LDD  R27,Y+17+1
	ADIW R26,5
	LD   R30,X
	ORI  R30,1
	ST   X,R30
;		}
;	} else {
_0x201:
	RJMP _0x202
_0x200:
;		ncl = (res == FR_DISK_ERR) ? 0xFFFFFFFF : 1;
	MOV  R26,R17
	LDI  R27,0
	SBIW R26,1
	BRNE _0x203
	__GETD1N 0xFFFFFFFF
	RJMP _0x204
_0x203:
	__GETD1N 0x1
_0x204:
	__PUTD1S 5
;	}
_0x202:
;
;	return ncl;		/* Return new cluster number or error code */
	__GETD1S 5
_0x20C001D:
	LDD  R17,Y+0
	ADIW R28,19
	RET
;}
; .FEND
;#endif /* !_FS_READONLY */
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* FAT handling - Convert offset into cluster with link map table        */
;/*-----------------------------------------------------------------------*/
;
;#if _USE_FASTSEEK
;static
;DWORD clmt_clust (	/* <2:Error, >=2:Cluster number */
;	FIL* fp,		/* Pointer to the file object */
;	DWORD ofs		/* File offset to be converted to cluster# */
;)
;{
;	DWORD cl, ncl, *tbl;
;
;
;	tbl = fp->cltbl + 1;	/* Top of CLMT */
;	cl = ofs / SS(fp->fs) / fp->fs->csize;	/* Cluster order from top of the file */
;	for (;;) {
;		ncl = *tbl++;			/* Number of cluters in the fragment */
;		if (!ncl) return 0;		/* End of table? (error) */
;		if (cl < ncl) break;	/* In this fragment? */
;		cl -= ncl; tbl++;		/* Next fragment */
;	}
;	return cl + *tbl;	/* Return the cluster number */
;}
;#endif	/* _USE_FASTSEEK */
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Directory handling - Set directory index                              */
;/*-----------------------------------------------------------------------*/
;
;static
;FRESULT dir_sdi (
;	DIR* dp,		/* Pointer to directory object */
;	WORD idx		/* Index of directory table */
;)
;{
_dir_sdi_G000:
; .FSTART _dir_sdi_G000
;	DWORD clst;
;	WORD ic;
;
;
;	dp->index = idx;
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,4
	ST   -Y,R17
	ST   -Y,R16
;	*dp -> Y+8
;	idx -> Y+6
;	clst -> Y+2
;	ic -> R16,R17
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	__PUTW1SNS 8,4
;	clst = dp->sclust;
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	ADIW R26,6
	CALL __GETD1P
	__PUTD1S 2
;	if (clst == 1 || clst >= dp->fs->n_fatent)	/* Check start cluster range */
	__GETD2S 2
	__CPD2N 0x1
	BREQ _0x207
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __GETW1P
	ADIW R30,18
	MOVW R26,R30
	CALL __GETD1P
	__GETD2S 2
	CALL __CPD21
	BRLO _0x206
_0x207:
;		return FR_INT_ERR;
	LDI  R30,LOW(2)
	LDD  R17,Y+1
	LDD  R16,Y+0
	RJMP _0x20C001A
;	if (!clst && dp->fs->fs_type == FS_FAT32)	/* Replace cluster# 0 with root cluster# if in FAT32 */
_0x206:
	__GETD1S 2
	CALL __CPD10
	BRNE _0x20A
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __GETW1P
	LD   R26,Z
	CPI  R26,LOW(0x3)
	BREQ _0x20B
_0x20A:
	RJMP _0x209
_0x20B:
;		clst = dp->fs->dirbase;
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __GETW1P
	ADIW R30,34
	MOVW R26,R30
	CALL __GETD1P
	__PUTD1S 2
;
;	if (clst == 0) {	/* Static table (root-directory in FAT12/16) */
_0x209:
	__GETD1S 2
	CALL __CPD10
	BRNE _0x20C
;		dp->clust = clst;
	__PUTD1SNS 8,10
;		if (idx >= dp->fs->n_rootdir)		/* Index is out of range */
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __GETW1P
	ADIW R30,8
	MOVW R26,R30
	CALL __GETW1P
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	CP   R26,R30
	CPC  R27,R31
	BRLO _0x20D
;			return FR_INT_ERR;
	LDI  R30,LOW(2)
	LDD  R17,Y+1
	LDD  R16,Y+0
	RJMP _0x20C001A
;		dp->sect = dp->fs->dirbase + idx / (SS(dp->fs) / SZ_DIR);	/* Sector# */
_0x20D:
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __GETW1P
	ADIW R30,34
	MOVW R26,R30
	CALL __GETD1P
	RJMP _0x4E2
;	}
;	else {				/* Dynamic table (sub-dirs or root-directory in FAT32) */
_0x20C:
;		ic = SS(dp->fs) / SZ_DIR * dp->fs->csize;	/* Entries per cluster */
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __GETW1P
	LDD  R30,Z+2
	LDI  R26,LOW(16)
	MUL  R30,R26
	MOVW R16,R0
;		while (idx >= ic) {	/* Follow cluster chain */
_0x20F:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	CP   R26,R16
	CPC  R27,R17
	BRSH PC+2
	RJMP _0x211
;			clst = get_fat(dp->fs, clst);				/* Get next cluster */
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	__GETD2S 4
	RCALL _get_fat
	__PUTD1S 2
;			if (clst == 0xFFFFFFFF) return FR_DISK_ERR;	/* Disk error */
	__GETD2S 2
	__CPD2N 0xFFFFFFFF
	BRNE _0x212
	LDI  R30,LOW(1)
	LDD  R17,Y+1
	LDD  R16,Y+0
	RJMP _0x20C001A
;			if (clst < 2 || clst >= dp->fs->n_fatent)	/* Reached to end of table or int error */
_0x212:
	__GETD2S 2
	__CPD2N 0x2
	BRLO _0x214
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __GETW1P
	ADIW R30,18
	MOVW R26,R30
	CALL __GETD1P
	__GETD2S 2
	CALL __CPD21
	BRLO _0x213
_0x214:
;				return FR_INT_ERR;
	LDI  R30,LOW(2)
	LDD  R17,Y+1
	LDD  R16,Y+0
	RJMP _0x20C001A
;			idx -= ic;
_0x213:
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	SUB  R30,R16
	SBC  R31,R17
	STD  Y+6,R30
	STD  Y+6+1,R31
;		}
	RJMP _0x20F
_0x211:
;		dp->clust = clst;
	__GETD1S 2
	__PUTD1SNS 8,10
;		dp->sect = clust2sect(dp->fs, clst) + idx / (SS(dp->fs) / SZ_DIR);	/* Sector# */
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	__GETD2S 4
	RCALL _clust2sect
_0x4E2:
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	CALL __LSRW4
	CLR  R22
	CLR  R23
	CALL __ADDD12
	__PUTD1SNS 8,14
;	}
;
;	dp->dir = dp->fs->win + (idx % (SS(dp->fs) / SZ_DIR)) * SZ_DIR;	/* Ptr to the entry in the sector */
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __GETW1P
	ADIW R30,46
	MOVW R26,R30
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ANDI R30,LOW(0xF)
	ANDI R31,HIGH(0xF)
	LSL  R30
	CALL __LSLW4
	ADD  R30,R26
	ADC  R31,R27
	__PUTW1SNS 8,18
;
;	return FR_OK;	/* Seek succeeded */
	LDI  R30,LOW(0)
	LDD  R17,Y+1
	LDD  R16,Y+0
	RJMP _0x20C001A
;}
; .FEND
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Directory handling - Move directory table index next                  */
;/*-----------------------------------------------------------------------*/
;
;static
;FRESULT dir_next (	/* FR_OK:Succeeded, FR_NO_FILE:End of table, FR_DENIED:Could not stretch */
;	DIR* dp,		/* Pointer to the directory object */
;	int stretch		/* 0: Do not stretch table, 1: Stretch table if needed */
;)
;{
_dir_next_G000:
; .FSTART _dir_next_G000
;	DWORD clst;
;	WORD i;
;
;
;	i = dp->index + 1;
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,4
	ST   -Y,R17
	ST   -Y,R16
;	*dp -> Y+8
;	stretch -> Y+6
;	clst -> Y+2
;	i -> R16,R17
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	ADIW R26,4
	CALL __GETW1P
	ADIW R30,1
	MOVW R16,R30
;	if (!i || !dp->sect)	/* Report EOT when index has reached 65535 */
	MOV  R0,R16
	OR   R0,R17
	BREQ _0x217
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	ADIW R26,14
	CALL __GETD1P
	CALL __CPD10
	BRNE _0x216
_0x217:
;		return FR_NO_FILE;
	LDI  R30,LOW(4)
	LDD  R17,Y+1
	LDD  R16,Y+0
	RJMP _0x20C001A
;
;	if (!(i % (SS(dp->fs) / SZ_DIR))) {	/* Sector changed? */
_0x216:
	MOVW R30,R16
	ANDI R30,LOW(0xF)
	BREQ PC+2
	RJMP _0x219
;		dp->sect++;					/* Next sector */
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	ADIW R26,14
	CALL __GETD1P_INC
	__SUBD1N -1
	CALL __PUTDP1_DEC
;
;		if (!dp->clust) {		/* Static table */
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	ADIW R26,10
	CALL __GETD1P
	CALL __CPD10
	BRNE _0x21A
;			if (i >= dp->fs->n_rootdir)	/* Report EOT if it reached end of static table */
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __GETW1P
	ADIW R30,8
	MOVW R26,R30
	CALL __GETW1P
	CP   R16,R30
	CPC  R17,R31
	BRLO _0x21B
;				return FR_NO_FILE;
	LDI  R30,LOW(4)
	LDD  R17,Y+1
	LDD  R16,Y+0
	RJMP _0x20C001A
;		}
_0x21B:
;		else {					/* Dynamic table */
	RJMP _0x21C
_0x21A:
;			if (((i / (SS(dp->fs) / SZ_DIR)) & (dp->fs->csize - 1)) == 0) {	/* Cluster changed? */
	MOVW R30,R16
	CALL __LSRW4
	MOVW R0,R30
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __GETW1P
	LDD  R30,Z+2
	LDI  R31,0
	SBIW R30,1
	AND  R30,R0
	AND  R31,R1
	SBIW R30,0
	BREQ PC+2
	RJMP _0x21D
;				clst = get_fat(dp->fs, dp->clust);				/* Get next cluster */
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	__GETD2Z 10
	RCALL _get_fat
	__PUTD1S 2
;				if (clst <= 1) return FR_INT_ERR;
	__GETD2S 2
	__CPD2N 0x2
	BRSH _0x21E
	LDI  R30,LOW(2)
	LDD  R17,Y+1
	LDD  R16,Y+0
	RJMP _0x20C001A
;				if (clst == 0xFFFFFFFF) return FR_DISK_ERR;
_0x21E:
	__GETD2S 2
	__CPD2N 0xFFFFFFFF
	BRNE _0x21F
	LDI  R30,LOW(1)
	LDD  R17,Y+1
	LDD  R16,Y+0
	RJMP _0x20C001A
;				if (clst >= dp->fs->n_fatent) {					/* If it reached end of dynamic table, */
_0x21F:
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __GETW1P
	ADIW R30,18
	MOVW R26,R30
	CALL __GETD1P
	__GETD2S 2
	CALL __CPD21
	BRSH PC+2
	RJMP _0x220
;#if !_FS_READONLY
;					BYTE c;
;					if (!stretch) return FR_NO_FILE;			/* If do not stretch, report EOT */
	SBIW R28,1
;	*dp -> Y+9
;	stretch -> Y+7
;	clst -> Y+3
;	c -> Y+0
	LDD  R30,Y+7
	LDD  R31,Y+7+1
	SBIW R30,0
	BRNE _0x221
	LDI  R30,LOW(4)
	ADIW R28,1
	LDD  R17,Y+1
	LDD  R16,Y+0
	RJMP _0x20C001A
;					clst = create_chain(dp->fs, dp->clust);		/* Stretch cluster chain */
_0x221:
	LDD  R26,Y+9
	LDD  R27,Y+9+1
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+11
	LDD  R31,Y+11+1
	__GETD2Z 10
	RCALL _create_chain_G000
	__PUTD1S 3
;					if (clst == 0) return FR_DENIED;			/* No free cluster */
	CALL __CPD10
	BRNE _0x222
	LDI  R30,LOW(7)
	ADIW R28,1
	LDD  R17,Y+1
	LDD  R16,Y+0
	RJMP _0x20C001A
;					if (clst == 1) return FR_INT_ERR;
_0x222:
	__GETD2S 3
	__CPD2N 0x1
	BRNE _0x223
	LDI  R30,LOW(2)
	ADIW R28,1
	LDD  R17,Y+1
	LDD  R16,Y+0
	RJMP _0x20C001A
;					if (clst == 0xFFFFFFFF) return FR_DISK_ERR;
_0x223:
	__GETD2S 3
	__CPD2N 0xFFFFFFFF
	BRNE _0x224
	LDI  R30,LOW(1)
	ADIW R28,1
	LDD  R17,Y+1
	LDD  R16,Y+0
	RJMP _0x20C001A
;					/* Clean-up stretched table */
;					if (sync_window(dp->fs)) return FR_DISK_ERR;/* Flush disk access window */
_0x224:
	LDD  R26,Y+9
	LDD  R27,Y+9+1
	CALL __GETW1P
	MOVW R26,R30
	CALL _sync_window_G000
	CPI  R30,0
	BREQ _0x225
	LDI  R30,LOW(1)
	ADIW R28,1
	LDD  R17,Y+1
	LDD  R16,Y+0
	RJMP _0x20C001A
;					mem_set(dp->fs->win, 0, SS(dp->fs));		/* Clear window buffer */
_0x225:
	LDD  R26,Y+9
	LDD  R27,Y+9+1
	CALL __GETW1P
	ADIW R30,46
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(512)
	LDI  R27,HIGH(512)
	CALL _mem_set_G000
;					dp->fs->winsect = clust2sect(dp->fs, clst);	/* Cluster start sector */
	LDD  R26,Y+9
	LDD  R27,Y+9+1
	CALL __GETW1P
	MOVW R26,R30
	ADIW R30,42
	PUSH R31
	PUSH R30
	MOVW R30,R26
	ST   -Y,R31
	ST   -Y,R30
	__GETD2S 5
	RCALL _clust2sect
	POP  R26
	POP  R27
	CALL __PUTDP1
;					for (c = 0; c < dp->fs->csize; c++) {		/* Fill the new cluster with 0 */
	LDI  R30,LOW(0)
	ST   Y,R30
_0x227:
	LDD  R26,Y+9
	LDD  R27,Y+9+1
	CALL __GETW1P
	LDD  R30,Z+2
	LD   R26,Y
	CP   R26,R30
	BRSH _0x228
;						dp->fs->wflag = 1;
	LDD  R26,Y+9
	LDD  R27,Y+9+1
	CALL __GETW1P
	ADIW R30,4
	LDI  R26,LOW(1)
	STD  Z+0,R26
;						if (sync_window(dp->fs)) return FR_DISK_ERR;
	LDD  R26,Y+9
	LDD  R27,Y+9+1
	CALL __GETW1P
	MOVW R26,R30
	CALL _sync_window_G000
	CPI  R30,0
	BREQ _0x229
	LDI  R30,LOW(1)
	ADIW R28,1
	LDD  R17,Y+1
	LDD  R16,Y+0
	RJMP _0x20C001A
;						dp->fs->winsect++;
_0x229:
	LDD  R26,Y+9
	LDD  R27,Y+9+1
	CALL __GETW1P
	ADIW R30,42
	MOVW R26,R30
	CALL __GETD1P_INC
	__SUBD1N -1
	CALL __PUTDP1_DEC
;					}
	LD   R30,Y
	SUBI R30,-LOW(1)
	ST   Y,R30
	RJMP _0x227
_0x228:
;					dp->fs->winsect -= c;						/* Rewind window offset */
	LDD  R26,Y+9
	LDD  R27,Y+9+1
	CALL __GETW1P
	ADIW R30,42
	PUSH R31
	PUSH R30
	MOVW R26,R30
	CALL __GETD1P
	MOVW R26,R30
	MOVW R24,R22
	LD   R30,Y
	LDI  R31,0
	CALL __CWD1
	CALL __SWAPD12
	CALL __SUBD12
	POP  R26
	POP  R27
	CALL __PUTDP1
;#else
;					if (!stretch) return FR_NO_FILE;			/* If do not stretch, report EOT */
;					return FR_NO_FILE;							/* Report EOT */
;#endif
;				}
	ADIW R28,1
;				dp->clust = clst;				/* Initialize data for new cluster */
_0x220:
	__GETD1S 2
	__PUTD1SNS 8,10
;				dp->sect = clust2sect(dp->fs, clst);
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	__GETD2S 4
	RCALL _clust2sect
	__PUTD1SNS 8,14
;			}
;		}
_0x21D:
_0x21C:
;	}
;
;	dp->index = i;	/* Current index */
_0x219:
	MOVW R30,R16
	__PUTW1SNS 8,4
;	dp->dir = dp->fs->win + (i % (SS(dp->fs) / SZ_DIR)) * SZ_DIR;	/* Current entry in the window */
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __GETW1P
	ADIW R30,46
	MOVW R26,R30
	MOVW R30,R16
	ANDI R30,LOW(0xF)
	ANDI R31,HIGH(0xF)
	LSL  R30
	CALL __LSLW4
	ADD  R30,R26
	ADC  R31,R27
	__PUTW1SNS 8,18
;
;	return FR_OK;
	LDI  R30,LOW(0)
	LDD  R17,Y+1
	LDD  R16,Y+0
	RJMP _0x20C001A
;}
; .FEND
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Directory handling - Reserve directory entry                          */
;/*-----------------------------------------------------------------------*/
;
;#if !_FS_READONLY
;static
;FRESULT dir_alloc (
;	DIR* dp,	/* Pointer to the directory object */
;	UINT nent	/* Number of contiguous entries to allocate (1-21) */
;)
;{
_dir_alloc_G000:
; .FSTART _dir_alloc_G000
;	FRESULT res;
;	UINT n;
;
;
;	res = dir_sdi(dp, 0);
	ST   -Y,R27
	ST   -Y,R26
	CALL __SAVELOCR4
;	*dp -> Y+6
;	nent -> Y+4
;	res -> R17
;	n -> R18,R19
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	RCALL _dir_sdi_G000
	MOV  R17,R30
;	if (res == FR_OK) {
	CPI  R17,0
	BRNE _0x22A
;		n = 0;
	__GETWRN 18,19,0
;		do {
_0x22C:
;			res = move_window(dp->fs, dp->sect);
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	__GETD2Z 14
	CALL _move_window_G000
	MOV  R17,R30
;			if (res != FR_OK) break;
	CPI  R17,0
	BRNE _0x22D
;			if (dp->dir[0] == DDE || dp->dir[0] == 0) {	/* Is it a blank entry? */
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LDD  R26,Z+18
	LDD  R27,Z+19
	LD   R26,X
	CPI  R26,LOW(0xE5)
	BREQ _0x230
	LDD  R26,Z+18
	LDD  R27,Z+19
	LD   R26,X
	CPI  R26,LOW(0x0)
	BRNE _0x22F
_0x230:
;				if (++n == nent) break;	/* A block of contiguous entries is found */
	MOVW R30,R18
	ADIW R30,1
	MOVW R18,R30
	MOVW R26,R30
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	CP   R30,R26
	CPC  R31,R27
	BREQ _0x22D
;			} else {
	RJMP _0x233
_0x22F:
;				n = 0;					/* Not a blank entry. Restart to search */
	__GETWRN 18,19,0
;			}
_0x233:
;			res = dir_next(dp, 1);		/* Next entry with table stretch enabled */
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(1)
	LDI  R27,0
	RCALL _dir_next_G000
	MOV  R17,R30
;		} while (res == FR_OK);
	CPI  R17,0
	BREQ _0x22C
_0x22D:
;	}
;	if (res == FR_NO_FILE) res = FR_DENIED;	/* No directory entry to allocate */
_0x22A:
	CPI  R17,4
	BRNE _0x234
	LDI  R17,LOW(7)
;	return res;
_0x234:
	RJMP _0x20C0018
;}
; .FEND
;#endif
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Directory handling - Load/Store start cluster number                  */
;/*-----------------------------------------------------------------------*/
;
;static
;DWORD ld_clust (
;	FATFS* fs,	/* Pointer to the fs object */
;	BYTE* dir	/* Pointer to the directory entry */
;)
;{
_ld_clust_G000:
; .FSTART _ld_clust_G000
;	DWORD cl;
;
;	cl = LD_WORD(dir+DIR_FstClusLO);
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,4
;	*fs -> Y+6
;	*dir -> Y+4
;	cl -> Y+0
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	LDD  R27,Z+27
	LDI  R26,LOW(0)
	LDD  R30,Z+26
	LDI  R31,0
	OR   R30,R26
	OR   R31,R27
	CLR  R22
	CLR  R23
	CALL __PUTD1S0
;	if (fs->fs_type == FS_FAT32)
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LD   R26,X
	CPI  R26,LOW(0x3)
	BRNE _0x235
;		cl |= (DWORD)LD_WORD(dir+DIR_FstClusHI) << 16;
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	LDD  R27,Z+21
	LDI  R26,LOW(0)
	LDD  R30,Z+20
	LDI  R31,0
	OR   R30,R26
	OR   R31,R27
	CLR  R22
	CLR  R23
	CALL __LSLD16
	CALL __GETD2S0
	CALL __ORD12
	CALL __PUTD1S0
;
;	return cl;
_0x235:
	CALL __GETD1S0
	RJMP _0x20C0017
;}
; .FEND
;
;
;#if !_FS_READONLY
;static
;void st_clust (
;	BYTE* dir,	/* Pointer to the directory entry */
;	DWORD cl	/* Value to be set */
;)
;{
_st_clust_G000:
; .FSTART _st_clust_G000
;	ST_WORD(dir+DIR_FstClusLO, cl);
	CALL __PUTPARD2
;	*dir -> Y+4
;	cl -> Y+0
	LD   R30,Y
	__PUTB1SNS 4,26
	LDD  R30,Y+1
	__PUTB1SNS 4,27
;	ST_WORD(dir+DIR_FstClusHI, cl >> 16);
	CALL __GETD1S0
	CALL __LSRD16
	__PUTB1SNS 4,20
	CALL __GETD1S0
	CALL __LSRD16
	CLR  R22
	CLR  R23
	MOV  R30,R31
	LDI  R31,0
	__PUTB1SNS 4,21
;}
	RJMP _0x20C0016
; .FEND
;#endif
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* LFN handling - Test/Pick/Fit an LFN segment from/to directory entry   */
;/*-----------------------------------------------------------------------*/
;#if _USE_LFN
;static
;const BYTE LfnOfs[] = {1,3,5,7,9,14,16,18,20,22,24,28,30};	/* Offset of LFN characters in the directory entry */
;
;
;static
;int cmp_lfn (			/* 1:Matched, 0:Not matched */
;	WCHAR* lfnbuf,		/* Pointer to the LFN to be compared */
;	BYTE* dir			/* Pointer to the directory entry containing a part of LFN */
;)
;{
;	UINT i, s;
;	WCHAR wc, uc;
;
;
;	i = ((dir[LDIR_Ord] & ~LLE) - 1) * 13;	/* Get offset in the LFN buffer */
;	s = 0; wc = 1;
;	do {
;		uc = LD_WORD(dir+LfnOfs[s]);	/* Pick an LFN character from the entry */
;		if (wc) {	/* Last character has not been processed */
;			wc = ff_wtoupper(uc);		/* Convert it to upper case */
;			if (i >= _MAX_LFN || wc != ff_wtoupper(lfnbuf[i++]))	/* Compare it */
;				return 0;				/* Not matched */
;		} else {
;			if (uc != 0xFFFF) return 0;	/* Check filler */
;		}
;	} while (++s < 13);				/* Repeat until all characters in the entry are checked */
;
;	if ((dir[LDIR_Ord] & LLE) && wc && lfnbuf[i])	/* Last segment matched but different length */
;		return 0;
;
;	return 1;						/* The part of LFN matched */
;}
;
;
;
;static
;int pick_lfn (			/* 1:Succeeded, 0:Buffer overflow */
;	WCHAR* lfnbuf,		/* Pointer to the Unicode-LFN buffer */
;	BYTE* dir			/* Pointer to the directory entry */
;)
;{
;	UINT i, s;
;	WCHAR wc, uc;
;
;
;	i = ((dir[LDIR_Ord] & 0x3F) - 1) * 13;	/* Offset in the LFN buffer */
;
;	s = 0; wc = 1;
;	do {
;		uc = LD_WORD(dir+LfnOfs[s]);		/* Pick an LFN character from the entry */
;		if (wc) {	/* Last character has not been processed */
;			if (i >= _MAX_LFN) return 0;	/* Buffer overflow? */
;			lfnbuf[i++] = wc = uc;			/* Store it */
;		} else {
;			if (uc != 0xFFFF) return 0;		/* Check filler */
;		}
;	} while (++s < 13);						/* Read all character in the entry */
;
;	if (dir[LDIR_Ord] & LLE) {				/* Put terminator if it is the last LFN part */
;		if (i >= _MAX_LFN) return 0;		/* Buffer overflow? */
;		lfnbuf[i] = 0;
;	}
;
;	return 1;
;}
;
;
;#if !_FS_READONLY
;static
;void fit_lfn (
;	const WCHAR* lfnbuf,	/* Pointer to the LFN buffer */
;	BYTE* dir,				/* Pointer to the directory entry */
;	BYTE ord,				/* LFN order (1-20) */
;	BYTE sum				/* SFN sum */
;)
;{
;	UINT i, s;
;	WCHAR wc;
;
;
;	dir[LDIR_Chksum] = sum;			/* Set check sum */
;	dir[LDIR_Attr] = AM_LFN;		/* Set attribute. LFN entry */
;	dir[LDIR_Type] = 0;
;	ST_WORD(dir+LDIR_FstClusLO, 0);
;
;	i = (ord - 1) * 13;				/* Get offset in the LFN buffer */
;	s = wc = 0;
;	do {
;		if (wc != 0xFFFF) wc = lfnbuf[i++];	/* Get an effective character */
;		ST_WORD(dir+LfnOfs[s], wc);	/* Put it */
;		if (!wc) wc = 0xFFFF;		/* Padding characters following last character */
;	} while (++s < 13);
;	if (wc == 0xFFFF || !lfnbuf[i]) ord |= LLE;	/* Bottom LFN part is the start of LFN sequence */
;	dir[LDIR_Ord] = ord;			/* Set the LFN order */
;}
;
;#endif
;#endif
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Create numbered name                                                  */
;/*-----------------------------------------------------------------------*/
;#if _USE_LFN
;void gen_numname (
;	BYTE* dst,			/* Pointer to generated SFN */
;	const BYTE* src,	/* Pointer to source SFN to be modified */
;	const WCHAR* lfn,	/* Pointer to LFN */
;	WORD seq			/* Sequence number */
;)
;{
;	BYTE ns[8], c;
;	UINT i, j;
;
;
;	mem_cpy(dst, src, 11);
;
;	if (seq > 5) {	/* On many collisions, generate a hash number instead of sequential number */
;		do seq = (seq >> 1) + (seq << 15) + (WORD)*lfn++; while (*lfn);
;	}
;
;	/* itoa (hexdecimal) */
;	i = 7;
;	do {
;		c = (seq % 16) + '0';
;		if (c > '9') c += 7;
;		ns[i--] = c;
;		seq /= 16;
;	} while (seq);
;	ns[i] = '~';
;
;	/* Append the number */
;	for (j = 0; j < i && dst[j] != ' '; j++) {
;		if (IsDBCS1(dst[j])) {
;			if (j == i - 1) break;
;			j++;
;		}
;	}
;	do {
;		dst[j++] = (i < 8) ? ns[i++] : ' ';
;	} while (j < 8);
;}
;#endif
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Calculate sum of an SFN                                               */
;/*-----------------------------------------------------------------------*/
;#if _USE_LFN
;static
;BYTE sum_sfn (
;	const BYTE* dir		/* Pointer to the SFN entry */
;)
;{
;	BYTE sum = 0;
;	UINT n = 11;
;
;	do sum = (sum >> 1) + (sum << 7) + *dir++; while (--n);
;	return sum;
;}
;#endif
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Directory handling - Find an object in the directory                  */
;/*-----------------------------------------------------------------------*/
;
;static
;FRESULT dir_find (
;	DIR* dp			/* Pointer to the directory object linked to the file name */
;)
;{
_dir_find_G000:
; .FSTART _dir_find_G000
;	FRESULT res;
;	BYTE c, *dir;
;#if _USE_LFN
;	BYTE a, ord, sum;
;#endif
;
;	res = dir_sdi(dp, 0);			/* Rewind directory object */
	ST   -Y,R27
	ST   -Y,R26
	CALL __SAVELOCR4
;	*dp -> Y+4
;	res -> R17
;	c -> R16
;	*dir -> R18,R19
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	RCALL _dir_sdi_G000
	MOV  R17,R30
;	if (res != FR_OK) return res;
	CPI  R17,0
	BREQ _0x236
	CALL __LOADLOCR4
	RJMP _0x20C0016
;
;#if _USE_LFN
;	ord = sum = 0xFF;
;#endif
;	do {
_0x236:
_0x238:
;		res = move_window(dp->fs, dp->sect);
	LDD  R26,Y+4
	LDD  R27,Y+4+1
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	__GETD2Z 14
	CALL _move_window_G000
	MOV  R17,R30
;		if (res != FR_OK) break;
	CPI  R17,0
	BRNE _0x239
;		dir = dp->dir;					/* Ptr to the directory entry of current index */
	LDD  R26,Y+4
	LDD  R27,Y+4+1
	ADIW R26,18
	LD   R18,X+
	LD   R19,X
;		c = dir[DIR_Name];
	MOVW R26,R18
	LD   R16,X
;		if (c == 0) { res = FR_NO_FILE; break; }	/* Reached to end of table */
	CPI  R16,0
	BRNE _0x23B
	LDI  R17,LOW(4)
	RJMP _0x239
;#if _USE_LFN	/* LFN configuration */
;		a = dir[DIR_Attr] & AM_MASK;
;		if (c == DDE || ((a & AM_VOL) && a != AM_LFN)) {	/* An entry without valid data */
;			ord = 0xFF;
;		} else {
;			if (a == AM_LFN) {			/* An LFN entry is found */
;				if (dp->lfn) {
;					if (c & LLE) {		/* Is it start of LFN sequence? */
;						sum = dir[LDIR_Chksum];
;						c &= ~LLE; ord = c;	/* LFN start order */
;						dp->lfn_idx = dp->index;
;					}
;					/* Check validity of the LFN entry and compare it with given name */
;					ord = (c == ord && sum == dir[LDIR_Chksum] && cmp_lfn(dp->lfn, dir)) ? ord - 1 : 0xFF;
;				}
;			} else {					/* An SFN entry is found */
;				if (!ord && sum == sum_sfn(dir)) break;	/* LFN matched? */
;				ord = 0xFF; dp->lfn_idx = 0xFFFF;	/* Reset LFN sequence */
;				if (!(dp->fn[NS] & NS_LOSS) && !mem_cmp(dir, dp->fn, 11)) break;	/* SFN matched? */
;			}
;		}
;#else		/* Non LFN configuration */
;		if (!(dir[DIR_Attr] & AM_VOL) && !mem_cmp(dir, dp->fn, 11)) /* Is it a valid entry? */
_0x23B:
	MOVW R30,R18
	LDD  R30,Z+11
	ANDI R30,LOW(0x8)
	BRNE _0x23D
	ST   -Y,R19
	ST   -Y,R18
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LDD  R26,Z+20
	LDD  R27,Z+21
	ST   -Y,R27
	ST   -Y,R26
	LDI  R26,LOW(11)
	LDI  R27,0
	CALL _mem_cmp_G000
	SBIW R30,0
	BREQ _0x23E
_0x23D:
	RJMP _0x23C
_0x23E:
;			break;
	RJMP _0x239
;#endif
;		res = dir_next(dp, 0);		/* Next entry */
_0x23C:
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	RCALL _dir_next_G000
	MOV  R17,R30
;	} while (res == FR_OK);
	CPI  R17,0
	BREQ _0x238
_0x239:
;
;	return res;
	MOV  R30,R17
	CALL __LOADLOCR4
	RJMP _0x20C0016
;}
; .FEND
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Read an object from the directory                                     */
;/*-----------------------------------------------------------------------*/
;#if _FS_MINIMIZE <= 1 || _USE_LABEL || _FS_RPATH >= 2
;static
;FRESULT dir_read (
;	DIR* dp,		/* Pointer to the directory object */
;	int vol			/* Filtered by 0:file/directory or 1:volume label */
;)
;{
_dir_read_G000:
; .FSTART _dir_read_G000
;	FRESULT res;
;	BYTE a, c, *dir;
;#if _USE_LFN
;	BYTE ord = 0xFF, sum = 0xFF;
;#endif
;
;	res = FR_NO_FILE;
	ST   -Y,R27
	ST   -Y,R26
	CALL __SAVELOCR6
;	*dp -> Y+8
;	vol -> Y+6
;	res -> R17
;	a -> R16
;	c -> R19
;	*dir -> R20,R21
	LDI  R17,LOW(4)
;	while (dp->sect) {
_0x23F:
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	ADIW R26,14
	CALL __GETD1P
	CALL __CPD10
	BRNE PC+2
	RJMP _0x241
;		res = move_window(dp->fs, dp->sect);
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	__GETD2Z 14
	CALL _move_window_G000
	MOV  R17,R30
;		if (res != FR_OK) break;
	CPI  R17,0
	BRNE _0x241
;		dir = dp->dir;					/* Ptr to the directory entry of current index */
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	ADIW R26,18
	LD   R20,X+
	LD   R21,X
;		c = dir[DIR_Name];
	MOVW R26,R20
	LD   R19,X
;		if (c == 0) { res = FR_NO_FILE; break; }	/* Reached to end of table */
	CPI  R19,0
	BRNE _0x243
	LDI  R17,LOW(4)
	RJMP _0x241
;		a = dir[DIR_Attr] & AM_MASK;
_0x243:
	MOVW R30,R20
	LDD  R30,Z+11
	ANDI R30,LOW(0x3F)
	MOV  R16,R30
;#if _USE_LFN	/* LFN configuration */
;		if (c == DDE || (!_FS_RPATH && c == '.') || (int)(a == AM_VOL) != vol) {	/* An entry without valid data */
;			ord = 0xFF;
;		} else {
;			if (a == AM_LFN) {			/* An LFN entry is found */
;				if (c & LLE) {			/* Is it start of LFN sequence? */
;					sum = dir[LDIR_Chksum];
;					c &= ~LLE; ord = c;
;					dp->lfn_idx = dp->index;
;				}
;				/* Check LFN validity and capture it */
;				ord = (c == ord && sum == dir[LDIR_Chksum] && pick_lfn(dp->lfn, dir)) ? ord - 1 : 0xFF;
;			} else {					/* An SFN entry is found */
;				if (ord || sum != sum_sfn(dir))	/* Is there a valid LFN? */
;					dp->lfn_idx = 0xFFFF;		/* It has no LFN. */
;				break;
;			}
;		}
;#else		/* Non LFN configuration */
;		if (c != DDE && (_FS_RPATH || c != '.') && a != AM_LFN && (int)(a == AM_VOL) == vol)	/* Is it a valid entry? */
	CPI  R19,229
	BREQ _0x245
	LDI  R30,LOW(0)
	CPI  R30,0
	BRNE _0x246
	CPI  R19,46
	BREQ _0x245
_0x246:
	CPI  R16,15
	BREQ _0x245
	MOV  R26,R16
	LDI  R30,LOW(8)
	CALL __EQB12
	LDI  R31,0
	MOVW R26,R30
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	CP   R30,R26
	CPC  R31,R27
	BREQ _0x248
_0x245:
	RJMP _0x244
_0x248:
;			break;
	RJMP _0x241
;#endif
;		res = dir_next(dp, 0);				/* Next entry */
_0x244:
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	RCALL _dir_next_G000
	MOV  R17,R30
;		if (res != FR_OK) break;
	CPI  R17,0
	BRNE _0x241
;	}
	RJMP _0x23F
_0x241:
;
;	if (res != FR_OK) dp->sect = 0;
	CPI  R17,0
	BREQ _0x24A
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	ADIW R26,14
	__GETD1N 0x0
	CALL __PUTDP1
;
;	return res;
_0x24A:
	MOV  R30,R17
	RJMP _0x20C0019
;}
; .FEND
;#endif	/* _FS_MINIMIZE <= 1 || _USE_LABEL || _FS_RPATH >= 2 */
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Register an object to the directory                                   */
;/*-----------------------------------------------------------------------*/
;#if !_FS_READONLY
;static
;FRESULT dir_register (	/* FR_OK:Successful, FR_DENIED:No free entry or too many SFN collision, FR_DISK_ERR:Disk error */
;	DIR* dp				/* Target directory with object name to be created */
;)
;{
_dir_register_G000:
; .FSTART _dir_register_G000
;	FRESULT res;
;#if _USE_LFN	/* LFN configuration */
;	WORD n, ne;
;	BYTE sn[12], *fn, sum;
;	WCHAR *lfn;
;
;
;	fn = dp->fn; lfn = dp->lfn;
;	mem_cpy(sn, fn, 12);
;
;	if (_FS_RPATH && (sn[NS] & NS_DOT))		/* Cannot create dot entry */
;		return FR_INVALID_NAME;
;
;	if (sn[NS] & NS_LOSS) {			/* When LFN is out of 8.3 format, generate a numbered name */
;		fn[NS] = 0; dp->lfn = 0;			/* Find only SFN */
;		for (n = 1; n < 100; n++) {
;			gen_numname(fn, sn, lfn, n);	/* Generate a numbered name */
;			res = dir_find(dp);				/* Check if the name collides with existing SFN */
;			if (res != FR_OK) break;
;		}
;		if (n == 100) return FR_DENIED;		/* Abort if too many collisions */
;		if (res != FR_NO_FILE) return res;	/* Abort if the result is other than 'not collided' */
;		fn[NS] = sn[NS]; dp->lfn = lfn;
;	}
;
;	if (sn[NS] & NS_LFN) {			/* When LFN is to be created, allocate entries for an SFN + LFNs. */
;		for (n = 0; lfn[n]; n++) ;
;		ne = (n + 25) / 13;
;	} else {						/* Otherwise allocate an entry for an SFN  */
;		ne = 1;
;	}
;	res = dir_alloc(dp, ne);		/* Allocate entries */
;
;	if (res == FR_OK && --ne) {		/* Set LFN entry if needed */
;		res = dir_sdi(dp, (WORD)(dp->index - ne));
;		if (res == FR_OK) {
;			sum = sum_sfn(dp->fn);	/* Sum value of the SFN tied to the LFN */
;			do {					/* Store LFN entries in bottom first */
;				res = move_window(dp->fs, dp->sect);
;				if (res != FR_OK) break;
;				fit_lfn(dp->lfn, dp->dir, (BYTE)ne, sum);
;				dp->fs->wflag = 1;
;				res = dir_next(dp, 0);	/* Next entry */
;			} while (res == FR_OK && --ne);
;		}
;	}
;#else	/* Non LFN configuration */
;	res = dir_alloc(dp, 1);		/* Allocate an entry for SFN */
	ST   -Y,R27
	ST   -Y,R26
	ST   -Y,R17
;	*dp -> Y+1
;	res -> R17
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(1)
	LDI  R27,0
	RCALL _dir_alloc_G000
	MOV  R17,R30
;#endif
;
;	if (res == FR_OK) {				/* Set SFN entry */
	CPI  R17,0
	BRNE _0x24B
;		res = move_window(dp->fs, dp->sect);
	LDD  R26,Y+1
	LDD  R27,Y+1+1
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+3
	LDD  R31,Y+3+1
	__GETD2Z 14
	CALL _move_window_G000
	MOV  R17,R30
;		if (res == FR_OK) {
	CPI  R17,0
	BRNE _0x24C
;			mem_set(dp->dir, 0, SZ_DIR);	/* Clean the entry */
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	LDD  R26,Z+18
	LDD  R27,Z+19
	ST   -Y,R27
	ST   -Y,R26
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(32)
	LDI  R27,0
	CALL _mem_set_G000
;			mem_cpy(dp->dir, dp->fn, 11);	/* Put SFN */
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	LDD  R26,Z+18
	LDD  R27,Z+19
	ST   -Y,R27
	ST   -Y,R26
	LDD  R30,Y+3
	LDD  R31,Y+3+1
	LDD  R26,Z+20
	LDD  R27,Z+21
	ST   -Y,R27
	ST   -Y,R26
	LDI  R26,LOW(11)
	LDI  R27,0
	CALL _mem_cpy_G000
;#if _USE_LFN
;			dp->dir[DIR_NTres] = dp->fn[NS] & (NS_BODY | NS_EXT);	/* Put NT flag */
;#endif
;			dp->fs->wflag = 1;
	LDD  R26,Y+1
	LDD  R27,Y+1+1
	CALL __GETW1P
	ADIW R30,4
	LDI  R26,LOW(1)
	STD  Z+0,R26
;		}
;	}
_0x24C:
;
;	return res;
_0x24B:
	RJMP _0x20C001C
;}
; .FEND
;#endif /* !_FS_READONLY */
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Remove an object from the directory                                   */
;/*-----------------------------------------------------------------------*/
;#if !_FS_READONLY && !_FS_MINIMIZE
;static
;FRESULT dir_remove (	/* FR_OK: Successful, FR_DISK_ERR: A disk error */
;	DIR* dp				/* Directory object pointing the entry to be removed */
;)
;{
_dir_remove_G000:
; .FSTART _dir_remove_G000
;	FRESULT res;
;#if _USE_LFN	/* LFN configuration */
;	WORD i;
;
;	i = dp->index;	/* SFN index */
;	res = dir_sdi(dp, (WORD)((dp->lfn_idx == 0xFFFF) ? i : dp->lfn_idx));	/* Goto the SFN or top of the LFN entries */
;	if (res == FR_OK) {
;		do {
;			res = move_window(dp->fs, dp->sect);
;			if (res != FR_OK) break;
;			*dp->dir = DDE;			/* Mark the entry "deleted" */
;			dp->fs->wflag = 1;
;			if (dp->index >= i) break;	/* When reached SFN, all entries of the object has been deleted. */
;			res = dir_next(dp, 0);		/* Next entry */
;		} while (res == FR_OK);
;		if (res == FR_NO_FILE) res = FR_INT_ERR;
;	}
;
;#else			/* Non LFN configuration */
;	res = dir_sdi(dp, dp->index);
	ST   -Y,R27
	ST   -Y,R26
	ST   -Y,R17
;	*dp -> Y+1
;	res -> R17
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+3
	LDD  R31,Y+3+1
	LDD  R26,Z+4
	LDD  R27,Z+5
	RCALL _dir_sdi_G000
	MOV  R17,R30
;	if (res == FR_OK) {
	CPI  R17,0
	BRNE _0x24D
;		res = move_window(dp->fs, dp->sect);
	LDD  R26,Y+1
	LDD  R27,Y+1+1
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+3
	LDD  R31,Y+3+1
	__GETD2Z 14
	CALL _move_window_G000
	MOV  R17,R30
;		if (res == FR_OK) {
	CPI  R17,0
	BRNE _0x24E
;			*dp->dir = DDE;			/* Mark the entry "deleted" */
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	LDD  R26,Z+18
	LDD  R27,Z+19
	LDI  R30,LOW(229)
	ST   X,R30
;			dp->fs->wflag = 1;
	LDD  R26,Y+1
	LDD  R27,Y+1+1
	CALL __GETW1P
	ADIW R30,4
	LDI  R26,LOW(1)
	STD  Z+0,R26
;		}
;	}
_0x24E:
;#endif
;
;	return res;
_0x24D:
_0x20C001C:
	MOV  R30,R17
	LDD  R17,Y+0
	ADIW R28,3
	RET
;}
; .FEND
;#endif /* !_FS_READONLY */
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Pick a segment and create the object name in directory form           */
;/*-----------------------------------------------------------------------*/
;
;static
;FRESULT create_name (
;	DIR* dp,			/* Pointer to the directory object */
;	const TCHAR** path	/* Pointer to pointer to the segment in the path string */
;)
;{
_create_name_G000:
; .FSTART _create_name_G000
;#if _USE_LFN	/* LFN configuration */
;	BYTE b, cf;
;	WCHAR w, *lfn;
;	UINT i, ni, si, di;
;	const TCHAR *p;
;
;	/* Create LFN in Unicode */
;	for (p = *path; *p == '/' || *p == '\\'; p++) ;	/* Strip duplicated separator */
;	lfn = dp->lfn;
;	si = di = 0;
;	for (;;) {
;		w = p[si++];					/* Get a character */
;		if (w < ' ' || w == '/' || w == '\\') break;	/* Break on end of segment */
;		if (di >= _MAX_LFN)				/* Reject too long name */
;			return FR_INVALID_NAME;
;#if !_LFN_UNICODE
;		w &= 0xFF;
;		if (IsDBCS1(w)) {				/* Check if it is a DBC 1st byte (always false on SBCS cfg) */
;			b = (BYTE)p[si++];			/* Get 2nd byte */
;			if (!IsDBCS2(b))
;				return FR_INVALID_NAME;	/* Reject invalid sequence */
;			w = (w << 8) + b;			/* Create a DBC */
;		}
;		w = ff_convert(w, 1);			/* Convert ANSI/OEM to Unicode */
;		if (!w) return FR_INVALID_NAME;	/* Reject invalid code */
;#endif
;		if (w < 0x80 && chk_chr("\"*:<>\?|\x7F", w)) /* Reject illegal characters for LFN */
;			return FR_INVALID_NAME;
;		lfn[di++] = w;					/* Store the Unicode character */
;	}
;	*path = &p[si];						/* Return pointer to the next segment */
;	cf = (w < ' ') ? NS_LAST : 0;		/* Set last segment flag if end of path */
;#if _FS_RPATH
;	if ((di == 1 && lfn[di-1] == '.') || /* Is this a dot entry? */
;		(di == 2 && lfn[di-1] == '.' && lfn[di-2] == '.')) {
;		lfn[di] = 0;
;		for (i = 0; i < 11; i++)
;			dp->fn[i] = (i < di) ? '.' : ' ';
;		dp->fn[i] = cf | NS_DOT;		/* This is a dot entry */
;		return FR_OK;
;	}
;#endif
;	while (di) {						/* Strip trailing spaces and dots */
;		w = lfn[di-1];
;		if (w != ' ' && w != '.') break;
;		di--;
;	}
;	if (!di) return FR_INVALID_NAME;	/* Reject nul string */
;
;	lfn[di] = 0;						/* LFN is created */
;
;	/* Create SFN in directory form */
;	mem_set(dp->fn, ' ', 11);
;	for (si = 0; lfn[si] == ' ' || lfn[si] == '.'; si++) ;	/* Strip leading spaces and dots */
;	if (si) cf |= NS_LOSS | NS_LFN;
;	while (di && lfn[di - 1] != '.') di--;	/* Find extension (di<=si: no extension) */
;
;	b = i = 0; ni = 8;
;	for (;;) {
;		w = lfn[si++];					/* Get an LFN character */
;		if (!w) break;					/* Break on end of the LFN */
;		if (w == ' ' || (w == '.' && si != di)) {	/* Remove spaces and dots */
;			cf |= NS_LOSS | NS_LFN; continue;
;		}
;
;		if (i >= ni || si == di) {		/* Extension or end of SFN */
;			if (ni == 11) {				/* Long extension */
;				cf |= NS_LOSS | NS_LFN; break;
;			}
;			if (si != di) cf |= NS_LOSS | NS_LFN;	/* Out of 8.3 format */
;			if (si > di) break;			/* No extension */
;			si = di; i = 8; ni = 11;	/* Enter extension section */
;			b <<= 2; continue;
;		}
;
;		if (w >= 0x80) {				/* Non ASCII character */
;#ifdef _EXCVT
;			w = ff_convert(w, 0);		/* Unicode -> OEM code */
;			if (w) w = ExCvt[w - 0x80];	/* Convert extended character to upper (SBCS) */
;#else
;			w = ff_convert(ff_wtoupper(w), 0);	/* Upper converted Unicode -> OEM code */
;#endif
;			cf |= NS_LFN;				/* Force create LFN entry */
;		}
;
;		if (_DF1S && w >= 0x100) {		/* Double byte character (always false on SBCS cfg) */
;			if (i >= ni - 1) {
;				cf |= NS_LOSS | NS_LFN; i = ni; continue;
;			}
;			dp->fn[i++] = (BYTE)(w >> 8);
;		} else {						/* Single byte character */
;			if (!w || chk_chr("+,;=[]", w)) {	/* Replace illegal characters for SFN */
;				w = '_'; cf |= NS_LOSS | NS_LFN;/* Lossy conversion */
;			} else {
;				if (IsUpper(w)) {		/* ASCII large capital */
;					b |= 2;
;				} else {
;					if (IsLower(w)) {	/* ASCII small capital */
;						b |= 1; w -= 0x20;
;					}
;				}
;			}
;		}
;		dp->fn[i++] = (BYTE)w;
;	}
;
;	if (dp->fn[0] == DDE) dp->fn[0] = NDDE;	/* If the first character collides with deleted mark, replace it with 0x05 */
;
;	if (ni == 8) b <<= 2;
;	if ((b & 0x0C) == 0x0C || (b & 0x03) == 0x03)	/* Create LFN entry when there are composite capitals */
;		cf |= NS_LFN;
;	if (!(cf & NS_LFN)) {						/* When LFN is in 8.3 format without extended character, NT flags are created */
;		if ((b & 0x03) == 0x01) cf |= NS_EXT;	/* NT flag (Extension has only small capital) */
;		if ((b & 0x0C) == 0x04) cf |= NS_BODY;	/* NT flag (Filename has only small capital) */
;	}
;
;	dp->fn[NS] = cf;	/* SFN is created */
;
;	return FR_OK;
;
;
;#else	/* Non-LFN configuration */
;	BYTE b, c, d, *sfn;
;	UINT ni, si, i;
;	const char *p;
;
;	/* Create file name in directory form */
;	for (p = *path; *p == '/' || *p == '\\'; p++) ;	/* Strip duplicated separator */
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,8
	CALL __SAVELOCR6
;	*dp -> Y+16
;	*path -> Y+14
;	b -> R17
;	c -> R16
;	d -> R19
;	*sfn -> R20,R21
;	ni -> Y+12
;	si -> Y+10
;	i -> Y+8
;	*p -> Y+6
	LDD  R26,Y+14
	LDD  R27,Y+14+1
	CALL __GETW1P
	STD  Y+6,R30
	STD  Y+6+1,R31
_0x250:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LD   R26,X
	CPI  R26,LOW(0x2F)
	BREQ _0x252
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LD   R26,X
	CPI  R26,LOW(0x5C)
	BRNE _0x251
_0x252:
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,1
	STD  Y+6,R30
	STD  Y+6+1,R31
	RJMP _0x250
_0x251:
;	sfn = dp->fn;
	LDD  R26,Y+16
	LDD  R27,Y+16+1
	ADIW R26,20
	LD   R20,X+
	LD   R21,X
;	mem_set(sfn, ' ', 11);
	ST   -Y,R21
	ST   -Y,R20
	LDI  R30,LOW(32)
	LDI  R31,HIGH(32)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(11)
	LDI  R27,0
	CALL _mem_set_G000
;	si = i = b = 0; ni = 8;
	LDI  R30,LOW(0)
	MOV  R17,R30
	LDI  R31,0
	STD  Y+8,R30
	STD  Y+8+1,R31
	STD  Y+10,R30
	STD  Y+10+1,R31
	LDI  R30,LOW(8)
	LDI  R31,HIGH(8)
	STD  Y+12,R30
	STD  Y+12+1,R31
;#if _FS_RPATH
;	if (p[si] == '.') { /* Is this a dot entry? */
;		for (;;) {
;			c = (BYTE)p[si++];
;			if (c != '.' || si >= 3) break;
;			sfn[i++] = c;
;		}
;		if (c != '/' && c != '\\' && c > ' ') return FR_INVALID_NAME;
;		*path = &p[si];									/* Return pointer to the next segment */
;		sfn[NS] = (c <= ' ') ? NS_LAST | NS_DOT : NS_DOT;	/* Set last segment flag if end of path */
;		return FR_OK;
;	}
;#endif
;	for (;;) {
_0x255:
;		c = (BYTE)p[si++];
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	ADIW R30,1
	STD  Y+10,R30
	STD  Y+10+1,R31
	SBIW R30,1
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADD  R26,R30
	ADC  R27,R31
	LD   R16,X
;		if (c <= ' ' || c == '/' || c == '\\') break;	/* Break on end of segment */
	CPI  R16,33
	BRLO _0x258
	CPI  R16,47
	BREQ _0x258
	CPI  R16,92
	BRNE _0x257
_0x258:
	RJMP _0x256
;		if (c == '.' || i >= ni) {
_0x257:
	CPI  R16,46
	BREQ _0x25B
	LDD  R30,Y+12
	LDD  R31,Y+12+1
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CP   R26,R30
	CPC  R27,R31
	BRLO _0x25A
_0x25B:
;			if (ni != 8 || c != '.') return FR_INVALID_NAME;
	LDD  R26,Y+12
	LDD  R27,Y+12+1
	SBIW R26,8
	BRNE _0x25E
	CPI  R16,46
	BREQ _0x25D
_0x25E:
	LDI  R30,LOW(6)
	RJMP _0x20C001B
;			i = 8; ni = 11;
_0x25D:
	LDI  R30,LOW(8)
	LDI  R31,HIGH(8)
	STD  Y+8,R30
	STD  Y+8+1,R31
	LDI  R30,LOW(11)
	LDI  R31,HIGH(11)
	STD  Y+12,R30
	STD  Y+12+1,R31
;			b <<= 2; continue;
	LSL  R17
	LSL  R17
	RJMP _0x254
;		}
;		if (c >= 0x80) {				/* Extended character? */
_0x25A:
	CPI  R16,128
	BRLO _0x260
;			b |= 3;						/* Eliminate NT flag */
	ORI  R17,LOW(3)
;#ifdef _EXCVT
;			c = ExCvt[c - 0x80];		/* To upper extended characters (SBCS cfg) */
	MOV  R30,R16
	LDI  R31,0
	SUBI R30,LOW(128)
	SBCI R31,HIGH(128)
	SUBI R30,LOW(-_ExCvt_G000*2)
	SBCI R31,HIGH(-_ExCvt_G000*2)
	LPM  R16,Z
;#else
;#if !_DF1S
;			return FR_INVALID_NAME;		/* Reject extended characters (ASCII cfg) */
;#endif
;#endif
;		}
;		if (IsDBCS1(c)) {				/* Check if it is a DBC 1st byte (always false on SBCS cfg) */
_0x260:
;			d = (BYTE)p[si++];			/* Get 2nd byte */
;			if (!IsDBCS2(d) || i >= ni - 1)	/* Reject invalid DBC */
;				return FR_INVALID_NAME;
;			sfn[i++] = c;
;			sfn[i++] = d;
;		} else {						/* Single byte code */
;			if (chk_chr("\"*+,:;<=>\?[]|\x7F", c))	/* Reject illegal chrs for SFN */
	__POINTW1MN _0x267,0
	ST   -Y,R31
	ST   -Y,R30
	MOV  R26,R16
	CLR  R27
	CALL _chk_chr_G000
	SBIW R30,0
	BREQ _0x266
;				return FR_INVALID_NAME;
	LDI  R30,LOW(6)
	RJMP _0x20C001B
;			if (IsUpper(c)) {			/* ASCII large capital? */
_0x266:
	CPI  R16,65
	BRLO _0x269
	CPI  R16,91
	BRLO _0x26A
_0x269:
	RJMP _0x268
_0x26A:
;				b |= 2;
	ORI  R17,LOW(2)
;			} else {
	RJMP _0x26B
_0x268:
;				if (IsLower(c)) {		/* ASCII small capital? */
	CPI  R16,97
	BRLO _0x26D
	CPI  R16,123
	BRLO _0x26E
_0x26D:
	RJMP _0x26C
_0x26E:
;					b |= 1; c -= 0x20;
	ORI  R17,LOW(1)
	SUBI R16,LOW(32)
;				}
;			}
_0x26C:
_0x26B:
;			sfn[i++] = c;
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ADIW R30,1
	STD  Y+8,R30
	STD  Y+8+1,R31
	SBIW R30,1
	ADD  R30,R20
	ADC  R31,R21
	ST   Z,R16
;		}
;	}
_0x254:
	RJMP _0x255
_0x256:
;	*path = &p[si];						/* Return pointer to the next segment */
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADD  R30,R26
	ADC  R31,R27
	LDD  R26,Y+14
	LDD  R27,Y+14+1
	ST   X+,R30
	ST   X,R31
;	c = (c <= ' ') ? NS_LAST : 0;		/* Set last segment flag if end of path */
	CPI  R16,33
	BRSH _0x26F
	LDI  R30,LOW(4)
	RJMP _0x270
_0x26F:
	LDI  R30,LOW(0)
_0x270:
	MOV  R16,R30
;
;	if (!i) return FR_INVALID_NAME;		/* Reject nul string */
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	SBIW R30,0
	BRNE _0x272
	LDI  R30,LOW(6)
	RJMP _0x20C001B
;	if (sfn[0] == DDE) sfn[0] = NDDE;	/* When first character collides with DDE, replace it with 0x05 */
_0x272:
	MOVW R26,R20
	LD   R26,X
	CPI  R26,LOW(0xE5)
	BRNE _0x273
	MOVW R26,R20
	LDI  R30,LOW(5)
	ST   X,R30
;
;	if (ni == 8) b <<= 2;
_0x273:
	LDD  R26,Y+12
	LDD  R27,Y+12+1
	SBIW R26,8
	BRNE _0x274
	LSL  R17
	LSL  R17
;	if ((b & 0x03) == 0x01) c |= NS_EXT;	/* NT flag (Name extension has only small capital) */
_0x274:
	MOV  R30,R17
	ANDI R30,LOW(0x3)
	CPI  R30,LOW(0x1)
	BRNE _0x275
	ORI  R16,LOW(16)
;	if ((b & 0x0C) == 0x04) c |= NS_BODY;	/* NT flag (Name body has only small capital) */
_0x275:
	MOV  R30,R17
	ANDI R30,LOW(0xC)
	CPI  R30,LOW(0x4)
	BRNE _0x276
	ORI  R16,LOW(8)
;
;	sfn[NS] = c;		/* Store NT flag, File name is created */
_0x276:
	MOVW R30,R20
	__PUTBZR 16,11
;
;	return FR_OK;
	LDI  R30,LOW(0)
_0x20C001B:
	CALL __LOADLOCR6
	ADIW R28,18
	RET
;#endif
;}
; .FEND

	.DSEG
_0x267:
	.BYTE 0xF
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Get file information from directory entry                             */
;/*-----------------------------------------------------------------------*/
;#if _FS_MINIMIZE <= 1 || _FS_RPATH >= 2
;static
;void get_fileinfo (		/* No return code */
;	DIR* dp,			/* Pointer to the directory object */
;	FILINFO* fno	 	/* Pointer to the file information to be filled */
;)
;{

	.CSEG
_get_fileinfo_G000:
; .FSTART _get_fileinfo_G000
;	UINT i;
;	TCHAR *p, c;
;
;
;	p = fno->fname;
	ST   -Y,R27
	ST   -Y,R26
	CALL __SAVELOCR6
;	*dp -> Y+8
;	*fno -> Y+6
;	i -> R16,R17
;	*p -> R18,R19
;	c -> R21
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,9
	MOVW R18,R30
;	if (dp->sect) {		/* Get SFN */
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	ADIW R26,14
	CALL __GETD1P
	CALL __CPD10
	BRNE PC+2
	RJMP _0x277
;		BYTE *dir = dp->dir;
;
;		i = 0;
	SBIW R28,2
;	*dp -> Y+10
;	*fno -> Y+8
;	*dir -> Y+0
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	ADIW R26,18
	CALL __GETW1P
	ST   Y,R30
	STD  Y+1,R31
	__GETWRN 16,17,0
;		while (i < 11) {		/* Copy name body and extension */
_0x278:
	__CPWRN 16,17,11
	BRSH _0x27A
;			c = (TCHAR)dir[i++];
	MOVW R30,R16
	__ADDWRN 16,17,1
	LD   R26,Y
	LDD  R27,Y+1
	ADD  R26,R30
	ADC  R27,R31
	LD   R21,X
;			if (c == ' ') continue;			/* Skip padding spaces */
	CPI  R21,32
	BREQ _0x278
;			if (c == NDDE) c = (TCHAR)DDE;	/* Restore replaced DDE character */
	CPI  R21,5
	BRNE _0x27C
	LDI  R21,LOW(229)
;			if (i == 9) *p++ = '.';			/* Insert a . if extension is exist */
_0x27C:
	LDI  R30,LOW(9)
	LDI  R31,HIGH(9)
	CP   R30,R16
	CPC  R31,R17
	BRNE _0x27D
	MOVW R26,R18
	__ADDWRN 18,19,1
	LDI  R30,LOW(46)
	ST   X,R30
;#if _USE_LFN
;			if (IsUpper(c) && (dir[DIR_NTres] & (i >= 9 ? NS_EXT : NS_BODY)))
;				c += 0x20;			/* To lower */
;#if _LFN_UNICODE
;			if (IsDBCS1(c) && i != 8 && i != 11 && IsDBCS2(dir[i]))
;				c = c << 8 | dir[i++];
;			c = ff_convert(c, 1);	/* OEM -> Unicode */
;			if (!c) c = '?';
;#endif
;#endif
;			*p++ = c;
_0x27D:
	PUSH R19
	PUSH R18
	__ADDWRN 18,19,1
	MOV  R30,R21
	POP  R26
	POP  R27
	ST   X,R30
;		}
	RJMP _0x278
_0x27A:
;		fno->fattrib = dir[DIR_Attr];				/* Attribute */
	LD   R30,Y
	LDD  R31,Y+1
	LDD  R30,Z+11
	__PUTB1SNS 8,8
;		fno->fsize = LD_DWORD(dir+DIR_FileSize);	/* Size */
	LD   R30,Y
	LDD  R31,Y+1
	LDD  R30,Z+31
	LDI  R31,0
	CALL __CWD1
	MOVW R26,R30
	MOVW R24,R22
	LDI  R30,LOW(24)
	CALL __LSLD12
	MOVW R26,R30
	MOVW R24,R22
	LD   R30,Y
	LDD  R31,Y+1
	LDD  R30,Z+30
	LDI  R31,0
	CALL __CWD1
	CALL __LSLD16
	CALL __ORD12
	MOVW R26,R30
	MOVW R24,R22
	LD   R30,Y
	LDD  R31,Y+1
	LDD  R31,Z+29
	LDI  R30,LOW(0)
	CLR  R22
	CLR  R23
	CALL __ORD12
	MOVW R26,R30
	MOVW R24,R22
	LD   R30,Y
	LDD  R31,Y+1
	LDD  R30,Z+28
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __ORD12
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __PUTDP1
;		fno->fdate = LD_WORD(dir+DIR_WrtDate);		/* Date */
	LD   R30,Y
	LDD  R31,Y+1
	LDD  R27,Z+25
	LDI  R26,LOW(0)
	LDD  R30,Z+24
	LDI  R31,0
	OR   R30,R26
	OR   R31,R27
	__PUTW1SNS 8,4
;		fno->ftime = LD_WORD(dir+DIR_WrtTime);		/* Time */
	LD   R30,Y
	LDD  R31,Y+1
	LDD  R27,Z+23
	LDI  R26,LOW(0)
	LDD  R30,Z+22
	LDI  R31,0
	OR   R30,R26
	OR   R31,R27
	__PUTW1SNS 8,6
;	}
	ADIW R28,2
;	*p = 0;		/* Terminate SFN string by a \0 */
_0x277:
	MOVW R26,R18
	LDI  R30,LOW(0)
	ST   X,R30
;
;#if _USE_LFN
;	if (fno->lfname) {
;		WCHAR w, *lfn;
;
;		i = 0; p = fno->lfname;
;		if (dp->sect && fno->lfsize && dp->lfn_idx != 0xFFFF) {	/* Get LFN if available */
;			lfn = dp->lfn;
;			while ((w = *lfn++) != 0) {		/* Get an LFN character */
;#if !_LFN_UNICODE
;				w = ff_convert(w, 0);		/* Unicode -> OEM */
;				if (!w) { i = 0; break; }	/* No LFN if it could not be converted */
;				if (_DF1S && w >= 0x100)	/* Put 1st byte if it is a DBC (always false on SBCS cfg) */
;					p[i++] = (TCHAR)(w >> 8);
;#endif
;				if (i >= fno->lfsize - 1) { i = 0; break; }	/* No LFN if buffer overflow */
;				p[i++] = (TCHAR)w;
;			}
;		}
;		p[i] = 0;	/* Terminate LFN string by a \0 */
;	}
;#endif
;}
_0x20C0019:
	CALL __LOADLOCR6
_0x20C001A:
	ADIW R28,10
	RET
; .FEND
;#endif /* _FS_MINIMIZE <= 1 || _FS_RPATH >= 2*/
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Get logical drive number from path name                               */
;/*-----------------------------------------------------------------------*/
;
;static
;int get_ldnumber (		/* Returns logical drive number (-1:invalid drive) */
;	const TCHAR** path	/* Pointer to pointer to the path name */
;)
;{
_get_ldnumber_G000:
; .FSTART _get_ldnumber_G000
;	int vol = -1;
;
;
;	if (*path) {
	ST   -Y,R27
	ST   -Y,R26
	ST   -Y,R17
	ST   -Y,R16
;	*path -> Y+2
;	vol -> R16,R17
	__GETWRN 16,17,-1
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	CALL __GETW1P
	SBIW R30,0
	BREQ _0x27E
;		vol = (*path)[0] - '0';
	CALL __GETW1P
	LD   R30,Z
	LDI  R31,0
	SBIW R30,48
	MOVW R16,R30
;		if ((UINT)vol < 9 && (*path)[1] == ':') {	/* There is a drive number */
	__CPWRN 16,17,9
	BRSH _0x280
	CALL __GETW1P
	LDD  R26,Z+1
	CPI  R26,LOW(0x3A)
	BREQ _0x281
_0x280:
	RJMP _0x27F
_0x281:
;			*path += 2;		/* Get value and strip it */
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	LD   R30,X+
	LD   R31,X+
	ADIW R30,2
	ST   -X,R31
	ST   -X,R30
;			if (vol >= _VOLUMES) vol = -1;	/* Check if the drive number is valid */
	__CPWRN 16,17,1
	BRLT _0x282
	__GETWRN 16,17,-1
;		} else {			/* No drive number use default drive */
_0x282:
	RJMP _0x283
_0x27F:
;#if _FS_RPATH && _VOLUMES >= 2
;			vol = CurrVol;	/* Current drive */
;#else
;			vol = 0;		/* Drive 0 */
	__GETWRN 16,17,0
;#endif
;		}
_0x283:
;	}
;
;	return vol;
_0x27E:
	MOVW R30,R16
	RJMP _0x20C0013
;}
; .FEND
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Follow a file path                                                    */
;/*-----------------------------------------------------------------------*/
;
;static
;FRESULT follow_path (	/* FR_OK(0): successful, !=0: error code */
;	DIR* dp,			/* Directory object to return last directory and found object */
;	const TCHAR* path	/* Full-path string to find a file or directory */
;)
;{
_follow_path_G000:
; .FSTART _follow_path_G000
;	FRESULT res;
;	BYTE *dir, ns;
;
;
;#if _FS_RPATH
;	if (*path == '/' || *path == '\\') {	/* There is a heading separator */
;		path++;	dp->sclust = 0;				/* Strip it and start from the root directory */
;	} else {								/* No heading separator */
;		dp->sclust = dp->fs->cdir;			/* Start from the current directory */
;	}
;#else
;	if (*path == '/' || *path == '\\')		/* Strip heading separator if exist */
	ST   -Y,R27
	ST   -Y,R26
	CALL __SAVELOCR4
;	*dp -> Y+6
;	*path -> Y+4
;	res -> R17
;	*dir -> R18,R19
;	ns -> R16
	LDD  R26,Y+4
	LDD  R27,Y+4+1
	LD   R26,X
	CPI  R26,LOW(0x2F)
	BREQ _0x285
	LDD  R26,Y+4
	LDD  R27,Y+4+1
	LD   R26,X
	CPI  R26,LOW(0x5C)
	BRNE _0x284
_0x285:
;		path++;
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	ADIW R30,1
	STD  Y+4,R30
	STD  Y+4+1,R31
;	dp->sclust = 0;							/* Always start from the root directory */
_0x284:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADIW R26,6
	__GETD1N 0x0
	CALL __PUTDP1
;#endif
;
;	if ((UINT)*path < ' ') {				/* Null path name is the origin directory itself */
	LDD  R26,Y+4
	LDD  R27,Y+4+1
	LD   R26,X
	CLR  R27
	SBIW R26,32
	BRSH _0x287
;		res = dir_sdi(dp, 0);
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	RCALL _dir_sdi_G000
	MOV  R17,R30
;		dp->dir = 0;
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADIW R26,18
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   X+,R30
	ST   X,R31
;	} else {								/* Follow path */
	RJMP _0x288
_0x287:
;		for (;;) {
_0x28A:
;			res = create_name(dp, &path);	/* Get a segment name of the path */
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ST   -Y,R31
	ST   -Y,R30
	MOVW R26,R28
	ADIW R26,6
	RCALL _create_name_G000
	MOV  R17,R30
;			if (res != FR_OK) break;
	CPI  R17,0
	BREQ _0x28C
	RJMP _0x28B
;			res = dir_find(dp);				/* Find an object with the sagment name */
_0x28C:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	RCALL _dir_find_G000
	MOV  R17,R30
;			ns = dp->fn[NS];
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADIW R26,20
	CALL __GETW1P
	LDD  R16,Z+11
;			if (res != FR_OK) {				/* Failed to find the object */
	CPI  R17,0
	BREQ _0x28D
;				if (res == FR_NO_FILE) {	/* Object is not found */
	CPI  R17,4
	BRNE _0x28E
;					if (_FS_RPATH && (ns & NS_DOT)) {	/* If dot entry is not exist, */
	LDI  R30,LOW(0)
	CPI  R30,0
	BREQ _0x290
	SBRC R16,5
	RJMP _0x291
_0x290:
	RJMP _0x28F
_0x291:
;						dp->sclust = 0; dp->dir = 0;	/* it is the root directory and stay there */
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADIW R26,6
	__GETD1N 0x0
	CALL __PUTDP1
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADIW R26,18
	ST   X+,R30
	ST   X,R31
;						if (!(ns & NS_LAST)) continue;	/* Continue to follow if not last segment */
	SBRS R16,2
	RJMP _0x289
;						res = FR_OK;					/* Ended at the root directroy. Function completed. */
	LDI  R17,LOW(0)
;					} else {							/* Could not find the object */
	RJMP _0x293
_0x28F:
;						if (!(ns & NS_LAST)) res = FR_NO_PATH;	/* Adjust error code if not last segment */
	SBRS R16,2
	LDI  R17,LOW(5)
;					}
_0x293:
;				}
;				break;
_0x28E:
	RJMP _0x28B
;			}
;			if (ns & NS_LAST) break;			/* Last segment matched. Function completed. */
_0x28D:
	SBRC R16,2
	RJMP _0x28B
;			dir = dp->dir;						/* Follow the sub-directory */
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADIW R26,18
	LD   R18,X+
	LD   R19,X
;			if (!(dir[DIR_Attr] & AM_DIR)) {	/* It is not a sub-directory and cannot follow */
	MOVW R30,R18
	LDD  R30,Z+11
	ANDI R30,LOW(0x10)
	BRNE _0x296
;				res = FR_NO_PATH; break;
	LDI  R17,LOW(5)
	RJMP _0x28B
;			}
;			dp->sclust = ld_clust(dp->fs, dir);
_0x296:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	MOVW R26,R18
	RCALL _ld_clust_G000
	__PUTD1SNS 6,6
;		}
_0x289:
	RJMP _0x28A
_0x28B:
;	}
_0x288:
;
;	return res;
_0x20C0018:
	MOV  R30,R17
	CALL __LOADLOCR4
_0x20C0017:
	ADIW R28,8
	RET
;}
; .FEND
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Load a sector and check if it is an FAT boot sector                   */
;/*-----------------------------------------------------------------------*/
;
;static
;BYTE check_fs (	/* 0:FAT boor sector, 1:Valid boor sector but not FAT, 2:Not a boot sector, 3:Disk error */
;	FATFS* fs,	/* File system object */
;	DWORD sect	/* Sector# (lba) to check if it is an FAT boot record or not */
;)
;{
_check_fs_G000:
; .FSTART _check_fs_G000
;	fs->wflag = 0; fs->winsect = 0xFFFFFFFF;	/* Invaidate window */
	CALL __PUTPARD2
;	*fs -> Y+4
;	sect -> Y+0
	LDD  R26,Y+4
	LDD  R27,Y+4+1
	ADIW R26,4
	LDI  R30,LOW(0)
	ST   X,R30
	LDD  R26,Y+4
	LDD  R27,Y+4+1
	ADIW R26,42
	__GETD1N 0xFFFFFFFF
	CALL __PUTDP1
;	if (move_window(fs, sect) != FR_OK)			/* Load boot record */
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	ST   -Y,R31
	ST   -Y,R30
	__GETD2S 2
	CALL _move_window_G000
	CPI  R30,0
	BREQ _0x297
;		return 3;
	LDI  R30,LOW(3)
	RJMP _0x20C0016
;
;	if (LD_WORD(&fs->win[BS_55AA]) != 0xAA55)	/* Check boot record signature (always placed at offset 510 even if the secto ...
_0x297:
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	ADIW R30,46
	MOVW R0,R30
	SUBI R30,LOW(-511)
	SBCI R31,HIGH(-511)
	LD   R31,Z
	LDI  R30,LOW(0)
	MOVW R26,R30
	MOVW R30,R0
	SUBI R30,LOW(-510)
	SBCI R31,HIGH(-510)
	LD   R30,Z
	LDI  R31,0
	OR   R30,R26
	OR   R31,R27
	CPI  R30,LOW(0xAA55)
	LDI  R26,HIGH(0xAA55)
	CPC  R31,R26
	BREQ _0x298
;		return 2;
	LDI  R30,LOW(2)
	RJMP _0x20C0016
;
;	if ((LD_DWORD(&fs->win[BS_FilSysType]) & 0xFFFFFF) == 0x544146)		/* Check "FAT" string */
_0x298:
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	SUBI R30,LOW(-103)
	SBCI R31,HIGH(-103)
	LD   R26,Z
	CLR  R27
	CLR  R24
	CLR  R25
	LDI  R30,LOW(24)
	CALL __LSLD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	SUBI R30,LOW(-102)
	SBCI R31,HIGH(-102)
	LD   R30,Z
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __LSLD16
	CALL __ORD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	SUBI R30,LOW(-101)
	SBCI R31,HIGH(-101)
	LD   R31,Z
	LDI  R30,LOW(0)
	CLR  R22
	CLR  R23
	CALL __ORD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	SUBI R30,LOW(-100)
	SBCI R31,HIGH(-100)
	LD   R30,Z
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __ORD12
	__ANDD1N 0xFFFFFF
	__CPD1N 0x544146
	BRNE _0x299
;		return 0;
	LDI  R30,LOW(0)
	RJMP _0x20C0016
;	if ((LD_DWORD(&fs->win[BS_FilSysType32]) & 0xFFFFFF) == 0x544146)	/* Check "FAT" string */
_0x299:
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	ADIW R30,46
	SUBI R30,LOW(-85)
	SBCI R31,HIGH(-85)
	LD   R26,Z
	CLR  R27
	CLR  R24
	CLR  R25
	LDI  R30,LOW(24)
	CALL __LSLD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	ADIW R30,46
	SUBI R30,LOW(-84)
	SBCI R31,HIGH(-84)
	LD   R30,Z
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __LSLD16
	CALL __ORD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	ADIW R30,46
	SUBI R30,LOW(-83)
	SBCI R31,HIGH(-83)
	LD   R31,Z
	LDI  R30,LOW(0)
	CLR  R22
	CLR  R23
	CALL __ORD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	ADIW R30,46
	SUBI R30,LOW(-82)
	SBCI R31,HIGH(-82)
	LD   R30,Z
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __ORD12
	__ANDD1N 0xFFFFFF
	__CPD1N 0x544146
	BRNE _0x29A
;		return 0;
	LDI  R30,LOW(0)
	RJMP _0x20C0016
;
;	return 1;
_0x29A:
	LDI  R30,LOW(1)
_0x20C0016:
	ADIW R28,6
	RET
;}
; .FEND
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Find logical drive and check if the volume is mounted                 */
;/*-----------------------------------------------------------------------*/
;
;static
;FRESULT find_volume (	/* FR_OK(0): successful, !=0: any error occurred */
;	FATFS** rfs,		/* Pointer to pointer to the found file system object */
;	const TCHAR** path,	/* Pointer to pointer to the path name (drive number) */
;	BYTE wmode			/* !=0: Check write protection for write access */
;)
;{
_find_volume_G000:
; .FSTART _find_volume_G000
;	BYTE fmt;
;	int vol;
;	DSTATUS stat;
;	DWORD bsect, fasize, tsect, sysect, nclst, szbfat;
;	WORD nrsv;
;	FATFS *fs;
;
;
;	/* Get logical drive number from the path name */
;	*rfs = 0;
	ST   -Y,R26
	SBIW R28,26
	CALL __SAVELOCR6
;	*rfs -> Y+35
;	*path -> Y+33
;	wmode -> Y+32
;	fmt -> R17
;	vol -> R18,R19
;	stat -> R16
;	bsect -> Y+28
;	fasize -> Y+24
;	tsect -> Y+20
;	sysect -> Y+16
;	nclst -> Y+12
;	szbfat -> Y+8
;	nrsv -> R20,R21
;	*fs -> Y+6
	LDD  R26,Y+35
	LDD  R27,Y+35+1
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   X+,R30
	ST   X,R31
;	vol = get_ldnumber(path);
	LDD  R26,Y+33
	LDD  R27,Y+33+1
	RCALL _get_ldnumber_G000
	MOVW R18,R30
;	if (vol < 0) return FR_INVALID_DRIVE;
	TST  R19
	BRPL _0x29B
	LDI  R30,LOW(11)
	RJMP _0x20C0014
;
;	/* Check if the file system object is valid or not */
;	fs = FatFs[vol];					/* Get pointer to the file system object */
_0x29B:
	MOVW R30,R18
	LDI  R26,LOW(_FatFs_G000)
	LDI  R27,HIGH(_FatFs_G000)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	STD  Y+6,R30
	STD  Y+6+1,R31
;	if (!fs) return FR_NOT_ENABLED;		/* Is the file system object available? */
	SBIW R30,0
	BRNE _0x29C
	LDI  R30,LOW(12)
	RJMP _0x20C0014
;
;	ENTER_FF(fs);						/* Lock the volume */
;	*rfs = fs;							/* Return pointer to the file system object */
_0x29C:
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LDD  R26,Y+35
	LDD  R27,Y+35+1
	ST   X+,R30
	ST   X,R31
;
;	if (fs->fs_type) {					/* If the volume has been mounted */
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LD   R30,X
	CPI  R30,0
	BREQ _0x29D
;		stat = disk_status(fs->drv);
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LDD  R26,Z+1
	CALL _disk_status
	MOV  R16,R30
;		if (!(stat & STA_NOINIT)) {		/* and the physical drive is kept initialized */
	SBRC R16,0
	RJMP _0x29E
;			if (!_FS_READONLY && wmode && (stat & STA_PROTECT))	/* Check write protection if needed */
	LDI  R30,LOW(1)
	CPI  R30,0
	BREQ _0x2A0
	LDD  R30,Y+32
	CPI  R30,0
	BREQ _0x2A0
	SBRC R16,2
	RJMP _0x2A1
_0x2A0:
	RJMP _0x29F
_0x2A1:
;				return FR_WRITE_PROTECTED;
	LDI  R30,LOW(10)
	RJMP _0x20C0014
;			return FR_OK;				/* The file system object is valid */
_0x29F:
	RJMP _0x20C0015
;		}
;	}
_0x29E:
;
;	/* The file system object is not valid. */
;	/* Following code attempts to mount the volume. (analyze BPB and initialize the fs object) */
;
;	fs->fs_type = 0;					/* Clear the file system object */
_0x29D:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(0)
	ST   X,R30
;	fs->drv = LD2PD(vol);				/* Bind the logical drive and a physical drive */
	MOV  R30,R18
	__PUTB1SNS 6,1
;	stat = disk_initialize(fs->drv);	/* Initialize the physical drive */
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LDD  R26,Z+1
	CALL _disk_initialize
	MOV  R16,R30
;	if (stat & STA_NOINIT)				/* Check if the initialization succeeded */
	SBRS R16,0
	RJMP _0x2A2
;		return FR_NOT_READY;			/* Failed to initialize due to no medium or hard error */
	LDI  R30,LOW(3)
	RJMP _0x20C0014
;	if (!_FS_READONLY && wmode && (stat & STA_PROTECT))	/* Check disk write protection if needed */
_0x2A2:
	LDI  R30,LOW(1)
	CPI  R30,0
	BREQ _0x2A4
	LDD  R30,Y+32
	CPI  R30,0
	BREQ _0x2A4
	SBRC R16,2
	RJMP _0x2A5
_0x2A4:
	RJMP _0x2A3
_0x2A5:
;		return FR_WRITE_PROTECTED;
	LDI  R30,LOW(10)
	RJMP _0x20C0014
;#if _MAX_SS != 512						/* Get sector size (variable sector size cfg only) */
;	if (disk_ioctl(fs->drv, GET_SECTOR_SIZE, &fs->ssize) != RES_OK)
;		return FR_DISK_ERR;
;#endif
;	/* Find an FAT partition on the drive. Supports only generic partitioning, FDISK and SFD. */
;	bsect = 0;
_0x2A3:
	LDI  R30,LOW(0)
	__CLRD1S 28
;	fmt = check_fs(fs, bsect);					/* Load sector 0 and check if it is an FAT boot sector as SFD */
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ST   -Y,R31
	ST   -Y,R30
	__GETD2S 30
	RCALL _check_fs_G000
	MOV  R17,R30
;	if (fmt == 1 || (!fmt && (LD2PT(vol)))) {	/* Not an FAT boot sector or forced partition number */
	CPI  R17,1
	BREQ _0x2A7
	CPI  R17,0
	BRNE _0x2A8
	LDI  R30,LOW(0)
	CPI  R30,0
	BRNE _0x2A7
_0x2A8:
	RJMP _0x2A6
_0x2A7:
;		UINT i;
;		DWORD br[4];
;
;		for (i = 0; i < 4; i++) {			/* Get partition offset */
	SBIW R28,18
;	*rfs -> Y+53
;	*path -> Y+51
;	wmode -> Y+50
;	bsect -> Y+46
;	fasize -> Y+42
;	tsect -> Y+38
;	sysect -> Y+34
;	nclst -> Y+30
;	szbfat -> Y+26
;	*fs -> Y+24
;	i -> Y+16
;	br -> Y+0
	LDI  R30,LOW(0)
	STD  Y+16,R30
	STD  Y+16+1,R30
_0x2AC:
	LDD  R26,Y+16
	LDD  R27,Y+16+1
	SBIW R26,4
	BRLO PC+2
	RJMP _0x2AD
;			BYTE *pt = fs->win+MBR_Table + i * SZ_PTE;
;			br[i] = pt[4] ? LD_DWORD(&pt[8]) : 0;
	SBIW R28,2
;	*rfs -> Y+55
;	*path -> Y+53
;	wmode -> Y+52
;	bsect -> Y+48
;	fasize -> Y+44
;	tsect -> Y+40
;	sysect -> Y+36
;	nclst -> Y+32
;	szbfat -> Y+28
;	*fs -> Y+26
;	i -> Y+18
;	br -> Y+2
;	*pt -> Y+0
	LDD  R30,Y+26
	LDD  R31,Y+26+1
	ADIW R30,46
	SUBI R30,LOW(-446)
	SBCI R31,HIGH(-446)
	__PUTW1R 23,24
	LDD  R26,Y+18
	LDD  R27,Y+18+1
	LDI  R30,LOW(16)
	CALL __MULB1W2U
	ADD  R30,R23
	ADC  R31,R24
	ST   Y,R30
	STD  Y+1,R31
	LDD  R30,Y+18
	LDD  R31,Y+18+1
	MOVW R26,R28
	ADIW R26,2
	CALL __LSLW2
	ADD  R30,R26
	ADC  R31,R27
	PUSH R31
	PUSH R30
	LD   R30,Y
	LDD  R31,Y+1
	LDD  R30,Z+4
	LDI  R31,0
	SBIW R30,0
	BREQ _0x2AE
	LD   R30,Y
	LDD  R31,Y+1
	LDD  R30,Z+11
	LDI  R31,0
	CALL __CWD1
	MOVW R26,R30
	MOVW R24,R22
	LDI  R30,LOW(24)
	CALL __LSLD12
	MOVW R26,R30
	MOVW R24,R22
	LD   R30,Y
	LDD  R31,Y+1
	LDD  R30,Z+10
	LDI  R31,0
	CALL __CWD1
	CALL __LSLD16
	CALL __ORD12
	MOVW R26,R30
	MOVW R24,R22
	LD   R30,Y
	LDD  R31,Y+1
	LDD  R31,Z+9
	LDI  R30,LOW(0)
	CLR  R22
	CLR  R23
	CALL __ORD12
	MOVW R26,R30
	MOVW R24,R22
	LD   R30,Y
	LDD  R31,Y+1
	LDD  R30,Z+8
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __ORD12
	RJMP _0x2AF
_0x2AE:
	__GETD1N 0x0
_0x2AF:
	POP  R26
	POP  R27
	CALL __PUTDP1
;		}
	ADIW R28,2
	LDD  R30,Y+16
	LDD  R31,Y+16+1
	ADIW R30,1
	STD  Y+16,R30
	STD  Y+16+1,R31
	RJMP _0x2AC
_0x2AD:
;		i = LD2PT(vol);						/* Partition number: 0:auto, 1-4:forced */
	LDI  R30,LOW(0)
	STD  Y+16,R30
	STD  Y+16+1,R30
;		if (i) i--;
	LDD  R30,Y+16
	LDD  R31,Y+16+1
	SBIW R30,0
	BREQ _0x2B1
	SBIW R30,1
	STD  Y+16,R30
	STD  Y+16+1,R31
;		do {								/* Find an FAT volume */
_0x2B1:
_0x2B3:
;			bsect = br[i];
	LDD  R30,Y+16
	LDD  R31,Y+16+1
	MOVW R26,R28
	CALL __LSLW2
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETD1P
	__PUTD1S 46
;			fmt = bsect ? check_fs(fs, bsect) : 2;	/* Check the partition */
	CALL __CPD10
	BREQ _0x2B5
	LDD  R30,Y+24
	LDD  R31,Y+24+1
	ST   -Y,R31
	ST   -Y,R30
	__GETD2S 48
	RCALL _check_fs_G000
	RJMP _0x2B6
_0x2B5:
	LDI  R30,LOW(2)
_0x2B6:
	MOV  R17,R30
;		} while (!LD2PT(vol) && fmt && ++i < 4);
	LDI  R30,LOW(1)
	CPI  R30,0
	BREQ _0x2B8
	CPI  R17,0
	BREQ _0x2B8
	LDD  R26,Y+16
	LDD  R27,Y+16+1
	ADIW R26,1
	STD  Y+16,R26
	STD  Y+16+1,R27
	SBIW R26,4
	BRLO _0x2B9
_0x2B8:
	RJMP _0x2B4
_0x2B9:
	RJMP _0x2B3
_0x2B4:
;	}
	ADIW R28,18
;	if (fmt == 3) return FR_DISK_ERR;		/* An error occured in the disk I/O layer */
_0x2A6:
	CPI  R17,3
	BRNE _0x2BA
	LDI  R30,LOW(1)
	RJMP _0x20C0014
;	if (fmt) return FR_NO_FILESYSTEM;		/* No FAT volume is found */
_0x2BA:
	CPI  R17,0
	BREQ _0x2BB
	LDI  R30,LOW(13)
	RJMP _0x20C0014
;
;	/* An FAT volume is found. Following code initializes the file system object */
;
;	if (LD_WORD(fs->win+BPB_BytsPerSec) != SS(fs))		/* (BPB_BytsPerSec must be equal to the physical sector size) */
_0x2BB:
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LDD  R27,Z+58
	LDI  R26,LOW(0)
	LDD  R30,Z+57
	LDI  R31,0
	OR   R30,R26
	OR   R31,R27
	CPI  R30,LOW(0x200)
	LDI  R26,HIGH(0x200)
	CPC  R31,R26
	BREQ _0x2BC
;		return FR_NO_FILESYSTEM;
	LDI  R30,LOW(13)
	RJMP _0x20C0014
;
;	fasize = LD_WORD(fs->win+BPB_FATSz16);				/* Number of sectors per FAT */
_0x2BC:
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	SUBI R30,LOW(-69)
	SBCI R31,HIGH(-69)
	LD   R31,Z
	LDI  R30,LOW(0)
	MOVW R26,R30
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	SUBI R30,LOW(-68)
	SBCI R31,HIGH(-68)
	LD   R30,Z
	LDI  R31,0
	OR   R30,R26
	OR   R31,R27
	CLR  R22
	CLR  R23
	__PUTD1S 24
;	if (!fasize) fasize = LD_DWORD(fs->win+BPB_FATSz32);
	CALL __CPD10
	BRNE _0x2BD
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	SUBI R30,LOW(-85)
	SBCI R31,HIGH(-85)
	LD   R30,Z
	LDI  R31,0
	CALL __CWD1
	MOVW R26,R30
	MOVW R24,R22
	LDI  R30,LOW(24)
	CALL __LSLD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	SUBI R30,LOW(-84)
	SBCI R31,HIGH(-84)
	LD   R30,Z
	LDI  R31,0
	CALL __CWD1
	CALL __LSLD16
	CALL __ORD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	SUBI R30,LOW(-83)
	SBCI R31,HIGH(-83)
	LD   R31,Z
	LDI  R30,LOW(0)
	CLR  R22
	CLR  R23
	CALL __ORD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	SUBI R30,LOW(-82)
	SBCI R31,HIGH(-82)
	LD   R30,Z
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __ORD12
	__PUTD1S 24
;	fs->fsize = fasize;
_0x2BD:
	__GETD1S 24
	__PUTD1SNS 6,22
;
;	fs->n_fats = fs->win[BPB_NumFATs];					/* Number of FAT copies */
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LDD  R30,Z+62
	__PUTB1SNS 6,3
;	if (fs->n_fats != 1 && fs->n_fats != 2)				/* (Must be 1 or 2) */
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LDD  R26,Z+3
	CPI  R26,LOW(0x1)
	BREQ _0x2BF
	LDD  R26,Z+3
	CPI  R26,LOW(0x2)
	BRNE _0x2C0
_0x2BF:
	RJMP _0x2BE
_0x2C0:
;		return FR_NO_FILESYSTEM;
	LDI  R30,LOW(13)
	RJMP _0x20C0014
;	fasize *= fs->n_fats;								/* Number of sectors for FAT area */
_0x2BE:
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LDD  R30,Z+3
	LDI  R31,0
	__GETD2S 24
	CALL __CWD1
	CALL __MULD12U
	__PUTD1S 24
;
;	fs->csize = fs->win[BPB_SecPerClus];				/* Number of sectors per cluster */
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LDD  R30,Z+59
	__PUTB1SNS 6,2
;	if (!fs->csize || (fs->csize & (fs->csize - 1)))	/* (Must be power of 2) */
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LDD  R30,Z+2
	CPI  R30,0
	BREQ _0x2C2
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LDD  R26,Z+2
	LDD  R30,Z+2
	LDI  R31,0
	SBIW R30,1
	LDI  R27,0
	AND  R30,R26
	AND  R31,R27
	SBIW R30,0
	BREQ _0x2C1
_0x2C2:
;		return FR_NO_FILESYSTEM;
	LDI  R30,LOW(13)
	RJMP _0x20C0014
;
;	fs->n_rootdir = LD_WORD(fs->win+BPB_RootEntCnt);	/* Number of root directory entries */
_0x2C1:
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	SUBI R30,LOW(-64)
	SBCI R31,HIGH(-64)
	LD   R31,Z
	LDI  R30,LOW(0)
	MOVW R26,R30
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LDD  R30,Z+63
	LDI  R31,0
	OR   R30,R26
	OR   R31,R27
	__PUTW1SNS 6,8
;	if (fs->n_rootdir % (SS(fs) / SZ_DIR))				/* (Must be sector aligned) */
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LDD  R26,Z+8
	LDD  R27,Z+9
	MOVW R30,R26
	ANDI R30,LOW(0xF)
	BREQ _0x2C4
;		return FR_NO_FILESYSTEM;
	LDI  R30,LOW(13)
	RJMP _0x20C0014
;
;	tsect = LD_WORD(fs->win+BPB_TotSec16);				/* Number of sectors on the volume */
_0x2C4:
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	SUBI R30,LOW(-66)
	SBCI R31,HIGH(-66)
	LD   R31,Z
	LDI  R30,LOW(0)
	MOVW R26,R30
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	SUBI R30,LOW(-65)
	SBCI R31,HIGH(-65)
	LD   R30,Z
	LDI  R31,0
	OR   R30,R26
	OR   R31,R27
	CLR  R22
	CLR  R23
	__PUTD1S 20
;	if (!tsect) tsect = LD_DWORD(fs->win+BPB_TotSec32);
	CALL __CPD10
	BRNE _0x2C5
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	SUBI R30,LOW(-81)
	SBCI R31,HIGH(-81)
	LD   R30,Z
	LDI  R31,0
	CALL __CWD1
	MOVW R26,R30
	MOVW R24,R22
	LDI  R30,LOW(24)
	CALL __LSLD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	SUBI R30,LOW(-80)
	SBCI R31,HIGH(-80)
	LD   R30,Z
	LDI  R31,0
	CALL __CWD1
	CALL __LSLD16
	CALL __ORD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	SUBI R30,LOW(-79)
	SBCI R31,HIGH(-79)
	LD   R31,Z
	LDI  R30,LOW(0)
	CLR  R22
	CLR  R23
	CALL __ORD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	SUBI R30,LOW(-78)
	SBCI R31,HIGH(-78)
	LD   R30,Z
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __ORD12
	__PUTD1S 20
;
;	nrsv = LD_WORD(fs->win+BPB_RsvdSecCnt);				/* Number of reserved sectors */
_0x2C5:
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LDD  R27,Z+61
	LDI  R26,LOW(0)
	LDD  R30,Z+60
	LDI  R31,0
	OR   R30,R26
	OR   R31,R27
	MOVW R20,R30
;	if (!nrsv) return FR_NO_FILESYSTEM;					/* (Must not be 0) */
	MOV  R0,R20
	OR   R0,R21
	BRNE _0x2C6
	LDI  R30,LOW(13)
	RJMP _0x20C0014
;
;	/* Determine the FAT sub type */
;	sysect = nrsv + fasize + fs->n_rootdir / (SS(fs) / SZ_DIR);	/* RSV+FAT+DIR */
_0x2C6:
	__GETD1S 24
	MOVW R26,R20
	CLR  R24
	CLR  R25
	CALL __ADDD12
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LDD  R26,Z+8
	LDD  R27,Z+9
	MOVW R30,R26
	CALL __LSRW4
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CLR  R22
	CLR  R23
	CALL __ADDD12
	__PUTD1S 16
;	if (tsect < sysect) return FR_NO_FILESYSTEM;		/* (Invalid volume size) */
	__GETD2S 20
	CALL __CPD21
	BRSH _0x2C7
	LDI  R30,LOW(13)
	RJMP _0x20C0014
;	nclst = (tsect - sysect) / fs->csize;				/* Number of clusters */
_0x2C7:
	__GETD2S 16
	__GETD1S 20
	CALL __SUBD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LDD  R30,Z+2
	LDI  R31,0
	CALL __CWD1
	CALL __DIVD21U
	__PUTD1S 12
;	if (!nclst) return FR_NO_FILESYSTEM;				/* (Invalid volume size) */
	CALL __CPD10
	BRNE _0x2C8
	LDI  R30,LOW(13)
	RJMP _0x20C0014
;	fmt = FS_FAT12;
_0x2C8:
	LDI  R17,LOW(1)
;	if (nclst >= MIN_FAT16) fmt = FS_FAT16;
	__GETD2S 12
	__CPD2N 0xFF6
	BRLO _0x2C9
	LDI  R17,LOW(2)
;	if (nclst >= MIN_FAT32) fmt = FS_FAT32;
_0x2C9:
	__GETD2S 12
	__CPD2N 0xFFF6
	BRLO _0x2CA
	LDI  R17,LOW(3)
;
;	/* Boundaries and Limits */
;	fs->n_fatent = nclst + 2;							/* Number of FAT entries */
_0x2CA:
	__GETD1S 12
	__ADDD1N 2
	__PUTD1SNS 6,18
;	fs->volbase = bsect;								/* Volume start sector */
	__GETD1S 28
	__PUTD1SNS 6,26
;	fs->fatbase = bsect + nrsv; 						/* FAT start sector */
	MOVW R30,R20
	__GETD2S 28
	CLR  R22
	CLR  R23
	CALL __ADDD12
	__PUTD1SNS 6,30
;	fs->database = bsect + sysect;						/* Data start sector */
	__GETD1S 16
	__GETD2S 28
	CALL __ADDD12
	__PUTD1SNS 6,38
;	if (fmt == FS_FAT32) {
	CPI  R17,3
	BREQ PC+2
	RJMP _0x2CB
;		if (fs->n_rootdir) return FR_NO_FILESYSTEM;		/* (BPB_RootEntCnt must be 0) */
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADIW R26,8
	CALL __GETW1P
	SBIW R30,0
	BREQ _0x2CC
	LDI  R30,LOW(13)
	RJMP _0x20C0014
;		fs->dirbase = LD_DWORD(fs->win+BPB_RootClus);	/* Root directory start cluster */
_0x2CC:
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	SUBI R30,LOW(-93)
	SBCI R31,HIGH(-93)
	LD   R30,Z
	LDI  R31,0
	CALL __CWD1
	MOVW R26,R30
	MOVW R24,R22
	LDI  R30,LOW(24)
	CALL __LSLD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	SUBI R30,LOW(-92)
	SBCI R31,HIGH(-92)
	LD   R30,Z
	LDI  R31,0
	CALL __CWD1
	CALL __LSLD16
	CALL __ORD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	SUBI R30,LOW(-91)
	SBCI R31,HIGH(-91)
	LD   R31,Z
	LDI  R30,LOW(0)
	CLR  R22
	CLR  R23
	CALL __ORD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	SUBI R30,LOW(-90)
	SBCI R31,HIGH(-90)
	LD   R30,Z
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __ORD12
	__PUTD1SNS 6,34
;		szbfat = fs->n_fatent * 4;						/* (Required FAT size) */
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	__GETD2Z 18
	__GETD1N 0x4
	CALL __MULD12U
	RJMP _0x4E3
;	} else {
_0x2CB:
;		if (!fs->n_rootdir)	return FR_NO_FILESYSTEM;	/* (BPB_RootEntCnt must not be 0) */
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADIW R26,8
	CALL __GETW1P
	SBIW R30,0
	BRNE _0x2CE
	LDI  R30,LOW(13)
	RJMP _0x20C0014
;		fs->dirbase = fs->fatbase + fasize;				/* Root directory start sector */
_0x2CE:
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	__GETD2Z 30
	__GETD1S 24
	CALL __ADDD12
	__PUTD1SNS 6,34
;		szbfat = (fmt == FS_FAT16) ?					/* (Required FAT size) */
;			fs->n_fatent * 2 : fs->n_fatent * 3 / 2 + (fs->n_fatent & 1);
	MOV  R26,R17
	LDI  R27,0
	SBIW R26,2
	BRNE _0x2CF
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	__GETD2Z 18
	__GETD1N 0x2
	CALL __MULD12U
	RJMP _0x2D0
_0x2CF:
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	__GETD2Z 18
	__GETD1N 0x3
	CALL __MULD12U
	CALL __LSRD1
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	__GETD2Z 18
	__GETD1N 0x1
	CALL __ANDD12
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __ADDD12
_0x2D0:
_0x4E3:
	__PUTD1S 8
;	}
;	if (fs->fsize < (szbfat + (SS(fs) - 1)) / SS(fs))	/* (BPB_FATSz must not be less than required) */
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	__GETD2Z 22
	PUSH R25
	PUSH R24
	PUSH R27
	PUSH R26
	__GETD2S 8
	__ADDD2N 511
	__GETD1N 0x200
	CALL __DIVD21U
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __CPD21
	BRSH _0x2D2
;		return FR_NO_FILESYSTEM;
	LDI  R30,LOW(13)
	RJMP _0x20C0014
;
;#if !_FS_READONLY
;	/* Initialize cluster allocation information */
;	fs->last_clust = fs->free_clust = 0xFFFFFFFF;
_0x2D2:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADIW R26,14
	__GETD1N 0xFFFFFFFF
	CALL __PUTDP1
	__PUTD1SNS 6,10
;
;	/* Get fsinfo if available */
;	fs->fsi_flag = 0x80;
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADIW R26,5
	LDI  R30,LOW(128)
	ST   X,R30
;	if (fmt == FS_FAT32				/* Enable FSINFO only if FAT32 and BPB_FSInfo is 1 */
;		&& LD_WORD(fs->win+BPB_FSInfo) == 1
;		&& move_window(fs, bsect + 1) == FR_OK)
	CPI  R17,3
	BRNE _0x2D4
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	SUBI R30,LOW(-95)
	SBCI R31,HIGH(-95)
	LD   R31,Z
	LDI  R30,LOW(0)
	MOVW R26,R30
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	SUBI R30,LOW(-94)
	SBCI R31,HIGH(-94)
	LD   R30,Z
	LDI  R31,0
	OR   R30,R26
	OR   R31,R27
	SBIW R30,1
	BRNE _0x2D4
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ST   -Y,R31
	ST   -Y,R30
	__GETD2S 30
	__ADDD2N 1
	CALL _move_window_G000
	CPI  R30,0
	BREQ _0x2D5
_0x2D4:
	RJMP _0x2D3
_0x2D5:
;	{
;		fs->fsi_flag = 0;
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADIW R26,5
	LDI  R30,LOW(0)
	ST   X,R30
;		if (LD_WORD(fs->win+BS_55AA) == 0xAA55	/* Load FSINFO data if available */
;			&& LD_DWORD(fs->win+FSI_LeadSig) == 0x41615252
;			&& LD_DWORD(fs->win+FSI_StrucSig) == 0x61417272)
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,46
	MOVW R0,R30
	SUBI R30,LOW(-511)
	SBCI R31,HIGH(-511)
	LD   R31,Z
	LDI  R30,LOW(0)
	MOVW R26,R30
	MOVW R30,R0
	SUBI R30,LOW(-510)
	SBCI R31,HIGH(-510)
	LD   R30,Z
	LDI  R31,0
	OR   R30,R26
	OR   R31,R27
	CPI  R30,LOW(0xAA55)
	LDI  R26,HIGH(0xAA55)
	CPC  R31,R26
	BREQ PC+2
	RJMP _0x2D7
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LDD  R26,Z+49
	CLR  R27
	CLR  R24
	CLR  R25
	LDI  R30,LOW(24)
	CALL __LSLD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LDD  R30,Z+48
	LDI  R31,0
	CALL __CWD1
	CALL __LSLD16
	CALL __ORD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LDD  R31,Z+47
	LDI  R30,LOW(0)
	CLR  R22
	CLR  R23
	CALL __ORD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LDD  R30,Z+46
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __ORD12
	__CPD1N 0x41615252
	BRNE _0x2D7
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,46
	SUBI R30,LOW(-487)
	SBCI R31,HIGH(-487)
	LD   R26,Z
	CLR  R27
	CLR  R24
	CLR  R25
	LDI  R30,LOW(24)
	CALL __LSLD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,46
	SUBI R30,LOW(-486)
	SBCI R31,HIGH(-486)
	LD   R30,Z
	LDI  R31,0
	CALL __CWD1
	CALL __LSLD16
	CALL __ORD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,46
	SUBI R30,LOW(-485)
	SBCI R31,HIGH(-485)
	LD   R31,Z
	LDI  R30,LOW(0)
	CLR  R22
	CLR  R23
	CALL __ORD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,46
	SUBI R30,LOW(-484)
	SBCI R31,HIGH(-484)
	LD   R30,Z
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __ORD12
	__CPD1N 0x61417272
	BREQ _0x2D8
_0x2D7:
	RJMP _0x2D6
_0x2D8:
;		{
;#if !_FS_NOFSINFO
;			fs->free_clust = LD_DWORD(fs->win+FSI_Free_Count);
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,46
	SUBI R30,LOW(-491)
	SBCI R31,HIGH(-491)
	LD   R30,Z
	LDI  R31,0
	CALL __CWD1
	MOVW R26,R30
	MOVW R24,R22
	LDI  R30,LOW(24)
	CALL __LSLD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,46
	SUBI R30,LOW(-490)
	SBCI R31,HIGH(-490)
	LD   R30,Z
	LDI  R31,0
	CALL __CWD1
	CALL __LSLD16
	CALL __ORD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,46
	SUBI R30,LOW(-489)
	SBCI R31,HIGH(-489)
	LD   R31,Z
	LDI  R30,LOW(0)
	CLR  R22
	CLR  R23
	CALL __ORD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,46
	SUBI R30,LOW(-488)
	SBCI R31,HIGH(-488)
	LD   R30,Z
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __ORD12
	__PUTD1SNS 6,14
;#endif
;			fs->last_clust = LD_DWORD(fs->win+FSI_Nxt_Free);
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,46
	SUBI R30,LOW(-495)
	SBCI R31,HIGH(-495)
	LD   R30,Z
	LDI  R31,0
	CALL __CWD1
	MOVW R26,R30
	MOVW R24,R22
	LDI  R30,LOW(24)
	CALL __LSLD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,46
	SUBI R30,LOW(-494)
	SBCI R31,HIGH(-494)
	LD   R30,Z
	LDI  R31,0
	CALL __CWD1
	CALL __LSLD16
	CALL __ORD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,46
	SUBI R30,LOW(-493)
	SBCI R31,HIGH(-493)
	LD   R31,Z
	LDI  R30,LOW(0)
	CLR  R22
	CLR  R23
	CALL __ORD12
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,46
	SUBI R30,LOW(-492)
	SBCI R31,HIGH(-492)
	LD   R30,Z
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __ORD12
	__PUTD1SNS 6,10
;		}
;	}
_0x2D6:
;#endif
;	fs->fs_type = fmt;	/* FAT sub-type */
_0x2D3:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ST   X,R17
;	fs->id = ++Fsid;	/* File system mount ID */
	LDI  R26,LOW(_Fsid_G000)
	LDI  R27,HIGH(_Fsid_G000)
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
	__PUTW1SNS 6,6
;#if _FS_RPATH
;	fs->cdir = 0;		/* Current directory (root dir) */
;#endif
;#if _FS_LOCK			/* Clear file lock semaphores */
;	clear_lock(fs);
;#endif
;
;	return FR_OK;
_0x20C0015:
	LDI  R30,LOW(0)
_0x20C0014:
	CALL __LOADLOCR6
	ADIW R28,37
	RET
;}
; .FEND
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Check if the file/directory object is valid or not                    */
;/*-----------------------------------------------------------------------*/
;
;static
;FRESULT validate (	/* FR_OK(0): The object is valid, !=0: Invalid */
;	void* obj		/* Pointer to the object FIL/DIR to check validity */
;)
;{
_validate_G000:
; .FSTART _validate_G000
;	FIL *fil = (FIL*)obj;	/* Assuming offset of .fs and .id in the FIL/DIR structure is identical */
;
;
;	if (!fil || !fil->fs || !fil->fs->fs_type || fil->fs->id != fil->id)
	ST   -Y,R27
	ST   -Y,R26
	ST   -Y,R17
	ST   -Y,R16
;	*obj -> Y+2
;	*fil -> R16,R17
	__GETWRS 16,17,2
	MOV  R0,R16
	OR   R0,R17
	BREQ _0x2DA
	MOVW R26,R16
	CALL __GETW1P
	SBIW R30,0
	BREQ _0x2DA
	CALL __GETW1P
	LD   R30,Z
	CPI  R30,0
	BREQ _0x2DA
	CALL __GETW1P
	__GETWRZ 0,1,6
	ADIW R26,2
	CALL __GETW1P
	CP   R30,R0
	CPC  R31,R1
	BREQ _0x2D9
_0x2DA:
;		return FR_INVALID_OBJECT;
	LDI  R30,LOW(9)
	RJMP _0x20C0013
;
;	ENTER_FF(fil->fs);		/* Lock file system */
;
;	if (disk_status(fil->fs->drv) & STA_NOINIT)
_0x2D9:
	MOVW R26,R16
	CALL __GETW1P
	LDD  R26,Z+1
	CALL _disk_status
	ANDI R30,LOW(0x1)
	BREQ _0x2DC
;		return FR_NOT_READY;
	LDI  R30,LOW(3)
	RJMP _0x20C0013
;
;	return FR_OK;
_0x2DC:
	LDI  R30,LOW(0)
_0x20C0013:
	LDD  R17,Y+1
	LDD  R16,Y+0
	ADIW R28,4
	RET
;}
; .FEND
;
;
;
;
;/*--------------------------------------------------------------------------
;
;   Public Functions
;
;--------------------------------------------------------------------------*/
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Mount/Unmount a Logical Drive                                         */
;/*-----------------------------------------------------------------------*/
;
;FRESULT f_mount (
;	FATFS* fs,			/* Pointer to the file system object (NULL:unmount)*/
;	const TCHAR* path,	/* Logical drive number to be mounted/unmounted */
;	BYTE opt			/* 0:Do not mount (delayed mount), 1:Mount immediately */
;)
;{
_f_mount:
; .FSTART _f_mount
;	FATFS *cfs;
;	int vol;
;	FRESULT res;
;   //init_spi(1);
;
;	vol = get_ldnumber(&path);
	ST   -Y,R26
	CALL __SAVELOCR6
;	*fs -> Y+9
;	*path -> Y+7
;	opt -> Y+6
;	*cfs -> R16,R17
;	vol -> R18,R19
;	res -> R21
	MOVW R26,R28
	ADIW R26,7
	RCALL _get_ldnumber_G000
	MOVW R18,R30
;	if (vol < 0) return FR_INVALID_DRIVE;
	TST  R19
	BRPL _0x2DD
	LDI  R30,LOW(11)
	RJMP _0x20C0012
;	cfs = FatFs[vol];					/* Pointer to fs object */
_0x2DD:
	MOVW R30,R18
	LDI  R26,LOW(_FatFs_G000)
	LDI  R27,HIGH(_FatFs_G000)
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LD   R16,X+
	LD   R17,X
;
;	if (cfs) {
	MOV  R0,R16
	OR   R0,R17
	BREQ _0x2DE
;#if _FS_LOCK
;		clear_lock(cfs);
;#endif
;#if _FS_REENTRANT						/* Discard sync object of the current volume */
;		if (!ff_del_syncobj(cfs->sobj)) return FR_INT_ERR;
;#endif
;		cfs->fs_type = 0;				/* Clear old fs object */
	MOVW R26,R16
	LDI  R30,LOW(0)
	ST   X,R30
;	}
;
;	if (fs) {
_0x2DE:
	LDD  R30,Y+9
	LDD  R31,Y+9+1
	SBIW R30,0
	BREQ _0x2DF
;		fs->fs_type = 0;				/* Clear new fs object */
	LDD  R26,Y+9
	LDD  R27,Y+9+1
	LDI  R30,LOW(0)
	ST   X,R30
;#if _FS_REENTRANT						/* Create sync object for the new volume */
;		if (!ff_cre_syncobj(vol, &fs->sobj)) return FR_INT_ERR;
;#endif
;	}
;	FatFs[vol] = fs;					/* Register new fs object */
_0x2DF:
	MOVW R30,R18
	LDI  R26,LOW(_FatFs_G000)
	LDI  R27,HIGH(_FatFs_G000)
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	LDD  R26,Y+9
	LDD  R27,Y+9+1
	STD  Z+0,R26
	STD  Z+1,R27
;
;	if (!fs || opt != 1) return FR_OK;	/* Do not mount now, it will be mounted later */
	LDD  R30,Y+9
	LDD  R31,Y+9+1
	SBIW R30,0
	BREQ _0x2E1
	LDD  R26,Y+6
	CPI  R26,LOW(0x1)
	BREQ _0x2E0
_0x2E1:
	LDI  R30,LOW(0)
	RJMP _0x20C0012
;
;	res = find_volume(&fs, &path, 0);	/* Force mounted the volume */
_0x2E0:
	MOVW R30,R28
	ADIW R30,9
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,9
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	RCALL _find_volume_G000
	MOV  R21,R30
;   // release_spi();
;	LEAVE_FF(fs, res);
_0x20C0012:
	CALL __LOADLOCR6
	ADIW R28,11
	RET
;}
; .FEND
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Open or Create a File                                                 */
;/*-----------------------------------------------------------------------*/
;
;FRESULT f_open (
;	FIL* fp,			/* Pointer to the blank file object */
;	const TCHAR* path,	/* Pointer to the file name */
;	BYTE mode			/* Access mode and file open mode flags */
;)
;{
_f_open:
; .FSTART _f_open
;	FRESULT res;
;	DIR dj;
;	BYTE *dir;
;	DEF_NAMEBUF;
;    //init_spi(1);
;
;	if (!fp) return FR_INVALID_OBJECT;
	ST   -Y,R26
	SBIW R28,34
	CALL __SAVELOCR4
;	*fp -> Y+41
;	*path -> Y+39
;	mode -> Y+38
;	res -> R17
;	dj -> Y+16
;	*dir -> R18,R19
;	sfn -> Y+4
	LDD  R30,Y+41
	LDD  R31,Y+41+1
	SBIW R30,0
	BRNE _0x2E3
	LDI  R30,LOW(9)
	RJMP _0x20C0011
;	fp->fs = 0;			/* Clear file object */
_0x2E3:
	LDD  R26,Y+41
	LDD  R27,Y+41+1
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   X+,R30
	ST   X,R31
;
;	/* Get logical drive number */
;#if !_FS_READONLY
;	mode &= FA_READ | FA_WRITE | FA_CREATE_ALWAYS | FA_OPEN_ALWAYS | FA_CREATE_NEW;
	LDD  R30,Y+38
	ANDI R30,LOW(0x1F)
	STD  Y+38,R30
;	res = find_volume(&dj.fs, &path, (BYTE)(mode & ~FA_READ));
	MOVW R30,R28
	ADIW R30,16
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,41
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+42
	ANDI R30,0xFE
	MOV  R26,R30
	RCALL _find_volume_G000
	MOV  R17,R30
;#else
;	mode &= FA_READ;
;	res = find_volume(&dj.fs, &path, 0);
;#endif
;	if (res == FR_OK) {
	CPI  R17,0
	BREQ PC+2
	RJMP _0x2E4
;		INIT_BUF(dj);
	MOVW R30,R28
	ADIW R30,4
	STD  Y+36,R30
	STD  Y+36+1,R31
;		res = follow_path(&dj, path);	/* Follow the file path */
	MOVW R30,R28
	ADIW R30,16
	ST   -Y,R31
	ST   -Y,R30
	LDD  R26,Y+41
	LDD  R27,Y+41+1
	RCALL _follow_path_G000
	MOV  R17,R30
;		dir = dj.dir;
	__GETWRS 18,19,34
;#if !_FS_READONLY	/* R/W configuration */
;		if (res == FR_OK) {
	CPI  R17,0
	BRNE _0x2E5
;			if (!dir)	/* Default directory itself */
	MOV  R0,R18
	OR   R0,R19
	BRNE _0x2E6
;				res = FR_INVALID_NAME;
	LDI  R17,LOW(6)
;#if _FS_LOCK
;			else
;				res = chk_lock(&dj, (mode & ~FA_READ) ? 1 : 0);
;#endif
;		}
_0x2E6:
;		/* Create or Open a file */
;		if (mode & (FA_CREATE_ALWAYS | FA_OPEN_ALWAYS | FA_CREATE_NEW)) {
_0x2E5:
	LDD  R30,Y+38
	ANDI R30,LOW(0x1C)
	BRNE PC+2
	RJMP _0x2E7
;			DWORD dw, cl;
;
;			if (res != FR_OK) {					/* No file, create new */
	SBIW R28,8
;	*fp -> Y+49
;	*path -> Y+47
;	mode -> Y+46
;	dj -> Y+24
;	sfn -> Y+12
;	dw -> Y+4
;	cl -> Y+0
	CPI  R17,0
	BREQ _0x2E8
;				if (res == FR_NO_FILE)			/* There is no file to open, create a new entry */
	CPI  R17,4
	BRNE _0x2E9
;#if _FS_LOCK
;					res = enq_lock() ? dir_register(&dj) : FR_TOO_MANY_OPEN_FILES;
;#else
;					res = dir_register(&dj);
	MOVW R26,R28
	ADIW R26,24
	CALL _dir_register_G000
	MOV  R17,R30
;#endif
;				mode |= FA_CREATE_ALWAYS;		/* File is created */
_0x2E9:
	LDD  R30,Y+46
	ORI  R30,8
	STD  Y+46,R30
;				dir = dj.dir;					/* New entry */
	__GETWRS 18,19,42
;			}
;			else {								/* Any object is already existing */
	RJMP _0x2EA
_0x2E8:
;				if (dir[DIR_Attr] & (AM_RDO | AM_DIR)) {	/* Cannot overwrite it (R/O or DIR) */
	MOVW R30,R18
	LDD  R30,Z+11
	ANDI R30,LOW(0x11)
	BREQ _0x2EB
;					res = FR_DENIED;
	LDI  R17,LOW(7)
;				} else {
	RJMP _0x2EC
_0x2EB:
;					if (mode & FA_CREATE_NEW)	/* Cannot create as new file */
	LDD  R30,Y+46
	ANDI R30,LOW(0x4)
	BREQ _0x2ED
;						res = FR_EXIST;
	LDI  R17,LOW(8)
;				}
_0x2ED:
_0x2EC:
;			}
_0x2EA:
;			if (res == FR_OK && (mode & FA_CREATE_ALWAYS)) {	/* Truncate it if overwrite mode */
	CPI  R17,0
	BRNE _0x2EF
	LDD  R30,Y+46
	ANDI R30,LOW(0x8)
	BRNE _0x2F0
_0x2EF:
	RJMP _0x2EE
_0x2F0:
;				dw = get_fattime();				/* Created time */
	CALL _get_fattime
	__PUTD1S 4
;				ST_DWORD(dir+DIR_CrtTime, dw);
	LDD  R30,Y+4
	__PUTB1RNS 18,14
	LDD  R30,Y+5
	__PUTB1RNS 18,15
	__GETD1S 4
	CALL __LSRD16
	__PUTB1RNS 18,16
	__GETD2S 4
	LDI  R30,LOW(24)
	CALL __LSRD12
	__PUTB1RNS 18,17
;				dir[DIR_Attr] = 0;				/* Reset attribute */
	MOVW R30,R18
	ADIW R30,11
	LDI  R26,LOW(0)
	STD  Z+0,R26
;				ST_DWORD(dir+DIR_FileSize, 0);	/* size = 0 */
	MOVW R30,R18
	ADIW R30,28
	STD  Z+0,R26
	MOVW R30,R18
	ADIW R30,29
	STD  Z+0,R26
	MOVW R30,R18
	ADIW R30,30
	STD  Z+0,R26
	MOVW R30,R18
	ADIW R30,31
	STD  Z+0,R26
;				cl = ld_clust(dj.fs, dir);		/* Get start cluster */
	LDD  R30,Y+24
	LDD  R31,Y+24+1
	ST   -Y,R31
	ST   -Y,R30
	MOVW R26,R18
	CALL _ld_clust_G000
	CALL __PUTD1S0
;				st_clust(dir, 0);				/* cluster = 0 */
	ST   -Y,R19
	ST   -Y,R18
	__GETD2N 0x0
	CALL _st_clust_G000
;				dj.fs->wflag = 1;
	LDD  R26,Y+24
	LDD  R27,Y+24+1
	ADIW R26,4
	LDI  R30,LOW(1)
	ST   X,R30
;				if (cl) {						/* Remove the cluster chain if exist */
	CALL __GETD1S0
	CALL __CPD10
	BREQ _0x2F1
;					dw = dj.fs->winsect;
	LDD  R26,Y+24
	LDD  R27,Y+24+1
	ADIW R26,42
	CALL __GETD1P
	__PUTD1S 4
;					res = remove_chain(dj.fs, cl);
	LDD  R30,Y+24
	LDD  R31,Y+24+1
	ST   -Y,R31
	ST   -Y,R30
	__GETD2S 2
	CALL _remove_chain_G000
	MOV  R17,R30
;					if (res == FR_OK) {
	CPI  R17,0
	BRNE _0x2F2
;						dj.fs->last_clust = cl - 1;	/* Reuse the cluster hole */
	CALL __GETD1S0
	__SUBD1N 1
	__PUTD1SNS 24,10
;						res = move_window(dj.fs, dw);
	LDD  R30,Y+24
	LDD  R31,Y+24+1
	ST   -Y,R31
	ST   -Y,R30
	__GETD2S 6
	CALL _move_window_G000
	MOV  R17,R30
;					}
;				}
_0x2F2:
;			}
_0x2F1:
;		}
_0x2EE:
	ADIW R28,8
;		else {	/* Open an existing file */
	RJMP _0x2F3
_0x2E7:
;			if (res == FR_OK) {					/* Follow succeeded */
	CPI  R17,0
	BRNE _0x2F4
;				if (dir[DIR_Attr] & AM_DIR) {	/* It is a directory */
	MOVW R30,R18
	LDD  R30,Z+11
	ANDI R30,LOW(0x10)
	BREQ _0x2F5
;					res = FR_NO_FILE;
	LDI  R17,LOW(4)
;				} else {
	RJMP _0x2F6
_0x2F5:
;					if ((mode & FA_WRITE) && (dir[DIR_Attr] & AM_RDO)) /* R/O violation */
	LDD  R30,Y+38
	ANDI R30,LOW(0x2)
	BREQ _0x2F8
	MOVW R30,R18
	LDD  R30,Z+11
	ANDI R30,LOW(0x1)
	BRNE _0x2F9
_0x2F8:
	RJMP _0x2F7
_0x2F9:
;						res = FR_DENIED;
	LDI  R17,LOW(7)
;				}
_0x2F7:
_0x2F6:
;			}
;		}
_0x2F4:
_0x2F3:
;		if (res == FR_OK) {
	CPI  R17,0
	BRNE _0x2FA
;			if (mode & FA_CREATE_ALWAYS)		/* Set file change flag if created or overwritten */
	LDD  R30,Y+38
	ANDI R30,LOW(0x8)
	BREQ _0x2FB
;				mode |= FA__WRITTEN;
	LDD  R30,Y+38
	ORI  R30,0x20
	STD  Y+38,R30
;			fp->dir_sect = dj.fs->winsect;		/* Pointer to the directory entry */
_0x2FB:
	LDD  R26,Y+16
	LDD  R27,Y+16+1
	ADIW R26,42
	CALL __GETD1P
	__PUTD1SNS 41,26
;			fp->dir_ptr = dir;
	MOVW R30,R18
	__PUTW1SNS 41,30
;#if _FS_LOCK
;			fp->lockid = inc_lock(&dj, (mode & ~FA_READ) ? 1 : 0);
;			if (!fp->lockid) res = FR_INT_ERR;
;#endif
;		}
;
;#else				/* R/O configuration */
;		if (res == FR_OK) {					/* Follow succeeded */
;			dir = dj.dir;
;			if (!dir) {						/* Current directory itself */
;				res = FR_INVALID_NAME;
;			} else {
;				if (dir[DIR_Attr] & AM_DIR)	/* It is a directory */
;					res = FR_NO_FILE;
;			}
;		}
;#endif
;		FREE_BUF();
_0x2FA:
;
;		if (res == FR_OK) {
	CPI  R17,0
	BREQ PC+2
	RJMP _0x2FC
;			fp->flag = mode;					/* File access mode */
	LDD  R30,Y+38
	__PUTB1SNS 41,4
;			fp->err = 0;						/* Clear error flag */
	LDD  R26,Y+41
	LDD  R27,Y+41+1
	ADIW R26,5
	LDI  R30,LOW(0)
	ST   X,R30
;			fp->sclust = ld_clust(dj.fs, dir);	/* File start cluster */
	LDD  R30,Y+16
	LDD  R31,Y+16+1
	ST   -Y,R31
	ST   -Y,R30
	MOVW R26,R18
	CALL _ld_clust_G000
	__PUTD1SNS 41,14
;			fp->fsize = LD_DWORD(dir+DIR_FileSize);	/* File size */
	MOVW R30,R18
	LDD  R30,Z+31
	LDI  R31,0
	CALL __CWD1
	MOVW R26,R30
	MOVW R24,R22
	LDI  R30,LOW(24)
	CALL __LSLD12
	MOVW R26,R30
	MOVW R24,R22
	MOVW R30,R18
	LDD  R30,Z+30
	LDI  R31,0
	CALL __CWD1
	CALL __LSLD16
	CALL __ORD12
	MOVW R26,R30
	MOVW R24,R22
	MOVW R30,R18
	LDD  R31,Z+29
	LDI  R30,LOW(0)
	CLR  R22
	CLR  R23
	CALL __ORD12
	MOVW R26,R30
	MOVW R24,R22
	MOVW R30,R18
	LDD  R30,Z+28
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __ORD12
	__PUTD1SNS 41,10
;			fp->fptr = 0;						/* File pointer */
	LDD  R26,Y+41
	LDD  R27,Y+41+1
	ADIW R26,6
	__GETD1N 0x0
	CALL __PUTDP1
;			fp->dsect = 0;
	LDD  R26,Y+41
	LDD  R27,Y+41+1
	ADIW R26,22
	CALL __PUTDP1
;#if _USE_FASTSEEK
;			fp->cltbl = 0;						/* Normal seek mode */
;#endif
;			fp->fs = dj.fs;	 					/* Validate file object */
	LDD  R30,Y+16
	LDD  R31,Y+16+1
	LDD  R26,Y+41
	LDD  R27,Y+41+1
	ST   X+,R30
	ST   X,R31
;			fp->id = fp->fs->id;
	LDD  R26,Y+41
	LDD  R27,Y+41+1
	CALL __GETW1P
	ADIW R30,6
	MOVW R26,R30
	CALL __GETW1P
	__PUTW1SNS 41,2
;		}
;	}
_0x2FC:
;   //release_spi();
;	LEAVE_FF(dj.fs, res);
_0x2E4:
	MOV  R30,R17
_0x20C0011:
	CALL __LOADLOCR4
	ADIW R28,43
	RET
;}
; .FEND
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Read File                                                             */
;/*-----------------------------------------------------------------------*/
;
;FRESULT f_read (
;	FIL* fp, 		/* Pointer to the file object */
;	void* buff,		/* Pointer to data buffer */
;	UINT btr,		/* Number of bytes to read */
;	UINT* br		/* Pointer to number of bytes read */
;)
;{
_f_read:
; .FSTART _f_read
;	FRESULT res;
;	DWORD clst, sect, remain;
;	UINT rcnt, cc;
;	BYTE csect, *rbuff = (BYTE*)buff;
;
;
;	*br = 0;	/* Clear read byte counter */
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,14
	CALL __SAVELOCR6
;	*fp -> Y+26
;	*buff -> Y+24
;	btr -> Y+22
;	*br -> Y+20
;	res -> R17
;	clst -> Y+16
;	sect -> Y+12
;	remain -> Y+8
;	rcnt -> R18,R19
;	cc -> R20,R21
;	csect -> R16
;	*rbuff -> Y+6
	LDD  R30,Y+24
	LDD  R31,Y+24+1
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDD  R26,Y+20
	LDD  R27,Y+20+1
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   X+,R30
	ST   X,R31
;
;	res = validate(fp);							/* Check validity */
	LDD  R26,Y+26
	LDD  R27,Y+26+1
	RCALL _validate_G000
	MOV  R17,R30
;	if (res != FR_OK) LEAVE_FF(fp->fs, res);
	CPI  R17,0
	BREQ _0x2FD
	RJMP _0x20C0010
;	if (fp->err)								/* Check error */
_0x2FD:
	LDD  R30,Y+26
	LDD  R31,Y+26+1
	LDD  R30,Z+5
	CPI  R30,0
	BREQ _0x2FE
;		LEAVE_FF(fp->fs, (FRESULT)fp->err);
	LDD  R30,Y+26
	LDD  R31,Y+26+1
	LDD  R30,Z+5
	RJMP _0x20C0010
;	if (!(fp->flag & FA_READ)) 					/* Check access mode */
_0x2FE:
	LDD  R30,Y+26
	LDD  R31,Y+26+1
	LDD  R26,Z+4
	ANDI R26,LOW(0x1)
	BRNE _0x2FF
;		LEAVE_FF(fp->fs, FR_DENIED);
	LDI  R30,LOW(7)
	RJMP _0x20C0010
;	remain = fp->fsize - fp->fptr;
_0x2FF:
	LDD  R30,Y+26
	LDD  R31,Y+26+1
	__GETD2Z 10
	PUSH R25
	PUSH R24
	PUSH R27
	PUSH R26
	__GETD2Z 6
	POP  R30
	POP  R31
	POP  R22
	POP  R23
	CALL __SUBD12
	__PUTD1S 8
;	if (btr > remain) btr = (UINT)remain;		/* Truncate btr by remaining bytes */
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	CLR  R24
	CLR  R25
	CALL __CPD12
	BRSH _0x300
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	STD  Y+22,R30
	STD  Y+22+1,R31
;
;	for ( ;  btr;								/* Repeat until all data read */
_0x300:
_0x302:
	LDD  R30,Y+22
	LDD  R31,Y+22+1
	SBIW R30,0
	BRNE PC+2
	RJMP _0x303
;		rbuff += rcnt, fp->fptr += rcnt, *br += rcnt, btr -= rcnt) {
;		if ((fp->fptr % SS(fp->fs)) == 0) {		/* On the sector boundary? */
	LDD  R30,Y+26
	LDD  R31,Y+26+1
	__GETD2Z 6
	MOVW R30,R26
	MOVW R22,R24
	ANDI R31,HIGH(0x1FF)
	SBIW R30,0
	BREQ PC+2
	RJMP _0x304
;			csect = (BYTE)(fp->fptr / SS(fp->fs) & (fp->fs->csize - 1));	/* Sector offset in the cluster */
	LDD  R30,Y+26
	LDD  R31,Y+26+1
	__GETD2Z 6
	__GETD1N 0x200
	CALL __DIVD21U
	MOV  R0,R30
	LDD  R26,Y+26
	LDD  R27,Y+26+1
	CALL __GETW1P
	LDD  R30,Z+2
	LDI  R31,0
	SBIW R30,1
	AND  R30,R0
	MOV  R16,R30
;			if (!csect) {						/* On the cluster boundary? */
	CPI  R16,0
	BREQ PC+2
	RJMP _0x305
;				if (fp->fptr == 0) {			/* On the top of the file? */
	ADIW R26,6
	CALL __GETD1P
	CALL __CPD10
	BRNE _0x306
;					clst = fp->sclust;			/* Follow from the origin */
	LDD  R26,Y+26
	LDD  R27,Y+26+1
	ADIW R26,14
	CALL __GETD1P
	RJMP _0x4E4
;				} else {						/* Middle or end of the file */
_0x306:
;#if _USE_FASTSEEK
;					if (fp->cltbl)
;						clst = clmt_clust(fp, fp->fptr);	/* Get cluster# from the CLMT */
;					else
;#endif
;						clst = get_fat(fp->fs, fp->clust);	/* Follow cluster chain on the FAT */
	LDD  R26,Y+26
	LDD  R27,Y+26+1
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+28
	LDD  R31,Y+28+1
	__GETD2Z 18
	CALL _get_fat
_0x4E4:
	__PUTD1S 16
;				}
;				if (clst < 2) ABORT(fp->fs, FR_INT_ERR);
	__GETD2S 16
	__CPD2N 0x2
	BRSH _0x308
	LDD  R26,Y+26
	LDD  R27,Y+26+1
	ADIW R26,5
	LDI  R30,LOW(2)
	ST   X,R30
	RJMP _0x20C0010
_0x308:
;				if (clst == 0xFFFFFFFF) ABORT(fp->fs, FR_DISK_ERR);
	__GETD2S 16
	__CPD2N 0xFFFFFFFF
	BRNE _0x309
	LDD  R26,Y+26
	LDD  R27,Y+26+1
	ADIW R26,5
	LDI  R30,LOW(1)
	ST   X,R30
	RJMP _0x20C0010
_0x309:
;				fp->clust = clst;				/* Update current cluster */
	__GETD1S 16
	__PUTD1SNS 26,18
;			}
;			sect = clust2sect(fp->fs, fp->clust);	/* Get current sector */
_0x305:
	LDD  R26,Y+26
	LDD  R27,Y+26+1
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+28
	LDD  R31,Y+28+1
	__GETD2Z 18
	CALL _clust2sect
	__PUTD1S 12
;			if (!sect) ABORT(fp->fs, FR_INT_ERR);
	CALL __CPD10
	BRNE _0x30A
	LDD  R26,Y+26
	LDD  R27,Y+26+1
	ADIW R26,5
	LDI  R30,LOW(2)
	ST   X,R30
	RJMP _0x20C0010
_0x30A:
;			sect += csect;
	MOV  R30,R16
	LDI  R31,0
	__GETD2S 12
	CALL __CWD1
	CALL __ADDD12
	__PUTD1S 12
;			cc = btr / SS(fp->fs);				/* When remaining bytes >= sector size, */
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	LDI  R30,LOW(512)
	LDI  R31,HIGH(512)
	CALL __DIVW21U
	MOVW R20,R30
;			if (cc) {							/* Read maximum contiguous sectors directly */
	MOV  R0,R20
	OR   R0,R21
	BRNE PC+2
	RJMP _0x30B
;				if (csect + cc > fp->fs->csize)	/* Clip at cluster boundary */
	MOV  R30,R16
	LDI  R31,0
	ADD  R30,R20
	ADC  R31,R21
	MOVW R0,R30
	LDD  R26,Y+26
	LDD  R27,Y+26+1
	CALL __GETW1P
	LDD  R30,Z+2
	MOVW R26,R0
	LDI  R31,0
	CP   R30,R26
	CPC  R31,R27
	BRSH _0x30C
;					cc = fp->fs->csize - csect;
	LDD  R26,Y+26
	LDD  R27,Y+26+1
	CALL __GETW1P
	LDD  R30,Z+2
	LDI  R31,0
	MOVW R26,R30
	MOV  R30,R16
	LDI  R31,0
	SUB  R26,R30
	SBC  R27,R31
	MOVW R20,R26
;				if (disk_read(fp->fs->drv, rbuff, sect, cc))
_0x30C:
	LDD  R26,Y+26
	LDD  R27,Y+26+1
	CALL __GETW1P
	LDD  R30,Z+1
	ST   -Y,R30
	LDD  R30,Y+7
	LDD  R31,Y+7+1
	ST   -Y,R31
	ST   -Y,R30
	__GETD1S 15
	CALL __PUTPARD1
	MOVW R26,R20
	CALL _disk_read
	CPI  R30,0
	BREQ _0x30D
;					ABORT(fp->fs, FR_DISK_ERR);
	LDD  R26,Y+26
	LDD  R27,Y+26+1
	ADIW R26,5
	LDI  R30,LOW(1)
	ST   X,R30
	RJMP _0x20C0010
_0x30D:
;#if !_FS_READONLY && _FS_MINIMIZE <= 2			/* Replace one of the read sectors with cached data if it contains a dirty sect ...
;#if _FS_TINY
;				if (fp->fs->wflag && fp->fs->winsect - sect < cc)
	LDD  R26,Y+26
	LDD  R27,Y+26+1
	CALL __GETW1P
	MOVW R26,R30
	LDD  R30,Z+4
	CPI  R30,0
	BREQ _0x30F
	MOVW R30,R26
	ADIW R30,42
	MOVW R26,R30
	CALL __GETD1P
	__GETD2S 12
	CALL __SUBD12
	MOVW R26,R30
	MOVW R24,R22
	MOVW R30,R20
	CLR  R22
	CLR  R23
	CALL __CPD21
	BRLO _0x310
_0x30F:
	RJMP _0x30E
_0x310:
;					mem_cpy(rbuff + ((fp->fs->winsect - sect) * SS(fp->fs)), fp->fs->win, SS(fp->fs));
	LDD  R26,Y+26
	LDD  R27,Y+26+1
	CALL __GETW1P
	ADIW R30,42
	MOVW R26,R30
	CALL __GETD1P
	MOVW R26,R30
	MOVW R24,R22
	__GETD1S 12
	CALL __SUBD21
	__GETD1N 0x200
	CALL __MULD12U
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	CLR  R24
	CLR  R25
	ADD  R30,R26
	ADC  R31,R27
	ST   -Y,R31
	ST   -Y,R30
	LDD  R26,Y+28
	LDD  R27,Y+28+1
	CALL __GETW1P
	ADIW R30,46
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(512)
	LDI  R27,HIGH(512)
	CALL _mem_cpy_G000
;#else
;				if ((fp->flag & FA__DIRTY) && fp->dsect - sect < cc)
;					mem_cpy(rbuff + ((fp->dsect - sect) * SS(fp->fs)), fp->buf, SS(fp->fs));
;#endif
;#endif
;				rcnt = SS(fp->fs) * cc;			/* Number of bytes transferred */
_0x30E:
	MOVW R30,R20
	LSL  R30
	ROL  R31
	MOV  R31,R30
	LDI  R30,0
	MOVW R18,R30
;				continue;
	RJMP _0x301
;			}
;#if !_FS_TINY
;			if (fp->dsect != sect) {			/* Load data sector if not in cache */
;#if !_FS_READONLY
;				if (fp->flag & FA__DIRTY) {		/* Write-back dirty sector cache */
;					if (disk_write(fp->fs->drv, fp->buf, fp->dsect, 1))
;						ABORT(fp->fs, FR_DISK_ERR);
;					fp->flag &= ~FA__DIRTY;
;				}
;#endif
;				if (disk_read(fp->fs->drv, fp->buf, sect, 1))	/* Fill sector cache */
;					ABORT(fp->fs, FR_DISK_ERR);
;			}
;#endif
;			fp->dsect = sect;
_0x30B:
	__GETD1S 12
	__PUTD1SNS 26,22
;		}
;		rcnt = SS(fp->fs) - ((UINT)fp->fptr % SS(fp->fs));	/* Get partial sector data from sector buffer */
_0x304:
	LDD  R30,Y+26
	LDD  R31,Y+26+1
	LDD  R26,Z+6
	LDD  R27,Z+7
	MOVW R30,R26
	ANDI R31,HIGH(0x1FF)
	LDI  R26,LOW(512)
	LDI  R27,HIGH(512)
	SUB  R26,R30
	SBC  R27,R31
	MOVW R18,R26
;		if (rcnt > btr) rcnt = btr;
	LDD  R30,Y+22
	LDD  R31,Y+22+1
	CP   R30,R18
	CPC  R31,R19
	BRSH _0x311
	__GETWRS 18,19,22
;#if _FS_TINY
;		if (move_window(fp->fs, fp->dsect))		/* Move sector window */
_0x311:
	LDD  R26,Y+26
	LDD  R27,Y+26+1
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+28
	LDD  R31,Y+28+1
	__GETD2Z 22
	CALL _move_window_G000
	CPI  R30,0
	BREQ _0x312
;			ABORT(fp->fs, FR_DISK_ERR);
	LDD  R26,Y+26
	LDD  R27,Y+26+1
	ADIW R26,5
	LDI  R30,LOW(1)
	ST   X,R30
	RJMP _0x20C0010
_0x312:
;		mem_cpy(rbuff, &fp->fs->win[fp->fptr % SS(fp->fs)], rcnt);	/* Pick partial sector */
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R26,Y+28
	LDD  R27,Y+28+1
	CALL __GETW1P
	ADIW R30,46
	MOVW R0,R30
	ADIW R26,6
	CALL __GETW1P
	ANDI R31,HIGH(0x1FF)
	ADD  R30,R0
	ADC  R31,R1
	ST   -Y,R31
	ST   -Y,R30
	MOVW R26,R18
	CALL _mem_cpy_G000
;#else
;		mem_cpy(rbuff, &fp->buf[fp->fptr % SS(fp->fs)], rcnt);	/* Pick partial sector */
;#endif
;	}
_0x301:
	MOVW R30,R18
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADD  R30,R26
	ADC  R31,R27
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDD  R30,Y+26
	LDD  R31,Y+26+1
	ADIW R30,6
	MOVW R0,R30
	MOVW R26,R30
	CALL __GETD1P
	MOVW R26,R30
	MOVW R24,R22
	MOVW R30,R18
	CLR  R22
	CLR  R23
	CALL __ADDD12
	MOVW R26,R0
	CALL __PUTDP1
	LDD  R26,Y+20
	LDD  R27,Y+20+1
	LD   R30,X+
	LD   R31,X+
	ADD  R30,R18
	ADC  R31,R19
	ST   -X,R31
	ST   -X,R30
	LDD  R30,Y+22
	LDD  R31,Y+22+1
	SUB  R30,R18
	SBC  R31,R19
	STD  Y+22,R30
	STD  Y+22+1,R31
	RJMP _0x302
_0x303:
;
;	LEAVE_FF(fp->fs, FR_OK);
	LDI  R30,LOW(0)
_0x20C0010:
	CALL __LOADLOCR6
	ADIW R28,28
	RET
;}
; .FEND
;
;
;
;
;#if !_FS_READONLY
;/*-----------------------------------------------------------------------*/
;/* Write File                                                            */
;/*-----------------------------------------------------------------------*/
;
;FRESULT f_write (
;	FIL* fp,			/* Pointer to the file object */
;	const void *buff,	/* Pointer to the data to be written */
;	UINT btw,			/* Number of bytes to write */
;	UINT* bw			/* Pointer to number of bytes written */
;)
;{
_f_write:
; .FSTART _f_write
;	FRESULT res;
;	DWORD clst, sect;
;	UINT wcnt, cc;
;	const BYTE *wbuff = (const BYTE*)buff;
;	BYTE csect;
;    //init_spi(1);
;
;	*bw = 0;	/* Clear write byte counter */
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,10
	CALL __SAVELOCR6
;	*fp -> Y+22
;	*buff -> Y+20
;	btw -> Y+18
;	*bw -> Y+16
;	res -> R17
;	clst -> Y+12
;	sect -> Y+8
;	wcnt -> R18,R19
;	cc -> R20,R21
;	*wbuff -> Y+6
;	csect -> R16
	LDD  R30,Y+20
	LDD  R31,Y+20+1
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDD  R26,Y+16
	LDD  R27,Y+16+1
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   X+,R30
	ST   X,R31
;
;	res = validate(fp);						/* Check validity */
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	RCALL _validate_G000
	MOV  R17,R30
;	if (res != FR_OK) LEAVE_FF(fp->fs, res);
	CPI  R17,0
	BREQ _0x313
	RJMP _0x20C000F
;	if (fp->err)							/* Check error */
_0x313:
	LDD  R30,Y+22
	LDD  R31,Y+22+1
	LDD  R30,Z+5
	CPI  R30,0
	BREQ _0x314
;		LEAVE_FF(fp->fs, (FRESULT)fp->err);
	LDD  R30,Y+22
	LDD  R31,Y+22+1
	LDD  R30,Z+5
	RJMP _0x20C000F
;	if (!(fp->flag & FA_WRITE))				/* Check access mode */
_0x314:
	LDD  R30,Y+22
	LDD  R31,Y+22+1
	LDD  R26,Z+4
	ANDI R26,LOW(0x2)
	BRNE _0x315
;		LEAVE_FF(fp->fs, FR_DENIED);
	LDI  R30,LOW(7)
	RJMP _0x20C000F
;	if (fp->fptr + btw < fp->fptr) btw = 0;	/* File size cannot reach 4GB */
_0x315:
	LDD  R30,Y+22
	LDD  R31,Y+22+1
	__GETD2Z 6
	LDD  R30,Y+18
	LDD  R31,Y+18+1
	CLR  R22
	CLR  R23
	CALL __ADDD12
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	ADIW R26,6
	CALL __GETD1P
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __CPD21
	BRSH _0x316
	LDI  R30,LOW(0)
	STD  Y+18,R30
	STD  Y+18+1,R30
;
;	for ( ;  btw;							/* Repeat until all data written */
_0x316:
_0x318:
	LDD  R30,Y+18
	LDD  R31,Y+18+1
	SBIW R30,0
	BRNE PC+2
	RJMP _0x319
;		wbuff += wcnt, fp->fptr += wcnt, *bw += wcnt, btw -= wcnt) {
;		if ((fp->fptr % SS(fp->fs)) == 0) {	/* On the sector boundary? */
	LDD  R30,Y+22
	LDD  R31,Y+22+1
	__GETD2Z 6
	MOVW R30,R26
	MOVW R22,R24
	ANDI R31,HIGH(0x1FF)
	SBIW R30,0
	BREQ PC+2
	RJMP _0x31A
;			csect = (BYTE)(fp->fptr / SS(fp->fs) & (fp->fs->csize - 1));	/* Sector offset in the cluster */
	LDD  R30,Y+22
	LDD  R31,Y+22+1
	__GETD2Z 6
	__GETD1N 0x200
	CALL __DIVD21U
	MOV  R0,R30
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	CALL __GETW1P
	LDD  R30,Z+2
	LDI  R31,0
	SBIW R30,1
	AND  R30,R0
	MOV  R16,R30
;			if (!csect) {					/* On the cluster boundary? */
	CPI  R16,0
	BREQ PC+2
	RJMP _0x31B
;				if (fp->fptr == 0) {		/* On the top of the file? */
	ADIW R26,6
	CALL __GETD1P
	CALL __CPD10
	BRNE _0x31C
;					clst = fp->sclust;		/* Follow from the origin */
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	ADIW R26,14
	CALL __GETD1P
	__PUTD1S 12
;					if (clst == 0)			/* When no cluster is allocated, */
	CALL __CPD10
	BRNE _0x31D
;						fp->sclust = clst = create_chain(fp->fs, 0);	/* Create a new cluster chain */
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	__GETD2N 0x0
	CALL _create_chain_G000
	__PUTD1S 12
	__PUTD1SNS 22,14
;				} else {					/* Middle or end of the file */
_0x31D:
	RJMP _0x31E
_0x31C:
;#if _USE_FASTSEEK
;					if (fp->cltbl)
;						clst = clmt_clust(fp, fp->fptr);	/* Get cluster# from the CLMT */
;					else
;#endif
;						clst = create_chain(fp->fs, fp->clust);	/* Follow or stretch cluster chain on the FAT */
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+24
	LDD  R31,Y+24+1
	__GETD2Z 18
	CALL _create_chain_G000
	__PUTD1S 12
;				}
_0x31E:
;				if (clst == 0) break;		/* Could not allocate a new cluster (disk full) */
	__GETD1S 12
	CALL __CPD10
	BRNE _0x31F
	RJMP _0x319
;				if (clst == 1) ABORT(fp->fs, FR_INT_ERR);
_0x31F:
	__GETD2S 12
	__CPD2N 0x1
	BRNE _0x320
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	ADIW R26,5
	LDI  R30,LOW(2)
	ST   X,R30
	RJMP _0x20C000F
_0x320:
;				if (clst == 0xFFFFFFFF) ABORT(fp->fs, FR_DISK_ERR);
	__GETD2S 12
	__CPD2N 0xFFFFFFFF
	BRNE _0x321
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	ADIW R26,5
	LDI  R30,LOW(1)
	ST   X,R30
	RJMP _0x20C000F
_0x321:
;				fp->clust = clst;			/* Update current cluster */
	__GETD1S 12
	__PUTD1SNS 22,18
;			}
;#if _FS_TINY
;			if (fp->fs->winsect == fp->dsect && sync_window(fp->fs))	/* Write-back sector cache */
_0x31B:
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	CALL __GETW1P
	ADIW R30,42
	MOVW R26,R30
	CALL __GETD1P
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	ADIW R26,22
	CALL __GETD1P
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __CPD12
	BRNE _0x323
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	CALL __GETW1P
	MOVW R26,R30
	CALL _sync_window_G000
	CPI  R30,0
	BRNE _0x324
_0x323:
	RJMP _0x322
_0x324:
;				ABORT(fp->fs, FR_DISK_ERR);
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	ADIW R26,5
	LDI  R30,LOW(1)
	ST   X,R30
	RJMP _0x20C000F
_0x322:
;#else
;			if (fp->flag & FA__DIRTY) {		/* Write-back sector cache */
;				if (disk_write(fp->fs->drv, fp->buf, fp->dsect, 1))
;					ABORT(fp->fs, FR_DISK_ERR);
;				fp->flag &= ~FA__DIRTY;
;			}
;#endif
;			sect = clust2sect(fp->fs, fp->clust);	/* Get current sector */
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+24
	LDD  R31,Y+24+1
	__GETD2Z 18
	CALL _clust2sect
	__PUTD1S 8
;			if (!sect) ABORT(fp->fs, FR_INT_ERR);
	CALL __CPD10
	BRNE _0x325
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	ADIW R26,5
	LDI  R30,LOW(2)
	ST   X,R30
	RJMP _0x20C000F
_0x325:
;			sect += csect;
	MOV  R30,R16
	LDI  R31,0
	__GETD2S 8
	CALL __CWD1
	CALL __ADDD12
	__PUTD1S 8
;			cc = btw / SS(fp->fs);			/* When remaining bytes >= sector size, */
	LDD  R26,Y+18
	LDD  R27,Y+18+1
	LDI  R30,LOW(512)
	LDI  R31,HIGH(512)
	CALL __DIVW21U
	MOVW R20,R30
;			if (cc) {						/* Write maximum contiguous sectors directly */
	MOV  R0,R20
	OR   R0,R21
	BRNE PC+2
	RJMP _0x326
;				if (csect + cc > fp->fs->csize)	/* Clip at cluster boundary */
	MOV  R30,R16
	LDI  R31,0
	ADD  R30,R20
	ADC  R31,R21
	MOVW R0,R30
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	CALL __GETW1P
	LDD  R30,Z+2
	MOVW R26,R0
	LDI  R31,0
	CP   R30,R26
	CPC  R31,R27
	BRSH _0x327
;					cc = fp->fs->csize - csect;
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	CALL __GETW1P
	LDD  R30,Z+2
	LDI  R31,0
	MOVW R26,R30
	MOV  R30,R16
	LDI  R31,0
	SUB  R26,R30
	SBC  R27,R31
	MOVW R20,R26
;				if (disk_write(fp->fs->drv, wbuff, sect, cc))
_0x327:
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	CALL __GETW1P
	LDD  R30,Z+1
	ST   -Y,R30
	LDD  R30,Y+7
	LDD  R31,Y+7+1
	ST   -Y,R31
	ST   -Y,R30
	__GETD1S 11
	CALL __PUTPARD1
	MOVW R26,R20
	CALL _disk_write
	CPI  R30,0
	BREQ _0x328
;					ABORT(fp->fs, FR_DISK_ERR);
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	ADIW R26,5
	LDI  R30,LOW(1)
	ST   X,R30
	RJMP _0x20C000F
_0x328:
;#if _FS_MINIMIZE <= 2
;#if _FS_TINY
;				if (fp->fs->winsect - sect < cc) {	/* Refill sector cache if it gets invalidated by the direct write */
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	CALL __GETW1P
	ADIW R30,42
	MOVW R26,R30
	CALL __GETD1P
	__GETD2S 8
	CALL __SUBD12
	MOVW R26,R30
	MOVW R24,R22
	MOVW R30,R20
	CLR  R22
	CLR  R23
	CALL __CPD21
	BRSH _0x329
;					mem_cpy(fp->fs->win, wbuff + ((fp->fs->winsect - sect) * SS(fp->fs)), SS(fp->fs));
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	CALL __GETW1P
	ADIW R30,46
	ST   -Y,R31
	ST   -Y,R30
	LDD  R26,Y+24
	LDD  R27,Y+24+1
	CALL __GETW1P
	ADIW R30,42
	MOVW R26,R30
	CALL __GETD1P
	MOVW R26,R30
	MOVW R24,R22
	__GETD1S 10
	CALL __SUBD21
	__GETD1N 0x200
	CALL __MULD12U
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CLR  R24
	CLR  R25
	ADD  R30,R26
	ADC  R31,R27
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(512)
	LDI  R27,HIGH(512)
	CALL _mem_cpy_G000
;					fp->fs->wflag = 0;
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	CALL __GETW1P
	ADIW R30,4
	LDI  R26,LOW(0)
	STD  Z+0,R26
;				}
;#else
;				if (fp->dsect - sect < cc) { /* Refill sector cache if it gets invalidated by the direct write */
;					mem_cpy(fp->buf, wbuff + ((fp->dsect - sect) * SS(fp->fs)), SS(fp->fs));
;					fp->flag &= ~FA__DIRTY;
;				}
;#endif
;#endif
;				wcnt = SS(fp->fs) * cc;		/* Number of bytes transferred */
_0x329:
	MOVW R30,R20
	LSL  R30
	ROL  R31
	MOV  R31,R30
	LDI  R30,0
	MOVW R18,R30
;				continue;
	RJMP _0x317
;			}
;#if _FS_TINY
;			if (fp->fptr >= fp->fsize) {	/* Avoid silly cache filling at growing edge */
_0x326:
	LDD  R30,Y+22
	LDD  R31,Y+22+1
	__GETD2Z 6
	MOVW R0,R26
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	ADIW R26,10
	CALL __GETD1P
	MOVW R26,R0
	CALL __CPD21
	BRLO _0x32A
;				if (sync_window(fp->fs)) ABORT(fp->fs, FR_DISK_ERR);
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	CALL __GETW1P
	MOVW R26,R30
	CALL _sync_window_G000
	CPI  R30,0
	BREQ _0x32B
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	ADIW R26,5
	LDI  R30,LOW(1)
	ST   X,R30
	RJMP _0x20C000F
_0x32B:
;				fp->fs->winsect = sect;
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	CALL __GETW1P
	ADIW R30,42
	__GETD2S 8
	CALL __PUTDZ20
;			}
;#else
;			if (fp->dsect != sect) {		/* Fill sector cache with file data */
;				if (fp->fptr < fp->fsize &&
;					disk_read(fp->fs->drv, fp->buf, sect, 1))
;						ABORT(fp->fs, FR_DISK_ERR);
;			}
;#endif
;			fp->dsect = sect;
_0x32A:
	__GETD1S 8
	__PUTD1SNS 22,22
;		}
;		wcnt = SS(fp->fs) - ((UINT)fp->fptr % SS(fp->fs));/* Put partial sector into file I/O buffer */
_0x31A:
	LDD  R30,Y+22
	LDD  R31,Y+22+1
	LDD  R26,Z+6
	LDD  R27,Z+7
	MOVW R30,R26
	ANDI R31,HIGH(0x1FF)
	LDI  R26,LOW(512)
	LDI  R27,HIGH(512)
	SUB  R26,R30
	SBC  R27,R31
	MOVW R18,R26
;		if (wcnt > btw) wcnt = btw;
	LDD  R30,Y+18
	LDD  R31,Y+18+1
	CP   R30,R18
	CPC  R31,R19
	BRSH _0x32C
	__GETWRS 18,19,18
;#if _FS_TINY
;		if (move_window(fp->fs, fp->dsect))	/* Move sector window */
_0x32C:
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+24
	LDD  R31,Y+24+1
	__GETD2Z 22
	CALL _move_window_G000
	CPI  R30,0
	BREQ _0x32D
;			ABORT(fp->fs, FR_DISK_ERR);
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	ADIW R26,5
	LDI  R30,LOW(1)
	ST   X,R30
	RJMP _0x20C000F
_0x32D:
;		mem_cpy(&fp->fs->win[fp->fptr % SS(fp->fs)], wbuff, wcnt);	/* Fit partial sector */
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	CALL __GETW1P
	ADIW R30,46
	MOVW R0,R30
	ADIW R26,6
	CALL __GETW1P
	ANDI R31,HIGH(0x1FF)
	ADD  R30,R0
	ADC  R31,R1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ST   -Y,R31
	ST   -Y,R30
	MOVW R26,R18
	CALL _mem_cpy_G000
;		fp->fs->wflag = 1;
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	CALL __GETW1P
	ADIW R30,4
	LDI  R26,LOW(1)
	STD  Z+0,R26
;#else
;		mem_cpy(&fp->buf[fp->fptr % SS(fp->fs)], wbuff, wcnt);	/* Fit partial sector */
;		fp->flag |= FA__DIRTY;
;#endif
;	}
_0x317:
	MOVW R30,R18
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADD  R30,R26
	ADC  R31,R27
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDD  R30,Y+22
	LDD  R31,Y+22+1
	ADIW R30,6
	MOVW R0,R30
	MOVW R26,R30
	CALL __GETD1P
	MOVW R26,R30
	MOVW R24,R22
	MOVW R30,R18
	CLR  R22
	CLR  R23
	CALL __ADDD12
	MOVW R26,R0
	CALL __PUTDP1
	LDD  R26,Y+16
	LDD  R27,Y+16+1
	LD   R30,X+
	LD   R31,X+
	ADD  R30,R18
	ADC  R31,R19
	ST   -X,R31
	ST   -X,R30
	LDD  R30,Y+18
	LDD  R31,Y+18+1
	SUB  R30,R18
	SBC  R31,R19
	STD  Y+18,R30
	STD  Y+18+1,R31
	RJMP _0x318
_0x319:
;
;	if (fp->fptr > fp->fsize) fp->fsize = fp->fptr;	/* Update file size if needed */
	LDD  R30,Y+22
	LDD  R31,Y+22+1
	__GETD2Z 6
	MOVW R0,R26
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	ADIW R26,10
	CALL __GETD1P
	MOVW R26,R0
	CALL __CPD12
	BRSH _0x32E
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	ADIW R26,6
	CALL __GETD1P
	__PUTD1SNS 22,10
;	fp->flag |= FA__WRITTEN;						/* Set file change flag */
_0x32E:
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	ADIW R26,4
	LD   R30,X
	ORI  R30,0x20
	ST   X,R30
;    //release_spi();
;	LEAVE_FF(fp->fs, FR_OK);
	LDI  R30,LOW(0)
_0x20C000F:
	CALL __LOADLOCR6
	ADIW R28,24
	RET
;}
; .FEND
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Synchronize the File                                                  */
;/*-----------------------------------------------------------------------*/
;
;FRESULT f_sync (
;	FIL* fp		/* Pointer to the file object */
;)
;{
_f_sync:
; .FSTART _f_sync
;	FRESULT res;
;	DWORD tm;
;	BYTE *dir;
;
;
;	res = validate(fp);					/* Check validity of the object */
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,4
	CALL __SAVELOCR4
;	*fp -> Y+8
;	res -> R17
;	tm -> Y+4
;	*dir -> R18,R19
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	RCALL _validate_G000
	MOV  R17,R30
;	if (res == FR_OK) {
	CPI  R17,0
	BREQ PC+2
	RJMP _0x32F
;		if (fp->flag & FA__WRITTEN) {	/* Has the file been written? */
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	LDD  R26,Z+4
	ANDI R26,LOW(0x20)
	BRNE PC+2
	RJMP _0x330
;			/* Write-back dirty buffer */
;
;#if !_FS_TINY
;			if (fp->flag & FA__DIRTY) {
;				if (disk_write(fp->fs->drv, fp->buf, fp->dsect, 1))
;					LEAVE_FF(fp->fs, FR_DISK_ERR);
;				fp->flag &= ~FA__DIRTY;
;			}
;#endif
;			res = move_window(fp->fs, fp->dir_sect);
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	__GETD2Z 26
	CALL _move_window_G000
	MOV  R17,R30
;			if (res == FR_OK) {
	CPI  R17,0
	BREQ PC+2
	RJMP _0x331
;				dir = fp->dir_ptr;
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	ADIW R26,30
	LD   R18,X+
	LD   R19,X
;				dir[DIR_Attr] |= AM_ARC;					/* Set archive bit */
	MOVW R26,R18
	ADIW R26,11
	LD   R30,X
	ORI  R30,0x20
	ST   X,R30
;				ST_DWORD(dir+DIR_FileSize, fp->fsize);		/* Update file size */
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	LDD  R30,Z+10
	__PUTB1RNS 18,28
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	LDD  R26,Z+10
	LDD  R27,Z+11
	MOVW R30,R26
	MOV  R30,R31
	LDI  R31,0
	__PUTB1RNS 18,29
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	__GETD2Z 10
	MOVW R30,R26
	MOVW R22,R24
	CALL __LSRD16
	__PUTB1RNS 18,30
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	__GETD2Z 10
	LDI  R30,LOW(24)
	CALL __LSRD12
	__PUTB1RNS 18,31
;				st_clust(dir, fp->sclust);					/* Update start cluster */
	ST   -Y,R19
	ST   -Y,R18
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	__GETD2Z 14
	CALL _st_clust_G000
;				tm = get_fattime();							/* Update updated time */
	RCALL _get_fattime
	__PUTD1S 4
;				ST_DWORD(dir+DIR_WrtTime, tm);
	LDD  R30,Y+4
	__PUTB1RNS 18,22
	LDD  R30,Y+5
	__PUTB1RNS 18,23
	__GETD1S 4
	CALL __LSRD16
	__PUTB1RNS 18,24
	__GETD2S 4
	LDI  R30,LOW(24)
	CALL __LSRD12
	__PUTB1RNS 18,25
;				ST_WORD(dir+DIR_LstAccDate, 0);
	MOVW R30,R18
	ADIW R30,18
	LDI  R26,LOW(0)
	STD  Z+0,R26
	MOVW R30,R18
	ADIW R30,19
	STD  Z+0,R26
;				fp->flag &= ~FA__WRITTEN;
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	ADIW R26,4
	LD   R30,X
	ANDI R30,0xDF
	ST   X,R30
;				fp->fs->wflag = 1;
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __GETW1P
	ADIW R30,4
	LDI  R26,LOW(1)
	STD  Z+0,R26
;				res = sync_fs(fp->fs);
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __GETW1P
	MOVW R26,R30
	CALL _sync_fs_G000
	MOV  R17,R30
;			}
;		}
_0x331:
;	}
_0x330:
;
;	LEAVE_FF(fp->fs, res);
_0x32F:
	MOV  R30,R17
	CALL __LOADLOCR4
	ADIW R28,10
	RET
;}
; .FEND
;
;#endif /* !_FS_READONLY */
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Close File                                                            */
;/*-----------------------------------------------------------------------*/
;
;FRESULT f_close (
;	FIL *fp		/* Pointer to the file object to be closed */
;)
;{
_f_close:
; .FSTART _f_close
;	FRESULT res;
;
;    // init_spi(1);
;#if _FS_READONLY
;	res = validate(fp);
;	{
;#if _FS_REENTRANT
;		FATFS *fs = 0;
;		if (res == FR_OK) fs = fp->fs;	/* Get corresponding file system object */
;#endif
;		if (res == FR_OK) fp->fs = 0;	/* Invalidate file object */
;		LEAVE_FF(fs, res);
;	}
;#else
;	res = f_sync(fp);					/* Flush cached data */
	ST   -Y,R27
	ST   -Y,R26
	ST   -Y,R17
;	*fp -> Y+1
;	res -> R17
	LDD  R26,Y+1
	LDD  R27,Y+1+1
	RCALL _f_sync
	MOV  R17,R30
;   // release_spi();
;#if _FS_LOCK
;	if (res == FR_OK) {					/* Decrement open counter */
;#if _FS_REENTRANT
;		res = validate(fp);
;		if (res == FR_OK) {
;			res = dec_lock(fp->lockid);
;			unlock_fs(fp->fs, FR_OK);
;		}
;#else
;		res = dec_lock(fp->lockid);
;#endif
;	}
;#endif
;   // release_spi();
;	if (res == FR_OK) fp->fs = 0;		/* Invalidate file object */
	CPI  R17,0
	BRNE _0x332
	LDD  R26,Y+1
	LDD  R27,Y+1+1
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   X+,R30
	ST   X,R31
;	return res;
_0x332:
	MOV  R30,R17
	LDD  R17,Y+0
	ADIW R28,3
	RET
;#endif
;}
; .FEND
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Change Current Directory or Current Drive, Get Current Directory      */
;/*-----------------------------------------------------------------------*/
;
;#if _FS_RPATH >= 1
;#if _VOLUMES >= 2
;FRESULT f_chdrive (
;	const TCHAR* path		/* Drive number */
;)
;{
;	int vol;
;
;
;	vol = get_ldnumber(&path);
;	if (vol < 0) return FR_INVALID_DRIVE;
;
;	CurrVol = (BYTE)vol;
;
;	return FR_OK;
;}
;#endif
;
;
;FRESULT f_chdir (
;	const TCHAR* path	/* Pointer to the directory path */
;)
;{
;	FRESULT res;
;	DIR dj;
;	DEF_NAMEBUF;
;
;
;	/* Get logical drive number */
;	res = find_volume(&dj.fs, &path, 0);
;	if (res == FR_OK) {
;		INIT_BUF(dj);
;		res = follow_path(&dj, path);		/* Follow the path */
;		FREE_BUF();
;		if (res == FR_OK) {					/* Follow completed */
;			if (!dj.dir) {
;				dj.fs->cdir = dj.sclust;	/* Start directory itself */
;			} else {
;				if (dj.dir[DIR_Attr] & AM_DIR)	/* Reached to the directory */
;					dj.fs->cdir = ld_clust(dj.fs, dj.dir);
;				else
;					res = FR_NO_PATH;		/* Reached but a file */
;			}
;		}
;		if (res == FR_NO_FILE) res = FR_NO_PATH;
;	}
;
;	LEAVE_FF(dj.fs, res);
;}
;
;
;#if _FS_RPATH >= 2
;FRESULT f_getcwd (
;	TCHAR* buff,	/* Pointer to the directory path */
;	UINT len		/* Size of path */
;)
;{
;	FRESULT res;
;	DIR dj;
;	UINT i, n;
;	DWORD ccl;
;	TCHAR *tp;
;	FILINFO fno;
;	DEF_NAMEBUF;
;
;
;	*buff = 0;
;	/* Get logical drive number */
;	res = find_volume(&dj.fs, (const TCHAR**)&buff, 0);	/* Get current volume */
;	if (res == FR_OK) {
;		INIT_BUF(dj);
;		i = len;			/* Bottom of buffer (directory stack base) */
;		dj.sclust = dj.fs->cdir;			/* Start to follow upper directory from current directory */
;		while ((ccl = dj.sclust) != 0) {	/* Repeat while current directory is a sub-directory */
;			res = dir_sdi(&dj, 1);			/* Get parent directory */
;			if (res != FR_OK) break;
;			res = dir_read(&dj, 0);
;			if (res != FR_OK) break;
;			dj.sclust = ld_clust(dj.fs, dj.dir);	/* Goto parent directory */
;			res = dir_sdi(&dj, 0);
;			if (res != FR_OK) break;
;			do {							/* Find the entry links to the child directory */
;				res = dir_read(&dj, 0);
;				if (res != FR_OK) break;
;				if (ccl == ld_clust(dj.fs, dj.dir)) break;	/* Found the entry */
;				res = dir_next(&dj, 0);
;			} while (res == FR_OK);
;			if (res == FR_NO_FILE) res = FR_INT_ERR;/* It cannot be 'not found'. */
;			if (res != FR_OK) break;
;#if _USE_LFN
;			fno.lfname = buff;
;			fno.lfsize = i;
;#endif
;			get_fileinfo(&dj, &fno);		/* Get the directory name and push it to the buffer */
;			tp = fno.fname;
;#if _USE_LFN
;			if (*buff) tp = buff;
;#endif
;			for (n = 0; tp[n]; n++) ;
;			if (i < n + 3) {
;				res = FR_NOT_ENOUGH_CORE; break;
;			}
;			while (n) buff[--i] = tp[--n];
;			buff[--i] = '/';
;		}
;		tp = buff;
;		if (res == FR_OK) {
;#if _VOLUMES >= 2
;			*tp++ = '0' + CurrVol;			/* Put drive number */
;			*tp++ = ':';
;#endif
;			if (i == len) {					/* Root-directory */
;				*tp++ = '/';
;			} else {						/* Sub-directroy */
;				do		/* Add stacked path str */
;					*tp++ = buff[i++];
;				while (i < len);
;			}
;		}
;		*tp = 0;
;		FREE_BUF();
;	}
;
;	LEAVE_FF(dj.fs, res);
;}
;#endif /* _FS_RPATH >= 2 */
;#endif /* _FS_RPATH >= 1 */
;
;
;
;#if _FS_MINIMIZE <= 2
;/*-----------------------------------------------------------------------*/
;/* Seek File R/W Pointer                                                 */
;/*-----------------------------------------------------------------------*/
;
;FRESULT f_lseek (
;	FIL* fp,		/* Pointer to the file object */
;	DWORD ofs		/* File pointer from top of file */
;)
;{
_f_lseek:
; .FSTART _f_lseek
;	FRESULT res;
;    //init_spi(1);
;
;	res = validate(fp);					/* Check validity of the object */
	CALL __PUTPARD2
	ST   -Y,R17
;	*fp -> Y+5
;	ofs -> Y+1
;	res -> R17
	LDD  R26,Y+5
	LDD  R27,Y+5+1
	RCALL _validate_G000
	MOV  R17,R30
;	if (res != FR_OK) LEAVE_FF(fp->fs, res);
	CPI  R17,0
	BREQ _0x333
	LDD  R17,Y+0
	RJMP _0x20C000D
;	if (fp->err)						/* Check error */
_0x333:
	LDD  R30,Y+5
	LDD  R31,Y+5+1
	LDD  R30,Z+5
	CPI  R30,0
	BREQ _0x334
;		LEAVE_FF(fp->fs, (FRESULT)fp->err);
	LDD  R30,Y+5
	LDD  R31,Y+5+1
	LDD  R30,Z+5
	LDD  R17,Y+0
	RJMP _0x20C000D
;
;#if _USE_FASTSEEK
;	if (fp->cltbl) {	/* Fast seek */
;		DWORD cl, pcl, ncl, tcl, dsc, tlen, ulen, *tbl;
;
;		if (ofs == CREATE_LINKMAP) {	/* Create CLMT */
;			tbl = fp->cltbl;
;			tlen = *tbl++; ulen = 2;	/* Given table size and required table size */
;			cl = fp->sclust;			/* Top of the chain */
;			if (cl) {
;				do {
;					/* Get a fragment */
;					tcl = cl; ncl = 0; ulen += 2;	/* Top, length and used items */
;					do {
;						pcl = cl; ncl++;
;						cl = get_fat(fp->fs, cl);
;						if (cl <= 1) ABORT(fp->fs, FR_INT_ERR);
;						if (cl == 0xFFFFFFFF) ABORT(fp->fs, FR_DISK_ERR);
;					} while (cl == pcl + 1);
;					if (ulen <= tlen) {		/* Store the length and top of the fragment */
;						*tbl++ = ncl; *tbl++ = tcl;
;					}
;				} while (cl < fp->fs->n_fatent);	/* Repeat until end of chain */
;			}
;			*fp->cltbl = ulen;	/* Number of items used */
;			if (ulen <= tlen)
;				*tbl = 0;		/* Terminate table */
;			else
;				res = FR_NOT_ENOUGH_CORE;	/* Given table size is smaller than required */
;
;		} else {						/* Fast seek */
;			if (ofs > fp->fsize)		/* Clip offset at the file size */
;				ofs = fp->fsize;
;			fp->fptr = ofs;				/* Set file pointer */
;			if (ofs) {
;				fp->clust = clmt_clust(fp, ofs - 1);
;				dsc = clust2sect(fp->fs, fp->clust);
;				if (!dsc) ABORT(fp->fs, FR_INT_ERR);
;				dsc += (ofs - 1) / SS(fp->fs) & (fp->fs->csize - 1);
;				if (fp->fptr % SS(fp->fs) && dsc != fp->dsect) {	/* Refill sector cache if needed */
;#if !_FS_TINY
;#if !_FS_READONLY
;					if (fp->flag & FA__DIRTY) {		/* Write-back dirty sector cache */
;						if (disk_write(fp->fs->drv, fp->buf, fp->dsect, 1))
;							ABORT(fp->fs, FR_DISK_ERR);
;						fp->flag &= ~FA__DIRTY;
;					}
;#endif
;					if (disk_read(fp->fs->drv, fp->buf, dsc, 1))	/* Load current sector */
;						ABORT(fp->fs, FR_DISK_ERR);
;#endif
;					fp->dsect = dsc;
;				}
;			}
;		}
;	} else
;#endif
;
;	/* Normal Seek */
;	{
_0x334:
;		DWORD clst, bcs, nsect, ifptr;
;
;		if (ofs > fp->fsize					/* In read-only mode, clip offset with the file size */
	SBIW R28,16
;	*fp -> Y+21
;	ofs -> Y+17
;	clst -> Y+12
;	bcs -> Y+8
;	nsect -> Y+4
;	ifptr -> Y+0
;#if !_FS_READONLY
;			 && !(fp->flag & FA_WRITE)
;#endif
;			) ofs = fp->fsize;
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	ADIW R26,10
	CALL __GETD1P
	__GETD2S 17
	CALL __CPD12
	BRSH _0x336
	LDD  R30,Y+21
	LDD  R31,Y+21+1
	LDD  R26,Z+4
	ANDI R26,LOW(0x2)
	BREQ _0x337
_0x336:
	RJMP _0x335
_0x337:
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	ADIW R26,10
	CALL __GETD1P
	__PUTD1S 17
;
;		ifptr = fp->fptr;
_0x335:
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	ADIW R26,6
	CALL __GETD1P
	CALL __PUTD1S0
;		fp->fptr = nsect = 0;
	__GETD1N 0x0
	__PUTD1S 4
	__PUTD1SNS 21,6
;		if (ofs) {
	__GETD1S 17
	CALL __CPD10
	BRNE PC+2
	RJMP _0x338
;			bcs = (DWORD)fp->fs->csize * SS(fp->fs);	/* Cluster size (byte) */
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	CALL __GETW1P
	LDD  R30,Z+2
	LDI  R31,0
	CALL __CWD1
	__GETD2N 0x200
	CALL __MULD12U
	__PUTD1S 8
;			if (ifptr > 0 &&
;				(ofs - 1) / bcs >= (ifptr - 1) / bcs) {	/* When seek to same or following cluster, */
	CALL __GETD2S0
	CALL __CPD02
	BRSH _0x33A
	__GETD1S 17
	__SUBD1N 1
	MOVW R26,R30
	MOVW R24,R22
	__GETD1S 8
	CALL __DIVD21U
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	CALL __GETD1S0
	__SUBD1N 1
	MOVW R26,R30
	MOVW R24,R22
	__GETD1S 8
	CALL __DIVD21U
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __CPD21
	BRSH _0x33B
_0x33A:
	RJMP _0x339
_0x33B:
;				fp->fptr = (ifptr - 1) & ~(bcs - 1);	/* start from the current cluster */
	CALL __GETD1S0
	__SUBD1N 1
	MOVW R26,R30
	MOVW R24,R22
	__GETD1S 8
	__SUBD1N 1
	CALL __COMD1
	CALL __ANDD12
	__PUTD1SNS 21,6
;				ofs -= fp->fptr;
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	ADIW R26,6
	CALL __GETD1P
	__GETD2S 17
	CALL __SUBD21
	__PUTD2S 17
;				clst = fp->clust;
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	ADIW R26,18
	CALL __GETD1P
	__PUTD1S 12
;			} else {									/* When seek to back cluster, */
	RJMP _0x33C
_0x339:
;				clst = fp->sclust;						/* start from the first cluster */
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	ADIW R26,14
	CALL __GETD1P
	__PUTD1S 12
;#if !_FS_READONLY
;				if (clst == 0) {						/* If no cluster chain, create a new chain */
	CALL __CPD10
	BREQ PC+2
	RJMP _0x33D
;					clst = create_chain(fp->fs, 0);
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	__GETD2N 0x0
	CALL _create_chain_G000
	__PUTD1S 12
;					if (clst == 1) ABORT(fp->fs, FR_INT_ERR);
	__GETD2S 12
	__CPD2N 0x1
	BRNE _0x33E
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	ADIW R26,5
	LDI  R30,LOW(2)
	ST   X,R30
	ADIW R28,16
	LDD  R17,Y+0
	RJMP _0x20C000D
_0x33E:
;					if (clst == 0xFFFFFFFF) ABORT(fp->fs, FR_DISK_ERR);
	__GETD2S 12
	__CPD2N 0xFFFFFFFF
	BRNE _0x33F
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	ADIW R26,5
	LDI  R30,LOW(1)
	ST   X,R30
	ADIW R28,16
	LDD  R17,Y+0
	RJMP _0x20C000D
_0x33F:
;					fp->sclust = clst;
	__GETD1S 12
	__PUTD1SNS 21,14
;				}
;#endif
;				fp->clust = clst;
_0x33D:
	__GETD1S 12
	__PUTD1SNS 21,18
;			}
_0x33C:
;			if (clst != 0) {
	__GETD1S 12
	CALL __CPD10
	BRNE PC+2
	RJMP _0x340
;				while (ofs > bcs) {						/* Cluster following loop */
_0x341:
	__GETD1S 8
	__GETD2S 17
	CALL __CPD12
	BRLO PC+2
	RJMP _0x343
;#if !_FS_READONLY
;					if (fp->flag & FA_WRITE) {			/* Check if in write mode or not */
	LDD  R30,Y+21
	LDD  R31,Y+21+1
	LDD  R26,Z+4
	ANDI R26,LOW(0x2)
	BREQ _0x344
;						clst = create_chain(fp->fs, clst);	/* Force stretch if in write mode */
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	__GETD2S 14
	CALL _create_chain_G000
	__PUTD1S 12
;						if (clst == 0) {				/* When disk gets full, clip file size */
	CALL __CPD10
	BRNE _0x345
;							ofs = bcs; break;
	__GETD1S 8
	__PUTD1S 17
	RJMP _0x343
;						}
;					} else
_0x345:
	RJMP _0x346
_0x344:
;#endif
;						clst = get_fat(fp->fs, clst);	/* Follow cluster chain if not in write mode */
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	__GETD2S 14
	CALL _get_fat
	__PUTD1S 12
;					if (clst == 0xFFFFFFFF) ABORT(fp->fs, FR_DISK_ERR);
_0x346:
	__GETD2S 12
	__CPD2N 0xFFFFFFFF
	BRNE _0x347
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	ADIW R26,5
	LDI  R30,LOW(1)
	ST   X,R30
	ADIW R28,16
	LDD  R17,Y+0
	RJMP _0x20C000D
_0x347:
;					if (clst <= 1 || clst >= fp->fs->n_fatent) ABORT(fp->fs, FR_INT_ERR);
	__GETD2S 12
	__CPD2N 0x2
	BRLO _0x349
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	CALL __GETW1P
	ADIW R30,18
	MOVW R26,R30
	CALL __GETD1P
	__GETD2S 12
	CALL __CPD21
	BRLO _0x348
_0x349:
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	ADIW R26,5
	LDI  R30,LOW(2)
	ST   X,R30
	ADIW R28,16
	LDD  R17,Y+0
	RJMP _0x20C000D
_0x348:
;					fp->clust = clst;
	__GETD1S 12
	__PUTD1SNS 21,18
;					fp->fptr += bcs;
	LDD  R30,Y+21
	LDD  R31,Y+21+1
	ADIW R30,6
	MOVW R0,R30
	MOVW R26,R30
	CALL __GETD1P
	__GETD2S 8
	CALL __ADDD12
	MOVW R26,R0
	CALL __PUTDP1
;					ofs -= bcs;
	__GETD2S 8
	__GETD1S 17
	CALL __SUBD12
	__PUTD1S 17
;				}
	RJMP _0x341
_0x343:
;				fp->fptr += ofs;
	LDD  R30,Y+21
	LDD  R31,Y+21+1
	ADIW R30,6
	MOVW R0,R30
	MOVW R26,R30
	CALL __GETD1P
	__GETD2S 17
	CALL __ADDD12
	MOVW R26,R0
	CALL __PUTDP1
;				if (ofs % SS(fp->fs)) {
	__GETD1S 17
	ANDI R31,HIGH(0x1FF)
	SBIW R30,0
	BREQ _0x34B
;					nsect = clust2sect(fp->fs, clst);	/* Current sector */
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	__GETD2S 14
	CALL _clust2sect
	__PUTD1S 4
;					if (!nsect) ABORT(fp->fs, FR_INT_ERR);
	CALL __CPD10
	BRNE _0x34C
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	ADIW R26,5
	LDI  R30,LOW(2)
	ST   X,R30
	ADIW R28,16
	LDD  R17,Y+0
	RJMP _0x20C000D
_0x34C:
;					nsect += ofs / SS(fp->fs);
	__GETD2S 17
	__GETD1N 0x200
	CALL __DIVD21U
	__GETD2S 4
	CALL __ADDD12
	__PUTD1S 4
;				}
;			}
_0x34B:
;		}
_0x340:
;		if (fp->fptr % SS(fp->fs) && nsect != fp->dsect) {	/* Fill sector cache if needed */
_0x338:
	LDD  R30,Y+21
	LDD  R31,Y+21+1
	__GETD2Z 6
	MOVW R30,R26
	MOVW R22,R24
	ANDI R31,HIGH(0x1FF)
	SBIW R30,0
	BREQ _0x34E
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	ADIW R26,22
	CALL __GETD1P
	__GETD2S 4
	CALL __CPD12
	BRNE _0x34F
_0x34E:
	RJMP _0x34D
_0x34F:
;#if !_FS_TINY
;#if !_FS_READONLY
;			if (fp->flag & FA__DIRTY) {			/* Write-back dirty sector cache */
;				if (disk_write(fp->fs->drv, fp->buf, fp->dsect, 1))
;					ABORT(fp->fs, FR_DISK_ERR);
;				fp->flag &= ~FA__DIRTY;
;			}
;#endif
;			if (disk_read(fp->fs->drv, fp->buf, nsect, 1))	/* Fill sector cache */
;				ABORT(fp->fs, FR_DISK_ERR);
;#endif
;			fp->dsect = nsect;
	__GETD1S 4
	__PUTD1SNS 21,22
;		}
;#if !_FS_READONLY
;		if (fp->fptr > fp->fsize) {			/* Set file change flag if the file size is extended */
_0x34D:
	LDD  R30,Y+21
	LDD  R31,Y+21+1
	__GETD2Z 6
	MOVW R0,R26
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	ADIW R26,10
	CALL __GETD1P
	MOVW R26,R0
	CALL __CPD12
	BRSH _0x350
;			fp->fsize = fp->fptr;
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	ADIW R26,6
	CALL __GETD1P
	__PUTD1SNS 21,10
;			fp->flag |= FA__WRITTEN;
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	ADIW R26,4
	LD   R30,X
	ORI  R30,0x20
	ST   X,R30
;		}
;#endif
;	}
_0x350:
	ADIW R28,16
;   // release_spi();
;	LEAVE_FF(fp->fs, res);
	MOV  R30,R17
	LDD  R17,Y+0
	RJMP _0x20C000D
;}
; .FEND
;
;
;
;#if _FS_MINIMIZE <= 1
;/*-----------------------------------------------------------------------*/
;/* Create a Directory Object                                             */
;/*-----------------------------------------------------------------------*/
;
;FRESULT f_opendir (
;	DIR* dp,			/* Pointer to directory object to create */
;	const TCHAR* path	/* Pointer to the directory path */
;)
;{
_f_opendir:
; .FSTART _f_opendir
;	FRESULT res;
;	FATFS* fs;
;	DEF_NAMEBUF;
;
;
;	if (!dp) return FR_INVALID_OBJECT;
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,12
	CALL __SAVELOCR4
;	*dp -> Y+18
;	*path -> Y+16
;	res -> R17
;	*fs -> R18,R19
;	sfn -> Y+4
	LDD  R30,Y+18
	LDD  R31,Y+18+1
	SBIW R30,0
	BRNE _0x351
	LDI  R30,LOW(9)
	RJMP _0x20C000E
;
;	/* Get logical drive number */
;	res = find_volume(&fs, &path, 0);
_0x351:
	IN   R30,SPL
	IN   R31,SPH
	SBIW R30,1
	ST   -Y,R31
	ST   -Y,R30
	PUSH R19
	PUSH R18
	MOVW R30,R28
	ADIW R30,18
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	CALL _find_volume_G000
	POP  R18
	POP  R19
	MOV  R17,R30
;	if (res == FR_OK) {
	CPI  R17,0
	BREQ PC+2
	RJMP _0x352
;		dp->fs = fs;
	LDD  R26,Y+18
	LDD  R27,Y+18+1
	ST   X+,R18
	ST   X,R19
;		INIT_BUF(*dp);
	MOVW R30,R28
	ADIW R30,4
	__PUTW1SNS 18,20
;		res = follow_path(dp, path);			/* Follow the path to the directory */
	LDD  R30,Y+18
	LDD  R31,Y+18+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R26,Y+18
	LDD  R27,Y+18+1
	CALL _follow_path_G000
	MOV  R17,R30
;		FREE_BUF();
;		if (res == FR_OK) {						/* Follow completed */
	CPI  R17,0
	BRNE _0x353
;			if (dp->dir) {						/* It is not the origin directory itself */
	LDD  R26,Y+18
	LDD  R27,Y+18+1
	ADIW R26,18
	CALL __GETW1P
	SBIW R30,0
	BREQ _0x354
;				if (dp->dir[DIR_Attr] & AM_DIR)	/* The object is a sub directory */
	LDD  R26,Y+18
	LDD  R27,Y+18+1
	ADIW R26,18
	CALL __GETW1P
	LDD  R30,Z+11
	ANDI R30,LOW(0x10)
	BREQ _0x355
;					dp->sclust = ld_clust(fs, dp->dir);
	ST   -Y,R19
	ST   -Y,R18
	LDD  R30,Y+20
	LDD  R31,Y+20+1
	LDD  R26,Z+18
	LDD  R27,Z+19
	CALL _ld_clust_G000
	__PUTD1SNS 18,6
;				else							/* The object is a file */
	RJMP _0x356
_0x355:
;					res = FR_NO_PATH;
	LDI  R17,LOW(5)
;			}
_0x356:
;			if (res == FR_OK) {
_0x354:
	CPI  R17,0
	BRNE _0x357
;				dp->id = fs->id;
	MOVW R26,R18
	ADIW R26,6
	CALL __GETW1P
	__PUTW1SNS 18,2
;				res = dir_sdi(dp, 0);			/* Rewind directory */
	LDD  R30,Y+18
	LDD  R31,Y+18+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	CALL _dir_sdi_G000
	MOV  R17,R30
;#if _FS_LOCK
;				if (res == FR_OK) {
;					if (dp->sclust) {
;						dp->lockid = inc_lock(dp, 0);	/* Lock the sub directory */
;						if (!dp->lockid)
;							res = FR_TOO_MANY_OPEN_FILES;
;					} else {
;						dp->lockid = 0;	/* Root directory need not to be locked */
;					}
;				}
;#endif
;			}
;		}
_0x357:
;		if (res == FR_NO_FILE) res = FR_NO_PATH;
_0x353:
	CPI  R17,4
	BRNE _0x358
	LDI  R17,LOW(5)
;	}
_0x358:
;	if (res != FR_OK) dp->fs = 0;		/* Invalidate the directory object if function faild */
_0x352:
	CPI  R17,0
	BREQ _0x359
	LDD  R26,Y+18
	LDD  R27,Y+18+1
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   X+,R30
	ST   X,R31
;
;	LEAVE_FF(fs, res);
_0x359:
	MOV  R30,R17
_0x20C000E:
	CALL __LOADLOCR4
	ADIW R28,20
	RET
;}
; .FEND
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Close Directory                                                       */
;/*-----------------------------------------------------------------------*/
;
;FRESULT f_closedir (
;	DIR *dp		/* Pointer to the directory object to be closed */
;)
;{
;	FRESULT res;
;
;
;	res = validate(dp);
;	*dp -> Y+1
;	res -> R17
;#if _FS_LOCK
;	if (res == FR_OK) {				/* Decrement open counter */
;		if (dp->lockid)
;			res = dec_lock(dp->lockid);
;#if _FS_REENTRANT
;		unlock_fs(dp->fs, FR_OK);
;#endif
;	}
;#endif
;	if (res == FR_OK) dp->fs = 0;	/* Invalidate directory object */
;	return res;
;}
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Read Directory Entries in Sequence                                    */
;/*-----------------------------------------------------------------------*/
;
;FRESULT f_readdir (
;	DIR* dp,			/* Pointer to the open directory object */
;	FILINFO* fno		/* Pointer to file information to return */
;)
;{
_f_readdir:
; .FSTART _f_readdir
;	FRESULT res;
;	DEF_NAMEBUF;
;
;
;	res = validate(dp);						/* Check validity of the object */
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,12
	ST   -Y,R17
;	*dp -> Y+15
;	*fno -> Y+13
;	res -> R17
;	sfn -> Y+1
	LDD  R26,Y+15
	LDD  R27,Y+15+1
	CALL _validate_G000
	MOV  R17,R30
;	if (res == FR_OK) {
	CPI  R17,0
	BREQ PC+2
	RJMP _0x35B
;		if (!fno) {
	LDD  R30,Y+13
	LDD  R31,Y+13+1
	SBIW R30,0
	BRNE _0x35C
;			res = dir_sdi(dp, 0);			/* Rewind the directory object */
	LDD  R30,Y+15
	LDD  R31,Y+15+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	CALL _dir_sdi_G000
	MOV  R17,R30
;		} else {
	RJMP _0x35D
_0x35C:
;			INIT_BUF(*dp);
	MOVW R30,R28
	ADIW R30,1
	__PUTW1SNS 15,20
;			res = dir_read(dp, 0);			/* Read an item */
	LDD  R30,Y+15
	LDD  R31,Y+15+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	CALL _dir_read_G000
	MOV  R17,R30
;			if (res == FR_NO_FILE) {		/* Reached end of directory */
	CPI  R17,4
	BRNE _0x35E
;				dp->sect = 0;
	LDD  R26,Y+15
	LDD  R27,Y+15+1
	ADIW R26,14
	__GETD1N 0x0
	CALL __PUTDP1
;				res = FR_OK;
	LDI  R17,LOW(0)
;			}
;			if (res == FR_OK) {				/* A valid entry is found */
_0x35E:
	CPI  R17,0
	BRNE _0x35F
;				get_fileinfo(dp, fno);		/* Get the object information */
	LDD  R30,Y+15
	LDD  R31,Y+15+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R26,Y+15
	LDD  R27,Y+15+1
	CALL _get_fileinfo_G000
;				res = dir_next(dp, 0);		/* Increment index for next */
	LDD  R30,Y+15
	LDD  R31,Y+15+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	CALL _dir_next_G000
	MOV  R17,R30
;				if (res == FR_NO_FILE) {
	CPI  R17,4
	BRNE _0x360
;					dp->sect = 0;
	LDD  R26,Y+15
	LDD  R27,Y+15+1
	ADIW R26,14
	__GETD1N 0x0
	CALL __PUTDP1
;					res = FR_OK;
	LDI  R17,LOW(0)
;				}
;			}
_0x360:
;			FREE_BUF();
_0x35F:
;		}
_0x35D:
;	}
;
;	LEAVE_FF(dp->fs, res);
_0x35B:
	MOV  R30,R17
	LDD  R17,Y+0
	ADIW R28,17
	RET
;}
; .FEND
;
;
;
;#if _FS_MINIMIZE == 0
;/*-----------------------------------------------------------------------*/
;/* Get File Status                                                       */
;/*-----------------------------------------------------------------------*/
;
;FRESULT f_stat (
;	const TCHAR* path,	/* Pointer to the file path */
;	FILINFO* fno		/* Pointer to file information to return */
;)
;{
;	FRESULT res;
;	DIR dj;
;	DEF_NAMEBUF;
;
;
;	/* Get logical drive number */
;	res = find_volume(&dj.fs, &path, 0);
;	*path -> Y+37
;	*fno -> Y+35
;	res -> R17
;	dj -> Y+13
;	sfn -> Y+1
;	if (res == FR_OK) {
;		INIT_BUF(dj);
;		res = follow_path(&dj, path);	/* Follow the file path */
;		if (res == FR_OK) {				/* Follow completed */
;			if (dj.dir) {		/* Found an object */
;				if (fno) get_fileinfo(&dj, fno);
;			} else {			/* It is root directory */
;				res = FR_INVALID_NAME;
;			}
;		}
;		FREE_BUF();
;	}
;
;	LEAVE_FF(dj.fs, res);
;}
;
;
;
;#if !_FS_READONLY
;/*-----------------------------------------------------------------------*/
;/* Get Number of Free Clusters                                           */
;/*-----------------------------------------------------------------------*/
;
;FRESULT f_getfree (
;	const TCHAR* path,	/* Path name of the logical drive number */
;	DWORD* nclst,		/* Pointer to a variable to return number of free clusters */
;	FATFS** fatfs		/* Pointer to return pointer to corresponding file system object */
;)
;{
;	FRESULT res;
;	FATFS *fs;
;	DWORD n, clst, sect, stat;
;	UINT i;
;	BYTE fat, *p;
;
;
;	/* Get logical drive number */
;	res = find_volume(fatfs, &path, 0);
;	*path -> Y+28
;	*nclst -> Y+26
;	*fatfs -> Y+24
;	res -> R17
;	*fs -> R18,R19
;	n -> Y+20
;	clst -> Y+16
;	sect -> Y+12
;	stat -> Y+8
;	i -> R20,R21
;	fat -> R16
;	*p -> Y+6
;	fs = *fatfs;
;	if (res == FR_OK) {
;		/* If free_clust is valid, return it without full cluster scan */
;		if (fs->free_clust <= fs->n_fatent - 2) {
;			*nclst = fs->free_clust;
;		} else {
;			/* Get number of free clusters */
;			fat = fs->fs_type;
;			n = 0;
;			if (fat == FS_FAT12) {
;				clst = 2;
;				do {
;					stat = get_fat(fs, clst);
;					if (stat == 0xFFFFFFFF) { res = FR_DISK_ERR; break; }
;					if (stat == 1) { res = FR_INT_ERR; break; }
;					if (stat == 0) n++;
;				} while (++clst < fs->n_fatent);
;			} else {
;				clst = fs->n_fatent;
;				sect = fs->fatbase;
;				i = 0; p = 0;
;				do {
;					if (!i) {
;						res = move_window(fs, sect++);
;						if (res != FR_OK) break;
;						p = fs->win;
;						i = SS(fs);
;					}
;					if (fat == FS_FAT16) {
;						if (LD_WORD(p) == 0) n++;
;						p += 2; i -= 2;
;					} else {
;						if ((LD_DWORD(p) & 0x0FFFFFFF) == 0) n++;
;						p += 4; i -= 4;
;					}
;				} while (--clst);
;			}
;			fs->free_clust = n;
;			fs->fsi_flag |= 1;
;			*nclst = n;
;		}
;	}
;	LEAVE_FF(fs, res);
;}
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Truncate File                                                         */
;/*-----------------------------------------------------------------------*/
;
;FRESULT f_truncate (
;	FIL* fp		/* Pointer to the file object */
;)
;{
;	FRESULT res;
;	DWORD ncl;
;
;
;	res = validate(fp);						/* Check validity of the object */
;	*fp -> Y+5
;	res -> R17
;	ncl -> Y+1
;	if (res == FR_OK) {
;		if (fp->err) {						/* Check error */
;			res = (FRESULT)fp->err;
;		} else {
;			if (!(fp->flag & FA_WRITE))		/* Check access mode */
;				res = FR_DENIED;
;		}
;	}
;	if (res == FR_OK) {
;		if (fp->fsize > fp->fptr) {
;			fp->fsize = fp->fptr;	/* Set file size to current R/W point */
;			fp->flag |= FA__WRITTEN;
;			if (fp->fptr == 0) {	/* When set file size to zero, remove entire cluster chain */
;				res = remove_chain(fp->fs, fp->sclust);
;				fp->sclust = 0;
;			} else {				/* When truncate a part of the file, remove remaining clusters */
;				ncl = get_fat(fp->fs, fp->clust);
;				res = FR_OK;
;				if (ncl == 0xFFFFFFFF) res = FR_DISK_ERR;
;				if (ncl == 1) res = FR_INT_ERR;
;				if (res == FR_OK && ncl < fp->fs->n_fatent) {
;					res = put_fat(fp->fs, fp->clust, 0x0FFFFFFF);
;					if (res == FR_OK) res = remove_chain(fp->fs, ncl);
;				}
;			}
;#if !_FS_TINY
;			if (res == FR_OK && (fp->flag & FA__DIRTY)) {
;				if (disk_write(fp->fs->drv, fp->buf, fp->dsect, 1))
;					res = FR_DISK_ERR;
;				else
;					fp->flag &= ~FA__DIRTY;
;			}
;#endif
;		}
;		if (res != FR_OK) fp->err = (FRESULT)res;
;	}
;
;	LEAVE_FF(fp->fs, res);
;}
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Delete a File or Directory                                            */
;/*-----------------------------------------------------------------------*/
;
;FRESULT f_unlink (
;	const TCHAR* path		/* Pointer to the file or directory path */
;)
;{
_f_unlink:
; .FSTART _f_unlink
;	FRESULT res;
;	DIR dj, sdj;
;	BYTE *dir;
;	DWORD dclst;
;	DEF_NAMEBUF;
;
;
;	/* Get logical drive number */
;	res = find_volume(&dj.fs, &path, 1);
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,60
	CALL __SAVELOCR4
;	*path -> Y+64
;	res -> R17
;	dj -> Y+42
;	sdj -> Y+20
;	*dir -> R18,R19
;	dclst -> Y+16
;	sfn -> Y+4
	MOVW R30,R28
	ADIW R30,42
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	SUBI R30,LOW(-(66))
	SBCI R31,HIGH(-(66))
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(1)
	CALL _find_volume_G000
	MOV  R17,R30
;	if (res == FR_OK) {
	CPI  R17,0
	BREQ PC+2
	RJMP _0x389
;		INIT_BUF(dj);
	MOVW R30,R28
	ADIW R30,4
	STD  Y+62,R30
	STD  Y+62+1,R31
;		res = follow_path(&dj, path);		/* Follow the file path */
	MOVW R30,R28
	ADIW R30,42
	ST   -Y,R31
	ST   -Y,R30
	__GETW2SX 66
	CALL _follow_path_G000
	MOV  R17,R30
;		if (_FS_RPATH && res == FR_OK && (dj.fn[NS] & NS_DOT))
	LDI  R30,LOW(0)
	CPI  R30,0
	BREQ _0x38B
	CPI  R17,0
	BRNE _0x38B
	LDD  R30,Y+62
	LDD  R31,Y+62+1
	LDD  R30,Z+11
	ANDI R30,LOW(0x20)
	BRNE _0x38C
_0x38B:
	RJMP _0x38A
_0x38C:
;			res = FR_INVALID_NAME;			/* Cannot remove dot entry */
	LDI  R17,LOW(6)
;#if _FS_LOCK
;		if (res == FR_OK) res = chk_lock(&dj, 2);	/* Cannot remove open file */
;#endif
;		if (res == FR_OK) {					/* The object is accessible */
_0x38A:
	CPI  R17,0
	BREQ PC+2
	RJMP _0x38D
;			dir = dj.dir;
	__GETWRS 18,19,60
;			if (!dir) {
	MOV  R0,R18
	OR   R0,R19
	BRNE _0x38E
;				res = FR_INVALID_NAME;		/* Cannot remove the start directory */
	LDI  R17,LOW(6)
;			} else {
	RJMP _0x38F
_0x38E:
;				if (dir[DIR_Attr] & AM_RDO)
	MOVW R30,R18
	LDD  R30,Z+11
	ANDI R30,LOW(0x1)
	BREQ _0x390
;					res = FR_DENIED;		/* Cannot remove R/O object */
	LDI  R17,LOW(7)
;			}
_0x390:
_0x38F:
;			dclst = ld_clust(dj.fs, dir);
	LDD  R30,Y+42
	LDD  R31,Y+42+1
	ST   -Y,R31
	ST   -Y,R30
	MOVW R26,R18
	CALL _ld_clust_G000
	__PUTD1S 16
;			if (res == FR_OK && (dir[DIR_Attr] & AM_DIR)) {	/* Is it a sub-dir? */
	CPI  R17,0
	BRNE _0x392
	MOVW R30,R18
	LDD  R30,Z+11
	ANDI R30,LOW(0x10)
	BRNE _0x393
_0x392:
	RJMP _0x391
_0x393:
;				if (dclst < 2) {
	__GETD2S 16
	__CPD2N 0x2
	BRSH _0x394
;					res = FR_INT_ERR;
	LDI  R17,LOW(2)
;				} else {
	RJMP _0x395
_0x394:
;					mem_cpy(&sdj, &dj, sizeof (DIR));	/* Check if the sub-directory is empty or not */
	MOVW R30,R28
	ADIW R30,20
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,44
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(22)
	LDI  R27,0
	CALL _mem_cpy_G000
;					sdj.sclust = dclst;
	__GETD1S 16
	__PUTD1S 26
;					res = dir_sdi(&sdj, 2);		/* Exclude dot entries */
	MOVW R30,R28
	ADIW R30,20
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(2)
	LDI  R27,0
	CALL _dir_sdi_G000
	MOV  R17,R30
;					if (res == FR_OK) {
	CPI  R17,0
	BRNE _0x396
;						res = dir_read(&sdj, 0);	/* Read an item */
	MOVW R30,R28
	ADIW R30,20
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	CALL _dir_read_G000
	MOV  R17,R30
;						if (res == FR_OK		/* Not empty directory */
;#if _FS_RPATH
;						|| dclst == dj.fs->cdir	/* Current directory */
;#endif
;						) res = FR_DENIED;
	CPI  R17,0
	BRNE _0x397
	LDI  R17,LOW(7)
;						if (res == FR_NO_FILE) res = FR_OK;	/* Empty */
_0x397:
	CPI  R17,4
	BRNE _0x398
	LDI  R17,LOW(0)
;					}
_0x398:
;				}
_0x396:
_0x395:
;			}
;			if (res == FR_OK) {
_0x391:
	CPI  R17,0
	BRNE _0x399
;				res = dir_remove(&dj);		/* Remove the directory entry */
	MOVW R26,R28
	ADIW R26,42
	CALL _dir_remove_G000
	MOV  R17,R30
;				if (res == FR_OK) {
	CPI  R17,0
	BRNE _0x39A
;					if (dclst)				/* Remove the cluster chain if exist */
	__GETD1S 16
	CALL __CPD10
	BREQ _0x39B
;						res = remove_chain(dj.fs, dclst);
	LDD  R30,Y+42
	LDD  R31,Y+42+1
	ST   -Y,R31
	ST   -Y,R30
	__GETD2S 18
	CALL _remove_chain_G000
	MOV  R17,R30
;					if (res == FR_OK) res = sync_fs(dj.fs);
_0x39B:
	CPI  R17,0
	BRNE _0x39C
	LDD  R26,Y+42
	LDD  R27,Y+42+1
	CALL _sync_fs_G000
	MOV  R17,R30
;				}
_0x39C:
;			}
_0x39A:
;		}
_0x399:
;		FREE_BUF();
_0x38D:
;	}
;
;	LEAVE_FF(dj.fs, res);
_0x389:
	MOV  R30,R17
	CALL __LOADLOCR4
	ADIW R28,63
	ADIW R28,3
	RET
;}
; .FEND
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Create a Directory                                                    */
;/*-----------------------------------------------------------------------*/
;
;FRESULT f_mkdir (
;	const TCHAR* path		/* Pointer to the directory path */
;)
;{
_f_mkdir:
; .FSTART _f_mkdir
;	FRESULT res;
;	DIR dj;
;	BYTE *dir, n;
;	DWORD dsc, dcl, pcl, tm = get_fattime();
;	DEF_NAMEBUF;
;
;
;	/* Get logical drive number */
;	res = find_volume(&dj.fs, &path, 1);
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,50
	CALL __SAVELOCR4
;	*path -> Y+54
;	res -> R17
;	dj -> Y+32
;	*dir -> R18,R19
;	n -> R16
;	dsc -> Y+28
;	dcl -> Y+24
;	pcl -> Y+20
;	tm -> Y+16
;	sfn -> Y+4
	RCALL _get_fattime
	__PUTD1S 16
	MOVW R30,R28
	ADIW R30,32
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,56
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(1)
	CALL _find_volume_G000
	MOV  R17,R30
;	if (res == FR_OK) {
	CPI  R17,0
	BREQ PC+2
	RJMP _0x39D
;		INIT_BUF(dj);
	MOVW R30,R28
	ADIW R30,4
	STD  Y+52,R30
	STD  Y+52+1,R31
;		res = follow_path(&dj, path);			/* Follow the file path */
	MOVW R30,R28
	ADIW R30,32
	ST   -Y,R31
	ST   -Y,R30
	LDD  R26,Y+56
	LDD  R27,Y+56+1
	CALL _follow_path_G000
	MOV  R17,R30
;		if (res == FR_OK) res = FR_EXIST;		/* Any object with same name is already existing */
	CPI  R17,0
	BRNE _0x39E
	LDI  R17,LOW(8)
;		if (_FS_RPATH && res == FR_NO_FILE && (dj.fn[NS] & NS_DOT))
_0x39E:
	LDI  R30,LOW(0)
	CPI  R30,0
	BREQ _0x3A0
	CPI  R17,4
	BRNE _0x3A0
	LDD  R30,Y+52
	LDD  R31,Y+52+1
	LDD  R30,Z+11
	ANDI R30,LOW(0x20)
	BRNE _0x3A1
_0x3A0:
	RJMP _0x39F
_0x3A1:
;			res = FR_INVALID_NAME;
	LDI  R17,LOW(6)
;		if (res == FR_NO_FILE) {				/* Can create a new directory */
_0x39F:
	CPI  R17,4
	BREQ PC+2
	RJMP _0x3A2
;			dcl = create_chain(dj.fs, 0);		/* Allocate a cluster for the new directory table */
	LDD  R30,Y+32
	LDD  R31,Y+32+1
	ST   -Y,R31
	ST   -Y,R30
	__GETD2N 0x0
	CALL _create_chain_G000
	__PUTD1S 24
;			res = FR_OK;
	LDI  R17,LOW(0)
;			if (dcl == 0) res = FR_DENIED;		/* No space to allocate a new cluster */
	CALL __CPD10
	BRNE _0x3A3
	LDI  R17,LOW(7)
;			if (dcl == 1) res = FR_INT_ERR;
_0x3A3:
	__GETD2S 24
	__CPD2N 0x1
	BRNE _0x3A4
	LDI  R17,LOW(2)
;			if (dcl == 0xFFFFFFFF) res = FR_DISK_ERR;
_0x3A4:
	__GETD2S 24
	__CPD2N 0xFFFFFFFF
	BRNE _0x3A5
	LDI  R17,LOW(1)
;			if (res == FR_OK)					/* Flush FAT */
_0x3A5:
	CPI  R17,0
	BRNE _0x3A6
;				res = sync_window(dj.fs);
	LDD  R26,Y+32
	LDD  R27,Y+32+1
	CALL _sync_window_G000
	MOV  R17,R30
;			if (res == FR_OK) {					/* Initialize the new directory table */
_0x3A6:
	CPI  R17,0
	BREQ PC+2
	RJMP _0x3A7
;				dsc = clust2sect(dj.fs, dcl);
	LDD  R30,Y+32
	LDD  R31,Y+32+1
	ST   -Y,R31
	ST   -Y,R30
	__GETD2S 26
	CALL _clust2sect
	__PUTD1S 28
;				dir = dj.fs->win;
	LDD  R30,Y+32
	LDD  R31,Y+32+1
	ADIW R30,46
	MOVW R18,R30
;				mem_set(dir, 0, SS(dj.fs));
	ST   -Y,R19
	ST   -Y,R18
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(512)
	LDI  R27,HIGH(512)
	CALL _mem_set_G000
;				mem_set(dir+DIR_Name, ' ', 11);	/* Create "." entry */
	MOVW R30,R18
	ADIW R30,0
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(32)
	LDI  R31,HIGH(32)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(11)
	LDI  R27,0
	CALL _mem_set_G000
;				dir[DIR_Name] = '.';
	MOVW R26,R18
	LDI  R30,LOW(46)
	ST   X,R30
;				dir[DIR_Attr] = AM_DIR;
	MOVW R30,R18
	ADIW R30,11
	LDI  R26,LOW(16)
	STD  Z+0,R26
;				ST_DWORD(dir+DIR_WrtTime, tm);
	LDD  R30,Y+16
	__PUTB1RNS 18,22
	LDD  R30,Y+17
	__PUTB1RNS 18,23
	__GETD1S 16
	CALL __LSRD16
	__PUTB1RNS 18,24
	__GETD2S 16
	LDI  R30,LOW(24)
	CALL __LSRD12
	__PUTB1RNS 18,25
;				st_clust(dir, dcl);
	ST   -Y,R19
	ST   -Y,R18
	__GETD2S 26
	CALL _st_clust_G000
;				mem_cpy(dir+SZ_DIR, dir, SZ_DIR); 	/* Create ".." entry */
	MOVW R30,R18
	ADIW R30,32
	ST   -Y,R31
	ST   -Y,R30
	ST   -Y,R19
	ST   -Y,R18
	LDI  R26,LOW(32)
	LDI  R27,0
	CALL _mem_cpy_G000
;				dir[SZ_DIR+1] = '.'; pcl = dj.sclust;
	MOVW R30,R18
	ADIW R30,33
	LDI  R26,LOW(46)
	STD  Z+0,R26
	__GETD1S 38
	__PUTD1S 20
;				if (dj.fs->fs_type == FS_FAT32 && pcl == dj.fs->dirbase)
	LDD  R26,Y+32
	LDD  R27,Y+32+1
	LD   R26,X
	CPI  R26,LOW(0x3)
	BRNE _0x3A9
	LDD  R26,Y+32
	LDD  R27,Y+32+1
	ADIW R26,34
	CALL __GETD1P
	__GETD2S 20
	CALL __CPD12
	BREQ _0x3AA
_0x3A9:
	RJMP _0x3A8
_0x3AA:
;					pcl = 0;
	LDI  R30,LOW(0)
	__CLRD1S 20
;				st_clust(dir+SZ_DIR, pcl);
_0x3A8:
	MOVW R30,R18
	ADIW R30,32
	ST   -Y,R31
	ST   -Y,R30
	__GETD2S 22
	CALL _st_clust_G000
;				for (n = dj.fs->csize; n; n--) {	/* Write dot entries and clear following sectors */
	LDD  R30,Y+32
	LDD  R31,Y+32+1
	LDD  R16,Z+2
_0x3AC:
	CPI  R16,0
	BREQ _0x3AD
;					dj.fs->winsect = dsc++;
	__GETD1S 28
	__SUBD1N -1
	__PUTD1S 28
	SBIW R30,1
	SBCI R22,0
	SBCI R23,0
	__PUTD1SNS 32,42
;					dj.fs->wflag = 1;
	LDD  R26,Y+32
	LDD  R27,Y+32+1
	ADIW R26,4
	LDI  R30,LOW(1)
	ST   X,R30
;					res = sync_window(dj.fs);
	LDD  R26,Y+32
	LDD  R27,Y+32+1
	CALL _sync_window_G000
	MOV  R17,R30
;					if (res != FR_OK) break;
	CPI  R17,0
	BRNE _0x3AD
;					mem_set(dir, 0, SS(dj.fs));
	ST   -Y,R19
	ST   -Y,R18
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(512)
	LDI  R27,HIGH(512)
	CALL _mem_set_G000
;				}
	SUBI R16,1
	RJMP _0x3AC
_0x3AD:
;			}
;			if (res == FR_OK) res = dir_register(&dj);	/* Register the object to the directoy */
_0x3A7:
	CPI  R17,0
	BRNE _0x3AF
	MOVW R26,R28
	ADIW R26,32
	CALL _dir_register_G000
	MOV  R17,R30
;			if (res != FR_OK) {
_0x3AF:
	CPI  R17,0
	BREQ _0x3B0
;				remove_chain(dj.fs, dcl);			/* Could not register, remove cluster chain */
	LDD  R30,Y+32
	LDD  R31,Y+32+1
	ST   -Y,R31
	ST   -Y,R30
	__GETD2S 26
	CALL _remove_chain_G000
;			} else {
	RJMP _0x3B1
_0x3B0:
;				dir = dj.dir;
	__GETWRS 18,19,50
;				dir[DIR_Attr] = AM_DIR;				/* Attribute */
	MOVW R30,R18
	ADIW R30,11
	LDI  R26,LOW(16)
	STD  Z+0,R26
;				ST_DWORD(dir+DIR_WrtTime, tm);		/* Created time */
	LDD  R30,Y+16
	__PUTB1RNS 18,22
	LDD  R30,Y+17
	__PUTB1RNS 18,23
	__GETD1S 16
	CALL __LSRD16
	__PUTB1RNS 18,24
	__GETD2S 16
	LDI  R30,LOW(24)
	CALL __LSRD12
	__PUTB1RNS 18,25
;				st_clust(dir, dcl);					/* Table start cluster */
	ST   -Y,R19
	ST   -Y,R18
	__GETD2S 26
	CALL _st_clust_G000
;				dj.fs->wflag = 1;
	LDD  R26,Y+32
	LDD  R27,Y+32+1
	ADIW R26,4
	LDI  R30,LOW(1)
	ST   X,R30
;				res = sync_fs(dj.fs);
	LDD  R26,Y+32
	LDD  R27,Y+32+1
	CALL _sync_fs_G000
	MOV  R17,R30
;			}
_0x3B1:
;		}
;		FREE_BUF();
_0x3A2:
;	}
;
;	LEAVE_FF(dj.fs, res);
_0x39D:
	MOV  R30,R17
	CALL __LOADLOCR4
	ADIW R28,56
	RET
;}
; .FEND
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Change Attribute                                                      */
;/*-----------------------------------------------------------------------*/
;
;FRESULT f_chmod (
;	const TCHAR* path,	/* Pointer to the file path */
;	BYTE value,			/* Attribute bits */
;	BYTE mask			/* Attribute mask to change */
;)
;{
;	FRESULT res;
;	DIR dj;
;	BYTE *dir;
;	DEF_NAMEBUF;
;
;
;	/* Get logical drive number */
;	res = find_volume(&dj.fs, &path, 1);
;	*path -> Y+40
;	value -> Y+39
;	mask -> Y+38
;	res -> R17
;	dj -> Y+16
;	*dir -> R18,R19
;	sfn -> Y+4
;	if (res == FR_OK) {
;		INIT_BUF(dj);
;		res = follow_path(&dj, path);		/* Follow the file path */
;		FREE_BUF();
;		if (_FS_RPATH && res == FR_OK && (dj.fn[NS] & NS_DOT))
;			res = FR_INVALID_NAME;
;		if (res == FR_OK) {
;			dir = dj.dir;
;			if (!dir) {						/* Is it a root directory? */
;				res = FR_INVALID_NAME;
;			} else {						/* File or sub directory */
;				mask &= AM_RDO|AM_HID|AM_SYS|AM_ARC;	/* Valid attribute mask */
;				dir[DIR_Attr] = (value & mask) | (dir[DIR_Attr] & (BYTE)~mask);	/* Apply attribute change */
;				dj.fs->wflag = 1;
;				res = sync_fs(dj.fs);
;			}
;		}
;	}
;
;	LEAVE_FF(dj.fs, res);
;}
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Change Timestamp                                                      */
;/*-----------------------------------------------------------------------*/
;
;FRESULT f_utime (
;	const TCHAR* path,	/* Pointer to the file/directory name */
;	const FILINFO* fno	/* Pointer to the time stamp to be set */
;)
;{
;	FRESULT res;
;	DIR dj;
;	BYTE *dir;
;	DEF_NAMEBUF;
;
;
;	/* Get logical drive number */
;	res = find_volume(&dj.fs, &path, 1);
;	*path -> Y+40
;	*fno -> Y+38
;	res -> R17
;	dj -> Y+16
;	*dir -> R18,R19
;	sfn -> Y+4
;	if (res == FR_OK) {
;		INIT_BUF(dj);
;		res = follow_path(&dj, path);	/* Follow the file path */
;		FREE_BUF();
;		if (_FS_RPATH && res == FR_OK && (dj.fn[NS] & NS_DOT))
;			res = FR_INVALID_NAME;
;		if (res == FR_OK) {
;			dir = dj.dir;
;			if (!dir) {					/* Root directory */
;				res = FR_INVALID_NAME;
;			} else {					/* File or sub-directory */
;				ST_WORD(dir+DIR_WrtTime, fno->ftime);
;				ST_WORD(dir+DIR_WrtDate, fno->fdate);
;				dj.fs->wflag = 1;
;				res = sync_fs(dj.fs);
;			}
;		}
;	}
;
;	LEAVE_FF(dj.fs, res);
;}
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Rename File/Directory                                                 */
;/*-----------------------------------------------------------------------*/
;
;FRESULT f_rename (
;	const TCHAR* path_old,	/* Pointer to the old name */
;	const TCHAR* path_new	/* Pointer to the new name */
;)
;{
;	FRESULT res;
;	DIR djo, djn;
;	BYTE buf[21], *dir;
;	DWORD dw;
;	DEF_NAMEBUF;
;
;
;	/* Get logical drive number of the source object */
;	res = find_volume(&djo.fs, &path_old, 1);
;	*path_old -> Y+87
;	*path_new -> Y+85
;	res -> R17
;	djo -> Y+63
;	djn -> Y+41
;	buf -> Y+20
;	*dir -> R18,R19
;	dw -> Y+16
;	sfn -> Y+4
;	if (res == FR_OK) {
;		djn.fs = djo.fs;
;		INIT_BUF(djo);
;		res = follow_path(&djo, path_old);		/* Check old object */
;		if (_FS_RPATH && res == FR_OK && (djo.fn[NS] & NS_DOT))
;			res = FR_INVALID_NAME;
;#if _FS_LOCK
;		if (res == FR_OK) res = chk_lock(&djo, 2);
;#endif
;		if (res == FR_OK) {						/* Old object is found */
;			if (!djo.dir) {						/* Is root dir? */
;				res = FR_NO_FILE;
;			} else {
;				mem_cpy(buf, djo.dir+DIR_Attr, 21);		/* Save the object information except for name */
;				mem_cpy(&djn, &djo, sizeof (DIR));		/* Check new object */
;				res = follow_path(&djn, path_new);
;				if (res == FR_OK) res = FR_EXIST;		/* The new object name is already existing */
;				if (res == FR_NO_FILE) { 				/* Is it a valid path and no name collision? */
;/* Start critical section that any interruption can cause a cross-link */
;					res = dir_register(&djn);			/* Register the new entry */
;					if (res == FR_OK) {
;						dir = djn.dir;					/* Copy object information except for name */
;						mem_cpy(dir+13, buf+2, 19);
;						dir[DIR_Attr] = buf[0] | AM_ARC;
;						djo.fs->wflag = 1;
;						if (djo.sclust != djn.sclust && (dir[DIR_Attr] & AM_DIR)) {		/* Update .. entry in the directory if needed */
;							dw = clust2sect(djo.fs, ld_clust(djo.fs, dir));
;							if (!dw) {
;								res = FR_INT_ERR;
;							} else {
;								res = move_window(djo.fs, dw);
;								dir = djo.fs->win+SZ_DIR;	/* .. entry */
;								if (res == FR_OK && dir[1] == '.') {
;									dw = (djo.fs->fs_type == FS_FAT32 && djn.sclust == djo.fs->dirbase) ? 0 : djn.sclust;
;									st_clust(dir, dw);
;									djo.fs->wflag = 1;
;								}
;							}
;						}
;						if (res == FR_OK) {
;							res = dir_remove(&djo);		/* Remove old entry */
;							if (res == FR_OK)
;								res = sync_fs(djo.fs);
;						}
;					}
;/* End critical section */
;				}
;			}
;		}
;		FREE_BUF();
;	}
;
;	LEAVE_FF(djo.fs, res);
;}
;
;#endif /* !_FS_READONLY */
;#endif /* _FS_MINIMIZE == 0 */
;#endif /* _FS_MINIMIZE <= 1 */
;#endif /* _FS_MINIMIZE <= 2 */
;
;
;
;#if _USE_LABEL
;/*-----------------------------------------------------------------------*/
;/* Get volume label                                                      */
;/*-----------------------------------------------------------------------*/
;
;FRESULT f_getlabel (
;	const TCHAR* path,	/* Path name of the logical drive number */
;	TCHAR* label,		/* Pointer to a buffer to return the volume label */
;	DWORD* sn			/* Pointer to a variable to return the volume serial number */
;)
;{
;	FRESULT res;
;	DIR dj;
;	UINT i, j;
;
;
;	/* Get logical drive number */
;	res = find_volume(&dj.fs, &path, 0);
;
;	/* Get volume label */
;	if (res == FR_OK && label) {
;		dj.sclust = 0;					/* Open root directory */
;		res = dir_sdi(&dj, 0);
;		if (res == FR_OK) {
;			res = dir_read(&dj, 1);		/* Get an entry with AM_VOL */
;			if (res == FR_OK) {			/* A volume label is exist */
;#if _LFN_UNICODE
;				WCHAR w;
;				i = j = 0;
;				do {
;					w = (i < 11) ? dj.dir[i++] : ' ';
;					if (IsDBCS1(w) && i < 11 && IsDBCS2(dj.dir[i]))
;						w = w << 8 | dj.dir[i++];
;					label[j++] = ff_convert(w, 1);	/* OEM -> Unicode */
;				} while (j < 11);
;#else
;				mem_cpy(label, dj.dir, 11);
;#endif
;				j = 11;
;				do {
;					label[j] = 0;
;					if (!j) break;
;				} while (label[--j] == ' ');
;			}
;			if (res == FR_NO_FILE) {	/* No label, return nul string */
;				label[0] = 0;
;				res = FR_OK;
;			}
;		}
;	}
;
;	/* Get volume serial number */
;	if (res == FR_OK && sn) {
;		res = move_window(dj.fs, dj.fs->volbase);
;		if (res == FR_OK) {
;			i = dj.fs->fs_type == FS_FAT32 ? BS_VolID32 : BS_VolID;
;			*sn = LD_DWORD(&dj.fs->win[i]);
;		}
;	}
;
;	LEAVE_FF(dj.fs, res);
;}
;
;
;
;#if !_FS_READONLY
;/*-----------------------------------------------------------------------*/
;/* Set volume label                                                      */
;/*-----------------------------------------------------------------------*/
;
;FRESULT f_setlabel (
;	const TCHAR* label	/* Pointer to the volume label to set */
;)
;{
;	FRESULT res;
;	DIR dj;
;	BYTE vn[11];
;	UINT i, j, sl;
;	WCHAR w;
;	DWORD tm;
;
;
;	/* Get logical drive number */
;	res = find_volume(&dj.fs, &label, 1);
;	if (res) LEAVE_FF(dj.fs, res);
;
;	/* Create a volume label in directory form */
;	vn[0] = 0;
;	for (sl = 0; label[sl]; sl++) ;				/* Get name length */
;	for ( ; sl && label[sl-1] == ' '; sl--) ;	/* Remove trailing spaces */
;	if (sl) {	/* Create volume label in directory form */
;		i = j = 0;
;		do {
;#if _LFN_UNICODE
;			w = ff_convert(ff_wtoupper(label[i++]), 0);
;#else
;			w = (BYTE)label[i++];
;			if (IsDBCS1(w))
;				w = (j < 10 && i < sl && IsDBCS2(label[i])) ? w << 8 | (BYTE)label[i++] : 0;
;#if _USE_LFN
;			w = ff_convert(ff_wtoupper(ff_convert(w, 1)), 0);
;#else
;			if (IsLower(w)) w -= 0x20;			/* To upper ASCII characters */
;#ifdef _EXCVT
;			if (w >= 0x80) w = ExCvt[w - 0x80];	/* To upper extended characters (SBCS cfg) */
;#else
;			if (!_DF1S && w >= 0x80) w = 0;		/* Reject extended characters (ASCII cfg) */
;#endif
;#endif
;#endif
;			if (!w || chk_chr("\"*+,.:;<=>\?[]|\x7F", w) || j >= (UINT)((w >= 0x100) ? 10 : 11)) /* Reject invalid characters for ...
;				LEAVE_FF(dj.fs, FR_INVALID_NAME);
;			if (w >= 0x100) vn[j++] = (BYTE)(w >> 8);
;			vn[j++] = (BYTE)w;
;		} while (i < sl);
;		while (j < 11) vn[j++] = ' ';
;	}
;
;	/* Set volume label */
;	dj.sclust = 0;					/* Open root directory */
;	res = dir_sdi(&dj, 0);
;	if (res == FR_OK) {
;		res = dir_read(&dj, 1);		/* Get an entry with AM_VOL */
;		if (res == FR_OK) {			/* A volume label is found */
;			if (vn[0]) {
;				mem_cpy(dj.dir, vn, 11);	/* Change the volume label name */
;				tm = get_fattime();
;				ST_DWORD(dj.dir+DIR_WrtTime, tm);
;			} else {
;				dj.dir[0] = DDE;			/* Remove the volume label */
;			}
;			dj.fs->wflag = 1;
;			res = sync_fs(dj.fs);
;		} else {					/* No volume label is found or error */
;			if (res == FR_NO_FILE) {
;				res = FR_OK;
;				if (vn[0]) {				/* Create volume label as new */
;					res = dir_alloc(&dj, 1);	/* Allocate an entry for volume label */
;					if (res == FR_OK) {
;						mem_set(dj.dir, 0, SZ_DIR);	/* Set volume label */
;						mem_cpy(dj.dir, vn, 11);
;						dj.dir[DIR_Attr] = AM_VOL;
;						tm = get_fattime();
;						ST_DWORD(dj.dir+DIR_WrtTime, tm);
;						dj.fs->wflag = 1;
;						res = sync_fs(dj.fs);
;					}
;				}
;			}
;		}
;	}
;
;	LEAVE_FF(dj.fs, res);
;}
;
;#endif /* !_FS_READONLY */
;#endif /* _USE_LABEL */
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Forward data to the stream directly (available on only tiny cfg)      */
;/*-----------------------------------------------------------------------*/
;#if _USE_FORWARD && _FS_TINY
;
;FRESULT f_forward (
;	FIL* fp, 						/* Pointer to the file object */
;	UINT (*func)(const BYTE*,UINT),	/* Pointer to the streaming function */
;	UINT btf,						/* Number of bytes to forward */
;	UINT* bf						/* Pointer to number of bytes forwarded */
;)
;{
;	FRESULT res;
;	DWORD remain, clst, sect;
;	UINT rcnt;
;	BYTE csect;
;
;
;	*bf = 0;	/* Clear transfer byte counter */
;
;	res = validate(fp);								/* Check validity of the object */
;	if (res != FR_OK) LEAVE_FF(fp->fs, res);
;	if (fp->err)									/* Check error */
;		LEAVE_FF(fp->fs, (FRESULT)fp->err);
;	if (!(fp->flag & FA_READ))						/* Check access mode */
;		LEAVE_FF(fp->fs, FR_DENIED);
;
;	remain = fp->fsize - fp->fptr;
;	if (btf > remain) btf = (UINT)remain;			/* Truncate btf by remaining bytes */
;
;	for ( ;  btf && (*func)(0, 0);					/* Repeat until all data transferred or stream becomes busy */
;		fp->fptr += rcnt, *bf += rcnt, btf -= rcnt) {
;		csect = (BYTE)(fp->fptr / SS(fp->fs) & (fp->fs->csize - 1));	/* Sector offset in the cluster */
;		if ((fp->fptr % SS(fp->fs)) == 0) {			/* On the sector boundary? */
;			if (!csect) {							/* On the cluster boundary? */
;				clst = (fp->fptr == 0) ?			/* On the top of the file? */
;					fp->sclust : get_fat(fp->fs, fp->clust);
;				if (clst <= 1) ABORT(fp->fs, FR_INT_ERR);
;				if (clst == 0xFFFFFFFF) ABORT(fp->fs, FR_DISK_ERR);
;				fp->clust = clst;					/* Update current cluster */
;			}
;		}
;		sect = clust2sect(fp->fs, fp->clust);		/* Get current data sector */
;		if (!sect) ABORT(fp->fs, FR_INT_ERR);
;		sect += csect;
;		if (move_window(fp->fs, sect))				/* Move sector window */
;			ABORT(fp->fs, FR_DISK_ERR);
;		fp->dsect = sect;
;		rcnt = SS(fp->fs) - (WORD)(fp->fptr % SS(fp->fs));	/* Forward data from sector window */
;		if (rcnt > btf) rcnt = btf;
;		rcnt = (*func)(&fp->fs->win[(WORD)fp->fptr % SS(fp->fs)], rcnt);
;		if (!rcnt) ABORT(fp->fs, FR_INT_ERR);
;	}
;
;	LEAVE_FF(fp->fs, FR_OK);
;}
;#endif /* _USE_FORWARD */
;
;
;
;#if _USE_MKFS && !_FS_READONLY
;/*-----------------------------------------------------------------------*/
;/* Create File System on the Drive                                       */
;/*-----------------------------------------------------------------------*/
;#define N_ROOTDIR	512		/* Number of root directory entries for FAT12/16 */
;#define N_FATS		1		/* Number of FAT copies (1 or 2) */
;
;
;FRESULT f_mkfs (
;	const TCHAR* path,	/* Logical drive number */
;	BYTE sfd,			/* Partitioning rule 0:FDISK, 1:SFD */
;	UINT au				/* Allocation unit [bytes] */
;)
;{
;	static const WORD vst[] = { 1024,   512,  256,  128,   64,    32,   16,    8,    4,    2,   0};
;	static const WORD cst[] = {32768, 16384, 8192, 4096, 2048, 16384, 8192, 4096, 2048, 1024, 512};
;	int vol;
;	BYTE fmt, md, sys, *tbl, pdrv, part;
;	DWORD n_clst, vs, n, wsect;
;	UINT i;
;	DWORD b_vol, b_fat, b_dir, b_data;	/* LBA */
;	DWORD n_vol, n_rsv, n_fat, n_dir;	/* Size */
;	FATFS *fs;
;	DSTATUS stat;
;
;
;	/* Check mounted drive and clear work area */
;	vol = get_ldnumber(&path);
;	if (vol < 0) return FR_INVALID_DRIVE;
;	if (sfd > 1) return FR_INVALID_PARAMETER;
;	if (au & (au - 1)) return FR_INVALID_PARAMETER;
;	fs = FatFs[vol];
;	if (!fs) return FR_NOT_ENABLED;
;	fs->fs_type = 0;
;	pdrv = LD2PD(vol);	/* Physical drive */
;	part = LD2PT(vol);	/* Partition (0:auto detect, 1-4:get from partition table)*/
;
;	/* Get disk statics */
;	stat = disk_initialize(pdrv);
;	if (stat & STA_NOINIT) return FR_NOT_READY;
;	if (stat & STA_PROTECT) return FR_WRITE_PROTECTED;
;#if _MAX_SS != 512					/* Get disk sector size */
;	if (disk_ioctl(pdrv, GET_SECTOR_SIZE, &SS(fs)) != RES_OK || SS(fs) > _MAX_SS)
;		return FR_DISK_ERR;
;#endif
;	if (_MULTI_PARTITION && part) {
;		/* Get partition information from partition table in the MBR */
;		if (disk_read(pdrv, fs->win, 0, 1)) return FR_DISK_ERR;
;		if (LD_WORD(fs->win+BS_55AA) != 0xAA55) return FR_MKFS_ABORTED;
;		tbl = &fs->win[MBR_Table + (part - 1) * SZ_PTE];
;		if (!tbl[4]) return FR_MKFS_ABORTED;	/* No partition? */
;		b_vol = LD_DWORD(tbl+8);	/* Volume start sector */
;		n_vol = LD_DWORD(tbl+12);	/* Volume size */
;	} else {
;		/* Create a partition in this function */
;		if (disk_ioctl(pdrv, GET_SECTOR_COUNT, &n_vol) != RES_OK || n_vol < 128)
;			return FR_DISK_ERR;
;		b_vol = (sfd) ? 0 : 63;		/* Volume start sector */
;		n_vol -= b_vol;				/* Volume size */
;	}
;
;	if (!au) {				/* AU auto selection */
;		vs = n_vol / (2000 / (SS(fs) / 512));
;		for (i = 0; vs < vst[i]; i++) ;
;		au = cst[i];
;	}
;	au /= SS(fs);		/* Number of sectors per cluster */
;	if (au == 0) au = 1;
;	if (au > 128) au = 128;
;
;	/* Pre-compute number of clusters and FAT sub-type */
;	n_clst = n_vol / au;
;	fmt = FS_FAT12;
;	if (n_clst >= MIN_FAT16) fmt = FS_FAT16;
;	if (n_clst >= MIN_FAT32) fmt = FS_FAT32;
;
;	/* Determine offset and size of FAT structure */
;	if (fmt == FS_FAT32) {
;		n_fat = ((n_clst * 4) + 8 + SS(fs) - 1) / SS(fs);
;		n_rsv = 32;
;		n_dir = 0;
;	} else {
;		n_fat = (fmt == FS_FAT12) ? (n_clst * 3 + 1) / 2 + 3 : (n_clst * 2) + 4;
;		n_fat = (n_fat + SS(fs) - 1) / SS(fs);
;		n_rsv = 1;
;		n_dir = (DWORD)N_ROOTDIR * SZ_DIR / SS(fs);
;	}
;	b_fat = b_vol + n_rsv;				/* FAT area start sector */
;	b_dir = b_fat + n_fat * N_FATS;		/* Directory area start sector */
;	b_data = b_dir + n_dir;				/* Data area start sector */
;	if (n_vol < b_data + au - b_vol) return FR_MKFS_ABORTED;	/* Too small volume */
;
;	/* Align data start sector to erase block boundary (for flash memory media) */
;	if (disk_ioctl(pdrv, GET_BLOCK_SIZE, &n) != RES_OK || !n || n > 32768) n = 1;
;	n = (b_data + n - 1) & ~(n - 1);	/* Next nearest erase block from current data start */
;	n = (n - b_data) / N_FATS;
;	if (fmt == FS_FAT32) {		/* FAT32: Move FAT offset */
;		n_rsv += n;
;		b_fat += n;
;	} else {					/* FAT12/16: Expand FAT size */
;		n_fat += n;
;	}
;
;	/* Determine number of clusters and final check of validity of the FAT sub-type */
;	n_clst = (n_vol - n_rsv - n_fat * N_FATS - n_dir) / au;
;	if (   (fmt == FS_FAT16 && n_clst < MIN_FAT16)
;		|| (fmt == FS_FAT32 && n_clst < MIN_FAT32))
;		return FR_MKFS_ABORTED;
;
;	/* Determine system ID in the partition table */
;	if (fmt == FS_FAT32) {
;		sys = 0x0C;		/* FAT32X */
;	} else {
;		if (fmt == FS_FAT12 && n_vol < 0x10000) {
;			sys = 0x01;	/* FAT12(<65536) */
;		} else {
;			sys = (n_vol < 0x10000) ? 0x04 : 0x06;	/* FAT16(<65536) : FAT12/16(>=65536) */
;		}
;	}
;
;	if (_MULTI_PARTITION && part) {
;		/* Update system ID in the partition table */
;		tbl = &fs->win[MBR_Table + (part - 1) * SZ_PTE];
;		tbl[4] = sys;
;		if (disk_write(pdrv, fs->win, 0, 1))	/* Write it to teh MBR */
;			return FR_DISK_ERR;
;		md = 0xF8;
;	} else {
;		if (sfd) {	/* No partition table (SFD) */
;			md = 0xF0;
;		} else {	/* Create partition table (FDISK) */
;			mem_set(fs->win, 0, SS(fs));
;			tbl = fs->win+MBR_Table;	/* Create partition table for single partition in the drive */
;			tbl[1] = 1;						/* Partition start head */
;			tbl[2] = 1;						/* Partition start sector */
;			tbl[3] = 0;						/* Partition start cylinder */
;			tbl[4] = sys;					/* System type */
;			tbl[5] = 254;					/* Partition end head */
;			n = (b_vol + n_vol) / 63 / 255;
;			tbl[6] = (BYTE)(n >> 2 | 63);	/* Partition end sector */
;			tbl[7] = (BYTE)n;				/* End cylinder */
;			ST_DWORD(tbl+8, 63);			/* Partition start in LBA */
;			ST_DWORD(tbl+12, n_vol);		/* Partition size in LBA */
;			ST_WORD(fs->win+BS_55AA, 0xAA55);	/* MBR signature */
;			if (disk_write(pdrv, fs->win, 0, 1))	/* Write it to the MBR */
;				return FR_DISK_ERR;
;			md = 0xF8;
;		}
;	}
;
;	/* Create BPB in the VBR */
;	tbl = fs->win;							/* Clear sector */
;	mem_set(tbl, 0, SS(fs));
;	mem_cpy(tbl, "\xEB\xFE\x90" "MSDOS5.0", 11);/* Boot jump code, OEM name */
;	i = SS(fs);								/* Sector size */
;	ST_WORD(tbl+BPB_BytsPerSec, i);
;	tbl[BPB_SecPerClus] = (BYTE)au;			/* Sectors per cluster */
;	ST_WORD(tbl+BPB_RsvdSecCnt, n_rsv);		/* Reserved sectors */
;	tbl[BPB_NumFATs] = N_FATS;				/* Number of FATs */
;	i = (fmt == FS_FAT32) ? 0 : N_ROOTDIR;	/* Number of root directory entries */
;	ST_WORD(tbl+BPB_RootEntCnt, i);
;	if (n_vol < 0x10000) {					/* Number of total sectors */
;		ST_WORD(tbl+BPB_TotSec16, n_vol);
;	} else {
;		ST_DWORD(tbl+BPB_TotSec32, n_vol);
;	}
;	tbl[BPB_Media] = md;					/* Media descriptor */
;	ST_WORD(tbl+BPB_SecPerTrk, 63);			/* Number of sectors per track */
;	ST_WORD(tbl+BPB_NumHeads, 255);			/* Number of heads */
;	ST_DWORD(tbl+BPB_HiddSec, b_vol);		/* Hidden sectors */
;	n = get_fattime();						/* Use current time as VSN */
;	if (fmt == FS_FAT32) {
;		ST_DWORD(tbl+BS_VolID32, n);		/* VSN */
;		ST_DWORD(tbl+BPB_FATSz32, n_fat);	/* Number of sectors per FAT */
;		ST_DWORD(tbl+BPB_RootClus, 2);		/* Root directory start cluster (2) */
;		ST_WORD(tbl+BPB_FSInfo, 1);			/* FSINFO record offset (VBR+1) */
;		ST_WORD(tbl+BPB_BkBootSec, 6);		/* Backup boot record offset (VBR+6) */
;		tbl[BS_DrvNum32] = 0x80;			/* Drive number */
;		tbl[BS_BootSig32] = 0x29;			/* Extended boot signature */
;		mem_cpy(tbl+BS_VolLab32, "NO NAME    " "FAT32   ", 19);	/* Volume label, FAT signature */
;	} else {
;		ST_DWORD(tbl+BS_VolID, n);			/* VSN */
;		ST_WORD(tbl+BPB_FATSz16, n_fat);	/* Number of sectors per FAT */
;		tbl[BS_DrvNum] = 0x80;				/* Drive number */
;		tbl[BS_BootSig] = 0x29;				/* Extended boot signature */
;		mem_cpy(tbl+BS_VolLab, "NO NAME    " "FAT     ", 19);	/* Volume label, FAT signature */
;	}
;	ST_WORD(tbl+BS_55AA, 0xAA55);			/* Signature (Offset is fixed here regardless of sector size) */
;	if (disk_write(pdrv, tbl, b_vol, 1))	/* Write it to the VBR sector */
;		return FR_DISK_ERR;
;	if (fmt == FS_FAT32)					/* Write backup VBR if needed (VBR+6) */
;		disk_write(pdrv, tbl, b_vol + 6, 1);
;
;	/* Initialize FAT area */
;	wsect = b_fat;
;	for (i = 0; i < N_FATS; i++) {		/* Initialize each FAT copy */
;		mem_set(tbl, 0, SS(fs));			/* 1st sector of the FAT  */
;		n = md;								/* Media descriptor byte */
;		if (fmt != FS_FAT32) {
;			n |= (fmt == FS_FAT12) ? 0x00FFFF00 : 0xFFFFFF00;
;			ST_DWORD(tbl+0, n);				/* Reserve cluster #0-1 (FAT12/16) */
;		} else {
;			n |= 0xFFFFFF00;
;			ST_DWORD(tbl+0, n);				/* Reserve cluster #0-1 (FAT32) */
;			ST_DWORD(tbl+4, 0xFFFFFFFF);
;			ST_DWORD(tbl+8, 0x0FFFFFFF);	/* Reserve cluster #2 for root directory */
;		}
;		if (disk_write(pdrv, tbl, wsect++, 1))
;			return FR_DISK_ERR;
;		mem_set(tbl, 0, SS(fs));			/* Fill following FAT entries with zero */
;		for (n = 1; n < n_fat; n++) {		/* This loop may take a time on FAT32 volume due to many single sector writes */
;			if (disk_write(pdrv, tbl, wsect++, 1))
;				return FR_DISK_ERR;
;		}
;	}
;
;	/* Initialize root directory */
;	i = (fmt == FS_FAT32) ? au : n_dir;
;	do {
;		if (disk_write(pdrv, tbl, wsect++, 1))
;			return FR_DISK_ERR;
;	} while (--i);
;
;#if _USE_ERASE	/* Erase data area if needed */
;	{
;		DWORD eb[2];
;
;		eb[0] = wsect; eb[1] = wsect + (n_clst - ((fmt == FS_FAT32) ? 1 : 0)) * au - 1;
;		disk_ioctl(pdrv, CTRL_ERASE_SECTOR, eb);
;	}
;#endif
;
;	/* Create FSINFO if needed */
;	if (fmt == FS_FAT32) {
;		ST_DWORD(tbl+FSI_LeadSig, 0x41615252);
;		ST_DWORD(tbl+FSI_StrucSig, 0x61417272);
;		ST_DWORD(tbl+FSI_Free_Count, n_clst - 1);	/* Number of free clusters */
;		ST_DWORD(tbl+FSI_Nxt_Free, 2);				/* Last allocated cluster# */
;		ST_WORD(tbl+BS_55AA, 0xAA55);
;		disk_write(pdrv, tbl, b_vol + 1, 1);	/* Write original (VBR+1) */
;		disk_write(pdrv, tbl, b_vol + 7, 1);	/* Write backup (VBR+7) */
;	}
;
;	return (disk_ioctl(pdrv, CTRL_SYNC, 0) == RES_OK) ? FR_OK : FR_DISK_ERR;
;}
;
;
;
;#if _MULTI_PARTITION
;/*-----------------------------------------------------------------------*/
;/* Divide Physical Drive                                                 */
;/*-----------------------------------------------------------------------*/
;
;FRESULT f_fdisk (
;	BYTE pdrv,			/* Physical drive number */
;	const DWORD szt[],	/* Pointer to the size table for each partitions */
;	void* work			/* Pointer to the working buffer */
;)
;{
;	UINT i, n, sz_cyl, tot_cyl, b_cyl, e_cyl, p_cyl;
;	BYTE s_hd, e_hd, *p, *buf = (BYTE*)work;
;	DSTATUS stat;
;	DWORD sz_disk, sz_part, s_part;
;
;
;	stat = disk_initialize(pdrv);
;	if (stat & STA_NOINIT) return FR_NOT_READY;
;	if (stat & STA_PROTECT) return FR_WRITE_PROTECTED;
;	if (disk_ioctl(pdrv, GET_SECTOR_COUNT, &sz_disk)) return FR_DISK_ERR;
;
;	/* Determine CHS in the table regardless of the drive geometry */
;	for (n = 16; n < 256 && sz_disk / n / 63 > 1024; n *= 2) ;
;	if (n == 256) n--;
;	e_hd = n - 1;
;	sz_cyl = 63 * n;
;	tot_cyl = sz_disk / sz_cyl;
;
;	/* Create partition table */
;	mem_set(buf, 0, _MAX_SS);
;	p = buf + MBR_Table; b_cyl = 0;
;	for (i = 0; i < 4; i++, p += SZ_PTE) {
;		p_cyl = (szt[i] <= 100U) ? (DWORD)tot_cyl * szt[i] / 100 : szt[i] / sz_cyl;
;		if (!p_cyl) continue;
;		s_part = (DWORD)sz_cyl * b_cyl;
;		sz_part = (DWORD)sz_cyl * p_cyl;
;		if (i == 0) {	/* Exclude first track of cylinder 0 */
;			s_hd = 1;
;			s_part += 63; sz_part -= 63;
;		} else {
;			s_hd = 0;
;		}
;		e_cyl = b_cyl + p_cyl - 1;
;		if (e_cyl >= tot_cyl) return FR_INVALID_PARAMETER;
;
;		/* Set partition table */
;		p[1] = s_hd;						/* Start head */
;		p[2] = (BYTE)((b_cyl >> 2) + 1);	/* Start sector */
;		p[3] = (BYTE)b_cyl;					/* Start cylinder */
;		p[4] = 0x06;						/* System type (temporary setting) */
;		p[5] = e_hd;						/* End head */
;		p[6] = (BYTE)((e_cyl >> 2) + 63);	/* End sector */
;		p[7] = (BYTE)e_cyl;					/* End cylinder */
;		ST_DWORD(p + 8, s_part);			/* Start sector in LBA */
;		ST_DWORD(p + 12, sz_part);			/* Partition size */
;
;		/* Next partition */
;		b_cyl += p_cyl;
;	}
;	ST_WORD(p, 0xAA55);
;
;	/* Write it to the MBR */
;	return (disk_write(pdrv, buf, 0, 1) || disk_ioctl(pdrv, CTRL_SYNC, 0)) ? FR_DISK_ERR : FR_OK;
;}
;
;
;#endif /* _MULTI_PARTITION */
;#endif /* _USE_MKFS && !_FS_READONLY */
;
;
;
;
;#if _USE_STRFUNC
;/*-----------------------------------------------------------------------*/
;/* Get a string from the file                                            */
;/*-----------------------------------------------------------------------*/
;
;TCHAR* f_gets (
;	TCHAR* buff,	/* Pointer to the string buffer to read */
;	int len,		/* Size of string buffer (characters) */
;	FIL* fp			/* Pointer to the file object */
;)
;{
;	int n = 0;
;	TCHAR c, *p = buff;
;	BYTE s[2];
;	UINT rc;
;
;
;	while (n < len - 1) {	/* Read characters until buffer gets filled */
;	*buff -> Y+14
;	len -> Y+12
;	*fp -> Y+10
;	n -> R16,R17
;	c -> R19
;	*p -> R20,R21
;	s -> Y+8
;	rc -> Y+6
;#if _LFN_UNICODE
;#if _STRF_ENCODE == 3		/* Read a character in UTF-8 */
;		f_read(fp, s, 1, &rc);
;		if (rc != 1) break;
;		c = s[0];
;		if (c >= 0x80) {
;			if (c < 0xC0) continue;	/* Skip stray trailer */
;			if (c < 0xE0) {			/* Two-byte sequence */
;				f_read(fp, s, 1, &rc);
;				if (rc != 1) break;
;				c = (c & 0x1F) << 6 | (s[0] & 0x3F);
;				if (c < 0x80) c = '?';
;			} else {
;				if (c < 0xF0) {		/* Three-byte sequence */
;					f_read(fp, s, 2, &rc);
;					if (rc != 2) break;
;					c = c << 12 | (s[0] & 0x3F) << 6 | (s[1] & 0x3F);
;					if (c < 0x800) c = '?';
;				} else {			/* Reject four-byte sequence */
;					c = '?';
;				}
;			}
;		}
;#elif _STRF_ENCODE == 2		/* Read a character in UTF-16BE */
;		f_read(fp, s, 2, &rc);
;		if (rc != 2) break;
;		c = s[1] + (s[0] << 8);
;#elif _STRF_ENCODE == 1		/* Read a character in UTF-16LE */
;		f_read(fp, s, 2, &rc);
;		if (rc != 2) break;
;		c = s[0] + (s[1] << 8);
;#else						/* Read a character in ANSI/OEM */
;		f_read(fp, s, 1, &rc);
;		if (rc != 1) break;
;		c = s[0];
;		if (IsDBCS1(c)) {
;			f_read(fp, s, 1, &rc);
;			if (rc != 1) break;
;			c = (c << 8) + s[0];
;		}
;		c = ff_convert(c, 1);	/* OEM -> Unicode */
;		if (!c) c = '?';
;#endif
;#else						/* Read a character without conversion */
;		f_read(fp, s, 1, &rc);
;		if (rc != 1) break;
;		c = s[0];
;#endif
;		if (_USE_STRFUNC == 2 && c == '\r') continue;	/* Strip '\r' */
;		*p++ = c;
;		n++;
;		if (c == '\n') break;		/* Break on EOL */
;	}
;	*p = 0;
;	return n ? buff : 0;			/* When no data read (eof or error), return with error. */
;}
;
;
;
;#if !_FS_READONLY
;#include <stdarg.h>
;/*-----------------------------------------------------------------------*/
;/* Put a character to the file                                           */
;/*-----------------------------------------------------------------------*/
;
;typedef struct {
;	FIL* fp;
;	int idx, nchr;
;	BYTE buf[64];
;} putbuff;
;
;
;static
;void putc_bfd (
;	putbuff* pb,
;	TCHAR c
;)
;{
_putc_bfd_G000:
; .FSTART _putc_bfd_G000
;	UINT bw;
;	int i;
;
;
;	if (_USE_STRFUNC == 2 && c == '\n')	 /* LF -> CRLF conversion */
	ST   -Y,R26
	CALL __SAVELOCR4
;	*pb -> Y+5
;	c -> Y+4
;	bw -> R16,R17
;	i -> R18,R19
	LDI  R30,LOW(1)
	CPI  R30,0
	BREQ _0x3E5
	LDD  R26,Y+4
	CPI  R26,LOW(0xA)
	BREQ _0x3E6
_0x3E5:
	RJMP _0x3E4
_0x3E6:
;		putc_bfd(pb, '\r');
	LDD  R30,Y+5
	LDD  R31,Y+5+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(13)
	RCALL _putc_bfd_G000
;
;	i = pb->idx;	/* Buffer write index (-1:error) */
_0x3E4:
	LDD  R26,Y+5
	LDD  R27,Y+5+1
	ADIW R26,2
	LD   R18,X+
	LD   R19,X
;	if (i < 0) return;
	TST  R19
	BRMI _0x20C000C
;
;#if _LFN_UNICODE
;#if _STRF_ENCODE == 3			/* Write a character in UTF-8 */
;	if (c < 0x80) {				/* 7-bit */
;		pb->buf[i++] = (BYTE)c;
;	} else {
;		if (c < 0x800) {		/* 11-bit */
;			pb->buf[i++] = (BYTE)(0xC0 | c >> 6);
;		} else {				/* 16-bit */
;			pb->buf[i++] = (BYTE)(0xE0 | c >> 12);
;			pb->buf[i++] = (BYTE)(0x80 | (c >> 6 & 0x3F));
;		}
;		pb->buf[i++] = (BYTE)(0x80 | (c & 0x3F));
;	}
;#elif _STRF_ENCODE == 2			/* Write a character in UTF-16BE */
;	pb->buf[i++] = (BYTE)(c >> 8);
;	pb->buf[i++] = (BYTE)c;
;#elif _STRF_ENCODE == 1			/* Write a character in UTF-16LE */
;	pb->buf[i++] = (BYTE)c;
;	pb->buf[i++] = (BYTE)(c >> 8);
;#else							/* Write a character in ANSI/OEM */
;	c = ff_convert(c, 0);	/* Unicode -> OEM */
;	if (!c) c = '?';
;	if (c >= 0x100)
;		pb->buf[i++] = (BYTE)(c >> 8);
;	pb->buf[i++] = (BYTE)c;
;#endif
;#else							/* Write a character without conversion */
;	pb->buf[i++] = (BYTE)c;
	LDD  R26,Y+5
	LDD  R27,Y+5+1
	ADIW R26,6
	MOVW R30,R18
	__ADDWRN 18,19,1
	ADD  R30,R26
	ADC  R31,R27
	LDD  R26,Y+4
	STD  Z+0,R26
;#endif
;
;	if (i >= (int)(sizeof pb->buf) - 3) {	/* Write buffered characters to the file */
	__CPWRN 18,19,61
	BRLT _0x3E8
;		f_write(pb->fp, pb->buf, (UINT)i, &bw);
	LDD  R26,Y+5
	LDD  R27,Y+5+1
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+7
	LDD  R31,Y+7+1
	ADIW R30,6
	ST   -Y,R31
	ST   -Y,R30
	ST   -Y,R19
	ST   -Y,R18
	IN   R26,SPL
	IN   R27,SPH
	SBIW R26,1
	PUSH R17
	PUSH R16
	CALL _f_write
	POP  R16
	POP  R17
;		i = (bw == (UINT)i) ? 0 : -1;
	__CPWRR 18,19,16,17
	BRNE _0x3E9
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	RJMP _0x3EA
_0x3E9:
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
_0x3EA:
	MOVW R18,R30
;	}
;	pb->idx = i;
_0x3E8:
	MOVW R30,R18
	__PUTW1SNS 5,2
;	pb->nchr++;
	LDD  R26,Y+5
	LDD  R27,Y+5+1
	ADIW R26,4
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
;}
_0x20C000C:
	CALL __LOADLOCR4
_0x20C000D:
	ADIW R28,7
	RET
; .FEND
;
;
;
;int f_putc (
;	TCHAR c,	/* A character to be output */
;	FIL* fp		/* Pointer to the file object */
;)
;{
;	putbuff pb;
;	UINT nw;
;
;
;	pb.fp = fp;			/* Initialize output buffer */
;	c -> Y+74
;	*fp -> Y+72
;	pb -> Y+2
;	nw -> R16,R17
;	pb.nchr = pb.idx = 0;
;
;	putc_bfd(&pb, c);	/* Put a character */
;
;	if (   pb.idx >= 0	/* Flush buffered characters to the file */
;		&& f_write(pb.fp, pb.buf, (UINT)pb.idx, &nw) == FR_OK
;		&& (UINT)pb.idx == nw) return pb.nchr;
;	return EOF;
;}
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Put a string to the file                                              */
;/*-----------------------------------------------------------------------*/
;
;int f_puts (
;	const TCHAR* str,	/* Pointer to the string to be output */
;	FIL* fp				/* Pointer to the file object */
;)
;{
_f_puts:
; .FSTART _f_puts
;	putbuff pb;
;	UINT nw;
;
;
;	pb.fp = fp;				/* Initialize output buffer */
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,63
	SBIW R28,7
	ST   -Y,R17
	ST   -Y,R16
;	*str -> Y+74
;	*fp -> Y+72
;	pb -> Y+2
;	nw -> R16,R17
	__GETW1SX 72
	STD  Y+2,R30
	STD  Y+2+1,R31
;	pb.nchr = pb.idx = 0;
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	STD  Y+4,R30
	STD  Y+4+1,R31
	STD  Y+6,R30
	STD  Y+6+1,R31
;
;	while (*str)			/* Put the string */
_0x3EF:
	__GETW2SX 74
	LD   R30,X
	CPI  R30,0
	BREQ _0x3F1
;		putc_bfd(&pb, *str++);
	MOVW R30,R28
	ADIW R30,2
	ST   -Y,R31
	ST   -Y,R30
	MOVW R26,R28
	SUBI R26,LOW(-(76))
	SBCI R27,HIGH(-(76))
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
	SBIW R30,1
	LD   R26,Z
	RCALL _putc_bfd_G000
	RJMP _0x3EF
_0x3F1:
;		&& f_write(pb.fp, pb.buf, (UINT)pb.idx, &nw) == FR_OK
;		&& (UINT)pb.idx == nw) return pb.nchr;
	LDD  R26,Y+5
	TST  R26
	BRMI _0x3F3
	LDD  R30,Y+2
	LDD  R31,Y+2+1
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,10
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ST   -Y,R31
	ST   -Y,R30
	IN   R26,SPL
	IN   R27,SPH
	SBIW R26,1
	PUSH R17
	PUSH R16
	CALL _f_write
	POP  R16
	POP  R17
	CPI  R30,0
	BRNE _0x3F3
	LDD  R26,Y+4
	LDD  R27,Y+4+1
	CP   R16,R26
	CPC  R17,R27
	BREQ _0x3F4
_0x3F3:
	RJMP _0x3F2
_0x3F4:
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	RJMP _0x20C000B
;	return EOF;
_0x3F2:
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
_0x20C000B:
	LDD  R17,Y+1
	LDD  R16,Y+0
	ADIW R28,63
	ADIW R28,13
	RET
;}
; .FEND
;
;
;
;
;/*-----------------------------------------------------------------------*/
;/* Put a formatted string to the file                                    */
;/*-----------------------------------------------------------------------*/
;
;int f_printf (
;	FIL* fp,			/* Pointer to the file object */
;	const TCHAR* fmt,	/* Pointer to the format string */
;	...					/* Optional arguments... */
;)
;{
;	va_list arp;
;	BYTE f, r;
;	UINT nw, i, j, w;
;	DWORD v;
;	TCHAR c, d, s[16], *p;
;	putbuff pb;
;
;
;	pb.fp = fp;				/* Initialize output buffer */
;	*fp -> Y+108
;	*fmt -> Y+106
;	*arp -> R16,R17
;	f -> R19
;	r -> R18
;	nw -> R20,R21
;	i -> Y+104
;	j -> Y+102
;	w -> Y+100
;	v -> Y+96
;	c -> Y+95
;	d -> Y+94
;	s -> Y+78
;	*p -> Y+76
;	pb -> Y+6
;	pb.nchr = pb.idx = 0;
;
;	va_start(arp, fmt);
;
;	for (;;) {
;		c = *fmt++;
;		if (c == 0) break;			/* End of string */
;		if (c != '%') {				/* Non escape character */
;			putc_bfd(&pb, c);
;			continue;
;		}
;		w = f = 0;
;		c = *fmt++;
;		if (c == '0') {				/* Flag: '0' padding */
;			f = 1; c = *fmt++;
;		} else {
;			if (c == '-') {			/* Flag: left justified */
;				f = 2; c = *fmt++;
;			}
;		}
;		while (IsDigit(c)) {		/* Precision */
;			w = w * 10 + c - '0';
;			c = *fmt++;
;		}
;		if (c == 'l' || c == 'L') {	/* Prefix: Size is long int */
;			f |= 4; c = *fmt++;
;		}
;		if (!c) break;
;		d = c;
;		if (IsLower(d)) d -= 0x20;
;		switch (d) {				/* Type is... */
;		case 'S' :					/* String */
;			p = va_arg(arp, TCHAR*);
;			for (j = 0; p[j]; j++) ;
;			if (!(f & 2)) {
;				while (j++ < w) putc_bfd(&pb, ' ');
;			while (*p) putc_bfd(&pb, *p++);
;		case 'C' :					/* Character */
;			putc_bfd(&pb, (TCHAR)va_arg(arp, int)); continue;
;		case 'B' :					/* Binary */
;			r = 2; break;
;		case 'O' :					/* Octal */
;			r = 8; break;
;		case 'D' :					/* Signed decimal */
;		case 'U' :					/* Unsigned decimal */
;			r = 10; break;
;		case 'X' :					/* Hexdecimal */
;			r = 16; break;
;		default:					/* Unknown type (pass-through) */
;			putc_bfd(&pb, c); continue;
;		}
;
;		/* Get an argument and put it in numeral */
;		v = (f & 4) ? (DWORD)va_arg(arp, long) : ((d == 'D') ? (DWORD)(long)va_arg(arp, int) : (DWORD)va_arg(arp, unsigned int ...
;		if (d == 'D' && (v & 0x80000000)) {
;			v = 0 - v;
;			f |= 8;
;		}
;		i = 0;
;		do {
;			d = (TCHAR)(v % r); v /= r;
;			if (d > 9) d += (c == 'x') ? 0x27 : 0x07;
;			s[i++] = d + '0';
;		} while (v && i < sizeof s / sizeof s[0]);
;		if (f & 8) s[i++] = '-';
;		j = i; d = (f & 1) ? '0' : ' ';
;		while (!(f & 2) && j++ < w) putc_bfd(&pb, d);
;		while (j++ < w) putc_bfd(&pb, d);
;
;	va_end(arp);
;
;	if (   pb.idx >= 0		/* Flush buffered characters to the file */
;		&& f_write(pb.fp, pb.buf, (UINT)pb.idx, &nw) == FR_OK
;		&& (UINT)pb.idx == nw) return pb.nchr;
;	return EOF;
;}
;
;#endif /* !_FS_READONLY */
;#endif /* _USE_STRFUNC */
;#include "menu.h"
;//#include "dataflash/df.c"
;
;#define DS1307_ADR    104
;
;#define MAX_FN_STR    320
;
;#define CS_KEYS_SET  PORTC.0 = 1;
;#define CS_KEYS_RESET  PORTC.0 = 0;
;#define CLK_KEYS_SET  PORTC.2 = 1;
;#define CLK_KEYS_RESET  PORTC.2 = 0;
;#define KEYS_INIT   DDRC.0 = 1; DDRC.2 = 1; DDRD.7 = 0;
;
;///KEYBOARD KEYS
;#define FORWARD  247
;#define BACKWARD 251
;#define PAUSE    253
;#define PLAY     254
;
;#define PWM_PORT PORTB
;#define PWM_DIR DDRB
;#define PWM_PIN 3
;
;#define BUF_SIZE 256
;#define HALF_BUF ((BUF_SIZE)/2)
;
;struct CFileInfo
;{
;unsigned char * szFileName;
;int nFileDate;
;int nFileSize;
;}g_FileInfo[32];
;
; DWORD get_fattime ()
;{
_get_fattime:
; .FSTART _get_fattime
;    /* Pack date and time into a DWORD variable */
;   return    ((DWORD)(/*rtc.year*/2010 - 1980) << 25)
;         | ((DWORD)/*rtc.month*/10 << 21)
;         | ((DWORD)/*rtc.mday*/7 << 16)
;          | ((DWORD)/*rtc.hour*/1 << 11)
;          | ((DWORD)/*rtc.min*/26 << 5)
;          | ((DWORD)/*rtc.sec*/6 >> 1);
	__GETD1N 0x3D470B43
	RET
;}
; .FEND
;
;//******************************************************************************
;// Функции браузера плеера
;//******************************************************************************
;FIL file;
;FIL simple_file;
;    BYTE bIsfOpened = 0;
;    unsigned char fn16_str[13];    // ТОЛЬКО ДЛЯ ФОРМАТА 8.3 !!!
;    unsigned char rootpath[32];
;    unsigned char tempstr[32];
;    unsigned char audiobuf[64];
;    int select_file_index = 0;
;    int select_file_option_index = 0;
;    unsigned int nNofDirFiles = 0;
;    int nKey;
;    int nAudioBufferIndex = 0;
;    BYTE bSelect = 0;
;    BYTE bFileInfoWindow = 0;
;    BYTE bFormatAlert = 0;
;    BYTE bTextReader = 0;
;    BYTE bMusicPlayer = 0;
;    BYTE bImageViever = 0;
;    int scroll_index = 0;
;    UINT state = 0;
;    BYTE bMusicFOpened = 0;
;
;enum FILE_OPTION_MENU {OPEN=0,DELETE,INFO}fOption;
;
;BYTE GetKeysStatus()      //функция чтения данных   74HC165
;{
_GetKeysStatus:
; .FSTART _GetKeysStatus
;  unsigned int i=0;
;  BYTE keydata;
;
;     CS_KEYS_RESET;         //защёлкиваем входные данные
	CALL __SAVELOCR4
;	i -> R16,R17
;	keydata -> R19
	__GETWRN 16,17,0
	CBI  0x8,0
;     //delay_us(1);
;     CS_KEYS_SET;
	SBI  0x8,0
;      CLK_KEYS_SET;
	SBI  0x8,2
;
;   for( i=0; i<7; i++ )
	__GETWRN 16,17,0
_0x44F:
	__CPWRN 16,17,7
	BRSH _0x450
;   {
;     keydata |= PIND.7;
	LDI  R30,0
	SBIC 0x9,7
	LDI  R30,1
	OR   R19,R30
;     keydata <<= 1;
	LSL  R19
;      CLK_KEYS_RESET;            //сдвигаем данные
	CBI  0x8,2
;      //delay_us(1);
;      CLK_KEYS_SET;
	SBI  0x8,2
;   }
	__ADDWRN 16,17,1
	RJMP _0x44F
_0x450:
;  keydata |= PIND.7;
	LDI  R30,0
	SBIC 0x9,7
	LDI  R30,1
	OR   R19,R30
;   return keydata;
	MOV  R30,R19
	CALL __LOADLOCR4
	ADIW R28,4
	RET
;}
; .FEND
;
;ISR(TIM0_OVF)
;{
_TIM0_OVF_func:
; .FSTART _TIM0_OVF_func
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
;  OCR0A = audiobuf[nAudioBufferIndex];
	LDI  R26,LOW(_audiobuf)
	LDI  R27,HIGH(_audiobuf)
	ADD  R26,R13
	ADC  R27,R14
	LD   R30,X
	OUT  0x27,R30
;  nAudioBufferIndex++;
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	__ADDWRR 13,14,30,31
;}
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	RETI
; .FEND
;
;ISR(EXT_INT0)
;{
_EXT_INT0_func:
; .FSTART _EXT_INT0_func
	ST   -Y,R0
	ST   -Y,R1
	ST   -Y,R15
	ST   -Y,R22
	ST   -Y,R23
	ST   -Y,R24
	ST   -Y,R25
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
;delay_ms(100);
	LDI  R26,LOW(100)
	LDI  R27,0
	CALL _delay_ms
;nKey = GetKeysStatus();
	RCALL _GetKeysStatus
	MOV  R11,R30
	CLR  R12
;}
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	LD   R25,Y+
	LD   R24,Y+
	LD   R23,Y+
	LD   R22,Y+
	LD   R15,Y+
	LD   R1,Y+
	LD   R0,Y+
	RETI
; .FEND
;
;
;FRESULT browser_scan_files (char* path) // Scan Files in the root directory
;{
_browser_scan_files:
; .FSTART _browser_scan_files
;    FRESULT res;
;    FILINFO fno;
;    DIR dir;
;    unsigned char * szFileMenuList[3] = {"Open","Delete","Info"};
;    int pos_index = 0;
;    int i = 0,nf_index = 0;
;    int j = 0;
;    int tempselindex = 0;
;    nlcd_Clear(WHITE);
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,56
	LDI  R24,12
	LDI  R26,LOW(0)
	LDI  R27,HIGH(0)
	LDI  R30,LOW(_0x456*2)
	LDI  R31,HIGH(_0x456*2)
	CALL __INITLOCB
	CALL __SAVELOCR6
;	*path -> Y+62
;	res -> R17
;	fno -> Y+40
;	dir -> Y+18
;	szFileMenuList -> Y+12
;	pos_index -> R18,R19
;	i -> R20,R21
;	nf_index -> Y+10
;	j -> Y+8
;	tempselindex -> Y+6
	__GETWRN 18,19,0
	__GETWRN 20,21,0
	LDI  R26,LOW(4095)
	LDI  R27,HIGH(4095)
	CALL _nlcd_Clear
;    if(!bIsfOpened)
	TST  R4
	BRNE _0x457
;    {
;    res = f_opendir(&dir, path);
	MOVW R30,R28
	ADIW R30,18
	ST   -Y,R31
	ST   -Y,R30
	__GETW2SX 64
	RCALL _f_opendir
	MOV  R17,R30
;    }
;    if (res == FR_OK)
_0x457:
	CPI  R17,0
	BREQ PC+2
	RJMP _0x458
;    {
;    if(!bIsfOpened)
	TST  R4
	BRNE _0x459
;    {
;    f_open(&file, "0:LOG/SPISOKF.txt", FA_OPEN_ALWAYS  | FA_WRITE);
	LDI  R30,LOW(_file)
	LDI  R31,HIGH(_file)
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1MN _0x455,17
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(18)
	CALL _f_open
;    f_lseek(&file,0);
	LDI  R30,LOW(_file)
	LDI  R31,HIGH(_file)
	ST   -Y,R31
	ST   -Y,R30
	__GETD2N 0x0
	RCALL _f_lseek
;    f_puts("Это список текущих файлов, просто лог, менять и удалять смысла нет\n\n",&file);
	__POINTW1MN _0x455,35
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(_file)
	LDI  R27,HIGH(_file)
	RCALL _f_puts
;    select_file_index = 0;
	CLR  R5
	CLR  R6
;    }
;       for (nf_index = 0;;nf_index++) {
_0x459:
	LDI  R30,LOW(0)
	STD  Y+10,R30
	STD  Y+10+1,R30
_0x45B:
;            if(!bIsfOpened)
	TST  R4
	BREQ PC+2
	RJMP _0x45D
;            {
;            res = f_readdir(&dir, &fno);
	MOVW R30,R28
	ADIW R30,18
	ST   -Y,R31
	ST   -Y,R30
	MOVW R26,R28
	ADIW R26,42
	RCALL _f_readdir
	MOV  R17,R30
;            if (res != FR_OK || fno.fname[0] == 0) break;
	CPI  R17,0
	BRNE _0x45F
	LDD  R26,Y+49
	CPI  R26,LOW(0x0)
	BRNE _0x45E
_0x45F:
	RJMP _0x45C
;            g_FileInfo[nf_index].szFileName = (unsigned char*)malloc(strlen(fno.fname)+1);
_0x45E:
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	LDI  R30,LOW(6)
	CALL __MULB1W2U
	SUBI R30,LOW(-_g_FileInfo)
	SBCI R31,HIGH(-_g_FileInfo)
	PUSH R31
	PUSH R30
	MOVW R26,R28
	ADIW R26,49
	CALL _strlen
	ADIW R30,1
	MOVW R26,R30
	CALL _malloc
	POP  R26
	POP  R27
	ST   X+,R30
	ST   X,R31
;            sprintf(g_FileInfo[nf_index].szFileName,"%s", fno.fname);
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	LDI  R30,LOW(6)
	CALL __MULB1W2U
	SUBI R30,LOW(-_g_FileInfo)
	SBCI R31,HIGH(-_g_FileInfo)
	MOVW R26,R30
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1FN _0x0,129
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,53
	CLR  R22
	CLR  R23
	CALL __PUTPARD1
	LDI  R24,4
	CALL _sprintf
	ADIW R28,8
;            g_FileInfo[nf_index].nFileSize = fno.fsize;
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	LDI  R30,LOW(6)
	CALL __MULB1W2U
	__ADDW1MN _g_FileInfo,4
	LDD  R26,Y+40
	LDD  R27,Y+40+1
	STD  Z+0,R26
	STD  Z+1,R27
;            g_FileInfo[nf_index].nFileDate = fno.fdate;
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	LDI  R30,LOW(6)
	CALL __MULB1W2U
	__ADDW1MN _g_FileInfo,2
	LDD  R26,Y+44
	LDD  R27,Y+44+1
	STD  Z+0,R26
	STD  Z+1,R27
;            strcpy(fn16_str,fno.fname);
	LDI  R30,LOW(_fn16_str)
	LDI  R31,HIGH(_fn16_str)
	ST   -Y,R31
	ST   -Y,R30
	MOVW R26,R28
	ADIW R26,51
	CALL _strcpy
;            strcat(fn16_str,"\n");
	LDI  R30,LOW(_fn16_str)
	LDI  R31,HIGH(_fn16_str)
	ST   -Y,R31
	ST   -Y,R30
	__POINTW2MN _0x455,104
	CALL _strcat
;            f_puts(fn16_str,&file);
	LDI  R30,LOW(_fn16_str)
	LDI  R31,HIGH(_fn16_str)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(_file)
	LDI  R27,HIGH(_file)
	RCALL _f_puts
;            nNofDirFiles = nf_index+1;
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	ADIW R30,1
	__PUTW1R 9,10
;            }
;            if(g_FileInfo[nf_index].szFileName[0] == 0)break;
_0x45D:
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	LDI  R30,LOW(6)
	CALL __MULB1W2U
	SUBI R30,LOW(-_g_FileInfo)
	SBCI R31,HIGH(-_g_FileInfo)
	MOVW R26,R30
	CALL __GETW1P
	LD   R30,Z
	CPI  R30,0
	BRNE _0x461
	RJMP _0x45C
;            if((select_file_index+1 > nNofDirFiles) && (select_file_index+1 > 0))select_file_index = 0;
_0x461:
	__GETW2R 5,6
	ADIW R26,1
	CP   R9,R26
	CPC  R10,R27
	BRSH _0x463
	__GETW2R 5,6
	ADIW R26,1
	CALL __CPW02
	BRLT _0x464
_0x463:
	RJMP _0x462
_0x464:
	CLR  R5
	CLR  R6
;            if(select_file_index+1 <= 0)select_file_index = nNofDirFiles-1;
_0x462:
	__GETW2R 5,6
	ADIW R26,1
	CALL __CPW02
	BRLT _0x465
	__GETW1R 9,10
	SBIW R30,1
	__PUTW1R 5,6
;                if(nf_index == select_file_index)
_0x465:
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	CP   R5,R26
	CPC  R6,R27
	BRNE _0x466
;                {
;                nlcd_Box(0,29+i,132,34+i,1,GREEN,0);
	LDI  R30,LOW(0)
	ST   -Y,R30
	MOV  R30,R20
	SUBI R30,-LOW(29)
	ST   -Y,R30
	LDI  R30,LOW(132)
	ST   -Y,R30
	MOV  R30,R20
	SUBI R30,-LOW(34)
	ST   -Y,R30
	LDI  R30,LOW(1)
	ST   -Y,R30
	LDI  R30,LOW(240)
	LDI  R31,HIGH(240)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	CALL _nlcd_Box
;                nlcd_String(g_FileInfo[nf_index].szFileName,30+i,10,WHITE,GREEN);
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	LDI  R30,LOW(6)
	CALL __MULB1W2U
	SUBI R30,LOW(-_g_FileInfo)
	SBCI R31,HIGH(-_g_FileInfo)
	MOVW R26,R30
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	MOV  R30,R20
	SUBI R30,-LOW(30)
	ST   -Y,R30
	LDI  R30,LOW(10)
	ST   -Y,R30
	LDI  R30,LOW(4095)
	LDI  R31,HIGH(4095)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(240)
	LDI  R27,0
	CALL _nlcd_String
;                pos_index = i;
	MOVW R18,R20
;                }
;                else
	RJMP _0x467
_0x466:
;                {
;                nlcd_String(g_FileInfo[nf_index].szFileName,30+i,10,BLACK,WHITE);
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	LDI  R30,LOW(6)
	CALL __MULB1W2U
	SUBI R30,LOW(-_g_FileInfo)
	SBCI R31,HIGH(-_g_FileInfo)
	MOVW R26,R30
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	MOV  R30,R20
	SUBI R30,-LOW(30)
	ST   -Y,R30
	LDI  R30,LOW(10)
	ST   -Y,R30
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(4095)
	LDI  R27,HIGH(4095)
	CALL _nlcd_String
;                }
_0x467:
;            i+=10;
	__ADDWRN 20,21,10
;        }
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	ADIW R30,1
	STD  Y+10,R30
	STD  Y+10+1,R31
	RJMP _0x45B
_0x45C:
;        if(bSelect)
	TST  R3
	BRNE PC+2
	RJMP _0x468
;        {
;        nlcd_Box(10,32+pos_index,58,90+pos_index,2,WHITE,GREEN);
	LDI  R30,LOW(10)
	ST   -Y,R30
	MOV  R30,R18
	SUBI R30,-LOW(32)
	ST   -Y,R30
	LDI  R30,LOW(58)
	ST   -Y,R30
	MOV  R30,R18
	SUBI R30,-LOW(90)
	ST   -Y,R30
	LDI  R30,LOW(2)
	ST   -Y,R30
	LDI  R30,LOW(4095)
	LDI  R31,HIGH(4095)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(240)
	LDI  R27,0
	CALL _nlcd_Box
;        for(i = 0;i<3;i++)
	__GETWRN 20,21,0
_0x46A:
	__CPWRN 20,21,3
	BRLT PC+2
	RJMP _0x46B
;        {
;        if(select_file_option_index > 2) select_file_option_index = 0;
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	CP   R30,R7
	CPC  R31,R8
	BRGE _0x46C
	CLR  R7
	CLR  R8
;        if(select_file_option_index < 0) select_file_option_index = 2;
_0x46C:
	CLR  R0
	CP   R7,R0
	CPC  R8,R0
	BRGE _0x46D
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	__PUTW1R 7,8
;        if(i == select_file_option_index)
_0x46D:
	__CPWRR 7,8,20,21
	BRNE _0x46E
;        {
;        nlcd_String(szFileMenuList[i],36+j+pos_index,25,WHITE,GREEN);
	MOVW R30,R20
	MOVW R26,R28
	ADIW R26,12
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+10
	SUBI R30,-LOW(36)
	ADD  R30,R18
	ST   -Y,R30
	LDI  R30,LOW(25)
	ST   -Y,R30
	LDI  R30,LOW(4095)
	LDI  R31,HIGH(4095)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(240)
	LDI  R27,0
	RJMP _0x4E7
;        }
;        else
_0x46E:
;        {
;        nlcd_String(szFileMenuList[i],36+j+pos_index,25,BLACK,WHITE);
	MOVW R30,R20
	MOVW R26,R28
	ADIW R26,12
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+10
	SUBI R30,-LOW(36)
	ADD  R30,R18
	ST   -Y,R30
	LDI  R30,LOW(25)
	ST   -Y,R30
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(4095)
	LDI  R27,HIGH(4095)
_0x4E7:
	CALL _nlcd_String
;        }
;        j+=10;
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ADIW R30,10
	STD  Y+8,R30
	STD  Y+8+1,R31
;        }
	__ADDWRN 20,21,1
	RJMP _0x46A
_0x46B:
;        }
;        if(!bIsfOpened)
_0x468:
	TST  R4
	BRNE _0x470
;        f_close(&file);
	LDI  R26,LOW(_file)
	LDI  R27,HIGH(_file)
	CALL _f_close
;    }
_0x470:
;    if((path[0] == '') || (path[0] == ' '))
_0x458:
	LDD  R26,Y+62
	LDD  R27,Y+62+1
	LD   R26,X
	CPI  R26,LOW(0x0)
	BREQ _0x472
	LDD  R26,Y+62
	LDD  R27,Y+62+1
	LD   R26,X
	CPI  R26,LOW(0x20)
	BRNE _0x471
_0x472:
;    {
;    nlcd_String("Root",18,5,BLACK,WHITE);
	__POINTW1MN _0x455,106
	RJMP _0x4E8
;    }
;    else
_0x471:
;    {
;    sprintf(&rootpath[0],"Root/%s", &path[0]);
	LDI  R30,LOW(_rootpath)
	LDI  R31,HIGH(_rootpath)
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1FN _0x0,137
	ST   -Y,R31
	ST   -Y,R30
	__GETW1SX 66
	CLR  R22
	CLR  R23
	CALL __PUTPARD1
	LDI  R24,4
	CALL _sprintf
	ADIW R28,8
;    nlcd_String(&rootpath[0],18,5,BLACK,WHITE);
	LDI  R30,LOW(_rootpath)
	LDI  R31,HIGH(_rootpath)
_0x4E8:
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(18)
	ST   -Y,R30
	LDI  R30,LOW(5)
	ST   -Y,R30
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(4095)
	LDI  R27,HIGH(4095)
	CALL _nlcd_String
;    }
;    return res;
	MOV  R30,R17
	CALL __LOADLOCR6
	ADIW R28,63
	ADIW R28,1
	RET
;}
; .FEND

	.DSEG
_0x455:
	.BYTE 0x6F
;
;
;void fileinfo_window(int nFileInfoIndex)
;{

	.CSEG
_fileinfo_window:
; .FSTART _fileinfo_window
;unsigned char szfinfo[10];
;nlcd_Clear(WHITE);
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,10
;	nFileInfoIndex -> Y+10
;	szfinfo -> Y+0
	LDI  R26,LOW(4095)
	LDI  R27,HIGH(4095)
	CALL _nlcd_Clear
;nlcd_String("***File Info***",5,5,RED,WHITE);
	__POINTW1MN _0x475,0
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(5)
	ST   -Y,R30
	ST   -Y,R30
	LDI  R30,LOW(3840)
	LDI  R31,HIGH(3840)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(4095)
	LDI  R27,HIGH(4095)
	CALL _nlcd_String
;nlcd_String(g_FileInfo[nFileInfoIndex].szFileName,15,10,BLUE,WHITE);
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	LDI  R30,LOW(6)
	CALL __MULB1W2U
	SUBI R30,LOW(-_g_FileInfo)
	SBCI R31,HIGH(-_g_FileInfo)
	MOVW R26,R30
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(15)
	ST   -Y,R30
	LDI  R30,LOW(10)
	ST   -Y,R30
	LDI  R30,LOW(15)
	LDI  R31,HIGH(15)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(4095)
	LDI  R27,HIGH(4095)
	CALL _nlcd_String
;nlcd_String("File Size",25,20,GREEN,WHITE);
	__POINTW1MN _0x475,16
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(25)
	ST   -Y,R30
	LDI  R30,LOW(20)
	ST   -Y,R30
	LDI  R30,LOW(240)
	LDI  R31,HIGH(240)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(4095)
	LDI  R27,HIGH(4095)
	CALL _nlcd_String
;sprintf(&szfinfo[0],"%i B", g_FileInfo[nFileInfoIndex].nFileSize);
	MOVW R30,R28
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1FN _0x0,171
	ST   -Y,R31
	ST   -Y,R30
	LDD  R26,Y+14
	LDD  R27,Y+14+1
	LDI  R30,LOW(6)
	CALL __MULB1W2U
	__ADDW1MN _g_FileInfo,4
	MOVW R26,R30
	CALL __GETW1P
	CALL __CWD1
	CALL __PUTPARD1
	LDI  R24,4
	CALL _sprintf
	ADIW R28,8
;nlcd_String(szfinfo,35,20,BLACK,WHITE);
	MOVW R30,R28
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(35)
	ST   -Y,R30
	LDI  R30,LOW(20)
	ST   -Y,R30
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(4095)
	LDI  R27,HIGH(4095)
	CALL _nlcd_String
;nlcd_String("Changing Date",45,20,GREEN,WHITE);
	__POINTW1MN _0x475,26
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(45)
	ST   -Y,R30
	LDI  R30,LOW(20)
	ST   -Y,R30
	LDI  R30,LOW(240)
	LDI  R31,HIGH(240)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(4095)
	LDI  R27,HIGH(4095)
	CALL _nlcd_String
;sprintf(&szfinfo[0],"%i", g_FileInfo[nFileInfoIndex].nFileDate);
	MOVW R30,R28
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1FN _0x0,190
	ST   -Y,R31
	ST   -Y,R30
	LDD  R26,Y+14
	LDD  R27,Y+14+1
	LDI  R30,LOW(6)
	CALL __MULB1W2U
	__ADDW1MN _g_FileInfo,2
	MOVW R26,R30
	CALL __GETW1P
	CALL __CWD1
	CALL __PUTPARD1
	LDI  R24,4
	CALL _sprintf
	ADIW R28,8
;nlcd_String(szfinfo,55,20,BLACK,WHITE);
	MOVW R30,R28
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(55)
	ST   -Y,R30
	LDI  R30,LOW(20)
	ST   -Y,R30
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(4095)
	LDI  R27,HIGH(4095)
	CALL _nlcd_String
;}
	ADIW R28,12
	RET
; .FEND

	.DSEG
_0x475:
	.BYTE 0x28
;
;unsigned char error[10];
;void browser_init()
;{

	.CSEG
_browser_init:
; .FSTART _browser_init
;FRESULT res;
;FATFS fs;
;UINT br, bw,i;
;if(!f_mount(&fs,"0",1))
	SBIW R28,48
	SUBI R29,2
	CALL __SAVELOCR6
;	res -> R17
;	fs -> Y+8
;	br -> R18,R19
;	bw -> R20,R21
;	i -> Y+6
	MOVW R30,R28
	ADIW R30,8
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1MN _0x477,0
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(1)
	CALL _f_mount
	CPI  R30,0
	BREQ PC+2
	RJMP _0x476
;{
;//PORTD.0 = 1;
;if(bFileInfoWindow && !bTextReader && !bMusicPlayer)
	LDS  R30,_bFileInfoWindow
	CPI  R30,0
	BREQ _0x479
	LDS  R30,_bTextReader
	CPI  R30,0
	BRNE _0x479
	LDS  R30,_bMusicPlayer
	CPI  R30,0
	BREQ _0x47A
_0x479:
	RJMP _0x478
_0x47A:
;{
;fileinfo_window(select_file_index);
	__GETW2R 5,6
	RCALL _fileinfo_window
;}
;if(!bFileInfoWindow && !bTextReader && bMusicPlayer)
_0x478:
	LDS  R30,_bFileInfoWindow
	CPI  R30,0
	BRNE _0x47C
	LDS  R30,_bTextReader
	CPI  R30,0
	BRNE _0x47C
	LDS  R30,_bMusicPlayer
	CPI  R30,0
	BRNE _0x47D
_0x47C:
	RJMP _0x47B
_0x47D:
;{
;music_player_init(select_file_index);
	__GETW2R 5,6
	RCALL _music_player_init
;}
;if(!bFileInfoWindow && bTextReader)
_0x47B:
	LDS  R30,_bFileInfoWindow
	CPI  R30,0
	BRNE _0x47F
	LDS  R30,_bTextReader
	CPI  R30,0
	BRNE _0x480
_0x47F:
	RJMP _0x47E
_0x480:
;{
;text_reader_init(select_file_index);
	__GETW2R 5,6
	RCALL _text_reader_init
;}
;else
	RJMP _0x481
_0x47E:
;{
;bMusicFOpened = 0;
	LDI  R30,LOW(0)
	STS  _bMusicFOpened,R30
;browser_scan_files("");
	__POINTW2MN _0x477,2
	RCALL _browser_scan_files
;}
_0x481:
;switch(nKey)
	__GETW1R 11,12
;{
;case FORWARD:
	CPI  R30,LOW(0xF7)
	LDI  R26,HIGH(0xF7)
	CPC  R31,R26
	BRNE _0x485
;if(bTextReader)
	LDS  R30,_bTextReader
	CPI  R30,0
	BREQ _0x486
;scroll_index+=16;
	LDS  R30,_scroll_index
	LDS  R31,_scroll_index+1
	ADIW R30,16
	STS  _scroll_index,R30
	STS  _scroll_index+1,R31
;if(bSelect)
_0x486:
	TST  R3
	BREQ _0x487
;select_file_option_index++;
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	__ADDWRR 7,8,30,31
;else
	RJMP _0x488
_0x487:
;select_file_index++;
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	__ADDWRR 5,6,30,31
;break;
_0x488:
	RJMP _0x484
;case BACKWARD:
_0x485:
	CPI  R30,LOW(0xFB)
	LDI  R26,HIGH(0xFB)
	CPC  R31,R26
	BRNE _0x489
;if(bTextReader)
	LDS  R30,_bTextReader
	CPI  R30,0
	BREQ _0x48A
;scroll_index-=16;
	LDS  R30,_scroll_index
	LDS  R31,_scroll_index+1
	SBIW R30,16
	STS  _scroll_index,R30
	STS  _scroll_index+1,R31
;if(bSelect)
_0x48A:
	TST  R3
	BREQ _0x48B
;select_file_option_index--;
	__GETW1R 7,8
	SBIW R30,1
	__PUTW1R 7,8
;else
	RJMP _0x48C
_0x48B:
;select_file_index--;
	__GETW1R 5,6
	SBIW R30,1
	__PUTW1R 5,6
;break;
_0x48C:
	RJMP _0x484
;case PAUSE:
_0x489:
	CPI  R30,LOW(0xFD)
	LDI  R26,HIGH(0xFD)
	CPC  R31,R26
	BRNE _0x48D
;bTextReader = 0;
	LDI  R30,LOW(0)
	STS  _bTextReader,R30
;bMusicPlayer = 0;
	STS  _bMusicPlayer,R30
;bSelect = 0;
	CLR  R3
;bFileInfoWindow = 0;
	STS  _bFileInfoWindow,R30
;break;
	RJMP _0x484
;case PLAY:
_0x48D:
	CPI  R30,LOW(0xFE)
	LDI  R26,HIGH(0xFE)
	CPC  R31,R26
	BREQ PC+2
	RJMP _0x484
;if(bSelect)
	TST  R3
	BRNE PC+2
	RJMP _0x48F
;{
;switch(select_file_option_index)
	__GETW1R 7,8
;{
;case OPEN:
	SBIW R30,0
	BREQ PC+2
	RJMP _0x493
;if(!strcmp(&g_FileInfo[select_file_index].szFileName[8],".TXT") || !strcmp(&g_FileInfo[select_file_index].szFileName[8], ...
	__GETW1R 5,6
	LDI  R26,LOW(6)
	LDI  R27,HIGH(6)
	CALL __MULW12U
	SUBI R30,LOW(-_g_FileInfo)
	SBCI R31,HIGH(-_g_FileInfo)
	MOVW R26,R30
	CALL __GETW1P
	ADIW R30,8
	ST   -Y,R31
	ST   -Y,R30
	__POINTW2MN _0x477,3
	CALL _strcmp
	CPI  R30,0
	BREQ _0x495
	__GETW1R 5,6
	LDI  R26,LOW(6)
	LDI  R27,HIGH(6)
	CALL __MULW12U
	SUBI R30,LOW(-_g_FileInfo)
	SBCI R31,HIGH(-_g_FileInfo)
	MOVW R26,R30
	CALL __GETW1P
	ADIW R30,8
	ST   -Y,R31
	ST   -Y,R30
	__POINTW2MN _0x477,8
	CALL _strcmp
	CPI  R30,0
	BRNE _0x494
_0x495:
;{
;bTextReader = 1;
	LDI  R30,LOW(1)
	STS  _bTextReader,R30
;}
;if(!strcmp(&g_FileInfo[select_file_index].szFileName[8],".WAV") || !strcmp(&g_FileInfo[select_file_index].szFileName[8], ...
_0x494:
	__GETW1R 5,6
	LDI  R26,LOW(6)
	LDI  R27,HIGH(6)
	CALL __MULW12U
	SUBI R30,LOW(-_g_FileInfo)
	SBCI R31,HIGH(-_g_FileInfo)
	MOVW R26,R30
	CALL __GETW1P
	ADIW R30,8
	ST   -Y,R31
	ST   -Y,R30
	__POINTW2MN _0x477,13
	CALL _strcmp
	CPI  R30,0
	BREQ _0x498
	__GETW1R 5,6
	LDI  R26,LOW(6)
	LDI  R27,HIGH(6)
	CALL __MULW12U
	SUBI R30,LOW(-_g_FileInfo)
	SBCI R31,HIGH(-_g_FileInfo)
	MOVW R26,R30
	CALL __GETW1P
	ADIW R30,8
	ST   -Y,R31
	ST   -Y,R30
	__POINTW2MN _0x477,18
	CALL _strcmp
	CPI  R30,0
	BRNE _0x497
_0x498:
;{
;bMusicPlayer = 1;
	LDI  R30,LOW(1)
	STS  _bMusicPlayer,R30
;}
;else
	RJMP _0x49A
_0x497:
;{
;bFormatAlert = 1;
	LDI  R30,LOW(1)
	STS  _bFormatAlert,R30
;}
_0x49A:
;break;
	RJMP _0x492
;case DELETE:
_0x493:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BREQ PC+2
	RJMP _0x49B
;if(!f_unlink(g_FileInfo[select_file_index].szFileName))
	__GETW1R 5,6
	LDI  R26,LOW(6)
	LDI  R27,HIGH(6)
	CALL __MULW12U
	SUBI R30,LOW(-_g_FileInfo)
	SBCI R31,HIGH(-_g_FileInfo)
	MOVW R26,R30
	CALL __GETW1P
	MOVW R26,R30
	RCALL _f_unlink
	CPI  R30,0
	BREQ PC+2
	RJMP _0x49C
;{
;bSelect = 0;
	CLR  R3
;bIsfOpened = 0;
	CLR  R4
;select_file_option_index = 0;
	CLR  R7
	CLR  R8
;select_file_index = 0;
	CLR  R5
	CLR  R6
;for(i = 0;i<nNofDirFiles;i++)
	LDI  R30,LOW(0)
	STD  Y+6,R30
	STD  Y+6+1,R30
_0x49E:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	CP   R26,R9
	CPC  R27,R10
	BRSH _0x49F
;{
;if(g_FileInfo[i].szFileName)
	LDI  R30,LOW(6)
	CALL __MULB1W2U
	SUBI R30,LOW(-_g_FileInfo)
	SBCI R31,HIGH(-_g_FileInfo)
	MOVW R26,R30
	CALL __GETW1P
	SBIW R30,0
	BREQ _0x4A0
;memset((void*)g_FileInfo[i].szFileName,0,32);
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(6)
	CALL __MULB1W2U
	SUBI R30,LOW(-_g_FileInfo)
	SBCI R31,HIGH(-_g_FileInfo)
	MOVW R26,R30
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(0)
	ST   -Y,R30
	LDI  R26,LOW(32)
	LDI  R27,0
	CALL _memset
;free(g_FileInfo[i].szFileName);
_0x4A0:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(6)
	CALL __MULB1W2U
	SUBI R30,LOW(-_g_FileInfo)
	SBCI R31,HIGH(-_g_FileInfo)
	MOVW R26,R30
	CALL __GETW1P
	MOVW R26,R30
	CALL _free
;g_FileInfo[i].szFileName = 0;
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(6)
	CALL __MULB1W2U
	SUBI R30,LOW(-_g_FileInfo)
	SBCI R31,HIGH(-_g_FileInfo)
	LDI  R26,LOW(0)
	LDI  R27,HIGH(0)
	STD  Z+0,R26
	STD  Z+1,R27
;}
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,1
	STD  Y+6,R30
	STD  Y+6+1,R31
	RJMP _0x49E
_0x49F:
;nKey = 0;
	CLR  R11
	CLR  R12
;}
;break;
_0x49C:
	RJMP _0x492
;case INFO:
_0x49B:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x492
;bFileInfoWindow = 1;
	LDI  R30,LOW(1)
	STS  _bFileInfoWindow,R30
;break;
;}
_0x492:
;}
;bSelect = 1;
_0x48F:
	LDI  R30,LOW(1)
	MOV  R3,R30
;break;
;}
_0x484:
;if(!bIsfOpened)
	TST  R4
	BRNE _0x4A2
;f_mkdir("LOG");
	__POINTW2MN _0x477,23
	RCALL _f_mkdir
;if(bFormatAlert)
_0x4A2:
	LDS  R30,_bFormatAlert
	CPI  R30,0
	BREQ _0x4A3
;{
;nlcd_Box(10,32,58,80,2,WHITE,GREEN);
	LDI  R30,LOW(10)
	ST   -Y,R30
	LDI  R30,LOW(32)
	ST   -Y,R30
	LDI  R30,LOW(58)
	ST   -Y,R30
	LDI  R30,LOW(80)
	ST   -Y,R30
	LDI  R30,LOW(2)
	ST   -Y,R30
	LDI  R30,LOW(4095)
	LDI  R31,HIGH(4095)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(240)
	LDI  R27,0
	CALL _nlcd_Box
;nlcd_String("Not Supported",45,20,RED,WHITE);
	__POINTW1MN _0x477,27
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(45)
	ST   -Y,R30
	LDI  R30,LOW(20)
	ST   -Y,R30
	LDI  R30,LOW(3840)
	LDI  R31,HIGH(3840)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(4095)
	LDI  R27,HIGH(4095)
	CALL _nlcd_String
;delay_ms(1000);
	LDI  R26,LOW(1000)
	LDI  R27,HIGH(1000)
	CALL _delay_ms
;bFormatAlert = 0;
	LDI  R30,LOW(0)
	STS  _bFormatAlert,R30
;}
;     // надо проверять готовность порта с помощью wait_ready, чтобы на MISO было 0xFF, иначе придется отрубать питание S ...
;bIsfOpened = 1;
_0x4A3:
	LDI  R30,LOW(1)
	MOV  R4,R30
;nKey = 0;
	CLR  R11
	CLR  R12
;}
;else //if(res == FR_NOT_READY)
	RJMP _0x4A4
_0x476:
;{
;//bBrowserInit = 1;
;f_mount(0,"0",1);
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1MN _0x477,41
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(1)
	CALL _f_mount
;bIsfOpened = 0;
	CLR  R4
;bSelect = 0;
	CLR  R3
;select_file_index = 0;
	CLR  R5
	CLR  R6
;select_file_option_index = 0;
	CLR  R7
	CLR  R8
;for(i = 0;i<nNofDirFiles;i++)
	LDI  R30,LOW(0)
	STD  Y+6,R30
	STD  Y+6+1,R30
_0x4A6:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	CP   R26,R9
	CPC  R27,R10
	BRSH _0x4A7
;{
;if(g_FileInfo[i].szFileName)
	LDI  R30,LOW(6)
	CALL __MULB1W2U
	SUBI R30,LOW(-_g_FileInfo)
	SBCI R31,HIGH(-_g_FileInfo)
	MOVW R26,R30
	CALL __GETW1P
	SBIW R30,0
	BREQ _0x4A8
;memset((void*)g_FileInfo[i].szFileName,0,32);
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(6)
	CALL __MULB1W2U
	SUBI R30,LOW(-_g_FileInfo)
	SBCI R31,HIGH(-_g_FileInfo)
	MOVW R26,R30
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(0)
	ST   -Y,R30
	LDI  R26,LOW(32)
	LDI  R27,0
	CALL _memset
;free(g_FileInfo[i].szFileName);
_0x4A8:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(6)
	CALL __MULB1W2U
	SUBI R30,LOW(-_g_FileInfo)
	SBCI R31,HIGH(-_g_FileInfo)
	MOVW R26,R30
	CALL __GETW1P
	MOVW R26,R30
	CALL _free
;}
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,1
	STD  Y+6,R30
	STD  Y+6+1,R31
	RJMP _0x4A6
_0x4A7:
;nlcd_String("<Slot Empty>",30,20,BLACK,WHITE);
	__POINTW1MN _0x477,43
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(30)
	ST   -Y,R30
	LDI  R30,LOW(20)
	ST   -Y,R30
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(4095)
	LDI  R27,HIGH(4095)
	CALL _nlcd_String
;nlcd_String("No Card",18,5,BLACK,WHITE);
	__POINTW1MN _0x477,56
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(18)
	ST   -Y,R30
	LDI  R30,LOW(5)
	ST   -Y,R30
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(4095)
	LDI  R27,HIGH(4095)
	CALL _nlcd_String
;}
_0x4A4:
;if(!bFileInfoWindow && !bTextReader)
	LDS  R30,_bFileInfoWindow
	CPI  R30,0
	BRNE _0x4AA
	LDS  R30,_bTextReader
	CPI  R30,0
	BREQ _0x4AB
_0x4AA:
	RJMP _0x4A9
_0x4AB:
;{
;nlcd_String("Browser",5,40,WHITE,BLUE);
	__POINTW1MN _0x477,64
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(5)
	ST   -Y,R30
	LDI  R30,LOW(40)
	ST   -Y,R30
	LDI  R30,LOW(4095)
	LDI  R31,HIGH(4095)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(15)
	LDI  R27,0
	CALL _nlcd_String
;nlcd_HorizontalLine(27,BLACK);
	LDI  R30,LOW(27)
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	CALL _nlcd_HorizontalLine
;nlcd_HorizontalLine(15,BLACK);
	LDI  R30,LOW(15)
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	CALL _nlcd_HorizontalLine
;for(i = 0;i<15;i++)
	LDI  R30,LOW(0)
	STD  Y+6,R30
	STD  Y+6+1,R30
_0x4AD:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	SBIW R26,15
	BRSH _0x4AE
;{
;nlcd_PixelLine2x1(30,i,WHITE,BLACK);
	LDI  R30,LOW(30)
	ST   -Y,R30
	LDD  R30,Y+7
	ST   -Y,R30
	LDI  R30,LOW(4095)
	LDI  R31,HIGH(4095)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	CALL _nlcd_PixelLine2x1
;nlcd_PixelLine2x1(100,i,WHITE,BLACK);
	LDI  R30,LOW(100)
	ST   -Y,R30
	LDD  R30,Y+7
	ST   -Y,R30
	LDI  R30,LOW(4095)
	LDI  R31,HIGH(4095)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	CALL _nlcd_PixelLine2x1
;}
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,1
	STD  Y+6,R30
	STD  Y+6+1,R31
	RJMP _0x4AD
_0x4AE:
;}
;nlcd_HorizontalLine(120,BLACK);
_0x4A9:
	LDI  R30,LOW(120)
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	CALL _nlcd_HorizontalLine
;for(i = 121;i<131;i++)
	LDI  R30,LOW(121)
	LDI  R31,HIGH(121)
	STD  Y+6,R30
	STD  Y+6+1,R31
_0x4B0:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	CPI  R26,LOW(0x83)
	LDI  R30,HIGH(0x83)
	CPC  R27,R30
	BRSH _0x4B1
;{
;nlcd_PixelLine2x1(50,i,WHITE,BLACK);
	LDI  R30,LOW(50)
	ST   -Y,R30
	LDD  R30,Y+7
	ST   -Y,R30
	LDI  R30,LOW(4095)
	LDI  R31,HIGH(4095)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	CALL _nlcd_PixelLine2x1
;nlcd_PixelLine2x1(95,i,WHITE,BLACK);
	LDI  R30,LOW(95)
	ST   -Y,R30
	LDD  R30,Y+7
	ST   -Y,R30
	LDI  R30,LOW(4095)
	LDI  R31,HIGH(4095)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	CALL _nlcd_PixelLine2x1
;}
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,1
	STD  Y+6,R30
	STD  Y+6+1,R31
	RJMP _0x4B0
_0x4B1:
;}
	CALL __LOADLOCR6
	ADIW R28,54
	SUBI R29,-2
	RET
; .FEND

	.DSEG
_0x477:
	.BYTE 0x48
;
;///////////////////////////////IMAGE VIEWER////////////////////////////////////////
;void image_viewer_init()
;{

	.CSEG
;
;}
;
;///////////////////////////////TEXT READER/////////////////////////////////////////
;void text_reader_init(int nFileIndex)
;{
_text_reader_init:
; .FSTART _text_reader_init
;/*unsigned char sznotestring[16];
;UINT bw;
;int i;
;   nlcd_String("***Note Pad***",5,5,RED,WHITE);
;   if(!f_open(&file,g_FileInfo[nFileIndex].szFileName,FA_OPEN_ALWAYS | FA_READ))
;   {
;   f_lseek(&file,scroll_index);
;   memset((void*)sznotestring,0,16);
;   for(i = 0;i<12;i++)
;   {
;   f_read(&file,sznotestring,16,&bw);
;   nlcd_String(sznotestring,15 + i*10,5,BLACK,WHITE);
;   f_lseek(&file,scroll_index+(i+1)*16);
;   memset((void*)sznotestring,0,16);
;   }
;   }      */
;}
	RET
; .FEND
;
;////////////////////////////////////MUSIC PLAYER//////////////////////////////////
;void music_player_init(int nFileIndex)
;{
_music_player_init:
; .FSTART _music_player_init
;UINT bw;
;unsigned char sznotestring[8];
;int nNumChannels = 0;
;nlcd_String("***Music Player***",5,1,RED,WHITE);
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,8
	CALL __SAVELOCR4
;	nFileIndex -> Y+12
;	bw -> R16,R17
;	sznotestring -> Y+4
;	nNumChannels -> R18,R19
	__GETWRN 18,19,0
	__POINTW1MN _0x4B2,0
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(5)
	ST   -Y,R30
	LDI  R30,LOW(1)
	ST   -Y,R30
	LDI  R30,LOW(3840)
	LDI  R31,HIGH(3840)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(4095)
	LDI  R27,HIGH(4095)
	CALL _nlcd_String
;nlcd_String(g_FileInfo[nFileIndex].szFileName,15,1,RED,WHITE);
	LDD  R26,Y+12
	LDD  R27,Y+12+1
	LDI  R30,LOW(6)
	CALL __MULB1W2U
	SUBI R30,LOW(-_g_FileInfo)
	SBCI R31,HIGH(-_g_FileInfo)
	MOVW R26,R30
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(15)
	ST   -Y,R30
	LDI  R30,LOW(1)
	ST   -Y,R30
	LDI  R30,LOW(3840)
	LDI  R31,HIGH(3840)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(4095)
	LDI  R27,HIGH(4095)
	CALL _nlcd_String
;//f_lseek(&file,22);
;//f_read(&file,sznotestring,2,&bw);
;//nNumChannels = atoi(sznotestring);
;if(!bMusicFOpened)
	LDS  R30,_bMusicFOpened
	CPI  R30,0
	BRNE _0x4B3
;{
;   if(!f_open(&file,g_FileInfo[nFileIndex].szFileName,FA_OPEN_ALWAYS | FA_READ))
	LDI  R30,LOW(_file)
	LDI  R31,HIGH(_file)
	ST   -Y,R31
	ST   -Y,R30
	LDD  R26,Y+14
	LDD  R27,Y+14+1
	LDI  R30,LOW(6)
	CALL __MULB1W2U
	SUBI R30,LOW(-_g_FileInfo)
	SBCI R31,HIGH(-_g_FileInfo)
	MOVW R26,R30
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(17)
	CALL _f_open
	CPI  R30,0
	BRNE _0x4B4
;   {
;TCCR0A=(0<<COM0A1) | (1<<COM0A0) | (0<<COM0B1) | (0<<COM0B0) | (1<<WGM01) | (1<<WGM00);
	LDI  R30,LOW(67)
	OUT  0x24,R30
;TCCR0B=(0<<WGM02) | (0<<CS02) | (0<<CS01) | (1<<CS00);
	LDI  R30,LOW(1)
	OUT  0x25,R30
;TCNT0=0x00;
	LDI  R30,LOW(0)
	OUT  0x26,R30
;OCR0A=0x00;
	OUT  0x27,R30
;OCR0B=0x00;
	OUT  0x28,R30
;bMusicFOpened = 1;
	LDI  R30,LOW(1)
	STS  _bMusicFOpened,R30
;f_lseek(&file,44);
	LDI  R30,LOW(_file)
	LDI  R31,HIGH(_file)
	ST   -Y,R31
	ST   -Y,R30
	__GETD2N 0x2C
	CALL _f_lseek
;}
;}
_0x4B4:
;switch (state)
_0x4B3:
	LDS  R30,_state
	LDS  R31,_state+1
;{
; case 0:
	SBIW R30,0
	BRNE _0x4B8
; if (nAudioBufferIndex >= HALF_BUF)
	LDI  R30,LOW(128)
	LDI  R31,HIGH(128)
	CP   R13,R30
	CPC  R14,R31
	BRLT _0x4B9
; {
;   f_read(&file,sznotestring, HALF_BUF, &bw);
	LDI  R30,LOW(_file)
	LDI  R31,HIGH(_file)
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,6
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(128)
	LDI  R31,HIGH(128)
	ST   -Y,R31
	ST   -Y,R30
	IN   R26,SPL
	IN   R27,SPH
	SBIW R26,1
	PUSH R17
	PUSH R16
	CALL _f_read
	POP  R16
	POP  R17
;   if (bw > HALF_BUF)
	__CPWRN 16,17,129
	BRLO _0x4BA
;   {
;      state = 1;
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	STS  _state,R30
	STS  _state+1,R31
;   }
; }
_0x4BA:
; break;
_0x4B9:
	RJMP _0x4B7
;
; case 1:
_0x4B8:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x4B7
; if (nAudioBufferIndex < HALF_BUF)
	LDI  R30,LOW(128)
	LDI  R31,HIGH(128)
	CP   R13,R30
	CPC  R14,R31
	BRGE _0x4BC
; {
;   f_read(&file,&sznotestring[HALF_BUF], HALF_BUF, &bw);
	LDI  R30,LOW(_file)
	LDI  R31,HIGH(_file)
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	SUBI R30,LOW(-134)
	SBCI R31,HIGH(-134)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(128)
	LDI  R31,HIGH(128)
	ST   -Y,R31
	ST   -Y,R30
	IN   R26,SPL
	IN   R27,SPH
	SBIW R26,1
	PUSH R17
	PUSH R16
	CALL _f_read
	POP  R16
	POP  R17
;   if (bw > HALF_BUF)
	__CPWRN 16,17,129
	BRLO _0x4BD
;   {
;      state = 0;
	LDI  R30,LOW(0)
	STS  _state,R30
	STS  _state+1,R30
;   }
; }
_0x4BD:
; break;
_0x4BC:
; }
_0x4B7:
;}
	CALL __LOADLOCR4
	ADIW R28,14
	RET
; .FEND

	.DSEG
_0x4B2:
	.BYTE 0x13
;#include <sleep.h>
;
;unsigned int vcc = 0;//variable to hold the value of Vcc
;
;
;
;void ADC_Init(){
; 0000 0013 void ADC_Init(){

	.CSEG
_ADC_Init:
; .FSTART _ADC_Init
; 0000 0014 ADCSRA=(1<<ADEN) | (0<<ADSC) | (0<<ADATE) | (0<<ADIF) | (0<<ADIE) | (1<<ADPS2) | (1<<ADPS1) | (0<<ADPS0);
	LDI  R30,LOW(134)
	STS  122,R30
; 0000 0015 ADCSRB=(0<<ADTS2) | (0<<ADTS1) | (0<<ADTS0);
	LDI  R30,LOW(0)
	STS  123,R30
; 0000 0016 ADMUX = (0 << REFS1)|(0 << REFS0) |(1 << MUX0)|(1 << MUX1)|(1 << MUX2)|(0 << MUX3);
	LDI  R30,LOW(7)
	STS  124,R30
; 0000 0017 }
	RET
; .FEND
;
;
;unsigned int ReadADC(unsigned char ref_channel){
; 0000 001A unsigned int ReadADC(unsigned char ref_channel){
_ReadADC:
; .FSTART _ReadADC
; 0000 001B   //ADMUX = ref_channel; //выбираем канал и источник опорного напряжения. Из соображений качества кода лучше бы разделит ...
; 0000 001C  int i;
; 0000 001D  for(i = 0;i<8;i++)
	ST   -Y,R26
	ST   -Y,R17
	ST   -Y,R16
;	ref_channel -> Y+2
;	i -> R16,R17
	__GETWRN 16,17,0
_0x4BF:
	__CPWRN 16,17,8
	BRGE _0x4C0
; 0000 001E  {
; 0000 001F  ADCSRA |= (1<<ADSC); //запускаем преобразование
	LDS  R30,122
	ORI  R30,0x40
	STS  122,R30
; 0000 0020   while(! (ADCSRA & (1<<ADIF)) ){} //ждем пока преобразование не закончится
_0x4C1:
	LDS  R30,122
	ANDI R30,LOW(0x10)
	BREQ _0x4C1
; 0000 0021   }
	__ADDWRN 16,17,1
	RJMP _0x4BF
_0x4C0:
; 0000 0022   ADCSRA |= (1<<ADIF); //сбрасываем флаг прерывания
	LDS  R30,122
	ORI  R30,0x10
	STS  122,R30
; 0000 0023   return ADCW;
	LDS  R30,120
	LDS  R31,120+1
	LDD  R17,Y+1
	LDD  R16,Y+0
	ADIW R28,3
	RET
; 0000 0024 }
; .FEND
;
;void main(void) //При использовании буффера (RAM памяти) и 12-битной графики двигать графические объекты и рисовать отде ...
; 0000 0027 {               // т.е. 1 пиксель = 2 пикселям идущим подряд
_main:
; .FSTART _main
; 0000 0028 int i = 0;
; 0000 0029 unsigned char bCardCheck = 0;
; 0000 002A unsigned char str1[32];
; 0000 002B unsigned int adc_data;
; 0000 002C unsigned char adcstr[32];
; 0000 002D unsigned char pBuffer[10];
; 0000 002E unsigned char pBufferstr[10];
; 0000 002F unsigned char adstr[32];
; 0000 0030 unsigned int adc_data2;
; 0000 0031 uint8_t timebuf[8];
; 0000 0032 uint8_t hour;
; 0000 0033 uint8_t min;
; 0000 0034 uint8_t sec;
; 0000 0035 unsigned char timestr[32];
; 0000 0036 CS_LCD_SET;
	SBIW R28,63
	SBIW R28,63
	SBIW R28,34
;	i -> R16,R17
;	bCardCheck -> R19
;	str1 -> Y+128
;	adc_data -> R20,R21
;	adcstr -> Y+96
;	pBuffer -> Y+86
;	pBufferstr -> Y+76
;	adstr -> Y+44
;	adc_data2 -> Y+42
;	timebuf -> Y+34
;	hour -> R18
;	min -> Y+33
;	sec -> Y+32
;	timestr -> Y+0
	__GETWRN 16,17,0
	LDI  R19,0
	SBI  0x5,2
; 0000 0037 CS_SRAM_SET;
	SBI  0x5,0
; 0000 0038 SRAM_HOLD_SET;
	SBI  0x8,1
; 0000 0039 DDRC = 0xFF;
	LDI  R30,LOW(255)
	OUT  0x7,R30
; 0000 003A PORTC = 0xFF;
	OUT  0x8,R30
; 0000 003B DDRD = 0xFF;
	OUT  0xA,R30
; 0000 003C DDRD.2 = 0;
	CBI  0xA,2
; 0000 003D PORTD.0 = 0;
	CBI  0xB,0
; 0000 003E nlcd_InitSPI();
	CALL _nlcd_InitSPI
; 0000 003F nlcd_InitPixelBuffer(1);
	LDI  R26,LOW(1)
	LDI  R27,0
	CALL _nlcd_InitPixelBuffer
; 0000 0040 nlcd_Init();
	CALL _nlcd_Init
; 0000 0041 delay_ms(20);
	LDI  R26,LOW(20)
	LDI  R27,0
	CALL _delay_ms
; 0000 0042 TWI_MasterInit(100);
	LDI  R26,LOW(100)
	LDI  R27,0
	CALL _TWI_MasterInit
; 0000 0043    /*подготавливаем сообщение*/
; 0000 0044   timebuf[0] = (DS1307_ADR<<1)|0;  //адресный пакет
	LDI  R30,LOW(208)
	STD  Y+34,R30
; 0000 0045   timebuf[1] = 0;                  //адрес регистра
	LDI  R30,LOW(0)
	STD  Y+35,R30
; 0000 0046   timebuf[2] = (5<<4)|5;           //значение секунд
	LDI  R30,LOW(85)
	STD  Y+36,R30
; 0000 0047   timebuf[3] = (5<<4)|9;           //значение минут
	LDI  R30,LOW(89)
	STD  Y+37,R30
; 0000 0048   timebuf[4] = 0;                  //значение часов
	LDI  R30,LOW(0)
	STD  Y+38,R30
; 0000 0049   TWI_SendData(timebuf, 5);
	MOVW R30,R28
	ADIW R30,34
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(5)
	CALL _TWI_SendData
; 0000 004A //смонтировать диск
; 0000 004B //df_Memory_Erase();
; 0000 004C /*pBuffer[0] = 10;
; 0000 004D pBuffer[1] = 2;
; 0000 004E pBuffer[2] = 3;
; 0000 004F pBuffer[3] = 4;
; 0000 0050 pBuffer[4] = 5;
; 0000 0051 //df_Memory_Write_Buffer(0xA74,0x0E,&pBuffer[0],4,1);
; 0000 0052 pBuffer[0] = 0;
; 0000 0053 pBuffer[1] = 0;
; 0000 0054 pBuffer[2] = 0;
; 0000 0055 pBuffer[3] = 0;
; 0000 0056 pBuffer[4] = 0;
; 0000 0057 df_Memory_Read_Buffer(0xA74,0x0E,&pBuffer[0],4,1);
; 0000 0058 sprintf(pBufferstr,"%i,%i,%i,%i",pBuffer[0],pBuffer[1],pBuffer[2],pBuffer[3]);  */
; 0000 0059 ADC_Init();
	RCALL _ADC_Init
; 0000 005A DDRD.2 = 0;
	CBI  0xA,2
; 0000 005B EICRA=(0<<ISC11) | (0<<ISC10) | (1<<ISC01) | (0<<ISC00);
	LDI  R30,LOW(2)
	STS  105,R30
; 0000 005C EIMSK=(0<<INT1) | (1<<INT0);
	LDI  R30,LOW(1)
	OUT  0x1D,R30
; 0000 005D EIFR=(0<<INTF1) | (1<<INTF0);
	OUT  0x1C,R30
; 0000 005E PCICR=(0<<PCIE2) | (0<<PCIE1) | (0<<PCIE0);
	LDI  R30,LOW(0)
	STS  104,R30
; 0000 005F KEYS_INIT;
	SBI  0x7,0
	SBI  0x7,2
	CBI  0xA,7
; 0000 0060 CS_KEYS_SET;
	SBI  0x8,0
; 0000 0061 #asm("sei");
	sei
; 0000 0062 while(1)
_0x4D2:
; 0000 0063     {
; 0000 0064 nlcd_Clear(WHITE);
	LDI  R26,LOW(4095)
	LDI  R27,HIGH(4095)
	CALL _nlcd_Clear
; 0000 0065 //nlcd_String(&pBufferstr[0],90,52,MAGENTA,WHITE);
; 0000 0066 CS_LCD_SET;
	SBI  0x5,2
; 0000 0067 CS_SRAM_SET;
	SBI  0x5,0
; 0000 0068 browser_init();
	RCALL _browser_init
; 0000 0069 PORTD.0 = 0;
	CBI  0xB,0
; 0000 006A ///ADC Vref 1.1V
; 0000 006B adc_data = ReadADC(14);
	LDI  R26,LOW(14)
	RCALL _ReadADC
	MOVW R20,R30
; 0000 006C vcc = 110 * 1024 / adc_data/3.3;     //// Для точности откалибровать !!! 1.2 - 1.3В бандгап
	CLR  R22
	CLR  R23
	__GETD2N 0x1B800
	CALL __DIVD21
	CALL __CDF1
	MOVW R26,R30
	MOVW R24,R22
	__GETD1N 0x40533333
	CALL __DIVF21
	LDI  R26,LOW(_vcc)
	LDI  R27,HIGH(_vcc)
	CALL __CFD1U
	ST   X+,R30
	ST   X,R31
; 0000 006D sprintf(&adcstr[0],"B:%i", vcc);
	MOVW R30,R28
	SUBI R30,LOW(-(96))
	SBCI R31,HIGH(-(96))
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1FN _0x0,276
	ST   -Y,R31
	ST   -Y,R30
	LDS  R30,_vcc
	LDS  R31,_vcc+1
	CLR  R22
	CLR  R23
	CALL __PUTPARD1
	LDI  R24,4
	CALL _sprintf
	ADIW R28,8
; 0000 006E strcat(&adcstr[0],"%");
	MOVW R30,R28
	SUBI R30,LOW(-(96))
	SBCI R31,HIGH(-(96))
	ST   -Y,R31
	ST   -Y,R30
	__POINTW2MN _0x4D7,0
	CALL _strcat
; 0000 006F nlcd_String(&adcstr[0],122,2,GREEN,WHITE);
	MOVW R30,R28
	SUBI R30,LOW(-(96))
	SBCI R31,HIGH(-(96))
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(122)
	ST   -Y,R30
	LDI  R30,LOW(2)
	ST   -Y,R30
	LDI  R30,LOW(240)
	LDI  R31,HIGH(240)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(4095)
	LDI  R27,HIGH(4095)
	CALL _nlcd_String
; 0000 0070        /*устанавливаем указатель DS1307
; 0000 0071        на нулевой адрес*/
; 0000 0072       timebuf[0] = (DS1307_ADR<<1)|0; //адресный пакет
	LDI  R30,LOW(208)
	STD  Y+34,R30
; 0000 0073       timebuf[1] = 0;                 //адрес регистра
	LDI  R30,LOW(0)
	STD  Y+35,R30
; 0000 0074       TWI_SendData(timebuf, 2);
	MOVW R30,R28
	ADIW R30,34
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(2)
	CALL _TWI_SendData
; 0000 0075       /*считываем время с DS1307*/
; 0000 0076       timebuf[0] = (DS1307_ADR<<1)|1;
	LDI  R30,LOW(209)
	STD  Y+34,R30
; 0000 0077       TWI_SendData(timebuf, 5);
	MOVW R30,R28
	ADIW R30,34
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(5)
	CALL _TWI_SendData
; 0000 0078       /*переписываем данные буфера
; 0000 0079       драйвера в свой буфер*/
; 0000 007A       TWI_GetData(timebuf, 5);
	MOVW R30,R28
	ADIW R30,34
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(5)
	CALL _TWI_GetData
; 0000 007B       sec = timebuf[1];
	LDD  R30,Y+35
	STD  Y+32,R30
; 0000 007C       min  = timebuf[2];
	LDD  R30,Y+36
	STD  Y+33,R30
; 0000 007D       hour = timebuf[3];
	LDD  R18,Y+37
; 0000 007E sprintf(&timestr[0],"%i%i:%i%i:%i%i",(hour>>4),(hour&0xf),(min>>4),(min&0xf),(sec>>4),(sec&0xf));
	MOVW R30,R28
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1FN _0x0,283
	ST   -Y,R31
	ST   -Y,R30
	MOV  R30,R18
	LDI  R31,0
	CALL __ASRW4
	CALL __CWD1
	CALL __PUTPARD1
	MOV  R30,R18
	ANDI R30,LOW(0xF)
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __PUTPARD1
	LDD  R30,Y+45
	LDI  R31,0
	CALL __ASRW4
	CALL __CWD1
	CALL __PUTPARD1
	LDD  R30,Y+49
	ANDI R30,LOW(0xF)
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __PUTPARD1
	LDD  R30,Y+52
	LDI  R31,0
	CALL __ASRW4
	CALL __CWD1
	CALL __PUTPARD1
	LDD  R30,Y+56
	ANDI R30,LOW(0xF)
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __PUTPARD1
	LDI  R24,24
	CALL _sprintf
	ADIW R28,28
; 0000 007F nlcd_String(&timestr[0],122,52,MAGENTA,WHITE);
	MOVW R30,R28
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(122)
	ST   -Y,R30
	LDI  R30,LOW(52)
	ST   -Y,R30
	LDI  R30,LOW(3855)
	LDI  R31,HIGH(3855)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(4095)
	LDI  R27,HIGH(4095)
	CALL _nlcd_String
; 0000 0080 nlcd_RenderPixelBuffer();
	CALL _nlcd_RenderPixelBuffer
; 0000 0081    }
	RJMP _0x4D2
; 0000 0082 }
_0x4D8:
	RJMP _0x4D8
; .FEND

	.DSEG
_0x4D7:
	.BYTE 0x2

	.CSEG
_memmove:
; .FSTART _memmove
	ST   -Y,R27
	ST   -Y,R26
    ldd  r25,y+1
    ld   r24,y
    adiw r24,0
    breq memmove3
    ldd  r27,y+5
    ldd  r26,y+4
    ldd  r31,y+3
    ldd  r30,y+2
    cp   r30,r26
    cpc  r31,r27
    breq memmove3
    brlt memmove1
memmove0:
    ld   r22,z+
    st   x+,r22
    sbiw r24,1
    brne memmove0
    rjmp memmove3
memmove1:
    add  r26,r24
    adc  r27,r25
    add  r30,r24
    adc  r31,r25
memmove2:
    ld   r22,-z
    st   -x,r22
    sbiw r24,1
    brne memmove2
memmove3:
    ldd  r31,y+5
    ldd  r30,y+4
	JMP  _0x20C0004
; .FEND
_memset:
; .FSTART _memset
	ST   -Y,R27
	ST   -Y,R26
    ldd  r27,y+1
    ld   r26,y
    adiw r26,0
    breq memset1
    ldd  r31,y+4
    ldd  r30,y+3
    ldd  r22,y+2
memset0:
    st   z+,r22
    sbiw r26,1
    brne memset0
memset1:
    ldd  r30,y+3
    ldd  r31,y+4
	JMP  _0x20C000A
; .FEND
_strcat:
; .FSTART _strcat
	ST   -Y,R27
	ST   -Y,R26
    ld   r30,y+
    ld   r31,y+
    ld   r26,y+
    ld   r27,y+
    movw r24,r26
strcat0:
    ld   r22,x+
    tst  r22
    brne strcat0
    sbiw r26,1
strcat1:
    ld   r22,z+
    st   x+,r22
    tst  r22
    brne strcat1
    movw r30,r24
    ret
; .FEND
_strcmp:
; .FSTART _strcmp
	ST   -Y,R27
	ST   -Y,R26
    ld   r30,y+
    ld   r31,y+
    ld   r26,y+
    ld   r27,y+
strcmp0:
    ld   r22,x+
    ld   r23,z+
    cp   r22,r23
    brne strcmp1
    tst  r22
    brne strcmp0
strcmp3:
    clr  r30
    ret
strcmp1:
    sub  r22,r23
    breq strcmp3
    ldi  r30,1
    brcc strcmp2
    subi r30,2
strcmp2:
    ret
; .FEND
_strcpy:
; .FSTART _strcpy
	ST   -Y,R27
	ST   -Y,R26
    ld   r30,y+
    ld   r31,y+
    ld   r26,y+
    ld   r27,y+
    movw r24,r26
strcpy0:
    ld   r22,z+
    st   x+,r22
    tst  r22
    brne strcpy0
    movw r30,r24
    ret
; .FEND
_strcpyf:
; .FSTART _strcpyf
	ST   -Y,R27
	ST   -Y,R26
    ld   r30,y+
    ld   r31,y+
    ld   r26,y+
    ld   r27,y+
    movw r24,r26
strcpyf0:
	lpm  r0,z+
    st   x+,r0
    tst  r0
    brne strcpyf0
    movw r30,r24
    ret
; .FEND
_strlen:
; .FSTART _strlen
	ST   -Y,R27
	ST   -Y,R26
    ld   r26,y+
    ld   r27,y+
    clr  r30
    clr  r31
strlen0:
    ld   r22,x+
    tst  r22
    breq strlen1
    adiw r30,1
    rjmp strlen0
strlen1:
    ret
; .FEND
_strlenf:
; .FSTART _strlenf
	ST   -Y,R27
	ST   -Y,R26
    clr  r26
    clr  r27
    ld   r30,y+
    ld   r31,y+
strlenf0:
	lpm  r0,z+
    tst  r0
    breq strlenf1
    adiw r26,1
    rjmp strlenf0
strlenf1:
    movw r30,r26
    ret
; .FEND
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x01
	.EQU __sm_mask=0x0E
	.EQU __sm_adc_noise_red=0x02
	.EQU __sm_powerdown=0x04
	.EQU __sm_powersave=0x06
	.EQU __sm_standby=0x0C
	.EQU __sm_ext_standby=0x0E
	.SET power_ctrl_reg=smcr
	#endif

	.CSEG
_put_buff_G101:
; .FSTART _put_buff_G101
	ST   -Y,R27
	ST   -Y,R26
	ST   -Y,R17
	ST   -Y,R16
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	ADIW R26,2
	CALL __GETW1P
	SBIW R30,0
	BREQ _0x2020016
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	ADIW R26,4
	CALL __GETW1P
	MOVW R16,R30
	SBIW R30,0
	BREQ _0x2020018
	__CPWRN 16,17,2
	BRLO _0x2020019
	MOVW R30,R16
	SBIW R30,1
	MOVW R16,R30
	__PUTW1SNS 2,4
_0x2020018:
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	ADIW R26,2
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
	SBIW R30,1
	LDD  R26,Y+4
	STD  Z+0,R26
_0x2020019:
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	CALL __GETW1P
	TST  R31
	BRMI _0x202001A
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
_0x202001A:
	RJMP _0x202001B
_0x2020016:
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	ST   X+,R30
	ST   X,R31
_0x202001B:
	LDD  R17,Y+1
	LDD  R16,Y+0
_0x20C000A:
	ADIW R28,5
	RET
; .FEND
__ftoe_G101:
; .FSTART __ftoe_G101
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,4
	LDI  R30,LOW(0)
	ST   Y,R30
	STD  Y+1,R30
	LDI  R30,LOW(128)
	STD  Y+2,R30
	LDI  R30,LOW(63)
	STD  Y+3,R30
	CALL __SAVELOCR4
	LDD  R30,Y+14
	LDD  R31,Y+14+1
	CPI  R30,LOW(0xFFFF)
	LDI  R26,HIGH(0xFFFF)
	CPC  R31,R26
	BRNE _0x202001F
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ST   -Y,R31
	ST   -Y,R30
	__POINTW2FN _0x2020000,0
	CALL _strcpyf
	RJMP _0x20C0009
_0x202001F:
	CPI  R30,LOW(0x7FFF)
	LDI  R26,HIGH(0x7FFF)
	CPC  R31,R26
	BRNE _0x202001E
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ST   -Y,R31
	ST   -Y,R30
	__POINTW2FN _0x2020000,1
	CALL _strcpyf
	RJMP _0x20C0009
_0x202001E:
	LDD  R26,Y+11
	CPI  R26,LOW(0x7)
	BRLO _0x2020021
	LDI  R30,LOW(6)
	STD  Y+11,R30
_0x2020021:
	LDD  R17,Y+11
_0x2020022:
	MOV  R30,R17
	SUBI R17,1
	CPI  R30,0
	BREQ _0x2020024
	__GETD2S 4
	__GETD1N 0x41200000
	CALL __MULF12
	__PUTD1S 4
	RJMP _0x2020022
_0x2020024:
	__GETD1S 12
	CALL __CPD10
	BRNE _0x2020025
	LDI  R19,LOW(0)
	__GETD2S 4
	__GETD1N 0x41200000
	CALL __MULF12
	__PUTD1S 4
	RJMP _0x2020026
_0x2020025:
	LDD  R19,Y+11
	__GETD1S 4
	__GETD2S 12
	CALL __CMPF12
	BREQ PC+2
	BRCC PC+2
	RJMP _0x2020027
	__GETD2S 4
	__GETD1N 0x41200000
	CALL __MULF12
	__PUTD1S 4
_0x2020028:
	__GETD1S 4
	__GETD2S 12
	CALL __CMPF12
	BRLO _0x202002A
	__GETD1N 0x3DCCCCCD
	CALL __MULF12
	__PUTD1S 12
	SUBI R19,-LOW(1)
	RJMP _0x2020028
_0x202002A:
	RJMP _0x202002B
_0x2020027:
_0x202002C:
	__GETD1S 4
	__GETD2S 12
	CALL __CMPF12
	BRSH _0x202002E
	__GETD1N 0x41200000
	CALL __MULF12
	__PUTD1S 12
	SUBI R19,LOW(1)
	RJMP _0x202002C
_0x202002E:
	__GETD2S 4
	__GETD1N 0x41200000
	CALL __MULF12
	__PUTD1S 4
_0x202002B:
	__GETD1S 12
	__GETD2N 0x3F000000
	CALL __ADDF12
	__PUTD1S 12
	__GETD1S 4
	__GETD2S 12
	CALL __CMPF12
	BRLO _0x202002F
	__GETD1N 0x3DCCCCCD
	CALL __MULF12
	__PUTD1S 12
	SUBI R19,-LOW(1)
_0x202002F:
_0x2020026:
	LDI  R17,LOW(0)
_0x2020030:
	LDD  R30,Y+11
	CP   R30,R17
	BRSH PC+2
	RJMP _0x2020032
	__GETD2S 4
	__GETD1N 0x3DCCCCCD
	CALL __MULF12
	__GETD2N 0x3F000000
	CALL __ADDF12
	MOVW R26,R30
	MOVW R24,R22
	CALL _floor
	__PUTD1S 4
	__GETD2S 12
	CALL __DIVF21
	CALL __CFD1U
	MOV  R16,R30
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	ADIW R26,1
	STD  Y+8,R26
	STD  Y+8+1,R27
	SBIW R26,1
	SUBI R30,-LOW(48)
	ST   X,R30
	MOV  R30,R16
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __CDF1
	__GETD2S 4
	CALL __MULF12
	__GETD2S 12
	CALL __SWAPD12
	CALL __SUBF12
	__PUTD1S 12
	MOV  R30,R17
	SUBI R17,-1
	CPI  R30,0
	BREQ _0x2020033
	RJMP _0x2020030
_0x2020033:
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	ADIW R26,1
	STD  Y+8,R26
	STD  Y+8+1,R27
	SBIW R26,1
	LDI  R30,LOW(46)
	ST   X,R30
	RJMP _0x2020030
_0x2020032:
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ADIW R30,1
	STD  Y+8,R30
	STD  Y+8+1,R31
	SBIW R30,1
	LDD  R26,Y+10
	STD  Z+0,R26
	CPI  R19,0
	BRGE _0x2020034
	NEG  R19
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDI  R30,LOW(45)
	RJMP _0x2020119
_0x2020034:
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDI  R30,LOW(43)
_0x2020119:
	ST   X,R30
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ADIW R30,1
	STD  Y+8,R30
	STD  Y+8+1,R31
	ADIW R30,1
	STD  Y+8,R30
	STD  Y+8+1,R31
	SBIW R30,1
	MOVW R22,R30
	MOV  R26,R19
	LDI  R30,LOW(10)
	CALL __DIVB21
	SUBI R30,-LOW(48)
	MOVW R26,R22
	ST   X,R30
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ADIW R30,1
	STD  Y+8,R30
	STD  Y+8+1,R31
	SBIW R30,1
	MOVW R22,R30
	MOV  R26,R19
	LDI  R30,LOW(10)
	CALL __MODB21
	SUBI R30,-LOW(48)
	MOVW R26,R22
	ST   X,R30
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDI  R30,LOW(0)
	ST   X,R30
_0x20C0009:
	CALL __LOADLOCR4
	ADIW R28,16
	RET
; .FEND
__print_G101:
; .FSTART __print_G101
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,63
	SBIW R28,17
	CALL __SAVELOCR6
	LDI  R17,0
	__GETW1SX 88
	STD  Y+8,R30
	STD  Y+8+1,R31
	__GETW1SX 86
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   X+,R30
	ST   X,R31
_0x2020036:
	MOVW R26,R28
	SUBI R26,LOW(-(92))
	SBCI R27,HIGH(-(92))
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
	SBIW R30,1
	LPM  R30,Z
	MOV  R18,R30
	CPI  R30,0
	BRNE PC+2
	RJMP _0x2020038
	MOV  R30,R17
	CPI  R30,0
	BRNE _0x202003C
	CPI  R18,37
	BRNE _0x202003D
	LDI  R17,LOW(1)
	RJMP _0x202003E
_0x202003D:
	ST   -Y,R18
	LDD  R26,Y+7
	LDD  R27,Y+7+1
	LDD  R30,Y+9
	LDD  R31,Y+9+1
	ICALL
_0x202003E:
	RJMP _0x202003B
_0x202003C:
	CPI  R30,LOW(0x1)
	BRNE _0x202003F
	CPI  R18,37
	BRNE _0x2020040
	ST   -Y,R18
	LDD  R26,Y+7
	LDD  R27,Y+7+1
	LDD  R30,Y+9
	LDD  R31,Y+9+1
	ICALL
	RJMP _0x202011A
_0x2020040:
	LDI  R17,LOW(2)
	LDI  R30,LOW(0)
	STD  Y+21,R30
	LDI  R16,LOW(0)
	CPI  R18,45
	BRNE _0x2020041
	LDI  R16,LOW(1)
	RJMP _0x202003B
_0x2020041:
	CPI  R18,43
	BRNE _0x2020042
	LDI  R30,LOW(43)
	STD  Y+21,R30
	RJMP _0x202003B
_0x2020042:
	CPI  R18,32
	BRNE _0x2020043
	LDI  R30,LOW(32)
	STD  Y+21,R30
	RJMP _0x202003B
_0x2020043:
	RJMP _0x2020044
_0x202003F:
	CPI  R30,LOW(0x2)
	BRNE _0x2020045
_0x2020044:
	LDI  R21,LOW(0)
	LDI  R17,LOW(3)
	CPI  R18,48
	BRNE _0x2020046
	ORI  R16,LOW(128)
	RJMP _0x202003B
_0x2020046:
	RJMP _0x2020047
_0x2020045:
	CPI  R30,LOW(0x3)
	BRNE _0x2020048
_0x2020047:
	CPI  R18,48
	BRLO _0x202004A
	CPI  R18,58
	BRLO _0x202004B
_0x202004A:
	RJMP _0x2020049
_0x202004B:
	LDI  R26,LOW(10)
	MUL  R21,R26
	MOV  R21,R0
	MOV  R30,R18
	SUBI R30,LOW(48)
	ADD  R21,R30
	RJMP _0x202003B
_0x2020049:
	LDI  R20,LOW(0)
	CPI  R18,46
	BRNE _0x202004C
	LDI  R17,LOW(4)
	RJMP _0x202003B
_0x202004C:
	RJMP _0x202004D
_0x2020048:
	CPI  R30,LOW(0x4)
	BRNE _0x202004F
	CPI  R18,48
	BRLO _0x2020051
	CPI  R18,58
	BRLO _0x2020052
_0x2020051:
	RJMP _0x2020050
_0x2020052:
	ORI  R16,LOW(32)
	LDI  R26,LOW(10)
	MUL  R20,R26
	MOV  R20,R0
	MOV  R30,R18
	SUBI R30,LOW(48)
	ADD  R20,R30
	RJMP _0x202003B
_0x2020050:
_0x202004D:
	CPI  R18,108
	BRNE _0x2020053
	ORI  R16,LOW(2)
	LDI  R17,LOW(5)
	RJMP _0x202003B
_0x2020053:
	RJMP _0x2020054
_0x202004F:
	CPI  R30,LOW(0x5)
	BREQ PC+2
	RJMP _0x202003B
_0x2020054:
	MOV  R30,R18
	CPI  R30,LOW(0x63)
	BRNE _0x2020059
	__GETW1SX 90
	SBIW R30,4
	__PUTW1SX 90
	LDD  R26,Z+4
	ST   -Y,R26
	LDD  R26,Y+7
	LDD  R27,Y+7+1
	LDD  R30,Y+9
	LDD  R31,Y+9+1
	ICALL
	RJMP _0x202005A
_0x2020059:
	CPI  R30,LOW(0x45)
	BREQ _0x202005D
	CPI  R30,LOW(0x65)
	BRNE _0x202005E
_0x202005D:
	RJMP _0x202005F
_0x202005E:
	CPI  R30,LOW(0x66)
	BREQ PC+2
	RJMP _0x2020060
_0x202005F:
	MOVW R30,R28
	ADIW R30,22
	STD  Y+14,R30
	STD  Y+14+1,R31
	__GETW2SX 90
	CALL __GETD1P
	__PUTD1S 10
	__GETW1SX 90
	SBIW R30,4
	__PUTW1SX 90
	LDD  R26,Y+13
	TST  R26
	BRMI _0x2020061
	LDD  R26,Y+21
	CPI  R26,LOW(0x2B)
	BREQ _0x2020063
	CPI  R26,LOW(0x20)
	BREQ _0x2020065
	RJMP _0x2020066
_0x2020061:
	__GETD1S 10
	CALL __ANEGF1
	__PUTD1S 10
	LDI  R30,LOW(45)
	STD  Y+21,R30
_0x2020063:
	SBRS R16,7
	RJMP _0x2020067
	LDD  R30,Y+21
	ST   -Y,R30
	LDD  R26,Y+7
	LDD  R27,Y+7+1
	LDD  R30,Y+9
	LDD  R31,Y+9+1
	ICALL
	RJMP _0x2020068
_0x2020067:
_0x2020065:
	LDD  R30,Y+14
	LDD  R31,Y+14+1
	ADIW R30,1
	STD  Y+14,R30
	STD  Y+14+1,R31
	SBIW R30,1
	LDD  R26,Y+21
	STD  Z+0,R26
_0x2020068:
_0x2020066:
	SBRS R16,5
	LDI  R20,LOW(6)
	CPI  R18,102
	BRNE _0x202006A
	__GETD1S 10
	CALL __PUTPARD1
	ST   -Y,R20
	LDD  R26,Y+19
	LDD  R27,Y+19+1
	CALL _ftoa
	RJMP _0x202006B
_0x202006A:
	__GETD1S 10
	CALL __PUTPARD1
	ST   -Y,R20
	ST   -Y,R18
	LDD  R26,Y+20
	LDD  R27,Y+20+1
	RCALL __ftoe_G101
_0x202006B:
	MOVW R30,R28
	ADIW R30,22
	STD  Y+14,R30
	STD  Y+14+1,R31
	LDD  R26,Y+14
	LDD  R27,Y+14+1
	CALL _strlen
	MOV  R17,R30
	RJMP _0x202006C
_0x2020060:
	CPI  R30,LOW(0x73)
	BRNE _0x202006E
	__GETW1SX 90
	SBIW R30,4
	__PUTW1SX 90
	__GETW2SX 90
	ADIW R26,4
	CALL __GETW1P
	STD  Y+14,R30
	STD  Y+14+1,R31
	LDD  R26,Y+14
	LDD  R27,Y+14+1
	CALL _strlen
	MOV  R17,R30
	RJMP _0x202006F
_0x202006E:
	CPI  R30,LOW(0x70)
	BRNE _0x2020071
	__GETW1SX 90
	SBIW R30,4
	__PUTW1SX 90
	__GETW2SX 90
	ADIW R26,4
	CALL __GETW1P
	STD  Y+14,R30
	STD  Y+14+1,R31
	LDD  R26,Y+14
	LDD  R27,Y+14+1
	CALL _strlenf
	MOV  R17,R30
	ORI  R16,LOW(8)
_0x202006F:
	ANDI R16,LOW(127)
	CPI  R20,0
	BREQ _0x2020073
	CP   R20,R17
	BRLO _0x2020074
_0x2020073:
	RJMP _0x2020072
_0x2020074:
	MOV  R17,R20
_0x2020072:
_0x202006C:
	LDI  R20,LOW(0)
	LDI  R30,LOW(0)
	STD  Y+20,R30
	LDI  R19,LOW(0)
	RJMP _0x2020075
_0x2020071:
	CPI  R30,LOW(0x64)
	BREQ _0x2020078
	CPI  R30,LOW(0x69)
	BRNE _0x2020079
_0x2020078:
	ORI  R16,LOW(4)
	RJMP _0x202007A
_0x2020079:
	CPI  R30,LOW(0x75)
	BRNE _0x202007B
_0x202007A:
	LDI  R30,LOW(10)
	STD  Y+20,R30
	SBRS R16,1
	RJMP _0x202007C
	__GETD1N 0x3B9ACA00
	__PUTD1S 16
	LDI  R17,LOW(10)
	RJMP _0x202007D
_0x202007C:
	__GETD1N 0x2710
	__PUTD1S 16
	LDI  R17,LOW(5)
	RJMP _0x202007D
_0x202007B:
	CPI  R30,LOW(0x58)
	BRNE _0x202007F
	ORI  R16,LOW(8)
	RJMP _0x2020080
_0x202007F:
	CPI  R30,LOW(0x78)
	BREQ PC+2
	RJMP _0x20200BE
_0x2020080:
	LDI  R30,LOW(16)
	STD  Y+20,R30
	SBRS R16,1
	RJMP _0x2020082
	__GETD1N 0x10000000
	__PUTD1S 16
	LDI  R17,LOW(8)
	RJMP _0x202007D
_0x2020082:
	__GETD1N 0x1000
	__PUTD1S 16
	LDI  R17,LOW(4)
_0x202007D:
	CPI  R20,0
	BREQ _0x2020083
	ANDI R16,LOW(127)
	RJMP _0x2020084
_0x2020083:
	LDI  R20,LOW(1)
_0x2020084:
	SBRS R16,1
	RJMP _0x2020085
	__GETW1SX 90
	SBIW R30,4
	__PUTW1SX 90
	__GETW2SX 90
	ADIW R26,4
	CALL __GETD1P
	RJMP _0x202011B
_0x2020085:
	SBRS R16,2
	RJMP _0x2020087
	__GETW1SX 90
	SBIW R30,4
	__PUTW1SX 90
	__GETW2SX 90
	ADIW R26,4
	CALL __GETW1P
	CALL __CWD1
	RJMP _0x202011B
_0x2020087:
	__GETW1SX 90
	SBIW R30,4
	__PUTW1SX 90
	__GETW2SX 90
	ADIW R26,4
	CALL __GETW1P
	CLR  R22
	CLR  R23
_0x202011B:
	__PUTD1S 10
	SBRS R16,2
	RJMP _0x2020089
	LDD  R26,Y+13
	TST  R26
	BRPL _0x202008A
	__GETD1S 10
	CALL __ANEGD1
	__PUTD1S 10
	LDI  R30,LOW(45)
	STD  Y+21,R30
_0x202008A:
	LDD  R30,Y+21
	CPI  R30,0
	BREQ _0x202008B
	SUBI R17,-LOW(1)
	SUBI R20,-LOW(1)
	RJMP _0x202008C
_0x202008B:
	ANDI R16,LOW(251)
_0x202008C:
_0x2020089:
	MOV  R19,R20
_0x2020075:
	SBRC R16,0
	RJMP _0x202008D
_0x202008E:
	CP   R17,R21
	BRSH _0x2020091
	CP   R19,R21
	BRLO _0x2020092
_0x2020091:
	RJMP _0x2020090
_0x2020092:
	SBRS R16,7
	RJMP _0x2020093
	SBRS R16,2
	RJMP _0x2020094
	ANDI R16,LOW(251)
	LDD  R18,Y+21
	SUBI R17,LOW(1)
	RJMP _0x2020095
_0x2020094:
	LDI  R18,LOW(48)
_0x2020095:
	RJMP _0x2020096
_0x2020093:
	LDI  R18,LOW(32)
_0x2020096:
	ST   -Y,R18
	LDD  R26,Y+7
	LDD  R27,Y+7+1
	LDD  R30,Y+9
	LDD  R31,Y+9+1
	ICALL
	SUBI R21,LOW(1)
	RJMP _0x202008E
_0x2020090:
_0x202008D:
_0x2020097:
	CP   R17,R20
	BRSH _0x2020099
	ORI  R16,LOW(16)
	SBRS R16,2
	RJMP _0x202009A
	ANDI R16,LOW(251)
	LDD  R30,Y+21
	ST   -Y,R30
	__GETW2SX 87
	__GETW1SX 89
	ICALL
	CPI  R21,0
	BREQ _0x202009B
	SUBI R21,LOW(1)
_0x202009B:
	SUBI R17,LOW(1)
	SUBI R20,LOW(1)
_0x202009A:
	LDI  R30,LOW(48)
	ST   -Y,R30
	LDD  R26,Y+7
	LDD  R27,Y+7+1
	LDD  R30,Y+9
	LDD  R31,Y+9+1
	ICALL
	CPI  R21,0
	BREQ _0x202009C
	SUBI R21,LOW(1)
_0x202009C:
	SUBI R20,LOW(1)
	RJMP _0x2020097
_0x2020099:
	MOV  R19,R17
	LDD  R30,Y+20
	CPI  R30,0
	BRNE _0x202009D
_0x202009E:
	CPI  R19,0
	BREQ _0x20200A0
	SBRS R16,3
	RJMP _0x20200A1
	LDD  R30,Y+14
	LDD  R31,Y+14+1
	LPM  R18,Z+
	STD  Y+14,R30
	STD  Y+14+1,R31
	RJMP _0x20200A2
_0x20200A1:
	LDD  R26,Y+14
	LDD  R27,Y+14+1
	LD   R18,X+
	STD  Y+14,R26
	STD  Y+14+1,R27
_0x20200A2:
	ST   -Y,R18
	LDD  R26,Y+7
	LDD  R27,Y+7+1
	LDD  R30,Y+9
	LDD  R31,Y+9+1
	ICALL
	CPI  R21,0
	BREQ _0x20200A3
	SUBI R21,LOW(1)
_0x20200A3:
	SUBI R19,LOW(1)
	RJMP _0x202009E
_0x20200A0:
	RJMP _0x20200A4
_0x202009D:
_0x20200A6:
	__GETD1S 16
	__GETD2S 10
	CALL __DIVD21U
	MOV  R18,R30
	CPI  R18,10
	BRLO _0x20200A8
	SBRS R16,3
	RJMP _0x20200A9
	SUBI R18,-LOW(55)
	RJMP _0x20200AA
_0x20200A9:
	SUBI R18,-LOW(87)
_0x20200AA:
	RJMP _0x20200AB
_0x20200A8:
	SUBI R18,-LOW(48)
_0x20200AB:
	SBRC R16,4
	RJMP _0x20200AD
	CPI  R18,49
	BRSH _0x20200AF
	__GETD2S 16
	__CPD2N 0x1
	BRNE _0x20200AE
_0x20200AF:
	RJMP _0x20200B1
_0x20200AE:
	CP   R20,R19
	BRSH _0x202011C
	CP   R21,R19
	BRLO _0x20200B4
	SBRS R16,0
	RJMP _0x20200B5
_0x20200B4:
	RJMP _0x20200B3
_0x20200B5:
	LDI  R18,LOW(32)
	SBRS R16,7
	RJMP _0x20200B6
_0x202011C:
	LDI  R18,LOW(48)
_0x20200B1:
	ORI  R16,LOW(16)
	SBRS R16,2
	RJMP _0x20200B7
	ANDI R16,LOW(251)
	LDD  R30,Y+21
	ST   -Y,R30
	__GETW2SX 87
	__GETW1SX 89
	ICALL
	CPI  R21,0
	BREQ _0x20200B8
	SUBI R21,LOW(1)
_0x20200B8:
_0x20200B7:
_0x20200B6:
_0x20200AD:
	ST   -Y,R18
	LDD  R26,Y+7
	LDD  R27,Y+7+1
	LDD  R30,Y+9
	LDD  R31,Y+9+1
	ICALL
	CPI  R21,0
	BREQ _0x20200B9
	SUBI R21,LOW(1)
_0x20200B9:
_0x20200B3:
	SUBI R19,LOW(1)
	__GETD1S 16
	__GETD2S 10
	CALL __MODD21U
	__PUTD1S 10
	LDD  R30,Y+20
	__GETD2S 16
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __DIVD21U
	__PUTD1S 16
	CALL __CPD10
	BREQ _0x20200A7
	RJMP _0x20200A6
_0x20200A7:
_0x20200A4:
	SBRS R16,0
	RJMP _0x20200BA
_0x20200BB:
	CPI  R21,0
	BREQ _0x20200BD
	SUBI R21,LOW(1)
	LDI  R30,LOW(32)
	ST   -Y,R30
	LDD  R26,Y+7
	LDD  R27,Y+7+1
	LDD  R30,Y+9
	LDD  R31,Y+9+1
	ICALL
	RJMP _0x20200BB
_0x20200BD:
_0x20200BA:
_0x20200BE:
_0x202005A:
_0x202011A:
	LDI  R17,LOW(0)
_0x202003B:
	RJMP _0x2020036
_0x2020038:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	CALL __GETW1P
	CALL __LOADLOCR6
	ADIW R28,63
	ADIW R28,31
	RET
; .FEND
_sprintf:
; .FSTART _sprintf
	PUSH R15
	MOV  R15,R24
	SBIW R28,6
	CALL __SAVELOCR4
	MOVW R26,R28
	ADIW R26,12
	CALL __ADDW2R15
	CALL __GETW1P
	SBIW R30,0
	BRNE _0x20200BF
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x20C0008
_0x20200BF:
	MOVW R26,R28
	ADIW R26,6
	CALL __ADDW2R15
	MOVW R16,R26
	MOVW R26,R28
	ADIW R26,12
	CALL __ADDW2R15
	CALL __GETW1P
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDI  R30,LOW(0)
	STD  Y+8,R30
	STD  Y+8+1,R30
	MOVW R26,R28
	ADIW R26,10
	CALL __ADDW2R15
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	ST   -Y,R17
	ST   -Y,R16
	LDI  R30,LOW(_put_buff_G101)
	LDI  R31,HIGH(_put_buff_G101)
	ST   -Y,R31
	ST   -Y,R30
	MOVW R26,R28
	ADIW R26,10
	RCALL __print_G101
	MOVW R18,R30
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(0)
	ST   X,R30
	MOVW R30,R18
_0x20C0008:
	CALL __LOADLOCR4
	ADIW R28,10
	POP  R15
	RET
; .FEND

	.CSEG
_ftoa:
; .FSTART _ftoa
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,4
	LDI  R30,LOW(0)
	ST   Y,R30
	STD  Y+1,R30
	STD  Y+2,R30
	LDI  R30,LOW(63)
	STD  Y+3,R30
	ST   -Y,R17
	ST   -Y,R16
	LDD  R30,Y+11
	LDD  R31,Y+11+1
	CPI  R30,LOW(0xFFFF)
	LDI  R26,HIGH(0xFFFF)
	CPC  R31,R26
	BRNE _0x204000D
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ST   -Y,R31
	ST   -Y,R30
	__POINTW2FN _0x2040000,0
	CALL _strcpyf
	RJMP _0x20C0007
_0x204000D:
	CPI  R30,LOW(0x7FFF)
	LDI  R26,HIGH(0x7FFF)
	CPC  R31,R26
	BRNE _0x204000C
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ST   -Y,R31
	ST   -Y,R30
	__POINTW2FN _0x2040000,1
	CALL _strcpyf
	RJMP _0x20C0007
_0x204000C:
	LDD  R26,Y+12
	TST  R26
	BRPL _0x204000F
	__GETD1S 9
	CALL __ANEGF1
	__PUTD1S 9
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADIW R26,1
	STD  Y+6,R26
	STD  Y+6+1,R27
	SBIW R26,1
	LDI  R30,LOW(45)
	ST   X,R30
_0x204000F:
	LDD  R26,Y+8
	CPI  R26,LOW(0x7)
	BRLO _0x2040010
	LDI  R30,LOW(6)
	STD  Y+8,R30
_0x2040010:
	LDD  R17,Y+8
_0x2040011:
	MOV  R30,R17
	SUBI R17,1
	CPI  R30,0
	BREQ _0x2040013
	__GETD2S 2
	__GETD1N 0x3DCCCCCD
	CALL __MULF12
	__PUTD1S 2
	RJMP _0x2040011
_0x2040013:
	__GETD1S 2
	__GETD2S 9
	CALL __ADDF12
	__PUTD1S 9
	LDI  R17,LOW(0)
	__GETD1N 0x3F800000
	__PUTD1S 2
_0x2040014:
	__GETD1S 2
	__GETD2S 9
	CALL __CMPF12
	BRLO _0x2040016
	__GETD2S 2
	__GETD1N 0x41200000
	CALL __MULF12
	__PUTD1S 2
	SUBI R17,-LOW(1)
	CPI  R17,39
	BRLO _0x2040017
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ST   -Y,R31
	ST   -Y,R30
	__POINTW2FN _0x2040000,5
	CALL _strcpyf
	RJMP _0x20C0007
_0x2040017:
	RJMP _0x2040014
_0x2040016:
	CPI  R17,0
	BRNE _0x2040018
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADIW R26,1
	STD  Y+6,R26
	STD  Y+6+1,R27
	SBIW R26,1
	LDI  R30,LOW(48)
	ST   X,R30
	RJMP _0x2040019
_0x2040018:
_0x204001A:
	MOV  R30,R17
	SUBI R17,1
	CPI  R30,0
	BRNE PC+2
	RJMP _0x204001C
	__GETD2S 2
	__GETD1N 0x3DCCCCCD
	CALL __MULF12
	__GETD2N 0x3F000000
	CALL __ADDF12
	MOVW R26,R30
	MOVW R24,R22
	CALL _floor
	__PUTD1S 2
	__GETD2S 9
	CALL __DIVF21
	CALL __CFD1U
	MOV  R16,R30
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADIW R26,1
	STD  Y+6,R26
	STD  Y+6+1,R27
	SBIW R26,1
	SUBI R30,-LOW(48)
	ST   X,R30
	MOV  R30,R16
	LDI  R31,0
	__GETD2S 2
	CALL __CWD1
	CALL __CDF1
	CALL __MULF12
	__GETD2S 9
	CALL __SWAPD12
	CALL __SUBF12
	__PUTD1S 9
	RJMP _0x204001A
_0x204001C:
_0x2040019:
	LDD  R30,Y+8
	CPI  R30,0
	BREQ _0x20C0006
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADIW R26,1
	STD  Y+6,R26
	STD  Y+6+1,R27
	SBIW R26,1
	LDI  R30,LOW(46)
	ST   X,R30
_0x204001E:
	LDD  R30,Y+8
	SUBI R30,LOW(1)
	STD  Y+8,R30
	SUBI R30,-LOW(1)
	BREQ _0x2040020
	__GETD2S 9
	__GETD1N 0x41200000
	CALL __MULF12
	__PUTD1S 9
	CALL __CFD1U
	MOV  R16,R30
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADIW R26,1
	STD  Y+6,R26
	STD  Y+6+1,R27
	SBIW R26,1
	SUBI R30,-LOW(48)
	ST   X,R30
	MOV  R30,R16
	LDI  R31,0
	__GETD2S 9
	CALL __CWD1
	CALL __CDF1
	CALL __SWAPD12
	CALL __SUBF12
	__PUTD1S 9
	RJMP _0x204001E
_0x2040020:
_0x20C0006:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(0)
	ST   X,R30
_0x20C0007:
	LDD  R17,Y+1
	LDD  R16,Y+0
	ADIW R28,13
	RET
; .FEND

	.DSEG

	.CSEG
_allocate_block_G102:
; .FSTART _allocate_block_G102
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,2
	CALL __SAVELOCR6
	__GETWRN 16,17,2204
	MOVW R26,R16
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   X+,R30
	ST   X,R31
_0x2040061:
	MOV  R0,R16
	OR   R0,R17
	BREQ _0x2040063
	MOVW R26,R16
	CALL __GETW1P
	ADD  R30,R16
	ADC  R31,R17
	ADIW R30,4
	MOVW R20,R30
	ADIW R26,2
	CALL __GETW1P
	MOVW R18,R30
	SBIW R30,0
	BREQ _0x2040064
	__PUTWSR 18,19,6
	RJMP _0x2040065
_0x2040064:
	LDI  R30,LOW(2304)
	LDI  R31,HIGH(2304)
	STD  Y+6,R30
	STD  Y+6+1,R31
_0x2040065:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	SUB  R26,R20
	SBC  R27,R21
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ADIW R30,4
	CP   R26,R30
	CPC  R27,R31
	BRLO _0x2040066
	MOVW R30,R20
	__PUTW1RNS 16,2
	MOVW R30,R18
	__PUTW1RNS 20,2
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	MOVW R26,R20
	ST   X+,R30
	ST   X,R31
	__ADDWRN 20,21,4
	MOVW R30,R20
	RJMP _0x20C0005
_0x2040066:
	MOVW R16,R18
	RJMP _0x2040061
_0x2040063:
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
_0x20C0005:
	CALL __LOADLOCR6
	ADIW R28,10
	RET
; .FEND
_find_prev_block_G102:
; .FSTART _find_prev_block_G102
	ST   -Y,R27
	ST   -Y,R26
	CALL __SAVELOCR4
	__GETWRN 16,17,2204
_0x2040067:
	MOV  R0,R16
	OR   R0,R17
	BREQ _0x2040069
	MOVW R26,R16
	ADIW R26,2
	CALL __GETW1P
	MOVW R18,R30
	MOVW R26,R30
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	CP   R30,R26
	CPC  R31,R27
	BRNE _0x204006A
	MOVW R30,R16
	RJMP _0x20C0003
_0x204006A:
	MOVW R16,R18
	RJMP _0x2040067
_0x2040069:
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
_0x20C0003:
	CALL __LOADLOCR4
_0x20C0004:
	ADIW R28,6
	RET
; .FEND
_realloc:
; .FSTART _realloc
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,2
	CALL __SAVELOCR6
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	SBIW R30,0
	BREQ _0x204006B
	SBIW R30,4
	MOVW R16,R30
	MOVW R26,R16
	RCALL _find_prev_block_G102
	MOVW R18,R30
	SBIW R30,0
	BREQ _0x204006C
	MOVW R26,R16
	ADIW R26,2
	CALL __GETW1P
	__PUTW1RNS 18,2
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	SBIW R30,0
	BREQ _0x204006D
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	RCALL _allocate_block_G102
	MOVW R20,R30
	SBIW R30,0
	BREQ _0x204006E
	MOVW R26,R16
	CALL __GETW1P
	STD  Y+6,R30
	STD  Y+6+1,R31
	MOVW R26,R30
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	CP   R26,R30
	CPC  R27,R31
	BRSH _0x204006F
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	STD  Y+8,R30
	STD  Y+8+1,R31
_0x204006F:
	ST   -Y,R21
	ST   -Y,R20
	LDD  R30,Y+12
	LDD  R31,Y+12+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R26,Y+12
	LDD  R27,Y+12+1
	CALL _memmove
	MOVW R30,R20
	RJMP _0x20C0002
_0x204006E:
	MOVW R30,R16
	__PUTW1RNS 18,2
_0x204006D:
_0x204006C:
_0x204006B:
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
_0x20C0002:
	CALL __LOADLOCR6
	ADIW R28,12
	RET
; .FEND
_malloc:
; .FSTART _malloc
	ST   -Y,R27
	ST   -Y,R26
	ST   -Y,R17
	ST   -Y,R16
	__GETWRN 16,17,0
	LDD  R30,Y+2
	LDD  R31,Y+2+1
	SBIW R30,0
	BREQ _0x2040070
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	RCALL _allocate_block_G102
	MOVW R16,R30
	SBIW R30,0
	BREQ _0x2040071
	ST   -Y,R17
	ST   -Y,R16
	LDI  R30,LOW(0)
	ST   -Y,R30
	LDD  R26,Y+5
	LDD  R27,Y+5+1
	CALL _memset
_0x2040071:
_0x2040070:
	MOVW R30,R16
	LDD  R17,Y+1
	LDD  R16,Y+0
	JMP  _0x20C0001
; .FEND
_free:
; .FSTART _free
	ST   -Y,R27
	ST   -Y,R26
	LD   R30,Y
	LDD  R31,Y+1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(0)
	LDI  R27,0
	RCALL _realloc
	ADIW R28,2
	RET
; .FEND
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x01
	.EQU __sm_mask=0x0E
	.EQU __sm_adc_noise_red=0x02
	.EQU __sm_powerdown=0x04
	.EQU __sm_powersave=0x06
	.EQU __sm_standby=0x0C
	.EQU __sm_ext_standby=0x0E
	.SET power_ctrl_reg=smcr
	#endif

	.CSEG

	.CSEG

	.CSEG
_ftrunc:
; .FSTART _ftrunc
	CALL __PUTPARD2
   ldd  r23,y+3
   ldd  r22,y+2
   ldd  r31,y+1
   ld   r30,y
   bst  r23,7
   lsl  r23
   sbrc r22,7
   sbr  r23,1
   mov  r25,r23
   subi r25,0x7e
   breq __ftrunc0
   brcs __ftrunc0
   cpi  r25,24
   brsh __ftrunc1
   clr  r26
   clr  r27
   clr  r24
__ftrunc2:
   sec
   ror  r24
   ror  r27
   ror  r26
   dec  r25
   brne __ftrunc2
   and  r30,r26
   and  r31,r27
   and  r22,r24
   rjmp __ftrunc1
__ftrunc0:
   clt
   clr  r23
   clr  r30
   clr  r31
   clr  r22
__ftrunc1:
   cbr  r22,0x80
   lsr  r23
   brcc __ftrunc3
   sbr  r22,0x80
__ftrunc3:
   bld  r23,7
   ld   r26,y+
   ld   r27,y+
   ld   r24,y+
   ld   r25,y+
   cp   r30,r26
   cpc  r31,r27
   cpc  r22,r24
   cpc  r23,r25
   bst  r25,7
   ret
; .FEND
_floor:
; .FSTART _floor
	CALL __PUTPARD2
	CALL __GETD2S0
	CALL _ftrunc
	CALL __PUTD1S0
    brne __floor1
__floor0:
	CALL __GETD1S0
	RJMP _0x20C0001
__floor1:
    brtc __floor0
	CALL __GETD1S0
	__GETD2N 0x3F800000
	CALL __SUBF12
_0x20C0001:
	ADIW R28,4
	RET
; .FEND

	.DSEG
_terror:
	.BYTE 0x20
_Stat_G000:
	.BYTE 0x1
_Timer1_G000:
	.BYTE 0x1
_Timer2_G000:
	.BYTE 0x1
_CardType_G000:
	.BYTE 0x1
_twiBuf_G000:
	.BYTE 0x8
_twiState_G000:
	.BYTE 0x1
_twiMsgSize_G000:
	.BYTE 0x1
_pre:
	.BYTE 0x4
_ptr_S000002F000:
	.BYTE 0x1
_FatFs_G000:
	.BYTE 0x2
_Fsid_G000:
	.BYTE 0x2
_g_FileInfo:
	.BYTE 0xC0
_file:
	.BYTE 0x20
_fn16_str:
	.BYTE 0xD
_rootpath:
	.BYTE 0x20
_audiobuf:
	.BYTE 0x40
_bFileInfoWindow:
	.BYTE 0x1
_bFormatAlert:
	.BYTE 0x1
_bTextReader:
	.BYTE 0x1
_bMusicPlayer:
	.BYTE 0x1
_scroll_index:
	.BYTE 0x2
_state:
	.BYTE 0x2
_bMusicFOpened:
	.BYTE 0x1
_vcc:
	.BYTE 0x2
__seed_G102:
	.BYTE 0x4

	.CSEG

	.CSEG
_delay_ms:
	adiw r26,0
	breq __delay_ms1
__delay_ms0:
	__DELAY_USW 0x7D0
	wdr
	sbiw r26,1
	brne __delay_ms0
__delay_ms1:
	ret

__ANEGF1:
	SBIW R30,0
	SBCI R22,0
	SBCI R23,0
	BREQ __ANEGF10
	SUBI R23,0x80
__ANEGF10:
	RET

__ROUND_REPACK:
	TST  R21
	BRPL __REPACK
	CPI  R21,0x80
	BRNE __ROUND_REPACK0
	SBRS R30,0
	RJMP __REPACK
__ROUND_REPACK0:
	ADIW R30,1
	ADC  R22,R25
	ADC  R23,R25
	BRVS __REPACK1

__REPACK:
	LDI  R21,0x80
	EOR  R21,R23
	BRNE __REPACK0
	PUSH R21
	RJMP __ZERORES
__REPACK0:
	CPI  R21,0xFF
	BREQ __REPACK1
	LSL  R22
	LSL  R0
	ROR  R21
	ROR  R22
	MOV  R23,R21
	RET
__REPACK1:
	PUSH R21
	TST  R0
	BRMI __REPACK2
	RJMP __MAXRES
__REPACK2:
	RJMP __MINRES

__UNPACK:
	LDI  R21,0x80
	MOV  R1,R25
	AND  R1,R21
	LSL  R24
	ROL  R25
	EOR  R25,R21
	LSL  R21
	ROR  R24

__UNPACK1:
	LDI  R21,0x80
	MOV  R0,R23
	AND  R0,R21
	LSL  R22
	ROL  R23
	EOR  R23,R21
	LSL  R21
	ROR  R22
	RET

__CFD1U:
	SET
	RJMP __CFD1U0
__CFD1:
	CLT
__CFD1U0:
	PUSH R21
	RCALL __UNPACK1
	CPI  R23,0x80
	BRLO __CFD10
	CPI  R23,0xFF
	BRCC __CFD10
	RJMP __ZERORES
__CFD10:
	LDI  R21,22
	SUB  R21,R23
	BRPL __CFD11
	NEG  R21
	CPI  R21,8
	BRTC __CFD19
	CPI  R21,9
__CFD19:
	BRLO __CFD17
	SER  R30
	SER  R31
	SER  R22
	LDI  R23,0x7F
	BLD  R23,7
	RJMP __CFD15
__CFD17:
	CLR  R23
	TST  R21
	BREQ __CFD15
__CFD18:
	LSL  R30
	ROL  R31
	ROL  R22
	ROL  R23
	DEC  R21
	BRNE __CFD18
	RJMP __CFD15
__CFD11:
	CLR  R23
__CFD12:
	CPI  R21,8
	BRLO __CFD13
	MOV  R30,R31
	MOV  R31,R22
	MOV  R22,R23
	SUBI R21,8
	RJMP __CFD12
__CFD13:
	TST  R21
	BREQ __CFD15
__CFD14:
	LSR  R23
	ROR  R22
	ROR  R31
	ROR  R30
	DEC  R21
	BRNE __CFD14
__CFD15:
	TST  R0
	BRPL __CFD16
	RCALL __ANEGD1
__CFD16:
	POP  R21
	RET

__CDF1U:
	SET
	RJMP __CDF1U0
__CDF1:
	CLT
__CDF1U0:
	SBIW R30,0
	SBCI R22,0
	SBCI R23,0
	BREQ __CDF10
	CLR  R0
	BRTS __CDF11
	TST  R23
	BRPL __CDF11
	COM  R0
	RCALL __ANEGD1
__CDF11:
	MOV  R1,R23
	LDI  R23,30
	TST  R1
__CDF12:
	BRMI __CDF13
	DEC  R23
	LSL  R30
	ROL  R31
	ROL  R22
	ROL  R1
	RJMP __CDF12
__CDF13:
	MOV  R30,R31
	MOV  R31,R22
	MOV  R22,R1
	PUSH R21
	RCALL __REPACK
	POP  R21
__CDF10:
	RET

__SWAPACC:
	PUSH R20
	MOVW R20,R30
	MOVW R30,R26
	MOVW R26,R20
	MOVW R20,R22
	MOVW R22,R24
	MOVW R24,R20
	MOV  R20,R0
	MOV  R0,R1
	MOV  R1,R20
	POP  R20
	RET

__UADD12:
	ADD  R30,R26
	ADC  R31,R27
	ADC  R22,R24
	RET

__NEGMAN1:
	COM  R30
	COM  R31
	COM  R22
	SUBI R30,-1
	SBCI R31,-1
	SBCI R22,-1
	RET

__SUBF12:
	PUSH R21
	RCALL __UNPACK
	CPI  R25,0x80
	BREQ __ADDF129
	LDI  R21,0x80
	EOR  R1,R21

	RJMP __ADDF120

__ADDF12:
	PUSH R21
	RCALL __UNPACK
	CPI  R25,0x80
	BREQ __ADDF129

__ADDF120:
	CPI  R23,0x80
	BREQ __ADDF128
__ADDF121:
	MOV  R21,R23
	SUB  R21,R25
	BRVS __ADDF1211
	BRPL __ADDF122
	RCALL __SWAPACC
	RJMP __ADDF121
__ADDF122:
	CPI  R21,24
	BRLO __ADDF123
	CLR  R26
	CLR  R27
	CLR  R24
__ADDF123:
	CPI  R21,8
	BRLO __ADDF124
	MOV  R26,R27
	MOV  R27,R24
	CLR  R24
	SUBI R21,8
	RJMP __ADDF123
__ADDF124:
	TST  R21
	BREQ __ADDF126
__ADDF125:
	LSR  R24
	ROR  R27
	ROR  R26
	DEC  R21
	BRNE __ADDF125
__ADDF126:
	MOV  R21,R0
	EOR  R21,R1
	BRMI __ADDF127
	RCALL __UADD12
	BRCC __ADDF129
	ROR  R22
	ROR  R31
	ROR  R30
	INC  R23
	BRVC __ADDF129
	RJMP __MAXRES
__ADDF128:
	RCALL __SWAPACC
__ADDF129:
	RCALL __REPACK
	POP  R21
	RET
__ADDF1211:
	BRCC __ADDF128
	RJMP __ADDF129
__ADDF127:
	SUB  R30,R26
	SBC  R31,R27
	SBC  R22,R24
	BREQ __ZERORES
	BRCC __ADDF1210
	COM  R0
	RCALL __NEGMAN1
__ADDF1210:
	TST  R22
	BRMI __ADDF129
	LSL  R30
	ROL  R31
	ROL  R22
	DEC  R23
	BRVC __ADDF1210

__ZERORES:
	CLR  R30
	CLR  R31
	CLR  R22
	CLR  R23
	POP  R21
	RET

__MINRES:
	SER  R30
	SER  R31
	LDI  R22,0x7F
	SER  R23
	POP  R21
	RET

__MAXRES:
	SER  R30
	SER  R31
	LDI  R22,0x7F
	LDI  R23,0x7F
	POP  R21
	RET

__MULF12:
	PUSH R21
	RCALL __UNPACK
	CPI  R23,0x80
	BREQ __ZERORES
	CPI  R25,0x80
	BREQ __ZERORES
	EOR  R0,R1
	SEC
	ADC  R23,R25
	BRVC __MULF124
	BRLT __ZERORES
__MULF125:
	TST  R0
	BRMI __MINRES
	RJMP __MAXRES
__MULF124:
	PUSH R0
	PUSH R17
	PUSH R18
	PUSH R19
	PUSH R20
	CLR  R17
	CLR  R18
	CLR  R25
	MUL  R22,R24
	MOVW R20,R0
	MUL  R24,R31
	MOV  R19,R0
	ADD  R20,R1
	ADC  R21,R25
	MUL  R22,R27
	ADD  R19,R0
	ADC  R20,R1
	ADC  R21,R25
	MUL  R24,R30
	RCALL __MULF126
	MUL  R27,R31
	RCALL __MULF126
	MUL  R22,R26
	RCALL __MULF126
	MUL  R27,R30
	RCALL __MULF127
	MUL  R26,R31
	RCALL __MULF127
	MUL  R26,R30
	ADD  R17,R1
	ADC  R18,R25
	ADC  R19,R25
	ADC  R20,R25
	ADC  R21,R25
	MOV  R30,R19
	MOV  R31,R20
	MOV  R22,R21
	MOV  R21,R18
	POP  R20
	POP  R19
	POP  R18
	POP  R17
	POP  R0
	TST  R22
	BRMI __MULF122
	LSL  R21
	ROL  R30
	ROL  R31
	ROL  R22
	RJMP __MULF123
__MULF122:
	INC  R23
	BRVS __MULF125
__MULF123:
	RCALL __ROUND_REPACK
	POP  R21
	RET

__MULF127:
	ADD  R17,R0
	ADC  R18,R1
	ADC  R19,R25
	RJMP __MULF128
__MULF126:
	ADD  R18,R0
	ADC  R19,R1
__MULF128:
	ADC  R20,R25
	ADC  R21,R25
	RET

__DIVF21:
	PUSH R21
	RCALL __UNPACK
	CPI  R23,0x80
	BRNE __DIVF210
	TST  R1
__DIVF211:
	BRPL __DIVF219
	RJMP __MINRES
__DIVF219:
	RJMP __MAXRES
__DIVF210:
	CPI  R25,0x80
	BRNE __DIVF218
__DIVF217:
	RJMP __ZERORES
__DIVF218:
	EOR  R0,R1
	SEC
	SBC  R25,R23
	BRVC __DIVF216
	BRLT __DIVF217
	TST  R0
	RJMP __DIVF211
__DIVF216:
	MOV  R23,R25
	PUSH R17
	PUSH R18
	PUSH R19
	PUSH R20
	CLR  R1
	CLR  R17
	CLR  R18
	CLR  R19
	CLR  R20
	CLR  R21
	LDI  R25,32
__DIVF212:
	CP   R26,R30
	CPC  R27,R31
	CPC  R24,R22
	CPC  R20,R17
	BRLO __DIVF213
	SUB  R26,R30
	SBC  R27,R31
	SBC  R24,R22
	SBC  R20,R17
	SEC
	RJMP __DIVF214
__DIVF213:
	CLC
__DIVF214:
	ROL  R21
	ROL  R18
	ROL  R19
	ROL  R1
	ROL  R26
	ROL  R27
	ROL  R24
	ROL  R20
	DEC  R25
	BRNE __DIVF212
	MOVW R30,R18
	MOV  R22,R1
	POP  R20
	POP  R19
	POP  R18
	POP  R17
	TST  R22
	BRMI __DIVF215
	LSL  R21
	ROL  R30
	ROL  R31
	ROL  R22
	DEC  R23
	BRVS __DIVF217
__DIVF215:
	RCALL __ROUND_REPACK
	POP  R21
	RET

__CMPF12:
	TST  R25
	BRMI __CMPF120
	TST  R23
	BRMI __CMPF121
	CP   R25,R23
	BRLO __CMPF122
	BRNE __CMPF121
	CP   R26,R30
	CPC  R27,R31
	CPC  R24,R22
	BRLO __CMPF122
	BREQ __CMPF123
__CMPF121:
	CLZ
	CLC
	RET
__CMPF122:
	CLZ
	SEC
	RET
__CMPF123:
	SEZ
	CLC
	RET
__CMPF120:
	TST  R23
	BRPL __CMPF122
	CP   R25,R23
	BRLO __CMPF121
	BRNE __CMPF122
	CP   R30,R26
	CPC  R31,R27
	CPC  R22,R24
	BRLO __CMPF122
	BREQ __CMPF123
	RJMP __CMPF121

__ADDW2R15:
	CLR  R0
	ADD  R26,R15
	ADC  R27,R0
	RET

__ADDD12:
	ADD  R30,R26
	ADC  R31,R27
	ADC  R22,R24
	ADC  R23,R25
	RET

__ADDD21:
	ADD  R26,R30
	ADC  R27,R31
	ADC  R24,R22
	ADC  R25,R23
	RET

__SUBD12:
	SUB  R30,R26
	SBC  R31,R27
	SBC  R22,R24
	SBC  R23,R25
	RET

__SUBD21:
	SUB  R26,R30
	SBC  R27,R31
	SBC  R24,R22
	SBC  R25,R23
	RET

__ANDD12:
	AND  R30,R26
	AND  R31,R27
	AND  R22,R24
	AND  R23,R25
	RET

__ORD12:
	OR   R30,R26
	OR   R31,R27
	OR   R22,R24
	OR   R23,R25
	RET

__ANEGW1:
	NEG  R31
	NEG  R30
	SBCI R31,0
	RET

__ANEGD1:
	COM  R31
	COM  R22
	COM  R23
	NEG  R30
	SBCI R31,-1
	SBCI R22,-1
	SBCI R23,-1
	RET

__LSLW12:
	TST  R30
	MOV  R0,R30
	MOVW R30,R26
	BREQ __LSLW12R
__LSLW12L:
	LSL  R30
	ROL  R31
	DEC  R0
	BRNE __LSLW12L
__LSLW12R:
	RET

__ASRW12:
	TST  R30
	MOV  R0,R30
	MOVW R30,R26
	BREQ __ASRW12R
__ASRW12L:
	ASR  R31
	ROR  R30
	DEC  R0
	BRNE __ASRW12L
__ASRW12R:
	RET

__LSLD12:
	TST  R30
	MOV  R0,R30
	MOVW R30,R26
	MOVW R22,R24
	BREQ __LSLD12R
__LSLD12L:
	LSL  R30
	ROL  R31
	ROL  R22
	ROL  R23
	DEC  R0
	BRNE __LSLD12L
__LSLD12R:
	RET

__LSRD12:
	TST  R30
	MOV  R0,R30
	MOVW R30,R26
	MOVW R22,R24
	BREQ __LSRD12R
__LSRD12L:
	LSR  R23
	ROR  R22
	ROR  R31
	ROR  R30
	DEC  R0
	BRNE __LSRD12L
__LSRD12R:
	RET

__LSLW4:
	LSL  R30
	ROL  R31
__LSLW3:
	LSL  R30
	ROL  R31
__LSLW2:
	LSL  R30
	ROL  R31
	LSL  R30
	ROL  R31
	RET

__ASRW4:
	ASR  R31
	ROR  R30
__ASRW3:
	ASR  R31
	ROR  R30
__ASRW2:
	ASR  R31
	ROR  R30
	ASR  R31
	ROR  R30
	RET

__LSRW4:
	LSR  R31
	ROR  R30
__LSRW3:
	LSR  R31
	ROR  R30
__LSRW2:
	LSR  R31
	ROR  R30
	LSR  R31
	ROR  R30
	RET

__LSRD1:
	LSR  R23
	ROR  R22
	ROR  R31
	ROR  R30
	RET

__ASRW8:
	MOV  R30,R31
	CLR  R31
	SBRC R30,7
	SER  R31
	RET

__LSRD16:
	MOV  R30,R22
	MOV  R31,R23
	LDI  R22,0
	LDI  R23,0
	RET

__LSLD16:
	MOV  R22,R30
	MOV  R23,R31
	LDI  R30,0
	LDI  R31,0
	RET

__CBD1:
	MOV  R31,R30
	ADD  R31,R31
	SBC  R31,R31
	MOV  R22,R31
	MOV  R23,R31
	RET

__CWD1:
	MOV  R22,R31
	ADD  R22,R22
	SBC  R22,R22
	MOV  R23,R22
	RET

__COMD1:
	COM  R30
	COM  R31
	COM  R22
	COM  R23
	RET

__EQB12:
	CP   R30,R26
	LDI  R30,1
	BREQ __EQB12T
	CLR  R30
__EQB12T:
	RET

__MULW12U:
	MUL  R31,R26
	MOV  R31,R0
	MUL  R30,R27
	ADD  R31,R0
	MUL  R30,R26
	MOV  R30,R0
	ADD  R31,R1
	RET

__MULD12U:
	MUL  R23,R26
	MOV  R23,R0
	MUL  R22,R27
	ADD  R23,R0
	MUL  R31,R24
	ADD  R23,R0
	MUL  R30,R25
	ADD  R23,R0
	MUL  R22,R26
	MOV  R22,R0
	ADD  R23,R1
	MUL  R31,R27
	ADD  R22,R0
	ADC  R23,R1
	MUL  R30,R24
	ADD  R22,R0
	ADC  R23,R1
	CLR  R24
	MUL  R31,R26
	MOV  R31,R0
	ADD  R22,R1
	ADC  R23,R24
	MUL  R30,R27
	ADD  R31,R0
	ADC  R22,R1
	ADC  R23,R24
	MUL  R30,R26
	MOV  R30,R0
	ADD  R31,R1
	ADC  R22,R24
	ADC  R23,R24
	RET

__MULB1W2U:
	MOV  R22,R30
	MUL  R22,R26
	MOVW R30,R0
	MUL  R22,R27
	ADD  R31,R0
	RET

__MULW12:
	RCALL __CHKSIGNW
	RCALL __MULW12U
	BRTC __MULW121
	RCALL __ANEGW1
__MULW121:
	RET

__DIVB21U:
	CLR  R0
	LDI  R25,8
__DIVB21U1:
	LSL  R26
	ROL  R0
	SUB  R0,R30
	BRCC __DIVB21U2
	ADD  R0,R30
	RJMP __DIVB21U3
__DIVB21U2:
	SBR  R26,1
__DIVB21U3:
	DEC  R25
	BRNE __DIVB21U1
	MOV  R30,R26
	MOV  R26,R0
	RET

__DIVB21:
	RCALL __CHKSIGNB
	RCALL __DIVB21U
	BRTC __DIVB211
	NEG  R30
__DIVB211:
	RET

__DIVW21U:
	CLR  R0
	CLR  R1
	LDI  R25,16
__DIVW21U1:
	LSL  R26
	ROL  R27
	ROL  R0
	ROL  R1
	SUB  R0,R30
	SBC  R1,R31
	BRCC __DIVW21U2
	ADD  R0,R30
	ADC  R1,R31
	RJMP __DIVW21U3
__DIVW21U2:
	SBR  R26,1
__DIVW21U3:
	DEC  R25
	BRNE __DIVW21U1
	MOVW R30,R26
	MOVW R26,R0
	RET

__DIVW21:
	RCALL __CHKSIGNW
	RCALL __DIVW21U
	BRTC __DIVW211
	RCALL __ANEGW1
__DIVW211:
	RET

__DIVD21U:
	PUSH R19
	PUSH R20
	PUSH R21
	CLR  R0
	CLR  R1
	CLR  R20
	CLR  R21
	LDI  R19,32
__DIVD21U1:
	LSL  R26
	ROL  R27
	ROL  R24
	ROL  R25
	ROL  R0
	ROL  R1
	ROL  R20
	ROL  R21
	SUB  R0,R30
	SBC  R1,R31
	SBC  R20,R22
	SBC  R21,R23
	BRCC __DIVD21U2
	ADD  R0,R30
	ADC  R1,R31
	ADC  R20,R22
	ADC  R21,R23
	RJMP __DIVD21U3
__DIVD21U2:
	SBR  R26,1
__DIVD21U3:
	DEC  R19
	BRNE __DIVD21U1
	MOVW R30,R26
	MOVW R22,R24
	MOVW R26,R0
	MOVW R24,R20
	POP  R21
	POP  R20
	POP  R19
	RET

__DIVD21:
	RCALL __CHKSIGND
	RCALL __DIVD21U
	BRTC __DIVD211
	RCALL __ANEGD1
__DIVD211:
	RET

__MODB21:
	CLT
	SBRS R26,7
	RJMP __MODB211
	NEG  R26
	SET
__MODB211:
	SBRC R30,7
	NEG  R30
	RCALL __DIVB21U
	MOV  R30,R26
	BRTC __MODB212
	NEG  R30
__MODB212:
	RET

__MODD21U:
	RCALL __DIVD21U
	MOVW R30,R26
	MOVW R22,R24
	RET

__CHKSIGNB:
	CLT
	SBRS R30,7
	RJMP __CHKSB1
	NEG  R30
	SET
__CHKSB1:
	SBRS R26,7
	RJMP __CHKSB2
	NEG  R26
	BLD  R0,0
	INC  R0
	BST  R0,0
__CHKSB2:
	RET

__CHKSIGNW:
	CLT
	SBRS R31,7
	RJMP __CHKSW1
	RCALL __ANEGW1
	SET
__CHKSW1:
	SBRS R27,7
	RJMP __CHKSW2
	COM  R26
	COM  R27
	ADIW R26,1
	BLD  R0,0
	INC  R0
	BST  R0,0
__CHKSW2:
	RET

__CHKSIGND:
	CLT
	SBRS R23,7
	RJMP __CHKSD1
	RCALL __ANEGD1
	SET
__CHKSD1:
	SBRS R25,7
	RJMP __CHKSD2
	CLR  R0
	COM  R26
	COM  R27
	COM  R24
	COM  R25
	ADIW R26,1
	ADC  R24,R0
	ADC  R25,R0
	BLD  R0,0
	INC  R0
	BST  R0,0
__CHKSD2:
	RET

__GETW1P:
	LD   R30,X+
	LD   R31,X
	SBIW R26,1
	RET

__GETD1P:
	LD   R30,X+
	LD   R31,X+
	LD   R22,X+
	LD   R23,X
	SBIW R26,3
	RET

__GETD1P_INC:
	LD   R30,X+
	LD   R31,X+
	LD   R22,X+
	LD   R23,X+
	RET

__PUTDP1:
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	RET

__PUTDP1_DEC:
	ST   -X,R23
	ST   -X,R22
	ST   -X,R31
	ST   -X,R30
	RET

__GETD1S0:
	LD   R30,Y
	LDD  R31,Y+1
	LDD  R22,Y+2
	LDD  R23,Y+3
	RET

__GETD2S0:
	LD   R26,Y
	LDD  R27,Y+1
	LDD  R24,Y+2
	LDD  R25,Y+3
	RET

__PUTD1S0:
	ST   Y,R30
	STD  Y+1,R31
	STD  Y+2,R22
	STD  Y+3,R23
	RET

__PUTDZ20:
	ST   Z,R26
	STD  Z+1,R27
	STD  Z+2,R24
	STD  Z+3,R25
	RET

__PUTPARD1:
	ST   -Y,R23
	ST   -Y,R22
	ST   -Y,R31
	ST   -Y,R30
	RET

__PUTPARD2:
	ST   -Y,R25
	ST   -Y,R24
	ST   -Y,R27
	ST   -Y,R26
	RET

__SWAPD12:
	MOV  R1,R24
	MOV  R24,R22
	MOV  R22,R1
	MOV  R1,R25
	MOV  R25,R23
	MOV  R23,R1

__SWAPW12:
	MOV  R1,R27
	MOV  R27,R31
	MOV  R31,R1

__SWAPB12:
	MOV  R1,R26
	MOV  R26,R30
	MOV  R30,R1
	RET

__CPD10:
	SBIW R30,0
	SBCI R22,0
	SBCI R23,0
	RET

__CPW02:
	CLR  R0
	CP   R0,R26
	CPC  R0,R27
	RET

__CPD02:
	CLR  R0
	CP   R0,R26
	CPC  R0,R27
	CPC  R0,R24
	CPC  R0,R25
	RET

__CPD12:
	CP   R30,R26
	CPC  R31,R27
	CPC  R22,R24
	CPC  R23,R25
	RET

__CPD21:
	CP   R26,R30
	CPC  R27,R31
	CPC  R24,R22
	CPC  R25,R23
	RET

__SAVELOCR6:
	ST   -Y,R21
__SAVELOCR5:
	ST   -Y,R20
__SAVELOCR4:
	ST   -Y,R19
__SAVELOCR3:
	ST   -Y,R18
__SAVELOCR2:
	ST   -Y,R17
	ST   -Y,R16
	RET

__LOADLOCR6:
	LDD  R21,Y+5
__LOADLOCR5:
	LDD  R20,Y+4
__LOADLOCR4:
	LDD  R19,Y+3
__LOADLOCR3:
	LDD  R18,Y+2
__LOADLOCR2:
	LDD  R17,Y+1
	LD   R16,Y
	RET

__INITLOCB:
__INITLOCW:
	ADD  R26,R28
	ADC  R27,R29
__INITLOC0:
	LPM  R0,Z+
	ST   X+,R0
	DEC  R24
	BRNE __INITLOC0
	RET

;END OF CODE MARKER
__END_OF_CODE:
