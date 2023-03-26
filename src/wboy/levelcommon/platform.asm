createplatformcommon:
	ldy	#MSPRITEY
	lda	actenemyfruitparam
	and	#248
	sta	(enemysprite),y
	lda	actenemyfruitparam
	and	#7
#ifdef PLATFORM_UP_DOWN
	cmp	#1
	bne	createplatform_lab1
	ldy	#MSPRITEENEMYMOVE
	lda	#<moveplatformvertical
	sta	(enemysprite),y
	iny
	lda	#>moveplatformvertical
	sta	(enemysprite),y
	ldy	#MSPRITEENEMYSPEED
	lda	#2
	sta	(enemysprite),y
	ldy	#MSPRITEENEMYMOVECNT
	sta	(enemysprite),y
	rts
createplatform_lab1:
#endif
#ifdef PLATFORM_LEFT_RIGHT
	cmp	#2
	bne	createplatform_lab2
	ldy	#MSPRITEENEMYMOVE
	lda	#<moveplatformhorizontal
	sta	(enemysprite),y
	iny
	lda	#>moveplatformhorizontal
	sta	(enemysprite),y
	ldy	#MSPRITEENEMYSPEED
	lda	#2
	sta	(enemysprite),y
	ldy	#MSPRITEENEMYMOVECNT
	sta	(enemysprite),y
	rts
createplatform_lab2:
#endif
#ifdef PLATFORM_FALL_DOWN
	cmp	#3
	bne	createplatform_lab3
	ldy	#MSPRITEENEMYCOINCFUNC
	lda	#<platformcoincfallfunc
	sta	(enemysprite),y
	iny
	lda	#>platformcoincfallfunc
	sta	(enemysprite),y
	ldy	#MSPRITEENEMYMOVE
	lda	#<moveplatformfalldown
	sta	(enemysprite),y
	iny
	lda	#>moveplatformfalldown
	sta	(enemysprite),y
	ldy	#MSPRITEENEMYSPEED
	lda	#2
	sta	(enemysprite),y
	ldy	#MSPRITEENEMYMOVECNT
	sta	(enemysprite),y
	rts
createplatform_lab3:
#endif
	rts

platformcoincfunc:
	; Ist TomTom schon auf der Platform?
	lda	tomtomonsprite
	bne	platformcoincfunc_lab0
	; Kollision "von oben"?
	lda	tomtomoldobeny
	cmp	tomtomobensprite+MSPRITEY
	bcs	platformcoincfunc_lab3
#ifdef DBG_ONSPRITE
	ldy	#MSPRITEY
	lda	(actcoincsprite),y
	tax
	ldy	#0
	callatm	itoa6502
	ldx	#34
	ldy	#0
	callatm	setcursorpos6502
	ldx	#<ITOASTRING
	ldy	#>ITOASTRING
	callatm	printstring6502
	ldx	tomtomuntensprite+MSPRITEY
	ldy	#0
	callatm	itoa6502
	ldx	#28
	ldy	#0
	callatm	setcursorpos6502
	ldx	#<ITOASTRING
	ldy	#>ITOASTRING
	callatm	printstring6502
#endif
	; TomTom "oberhalb" Platform?
	lda	tomtomuntensprite+MSPRITEY
	ldy	#MSPRITEY
	cmp	(actcoincsprite),y
	bcc	platformcoincfunc_lab1
platformcoincfunc_lab3:
	rts
platformcoincfunc_lab1:
	lda	#1
	sta	tomtomonsprite
	ldy	#MSPRITEID
	lda	(actcoincsprite),y
	sta	tomtomonspriteid
	lda	#0
	sta	tomtomjumpflag
platformcoincfunc_lab0:
	ldy	#MSPRITEY
	lda	(actcoincsprite),y
	sta	tomtomonspritey
	jmp	setyoftomtomsprite

#ifdef PLATFORM_FALL_DOWN
platformcoincfallfunc:
	jsr	platformcoincfunc
	lda	tomtomonsprite
	bne	platformcoincfallfunc_lab1
	rts
platformcoincfallfunc_lab1:
	ldy	#MSPRITEPLATFORMDIR
	sta	(actcoincsprite),y
	rts
#endif

moveplatform:
	; Test auf "ausserhalb" Bildschirm
	jsr	test4outofscreen2
moveplatform_lab0:
	; x < 0?
	ldy	#MSPRITEX
	lda	(enemysprite),y
	cmp	#208
	bcc	moveplatform_lab1
	; x < 0 -> coincredleft = -x
	eor	#255
	clc
	adc	#1
	ldy	#MSPRITECOINCREDLEFT
	sta	(enemysprite),y
moveplatform_lab1:
	rts

#ifdef PLATFORM_UP_DOWN
moveplatformvertical:
	; Test auf "ausserhalb" Bildschirm
	jsr	test4outofscreen2
	; Test auf "x < 0"
	jsr	moveplatform_lab0
	; y-Position bestimmen
	ldy	#MSPRITEPLATFORMDIR
	lda	(enemysprite),y
	bne	moveplatformvertical_lab2
	; Bewegung nach oben
	ldy	#MSPRITEPLATFORMCNT
	lda	(enemysprite),y
	cmp	#127-30
	bcc	moveplatformvertical_lab1
	lda	#254 ; -2
moveplatformvertical_lab4:
	tax
	clc
	adc	(enemysprite),y
	sta	(enemysprite),y
	txa
	ldy	#MSPRITEY
	clc
	adc	(enemysprite),y
	sta	(enemysprite),y
	rts
moveplatformvertical_lab1:
	; Richtungswechsel
	ldy	#MSPRITEPLATFORMDIR
	lda	#1
	sta	(enemysprite),y
	rts
moveplatformvertical_lab2:
	; Bewegung nach unten
	ldy	#MSPRITEPLATFORMCNT
	lda	(enemysprite),y
	cmp	#127+30
	bcs	moveplatformvertical_lab3
	lda	#2
	; jump always
	bne	moveplatformvertical_lab4
moveplatformvertical_lab3:
	; Richtungswechsel
	ldy	#MSPRITEPLATFORMDIR
	lda	#0
	sta	(enemysprite),y
	rts
#endif

#ifdef PLATFORM_LEFT_RIGHT
moveplatformhorizontal:
	; Test auf "ausserhalb" Bildschirm
	jsr	test4outofscreen2
	; Test auf "x < 0"
	jsr	moveplatform_lab0
	; x-Position bestimmen
	ldy	#MSPRITEPLATFORMDIR
	lda	(enemysprite),y
	bne	moveplatformhorizontal_lab2
	; Bewegung nach links
	ldy	#MSPRITEPLATFORMCNT
	lda	(enemysprite),y
	cmp	#127-20
	bcc	moveplatformhorizontal_lab1
	lda	#255 ; -1
moveplatformhorizontal_lab4:
	sta	tomtomonspritedeltax
	tax
	clc
	adc	(enemysprite),y
	sta	(enemysprite),y
	txa
	ldy	#MSPRITEX
	clc
	adc	(enemysprite),y
	sta	(enemysprite),y
	ldy	#MSPRITEPLATFORMTTDELTAX
	lda	tomtomonspritedeltax
	sta	(enemysprite),y
	rts
moveplatformhorizontal_lab1:
	; Richtungswechsel
	ldy	#MSPRITEPLATFORMDIR
	lda	#1
	sta	(enemysprite),y
	rts
moveplatformhorizontal_lab2:
	; Bewegung nach rechts
	ldy	#MSPRITEPLATFORMCNT
	lda	(enemysprite),y
	cmp	#127+20
	bcs	moveplatformhorizontal_lab3
	lda	#1
	; jump always
	bne	moveplatformhorizontal_lab4
moveplatformhorizontal_lab3:
	; Richtungswechsel
	ldy	#MSPRITEPLATFORMDIR
	lda	#0
	sta	(enemysprite),y
	rts
#endif

#ifdef PLATFORM_FALL_DOWN
moveplatformfalldown:
	; Test auf "ausserhalb" Bildschirm
	jsr	test4outofscreen2
	; Test auf "x < 0"
	jsr	moveplatform_lab0
	; y-Position bestimmen
	ldy	#MSPRITEPLATFORMDIR
	lda	(enemysprite),y
	bne	moveplatformfalldown_lab2
	rts
moveplatformfalldown_lab2:
	; Fall nach unten
	ldy	#MSPRITEY
	lda	(enemysprite),y
	clc
	adc	#FALLDOWNSPEED
	cmp	#GROUND
	bcc	moveplatformfalldown_lab6
	jmp	deleteactenemy
moveplatformfalldown_lab6:
	sta	(enemysprite),y
	rts
#endif

PLATFORMSPEED = 20
