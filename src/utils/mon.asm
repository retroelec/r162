; Kompilieren
; xa mon.asm -o mon

#include "../atmega/6502def.inc"

MEMADDR = 10
MEMADDR2 = 12
COUNTER = 14
COUNTER2 = 15


* = START6502CODE


; Autostart-Programm
jmp	start
.asc	"AUTO"


illegalnatxt:
.asc	"usage: mon address", 10, 0

illegalna:
	ldx	#<illegalnatxt
	ldy	#>illegalnatxt
	callatm	printstring6502
	jmpsh


start:
	; Pruefe Anzahl Argumente
	lda	SHELLNUMARGS
	cmp	#2
	bne	illegalna
	; Adresse ermitteln
	lda	#<SHELLBUFFER
	sta	MEMADDR
	lda	#>SHELLBUFFER
	sta	MEMADDR+1
	ldy	#0
lab10:
	inc	MEMADDR
	bne	lab11
	inc	MEMADDR+1
lab11:
	lda	(MEMADDR),y
	bne	lab10
	inc	MEMADDR
	bne	lab12
	inc	MEMADDR+1
lab12:
	ldx	MEMADDR
	ldy	MEMADDR+1
	callatm	atoi6502
	lda	RATOI6502
	sta	MEMADDR
	sta	MEMADDR2
	lda	RATOI6502+1
	sta	MEMADDR+1
	sta	MEMADDR2+1

lab8:
	lda	#24
	sta	COUNTER2

lab6:
	; Drucke Adresse
	ldx	MEMADDR
	ldy	MEMADDR+1
	callatm	itoaformat6502
	ldx	#<ITOASTRING
	ldy	#>ITOASTRING
	callatm	printstring6502
	ldy	#3
lab1:
	lda	#' '
	callatm	printcharnoctrl6502
	dey
	bne	lab1

	; Drucke den Wert der naechsten 6 Bytes
	lda	#6
	sta	COUNTER
lab2:
	ldy	#0
	lda	(MEMADDR),y
	tax
	ldy	#0
	callatm	itoaformat6502
	ldx	#<(ITOASTRING+2)
	ldy	#>(ITOASTRING+2)
	callatm	printstring6502
	lda	#' '
	callatm	printcharnoctrl6502
	inc	MEMADDR
	bne	lab3
	inc	MEMADDR+1
lab3:
	dec	COUNTER
	bne	lab2

	; Drucke die ASCII-Zeichen der gleichen 6 Bytes
	lda	#' '
	callatm	printcharnoctrl6502
	lda	#' '
	callatm	printcharnoctrl6502
	lda	#6
	sta	COUNTER
	ldy	#0
lab4:
	lda	(MEMADDR2),y
	callatm	printcharnoctrl6502
	inc	MEMADDR2
	bne	lab5
	inc	MEMADDR2+1
lab5:
	dec	COUNTER
	bne	lab4

	dec	COUNTER2
	bne	lab6

	; Naechste Seite oder Ende -> Warten auf Tastendruck
lab7:
	callatm	getchwait6502
	lda	RGETCH6502
	cmp	#' '
	beq	lab8
	cmp	#'q'
	beq	lab9
	cmp	#'Q'
	beq	lab9
	bne	lab7
lab9:
	jmpsh
