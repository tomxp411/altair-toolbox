From Mark Lawler on the Altairduino Google Group:

Thanks to the help of Tom Wilson and Udo I have a patched copy of QTERM and it appears that it works with the RS232 port built into the Altair Duino 8800 Pro kit.  I modified Udo's QT-IMSAI.ASM (now called QT-ALTD.ASM -- I wanted to show it was tested with the Duino version vs. a real one) and patched it into QTERM to create a QT-ALTD.COM version.  

Control+^ is the break character
Control+^U calls up the user defined port selection (defaults to A)
A -- Pins A6/A7 serial port (which is the physical RS232 connector on the back of the Altair Duino 8800 Pro Kit)
B -- Pins A18/19 serial port (which is used by the VGA emulator on the Pro card)

To install...
Assemble QT-ALTD.asm
ASM QT-ALTD
Load a copy of QTERM.COM into memory using DDT (I used Udo's QT-IMSAI.COM)
DDT QT-IMSAI.COM
Load the patch into memory
IQT-ALTD.HEX
R
Control+C
Save new executable
SAVE 69 QT-ALTD.COM
Sorry, but I wasn't able to upload my patched QT-ALTD.COM up as an attachment...

