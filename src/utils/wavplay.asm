; xa wavplay.asm -o wavplay

#include "../atmega/6502def.inc"

; zero page variables
; pointer to the next argument
argptr = 10
; argument 1 = sound data (2 bytes)
arg1 = argptr+2
; index for array readsectarr (1 byte)
idx = arg1+2
; flag "last block read"
lastblockread = idx+1
; flag "read buffer"
readbuffer = lastblockread+1

; constants
NUMOFBUFBLKS = 4


* = START6502CODE

; Autostart-Programm
jmp	start
.asc	"AUTO"

loadfilestruct:
.dsb	6,0

filestruct:
.dsb	FILESTRUCTSIZE, 0

clearbufstruct:
.word	0
.byt	0,0,0

illegalnatxt:
.asc	"usage: wavplay filename", 10, 0

fileerrortxt:
.asc	"file error, code = ", 0

formaterrortxt:
.asc	"wrong format", 0

RIFF1:
.asc	"RIFF"
RIFF2:
.asc	"WAVE"
.asc	"fmt "
.byte	16,0,0,0,1,0,1,0
RIFF3:
.byte	1,0,8,0
.asc	"data"


getnextarg:
	ldy	#0
getnextarg_lab10:
	inc	argptr
	bne	getnextarg_lab11
	inc	argptr+1
getnextarg_lab11:
	lda	(argptr),y
	bne	getnextarg_lab10
	inc	argptr
	bne	getnextarg_lab12
	inc	argptr+1
getnextarg_lab12:
	rts

illegalna:
	ldx	#<illegalnatxt
	ldy	#>illegalnatxt
	callatm	printstring6502
	jmpsh

fileerror:
	ldx	#<fileerrortxt
	ldy	#>fileerrortxt
	callatm	printstring6502
	ldx	RERRCODE6502
	ldy	#0
	callatm	itoa6502
	ldx	#<ITOASTRING
	ldy	#>ITOASTRING
	callatm	printstring6502
	callatm	println6502
	jmpsh

wrongformaterror:
	ldx	#<formaterrortxt
	ldy	#>formaterrortxt
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
	; get argument
	jsr	getnextarg
	; sound data file in arg1
	lda	argptr
	sta	arg1
	lda	argptr+1
	sta	arg1+1

	; prepare loadfile structure
	lda	#<filestruct
	sta	loadfilestruct+FATLOADSAVE_FILE
	lda	#>filestruct
	sta	loadfilestruct+FATLOADSAVE_FILE+1
	lda	arg1
	sta	loadfilestruct+FATLOADSAVE_NAME
	lda	arg1+1
	sta	loadfilestruct+FATLOADSAVE_NAME+1

	; open file
	ldx	#<loadfilestruct
	ldy	#>loadfilestruct
	callatm	fatopen6502
	lda	RERRCODE6502
	beq	lab1
lab2:
	jmp	fileerror
lab8:
	jmp	wrongformaterror
lab1:

	; read first sector (512 bytes)
	lda	#<DATASTART
	sta	loadfilestruct+FATLOADSAVE_MEM
	lda	#>DATASTART
	sta	loadfilestruct+FATLOADSAVE_MEM+1
	lda	#0
	callatm	fatreadnextsector6502
	lda	RERRCODE6502
	bne	lab2
	lda	loadfilestruct+FATLOADSAVE_MEM+1
	clc
	adc	#2
	sta	loadfilestruct+FATLOADSAVE_MEM+1

	; format ok?
	ldy	#3
lab10:
	lda	DATASTART,y
	cmp	RIFF1,y
	bne	lab8
	dey
	bpl	lab10
	ldy	#15
lab11:
	lda	DATASTART+8,y
	cmp	RIFF2,y
	bne	lab8
	dey
	bpl	lab11
	ldy	#7
lab12:
	lda	DATASTART+32,y
	cmp	RIFF3,y
	bne	lab8
	dey
	bpl	lab12

	; init. variables
	lda	#1
	sta	idx
	sta	readbuffer
	lda	#0
	sta	lastblockread

	; install vsync interrupt
	lda	#<vsyncint
	sta	$FFFC
	lda	#>vsyncint
	sta	$FFFD

	; enable vsync interrupt
	lda	#16
	sta	INTMASK6502

	; prepare autosound
	; (for first phase also play 44 header bytes)
	lda	#<(DATASTART+768)
	sta	AUTOSNDPTRP768
	sta	AUTOSNDREPEATPTRP768
	lda	#>(DATASTART+768)
	sta	AUTOSNDPTRP768+1
	sta	AUTOSNDREPEATPTRP768+1
	lda	#<(NUMOFBUFBLKS*512)
	sta	AUTOSNDCNT
	sta	AUTOSNDREPEATCNT
	lda	#>(NUMOFBUFBLKS*512)
	sta	AUTOSNDCNT+1
	sta	AUTOSNDREPEATCNT+1

	; start play sound
	lda	#105
	sta	SNDTCCR2
	lda	#1
	sta	AUTOSND
	sta	AUTOSNDSYNC
	sta	AUTOSNDREPEAT

lab7:
	lda	#0
	sta	AUTOSNDREPEATED

	; wait until sound is played
lab3:
	lda	AUTOSNDREPEATED
	beq	lab3

	; last block read?
	lda	lastblockread
	beq	lab7
	; end of sound
	lda	#0
	sta	AUTOSND
	sta	AUTOSNDSYNC2
	sta	AUTOSNDREPEAT
	jmpsh


vsyncint:
	pha
	tya
	pha
	txa
	pha

	; read buffer?
	lda	readbuffer
	beq	vsyncint_lab1

	; which cycle?
	ldx	idx
	cpx	#NUMOFBUFBLKS
	beq	vsyncint_lab4
	inx
	stx	idx

vsyncint_lab3:
	; read next sector (512 bytes)
	ldx	#<loadfilestruct
	ldy	#>loadfilestruct
	lda	#1
	callatm	fatreadnextsector6502
	lda	RERRCODE6502
	beq	vsyncint_lab5
	cmp	#FATINFOLASTCLUST
	beq	vsyncint_lab7
	jmp	fileerror
vsyncint_lab5:
	lda	loadfilestruct+FATLOADSAVE_MEM+1
	clc
	adc	#2
	sta	loadfilestruct+FATLOADSAVE_MEM+1

vsyncint_lab2:
	pla
	tax
	pla
	tay
	pla
	rti

vsyncint_lab1:
	; check if buffer gets empty
	lda	AUTOSNDCNT+1
	cmp	#2
	bcs	vsyncint_lab2
	; buffer nearly empty -> read blocks again
	lda	#1
	sta	idx
	sta	readbuffer
	; jump always
	bne	vsyncint_lab3

vsyncint_lab4:
	; buffer full
	; prepare for next buffer reading phase
	lda	#<DATASTART
	sta	loadfilestruct+FATLOADSAVE_MEM
	lda	#>DATASTART
	sta	loadfilestruct+FATLOADSAVE_MEM+1
	; stop reading
	lda	#0
	sta	readbuffer
	; jump always
	beq	vsyncint_lab2

vsyncint_lab7:
	; last block read
	sta	lastblockread
	lda	#0
	sta	readbuffer
	; clear remaining buffer
	lda	loadfilestruct+FATLOADSAVE_MEM
	sta	clearbufstruct+MEMFILL6502_MEMPTR
	lda	loadfilestruct+FATLOADSAVE_MEM+1
	clc
	adc	#2
	sta	clearbufstruct+MEMFILL6502_MEMPTR+1
	lda	#2
	sta	clearbufstruct+MEMFILL6502_N
	lda	#NUMOFBUFBLKS
	sec
	sbc	idx
	sta	clearbufstruct+MEMFILL6502_M
	ldx	#<clearbufstruct
	ldy	#>clearbufstruct
	callatm	memfill6502
	jmp	vsyncint_lab2

DATASTART:
