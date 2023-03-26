; xa rm.asm -o rm

#include "../atmega/6502def.inc"

; zero page variables

; pointer to argument (2 bytes)
argptr = 10
; pointer to directory entry (2 bytes)
direntryptr = argptr+2


* = START6502CODE

; Autostart-Programm
jmp	start
.asc	"AUTO"


loadfilestruct:
.dsb	6,0

filestruct:
.dsb	FILESTRUCTSIZE, 0

sdrwsectstruct:
.dsb	5,0

illegalnatxt:
.asc	"usage: rm filename", 10, 0

fileerrortxt:
.asc	"file error, code = ", 0


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


illegalna:
	ldx	#<illegalnatxt
	ldy	#>illegalnatxt
	callatm	printstring6502
	jmpsh


error:
	ldx	#<fileerrortxt
	ldy	#>fileerrortxt
	callatm	printstring6502
        ldx     RERRCODE6502
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
	bcc	illegalna

	; get first argument
	lda	#<SHELLBUFFER
	sta	argptr
	lda	#>SHELLBUFFER
	sta	argptr+1
	; skip program name
	jsr	skipnextarg

	; prepare loadfile structure
	lda	#<filestruct
	sta	loadfilestruct+FATLOADSAVE_FILE
	lda	#>filestruct
	sta	loadfilestruct+FATLOADSAVE_FILE+1
	lda	argptr
	sta	loadfilestruct+FATLOADSAVE_NAME
	lda	argptr+1
	sta	loadfilestruct+FATLOADSAVE_NAME+1

	; open file
	ldx	#<loadfilestruct
	ldy	#>loadfilestruct
	callatm	fatopen6502
        lda     RERRCODE6502
        bne     error

	; "remove cluster chain"
	lda	#1
	sta	FATRMFLAG6502
	ldx	#<loadfilestruct
	ldy	#>loadfilestruct
	callatm	fatrmorextcc6502
	lda	RERRCODE6502
	cmp	#248
	bcs	lab1
	cmp	#FATINFOLASTCLUST
	beq	lab1
	; jump always
	bne	error

lab1:
	; open "empty file"
	ldx	#<loadfilestruct
	ldy	#>loadfilestruct
	callatm	fatopen6502
        lda     RERRCODE6502
        bne     error

	; "delete" directory entry
	ldx	#32
	ldy	FATOPENACTENTRY6502
	callatm	mul8x86502
	clc
	lda	RMUL6502
	adc	#<FATBUFFER
	sta	direntryptr
	lda	RMUL6502+1
	adc	#>FATBUFFER
	sta	direntryptr+1
	ldy	#0
	lda	#229
	sta	(direntryptr),y

	; write sector with directory entry
	lda	FATOPENACTSECT6502
	sta	sdrwsectstruct+SDREADWRITESECTOR_NR
	lda	FATOPENACTSECT6502+1
	sta	sdrwsectstruct+SDREADWRITESECTOR_NR+1
	lda	FATOPENACTSECT6502+2
	sta	sdrwsectstruct+SDREADWRITESECTOR_NR+2
	lda	#<FATBUFFER
	sta	sdrwsectstruct+SDREADWRITESECTOR_MEM
	lda	#>FATBUFFER
	sta	sdrwsectstruct+SDREADWRITESECTOR_MEM+1
	ldx	#<sdrwsectstruct
	ldy	#>sdrwsectstruct
	callatm	sdwritesector6502
	lda	RERRCODE6502
	beq	lab2
	jmp	error

lab2:
	; exit
	jmpsh
