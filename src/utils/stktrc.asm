; Kompilieren
; xa stktrc.asm -o stktrc

; Bsp. Absturz:
; Stack bei Adresse 251
; -> Stack-Inhalte von 252-255 interessant (da post-decrement)
; ->
; peek 1276
; 67
; peek 1277
; 191
; peek 1278
; 50
; peek 1279
; 160
; ->
; 160*256+50 = 0xa032
; 191*256+67 = 0xbf43
; ->
; Aufruf-Kette (Adresse auf dem Stack minus 2):
; 0xa030
; 0xbf41

#include "../atmega/6502def.inc"

MEMADDR = 0
MEMVAL = 2

* = START6502CODE


; Autostart-Programm
jmp	start
.asc	"AUTO"


illegalnatxt:
.asc	"usage: stktrc stackptr", 10, 0

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

	; Stack-Adresse ermitteln
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
	; Adresse muss immer zwischen gleich 256 und 511 sein
	lda	RATOI6502
	sta	MEMADDR
	lda	#1
	sta	MEMADDR+1

	; Gebe Stack-Adressen aus
lab2:
	inc	MEMADDR
	beq	lab9
	ldy	#0
	lda	(MEMADDR),y
	sta	MEMVAL
	inc	MEMADDR
	beq	lab9
	lda	(MEMADDR),y
	sta	MEMVAL+1
	lda	MEMVAL
	sec
	sbc	#2
	sta	MEMVAL
	bcs	lab8
	dec	MEMVAL+1
lab8:
	ldx	MEMVAL
	ldy	MEMVAL+1
	callatm	itoa6502
	ldx	#<ITOASTRING
	ldy	#>ITOASTRING
	callatm	printstring6502
	callatm	println6502
	jmp	lab2
lab9:
	jmpsh
