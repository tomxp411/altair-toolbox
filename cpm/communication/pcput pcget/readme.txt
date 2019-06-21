PCPUT and PCGET are simple XMODEM file transfer programs for 
CPM. This version is assembled for the Altair 8800.

PCGET transfers from your PC to the Altair.
PCPUT transfers from the Altair to your PC. 

See the ASM files for more details and attribution.

;
;  PCGET  This CP/M program will obtain a file from a PC sent via a serial 
;  port and write it to file on the CP/M system. The program on the PC
;  should send the file in a XModem format/protocol. (Use Absolute Telnet).
;
;  The program seems to work up to at least 38,400 Baud fine. 
;  Note this is just the gutted Ward Christenson Modem program,
;  This program can be assembled to utilize the serial ports of the SD-Systems 
;  Serial IO board or the S100Computers/N8VEM Serial-IO Board. 
;  It can be easily modified for most other serial ports.
;
;	John Monahan	2/8/2013		(monahan@vitasoft.org)
;

;
;  PCPUT.COM  This CP/M program will send a file to a PC sent via a serial 
;  port and write it as an MSDOS file. The program on the PC
;  should recieve the file in a XModem format/protocol. (Use Absolute Telnet).
;
;  The program seems to work up to at least 38,400 Baud fine. 
;  Note this is just the gutted Ward Christenson Modem program,
;  This program can be assembled to utilize the serial ports of the SD-Systems 
;  Serial IO board or the S100Computers/N8VEM Serial-IO Board. 
;  It can be easily modified for most other serial ports.
;
;	John Monahan	2/8/2013		(monahan@vitasoft.org)
;
