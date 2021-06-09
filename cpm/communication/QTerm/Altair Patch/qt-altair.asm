;
; QTerm patch for Altair 8800 2SIO with VT 100 terminal
; Leverages Serial Port on pins A6/A7 on Altair Dunio Pro kit
;
; September 2019, Udo Munk
; June 2021, Mark Lawler (simply updated Udo's work with new port values
;			  for the external RS232 port on the Altair-Dunio
;			  Pro kit)
;

INVERSE	SET	0		;conditional use inverse video

SIOAC	EQU	12H		;sio a control port
SIOAD	EQU	13H		;sio a data port
SIOBC	EQU	10H		;sio b control port
SIOBD	EQU	11H		;sio b data port

RXRDY	EQU	1		;receiver ready
TXRDY	EQU	2		;transmitter ready
	
	ORG	0110H
P1:	IN	SIOAC		;get modem input status
	ANI	RXRDY		;result to Z
	RET

	ORG	0120H
P2:	IN	SIOAD		;read modem input character
	RET

	ORG	0130H
P3:	IN	SIOAC		;get modem output status
	ANI	TXRDY		;result to Z
	RET

	ORG	0140H
P4:	OUT	SIOAD		;write modem output character
	RET

	ORG	0150H
	RET			;start break

	ORG	0160H
	RET			;stop break

	ORG	0170H
	RET			;drop DTR
	DB	00CH		;length of modem hang up string
	DB	0FEH,0FEH	;two delays
	DB	02BH,02BH,02BH	;+++
	DB	0FEH,0FEH	;two delays
	DB	041H,054H,048H,030H,0DH	;ATH0 <return>

	ORG	0180H
	RET			;restore DTR

	ORG	0190H
	RET			;set baud rate

	ORG	01A0H
	DB	0,0,0,0,0,0,0,0	;baud rate table
	DB	0,0,0,0,0,0,0,0

	ORG	01B0H
	RET			;set communication mode

	ORG	01C0H
	DB	0,0,0,0,0,0,0,0	;communication mode table
	DB	0,0,0,0

	ORG	01CDH
	DB	8		;number of K to read/write during file xfers

	ORG	01CEH
	DB	2		;CPU speed MHz

	ORG	01CFH
	DB	01EH		;escape character CTL-^

	ORG	01D0H
	DB	'ALTAIR 8800 - VT 100',0

	ORG	01F0H
	DB	1BH,'[2J'	;clear screen, home cursor
	DB	1BH,'[1;1H',0

	ORG	0200H
	PUSH	H		;move cursor
	MVI	C,1BH
	CALL	109H		;lead in escape
	MVI	C,'['
	CALL	109H		;print '['
	POP	H
	PUSH	H
	MOV	L,H
	MVI	H,0
	INR	L
	CALL	10CH		;print row in decimal
	MVI	C,';'
	CALL	109H		;print ';'
	POP	H
	PUSH	H
	MVI	H,0
	INR	L
	CALL	10CH		;print column in decimal
	MVI	C,'H'
	CALL	109H		;print 'H'
	POP	H
	RET

	ORG	022FH
	IF	INVERSE
	DB	11000011B	;terminal capabilities bitmap
	ENDIF
	IF NOT INVERSE
	DB	11000000B
	ENDIF
				;bit 0: end highlight mode
				;bit 1: start highlight mode
				;bit 2: delete line
				;bit 3: insert line
				;bit 4: delete character
				;bit 5: insert character
				;bit 6: clear to end of line
				;bit 7: clear to end of screen

	DB	1BH,'[m',0,0,0,0,0	;revers off
	DB	1BH,'[7m',0,0,0,0	;reverse on
	DB	0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0
	DB	1BH,'[0K',0,0,0,0	;clear to end of line
	DB	1BH,'[0J',0,0,0,0	;clear to end of screen

	ORG	0270H
	RET			;entry subroutine

	ORG	0273H
	RET			;exit subroutine

	ORG	0276H
	JMP	USER		;user subroutine

	ORG	0279H
	RET			;keyboard map subroutine

	ORG	0280H		;patch area
USER:	CALL	027CH		;call line prompt
	DB	'Enter modem channel A or B: ',0
	LDA	080H		;get answer
	CPI	'a'		;channel A?
	JZ	CHANA
	CPI	'A'
	JZ	CHANA
	CPI	'b'		;channel B?
	JZ	CHANB
	CPI	'B'
	JZ	CHANB
	RET			;no, don't change

CHANA:				;set modem to channel A
	MVI	A,SIOAC
	STA	P1+1
	STA	P3+1
	MVI	A,SIOAD
	STA	P2+1
	STA	P4+1
	RET

CHANB:				;set modem to channel B
	MVI	A,SIOBC
	STA	P1+1
	STA	P3+1
	MVI	A,SIOBD
	STA	P2+1
	STA	P4+1
	RET

	END
