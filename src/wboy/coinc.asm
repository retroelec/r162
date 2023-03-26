coinctomtom:
	ldx	#<tomtomuntensprite
	ldy	#>tomtomuntensprite
	callatm	coincmsprite6502
	ldx	tomtomuntensprite+MSPRITENUMCOINC
	beq	coinctomtom_lab2
coinctomtom_lab1:
	stx	tmpnumofcoincs
	lda	tomtomuntensprite+MSPRITECOINCARR-1,x
	cmp	#MAXIDENEMYSPRITES+1
	bcs	coinctomtom_lab5
	; Rufe die Coinc-Funktion der betroffenen Sprites auf
	jsr	getenemyptrfromspritenum
	; Pruefung, ob Feind schon am Sterben ist
	; -> keine Gefahr mehr fuer TomTom
	ldy	#MSPRITEENEMYISDYING
	lda	(actcoincsprite),y
	bne	coinctomtom_lab4
	ldy	#MSPRITEENEMYCOINCFUNC
	lda	(actcoincsprite),y
	sta	actcoincfunc
	iny
	lda	(actcoincsprite),y
	sta	actcoincfunc+1
	jsr	subcoincfunc
coinctomtom_lab4:
	ldx	tmpnumofcoincs
coinctomtom_lab5:
	; naechste Coinc-Funktion
	dex
	bne	coinctomtom_lab1
coinctomtom_lab2:
	rts


coincshot1:
	lda	shot1sprite+MSPRITESTATUS
	beq	coincshot1_lab2
	ldx	#<shot1sprite
	ldy	#>shot1sprite
	callatm	coincmsprite6502
	ldx	shot1sprite+MSPRITENUMCOINC
	bne	coincshot1_lab1
coincshot1_lab2:
	rts
coincshot1_lab1:
	stx	tmpnumofcoincs
	lda	shot1sprite+MSPRITECOINCARR-1,x
	cmp	#MAXIDENEMYSPRITES+1
	bcs	coincshot1_lab4
	; Ermittle die K-Coinc-Funktion des betroffenen Sprites
	jsr	getenemyptrfromspritenum
	ldy	#MSPRITEENEMYISDYING
	lda	(actcoincsprite),y
	bne	coincshot1_lab4
	ldy	#MSPRITEENEMYKCOINCFUNC
	lda	(actcoincsprite),y
	sta	actcoincfunc
	iny
	lda	(actcoincsprite),y
	sta	actcoincfunc+1
	; Setze am betroffenen Sprite die Richtung, aus der der Schuss kam
	ldy	#MSPRITEENEMYSHOTDIR
	lda	shot1speed
	sta	(actcoincsprite),y
	; K-Coinc-Funktion aufrufen
	jsr	subcoincfunc
	; Schuss loeschen?
	bne	coincshot1_lab3
coincshot1_lab4:
	ldx	tmpnumofcoincs
	dex
	bne	coincshot1_lab1
	rts
coincshot1_lab3:
	; Loesche Schuss 1
	ldx	#<shot1sprite
	ldy	#>shot1sprite
	callatm	delmsprite6502
	rts


coincshot2:
	lda	shot2sprite+MSPRITESTATUS
	beq	coincshot2_lab2
	ldx	#<shot2sprite
	ldy	#>shot2sprite
	callatm	coincmsprite6502
	ldx	shot2sprite+MSPRITENUMCOINC
	bne	coincshot2_lab1
coincshot2_lab2:
	rts
coincshot2_lab1:
	stx	tmpnumofcoincs
	lda	shot2sprite+MSPRITECOINCARR-1,x
	cmp	#MAXIDENEMYSPRITES+1
	bcs	coincshot2_lab4
	; Ermittle die K-Coinc-Funktion des betroffenen Sprites
	jsr	getenemyptrfromspritenum
	ldy	#MSPRITEENEMYISDYING
	lda	(actcoincsprite),y
	bne	coincshot2_lab4
	ldy	#MSPRITEENEMYKCOINCFUNC
	lda	(actcoincsprite),y
	sta	actcoincfunc
	iny
	lda	(actcoincsprite),y
	sta	actcoincfunc+1
	; Setze am betroffenen Sprite die Richtung, aus der der Schuss kam
	ldy	#MSPRITEENEMYSHOTDIR
	lda	shot2speed
	sta	(actcoincsprite),y
	; K-Coinc-Funktion aufrufen
	jsr	subcoincfunc
	; Schuss loeschen?
	bne	coincshot2_lab3
coincshot2_lab4:
	ldx	tmpnumofcoincs
	dex
	bne	coincshot2_lab1
	rts
coincshot2_lab3:
	; Loesche Schuss 2
	ldx	#<shot2sprite
	ldy	#>shot2sprite
	callatm	delmsprite6502
	rts


subcoincfunc:
	jmp	(actcoincfunc)
