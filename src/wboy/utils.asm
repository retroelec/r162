getyfromx_lab0:
	cmp	#EVENTSTARTX+1
	bcc	getyfromx
	lda	#0
getyfromx:
	lsr
	lsr
	tay
	lda	(actgroundheightptr),y
	rts


getenemyptrfromspritenum:
	; Eingabe -> Sprite-Nummer in Register A
	; Ausgabe -> Pointer auf Sprite in actcoincsprite

	; Ermittlung Pointer auf Enemy-Struktur -> enemy1 + (spriteID-MINIDENEMYSPRITES)*SIZEOFENEMYSPRITE
	sec
	sbc	#MINIDENEMYSPRITES
	sta	RMUL6502
	lda	#0
	sta	RMUL6502+1
	lda	#<SIZEOFENEMYSPRITE
	sta	RMUL6502+2
	lda	#>SIZEOFENEMYSPRITE
	sta	RMUL6502+3
	callatm	mul16x16mod6502
	clc
	lda	RMUL6502
	adc	#<enemy1
	sta	actcoincsprite
	lda	RMUL6502+1
	adc	#>enemy1
	sta	actcoincsprite+1
	rts


energycounterinit:
	; Zeichne leeren Energy-Bar
	lda	#252
	ldx	#32
energycounterinit_lab1:
	sta	ENERGYBARADR-1,x
	dex
	bne	energycounterinit_lab1
	lda	#PALEPINK
	ldx	#32
energycounterinit_lab2:
	sta	ENERGYBARCOLADR-1,x
	dex
	bne	energycounterinit_lab2
	lda	#0
	sta	energycounterold
	lda	#ENERGYCOUNTERSTART
	sta	energycounter


adaptenergybar:
	; Zeichne gefuellten Energy Bar
	lda	energycounter
	bpl	adaptenergybar_lab5
	; Energie negativ -> setze auf 0
	lda	#0
	sta	energycounter
	; jump always
	beq	adaptenergybar_lab6
adaptenergybar_lab5:
	cmp	#33
	bcc	adaptenergybar_lab6
	; Zu viel Energie -> setze auf Maximalwert
	lda	#32
	sta	energycounter
adaptenergybar_lab6:
	sec
	sbc	energycounterold
	beq	adaptenergybar_lab2
	bcc	adaptenergybar_lab1
	; mehr Energie
	tax
	ldy	energycounterold
	lda	#YELLOW
adaptenergybar_lab3:
	sta	ENERGYBARCOLADR,y
	iny
	dex
	bne	adaptenergybar_lab3
adaptenergybar_lab2:
	rts
adaptenergybar_lab1:
	; weniger Energie
	tax
	ldy	energycounterold
	lda	#PALEPINK
adaptenergybar_lab4:
	dey
	sta	ENERGYBARCOLADR,y
	inx
	bne	adaptenergybar_lab4
	rts


updatescore:
	ldx	score
	ldy	score+1
	callatm	itoaformat6502
	ldx	#34
	ldy	#0
	callatm setcursorpos6502
	ldx	#<ITOASTRING
	ldy	#>ITOASTRING
	callatm	printstring6502
	lda	score+1
	cmp	highscore+1
	bcc	updatescore_lab1
	bne	updatescore_lab2
	lda	score
	cmp	highscore
	bcc	updatescore_lab1
updatescore_lab2:
	lda	score
	sta	highscore
	lda	score+1
	sta	highscore+1
	ldx	#18
	ldy	#0
	callatm setcursorpos6502
	ldx	#<ITOASTRING
	ldy	#>ITOASTRING
	callatm	printstring6502
updatescore_lab1:
	rts


loaddataerrortxt:
.asc	" not found", 10, 0

loaddataerror:
	ldx	loadfilestruct+FATLOADSAVE_NAME
	ldy	loadfilestruct+FATLOADSAVE_NAME+1
	callatm	printstring6502
	ldx	#<loaddataerrortxt
	ldy	#>loaddataerrortxt
	callatm	printstring6502
	jmp	quitgame
