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
	TITLE	FIVEO 5.0 Features -WHILE/WEND, CALL, CHAIN, WRITE /P. Allen
	.SALL	
	EXTRN	CHRGTR,SYNCHR,DCOMPR
	EXTRN	GETYPR
	EXTRN	SNERR,GETSTK,PTRGET,SUBFLG,TEMP,CRDO
	EXTRN	VMOVFM,FRCINT
	PAGE
	SUBTTL	WHILE, WEND
	PUBLIC	WHILE,WEND
	EXTRN	ENDFOR,ERROR,FRMEVL,$FOR,$WHILE,WNDSCN
	EXTRN	SAVSTK,NEWSTT,NXTLIN,CURLIN,FORSZC,ERRWE
;
; THIS CODE HANDLES THE STATEMENTS WHILE/WEND
; THE 8080 STACK IS USED TO PUT AN ENTRY ON FOR EACH ACTIVE WHILE
; THE SAME WAY ACTIVE GOSUB AND FOR ENTRIES ARE MADE.
; THE FORMAT IS AS FOLLOWS:
;	$WHILE - THE TOKEN IDENTIFYING THE ENTRY (1 BYTE)
;	A TEXT POINTER AT THE CHARACTER AFTER THE WEND OF THE WHILE BODY (2 BYTES)
;	A TEXT POINTER AT THE CHARACTER AFTER THE WHILE OF THE WHILE BODY (2 BYTES)
;	THE LINE NUMBER OF THE LINE THAT THE WHILE IS ON (2 BYTES)
;
;	TOTAL	7 BYTES
;
WHILE:	SHLD	ENDFOR			;KEEP THE WHILE TEXT POINTER HERE
	CALL	WNDSCN			;SCAN FOR THE MATCHING WEND
					;CAUSE AN ERRWH IF NO WEND TO MATCH
	CALL	CHRGTR			;POINT AT CHARACTWER AFTER WEND
	XCHG				;[D,E]= POSITION OF MATCHING WEND
	CALL	FNDWND			;SEE IF THERE IS A STACK ENTRY FOR THIS WHILE
	INX	SP			;GET RID OF THE NEWSTT ADDRESS ON THE STACK
	INX	SP
	JNZ	WNOTOL			;IF NO MATCH NO NEED TO TRUNCATE THE STACK
	DAD	B			;ELIMINATE EVERYTHING UP TO AND INCLUDING
					;THE MATCHING WHILE ENTRY
	SPHL	
	SHLD	SAVSTK
WNOTOL:	LHLD	CURLIN			;MAKE THE STACK ENTRY
	PUSH	H
	LHLD	ENDFOR			;GET TEXT POINTER FOR WHILE BACK
	PUSH	H
	PUSH	D			;SAVE THE WEND TEXT POINTER
	JMP	FNWEND			;FINISH USING WEND CODE

WEND:	JNZ	SNERR			;STATEMENT HAS NO ARGUMENTS
	XCHG				;FIND MATCHING WHILE ENTRY ON STACK
	CALL	FNDWND
	JNZ	WEERR			;MUST MATCH OR ELSE ERROR
	SPHL				;TRUNCATE STACK AT MATCH POINT
	SHLD	SAVSTK
	XCHG				;SAVE [H,L] POINTING INTO STACK ENTRY
	LHLD	CURLIN			;REMEMBER WEND LINE #
	SHLD	NXTLIN			;IN NXTLIN
	XCHG	
	INX	H			;INDEX INTO STACK ENTRY TO GET VALUES
	INX	H			;SKIP OVER TEXT POINTER OF WEND
	MOV	E,M			;SET [D,E]=TEXT POINTER OF WHILE
	INX	H
	MOV	D,M
	INX	H
	MOV	A,M			;[H,L]=LINE NUMBER OF WHILE
	INX	H
	MOV	H,M
	MOV	L,A
	SHLD	CURLIN			;IN CASE OF ERROR OR CONTINUATION FIX CURLIN
	XCHG				;GET TEXT POINTER OF WHILE FORMULA INTO [H,L]
FNWEND:	CALL	FRMEVL			;EVALUATE FORMULA
	EXTRN	VSIGN
	PUSH	H			;SAVE TEXT POINTER
	CALL	VSIGN			;GET IF TRUE OR FALSE
	POP	H			;GET BACK WHILE TEXT POINTER
	JZ	FLSWHL			;GO BACK AT WEND IF FALSE
	LXI	B,0+$WHILE		;COMPLETE WHILE ENTRY
	MOV	B,C			;NEED IT IN THE HIGH BYTE
	PUSH	B
	INX	SP			;ONLY USE ONE BYTE
	JMP	NEWSTT

FLSWHL:	LHLD	NXTLIN			;SETUP CURLIN FOR WEND
	SHLD	CURLIN
	POP	H			;TAKE OFF TEXT OF WEND AS NEW TEXT POINTER
	POP	PSW			;GET RID OF TEXT POINTER OF WHILE
	POP	PSW			;TAKE OFF LINE NUMBER OF WHILE
	JMP	NEWSTT
;
; THIS SUBROUTINE SEARCHES THE STACK FOR AN WHILE ENTRY
; WHOSE WEND TEXT POINTER MATCHES [D,E]. IT RETURNS WITH ZERO TRUE
; IF A MATCH IS FOUND AND ZERO FALSE OTHERWISE. FOR ENTRIES
; ARE SKIPPED OVER, BUT GOSUB ENTRIES ARE NOT.
;
WHLSIZ	SET	6
FNDWND:	LXI	H,0+4			;SKIP OVER RETURN ADDRESS AND NEWSTT
	DAD	SP
FNDWN2:
	MOV	A,M			;GET THE ENTRY TYPE
	INX	H
	LXI	B,0+$FOR
	CMP	C			;SEE IF ITS $FOR
	JNZ	FNDWN3
	LXI	B,FORSZC
	DAD	B
	JMP	FNDWN2
FNDWN3:	LXI	B,0+$WHILE
	CMP	C
	RNZ	
	PUSH	H
	MOV	C,M			;PICK UP THE WEND TEXT POINTER
	INX	H
	MOV	B,M
	MOV	H,B
	MOV	L,C
	CALL	DCOMPR
	POP	H
	LXI	B,0+WHLSIZ
	RZ				;RETURN IF ENTRY MATCHES
	DAD	B
	JMP	FNDWN2

WEERR:	LXI	D,0+ERRWE
	JMP	ERROR
	PAGE
	SUBTTL	CALL statement
	PUBLIC	CALLS
; This is the CALL <simple var>[(<simple var>[,<simple var>]..)]
; Stragegy:
;
; 1.) Make sure suboutine name is simple var, get value & save it
;
; 2.) Allocate space on stack for param adresses
;
; 3.) Evaluate params & stuff pointers on stack
;
; 3.) POP off pointers ala calling convention
;
; 4.) CALL suboutine with return address on stack
MAXPRM	SET	32			;MAX # OF PARAMS TO ASSEMBLY LANGUAGE SUBROUTINE
	EXTRN	TEMPA
CALLS:
	MVI	A,200O			;Flag PTRGET not to allow arrays
	STA	SUBFLG
	CALL	PTRGET			;Evaluate var pointer
	PUSH	H			;Save text pointer
	XCHG				;Var pointer to [H,L]
	CALL	GETYPR			;Get type of var
	CALL	VMOVFM			;Store value in FAC
	CALL	FRCINT			;Evaluate var
	SHLD	TEMPA			;Save it
	MVI	C,MAXPRM		;Check to see if we have space for max parm block
	CALL	GETSTK
	POP	D			;Get text pointer off stack
	LXI	H,0-2*MAXPRM		;Get space on stack for parms
	DAD	SP
	SPHL				;Adjust stack
	XCHG				;Put text pointer in [H,L], stack pointer in [D,E]
	MVI	C,MAXPRM		;Get # of params again
	DCX	H			;Back up text pointer
	CALL	CHRGTR			;Get char
	SHLD	TEMP			;Save text pointer
	JZ	CALLST			;If end of line, GO!
	CALL	SYNCHR
	DB	'('			;Eat left paren
GETPAR:	PUSH	B			;Save count
	PUSH	D			;Save pointer into stack
	CALL	PTRGET			;Evaluate param address
	XTHL				;Save text pointer get pointer into stack
	MOV	M,E			;Save var address on stack
	INX	H
	MOV	M,D
	INX	H
	XTHL				;Save back var pointer, get text pointer
	POP	D
	POP	B
	MOV	A,M			;Look at terminator
	CPI	54O			;Comma?
	JNZ	ENDPAR			;Test
	DCR	C			;Decrement count of params
	CALL	CHRGTR			;Get next char
	JMP	GETPAR			;Back for more
ENDPAR:	CALL	SYNCHR
	DB	')'			;Should have left paren
	SHLD	TEMP			;Save text pointer
	MVI	A,MAXPRM+1		;Calc # of params
	SUB	C
	POP	H			;At least one, get its address in [H,L]
	DCR	A			;Was it one?
	JZ	CALLST			;Yes
	POP	D			;Next address in [D,E]
	DCR	A			;Two?
	JZ	CALLST			;Yes
	POP	B			;Final in [B,C]
	DCR	A			;Three?
	JZ	CALLST			;Yes
	PUSH	B			;Save back third parm
	PUSH	H			;Save back first
	LXI	H,0+2			;Point to rest of parm list
	DAD	SP
	MOV	B,H			;Get into [B,C]
	MOV	C,L
	POP	H			;Restore parm three
CALLST:	PUSH	H			;Save parm three
	LXI	H,CALLRT		;Where subroutines return
	XTHL				;Put it on stack, get back parm three
	PUSH	H			;Save parm three
	LHLD	TEMPA			;Get subroutine address
	XTHL				;Save, get back parm three
	RET				;Dispatch to subroutine

CALLRT:	LHLD	SAVSTK			;Restore stack to former state
	SPHL	
	LHLD	TEMP			;Get back text poiner
	JMP	NEWSTT			;Get next statement
	PAGE
	SUBTTL	CHAIN
	EXTRN	TXTTAB,FRMEVL,$COMMO,OMERR,SCRTCH,VALTYP,$MERGE,LINGET
	EXTRN	$DELETE
	PUBLIC	CHAIN,COMPTR,COMPT2,COMMON
	EXTRN	GARBA2,FRETOP,MOVE1,NEWSTT,PTRGET,STRCPY
	EXTRN	SAVFRE
	EXTRN	IADAHL
	EXTRN	SUBFLG,TEMP3,TEMP9,VARTAB,ARYTAB,BLTUC,CHNFLG,CHNLIN,DATA
	EXTRN	FNDLIN,STREND,USERR,CURLIN,ERSFIN,FCERR,NOARYS,SAVSTK,ENDBUF
	EXTRN	DEL,CMEPTR,CMSPTR,MRGFLG,MDLFLG,LINKER,SCNLIN,FRQINT
; This is the code for the CHAIN statement
; The syntax is:
; CHAIN [MERGE]<file name>[,[<line number>][,ALL][,DELETE <range>]]
; The steps required to execute a CHAIN are:
;
; 1.) Scan arguments
;
; 2.) Scan program for all COMMON statements and 
;	mark specified variables.
;
; 3.) Squeeze unmarked entries from symbol table.
;
; 4.) Copy string literals to string space
;
; 5.) Move all simple variables and arrays into the
;	bottom of string space.
;
; 6.) Load new program
;
; 7.) Move variables back down positioned after program.
;
; 8.) Run program
CHAIN:
	XRA	A			;Assume no MERGE
	STA	MRGFLG
	STA	MDLFLG			;Also no MERGE w/ DELETE option
	MOV	A,M			;Get current char
	LXI	D,0+$MERGE		;Is it MERGE?
	CMP	E			;Test
	JNZ	NTCHNM			;NO
	STA	MRGFLG			;Set MERGE flag
	INX	H
NTCHNM:	DCX	H			;Rescan file name
	CALL	CHRGTR
	EXTRN	PRGFLI
	CALL	PRGFLI			;Evaluate file name and OPEN it
	PUSH	H			;Save text pointer
	LXI	H,0			;Get zero
	SHLD	CHNLIN			;Assume no CHAIN line #
	POP	H			;Restore text pointer
	DCX	H			;Back up pointer
	CALL	CHRGTR			;Scan char
	JZ	NTCHAL			;No line number etc.
	CALL	SYNCHR
	DB	54O			;Must be comma
	CPI	54O			;Ommit line # (Use ALL for instance)
	JZ	NTLINF			;YES
	CALL	FRMEVL			;Evaluate line # formula
	PUSH	H			;Save text poiner
	CALL	FRQINT			;Force to int in [H,L]
	SHLD	CHNLIN			;Save it for later
	POP	H			;Restore text poiner
	DCX	H			;Rescan last char
	CALL	CHRGTR
	JZ	NTCHAL			;No ALL i.e. preserve all vars across CHAIN
NTLINF:	CALL	SYNCHR
	DB	54O			;Should be comma here
	LXI	D,0+$DELETE		;Test for DELETE option
	CMP	E			;Is it?
	JZ	CHMWDL			;Yes
	CALL	SYNCHR
	DB	'A'			;Check for "ALL"
	CALL	SYNCHR
	DB	'L'
	CALL	SYNCHR
	DB	'L'
	JZ	DNCMDA			;Goto step 3
	CALL	SYNCHR
	DB	54O			;Force comma to appear
	CMP	E			;Must be DELETE
	JNZ	SNERR			;No, give error
	ORA	A			;Flag to goto DNCMDA
CHMWDL:	PUSH	PSW			;Save ALL flag
	STA	MDLFLG			;Set MERGE w/ DELETE
	CALL	CHRGTR			;Get char after comma
	CALL	SCNLIN			;Scan line range
	EXTRN	DEPTR
	PUSH	B
	CALL	DEPTR			;Change pointers back to numbers
	POP	B
	POP	D			;Pop max line off stack
	PUSH	B			;Save pointer to start of 1st line
	MOV	H,B			;Save pointer to start line
	MOV	L,C
	SHLD	CMSPTR
	CALL	FNDLIN			;Find the last line
	JNC	FCERRG			;Must have exact match on end of range
	MOV	D,H			;[D,E] =  pointer at the start of the line
	MOV	E,L			;beyond the last line in the range
	SHLD	CMEPTR			;Save pointer to end line
	POP	H			;Get back pointer to start of range
	CALL	DCOMPR			;Make sure the start comes before the end
FCERRG:	JNC	FCERR			;If not, "Illegal function call"
	POP	PSW			;Flag that says whether to go to DNCMDA
	JNZ	DNCMDA			;"ALL" option was present
NTCHAL:	LHLD	TXTTAB			;Start searching for COMMONs at program start
	DCX	H			;Compensate for next instr
CLPSC1:	INX	H			;Look at first char of next line
CLPSCN:	MOV	A,M			;Get char from program
	INX	H
	ORA	M			;Are we pointing to program end?
	JZ	CLPFIN			;Yes
	INX	H
	MOV	E,M			;Get line # in [D,E]
	INX	H
	MOV	D,M
	XCHG				;Save current line # in CURLIN for errors
	SHLD	CURLIN
	XCHG	
CSTSCN:	CALL	CHRGTR			;Get statment type
AFTCOM:	ORA	A
	JZ	CLPSC1			;EOL Scan next one
	CPI	':'			;Are we looking at colon
	JZ	CSTSCN			;Yes, get next statement
	LXI	D,0+$COMMO		;Test for COMMON, avoid byte externals
	CMP	E			;Is it a COMMON?
	JZ	DOCOMM			;Yes, handle it
	CALL	CHRGTR			;Get first char of statement
	CALL	DATA			;Skip over statement
	DCX	H			;Back up to rescan terminator
	JMP	CSTSCN			;Scan next one
DOCOMM:	CALL	CHRGTR			;Get thing after COMMON
	JZ	AFTCOM			;Get next thing
NXTCOM:	PUSH	H			;Save text pointer
	MVI	A,1			;Call PTRGET to search for array
	STA	SUBFLG
	CALL	PTRGET			;This subroutine in F3 scans variables
	JZ	FNDAAY			;Found array
	MOV	A,B			;Try finding array with COMMON bit set
	ORI	128
	MOV	B,A
	XRA	A			;Set zero CC
	CALL	ERSFIN			;Search array table
	MVI	A,0			;Clear SUBFLG in all cases
	STA	SUBFLG
	JNZ	NTFN2T			;Not found, try simple
	MOV	A,M			;Get terminator, should be "("
	CPI	'('			;Test
	JNZ	SCNSMP			;Must be simple then
	POP	PSW			;Get rid of saved text pointer
	JMP	COMADY			;Already was COMMON, ignore it
NTFN2T:	MOV	A,M			;Get terminator
	CPI	'('			;Array specifier?
	JZ	FCERR			;No such animal, give "Function call" error
SCNSMP:	POP	H			;Rescan variable name for start
	CALL	PTRGET			;Evaluate as simple
COMPTR:	MOV	A,D			;If var not found, [D,E]=0
	ORA	E
	JNZ	COMFNS			;Found it
	MOV	A,B			;Try to find in COMMON
	ORI	128			;Set COMMON bit
	MOV	B,A
	LDA	VALTYP			;Must have VALTYP in [D]
	MOV	D,A
	CALL	NOARYS			;Search symbol table
COMPT2:	MOV	A,D			;Found?
	ORA	E
	JZ	FCERR			;No, who is this guy?
COMFNS:	PUSH	H			;Save text pointer
	MOV	B,D			;Get pointer to var in [B,C]
	MOV	C,E
	LXI	H,BCKUCM		;Loop back here
	PUSH	H
CBAKBL:	DCX	B			;Point at first char of rest
LPBKNC:	LDAX	B			;Back up until plus byte
	DCX	B
	ORA	A
	JM	LPBKNC
					;Now point to 2nd char of var name
	LDAX	B			;set COMMON bit
	ORI	128
	STAX	B
	RET				;done
FNDAAY:	STA	SUBFLG			;Array found, clear SUBFLG
	MOV	A,M			;Make sure really array spec
	CPI	'('			;Really an array?
	JNZ	SCNSMP			;No, scan as simp
	XTHL				;Save text pointer, get rid of saved text pointer
BAKCOM:	DCX	B			;Point at last char of name extension
	DCX	B
	CALL	CBAKBL			;Back up before variable and mark as COMMON
BCKUCM:	POP	H			;Restore text pointer
	DCX	H			;Rescan terminator
	CALL	CHRGTR
	JZ	AFTCOM			;End of COMMON statement
	CPI	'('			;End of COMMON array spec?
	JNZ	CHKCST			;No, should be comma
COMADY:	CALL	CHRGTR			;Fetch char after paren
	CALL	SYNCHR
	DB	')'			;Right paren should follow
	JZ	AFTCOM			;End of COMMON
CHKCST:	CALL	SYNCHR
	DB	54O			;Force comma to appear here
	JMP	NXTCOM			;Get next COMMON variable
; Step 3 - Squeeze..
CLPFIN:	LHLD	ARYTAB			;End of simple var squeeze
	XCHG				;To [D,E]
	LHLD	VARTAB			;Start of simps
CLPSLP:	CALL	DCOMPR			;Are we done?
	JZ	DNCMDS			;Yes done, with simps
	PUSH	H			;Save where this simp is
	MOV	C,M			;Get VALTYP
	INX	H
	INX	H
	MOV	A,M			;Get COMMON bit
	ORA	A			;Set minus if COMMON
	PUSH	PSW			;Save indicator
	ANI	177O			;Clear COMMON bit
	MOV	M,A			;Save back
	INX	H
	CALL	IADAHL			;Skip over rest of var name
	MVI	B,0			;Skip VALTYP bytes
	DAD	B
	POP	PSW			;Get indicator whether to delete
	POP	B			;Pointer to where var started
	JM	CLPSLP
	PUSH	B			;This is where we will resume scanning vars later
	CALL	VARDLS			;Delete variable
	LHLD	ARYTAB			;Now correct ARYTAB by # of bytes deleted
	DAD	D			;Add negative difference between old and new
	SHLD	ARYTAB			;Save new ARYTAB
	XCHG				;To [D,E]
	POP	H			;Get current place back in [H,L]
	JMP	CLPSLP
VARDLS:	XCHG				;Point to where var ends
	LHLD	STREND			;One beyond last byte to move
DLSVLP:	CALL	DCOMPR			;Done?
	LDAX	D			;Grab byte
	STAX	B			;Move down
	INX	D			;Increment pointers
	INX	B
	JNZ	DLSVLP
	MOV	A,C			;Get difference between old and new
	SUB	L			;Into [D,E] ([D,E]=[B,C]-[H,L])
	MOV	E,A
	MOV	A,B
	SBB	H
	MOV	D,A
	DCX	D			;Correct # of bytes
	DCX	B			;Moved one too far
	MOV	H,B			;Get new STREND [H,L]
	MOV	L,C
	SHLD	STREND			;Store it
	RET	
DNCMDS:	LHLD	STREND			;Limit of array search
	XCHG				;To [D,E]
CLPAKP:	CALL	DCOMPR			;Done?
	JZ	DNCMDA			;Yes
	PUSH	H			;Save pointer to VALTYP
	INX	H			;Move down to COMMON bit
	INX	H
	MOV	A,M			;Get it
	ORA	A			;Set CC's
	PUSH	PSW			;Save COMMON indicator
	ANI	177O			;Clear COMMON bit
	MOV	M,A			;Save back
	INX	H			;Point to length of array
	CALL	IADAHL			;Add length of var name
	MOV	C,M			;Get length of array in [B,C]
	INX	H
	MOV	B,M
	INX	H
	DAD	B			;[H,L] now points after array
	POP	PSW			;Get back COMMON indicator
	POP	B			;Get pointer to start of array
	JM	CLPAKP			;COMMON, dont delete!
	PUSH	B			;Save so we can resume
	CALL	VARDLS			;Delete variable
	XCHG				;Put STREND in [D,E]
	POP	H			;Point to next var
	JMP	CLPAKP			;Look at next array
; Step 4 - Copy literals into string space
; This code is very smilar to the string garbage collect code
DNCMDA:	LHLD	VARTAB			;Look at simple strings
CSVAR:	XCHG				;Into [D,E]
	LHLD	ARYTAB			;Limit of search
	XCHG				;Start in [H,L], limit in [D,E]
	CALL	DCOMPR			;Done?
	JZ	CAYVAR			;Yes
	MOV	A,M			;Get VALTYP
	INX	H			;Point to length of long var name
	INX	H
	INX	H
	PUSH	PSW			;Save VALTYP
	CALL	IADAHL			;Move past long variable name
	POP	PSW			;Ge back VALTYP
	CPI	3			;String?
	JNZ	CSKPVA			;Skip this var, not string
	CALL	CDVARS			;Copy this guy into string space if nesc
	XRA	A			;CDVARS has already incremented [H,L]
CSKPVA:	MOV	E,A
	MVI	D,0			;Add length of VALTYP
	DAD	D
	JMP	CSVAR
CAYVA2:	POP	B			;Adjust stack
CAYVAR:	XCHG				;Save where we are
	LHLD	STREND			;New limit of search
	XCHG				;In [D,E], limit in [H,L]
	CALL	DCOMPR			;Done?
	JZ	DNCCLS			;Yes
	MOV	A,M			;Get VALTYP of array
	INX	H
	INX	H
	PUSH	PSW			;Save VALTYP
	INX	H
	CALL	IADAHL			;Skip over rest of array name
	MOV	C,M			;Get length of array
	INX	H
	MOV	B,M			;Into [B,C]
	INX	H
	POP	PSW			;Get back VALTYP
	PUSH	H			;Save pointer to array element
	DAD	B			;Point after array
	CPI	3			;String array?
	JNZ	CAYVA2			;No, look at next one
	SHLD	TEMP3			;Save pointer to end of array
	POP	H			;Get back pointer to array start
	MOV	C,M			;Pick up number of DIMs
	MVI	B,0			;Make double with high zero
	DAD	B			;Go past DIMS
	DAD	B
	INX	H			;One more to account for # of DIMs
CAYSTR:	XCHG				;Save current position in [D,E]
	LHLD	TEMP3			;Get end of array
	XCHG	
	CALL	DCOMPR			;See if at end of array
	JZ	CAYVAR			;Get next array
	LXI	B,CAYSTR		;Do next str in array
	PUSH	B			;Save branch address on stack
CDVARS:	XRA	A			;Get length of array and
	ORA	M			;Set CC's on VALTYP
	INX	H			;Also pick up pointer into [D,E]
	MOV	E,M
	INX	H
	MOV	D,M
	INX	H			;[H,L] points after descriptor
	RZ				;Ignore null strings
	PUSH	H			;Save where we are
	LHLD	VARTAB			;Is string in program text or disk buffers?
	CALL	DCOMPR			;Compare
	POP	H			;Restore where we are
	RC				;No, must be in string space
	PUSH	H			;save where we are again.
	LHLD	TXTTAB			;is it in buffers?
	CALL	DCOMPR			;test
	POP	H			;Restore where we are
	RNC				;in buffers, do nothing
	PUSH	H			;Save where we are for nth time
	DCX	H			;Point to start of descriptor
	DCX	H
	DCX	H
	PUSH	H			;Save pointer to start
	CALL	STRCPY			;Copy string into DSCTMP
	POP	H			;Destination in [H,L], source in [D,E]
	MVI	B,3			;# of bytes to move
	CALL	MOVE1			;Move em
	POP	H			;Where we are
	RET	
; Step 5 - Move stuff up into string space!
DNCCLS:	CALL	GARBA2			;Get rid of unused strings
	LHLD	STREND			;Load end of vars
	MOV	B,H			;Into [B,C]
	MOV	C,L
	LHLD	VARTAB			;Start of simps into [D,E]
	XCHG	
	LHLD	ARYTAB
	MOV	A,L			;Get length of simps in [H,L]
	SUB	E
	MOV	L,A
	MOV	A,H
	SBB	D
	MOV	H,A
	SHLD	TEMP9			;Save here
	LHLD	FRETOP			;Destination of high byte
	SHLD	SAVFRE			;Save FRETOP to restore later
	CALL	BLTUC			;Move stuff up
	MOV	H,B			;Now adjust top of memory below saved vars
	MOV	L,C
	DCX	H			;One lower to be sure
	SHLD	FRETOP			;Update FRETOP to reflect new value
	LDA	MDLFLG			;MERGE w/ DELETE?
	ORA	A			;Test
	JZ	NTMDLT			;No
	LHLD	CMSPTR			;Start of lines to delete
	MOV	B,H			;Into [B,C]
	MOV	C,L
	LHLD	CMEPTR			;End of lines to delete
	CALL	DEL			;Delete the lines
	CALL	LINKER			;Re-link lines just in case
; Step 6 - load new program
NTMDLT:	MVI	A,1			;Set CHAIN flag
	STA	CHNFLG
	EXTRN	CHNENT,MAXFIL,LSTFRE,OKGETM
	LDA	MRGFLG			;MERGEing?
	ORA	A			;Set cc'S
	JNZ	OKGETM			;Do MERGE
	LDA	MAXFIL			;Save the number of files
	STA	LSTFRE+1		;Since we make it look like zero
	JMP	CHNENT			;Jump to LOAD code
; Step 7 - Move stuff back down
	PUBLIC	CHNRET
CHNRET:	XRA	A			;Clear CHAIN, MERGE flags
	STA	CHNFLG
	STA	MRGFLG
	LHLD	VARTAB			;Get current VARTAB
	MOV	B,H			;Into [B,C]
	MOV	C,L
	LHLD	TEMP9			;Get length of simps
	DAD	B			;Add to present VARTAB to get new ARYTAB
	SHLD	ARYTAB
	LHLD	FRETOP			;Where to start moving
	INX	H			;One higher
	XCHG				;Into [D,E]
	LHLD	SAVFRE			;Last byte to move
	SHLD	FRETOP			;Restore FRETOP from this
MVBKVR:	CALL	DCOMPR			;Done?
	LDAX	D			;Move byte down
	STAX	B
	INX	D			;Increment pointers
	INX	B
	JNZ	MVBKVR
	DCX	B			;Point to last var byte
	MOV	H,B			;[H,L]=last var byte
	MOV	L,C
	SHLD	STREND			;This is new end
	LHLD	CHNLIN			;Get CHAIN line #
	MOV	A,H			;Test for zero
	ORA	L
	XCHG				;Put in [D,E]
	LHLD	TXTTAB			;Get prog start in [H,L]
	DCX	H			;Point at zero before program
	JZ	NEWSTT			;line #=0, go...
	CALL	FNDLIN			;Try to find destination line
	JNC	USERR			;Not there...
	DCX	B			;Point to zero on previous line
	MOV	H,B			;Make text pointer for NEWSTT
	MOV	L,C
	JMP	NEWSTT			;Bye...
COMMON:	JMP	DATA
	PAGE
	SUBTTL	WRITE
	EXTRN	FINPRT
	EXTRN	FOUT,STRLIT,STRPRT,OUTDO,FACLO
	PUBLIC	WRITE
WRITE:
	EXTRN	FILGET
	MVI	C,MD.SQO		;Setup output file
	CALL	FILGET
WRTCHR:	DCX	H
	CALL	CHRGTR			;Get another character
	JZ	WRTFIN			;Done with WRITE
WRTMLP:	CALL	FRMEVL			;Evaluate formula
	PUSH	H			;Save the text pointer
	CALL	GETYPR			;See if we have a string
	JZ	WRTSTR			;We do
	CALL	FOUT			;Convert to a string
	CALL	STRLIT			;Literalize string
	LHLD	FACLO			;Get pointer to string
	INX	H			;Point to address field
	MOV	E,M
	INX	H
	MOV	D,M
	LDAX	D			;Is number positive?
	CPI	' '			;Test
	JNZ	WRTNEG			;No, must be negative
	INX	D
	MOV	M,D
	DCX	H
	MOV	M,E
	DCX	H
	DCR	M			;Adjust length of string
WRTNEG:	CALL	STRPRT			;Print the number
NXTWRV:	POP	H			;Get back text pointer
	DCX	H			;Back up pointer
	CALL	CHRGTR			;Get next char
	JZ	WRTFIN			;end
	CPI	59			;Semicolon?
	JZ	WASEMI			;Was one
	CALL	SYNCHR
	DB	54O			;Only possib left is comma
	DCX	H			;to compensate for later CHRGET
WASEMI:	CALL	CHRGTR			;Fetch next char
	MVI	A,54O			;put out comma
	CALL	OUTDO
	JMP	WRTMLP			;Back for more
WRTSTR:	MVI	A,34			;put out double quote
	CALL	OUTDO			;Send it
	CALL	STRPRT			;print the string
	MVI	A,34			;Put out another double quote
	CALL	OUTDO			;Send it
	JMP	NXTWRV			;Get next value
WRTFIN:
	EXTRN	CMPFBC,CRDO,PTRFIL
	PUSH	H			;Save text pointer
	LHLD	PTRFIL			;See if disk file
	MOV	A,H
	ORA	L
	JZ	NTRNDW			;No
	MOV	A,M			;Get file mode
	CPI	MD.RND			;Random?
	JNZ	NTRNDW			;NO
	CALL	CMPFBC			;See how many bytes left
	MOV	A,L			;do subtract
	SUB	E
	MOV	L,A
	MOV	A,H
	SBB	D
	MOV	H,A
CRLFSQ	SET	2			;Number of bytes in CR/LF sequence
	LXI	D,0-CRLFSQ		;Subtract bytes in <cr>
	DAD	D
	JNC	NTRNDW			;Not enough, give error eventually
NXTWSP:	MVI	A,' '			;Put out spaces
	CALL	OUTDO			;Send space
	DCX	H			;Count down
	MOV	A,H			;Count down
	ORA	L
	JNZ	NXTWSP
NTRNDW:	POP	H			;Restore [H,L]
	CALL	CRDO			;Do crlf
	JMP	FINPRT
	END	
                                                                      