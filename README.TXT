Welcome to the CodeVisionAVR C Compiler V3 and the CodeWizardAVR Automatic Program Generator

The compiler is designed to be used along with the AVR Studio V4.19 and
Atmel Studio 6.2 or later debuggers, which can be downloaded from the ATMEL web site:
www.atmel.com

For JTAGICE 3 programming support to be available Atmel Studio 6.2 or later must be installed.

Details about using CodeVisionAVR with these debuggers are available in the Help topics:
- Using the CodeVisionAVR Extension for Atmel Studio
- CodeVisionAVR C Compiler Reference|Using the AVR Studio 4.19 Debugger
and in the chapters: 1, 4.21 of the CodeVisionAVR User Manual.

1. Installing CodeVisionAVR V3
1.1 Installing CodeVisionAVR V3 as an Atmel Studio extension

This installation scenario requires Atmel Studio 6.1 or later to be
installed before CodeVisionAVR V3, the user being logged-in as Administrator.

If the older AVR Studio 5 or Atmel Studio 6.0/6.1 are installed, they must be 
first fully uninstalled before installing Atmel Studio 6.2 or later.
It is not recommended to upgrade Atmel Studio 6.0/6.1 to 6.2 or later, 
but to perform a complete uninstall of V6.0/6.1 and then a fresh 
installation of the newer version.
After uninstalling the old Atmel Studio, the remaining "C:\Program Files (x86)\Atmel\Atmel Studio 6.0" or  
"C:\Program Files (x86)\Atmel\Atmel Studio 6.1" directory and its contents must be deleted.

When installing Atmel Studio 6.2, the user will be prompted by Windows 
if Atmel Studio is allowed to make changes to the computer. 
The answer must be affirmative.
Under Windows XP the checkbox "Protect my computer and data from 
unauthorized program activity" must be unchecked.

After Atmel Studio was successfully installed, the CodeVisionAVR 
installer "setup.exe" can be launched to finish the installation procedure.
The above step must be also performed being logged-in as Administrator.

For installing under Windows Vista, the following steps should be performed, 
being logged-in as Administrator.

- The Windows Vista User Account Control must be disabled using the steps below:

    - press the Windows button and click on the Control Panel link
    - in the Control Panel window, under the User Accounts and Family Safety, 
      click on the Add or remove user accounts link
    - a new window will open, click on the Go to the main User Accounts page 
      link located at the bottom of the window
    - a new window will open, click on the Turn User Account Control on or off 
      link located at the bottom of the window
    - in the new window that will open, uncheck the Use User Account Control (UAC)
      to help protect your computer check box and press the OK button to confirm
    - the computer will have to be restarted for this setting to become effective

- run the "setup.exe" installer
- after the installation is complete, right click on the CodeVisionAVR icon on 
  the desktop
- select Properties in the popup menu that will open
- a new window called CodeVisionAVR Properties will open
- select the Compatibility tab
- check the Privilege Level|Run this program as an administrator check box and 
  press the OK button to confirm.

Notes: 
- CodeVisionAVR usage always requires the user to be logged-in as Administrator.
- The Naggy extension for Atmel Studio is not compatible with CodeVisionAVR.
  Naggy must be disabled from Atmel Studio menu: Tools|Disable Naggy.
- Altough CodeVisionAVR V3 was installed as an Atmel Studio extension, it can 
  also be used from it's own IDE without Atmel Studio.

1.2 Installing CodeVisionAVR V3 without Atmel Studio

Log-in as Administrator and launch the CodeVisionAVR installer "setup.exe" to 
perform the installation procedure.
Please ignore the error message, displayed during setup, that no Atmel Studio 
installation was found.
For installing under Windows Vista please follow the steps mentioned at 1.1.
After CodeVisionAVR was successfully installed, the AVR Studio 4.19 debugger 
may be also installed in order to allow source level debugging.

Note: CodeVisionAVR usage always requires the user to be logged-in as Administrator.


2. New features/bug fixes in CodeVisionAVR V3.12
2.1 Compiler:
- Improved CodeVisionAVR project export to Atmel Studio when there is no exact
  chip type match.
- When importing a CodeVisionAVR project in Atmel Studio 6.2, ensure that the active build 
  configuration of the new created Atmel Studio solution matches the one from the 
  CodeVisionAVR project .prj file.
- Fixed errors which occurred when using the USB library for the ATmega U2, U4 and
  AT90USB82/162 chips.

2.2 CodeWizardAVR:
- Fixed: ADC reference type and clock frequency settings were not correctly read
  from the CodeWizardAVR .cwp project file.

2.3 Chip programmer:
- Fixed: Reading chip signature, lock bits and calibration bytes didn't work 
  correctly for STK600, AVRISP, AVR Dragon and JTAGICE when Atmel Studio 6.2 was installed.


3. New features/changes in CodeVisionAVR V3, not available in old V1.25.x compilers:
3.1 Compiler:
- ANSI C compatible C front-end
- the bool data type was added (stdbool.h)
- the @ operator can now be used with variables located in EEPROM too
- the & unary operator can now be applied to I/O registers declared using the sfrb and sfrw keywords.
  It will return a pointer to the RAM address where these registers are mapped.
- there is no need to specify the flash or eeprom memory attribute during structure or union type definition.
  Therefore the  same structure or union data type can be easily located in any memory area during
  variable declaration.
- the compiler now makes distinction between the const type qualifier and the flash memory attribute.
  In order to maintain compatibility with V1.25.x projects, 
  the Project|Configure|C Compiler|Code Generation|Store Global Constants in FLASH Memory must be checked. 
  If this option is not checked, identifiers declared with the 'const' type qualifier will be 
  placed in RAM.
- the Code Information tab, present in the Navigator after the first Build, displays detailed information
  regarding defined data types, preprocessor macros, function and variables declarations, 
  included header files, memory and register allocation
- the abs, cabs, labs and fabs functions were moved from the math.h header to the stdlib.h header
- the preprocessor does not use the old 'funcused' directive, when it is found it is always evaluated to 1
- added the #message preprocessor directive
- improved error and warning checking
- improved linker: only the modified C source files are compiled when the Project|Build command is executed
- improved COFF object file generator
- improved code optimizer
- enhanced libraries, including MMC/SD/SD HC FLASH Memory Card and FAT support
- I/O registers bits definitions were added to the device header files.
  For projects created with prior versions, these definitions are not enabled by default.
  In order to enable them the Project|Configure|C Compiler|Code Generation|Preprocessor|Include I/O 
  Registers Bits Definitions option must be activated.
  For newly created projects, this option is enabled by default. 
- in order to eliminate naming conflicts with I/O registers bits definitions, the names of the
  SPCR0, SPDR0, SPSR0 registers were changed to SPCR, SPDR, SPSR in the following
  header files: mega164.h, mega324.h, mega644.h, mega644p.h.
- in order to eliminate naming conflicts with I/O registers bits definitions, the names of the
  PCINT0, PCINT1, PCINT2, PCINT3 interrupt vectors were changed to
  PC_INT0, PC_INT1, PC_INT2, PC_INT3  in the following header files:
  90usb1286.h, 90usb1287.h, 90usb646.h, 90usb647.h, 90usb162.h, 90usb162.h,
  mega1280.h, mega1281.h, mega2560.h, mega2561.h, mega640.h, mega1284p.h,
  mega162.h, mega164.h, mega165.h, mega168.h, mega168p.h, mega169.h,
  mega324.h, mega325.h, mega325p.h, mega3250.h, mega3250p.h, mega328p.h,
  mega329.h, mega329p.h, mega3290.h, mega3290p.h, mega406.h,
  mega48.h, mega48p.h, mega644.h, mega644p.h, mega645.h, mega6450.h,
  mega649.h, mega6490.h, mega88.h, mega88p.h,
  tiny10.h, tiny13.h, tiny24.h, tiny25.h, tiny44.h, tiny45.h, tiny48.h,
  tiny84.h, tiny 85.h, tiny88.h, tiny261.h, tiny461.h, tiny861.h, tiny2313.h.
  If these interrupt vectors are used in your programs, their names must be updated.
- in order to eliminate naming conflicts with I/O registers bits definitions, the names of the
  INT0...INT7 interrupt vectors were changed to EXT_INT0...EXT_INT7
  in the following header files: mega1280.h, mega1281.h, mega2560.h, mega2561.h,
  mega640.h, mega1284p.h, mega164.h, mega324.h, mega644.h, mega644p.h.
  If these interrupt vectors are used in your programs, their names must be updated.
- removed the limitation: when a literal char string enclosed between quotes,
  is passed as an argument to a function parameter of pointer to char,
  the pointer now can point to any memory type: RAM, EEPROM or FLASH, not only FLASH like in previous
  versions.
  The CodeVisionAVR C Compiler Reference|Constants Help topic and User Manual chapter were updated to
  reflect this change.

3.2 IDE:
- CodeVisionAVR extension for Atmel Studio 6.1
- completely redesigned text Editor with improved syntax highlighting for both C and AVR assembly
- added function parameters and global structure/union members auto complete
- improved code folding
- code folding state can be saved and restored
- bookmarks state can be saved and restored
- added automatic matching brace highlighting when the user places the cursor before the brace
- added automatic file saving at specified time interval
- the Code Navigator was redesigned and displays project information in a more logical way
- an additional Code Information tab is present after a project build. It displays detailed information about the included 
  header files, preprocessor macro definitions, type definitions, global/static variable declarations, memory allocation and 
  function definitions.
- added the Functions Call Tree tab in the Navigator
- the new Project|Configure|Files|Output Directories allows to specify in which directories the files generated by the 
  compiler/linker will be placed.
- improved toolbar

3.3 CodeWizardAVR:
- Generates code using symbolic names for peripheral configuration registers' bits.
- Improved user interface.

It is important to note that in CodeVisionAVR V2 the .asm, .hex, .eep, .cof files created by the compiler have the name of 
the project .prj file.

4. New ATxmega chips support in CodeVisionAVR

- the Standard C I/O Functions use by default the USARTC0. This can be changed by defining the _ATXMEGA_USART_ macro
  as described in the corresponding Help topic.
- the SPI functions use by default the SPIC controller on PORTC. This can be changed by defining the _ATXMEGA_SPI_
  and _ATXMEGA_SPI_PORT_ preprocessor macros as described in the corresponding Help topic.  
- the RTC functions do not yet support the ATxmega chips.

5. Example programs

The Compiler is supplied with the following example programs in the CodeVisionAVR installation folder:

 - ATxmega chips in \EXAMPLES ATxmega
 - ATxmega USB example in \EXAMPLES ATxmega\USB
 - Graphic LCDs in \EXAMPLES\Graphic LCD and \EXAMPLES ATxmega\Graphic LCD
 - Resistive Touchscreen in \EXAMPLES ATxmega\Graphic LCD\Resistive Touchscreen
 - SD FLASH Memory Cards access in \EXAMPLES\SDCARD and EXAMPLES ATxmega\Graphic LCD\Display Image from SD Card
 - USB in \EXAMPLES\USB
 - AVR 109 Bootloader
 - AES Encryption-Decryption
 - "ATmega8535 ADC on the STK500" in \EXAMPLES\ADC8535
 - "Real Time Clock with ATmega103, Atmel Application Note AVR134" in \EXAMPLES\AVR134
 - "Calling functions written in assembler from C" in \EXAMPLES\C_ASM
 - "Moving LED" in \EXAMPLES\LED
 - "Accessing the EEPROM" in \EXAMPLES\EEPROM
 - "LCD Demo" in \EXAMPLES\LCDDEMO
 - "Definition of user characters in LCDs" in \EXAMPLES\LCDCHAR
 - "LM75 Thermometer" in \EXAMPLES\THERM75
 - "LCD Thermometer" in \EXAMPLES\THERMLCD
 - "DS1820/DS18S20 Multipoint thermometer" in \EXAMPLES\DS1820
 - "DS1990 Serial Number iButton" in \EXAMPLES\DS1990
 - "AD7896 Digital voltmeter" in \EXAMPLES\SPI
 - "MAX1241 Digital voltmeter" in \EXAMPLES\MAX1241
 - "4x4 Keypad" in \EXAMPLES\KEYPAD
 - "Simple multifile project" in \EXAMPLES\MULTFILE
 - "Redirecting the output of standard C I/O functions to USART0, USART1
   and LCD for an ATmega128 chip" in \EXAMPLES\2USART_LCD
 - Tiny5 Level Meter
 - uIP_Crumb644-Net_CVAVR web server
 - TWI Master-Slave
 
After starting CodeVisionAVR, execute the File|Open menu command and load the 
Project (*.prj) file for the example you like.
Then execute the Project|Build All menu command to compile and link the project.

Take some time and carefully read the Help.

