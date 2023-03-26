; xa playsnd.asm -o playsnd

#include "../atmega/6502def.inc"
#include "sndN8.inc"

; zero page variables
; 
argptr = 10
; pointer to the melody
melodyptr = 12
; lenght of the actual tone
durationsnd = 14

; constants
SNDPAUSE = 0
SNDEND = 255

* = START6502CODE

; Autostart-Programm
jmp	start
.asc	"AUTO"

loadfilestruct:
.dsb	6,0

filestruct:
.dsb	FILESTRUCTSIZE, 0

illegalnatxt:
.asc	"usage: playsnd filename", 10, 0

illegalna:
	ldx	#<illegalnatxt
	ldy	#>illegalnatxt
	callatm	printstring6502
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
	ldy	#0
lab10:
	inc	argptr
	bne	lab11
	inc	argptr+1
lab11:
	lda	(argptr),y
	bne	lab10
	inc	argptr
	bne	lab12
	inc	argptr+1
lab12:

	; prepare loadfile structure
	lda	#<filestruct
	sta	loadfilestruct+FATLOADSAVE_FILE
	lda	#>filestruct
	sta	loadfilestruct+FATLOADSAVE_FILE+1
	lda	argptr
	sta	loadfilestruct+FATLOADSAVE_NAME
	lda	argptr+1
	sta	loadfilestruct+FATLOADSAVE_NAME+1
	lda	#<startofdata
	sta	loadfilestruct+FATLOADSAVE_MEM
	lda	#>startofdata
	sta	loadfilestruct+FATLOADSAVE_MEM+1

	; load data from file
	ldx	#<loadfilestruct
	ldy	#>loadfilestruct
	callatm	fatload6502

	; initialize sound
	lda	#30
	sta	SNDTCCR2

	; play sound
	lda	#<startofdata
	sta	melodyptr
	lda	#>startofdata
	sta	melodyptr+1
	jsr	playmelody

	; Sound ausschalten
	lda	#0
	sta	SNDTCCR2
	jmpsh

playmelody:
	lda	#1
	sta	durationsnd
	ldy	#0
playmelody_lab1:
	dec	durationsnd
	bne	playmelody_lab5

	; lenght of tone
	lda	(melodyptr),y
	sta	durationsnd
	iny
	; tone
	lda	(melodyptr),y
	cmp	#SNDEND
	beq	playmelody_lab2
	iny
	bne	playmelody_lab3
	inc	melodyptr+1
playmelody_lab3:
	sta	SNDOCR2
playmelody_lab5:
	lda	TIMER
playmelody_lab6:
	cmp	TIMER
	beq	playmelody_lab6
	jmp	playmelody_lab1
playmelody_lab2:
	rts

startofdata:
