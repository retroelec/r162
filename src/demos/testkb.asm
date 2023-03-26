#include "../atmega/6502def.inc"

* = START6502CODE


; Autostart-Programm
jmp	start
.asc	"AUTO"


txtkeypressed:
.asc	"key pressed: ", 0


printkeypressed:
	ldx	#<txtkeypressed
	ldy	#>txtkeypressed
	callatm	printstring6502
	tax
	ldy	#0
	callatm	itoa6502
	ldx	#<ITOASTRING
	ldy	#>ITOASTRING
	callatm	printstring6502
	callatm	println6502
	rts

start:
	callatm	getchwait6502
	lda	RGETCH6502
	beq	lab1
	jsr	printkeypressed
lab1:
	cmp	#'q'
	beq	labend
	cmp	#'Q'
	beq	labend
	jmp	start
labend:
	jmpsh
