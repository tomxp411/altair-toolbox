10 REM Simple terminal program
20 REM Set PI and PD to the locations of your SIO board.
30 REM ^C to quit.
40 REM Donated to public domain Tom Wilson
50 PRINT "Simple Term: ^C to quit ^A c to send ^c"
100 PS=18 : REM SIO port 1 status register
110 PD=19 : REM SIO port 1 data register
198 REM Terminal loop. Read from keyboard and send,
199 REM then read from modem and print on console.
200 A$=INKEY$:IF A$="" THEN 300
210 IF A$=CHR$(1) THEN A$=INPUT$(1):A=ASC(A$) AND 31:A$=CHR$(A)
240 OUT PD,ASC(A$)
300 S=INP(PS) AND 1:IF S=0 THEN 200
310 A=INP(PD) : PRINT CHR$(A);
320 GOTO 200
