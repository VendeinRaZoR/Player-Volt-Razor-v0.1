
;CodeVisionAVR C Compiler V3.12 Advanced
;(C) Copyright 1998-2014 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com

;Build configuration    : Release
;Chip type              : ATmega328P
;Program type           : Boot Loader
;Clock frequency        : 16,000000 MHz
;Memory model           : Small
;Optimize for           : Size
;(s)printf features     : int, width
;(s)scanf features      : int, width
;External RAM size      : 0
;Data Stack size        : 512 byte(s)
;Heap size              : 0 byte(s)
;Promote 'char' to 'int': No
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
	.EQU __DSTACK_SIZE=0x0200
	.EQU __HEAP_SIZE=0x0000
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
	.DEF _startup_delay_cnt=R5

;GPIOR0 INITIALIZATION VALUE
	.EQU __GPIOR0_INIT=0x00

	.CSEG
	.ORG 0x3C00

;START OF CODE MARKER
__START_OF_CODE:

;INTERRUPT VECTORS
	JMP  __RESET
	JMP  0x3C00
	JMP  0x3C00
	JMP  0x3C00
	JMP  0x3C00
	JMP  0x3C00
	JMP  0x3C00
	JMP  0x3C00
	JMP  0x3C00
	JMP  0x3C00
	JMP  0x3C00
	JMP  0x3C00
	JMP  0x3C00
	JMP  _timer1_ovf_isr
	JMP  0x3C00
	JMP  0x3C00
	JMP  0x3C00
	JMP  0x3C00
	JMP  0x3C00
	JMP  0x3C00
	JMP  0x3C00
	JMP  0x3C00
	JMP  0x3C00
	JMP  0x3C00
	JMP  0x3C00
	JMP  0x3C00

_tbl10_G100:
	.DB  0x10,0x27,0xE8,0x3,0x64,0x0,0xA,0x0
	.DB  0x1,0x0
_tbl16_G100:
	.DB  0x0,0x10,0x0,0x1,0x10,0x0,0x1,0x0

__RESET:
	CLI
	CLR  R30
	OUT  EECR,R30

;INTERRUPT VECTORS ARE PLACED
;AT THE START OF THE BOOT LOADER
	LDI  R31,1
	OUT  MCUCR,R31
	LDI  R31,2
	OUT  MCUCR,R31

;DISABLE WATCHDOG
	LDI  R31,0x18
	WDR
	IN   R26,MCUSR
	CBR  R26,8
	OUT  MCUSR,R26
	STS  WDTCSR,R31
	STS  WDTCSR,R30

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
	.ORG 0x300

	.CSEG
;//******************************************************************************
;// Bootloader based on Atmel application note AVR109 communication protocol
;// Target chips: ATmega168/328
;// Chip clock frequency: 16MHz specified in the project configuration.
;//
;// (C) 2010-2012 Pavel Haiduc, HP InfoTech s.r.l.,
;// All rights reserved
;//
;// Compiler: CodeVisionAVR V2.60+
;// Version: 1.00
;//******************************************************************************
;
;/*
;The bootloader expects to receive the '@' character in the first
;5 seconds after reset and enters the bootloader mode and
;responds with a '\r' character.
;If the above condition is not met, execution starts from address 0.
;
;It can be tested with the included avr109test.exe program.
;*/
;
;#include "defines.h"
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
     #define WR_SPMCR_REG_R22 out 0x37,r22
;#include "flash.h"
;#include <stdio.h>
;
;// Baud rate used for communication with the bootloader
;#define	BAUD_RATE 115200
;// baud rate register value calculation
;#define	BRREG_VALUE	(_MCU_CLOCK_FREQUENCY_/(8*BAUD_RATE)-1)
;
;#define STARTUP_CHAR '@' // character used to start bootloader mode
;#define STARTUP_DELAY 5  // period during which the bootloader expects
;                         // to receive the STARTUP_CHAR character
;                         // to enter bootloader mode
;#define TIMER1_OVF_PERIOD 100 // time period between two timer 1 overflows [ms]
;#define TIMER1_CLK_DIV 64 // value for timer 1 clock division coeficient
;#define TIMER1_CNT_INIT (65536-(_MCU_CLOCK_FREQUENCY_*TIMER1_OVF_PERIOD)/(TIMER1_CLK_DIV*1000))
;
;// BLOCKSIZE should be chosen so that the following holds: BLOCKSIZE*n = PAGESIZE,  where n=1,2,3...
;#define BLOCKSIZE PAGESIZE
;
;unsigned char startup_delay_cnt;
;
;// Timer1 overflow interrupt service routine
;// Occurs every 100 ms
;interrupt [TIM1_OVF] void timer1_ovf_isr(void)
; 0000 002F {

	.CSEG
_timer1_ovf_isr:
; .FSTART _timer1_ovf_isr
	ST   -Y,R30
	IN   R30,SREG
	ST   -Y,R30
; 0000 0030 // Reinitialize Timer1 value
; 0000 0031 TCNT1H=TIMER1_CNT_INIT >> 8;
	CALL SUBOPT_0x0
; 0000 0032 TCNT1L=TIMER1_CNT_INIT & 0xff;
; 0000 0033 // decrement the startup delay counter
; 0000 0034 if (startup_delay_cnt) --startup_delay_cnt;
	TST  R5
	BREQ _0x3
	DEC  R5
; 0000 0035 }
_0x3:
	LD   R30,Y+
	OUT  SREG,R30
	LD   R30,Y+
	RETI
; .FEND
;
;unsigned char BlockLoad(unsigned int size, unsigned char mem, ADDR_t *address);
;void BlockRead(unsigned int size, unsigned char mem, ADDR_t *address);
;
;void main(void)
; 0000 003B {
_main:
; .FSTART _main
; 0000 003C ADDR_t address;
; 0000 003D unsigned int temp_int;
; 0000 003E unsigned char val;
; 0000 003F 
; 0000 0040 // Initialize USART
; 0000 0041 UCSR0A=(0<<RXC0) | (0<<TXC0) | (0<<UDRE0) | (0<<FE0) | (0<<DOR0) | (0<<UPE0) | (1<<U2X0) | (0<<MPCM0);
;	address -> R16,R17
;	temp_int -> R18,R19
;	val -> R21
	LDI  R30,LOW(2)
	STS  192,R30
; 0000 0042 UCSR0B=(0<<RXCIE0) | (0<<TXCIE0) | (0<<UDRIE0) | (1<<RXEN0) | (1<<TXEN0) | (0<<UCSZ02) | (0<<RXB80) | (0<<TXB80);
	LDI  R30,LOW(24)
	STS  193,R30
; 0000 0043 UCSR0C=(0<<UMSEL01) | (0<<UMSEL00) | (0<<UPM01) | (0<<UPM00) | (0<<USBS0) | (1<<UCSZ01) | (1<<UCSZ00) | (0<<UCPOL0);
	LDI  R30,LOW(6)
	STS  194,R30
; 0000 0044 UBRR0H=BRREG_VALUE >> 8;
	LDI  R30,LOW(0)
	STS  197,R30
; 0000 0045 UBRR0L=BRREG_VALUE & 0xFF;
	LDI  R30,LOW(16)
	STS  196,R30
; 0000 0046 
; 0000 0047 // Timer/Counter 1 initialization
; 0000 0048 // Clock source: System Clock
; 0000 0049 // Clock divisor: 64
; 0000 004A // Mode: Normal top=0xFFFF
; 0000 004B // Timer Period: 100 ms
; 0000 004C // Timer1 Overflow Interrupt: On
; 0000 004D TCCR1A=(0<<COM1A1) | (0<<COM1A0) | (0<<COM1B1) | (0<<COM1B0) | (0<<WGM11) | (0<<WGM10);
	LDI  R30,LOW(0)
	STS  128,R30
; 0000 004E TCCR1B=(0<<ICNC1) | (0<<ICES1) | (0<<WGM13) | (0<<WGM12) | (0<<CS12) | (1<<CS11) | (1<<CS10);
	LDI  R30,LOW(3)
	STS  129,R30
; 0000 004F TCNT1H=TIMER1_CNT_INIT >> 8;
	CALL SUBOPT_0x0
; 0000 0050 TCNT1L=TIMER1_CNT_INIT & 0xFF;
; 0000 0051 
; 0000 0052 // Timer/Counter 1 Interrupt(s) initialization
; 0000 0053 TIMSK1=(0<<ICIE1) | (0<<OCIE1B) | (0<<OCIE1A) | (1<<TOIE1);
	LDI  R30,LOW(1)
	STS  111,R30
; 0000 0054 
; 0000 0055 startup_delay_cnt=STARTUP_DELAY*10;
	LDI  R30,LOW(50)
	MOV  R5,R30
; 0000 0056 
; 0000 0057 // Global enable interrupts
; 0000 0058 #asm("sei")
	sei
; 0000 0059 
; 0000 005A // wait to receive the '@' character
; 0000 005B while (startup_delay_cnt)
_0x4:
	TST  R5
	BREQ _0x6
; 0000 005C       {
; 0000 005D       if (UCSR0A & (1<<RXC0))
	LDS  R30,192
	ANDI R30,LOW(0x80)
	BREQ _0x7
; 0000 005E          if (UDR0==STARTUP_CHAR) goto enter_bootloader_mode;
	LDS  R26,198
	CPI  R26,LOW(0x40)
	BREQ _0x9
; 0000 005F       }
_0x7:
	RJMP _0x4
_0x6:
; 0000 0060 
; 0000 0061 // the startup delay elapsed without having received the
; 0000 0062 // STARTUP_CHAR character, so start execution from the application section
; 0000 0063 // stop Timer 1 as it's not needed anymore
; 0000 0064 TCCR1B=(0<<ICNC1) | (0<<ICES1) | (0<<WGM13) | (0<<WGM12) | (0<<CS12) | (0<<CS11) | (0<<CS10);
	CALL SUBOPT_0x1
; 0000 0065 TIMSK1=(0<<ICIE1) | (0<<OCIE1B) | (0<<OCIE1A) | (0<<TOIE1);
; 0000 0066 
; 0000 0067 start_application:
_0xA:
; 0000 0068 // disable interrupts
; 0000 0069 #asm("cli")
	cli
; 0000 006A 
; 0000 006B #pragma optsize-
; 0000 006C // will use the interrupt vectors from the application section
; 0000 006D MCUCR=(1<<IVCE);
	LDI  R30,LOW(1)
	OUT  0x35,R30
; 0000 006E MCUCR=(0<<IVSEL) | (0<<IVCE);
	LDI  R30,LOW(0)
	OUT  0x35,R30
; 0000 006F #ifdef _OPTIMIZE_SIZE_
; 0000 0070 #pragma optsize+
; 0000 0071 #endif
; 0000 0072 
; 0000 0073 // start execution from address 0
; 0000 0074 #asm("jmp 0")
	jmp 0
; 0000 0075 
; 0000 0076 enter_bootloader_mode:
_0x9:
; 0000 0077 // stop Timer 1 as it's not needed anymore
; 0000 0078 TCCR1B=(0<<ICNC1) | (0<<ICES1) | (0<<WGM13) | (0<<WGM12) | (0<<CS12) | (0<<CS11) | (0<<CS10);
	CALL SUBOPT_0x1
; 0000 0079 TIMSK1=(0<<ICIE1) | (0<<OCIE1B) | (0<<OCIE1A) | (0<<TOIE1);
; 0000 007A 
; 0000 007B // send confirmation response
; 0000 007C putchar('\r');
	LDI  R26,LOW(13)
	CALL _putchar
; 0000 007D 
; 0000 007E // main loop
; 0000 007F while (1)
_0xB:
; 0000 0080     {
; 0000 0081         val=getchar(); // Wait for command character.
	CALL _getchar
	MOV  R21,R30
; 0000 0082 
; 0000 0083         // Check autoincrement status.
; 0000 0084         if(val=='a')
	CPI  R21,97
	BRNE _0xE
; 0000 0085         {
; 0000 0086             putchar('Y'); // Yes, we do autoincrement.
	LDI  R26,LOW(89)
	RJMP _0x86
; 0000 0087         }
; 0000 0088 
; 0000 0089 
; 0000 008A         // Set address.
; 0000 008B         else if(val=='A') // Set address...
_0xE:
	CPI  R21,65
	BRNE _0x10
; 0000 008C         { // NOTE: Flash addresses are given in words, not bytes.
; 0000 008D             // Read address high and low byte.
; 0000 008E             ((unsigned char *) &address)[1] = getchar(); // MSB
	CALL _getchar
	MOV  R17,R30
; 0000 008F             ((unsigned char *) &address)[0] = getchar(); // LSB
	CALL _getchar
	MOV  R16,R30
; 0000 0090             putchar('\r'); // Send OK back.
	LDI  R26,LOW(13)
	RJMP _0x86
; 0000 0091         }
; 0000 0092 
; 0000 0093 
; 0000 0094         // Chip erase.
; 0000 0095         else if(val=='e')
_0x10:
	CPI  R21,101
	BRNE _0x12
; 0000 0096         {
; 0000 0097             for(address = 0; address < APP_END;address += PAGESIZE)
	__GETWRN 16,17,0
_0x14:
	__CPWRN 16,17,15360
	BRSH _0x15
; 0000 0098             { // NOTE: Here we use address as a byte-address, not word-address, for convenience.
; 0000 0099                 _WAIT_FOR_SPM();
_0x16:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x16
; 0000 009A                 _PAGE_ERASE( address );
	ST   -Y,R17
	ST   -Y,R16
	LDI  R26,LOW(3)
	CALL ___AddrToZByteToSPMCR_SPM
; 0000 009B             }
	__ADDWRN 16,17,128
	RJMP _0x14
_0x15:
; 0000 009C 
; 0000 009D             putchar('\r'); // Send OK back.
	LDI  R26,LOW(13)
	RJMP _0x86
; 0000 009E         }
; 0000 009F 
; 0000 00A0         // Check block load support.
; 0000 00A1         else if(val=='b')
_0x12:
	CPI  R21,98
	BRNE _0x1A
; 0000 00A2         {
; 0000 00A3             putchar('Y'); // Report block load supported.
	LDI  R26,LOW(89)
	CALL _putchar
; 0000 00A4             putchar((BLOCKSIZE>>8) & 0xFF); // MSB first.
	LDI  R26,LOW(0)
	CALL _putchar
; 0000 00A5             putchar(BLOCKSIZE&0xFF); // Report BLOCKSIZE (bytes).
	LDI  R26,LOW(128)
	RJMP _0x86
; 0000 00A6         }
; 0000 00A7 
; 0000 00A8 
; 0000 00A9         // Start block load.
; 0000 00AA         else if(val=='B')
_0x1A:
	CPI  R21,66
	BRNE _0x1C
; 0000 00AB         {
; 0000 00AC             // Get block size.
; 0000 00AD             ((unsigned char *) &temp_int)[1] = getchar(); // MSB
	CALL SUBOPT_0x2
; 0000 00AE             ((unsigned char *) &temp_int)[0] = getchar(); // LSB
; 0000 00AF             putchar( BlockLoad(temp_int,getchar() /* Get mem. type */,&address) ); // Block load.
	IN   R26,SPL
	IN   R27,SPH
	SBIW R26,1
	PUSH R17
	PUSH R16
	RCALL _BlockLoad
	POP  R16
	POP  R17
	MOV  R26,R30
	RJMP _0x86
; 0000 00B0         }
; 0000 00B1 
; 0000 00B2         // Start block read.
; 0000 00B3         else if(val=='g')
_0x1C:
	CPI  R21,103
	BRNE _0x1E
; 0000 00B4         {
; 0000 00B5             // Get block size.
; 0000 00B6             ((unsigned char *) &temp_int)[1] = getchar(); // MSB
	CALL SUBOPT_0x2
; 0000 00B7             ((unsigned char *) &temp_int)[0] = getchar(); // LSB
; 0000 00B8             BlockRead(temp_int,getchar() /* Get mem. type */,&address); // Block read
	IN   R26,SPL
	IN   R27,SPH
	SBIW R26,1
	PUSH R17
	PUSH R16
	RCALL _BlockRead
	POP  R16
	POP  R17
; 0000 00B9         }
; 0000 00BA 
; 0000 00BB         // Read program memory.
; 0000 00BC         else if(val=='R')
	RJMP _0x1F
_0x1E:
	CPI  R21,82
	BRNE _0x20
; 0000 00BD         {
; 0000 00BE             // Send high byte, then low byte of flash word.
; 0000 00BF             _WAIT_FOR_SPM();
_0x21:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x21
; 0000 00C0             _ENABLE_RWW_SECTION();
	CALL SUBOPT_0x3
; 0000 00C1             putchar( _LOAD_PROGRAM_MEMORY( (address << 1)+1 ) );
	MOVW R30,R16
	LSL  R30
	ROL  R31
	ADIW R30,1
	LPM  R26,Z
	CALL _putchar
; 0000 00C2             putchar( _LOAD_PROGRAM_MEMORY( (address << 1)+0 ) );
	MOVW R30,R16
	LSL  R30
	ROL  R31
	ADIW R30,0
	LPM  R26,Z
	CALL _putchar
; 0000 00C3 
; 0000 00C4             address++; // Auto-advance to next Flash word.
	__ADDWRN 16,17,1
; 0000 00C5         }
; 0000 00C6 
; 0000 00C7 
; 0000 00C8         // Write program memory, low byte.
; 0000 00C9         else if(val=='c')
	RJMP _0x24
_0x20:
	CPI  R21,99
	BRNE _0x25
; 0000 00CA         { // NOTE: Always use this command before sending high byte.
; 0000 00CB             temp_int=getchar(); // Get low byte for later _FILL_TEMP_WORD.
	CALL _getchar
	MOV  R18,R30
	CLR  R19
; 0000 00CC             putchar('\r'); // Send OK back.
	LDI  R26,LOW(13)
	RJMP _0x86
; 0000 00CD         }
; 0000 00CE 
; 0000 00CF 
; 0000 00D0         // Write program memory, high byte.
; 0000 00D1         else if(val=='C')
_0x25:
	CPI  R21,67
	BRNE _0x27
; 0000 00D2         {
; 0000 00D3             // Get and insert high byte.
; 0000 00D4             ((unsigned char *) &temp_int)[1] = getchar(); // MSB
	CALL _getchar
	MOV  R19,R30
; 0000 00D5             _WAIT_FOR_SPM();
_0x28:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x28
; 0000 00D6             _FILL_TEMP_WORD( (address << 1), temp_int ); // Convert word-address to byte-address and fill.
	MOVW R30,R16
	LSL  R30
	ROL  R31
	ST   -Y,R31
	ST   -Y,R30
	ST   -Y,R19
	ST   -Y,R18
	LDI  R26,LOW(1)
	CALL ___AddrToZWordToR1R0ByteToSPMCR_SPM
; 0000 00D7             address++; // Auto-advance to next Flash word.
	__ADDWRN 16,17,1
; 0000 00D8             putchar('\r'); // Send OK back.
	LDI  R26,LOW(13)
	RJMP _0x86
; 0000 00D9         }
; 0000 00DA 
; 0000 00DB 
; 0000 00DC         // Write page.
; 0000 00DD         else if(val== 'm')
_0x27:
	CPI  R21,109
	BRNE _0x2C
; 0000 00DE         {
; 0000 00DF             if( address >= (APP_END>>1) ) // Protect bootloader area.
	__CPWRN 16,17,7680
	BRLO _0x2D
; 0000 00E0             {
; 0000 00E1                 putchar('?');
	LDI  R26,LOW(63)
	CALL _putchar
; 0000 00E2             }
; 0000 00E3             else
	RJMP _0x2E
_0x2D:
; 0000 00E4             {
; 0000 00E5                 _WAIT_FOR_SPM();
_0x2F:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x2F
; 0000 00E6                 _PAGE_WRITE( address << 1 ); // Convert word-address to byte-address and write.
	MOVW R30,R16
	LSL  R30
	ROL  R31
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(5)
	CALL ___AddrToZByteToSPMCR_SPM
; 0000 00E7             }
_0x2E:
; 0000 00E8 
; 0000 00E9             putchar('\r'); // Send OK back.
	LDI  R26,LOW(13)
	RJMP _0x86
; 0000 00EA         }
; 0000 00EB 
; 0000 00EC         // Write EEPROM memory.
; 0000 00ED         else if (val == 'D')
_0x2C:
	CPI  R21,68
	BRNE _0x33
; 0000 00EE         {
; 0000 00EF             _WAIT_FOR_SPM();
_0x34:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x34
; 0000 00F0             *((eeprom unsigned char *) address) = getchar(); // Write received byte.
	CALL _getchar
	MOVW R26,R16
	CALL __EEPROMWRB
; 0000 00F1             address++; // Auto-advance to next EEPROM byte.
	__ADDWRN 16,17,1
; 0000 00F2             putchar('\r');// Send OK back.
	LDI  R26,LOW(13)
	RJMP _0x86
; 0000 00F3         }
; 0000 00F4 
; 0000 00F5 
; 0000 00F6         // Read EEPROM memory.
; 0000 00F7         else if (val == 'd')
_0x33:
	CPI  R21,100
	BRNE _0x38
; 0000 00F8         {
; 0000 00F9             putchar(*((eeprom unsigned char *) address)); // Read byte send it back.
	MOVW R26,R16
	CALL __EEPROMRDB
	MOV  R26,R30
	CALL _putchar
; 0000 00FA             address++; // Auto-advance to next EEPROM byte.
	__ADDWRN 16,17,1
; 0000 00FB         }
; 0000 00FC 
; 0000 00FD         // Write lockbits.
; 0000 00FE         else if(val=='l')
	RJMP _0x39
_0x38:
	CPI  R21,108
	BRNE _0x3A
; 0000 00FF         {
; 0000 0100             _WAIT_FOR_SPM();
_0x3B:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x3B
; 0000 0101             _SET_LOCK_BITS( getchar() ); // Read and set lock bits.
	CALL _getchar
	ST   -Y,R30
	LDI  R26,LOW(9)
	CALL ___DataToR0ByteToSPMCR_SPM
; 0000 0102             putchar('\r'); // Send OK back.
	LDI  R26,LOW(13)
	RJMP _0x86
; 0000 0103         }
; 0000 0104 
; 0000 0105 
; 0000 0106         // Read lock bits.
; 0000 0107         else if(val=='r')
_0x3A:
	CPI  R21,114
	BRNE _0x3F
; 0000 0108         {
; 0000 0109             _WAIT_FOR_SPM();
_0x40:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x40
; 0000 010A             putchar( _GET_LOCK_BITS() );
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	CALL SUBOPT_0x4
	RJMP _0x86
; 0000 010B         }
; 0000 010C 
; 0000 010D 
; 0000 010E         // Read fuse bits.
; 0000 010F         else if(val=='F')
_0x3F:
	CPI  R21,70
	BRNE _0x44
; 0000 0110         {
; 0000 0111             _WAIT_FOR_SPM();
_0x45:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x45
; 0000 0112             putchar( _GET_LOW_FUSES() );
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	CALL SUBOPT_0x4
	RJMP _0x86
; 0000 0113         }
; 0000 0114 
; 0000 0115 
; 0000 0116         // Read high fuse bits.
; 0000 0117         else if(val=='N')
_0x44:
	CPI  R21,78
	BRNE _0x49
; 0000 0118         {
; 0000 0119             _WAIT_FOR_SPM();
_0x4A:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x4A
; 0000 011A             putchar( _GET_HIGH_FUSES() );
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	CALL SUBOPT_0x4
	RJMP _0x86
; 0000 011B         }
; 0000 011C 
; 0000 011D 
; 0000 011E         // Read extended fuse bits.
; 0000 011F         else if(val=='Q')
_0x49:
	CPI  R21,81
	BRNE _0x4E
; 0000 0120         {
; 0000 0121             _WAIT_FOR_SPM();
_0x4F:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x4F
; 0000 0122             putchar( _GET_EXTENDED_FUSES() );
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	CALL SUBOPT_0x4
	RJMP _0x86
; 0000 0123         }
; 0000 0124 
; 0000 0125         // Enter and leave programming mode.
; 0000 0126         else if((val=='P')||(val=='L'))
_0x4E:
	CPI  R21,80
	BREQ _0x54
	CPI  R21,76
	BRNE _0x53
_0x54:
; 0000 0127         {
; 0000 0128             putchar('\r'); // Nothing special to do, just answer OK.
	LDI  R26,LOW(13)
	RJMP _0x86
; 0000 0129         }
; 0000 012A 
; 0000 012B 
; 0000 012C         // Exit bootloader.
; 0000 012D         else if(val=='E')
_0x53:
	CPI  R21,69
	BRNE _0x57
; 0000 012E         {
; 0000 012F             _WAIT_FOR_SPM();
_0x58:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x58
; 0000 0130             _ENABLE_RWW_SECTION();
	CALL SUBOPT_0x3
; 0000 0131             putchar('\r');
	LDI  R26,LOW(13)
	CALL _putchar
; 0000 0132             // Jump to Reset vector 0x0000 in Application Section.
; 0000 0133             goto start_application;
	RJMP _0xA
; 0000 0134         }
; 0000 0135 
; 0000 0136 
; 0000 0137         // Get programmer type.
; 0000 0138         else if (val=='p')
_0x57:
	CPI  R21,112
	BRNE _0x5C
; 0000 0139         {
; 0000 013A             putchar('S'); // Answer 'SERIAL'.
	LDI  R26,LOW(83)
	RJMP _0x86
; 0000 013B         }
; 0000 013C 
; 0000 013D 
; 0000 013E         // Return supported device codes.
; 0000 013F         else if(val=='t')
_0x5C:
	CPI  R21,116
	BRNE _0x5E
; 0000 0140         {
; 0000 0141             putchar( PARTCODE ); // Supports only this device, of course.
	LDI  R26,LOW(68)
	CALL _putchar
; 0000 0142             putchar( 0 ); // Send list terminator.
	LDI  R26,LOW(0)
	RJMP _0x86
; 0000 0143         }
; 0000 0144 
; 0000 0145 
; 0000 0146         // Set LED, clear LED and set device type.
; 0000 0147         else if((val=='x')||(val=='y')||(val=='T'))
_0x5E:
	CPI  R21,120
	BREQ _0x61
	CPI  R21,121
	BREQ _0x61
	CPI  R21,84
	BRNE _0x60
_0x61:
; 0000 0148         {
; 0000 0149             getchar(); // Ignore the command and it's parameter.
	CALL _getchar
; 0000 014A             putchar('\r'); // Send OK back.
	LDI  R26,LOW(13)
	RJMP _0x86
; 0000 014B         }
; 0000 014C 
; 0000 014D         // Return programmer identifier.
; 0000 014E         else if(val=='S')
_0x60:
	CPI  R21,83
	BRNE _0x64
; 0000 014F         {
; 0000 0150             putchar('A'); // Return 'AVRBOOT'.
	LDI  R26,LOW(65)
	CALL _putchar
; 0000 0151             putchar('V'); // Software identifier (aka programmer signature) is always 7 characters.
	LDI  R26,LOW(86)
	CALL _putchar
; 0000 0152             putchar('R');
	LDI  R26,LOW(82)
	CALL _putchar
; 0000 0153             putchar('B');
	LDI  R26,LOW(66)
	CALL _putchar
; 0000 0154             putchar('O');
	LDI  R26,LOW(79)
	CALL _putchar
; 0000 0155             putchar('O');
	LDI  R26,LOW(79)
	CALL _putchar
; 0000 0156             putchar('T');
	LDI  R26,LOW(84)
	RJMP _0x86
; 0000 0157         }
; 0000 0158 
; 0000 0159         // Return software version.
; 0000 015A         else if(val=='V')
_0x64:
	CPI  R21,86
	BRNE _0x66
; 0000 015B         {
; 0000 015C             putchar('1');
	LDI  R26,LOW(49)
	CALL _putchar
; 0000 015D             putchar('0');
	LDI  R26,LOW(48)
	RJMP _0x86
; 0000 015E         }
; 0000 015F 
; 0000 0160         // Return signature bytes.
; 0000 0161         else if(val=='s')
_0x66:
	CPI  R21,115
	BRNE _0x68
; 0000 0162         {
; 0000 0163             putchar( SIGNATURE_BYTE_3 );
	LDI  R26,LOW(15)
	CALL _putchar
; 0000 0164             putchar( SIGNATURE_BYTE_2 );
	LDI  R26,LOW(148)
	CALL _putchar
; 0000 0165             putchar( SIGNATURE_BYTE_1 );
	LDI  R26,LOW(30)
	RJMP _0x86
; 0000 0166         }
; 0000 0167 
; 0000 0168         // The last command to accept is ESC (synchronization).
; 0000 0169         else if(val!=0x1b)                  // If not ESC, then it is unrecognized...
_0x68:
	CPI  R21,27
	BREQ _0x6A
; 0000 016A         {
; 0000 016B             putchar('?');
	LDI  R26,LOW(63)
_0x86:
	CALL _putchar
; 0000 016C         }
; 0000 016D     }
_0x6A:
_0x39:
_0x24:
_0x1F:
	RJMP _0xB
; 0000 016E 
; 0000 016F }
_0x6B:
	RJMP _0x6B
; .FEND
;
;unsigned char BlockLoad(unsigned int size, unsigned char mem, ADDR_t *address)
; 0000 0172 {
_BlockLoad:
; .FSTART _BlockLoad
; 0000 0173 unsigned int data;
; 0000 0174 ADDR_t tempaddress,addr;
; 0000 0175 unsigned char buffer[BLOCKSIZE];
; 0000 0176 
; 0000 0177 addr=*address;
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,63
	SBIW R28,63
	SBIW R28,2
	CALL __SAVELOCR6
;	size -> Y+137
;	mem -> Y+136
;	*address -> Y+134
;	data -> R16,R17
;	tempaddress -> R18,R19
;	addr -> R20,R21
;	buffer -> Y+6
	CALL SUBOPT_0x5
	LD   R20,X+
	LD   R21,X
; 0000 0178 
; 0000 0179 // EEPROM memory type.
; 0000 017A if(mem=='E')
	__GETB2SX 136
	CPI  R26,LOW(0x45)
	BRNE _0x6C
; 0000 017B {
; 0000 017C     /* Fill buffer first, as EEPROM is too slow to copy with UART speed */
; 0000 017D     for(tempaddress=0;tempaddress<size;tempaddress++)
	__GETWRN 18,19,0
_0x6E:
	CALL SUBOPT_0x6
	BRSH _0x6F
; 0000 017E         buffer[tempaddress] = getchar();
	MOVW R30,R18
	MOVW R26,R28
	ADIW R26,6
	ADD  R30,R26
	ADC  R31,R27
	PUSH R31
	PUSH R30
	CALL _getchar
	POP  R26
	POP  R27
	ST   X,R30
	__ADDWRN 18,19,1
	RJMP _0x6E
_0x6F:
; 0000 0180 while( SPMCSR & (1<<0       ) );;
_0x70:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x70
; 0000 0181     /* Then program the EEPROM */
; 0000 0182     for( tempaddress=0; tempaddress < size; tempaddress++)
	__GETWRN 18,19,0
_0x74:
	CALL SUBOPT_0x6
	BRSH _0x75
; 0000 0183     {
; 0000 0184         *((eeprom unsigned char *) addr++) = buffer[tempaddress]; // Write byte.
	PUSH R21
	PUSH R20
	__ADDWRN 20,21,1
	MOVW R26,R28
	ADIW R26,6
	ADD  R26,R18
	ADC  R27,R19
	LD   R30,X
	POP  R26
	POP  R27
	CALL __EEPROMWRB
; 0000 0185     }
	__ADDWRN 18,19,1
	RJMP _0x74
_0x75:
; 0000 0186 
; 0000 0187     *address=addr;
	CALL SUBOPT_0x5
	ST   X+,R20
	ST   X,R21
; 0000 0188     return '\r'; // Report programming OK
	LDI  R30,LOW(13)
	RJMP _0x2060002
; 0000 0189 }
; 0000 018A 
; 0000 018B // Flash memory type.
; 0000 018C if(mem=='F')
_0x6C:
	__GETB2SX 136
	CPI  R26,LOW(0x46)
	BRNE _0x76
; 0000 018D { // NOTE: For flash programming, 'address' is given in words.
; 0000 018E     addr <<= 1; // Convert address to bytes temporarily.
	LSL  R20
	ROL  R21
; 0000 018F     tempaddress = addr;  // Store address in page.
	MOVW R18,R20
; 0000 0190 
; 0000 0191     do
_0x78:
; 0000 0192     {
; 0000 0193         ((unsigned char *) &data)[0] = getchar(); // LSB
	CALL _getchar
	MOV  R16,R30
; 0000 0194         ((unsigned char *) &data)[1] = getchar(); // MSB
	CALL _getchar
	MOV  R17,R30
; 0000 0195         _FILL_TEMP_WORD(addr,data);
	ST   -Y,R21
	ST   -Y,R20
	ST   -Y,R17
	ST   -Y,R16
	LDI  R26,LOW(1)
	CALL ___AddrToZWordToR1R0ByteToSPMCR_SPM
; 0000 0196         addr += 2; // Select next word in memory.
	__ADDWRN 20,21,2
; 0000 0197         size -= 2; // Reduce number of bytes to write by two.
	CALL SUBOPT_0x7
	SBIW R30,2
	__PUTW1SX 137
; 0000 0198     } while(size); // Loop until all bytes written.
	CALL SUBOPT_0x7
	SBIW R30,0
	BRNE _0x78
; 0000 0199 
; 0000 019A     _PAGE_WRITE(tempaddress);
	ST   -Y,R19
	ST   -Y,R18
	LDI  R26,LOW(5)
	CALL ___AddrToZByteToSPMCR_SPM
; 0000 019B     _WAIT_FOR_SPM();
_0x7A:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x7A
; 0000 019C     _ENABLE_RWW_SECTION();
	CALL SUBOPT_0x3
; 0000 019D 
; 0000 019E     addr >>= 1; // Convert address back to Flash words again.
	LSR  R21
	ROR  R20
; 0000 019F     *address=addr;
	CALL SUBOPT_0x5
	ST   X+,R20
	ST   X,R21
; 0000 01A0     return '\r'; // Report programming OK
	LDI  R30,LOW(13)
	RJMP _0x2060002
; 0000 01A1 }
; 0000 01A2 
; 0000 01A3 // Invalid memory type?
; 0000 01A4 return '?';
_0x76:
	LDI  R30,LOW(63)
_0x2060002:
	CALL __LOADLOCR6
	ADIW R28,63
	ADIW R28,63
	ADIW R28,13
	RET
; 0000 01A5 }
; .FEND
;
;
;void BlockRead(unsigned int size, unsigned char mem, ADDR_t *address)
; 0000 01A9 {
_BlockRead:
; .FSTART _BlockRead
; 0000 01AA ADDR_t addr=*address;
; 0000 01AB 
; 0000 01AC // EEPROM memory type.
; 0000 01AD if (mem=='E') // Read EEPROM
	ST   -Y,R27
	ST   -Y,R26
	ST   -Y,R17
	ST   -Y,R16
;	size -> Y+5
;	mem -> Y+4
;	*address -> Y+2
;	addr -> R16,R17
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	CALL __GETW1P
	MOVW R16,R30
	LDD  R26,Y+4
	CPI  R26,LOW(0x45)
	BRNE _0x7D
; 0000 01AE {
; 0000 01AF     do
_0x7F:
; 0000 01B0     {
; 0000 01B1         putchar(*((eeprom unsigned char *) addr++)); // Transmit EEPROM data to PC
	MOVW R26,R16
	__ADDWRN 16,17,1
	CALL __EEPROMRDB
	MOV  R26,R30
	CALL _putchar
; 0000 01B2     } while (--size); // Repeat until all block has been read
	LDD  R30,Y+5
	LDD  R31,Y+5+1
	SBIW R30,1
	STD  Y+5,R30
	STD  Y+5+1,R31
	BRNE _0x7F
; 0000 01B3     *address=addr;
	RJMP _0x87
; 0000 01B4 }
; 0000 01B5 
; 0000 01B6 // Flash memory type.
; 0000 01B7 else if(mem=='F')
_0x7D:
	LDD  R26,Y+4
	CPI  R26,LOW(0x46)
	BRNE _0x82
; 0000 01B8 {
; 0000 01B9     addr <<= 1; // Convert address to bytes temporarily.
	LSL  R16
	ROL  R17
; 0000 01BA 
; 0000 01BB     do
_0x84:
; 0000 01BC     {
; 0000 01BD         putchar( _LOAD_PROGRAM_MEMORY(addr++) );
	CALL SUBOPT_0x8
; 0000 01BE         putchar( _LOAD_PROGRAM_MEMORY(addr++) );
	CALL SUBOPT_0x8
; 0000 01BF         size -= 2; // Subtract two bytes from number of bytes to read
	LDD  R30,Y+5
	LDD  R31,Y+5+1
	SBIW R30,2
	STD  Y+5,R30
	STD  Y+5+1,R31
; 0000 01C0     } while (size); // Repeat until all block has been read
	SBIW R30,0
	BRNE _0x84
; 0000 01C1 
; 0000 01C2     addr >>= 1; // Convert address back to Flash words again.
	LSR  R17
	ROR  R16
; 0000 01C3     *address=addr;
_0x87:
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	ST   X+,R16
	ST   X,R17
; 0000 01C4 }
; 0000 01C5 }
_0x82:
	LDD  R17,Y+1
	LDD  R16,Y+0
	ADIW R28,7
	RET
; .FEND
;
;//******************************************************************************
;// Bootloader based on Atmel application note AVR109 communication protocol
;//
;// (C) 2010-2012 Pavel Haiduc, HP InfoTech s.r.l.,
;// All rights reserved
;//
;// Compiler: CodeVisionAVR V2.60+
;// Version: 1.00
;//******************************************************************************
;
;#include "defines.h"
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
     #define WR_SPMCR_REG_R22 out 0x37,r22
;
;#pragma warn-
;
;unsigned char __AddrToZByteToSPMCR_LPM(void flash *addr, unsigned char ctrl)
; 0001 0010 {

	.CSEG
___AddrToZByteToSPMCR_LPM:
; .FSTART ___AddrToZByteToSPMCR_LPM
; 0001 0011 #asm
	ST   -Y,R26
;	*addr -> Y+1
;	ctrl -> Y+0
; 0001 0012      ldd  r30,y+1
     ldd  r30,y+1
; 0001 0013      ldd  r31,y+2
     ldd  r31,y+2
; 0001 0014      ld   r22,y
     ld   r22,y
; 0001 0015      WR_SPMCR_REG_R22
     WR_SPMCR_REG_R22
; 0001 0016      lpm
     lpm
; 0001 0017      mov  r30,r0
     mov  r30,r0
	RJMP _0x2060001
; 0001 0018 #endasm
; 0001 0019 }
; .FEND
;
;void __DataToR0ByteToSPMCR_SPM(unsigned char data, unsigned char ctrl)
; 0001 001C {
___DataToR0ByteToSPMCR_SPM:
; .FSTART ___DataToR0ByteToSPMCR_SPM
; 0001 001D #asm
	ST   -Y,R26
;	data -> Y+1
;	ctrl -> Y+0
; 0001 001E      ldd  r0,y+1
     ldd  r0,y+1
; 0001 001F      ld   r22,y
     ld   r22,y
; 0001 0020      WR_SPMCR_REG_R22
     WR_SPMCR_REG_R22
; 0001 0021      spm
     spm
; 0001 0022 #endasm
; 0001 0023 }
	ADIW R28,2
	RET
; .FEND
;
;void __AddrToZWordToR1R0ByteToSPMCR_SPM(void flash *addr, unsigned int data, unsigned char ctrl)
; 0001 0026 {
___AddrToZWordToR1R0ByteToSPMCR_SPM:
; .FSTART ___AddrToZWordToR1R0ByteToSPMCR_SPM
; 0001 0027 #asm
	ST   -Y,R26
;	*addr -> Y+3
;	data -> Y+1
;	ctrl -> Y+0
; 0001 0028      ldd  r30,y+3
     ldd  r30,y+3
; 0001 0029      ldd  r31,y+4
     ldd  r31,y+4
; 0001 002A      ldd  r0,y+1
     ldd  r0,y+1
; 0001 002B      ldd  r1,y+2
     ldd  r1,y+2
; 0001 002C      ld   r22,y
     ld   r22,y
; 0001 002D      WR_SPMCR_REG_R22
     WR_SPMCR_REG_R22
; 0001 002E      spm
     spm
; 0001 002F #endasm
; 0001 0030 }
	ADIW R28,5
	RET
; .FEND
;
;void __AddrToZByteToSPMCR_SPM(void flash *addr, unsigned char ctrl)
; 0001 0033 {
___AddrToZByteToSPMCR_SPM:
; .FSTART ___AddrToZByteToSPMCR_SPM
; 0001 0034 #asm
	ST   -Y,R26
;	*addr -> Y+1
;	ctrl -> Y+0
; 0001 0035      ldd  r30,y+1
     ldd  r30,y+1
; 0001 0036      ldd  r31,y+2
     ldd  r31,y+2
; 0001 0037      ld   r22,y
     ld   r22,y
; 0001 0038      WR_SPMCR_REG_R22
     WR_SPMCR_REG_R22
; 0001 0039      spm
     spm
_0x2060001:
; 0001 003A #endasm
; 0001 003B }
	ADIW R28,3
	RET
; .FEND
;
;void __AddrToZ24WordToR1R0ByteToSPMCR_SPM(void flash *addr, unsigned int data, unsigned char ctrl)
; 0001 003E {
; 0001 003F #asm
;	*addr -> Y+3
;	data -> Y+1
;	ctrl -> Y+0
; 0001 0040      ldd  r30,y+3
; 0001 0041      ldd  r31,y+4
; 0001 0042      ldd  r22,y+5
; 0001 0043      out  rampz,r22
; 0001 0044      ldd  r0,y+1
; 0001 0045      ldd  r1,y+2
; 0001 0046      ld   r22,y
; 0001 0047      WR_SPMCR_REG_R22
; 0001 0048      spm
; 0001 0049 #endasm
; 0001 004A }
;
;void __AddrToZ24ByteToSPMCR_SPM(void flash *addr, unsigned char ctrl)
; 0001 004D {
; 0001 004E #asm
;	*addr -> Y+1
;	ctrl -> Y+0
; 0001 004F      ldd  r30,y+1
; 0001 0050      ldd  r31,y+2
; 0001 0051      ldd  r22,y+3
; 0001 0052      out  rampz,r22
; 0001 0053      ld   r22,y
; 0001 0054      WR_SPMCR_REG_R22
; 0001 0055      spm
; 0001 0056 #endasm
; 0001 0057 }
;
;#ifdef _WARNINGS_ON_
;#pragma warn+
;#endif
;
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
_getchar:
; .FSTART _getchar
_0x2000003:
	LDS  R30,192
	ANDI R30,LOW(0x80)
	BREQ _0x2000003
	LDS  R30,198
	RET
; .FEND
_putchar:
; .FSTART _putchar
	ST   -Y,R26
_0x2000006:
	LDS  R30,192
	ANDI R30,LOW(0x20)
	BREQ _0x2000006
	LD   R30,Y
	STS  198,R30
	ADIW R28,1
	RET
; .FEND

	.CSEG

	.CSEG

	.CSEG
;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x0:
	LDI  R30,LOW(158)
	STS  133,R30
	LDI  R30,LOW(88)
	STS  132,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x1:
	LDI  R30,LOW(0)
	STS  129,R30
	STS  111,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x2:
	CALL _getchar
	MOV  R19,R30
	CALL _getchar
	MOV  R18,R30
	ST   -Y,R19
	ST   -Y,R18
	CALL _getchar
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x3:
	LDI  R30,LOW(0)
	ST   -Y,R30
	LDI  R26,LOW(17)
	JMP  ___DataToR0ByteToSPMCR_SPM

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x4:
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(9)
	CALL ___AddrToZByteToSPMCR_LPM
	MOV  R26,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x5:
	__GETW2SX 134
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x6:
	__GETW1SX 137
	CP   R18,R30
	CPC  R19,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x7:
	__GETW1SX 137
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x8:
	MOVW R30,R16
	__ADDWRN 16,17,1
	LPM  R26,Z
	JMP  _putchar


	.CSEG
__GETW1P:
	LD   R30,X+
	LD   R31,X
	SBIW R26,1
	RET

__EEPROMRDB:
	SBIC EECR,EEWE
	RJMP __EEPROMRDB
	PUSH R31
	IN   R31,SREG
	CLI
	OUT  EEARL,R26
	OUT  EEARH,R27
	SBI  EECR,EERE
	IN   R30,EEDR
	OUT  SREG,R31
	POP  R31
	RET

__EEPROMWRB:
	SBIS EECR,EEWE
	RJMP __EEPROMWRB1
	WDR
	RJMP __EEPROMWRB
__EEPROMWRB1:
	IN   R25,SREG
	CLI
	OUT  EEARL,R26
	OUT  EEARH,R27
	SBI  EECR,EERE
	IN   R24,EEDR
	CP   R30,R24
	BREQ __EEPROMWRB0
	OUT  EEDR,R30
	SBI  EECR,EEMWE
	SBI  EECR,EEWE
__EEPROMWRB0:
	OUT  SREG,R25
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

;END OF CODE MARKER
__END_OF_CODE:
