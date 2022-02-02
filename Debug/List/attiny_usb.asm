
;CodeVisionAVR C Compiler V3.12 Advanced
;(C) Copyright 1998-2014 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com

;Build configuration    : Debug
;Chip type              : ATtiny85
;Program type           : Application
;Clock frequency        : 12,000000 MHz
;Memory model           : Small
;Optimize for           : Size
;(s)printf features     : int, width
;(s)scanf features      : int, width
;External RAM size      : 0
;Data Stack size        : 128 byte(s)
;Heap size              : 0 byte(s)
;Promote 'char' to 'int': Yes
;'char' is unsigned     : Yes
;8 bit enums            : Yes
;Global 'const' stored in FLASH: No
;Enhanced function parameter passing: Yes
;Enhanced core instructions: On
;Automatic register allocation for global variables: On
;Smart register allocation: On

	#define _MODEL_SMALL_

	#pragma AVRPART ADMIN PART_NAME ATtiny85
	#pragma AVRPART MEMORY PROG_FLASH 8192
	#pragma AVRPART MEMORY EEPROM 512
	#pragma AVRPART MEMORY INT_SRAM SIZE 512
	#pragma AVRPART MEMORY INT_SRAM START_ADDR 0x60

	.LISTMAC
	.EQU EERE=0x0
	.EQU EEWE=0x1
	.EQU EEMWE=0x2
	.EQU EECR=0x1C
	.EQU EEDR=0x1D
	.EQU EEARL=0x1E

	.EQU EEARH=0x1F
	.EQU WDTCR=0x21
	.EQU MCUSR=0x34
	.EQU MCUCR=0x35
	.EQU SPL=0x3D
	.EQU SPH=0x3E
	.EQU SREG=0x3F
	.EQU GPIOR0=0x11
	.EQU GPIOR1=0x12
	.EQU GPIOR2=0x13

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

	.EQU __SRAM_START=0x0060
	.EQU __SRAM_END=0x025F
	.EQU __DSTACK_SIZE=0x0080
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
	RCALL __EEPROMWRB
	.ENDM

	.MACRO __PUTW1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	RCALL __EEPROMWRW
	.ENDM

	.MACRO __PUTD1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	RCALL __EEPROMWRD
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
	RCALL __GETW1PF
	ICALL
	.ENDM

	.MACRO __CALL2EN
	PUSH R26
	PUSH R27
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	RCALL __EEPROMRDW
	POP  R27
	POP  R26
	ICALL
	.ENDM

	.MACRO __CALL2EX
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	RCALL __EEPROMRDD
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
	RCALL __PUTDP1
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
	RCALL __PUTDP1
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
	RCALL __PUTDP1
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
	RCALL __PUTDP1
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
	RCALL __PUTDP1
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
	RCALL __PUTDP1
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
	RCALL __PUTDP1
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
	RCALL __PUTDP1
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

;NAME DEFINITIONS FOR GLOBAL VARIABLES ALLOCATED TO REGISTERS
	.DEF _tx_ack=R3
	.DEF _tx_nak=R2
	.DEF _usb_rx_off=R5
	.DEF _usb_rx_len=R4
	.DEF _usb_rx_token=R7
	.DEF _usb_tx_len=R6
	.DEF _usb_address=R9
	.DEF _usb_new_address=R8

;GPIOR0-GPIOR2 INITIALIZATION VALUES
	.EQU __GPIOR0_INIT=0x00
	.EQU __GPIOR1_INIT=0x00
	.EQU __GPIOR2_INIT=0x00

	.CSEG
	.ORG 0x00

;START OF CODE MARKER
__START_OF_CODE:

;INTERRUPT VECTORS
	RJMP __RESET
	RJMP 0x00
	RJMP 0x00
	RJMP 0x00
	RJMP 0x00
	RJMP 0x00
	RJMP 0x00
	RJMP 0x00
	RJMP 0x00
	RJMP 0x00
	RJMP 0x00
	RJMP 0x00
	RJMP 0x00
	RJMP 0x00
	RJMP 0x00

_string_vendor:
	.DB  0x20,0x3,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
_string_device:
	.DB  0x18,0x3,LOW(_0x0*2),HIGH(_0x0*2),0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
_string_langid_G000:
	.DB  0x4,0x3,0x9,0x4
_descr_device_G000:
	.DB  0x12,0x1,0x1,0x1,0xFF,0x0,0x0,0x8
	.DB  0x81,0x17,0x9F,0xC,0x7,0x1,0x1,0x2
	.DB  0x0,0x1
_descr_config_G000:
	.DB  0x9,0x2,0x12,0x0,0x1,0x1,0x0,0x80
	.DB  0x32,0x9,0x4,0x0,0x0,0x0,0xFF,0x0
	.DB  0x0,0x0

_0x0:
	.DB  0x55,0x53,0x42,0x74,0x69,0x6E,0x79,0x20
	.DB  0x53,0x50,0x49,0x0
__RESET:
	CLI
	CLR  R30
	OUT  EECR,R30
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
	LDI  R26,__SRAM_START
__CLEAR_SRAM:
	ST   X+,R30
	SBIW R24,1
	BRNE __CLEAR_SRAM

;GPIOR0-GPIOR2 INITIALIZATION
	LDI  R30,__GPIOR0_INIT
	OUT  GPIOR0,R30
	;__GPIOR1_INIT = __GPIOR0_INIT
	OUT  GPIOR1,R30
	;__GPIOR2_INIT = __GPIOR0_INIT
	OUT  GPIOR2,R30

;HARDWARE STACK POINTER INITIALIZATION
	LDI  R30,LOW(__SRAM_END-__HEAP_SIZE)
	OUT  SPL,R30
	LDI  R30,HIGH(__SRAM_END-__HEAP_SIZE)
	OUT  SPH,R30

;DATA STACK POINTER INITIALIZATION
	LDI  R28,LOW(__SRAM_START+__DSTACK_SIZE)
	LDI  R29,HIGH(__SRAM_START+__DSTACK_SIZE)

	RJMP _main

	.ESEG
	.ORG 0

	.DSEG
	.ORG 0xE0

	.CSEG
;/*
; * attiny_usb.c
; *
; * Created: 05.09.2016 23:56:04
; * Author: Vendein_RaZoR
; */
;
;#include <io.h>
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x20
	.EQU __sm_mask=0x18
	.EQU __sm_adc_noise_red=0x08
	.EQU __sm_powerdown=0x10
	.EQU __sm_standby=0x18
	.SET power_ctrl_reg=mcucr
	#endif
;#include <tiny85.h>
;#include "usb.c"
;// ======================================================================
;// USB driver
;//
;// Entry points:
;// 	usb_init()	- enable the USB interrupt
;// 	usb_poll()	- poll for incoming packets and process them
;//
;// This code communicates with the interrupt handler through a number of
;// global variables, including two input buffers and one output buffer.
;// Packets are queued for transmission by copying them into the output
;// buffer. The interrupt handler will transmit such a packet on the
;// reception of an IN packet.
;//
;// Standard SETUP packets are handled here. Non-standard SETUP packets
;// are forwarded to the application code by calling usb_setup(). The
;// macros USBTINY_CALLBACK_IN and USBTINY_CALLBACK_OUT control whether
;// the callback functions usb_in() and usb_out() will be called for IN
;// and OUT transfers.
;//
;// Maximum stack usage (gcc 4.1.0 & 4.3.4) of usb_poll(): 5 bytes plus
;// possible additional stack usage in usb_setup(), usb_in() or usb_out().
;//
;// Copyright 2006-2010 Dick Streefland
;//
;// This is free software, licensed under the terms of the GNU General
;// Public License as published by the Free Software Foundation.
;// ======================================================================
;
;#include <pgmspace.h>
;#include <interrupt.h>
;	flags -> R17

	.CSEG
;//#include <tiny85.h>
;#include "def.h"
;#include "usb.h"
;
;#define	LE(word)			(word) & 0xff, (word) >> 8
;
;// ----------------------------------------------------------------------
;// typedefs
;// ----------------------------------------------------------------------
;
;#if	USBTINY_CALLBACK_IN == 2
;typedef	uint_t		txlen_t;
;#else
;typedef	byte_t		txlen_t;
;#endif
;
;// ----------------------------------------------------------------------
;// USB constants
;// ----------------------------------------------------------------------
;
;enum
;{
;	DESCRIPTOR_TYPE_DEVICE = 1,
;	DESCRIPTOR_TYPE_CONFIGURATION,
;	DESCRIPTOR_TYPE_STRING,
;	DESCRIPTOR_TYPE_INTERFACE,
;	DESCRIPTOR_TYPE_ENDPOINT,
;};
;
;// ----------------------------------------------------------------------
;// Interrupt handler interface
;// ----------------------------------------------------------------------
;
;#if	USBTINY_NO_DATA
;byte_t	tx_ack;				// ACK packet
;byte_t	tx_nak;				// NAK packet
;#else
;byte_t	tx_ack = USB_PID_ACK;		// ACK packet
;byte_t	tx_nak = USB_PID_NAK;		// NAK packet
;#endif
;
;byte_t	usb_rx_buf[2*USB_BUFSIZE];	// two input buffers
;byte_t	usb_rx_off;			// buffer offset: 0 or USB_BUFSIZE
;byte_t	usb_rx_len;			// buffer size, 0 means empty
;byte_t	usb_rx_token;			// PID of token packet: SETUP or OUT
;
;byte_t	usb_tx_buf[USB_BUFSIZE];	// output buffer
;byte_t	usb_tx_len;			// output buffer size, 0 means empty
;
;byte_t	usb_address;			// assigned device address
;byte_t	usb_new_address;		// new device address
;
;// ----------------------------------------------------------------------
;// Local data
;// ----------------------------------------------------------------------
;
;enum
;{
;	TX_STATE_IDLE = 0,		// transmitter idle
;	TX_STATE_RAM,			// usb_tx_data is a RAM address
;	TX_STATE_ROM,			// usb_tx_data is a ROM address
;	TX_STATE_CALLBACK,		// call usb_in() to obtain transmit data
;};
;
;static	byte_t	usb_tx_state;		// TX_STATE_*, see enum above
;static	txlen_t	usb_tx_total;		// total transmit size
;static	byte_t*	usb_tx_data;		// pointer to data to transmit
;
;#if	defined USBTINY_VENDOR_NAME
;struct
;{
;	byte_t	length;
;	byte_t	type;
;	int	string[sizeof(USBTINY_VENDOR_NAME)-1];
;}flash const	string_vendor =
;{
;	2 * sizeof(USBTINY_VENDOR_NAME),
;	DESCRIPTOR_TYPE_STRING,
;};
;#  define	VENDOR_NAME_ID	1
;#else
;#  define	VENDOR_NAME_ID	0
;#endif
;
;#if	defined USBTINY_DEVICE_NAME
;struct
;{
;	byte_t	length;
;	byte_t	type;
;	int	string[sizeof(USBTINY_DEVICE_NAME)-1];
;}flash const string_device = {2 * sizeof(USBTINY_DEVICE_NAME),DESCRIPTOR_TYPE_STRING,(int)USBTINY_DEVICE_NAME};
;#  define	DEVICE_NAME_ID	2
;#else
;#  define	DEVICE_NAME_ID	0
;#endif
;
;#if	defined USBTINY_SERIAL
;struct
;{
;	byte_t	length;
;	byte_t	type;
;	int	string[sizeof(USBTINY_SERIAL)-1];
;}	const	string_serial PROGMEM =
;{
;	2 * sizeof(USBTINY_SERIAL),
;	DESCRIPTOR_TYPE_STRING,
;	{ CAT2(L, USBTINY_SERIAL) }
;};
;#  define	SERIAL_ID	3
;#else
;#  define	SERIAL_ID	0
;#endif
;
;#if	VENDOR_NAME_ID || DEVICE_NAME_ID || SERIAL_ID
;flash static	byte_t	const	string_langid [] =
;{
;	4,				// bLength
;	DESCRIPTOR_TYPE_STRING,		// bDescriptorType (string)
;	LE(0x0409),			// wLANGID[0] (American English)
;};
;#endif
;
;// Device Descriptor
;flash static	byte_t	const	descr_device [18] =
;{
;	18,				// bLength
;	DESCRIPTOR_TYPE_DEVICE,		// bDescriptorType
;	LE(0x0101),			// bcdUSB
;	USBTINY_DEVICE_CLASS,		// bDeviceClass
;	USBTINY_DEVICE_SUBCLASS,	// bDeviceSubClass
;	USBTINY_DEVICE_PROTOCOL,	// bDeviceProtocol
;	8,				// bMaxPacketSize0
;	LE(USBTINY_VENDOR_ID),		// idVendor
;	LE(USBTINY_DEVICE_ID),		// idProduct
;	LE(USBTINY_DEVICE_VERSION),	// bcdDevice
;	VENDOR_NAME_ID,			// iManufacturer
;	DEVICE_NAME_ID,			// iProduct
;	SERIAL_ID,			// iSerialNumber
;	1,				// bNumConfigurations
;};
;
;// Configuration Descriptor
;flash static	byte_t	const	descr_config [] =
;{
;	9,				// bLength
;	DESCRIPTOR_TYPE_CONFIGURATION,	// bDescriptorType
;	LE(9+9+7*USBTINY_ENDPOINT),	// wTotalLength
;	1,				// bNumInterfaces
;	1,				// bConfigurationValue
;	0,				// iConfiguration
;	(USBTINY_MAX_POWER ? 0x80 : 0xc0), // bmAttributes
;	(USBTINY_MAX_POWER + 1) / 2,	// MaxPower
;
;	// Standard Interface Descriptor
;	9,				// bLength
;	DESCRIPTOR_TYPE_INTERFACE,	// bDescriptorType
;	0,				// bInterfaceNumber
;	0,				// bAlternateSetting
;	USBTINY_ENDPOINT,		// bNumEndpoints
;	USBTINY_INTERFACE_CLASS,	// bInterfaceClass
;	USBTINY_INTERFACE_SUBCLASS,	// bInterfaceSubClass
;	USBTINY_INTERFACE_PROTOCOL,	// bInterfaceProtocol
;	0,				// iInterface
;
;#if	USBTINY_ENDPOINT
;	// Additional Endpoint
;	7,				// bLength
;	DESCRIPTOR_TYPE_ENDPOINT,	// bDescriptorType
;	USBTINY_ENDPOINT_ADDRESS,	// bEndpointAddress
;	USBTINY_ENDPOINT_TYPE,		// bmAttributes
;	LE(8),				// wMaxPacketSize
;	USBTINY_ENDPOINT_INTERVAL,	// bInterval
;#endif
;};
;
;// ----------------------------------------------------------------------
;// Inspect an incoming packet.
;// ----------------------------------------------------------------------
;static	void	usb_receive ( byte_t* data, byte_t rx_len )
; 0000 000A {
_usb_receive_G000:
; .FSTART _usb_receive_G000
;	byte_t	len;
;	byte_t	type;
;	txlen_t	limit;
;
;	usb_tx_state = TX_STATE_RAM;
	ST   -Y,R26
	RCALL __SAVELOCR4
;	*data -> Y+5
;	rx_len -> Y+4
;	len -> R17
;	type -> R16
;	limit -> R19
	LDI  R30,LOW(1)
	RCALL SUBOPT_0x0
;	len = 0;
	LDI  R17,LOW(0)
;	limit = 0;
	LDI  R19,LOW(0)
;	if	( usb_rx_token == USB_PID_SETUP )
	LDI  R30,LOW(45)
	CP   R30,R7
	BREQ PC+2
	RJMP _0x4
;	{
;#if	USBTINY_CALLBACK_IN == 2
;		limit = * (uint_t*) & data[6];
;#else
;		limit = data[6];
	RCALL SUBOPT_0x1
	ADIW R26,6
	LD   R19,X
;		if	( data[7] )
	RCALL SUBOPT_0x2
	LDD  R30,Z+7
	CPI  R30,0
	BREQ _0x5
;		{
;			limit = 255;
	LDI  R19,LOW(255)
;		}
;#endif
;		type = data[0] & 0x60;
_0x5:
	RCALL SUBOPT_0x1
	LD   R30,X
	ANDI R30,LOW(0x60)
	MOV  R16,R30
;		if	( type == 0x00 )
	CPI  R16,0
	BREQ PC+2
	RJMP _0x6
;		{	// Standard request
;			if	( data[1] == 0 )	// GET_STATUS
	RCALL SUBOPT_0x2
	LDD  R30,Z+1
	CPI  R30,0
	BRNE _0x7
;			{
;				len = 2;
	LDI  R17,LOW(2)
;#if	USBTINY_MAX_POWER == 0
;				data[0] = (data[0] == 0x80);
;#else
;				data[0] = 0;
	RCALL SUBOPT_0x1
	LDI  R30,LOW(0)
	ST   X,R30
;#endif
;				data[1] = 0;
	RCALL SUBOPT_0x3
	LDI  R30,LOW(0)
	ST   X,R30
;			}
;			else if	( data[1] == 5 )	// SET_ADDRESS
	RJMP _0x8
_0x7:
	RCALL SUBOPT_0x3
	LD   R26,X
	CPI  R26,LOW(0x5)
	BRNE _0x9
;			{
;				usb_new_address = data[2];
	RCALL SUBOPT_0x1
	ADIW R26,2
	LD   R8,X
;#ifdef	USBTINY_USB_OK_LED
;				SET(USBTINY_USB_OK_LED);// LED on
;#endif
;			}
;			else if	( data[1] == 6 )	// GET_DESCRIPTOR
	RJMP _0xA
_0x9:
	RCALL SUBOPT_0x3
	LD   R26,X
	CPI  R26,LOW(0x6)
	BRNE _0xB
;			{
;				usb_tx_state = TX_STATE_ROM;
	LDI  R30,LOW(2)
	RCALL SUBOPT_0x0
;				if	( data[3] == 1 )
	RCALL SUBOPT_0x4
	CPI  R26,LOW(0x1)
	BRNE _0xC
;				{	// DEVICE
;					data = (byte_t*) &descr_device;
	LDI  R30,LOW(_descr_device_G000*2)
	LDI  R31,HIGH(_descr_device_G000*2)
	STD  Y+5,R30
	STD  Y+5+1,R31
;					len = sizeof(descr_device);
	LDI  R17,LOW(18)
;				}
;				else if	( data[3] == 2 )
	RJMP _0xD
_0xC:
	RCALL SUBOPT_0x4
	CPI  R26,LOW(0x2)
	BRNE _0xE
;				{	// CONFIGURATION
;					data = (byte_t*) &descr_config;
	LDI  R30,LOW(_descr_config_G000*2)
	LDI  R31,HIGH(_descr_config_G000*2)
	RCALL SUBOPT_0x5
;					len = sizeof(descr_config);
	LDI  R17,LOW(18)
;				}
;#if	VENDOR_NAME_ID || DEVICE_NAME_ID || SERIAL_ID
;				else if	( data[3] == 3 )
	RJMP _0xF
_0xE:
	RCALL SUBOPT_0x4
	CPI  R26,LOW(0x3)
	BRNE _0x10
;				{	// STRING
;					if	( data[2] == 0 )
	RCALL SUBOPT_0x2
	LDD  R30,Z+2
	CPI  R30,0
	BRNE _0x11
;					{
;						data = (byte_t*) &string_langid;
	LDI  R30,LOW(_string_langid_G000*2)
	LDI  R31,HIGH(_string_langid_G000*2)
	RCALL SUBOPT_0x5
;						len = sizeof(string_langid);
	LDI  R17,LOW(4)
;					}
;#if	VENDOR_NAME_ID
;					else if	( data[2] == VENDOR_NAME_ID )
	RJMP _0x12
_0x11:
	RCALL SUBOPT_0x1
	ADIW R26,2
	LD   R26,X
	CPI  R26,LOW(0x1)
	BRNE _0x13
;					{
;						data = (byte_t*) &string_vendor;
	LDI  R30,LOW(_string_vendor*2)
	LDI  R31,HIGH(_string_vendor*2)
	RCALL SUBOPT_0x5
;						len = sizeof(string_vendor);
	LDI  R17,LOW(32)
;					}
;#endif
;#if	DEVICE_NAME_ID
;					else if ( data[2] == DEVICE_NAME_ID )
	RJMP _0x14
_0x13:
	RCALL SUBOPT_0x1
	ADIW R26,2
	LD   R26,X
	CPI  R26,LOW(0x2)
	BRNE _0x15
;					{
;						data = (byte_t*) &string_device;
	LDI  R30,LOW(_string_device*2)
	LDI  R31,HIGH(_string_device*2)
	RCALL SUBOPT_0x5
;						len = sizeof(string_device);
	LDI  R17,LOW(24)
;					}
;#endif
;#if	SERIAL_ID
;					else if ( data[2] == SERIAL_ID )
;					{
;						data = (byte_t*) &string_serial;
;						len = sizeof(string_serial);
;					}
;#endif
;				}
_0x15:
_0x14:
_0x12:
;#endif
;			}
_0x10:
_0xF:
_0xD:
;			else if	( data[1] == 8 )	// GET_CONFIGURATION
	RJMP _0x16
_0xB:
	RCALL SUBOPT_0x3
	LD   R26,X
	CPI  R26,LOW(0x8)
	BRNE _0x17
;			{
;				data[0] = 1;		// return bConfigurationValue
	RCALL SUBOPT_0x1
	LDI  R30,LOW(1)
	RJMP _0x3B
;				len = 1;
;			}
;			else if	( data[1] == 10 )	// GET_INTERFACE
_0x17:
	RCALL SUBOPT_0x3
	LD   R26,X
	CPI  R26,LOW(0xA)
	BRNE _0x19
;			{
;				data[0] = 0;
	RCALL SUBOPT_0x1
	LDI  R30,LOW(0)
_0x3B:
	ST   X,R30
;				len = 1;
	LDI  R17,LOW(1)
;			}
;		}
_0x19:
_0x16:
_0xA:
_0x8:
;		else
	RJMP _0x1A
_0x6:
;		{	// Class or Vendor request
;			len = usb_setup( data );
	RCALL SUBOPT_0x1
	RCALL _usb_setup
	MOV  R17,R30
;#if	USBTINY_CALLBACK_IN
;			if	( len == 0xff )
	CPI  R17,255
	BRNE _0x1B
;			{
;				usb_tx_state = TX_STATE_CALLBACK;
	LDI  R30,LOW(3)
	RCALL SUBOPT_0x0
;			}
;#endif
;		}
_0x1B:
_0x1A:
;		if	(  len < limit
;#if	USBTINY_CALLBACK_IN == 2
;			&& len != 0xff
;#endif
;			)
	CP   R17,R19
	BRSH _0x1C
;		{
;			limit = len;
	MOV  R19,R17
;		}
;		usb_tx_data = data;
_0x1C:
	RCALL SUBOPT_0x2
	STS  _usb_tx_data_G000,R30
	STS  _usb_tx_data_G000+1,R31
;	}
;#if	USBTINY_CALLBACK_OUT
;	else if	( rx_len > 0 )
	RJMP _0x1D
_0x4:
	LDD  R26,Y+4
	CPI  R26,LOW(0x1)
	BRLO _0x1E
;	{	// usb_rx_token == USB_PID_OUT
;		usb_out( data, rx_len );
	RCALL SUBOPT_0x2
	ST   -Y,R31
	ST   -Y,R30
	LDD  R26,Y+6
	RCALL _usb_out
;	}
;#endif
;	usb_tx_total  = limit;
_0x1E:
_0x1D:
	STS  _usb_tx_total_G000,R19
;	usb_tx_buf[0] = USB_PID_DATA0;	// next data packet will be DATA1
	LDI  R30,LOW(195)
	STS  _usb_tx_buf,R30
;}
	RCALL __LOADLOCR4
	RJMP _0x2020002
; .FEND
;
;// ----------------------------------------------------------------------
;// Load the transmit buffer with the next packet.
;// ----------------------------------------------------------------------
;static	void	usb_transmit ( void )
;{
_usb_transmit_G000:
; .FSTART _usb_transmit_G000
;	byte_t	len;
;	byte_t*	src;
;	byte_t*	dst;
;	byte_t	i;
;	byte_t	b;
;
;	usb_tx_buf[0] ^= (USB_PID_DATA0 ^ USB_PID_DATA1);
	SBIW R28,1
	RCALL __SAVELOCR6
;	len -> R17
;	*src -> R18,R19
;	*dst -> R20,R21
;	i -> R16
;	b -> Y+6
	LDS  R26,_usb_tx_buf
	LDI  R30,LOW(136)
	EOR  R30,R26
	STS  _usb_tx_buf,R30
;	if	( usb_tx_total > 8 )
	LDS  R26,_usb_tx_total_G000
	CPI  R26,LOW(0x9)
	BRLO _0x1F
;	{
;		len = 8;
	LDI  R17,LOW(8)
;	}
;	else
	RJMP _0x20
_0x1F:
;	{
;		len = (byte_t) usb_tx_total;
	LDS  R17,_usb_tx_total_G000
;	}
_0x20:
;	dst = usb_tx_buf + 1;
	__POINTWRMN 20,21,_usb_tx_buf,1
;	if	( len > 0 )
	CPI  R17,1
	BRLO _0x21
;	{
;#if	USBTINY_CALLBACK_IN
;		if	( usb_tx_state == TX_STATE_CALLBACK )
	LDS  R26,_usb_tx_state_G000
	CPI  R26,LOW(0x3)
	BRNE _0x22
;		{
;			len = usb_in( dst, len );
	ST   -Y,R21
	ST   -Y,R20
	MOV  R26,R17
	RCALL _usb_in
	MOV  R17,R30
;		}
;		else
	RJMP _0x23
_0x22:
;#endif
;		{
;			src = usb_tx_data;
	__GETWRMN 18,19,0,_usb_tx_data_G000
;			if	( usb_tx_state == TX_STATE_RAM )
	LDS  R26,_usb_tx_state_G000
	CPI  R26,LOW(0x1)
	BRNE _0x24
;			{
;				for	( i = 0; i < len; i++ )
	LDI  R16,LOW(0)
_0x26:
	CP   R16,R17
	BRSH _0x27
;				{
;					*dst++ = *src++;
	PUSH R21
	PUSH R20
	__ADDWRN 20,21,1
	MOVW R26,R18
	__ADDWRN 18,19,1
	LD   R30,X
	POP  R26
	POP  R27
	ST   X,R30
;				}
	SUBI R16,-1
	RJMP _0x26
_0x27:
;			}
;			else	// usb_tx_state == TX_STATE_ROM
	RJMP _0x28
_0x24:
;			{
;				for	( i = 0; i < len; i++ )
	LDI  R16,LOW(0)
_0x2A:
	CP   R16,R17
	BRSH _0x2B
;				{
;					b = pgm_read_byte( src );
	MOVW R30,R18
	LPM  R0,Z
	STD  Y+6,R0
;					src++;
	__ADDWRN 18,19,1
;					*dst++ = b;
	PUSH R21
	PUSH R20
	__ADDWRN 20,21,1
	LDD  R30,Y+6
	POP  R26
	POP  R27
	ST   X,R30
;				}
	SUBI R16,-1
	RJMP _0x2A
_0x2B:
;			}
_0x28:
;			usb_tx_data = src;
	__PUTWMRN _usb_tx_data_G000,0,18,19
;		}
_0x23:
;		usb_tx_total -= len;
	LDS  R30,_usb_tx_total_G000
	SUB  R30,R17
	STS  _usb_tx_total_G000,R30
;	}
;	crc( usb_tx_buf + 1, len );
_0x21:
	__POINTW1MN _usb_tx_buf,1
	ST   -Y,R31
	ST   -Y,R30
	MOV  R26,R17
	RCALL _crc
;	usb_tx_len = len + 3;
	MOV  R30,R17
	SUBI R30,-LOW(3)
	MOV  R6,R30
;	if	( len < 8 )
	CPI  R17,8
	BRSH _0x2C
;	{	// this is the last packet
;		usb_tx_state = TX_STATE_IDLE;
	LDI  R30,LOW(0)
	RCALL SUBOPT_0x0
;	}
;}
_0x2C:
	RCALL __LOADLOCR6
_0x2020002:
	ADIW R28,7
	RET
; .FEND
;
;// ----------------------------------------------------------------------
;// Initialize the low-level USB driver.
;// ----------------------------------------------------------------------
;extern	void	usb_init ( void )
;{
_usb_init:
; .FSTART _usb_init
;	USB_INT_CONFIG |= USB_INT_CONFIG_SET;
	IN   R30,0x35
	ORI  R30,LOW(0x3)
	OUT  0x35,R30
;	USB_INT_ENABLE |= (1 << USB_INT_ENABLE_BIT);
	IN   R30,0x3B
	ORI  R30,0x40
	OUT  0x3B,R30
;#ifdef	USBTINY_USB_OK_LED
;	OUTPUT(USBTINY_USB_OK_LED);
;#endif
;#ifdef	USBTINY_DMINUS_PULLUP
;	SET(USBTINY_DMINUS_PULLUP);
;	OUTPUT(USBTINY_DMINUS_PULLUP);	// enable pullup on D-
;#endif
;#if	USBTINY_NO_DATA
;	tx_ack = USB_PID_ACK;
	LDI  R30,LOW(210)
	MOV  R3,R30
;	tx_nak = USB_PID_NAK;
	LDI  R30,LOW(90)
	MOV  R2,R30
;#endif
;	sei();
	sei
;}
	RET
; .FEND
;
;// ----------------------------------------------------------------------
;// Poll USB driver:
;// - check for incoming USB packets
;// - refill an empty transmit buffer
;// - check for USB bus reset
;// ----------------------------------------------------------------------
;extern	void	usb_poll ( void )
;{
_usb_poll:
; .FSTART _usb_poll
;	byte_t	i;
;
;	// check for incoming USB packets
;	if	( usb_rx_len != 0 )
	ST   -Y,R17
;	i -> R17
	TST  R4
	BREQ _0x2D
;	{
;		usb_receive( usb_rx_buf + USB_BUFSIZE - usb_rx_off + 1, usb_rx_len - 3 );
	__POINTW2MN _usb_rx_buf,11
	MOV  R30,R5
	LDI  R31,0
	RCALL __SWAPW12
	SUB  R30,R26
	SBC  R31,R27
	ADIW R30,1
	ST   -Y,R31
	ST   -Y,R30
	MOV  R26,R4
	SUBI R26,LOW(3)
	RCALL _usb_receive_G000
;		usb_tx_len = 0;	// abort pending transmission
	CLR  R6
;		usb_rx_len = 0;	// accept next packet
	CLR  R4
;	}
;	// refill an empty transmit buffer, when the transmitter is active
;	if	( usb_tx_len == 0 && usb_tx_state != TX_STATE_IDLE )
_0x2D:
	TST  R6
	BRNE _0x2F
	LDS  R26,_usb_tx_state_G000
	CPI  R26,LOW(0x0)
	BRNE _0x30
_0x2F:
	RJMP _0x2E
_0x30:
;	{
;		usb_transmit();
	RCALL _usb_transmit_G000
;	}
;	// check for USB bus reset
;	for	( i = 10; i > 0 && ! (USB_IN & USB_MASK_DMINUS); i-- )
_0x2E:
	LDI  R17,LOW(10)
_0x32:
	CPI  R17,1
	BRLO _0x34
	SBIS 0x16,4
	RJMP _0x35
_0x34:
	RJMP _0x33
_0x35:
;	{
;	}
	SUBI R17,1
	RJMP _0x32
_0x33:
;	if	( i == 0 )
	CPI  R17,0
	BRNE _0x36
;	{	// SE0 for more than 2.5uS is a reset
;		usb_new_address = 0;
	CLR  R8
;		usb_address = 0;
	CLR  R9
;#ifdef	USBTINY_USB_OK_LED
;		CLR(USBTINY_USB_OK_LED);	// LED off
;#endif
;	}
;}
_0x36:
	LD   R17,Y+
	RET
; .FEND
;
;byte_t		usb_setup ( byte_t data[8] )
; 0000 000D {
_usb_setup:
; .FSTART _usb_setup
; 0000 000E }
	RET
; .FEND
;
;void		usb_out ( byte_t* data, byte_t len )
; 0000 0011 {
_usb_out:
; .FSTART _usb_out
; 0000 0012 }
; .FEND
;
;byte_t		usb_in ( byte_t* data, byte_t len )
; 0000 0015 {
_usb_in:
; .FSTART _usb_in
; 0000 0016 
; 0000 0017 }
_0x2020001:
	ADIW R28,2
	RET
; .FEND
;
;void		crc ( byte_t* data, byte_t len )
; 0000 001A {
_crc:
; .FSTART _crc
; 0000 001B #asm
	ST   -Y,R26
;	*data -> Y+1
;	len -> Y+0
; 0000 001C {
{
; 0000 001D ; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; 0000 001E ; void crc(unsigned char *data, unsigned char len);
; void crc(unsigned char *data, unsigned char len);
; 0000 001F ; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; 0000 0020 #define    data    r24
#define    data    r24
; 0000 0021 #define    len    r22
#define    len    r22
; 0000 0022 

; 0000 0023 #define    b    r18
#define    b    r18
; 0000 0024 #define    con_01    r19
#define    con_01    r19
; 0000 0025 #define    con_a0    r20
#define    con_a0    r20
; 0000 0026 #define    crc_l    r24
#define    crc_l    r24
; 0000 0027 #define    crc_h    r25
#define    crc_h    r25
; 0000 0028 

; 0000 0029    // .text
   // .text
; 0000 002A     //.global    crc
    //.global    crc
; 0000 002B    // .type    crc, @function
   // .type    crc, @function
; 0000 002C crc:
crc:
; 0000 002D     movw    r26, r24
    movw    r26, r24
; 0000 002E     ldi    crc_h, 0xff
    ldi    crc_h, 0xff
; 0000 002F 	ldi	crc_l, 0xff
	ldi	crc_l, 0xff
; 0000 0030 	tst	len
	tst	len
; 0000 0031 	breq	done1
	breq	done1
; 0000 0032 	ldi	con_a0, 0xa0
	ldi	con_a0, 0xa0
; 0000 0033 	ldi	con_01, 0x01
	ldi	con_01, 0x01
; 0000 0034 next_byte:
next_byte:
; 0000 0035 	ld	b, X+
	ld	b, X+
; 0000 0036 	eor	crc_l, b
	eor	crc_l, b
; 0000 0037 	ldi	b, 8
	ldi	b, 8
; 0000 0038 next_bit:
next_bit:
; 0000 0039 	lsr	crc_h
	lsr	crc_h
; 0000 003A 	ror	crc_l
	ror	crc_l
; 0000 003B 	brcc	noxor
	brcc	noxor
; 0000 003C 	eor	crc_h, con_a0
	eor	crc_h, con_a0
; 0000 003D 	eor	crc_l, con_01
	eor	crc_l, con_01
; 0000 003E noxor:
noxor:
; 0000 003F 	dec	b
	dec	b
; 0000 0040 	brne	next_bit
	brne	next_bit
; 0000 0041 	dec	len
	dec	len
; 0000 0042 	brne	next_byte
	brne	next_byte
; 0000 0043 done1:
done1:
; 0000 0044 	com	crc_l
	com	crc_l
; 0000 0045 	com	crc_h
	com	crc_h
; 0000 0046 	st	X+, crc_l
	st	X+, crc_l
; 0000 0047 	st	X+, crc_h
	st	X+, crc_h
; 0000 0048 	ret
	ret
; 0000 0049 }
}
; 0000 004A #endasm
; 0000 004B }
	ADIW R28,3
	RET
; .FEND
;
;void main(void)
; 0000 004E {
_main:
; .FSTART _main
; 0000 004F usb_init();
	RCALL _usb_init
; 0000 0050 while (1)
_0x37:
; 0000 0051     {
; 0000 0052     // Please write your application code here
; 0000 0053   usb_poll();
	RCALL _usb_poll
; 0000 0054     }
	RJMP _0x37
; 0000 0055 }
_0x3A:
	RJMP _0x3A
; .FEND

	.CSEG

	.DSEG
_usb_rx_buf:
	.BYTE 0x16
_usb_tx_buf:
	.BYTE 0xB
_usb_tx_state_G000:
	.BYTE 0x1
_usb_tx_total_G000:
	.BYTE 0x1
_usb_tx_data_G000:
	.BYTE 0x2

	.CSEG
;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x0:
	STS  _usb_tx_state_G000,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 17 TIMES, CODE SIZE REDUCTION:14 WORDS
SUBOPT_0x1:
	LDD  R26,Y+5
	LDD  R27,Y+5+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x2:
	LDD  R30,Y+5
	LDD  R31,Y+5+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x3:
	RCALL SUBOPT_0x1
	ADIW R26,1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x4:
	RCALL SUBOPT_0x1
	ADIW R26,3
	LD   R26,X
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x5:
	STD  Y+5,R30
	STD  Y+5+1,R31
	RET


	.CSEG
__SWAPW12:
	MOV  R1,R27
	MOV  R27,R31
	MOV  R31,R1

__SWAPB12:
	MOV  R1,R26
	MOV  R26,R30
	MOV  R30,R1
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
