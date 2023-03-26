; xa more.asm -o more

#include "../atmega/6502def.inc"

; zero page variables
; pointer to the next argument
argptr = 10
; argument (2 bytes)
arg1 = argptr+2
; variable to save the actual state of PAGERACTIVE (1 byte)
pagerstate = arg1+2
; size of file (2 bytes)
size = pagerstate+1
; temp pointer
tmpptr = size+2

* = START6502CODE

; Autostart-Programm
jmp	start
.asc	"AUTO"

loadfilestruct:
.dsb	6,0

filestruct:
.dsb	FILESTRUCTSIZE, 0

illegalnatxt:
.asc	"usage: more filename", 10, 0

errortxt:
.asc	"file error, code = ", 0


illegalna:
	ldx	#<illegalnatxt
	ldy	#>illegalnatxt
	callatm	printstring6502
	jmpsh


skipnextarg:
	ldy	#0
skipnextarg_lab10:
	inc	argptr
	bne	skipnextarg_lab11
	inc	argptr+1
skipnextarg_lab11:
	lda	(argptr),y
	bne	skipnextarg_lab10
	inc	argptr
	bne	skipnextarg_lab12
	inc	argptr+1
skipnextarg_lab12:
	rts


error:
	ldx	#<errortxt
	ldy	#>errortxt
	callatm	printstring6502
	ldx	RERRCODE6502
	ldy	#0
	callatm	itoa6502
	ldx	#<ITOASTRING
	ldy	#>ITOASTRING
	callatm	printstring6502
	callatm	println6502
	jmpsh


start:
	; check number of arguments
	lda	SHELLNUMARGS
	cmp	#2
	bne	illegalna

	; get first argument
	lda	#<SHELLBUFFER
	sta	argptr
	lda	#>SHELLBUFFER
	sta	argptr+1
	; skip program name
	jsr	skipnextarg
	lda	argptr
	sta	arg1
	lda	argptr+1
	sta	arg1+1

	; load text file
	lda	#<filestruct
	sta	loadfilestruct+FATLOADSAVE_FILE
	lda	#>filestruct
	sta	loadfilestruct+FATLOADSAVE_FILE+1
	lda	arg1
	sta	loadfilestruct+FATLOADSAVE_NAME
	lda	arg1+1
	sta	loadfilestruct+FATLOADSAVE_NAME+1
	lda	#<startofdata
	sta	loadfilestruct+FATLOADSAVE_MEM
	lda	#>startofdata
	sta	loadfilestruct+FATLOADSAVE_MEM+1
	ldx	#<loadfilestruct
	ldy	#>loadfilestruct
	callatm	fatload6502
	lda	RERRCODE6502
	beq	lab8
	jmp	error
lab8:

	; get size of file
	lda	#<filestruct
	sta	tmpptr
	lda	#>filestruct
	sta	tmpptr+1
	ldy	#FILEMODSIZE
	lda	(tmpptr),y
	sta	size
	ldy	#FILEDIVSIZE
	lda	(tmpptr),y
	asl
	ldy	#FILEMODSIZE+1
	ora	(tmpptr),y
	sta	size+1

	; set end of text mark
	clc
	lda	#<startofdata
	adc	size
	sta	tmpptr
	lda	#>startofdata
	adc	size+1
	sta	tmpptr+1
	ldy	#0
	tya
	sta	(tmpptr),y

	; show text
	lda	PAGERACTIVE
	sta	pagerstate
	lda	#1
	sta	PAGERACTIVE
	lda	#0
	sta	PAGERBREAK
	lda	#25
	sec
	sbc	CURY
	sta	PAGERCNT
	ldx	#<startofdata
	ldy	#>startofdata
	callatm	printstring6502
	lda	pagerstate
	sta	PAGERACTIVE
	jmpsh

startofdata:
