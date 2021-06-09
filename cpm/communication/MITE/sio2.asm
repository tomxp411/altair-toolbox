;;;	sio2 - CIOS for MITE utility / IMSAI SIO2-2 + Smartmodem verison
;
;	L.E. Hughes
;
;	Mycroft Labs, Inc.
;	P.O. Box 6045
;	Tallahassee, FL 32301
;
;	(904) 385-2708
;
;	Modified June 2021 by Mark Lawler for Altair Duino 8800 2SIO
;	external serial port.
;
stat	equ	012H
data	equ	013H
ctrl	equ	010H
 
cr	equ	0DH		;carriage return
lf	equ	0AH		;line feed
eos	equ	'$'		;end of string
 
	org	180H

;;	jump vector
;
 
	jmp	initm
	jmp	modin
	jmp	modout
	jmp	chkrr
	jmp	chktr
	jmp	chkcd
	jmp	chkpe
	jmp	chkfe
	jmp	chkoe
	jmp	chkri
	jmp	setbr
	jmp	setpar
	jmp	set8db
	jmp	set2sb
	jmp	setorg
	jmp	setoh
	jmp	settxe
	jmp	setbrk
	jmp	dial
	jmp	tenths
	jmp	w1ms

;;;	initm - initialize modem
;

initm:	mvi	a,40H
	out	stat
	mvi	a,01111010B
	out	stat
	sta	cr1
	mvi	a,00100111B
	out	stat
	sta	cr2
	ret
 
;;;	modin - input character from modem
;
;	exit:	A	character from modem
 
modin:	in	data
	ret

;;;	modout - output character to modem
;
;	entry:	A	character for modem

modout:	out	data
	ret
 
;;;	chkrr - check for receiver ready
;
;	exit:	c-flag	set if character available

chkrr:	in	stat
	ani	01H
	jz	chkrr1
	stc
	ret
chkrr1:	ora	a
	ret
 
;;;	chktr - check for tranmitter ready
;
;	exit:	c-flag	set if transmitter ready

chktr:	in	stat
	ani	02H
	jz	chktr1
	stc
	ret
chktr1:	ora	a
	ret

;;	chkcd - check for carrier detect
;
;	exit:	c-flag	set if carrier present

chkcd:	in	ctrl
	ani	40H
	jnz	chkcd1
	stc
	ret
chkcd1:	ora	a
	ret

;;;	chkpe - check for parity error
;
;	exit:	c-flag set if parity error
 
chkpe:	in	stat
	ani	08H
	jz	chkpe1
	stc
	ret
chkpe1:	ora	a
	ret
 
;;;	chkfe - check for frame error
;
;	exit:	c-flag set if frame error
 
chkfe:	in	stat
	ani	20H
	jz	chkfe1
	stc
	ret
chkfe1:	ora	a
	ret
 
;;;	chkoe - check for overrun error
;
;	exit:	c-flag set if overrun error
 
chkoe:	in	stat
	ani	10H
	jz	chkoe1
	stc
	ret
chkoe1:	ora	a
	ret
 
;;;	chkri - check for ring indicate
;
;	exit:	c-flag	set if incoming call
 
chkri:	stc
	ret
 
;;;	setbr - set baud rate
;
;	entry:	HL	baud rate
;
;	exit:	c-flag	set if error
 
setbr:	lxi	d,300
	call	cmpde
	jnz	setbr1
	mvi	b,01H
	call	cr1on
	ora	a
	ret
setbr1:	lxi	d,1200
	call	cmpde
	jnz	setbr2
	mvi	b,01H
	call	cr1off
	ora	a
	ret
setbr2:	lxi	d,2400
	call	cmpde
	jnz	setbr3
	mvi	b,01H
	call	cr1off
	ora	a
	ret
setbr3:	lxi	d,4800
	call	cmpde
	jnz	setbr4
	mvi	b,01H
	call	cr1off
	ora	a
	ret
setbr4:	lxi	d,9600
	call	cmpde
	jnz	setbr5
	mvi	b,01H
	call	cr1off
	ora	a
	ret
setbr5:	stc
	ret
 
;;;	setpar - set parity
;
;	entry:	A	parity select code:
;				0 = NONE
;				1 = ODD
;				2 = EVEN

setpar:	ora	a		;jump if A .ne. 0
	jnz	setp1
	mvi	b,10H
	jmp	cr1off
setp1:	dcr	a		;jump if A .ne. 1
	jnz	setp2
	mvi	b,10H
	call	cr1on
	mvi	b,20H
	jmp	cr1off
setp2:	mvi	b,10H
	call	cr1on
	mvi	b,20H
	jmp	cr1on

;;;	set8db - set number of data bits
;
;	entry:	A	data bits select code:
;				0 = 7 data bits
;				1 = 8 data bits

set8db:	ora	a		;jump if A .ne. 0
	jnz	set8d1
	mvi	b,04H
	call	cr1off
	ret
set8d1:	mvi	b,04H
	call	cr1on
	ret
 
;;;	set2sb - set number of stop bits
;
;	entry:	A	stop bits select code:
;				0 = 1 stop bit
;				1 = 2 stop bits
 
set2sb:	ora	a		;jump if A .ne. 0
	jnz	set2s1
	mvi	b,80H
	jmp	cr1off
set2s1:	mvi	b,80H
	jmp	cr1on
 
;;;	setorg - set modem mode (answer or originate)
;
;	entry:	A	mode select code:
;				0 = answer
;				1 = originate

setorg:	ret
 
;;;	setoh - set phone "off hook"
;
;	entry:	A	hook select code:
;				0 = on hook (hung up)
;				1 = off hook
 
setoh:	ora	a
	jnz	setoh1
	mvi	b,02H
	jmp	cr2off
setoh1:	mvi	b,02H
	jmp	cr2on

;;;	settxe - set transmitter enable
;
;	entry:	A	transmitter enable code:
;				0 = disabled
;				1 = enabled
 
settxe:	ret
	
;;;	setbrk - set communications line break
;
;	entry:	A	break enable code:
;				0 = normal
;				1 = break
 
setbrk:	ora	a		;jump if A .ne. 0 (break)
	jnz	setbk1
	mvi	b,08H
	jmp	cr2off
setbk1:	mvi	b,08H
	jmp	cr2on

 
;;	cr1on - turn on bit(s) on modem control reg. one
;
;	entry conditions
;
;		b	ones in positions to turn on
 
cr1on:	push	psw
	mvi	a,40H
	out	stat
	lda	cr1
	ora	b
	sta	cr1
	out	stat
	lda	cr2
	out	stat
	pop	psw
	ret
 
;;	cr1off - turn bit(s) off on modem control reg. one
;
;	entry conditions
;
;		b	ones in positions to turn off
 
cr1off:	push	psw
	mvi	a,40H
	out	stat
	mov	a,b
	cma
	mov	b,a
	lda	cr1
	ana	b
	sta	cr1
	out	stat
	lda	cr2
	out	stat
	pop	psw
	ret
 
;;	cr2on - turn on bit(s) on modem control reg. two
;
;	entry conditions
;
;		b	ones in positions to turn on
 
cr2on:	push	psw
	lda	cr2
	ora	b
	sta	cr2
	out	stat
	pop	psw
	ret
 
;;	cr2off - turn bit(s) off on modem control reg. two
;
;	entry conditions
;
;		b	ones in positions to turn off
 
cr2off:	push	psw
	mov	a,b
	cma
	mov	b,a
	lda	cr2
	ana	b
	sta	cr2
	out	stat
	pop	psw
	ret
 
;;;	cmpde - compare de to hl
;
;	exit:	c-flag	set if de < hl
;		z-flag	set if de = hl

cmpde:	mov	a,h
	cmp	d
	rnz
	mov	a,l
	cmp	e
	ret
 
;;;	dial - dial phone number
;
;	entry:	HL	points to phone number, term by 0 byte

dial:	push	h
	lxi	d,str1		;point to header string
	call	wasm		;write to 'modem'
	pop	h
dial1:	mov	a,m		;fetch next digit
	ora	a		;jump if end of string
	jz	dial2
	call	wacm		;write to modem
	inx	h
	jmp	dial1
dial2:	mvi	a,cr		;issue CR
	call	wacm
	ret

;;	wasm - write ASCII string to modem
;
 
wasm:	ldax	d
	cpi	'$'
	rz
	call	wacm
	inx	d
	jmp	wasm
 
;;	wacm - write ASCII character to modem
;
 
wacm:	push	psw
wacm1:	call	chktr
	jnc	wacm1
	pop	psw
	jmp	modout
 
;;	racm - read ASCII character from modem
;
 
racm:	call	chkrr
	jnc	racm
	jmp	modin
 
;;	tenths - wait B tenths of a second
;
;	entry:	B	number of tenths of a second to wait

tenths:	call	tenth
	dcr	b
	jnz	tenths
	ret
 
;;	tenth - wait 1 tenth of a second
;
 
tenth:	push	b
	mvi	b,100
tenth1:	call	w1ms
	dcr	b
	jnz	tenth1
	pop	b
	ret

;;	w1ms - wait one millisecond
;
 
w1ms:	push	psw
	push	h
	lxi	h,160
w1ms1:	dcx	h
	mov	a,h
	ora	l
	jnz	w1ms1
	pop	h
	pop	psw
	ret
 
str1:	db	cr,'AT D$'	;SMARTMODEM dial header
 
cr1:	ds	1
cr2:	ds	1
 
	end	sio2