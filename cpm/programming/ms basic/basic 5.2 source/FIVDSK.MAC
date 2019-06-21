	SUBTTL	Common file for BASIC interpreter
	.SALL	

CONTO	SET	15			;CHARACTER TO SUPRESS OUTPUT (USUALLY CONTROL-O)
DBLTRN	SET	0			;FOR DOUBLE PRECISION TRANSCENDENTALS
	IF2	

	.PRINTX	/EXTENDED/


	.PRINTX	/LPT/

	.PRINTX	/CPM DISK/


	.PRINTX	/Z80/

	.PRINTX	/FAST/

	.PRINTX	/5.0 FEATURES/

	.PRINTX	/ANSI COMPATIBLE/
	ENDIF

CLMWID	SET	14			;MAKE COMMA COLUMNS FOURTEEN CHARACTERS
DATPSC	SET	128			;NUMBER OF DATA BYTES IN DISK SECTOR
LINLN	SET	80			;TERMINAL LINE LENGTH 
LPTLEN	SET	132
BUFLEN	SET	255			;LONG LINES
NAMLEN	SET	40			;MAXIMUM LENGTH NAME -- 3 TO 127

NUMLEV	SET	0*20+19+2*5		;NUMBER OF STACK LEVELS RESERVED
					;BY AN EXPLICIT CALL TO GETSTK

STRSIZ	SET	4

STRSIZ	SET	3
NUMTMP	SET	3			;NUMBER OF STRING TEMPORARIES

NUMTMP	SET	10

MD.RND	SET	3			;THE MODE NUMBER FOR RANDOM FILES
MD.SQI	SET	1			;THE MODE NUMBER FOR SEQUENTIAL INPUT FILES
					;NEVER WRITTEN INTO A FILE
MD.SQO	SET	2			;THE MODE FOR SEQUENTIAL OUTPUT FILES
					;AND PROGRAM FILES
CPMWRM	SET	0			;CP/M WARM BOOT ADDR
CPMENT	SET	CPMWRM+5		;CP/M BDOS CALL ADDR
	CSEG	
TRUROM	SET	0
	PAGE
	TITLE	FIVDSK 5.0 Features - Variable length records, Protected files /P. Allen
	.SALL	

	EXTRN	DCOMPR
	EXTRN	CHRGTR,SYNCHR
;
;The 5.0 Disk code is essentially an extra level of buffering
;for random disk I/O files. Sequential I/O is not
;affected by the 5.0 code. Great care has been taken to
;insure compatibility with existing code to support diverse
;operating systems. The 5.0 disk code has its
;own data structure for handling the variable length
;records in random files. This data structure sits right after
;the regular data block for the file and consumes an amount of 
;memory equal to  MAXREC (The maximum allowed record size) plus
;9 bytes.
;
;Here is the content of the data block:
;
;FD.SIZ size 2			;Variable length record size default 128
;FD.PHY size 2			;Current physical record #
;FD.LOG size 2			;Current logical record number
;FD.CHG size 1			;Future flag for accross block PRINTs etc.
;FD.OPS size 2			;Output print position for PRINT, INPUT, WRITE
;FD.DAT size FD.ZSIZ		;Actual FIELD data buffer
;				;Size is FD.SIZ bytes long
;
;DATE				FIX
;----				---
;8/6/179				Make PUT, GET increment LOC correctly
;8/14/1979			PUUut in BASIC COCOcompiler switch (main source)
;%
	EXTRN	DATOFS,DERBFM,DERBRN,FCERR,MAXTRK,FIVDPT,LOCOFS
	EXTRN	FD.SIZ,FD.PHY,FD.LOG,FD.CHG,FD.OPS,FD.DAT
	EXTRN	DERFOV,NMLOFS
	EXTRN	FILSCN,PROFLG,CURLIN,SINCON,ATNCON,GTMPRT
	EXTRN	TEMP,TXTTAB,VARTAB,SNERR,MAXREC
	PAGE
	SUBTTL	VARECS - Variable record scan for OPEN
	PUBLIC	VARECS,TEMPB,FILOFV,FILIFV,CMPFBC

;	Enter VARECS with file mode in [A]

VARECS:	CPI	MD.RND			;Random?
	RNZ				;No, give error later if he gave record length
	DCX	H			;Back up pointer
	CALL	CHRGTR			;Test for eol
	PUSH	D			;Save [D,E]
	LXI	D,0+DATPSC		;Assume record length=DATPSC
	JZ	NOTSEP			;No other params for OPEN
	PUSH	B			;Save file data block pointer
	EXTRN	INTIDX
	CALL	INTIDX			;Get record length
	POP	B			;Get back file data block
NOTSEP:	PUSH	H			;Save text pointer
	LHLD	MAXREC			;Is size ok?
	CALL	DCOMPR
	JC	FCERR			;No, give error
	LXI	H,0+FD.SIZ		;Stuff into data block
	DAD	B
	MOV	M,E
	INX	H
	MOV	M,D
	XRA	A			;Clear other bytes in data block
	MVI	E,7			;# of bytes to clear
ZOFIVB:	INX	H			;Increment pointer
	MOV	M,A			;Clear byte
	DCR	E			;Count down
	JNZ	ZOFIVB			;Go back for more
	POP	H			;Text pointer 
	POP	D			;Restore [D,E]
	RET	
	PAGE
	SUBTTL	PUT AND GET STATEMENTS

	PUBLIC	GET,PUT
PUT:	DB	366O			;"ORI"to set non-zero flag
GET:	XRA	A			;Set zero
	STA	PGTFLG			;Save flag
	CALL	FILSCN			;Get pointer at file data block
	CPI	MD.RND			;Must be a random file
	JNZ	DERBFM			;If not, "Bad file mode"
	PUSH	B			;Save pointer at file data block
	PUSH	H			;Save text pointer
	LXI	H,0+FD.LOG		;Fetch current logical posit
	DAD	B
	MOV	E,M
	INX	H
	MOV	D,M
	INX	D			;Compensate for "DCX D" when call INTIDX
	XTHL				;Save data block pointer and get text pointer
	MOV	A,M
	CPI	44			;Is there a record number
	CZ	INTIDX			;Read it if there, 1-indexed
	DCX	H			;Make sure statement ends
	CALL	CHRGTR
	JNZ	SNERR
	XTHL				;Save text pointer, get data block pointer
	MOV	A,E			;Get record #
	ORA	D			;Make sure its not zero
	JZ	DERBRN			;If so, "Bad record number"
	DCX	H
	MOV	M,E
	INX	H
	MOV	M,D
	DCX	D
	POP	H			;Get back text pointer 
	POP	B
	PUSH	H			;Save back text pointer 
	PUSH	B			;Pointer to file data block
	LXI	H,0+FD.OPS		;Zero output file posit
	DAD	B
	XRA	A
	MOV	M,A
	INX	H
	MOV	M,A
	LXI	H,0+FD.SIZ		;Get logical record size in [D,E]
	DAD	B
	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A
	XCHG				;Record size to [D,E], posit in [H,L]
	PUSH	D			;Save record size (count of bytes)
; Record size in [D,E]
; Logical position in [H,L]
; This code computes physical record # in [H,L]
; offset into buffer in [D,E]
	PUSH	H			;Save logical posit
	LXI	H,0+DATPSC		;Get sector size
	CALL	DCOMPR			;Compare the two
	POP	H			;Restore logical posit
	JNZ	NTLSAP			;If record size=sector size, done
	LXI	D,0			;Set offset to zero
	JMP	DONCLC			;Done with calculations
NTLSAP:	MOV	B,D			;Copy record size to [B,C]
	MOV	C,E
	MVI	A,20O			;16 by 16 multiply
	XCHG				;Put multiplier in [D,E]
	LXI	H,0			;Set both parts of product to zero
	PUSH	H			;2nd part is on stack
FRMUL1:	DAD	H
	XTHL	
	JNC	FNOCRY
	DAD	H
	INX	H
	JMP	FNOCY0
FNOCRY:	DAD	H
FNOCY0:	XTHL	
	XCHG	
	DAD	H			;Rotate [D,E] left one
	XCHG	
	JNC	FNOCY2			;Add in [B,C] if Ho=1
	DAD	B
	XTHL	
	JNC	FNOINH
	INX	H
FNOINH:	XTHL	
FNOCY2:	DCR	A			;are we done multiplying
	JNZ	FRMUL1			;No, go back for next bit of product
; Now divide by the number of bytes in a sector
	IFF	DATPSC-256
	MOV	E,L			;Remainder is just low byte
	MVI	D,0			;Of which HO is 0
	MOV	L,H			;Annd record # is shifted down
	POP	B			;Get most sig. Byte of record #
	MOV	H,C			;set record # to it
	MOV	A,B			;Make sure rest=0
	ORA	A
	JNZ	FCERR
	ENDIF				;UH-OH
	IF	DATPSC-128
	IF	DATPSC-256
	POP	D			;Get high word of dividend in [D,E]
	LXI	B,0			;Set dividend to zero.
KEPSUB:	PUSH	B			;Save dividend
	LXI	B,0-DATPSC		;Get divisor (# of bytes sector)
	DAD	B			;Subtract it
	JC	GUARCY			;Carry from low bytes implies cary from high
	XCHG				;Subtract -1 from high byte
	LXI	B,0-1
	DAD	B
	XCHG				;Put result back where it belongs
GUARCY:	POP	B			;Restore dividend
	JNC	DONDIV			;Finished
	INX	B			;Add one to it
	MOV	A,B			;See if overflowed
	ORA	C
	JNZ	KEPSUB			;Keep at it till done
	JMP	FCERR			;Yes give error
DONDIV:	PUSH	B			;Save dividend
	LXI	B,0+DATPSC		;Correct for one too many subtraction
	DAD	B			;By adding divisor back in
	POP	D			;Dividend ends up in [D,E], Remainder in [H,L]
	XCHG	
	ENDIF
	ENDIF				;Put values in right regs for rest of code
	IFF	DATPSC-128
	MOV	A,L			;Get low byte of result
	ANI	127			;Get rid of high bit
	MOV	E,A			;this is it
	MVI	D,0			;Set high byte of remainder to zero
	POP	B			;Get high word of product
	MOV	A,L			;Get MSB of low word
	MOV	L,H
	MOV	H,C
	DAD	H			;Make space for it
	JC	FCERR			;UH-OH record # to big!
	RAL				;Is it set?
	JNC	DONINH			;Not set
	INX	H			;Copy it into low bit
DONINH:	MOV	A,B			;Get high byte of record #
	ORA	A			; Is it non-zero
	JNZ	FCERR
	ENDIF				;Bad
DONCLC:
; At this point, record #is in [H,L]
; offset into record in [D,E]
; Stack:
; COUNT of bytes to read or write
; data block
; Text pointer
; Return Address
	SHLD	RECORD			;Save record size
	POP	H			;Get count
	POP	B			;Pointer to file data block
	PUSH	H			;Save back count
	LXI	H,0+FD.DAT		;Point to Field buffer
	DAD	B			;Add start of data block
	SHLD	LBUFF			;Save pointer to FIELD buffer
NXTOPD:	LXI	H,0+DATOFS		;Point to physical buffer
	DAD	B			;Add file block offset
	DAD	D
	SHLD	PBUFF			;Save
	POP	H			;Get count
	PUSH	H			;Save count
	LXI	H,0+DATPSC		;[H,L]=DATPSC-offset
	MOV	A,L
	SUB	E
	MOV	L,A
	MOV	A,H
	SBB	D
	MOV	H,A
	POP	D			;Get back count (destroy offset)
	PUSH	D			;Save COUNT
	CALL	DCOMPR			;Which is smaller, count or DATPSC-offset?
	JC	DATMOF			;The latter
	MOV	H,D			;Copy count into bytes
	MOV	L,E
DATMOF:	LDA	PGTFLG			;PUT or GET
	ORA	A			;Set cc's
	JZ	FIVDRD			;Was Read
	LXI	D,0+DATPSC		;If bytes .LT. DATPSC then read(sector)
	CALL	DCOMPR
	JNC	NOFVRD			;(Idea-if writing full buffer, no need to read)
	PUSH	H			;Save bytes
	CALL	GETSUB			;Read record.
	POP	H			;Bytes
NOFVRD:	PUSH	B
	MOV	B,H
	MOV	C,L
	LHLD	PBUFF
	XCHG	
	LHLD	LBUFF			;Get ready to move bytes between buffers
	CALL	FDMOV			;Move bytes to physical buffer
	SHLD	LBUFF			;Store updated pointer
	MOV	D,B			;COUNT TO [D,E]
	MOV	E,C
	POP	B			;Restore FDB pointer
	CALL	PUTSUB			;Do write
NXFVBF:	POP	H			;Count
	MOV	A,L			;Make count correct
	SUB	E
	MOV	L,A
	MOV	A,H
	SBB	D
	MOV	H,A
	ORA	L			;Is count zero?
	LXI	D,0			;Set offset=0
	PUSH	H			;Save COUNT
	LHLD	RECORD
	INX	H			;Increment it
	SHLD	RECORD			;Save back
	JNZ	NXTOPD			;Keep working on it
	POP	H			;Get rid of COUNT
	POP	H			;Restore text pointer
	RET				;Done

; Read code
; [H,L]=bytes
; [D,E]=count
FIVDRD:	PUSH	H			;Save bytes
	CALL	GETSUB			;Do read
	POP	H			;Get back bytes
	PUSH	B
	MOV	B,H
	MOV	C,L
	LHLD	LBUFF			;Point to logical buffer
	XCHG	
	LHLD	PBUFF
	CALL	FDMOV
	XCHG				;Get pointer to FIELD buffer in [H,L]
	SHLD	LBUFF			;Save back updated logical buffer
	MOV	D,B			;COUNT TO [D,E]
	MOV	E,C
	POP	B
	JMP	NXFVBF
PUTSUB:	DB	366Q
GETSUB:	XRA	A
	STA	MAXTRK			;GET/PUT Fflag
	PUSH	B
	PUSH	D
	PUSH	H
	LHLD	RECORD
	XCHG	
	LXI	H,0+FD.PHY		;Point to physical record #
	DAD	B			;Add offset to file buffer
	PUSH	H			;Save this pointer
	MOV	A,M			;Get current phys. rec #
	INX	H
	MOV	H,M
	MOV	L,A
	INX	D
	CALL	DCOMPR			;Do we already have record in buffer
	POP	H			;Restore pointer
	MOV	M,E
	INX	H
	MOV	M,D			;Store new record number
	JNZ	NTREDS			;Curent and previos record numbers are different
	LDA	MAXTRK			;Trying to do read?
	ORA	A
	JZ	SUBRET			;If trying to read and record already
					;in buffer, do nothing
NTREDS:	LXI	H,SUBRET		;Where to return to
	PUSH	H
	PUSH	B			;File data block
	PUSH	H			;Dummy text pointer
	LXI	H,0+LOCOFS+1		;where [H,L] is expected to be
	DAD	B
	JMP	FIVDPT			;Call old PUT/GET
SUBRET:	POP	H
	POP	D
	POP	B
	RET				;Restore all regs and return to caller

; Move bytes from [H,L] to [D,E] [B,C] times
FDMOV:	PUSH	B			;Save count
FDMOV1:	MOV	A,M			;Get byte
	STAX	D			;Store it
	INX	H
	INX	D
	DCX	B			;Decrement count
	MOV	A,B			;Gone to zero?
	ORA	C
	JNZ	FDMOV1			;Go back for more
	POP	B			;Return with count in [D,E]
	RET	

FILOFV:	POP	PSW			;Get character off stack
	PUSH	D			;Save [D,E]
	PUSH	B			;Save [B,C]
	PUSH	PSW			;Save back char
	MOV	B,H			;[B,C]=file data block
	MOV	C,L
	CALL	CMPFPS			;Any room in buffer
	JZ	DERFOV			;No
	CALL	SETFPI			;save new position
	LXI	H,0+FD.DAT-1		;Index into data buffer
	DAD	B			;Add start of file control block
	DAD	D			;Add offset into buffer
	POP	PSW			;Get back char
	MOV	M,A			;Store in buffer
	PUSH	PSW			;Save char
	LXI	H,0+NMLOFS		;Set up [H,L] to point at print posit
	DAD	B
	MOV	D,M			;Get present position
	MVI	M,0			;Assume set it to zero
	CPI	13			;Is it <Cr>?
	JZ	FISCR			;Yes
	ADI	224			;Set carry for spaces & higher
	MOV	A,D			;Add one to current posit
	ACI	0
	MOV	M,A
FISCR:	POP	PSW			;Restore all regs
	POP	B
	POP	D
	POP	H
	RET	

FILIFV:	PUSH	D			;Save [D,E]
	CALL	CMPFBC			;Compare to present posit
	JZ	DERFOV			;Return with null 
	CALL	SETFPI			;Set new position
	LXI	H,0+FD.DAT-1		;Point to data
	DAD	B
	DAD	D
	MOV	A,M			;Get the byte
	ORA	A			;Clear carry (no EOF)
	POP	D			;Restore [D,E]
	POP	H			;Restore [H,L]
	POP	B			;Restore [B,C]
	RET	

GETFSZ:	LXI	H,0+FD.SIZ		;Point to record size
	JMP	GETFP1			;Continue
GETFPS:	LXI	H,0+FD.OPS		;Point to output position
GETFP1:	DAD	B			;Add offset into buffer
	MOV	E,M			;Get value
	INX	H
	MOV	D,M
	RET	

SETFPI:	INX	D			;Increment current posit
SETFPS:	LXI	H,0+FD.OPS		;Point to output position
	DAD	B			;Add file control block address
	MOV	M,E
	INX	H
	MOV	M,D
	RET	
CMPFBC:	MOV	B,H			;Copy file data block into [B,C]
	MOV	C,L
CMPFPS:	CALL	GETFPS			;Get present posit
	PUSH	D			;Save it
	CALL	GETFSZ			;Get file size
	XCHG				;into [H,L]
	POP	D			;Get back posit
	CALL	DCOMPR			;See if were at end
	RET	

	PAGE
	SUBTTL	Protected files

	PUBLIC	PROLOD
	EXTRN	BINPSV
	PUBLIC	PROSAV
PROSAV:	CALL	CHRGTR			;Get char after "S"
	SHLD	TEMP			;Save text pointer
	EXTRN	SCCPTR
	CALL	SCCPTR			;Get rid of GOTO pointers
	CALL	PENCOD			;encode binary
	MVI	A,254			;Put out 254 at start of file
	CALL	BINPSV			;Do SAVE
	CALL	PDECOD			;Re-decode binary
	JMP	GTMPRT			;Back to NEWSTT

N1	SET	11			;Number of bytes to use from ATNCON
N2	SET	13			;Number of bytes to use from SINCON
	PUBLIC	PENCOD
PENCOD:	LXI	B,0+N1+N2*256		;Initialize both counters
	LHLD	TXTTAB			;Starting point
	XCHG				;Into [D,E]
ENCDBL:	LHLD	VARTAB			;At end?
	CALL	DCOMPR			;Test
	RZ				;Yes
	LXI	H,ATNCON		;Point to first scramble table
	MOV	A,L			;Use [C] to index into it
	ADD	C
	MOV	L,A
	MOV	A,H
	ACI	0
	MOV	H,A
	LDAX	D			;Get byte from program
	SUB	B			;Subtract counter for no reason
	XRA	M			;XOR entry
	PUSH	PSW			;Save result
	LXI	H,SINCON		;calculate offset into SINCON using [B]
	MOV	A,L
	ADD	B
	MOV	L,A
	MOV	A,H
	ACI	0
	MOV	H,A
	POP	PSW			;Get back current byte
	XRA	M			;XOR on this one too
	ADD	C			;Add counter for randomness
	STAX	D			;Store back in program
	INX	D			;Incrment pointer
	DCR	C			;decrment first table index
	JNZ	CNTZER			;Still non-Zero
	MVI	C,N1			;Re-initialize counter 1
CNTZER:	DCR	B			;dedecrement counter-2
	JNZ	ENCDBL			;Still non-zero, go for more
	MVI	B,N2			;Re-initialize counter 2
	JMP	ENCDBL			;Keep going until done
PROLOD:
PDECOD:	LXI	B,0+N1+N2*256		;Initialize both counters
	LHLD	TXTTAB			;Starting point
	XCHG				;Into [D,E]
DECDBL:	LHLD	VARTAB			;At end?
	CALL	DCOMPR			;Test
	RZ				;Yes
	LXI	H,SINCON		;calculate offset into SINCON using [B]
	MOV	A,L
	ADD	B
	MOV	L,A
	MOV	A,H
	ACI	0
	MOV	H,A
	LDAX	D			;Get byte from program
	SUB	C			;Subtract counter for randomness
	XRA	M			;XOR on this one too
	PUSH	PSW			;Save result
	LXI	H,ATNCON		;Point to first scramble table
	MOV	A,L			;Use [C] to index into it
	ADD	C
	MOV	L,A
	MOV	A,H
	ACI	0
	MOV	H,A
	POP	PSW			;Get back current byte
	XRA	M			;XOR entry
	ADD	B			;Add counter for no reason
	STAX	D			;Store back in program
	INX	D			;Increment pointer
	DCR	C			;decrment first table index
	JNZ	CNTZR2			;Still non-Zero
	MVI	C,N1			;Re-initialize counter 1
CNTZR2:	DCR	B
	JNZ	DECDBL			;Decrement counter-2, Still non-zero, go for more
	MVI	B,N2			;Re-initialize counter 2
	JMP	DECDBL			;Keep going until done

	PUBLIC	PROCHK,PRODIR
PRODIR:	PUSH	H			;Save [H,L]
	LHLD	CURLIN			;Get current line #
	MOV	A,H			;Direct?
	ANA	L
	POP	H			;Restore [H,L]
	INR	A			;If A=0, direct
	RNZ	
PROCHK:	PUSH	PSW			;Save flags
	LDA	PROFLG			;Is this a protected file?
	ORA	A			;Set CC's
	JNZ	FCERR			;Yes, give error
	POP	PSW			;Restore flags
	RET	

TEMPB:					;Used by FIELD
RECORD:	DS	2			;Record #
LBUFF:	DS	2			;Logical buffer address
PBUFF:	DS	2			;Physical buffer address
PGTFLG:	DS	1			;PUT/GET flag (Non zero=PUT)

	END	
                     