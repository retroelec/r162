tomtominit:
	lda	#0
	sta	tomtomdiesflag
	sta	tomtomisdead
	sta	tomtomtumbleflag
	sta	tomtomjumphighflag
	sta	tomtomonsprite
	sta	tomtomonspring
	sta	tomtomactspeed
	sta	tomtomviewdir
	sta	tomtomjumpflag
	sta	tomtomspeedact
	sta	tomtombacktonormalcnt
	sta	tomtomonspritedeltax
	lda	#TOMTOMSPEEDINCSTD
	sta	tomtomspeedinc
	lda	#SPEEDTOMTOMANIMSLOW
	sta	tomtomanimcnt
	lda	#255
	sta	tomtomanimlook
	lda	#TOMTOMMAXX
	sta	tomtommaxx
	lda	#TOMTOMSPEEDSLOW
	sta	tomtomspeedright
	lda	#TOMTOMSPEEDSLOWL
	sta	tomtomspeedleft
	lda	#TOMTOMSTARTX
	sta	tomtomobensprite+MSPRITEX
	sta	tomtomuntensprite+MSPRITEX
	jsr	getyfromx
	sec
	sbc	#(TOMTOMUPPERH+TOMTOMLOWERH)
	sta	tomtomacty
	sta	tomtomobensprite+MSPRITEY
	clc
	adc	#TOMTOMUPPERH
	sta	tomtomuntensprite+MSPRITEY
	lda	#TOMTOMUPPERW
	sta	tomtomobensprite+MSPRITEW
	lda	#<tomtomoben
	sta	tomtomobensprite+MSPRITEDATA
	lda	#>tomtomoben
	sta	tomtomobensprite+MSPRITEDATA+1
	lda	#TOMTOMLOWER1W
	sta	tomtomuntensprite+MSPRITEW
	lda	#<tomtomunten1
	sta	tomtomuntensprite+MSPRITEDATA
	lda	#>tomtomunten1
	sta	tomtomuntensprite+MSPRITEDATA+1
	ldx	#<tomtomobensprite
	ldy	#>tomtomobensprite
	callatm	addmsprite6502
	ldx	#<tomtomuntensprite
	ldy	#>tomtomuntensprite
	callatm	addmsprite6502
	rts


tomtommove:
	lda	#0
	sta	scrollingon
	lda	tomtomdiesflag
	beq	tomtommove_lab79
	jmp	tomtomdies
tomtommove_lab79:
	lda	tomtomtumbleflag
	beq	tomtommove_lab71
	jmp	tomtommove_lab48
tomtommove_lab71:
	lda	tomtomonspring
	beq	tomtommove_lab96
	lda	#0
	sta	tomtomonspring
	sta	tomtomactjumpidx
	lda	#<tomtomjumpfromspring
	sta	tomtomjumparr
	lda	#>tomtomjumpfromspring
	sta	tomtomjumparr+1
	lda	#1
	sta	tomtomjumpflag
	jmp	tomtommove_lab19
tomtommove_lab96:

	; * TomTom-Bewegung (links, rechts) *

	lda	tomtomobensprite+MSPRITEX
	sta	tomtomoldobenx
	lda	tomtomuntensprite+MSPRITEX
	sta	tomtomolduntenx
	lda	tomtomviewdir
	sta	tomtomviewdirold
	lda	tomtomobensprite+MSPRITEY
	sta	tomtomoldobeny

	; Ermitteln der aktuellen Geschwindigkeit (in Abh. der gewuenschten Bewegung) -> in tomtomspeedact
	lda	KEYPRARR+11
	beq	tomtommove_lab41
	; User will nach links
	lda	#LEFT
	sta	tomtomviewdir
	lda	#1
	sta	tomtomjumphighflag
	lda	tomtomspeedact
	sec
	sbc	tomtomspeedinc
	sta	tomtomspeedact
	jmp	tomtommove_lab45
tomtommove_lab41:
	lda	KEYPRARR+20
	beq	tomtommove_lab42
	; User will nach rechts
	lda	#RIGHT
	sta	tomtomviewdir
	lda	#1
	sta	tomtomjumphighflag
	lda	tomtomspeedact
	clc
	adc	tomtomspeedinc
	sta	tomtomspeedact
	jmp	tomtommove_lab45
tomtommove_lab42:
	; User will stehen bleiben
	lda	tomtomspeedact
	beq	tomtommove_lab48
	bmi	tomtommove_lab44
	sec
	sbc	tomtomspeedinc
	sta	tomtomspeedact
	jmp	tomtommove_lab45
tomtommove_lab44:
	clc
	adc	tomtomspeedinc
	sta	tomtomspeedact
tomtommove_lab45:

	; TomTom-Geschwindigkeit korrigieren, falls noetig
	lda	tomtomspeedact
	bne	tomtommove_lab72
	jmp	tomtommove_lab24
tomtommove_lab72:
	bmi	tomtommove_lab46
	; tomtomspeedact > tomtomspeedright?
	cmp	tomtomspeedright
	beq	tomtommove_lab48
	bcc	tomtommove_lab47
	lda	tomtomspeedright
	sta	tomtomspeedact
	jmp	tomtommove_lab48
tomtommove_lab47:
	; tomtomspeedact < tomtomspeedinc?
	cmp	tomtomspeedinc
	bcs	tomtommove_lab48
	lda	#0
	sta	tomtomspeedact
	jmp	tomtommove_lab48
tomtommove_lab46:
	; tomtomspeedact < tomtomspeedleft?
	cmp	tomtomspeedleft
	beq	tomtommove_lab48
	bcs	tomtommove_lab49
	lda	tomtomspeedleft
	sta	tomtomspeedact
	jmp	tomtommove_lab48
tomtommove_lab49:
	; tomtomspeedact < tomtomspeedinc?
	eor	#255
	clc
	adc	#1
	cmp	tomtomspeedinc
	bcs	tomtommove_lab48
	lda	#0
	sta	tomtomspeedact

tomtommove_lab48:
	; TomTom bewegen in Abhaengigkeit der ermittelten Geschwindigkeit und Richtung
	lda	tomtomspeedact
	beq	tomtommove_lab24
	bpl	tomtommove_lab21
	; TomTom nach links
	lda	tomtomobensprite+MSPRITEX
	cmp	#TOMTOMMINX
	bcs	tomtommove_lab39
	lda	#0
	sta	tomtomspeedact
	; jump always
	beq	tomtommove_lab24
tomtommove_lab39:

	;   tomtomactspeed += tomtomspeedact;
	lda	tomtomactspeed
	sec
	sbc	tomtomspeedact
	;   while (tomtomactspeed >= TOMTOMBASESPEED) {
tomtommove_lab25:
	sta	tomtomactspeed
	cmp	#TOMTOMBASESPEED
	bcc	tomtommove_lab24
	;     spritex--;
	dec	tomtomobensprite+MSPRITEX
	dec	tomtomuntensprite+MSPRITEX
	;     tomtomactspeed -= TOMTOMBASESPEED;
	sec
	sbc	#TOMTOMBASESPEED
	jmp	tomtommove_lab25
	;   }
tomtommove_lab21:
	; TomTom nach rechts
	lda	tomtomobensprite+MSPRITEX
	cmp	tomtommaxx
	bcs	tomtommove_lab22
	;   tomtomactspeed += tomtomspeedact;
	lda	tomtomactspeed
	clc
	adc	tomtomspeedact
	;   while (tomtomactspeed >= TOMTOMBASESPEED) {
tomtommove_lab27:
	sta	tomtomactspeed
	cmp	#TOMTOMBASESPEED
	bcc	tomtommove_lab24
	;     spritex++;
	inc	tomtomobensprite+MSPRITEX
	inc	tomtomuntensprite+MSPRITEX
	;     tomtomactspeed -= TOMTOMBASESPEED;
	sec
	sbc	#TOMTOMBASESPEED
	jmp	tomtommove_lab27
	;   }
tomtommove_lab22:
	lda	endlevelzone
	bne	tomtommove_lab24
	lda	#1
	sta	scrollingon
tomtommove_lab24:

	; Koordinaten anpassen, wenn TomTom auf der "Platform" ist
	lda	tomtomonsprite
	beq	tomtommove_lab68
	; TomTom war auf einem "Platform"-Sprite
	; Ist TomTom noch immer auf einem "Platform"-Sprite?
	lda	tomtomonspriteid
	jsr	getenemyptrfromspritenum
	ldy	#MSPRITEY
	lda	(actcoincsprite),y
	sta	tomtomonspritey
	ldy	#MSPRITEPLATFORMTTDELTAX
	lda	tomtomobensprite+MSPRITEX
	clc
	adc	(actcoincsprite),y
	sta	tomtomobensprite+MSPRITEX
	lda	tomtomuntensprite+MSPRITEX
	clc
	adc	(actcoincsprite),y
	sta	tomtomuntensprite+MSPRITEX
	lda	#0
	sta	(actcoincsprite),y
	lda	tomtomuntensprite+MSPRITEX
	clc
	adc	#TOMTOMLOWER1W-4
	sta	tomtommovetemp1
	ldy	#MSPRITEX
	lda	(actcoincsprite),y
	cmp	#208
	bcs	tomtommove_lab101
	cmp	tomtommovetemp1
	bcs	tomtommove_lab76
tomtommove_lab101:
	lda	(actcoincsprite),y
	ldy	#MSPRITEW
	clc
	adc	(actcoincsprite),y
	sec
	sbc	#4
	cmp	tomtomuntensprite+MSPRITEX
	bcc	tomtommove_lab76
	lda	tomtomonspritey
	; jump always
	bne	tomtommove_lab69
tomtommove_lab76:
	lda	#0
	sta	tomtomonsprite
tomtommove_lab68:
	; Bestimmen der aktuellen y-Position
	lda	tomtomobensprite+MSPRITEX
	jsr	getyfromx
tomtommove_lab69:
	sec
	sbc	#(TOMTOMUPPERH+TOMTOMLOWERH)
	sta	tomtomacty
	lda	tomtomjumpflag
	bne	tomtommove_lab89
	lda	tomtomonsprite
	bne	tomtommove_lab86
	; TomTom-y-Position pruefen -> TomTom kann beim Laufen max. 2 Pixel ueberwinden
	lda	tomtomacty
	cmp	tomtomobensprite+MSPRITEY
	bcc	tomtommove_lab87
	; aktuelle Position gleich hoch oder weiter unten
	sec
	sbc	tomtomobensprite+MSPRITEY
	cmp	#TOMTOMMOVEMAXNUMOFPIXS+1
	bcc	tomtommove_lab86
	; aktuelle Position "deutlich" weiter unten -> Fall
	sta	tomtomjumpflag
	lda	#TOMTOMJUMPLASTIDX
	sta	tomtomactjumpidx
	; jump always
	bne	tomtommove_lab18
tomtommove_lab89:
	; TomTom springt gerade
	lda	tomtomobensprite+MSPRITEY
	cmp	tomtomacty
	bcc	tomtommove_lab97
	cmp	#GROUND
	bcs	tomtommove_lab97
	lda	flagwall
	beq	tomtommove_lab97
	; TomTom springt gegen eine Wand
	; jump always
	bne	tomtommove_lab88
tomtommove_lab87:
	; aktuelle Position hoeher
	clc
	adc	#TOMTOMMOVEMAXNUMOFPIXS+1
	cmp	tomtomobensprite+MSPRITEY
	bcs	tomtommove_lab86
tomtommove_lab88:
	; Wand vor TomTom
	lda	#0
	sta	scrollingon
	lda	tomtomolduntenx
	sta	tomtomuntensprite+MSPRITEX
	lda	tomtomoldobenx
	sta	tomtomobensprite+MSPRITEX
	; tomtomacty neu bestimmen!
	jsr	getyfromx
	sec
	sbc	#(TOMTOMUPPERH+TOMTOMLOWERH)
	sta	tomtomacty
	jmp	tomtommove_lab18
tomtommove_lab86:
	; TomTom-y-Position setzen
	lda	tomtomacty
	sta	tomtomobensprite+MSPRITEY
	clc
	adc	#TOMTOMUPPERH
	sta	tomtomuntensprite+MSPRITEY
tomtommove_lab18:
	lda	tomtomtumbleflag
	beq	tomtommove_lab97

	; TomTom stolpert ueber einen Stein
	dec	tomtomtumblecnt
	beq	tomtommove_lab70
	jmp	tomtommove_lab1
tomtommove_lab70:
	lda	#0
	sta	tomtomtumbleflag
	lda	#1
	sta	tomtombacktonormalcnt

	; * TomTom-Sprung *

tomtommove_lab97:
	lda	#0
	sta	keyjumpok
	lda	KEYPRARR+2
	beq	tomtommove_lab32
	lda	keyjumppressed
	bne	tomtommove_lab33
	; Neuer Sprung OK (wenn TomTom nicht bereits springt)
	lda	#1
	sta	keyjumpok
tomtommove_lab32:
	sta	keyjumppressed
tomtommove_lab33:
	lda	tomtomjumpflag
	bne	tomtommove_lab19
	lda	keyjumpok
	beq	tomtommove_lab67
	sta	tomtomjumpflag
	; Wird schon ein Sound Sample gespielt?
	lda	soundeffectflag
	bne	tomtommove_lab100
	; Vorbereitung Sample
	lda	#<(SNDJUMPFSIZE-4)
	sta	tmpautosndcnt
	lda	#>(SNDJUMPFSIZE-4)
	sta	tmpautosndcnt+1
	lda	#<(SNDJUMPFMEM+768+4)
	sta	tmpautosndptr
	lda	#>(SNDJUMPFMEM+768+4)
	sta	tmpautosndptr+1
	lda	#WBOYSAMPLESCONST1
	sta	tmpautosndsync
	lda	#1
	sta	newsoundeffectflag
tomtommove_lab100:
	; Init. Sprung-Variabeln
	lda	#0
	sta	tomtomactjumpidx
	sta	tomtomonsprite
	lda	tomtomjumphighflag
	bne	tomtommove_lab30
	lda	#<tomtomjumpslow
	sta	tomtomjumparr
	lda	#>tomtomjumpslow
	sta	tomtomjumparr+1
	jmp	tomtommove_lab19
tomtommove_lab67:
	jmp	tomtommove_lab20
tomtommove_lab30:
	lda	#<tomtomjumpfast
	sta	tomtomjumparr
	lda	#>tomtomjumpfast
	sta	tomtomjumparr+1
tomtommove_lab19:
	; TomTom springt
	ldy	tomtomactjumpidx
	lda	(tomtomjumparr),y
	cmp	#128
	bne	tomtommove_lab31
	dec	tomtomactjumpidx
	lda	#FALLDOWNSPEED
tomtommove_lab31:
	clc
	adc	tomtomobensprite+MSPRITEY
	cmp	tomtomacty
	bcc	tomtommove_lab23
	sec
	sbc	#FALLDOWNSPEED+TOMTOMMOVEMAXNUMOFPIXS
	cmp	tomtomacty
	bcc	tomtommove_lab40
	clc
	adc	#FALLDOWNSPEED
	; branch always
	bne	tomtommove_lab23
tomtommove_lab40:
	lda	#0
	sta	tomtomjumpflag
	lda	tomtomacty
tomtommove_lab23:
	inc	tomtomactjumpidx
	; TomTom stuertzt in den Abgrund?
	cmp	#(GROUND-TOMTOMUPPERH-TOMTOMLOWERH)
	bcc	tomtommove_lab66
	; Test auf "Sprung nach oben"
	cmp	#GROUND
	bcs	tomtommove_lab20
	jmp	tomtomdiesinit
tomtommove_lab66:
	sta	tomtomobensprite+MSPRITEY
	clc
	adc	#TOMTOMUPPERH
	sta	tomtomuntensprite+MSPRITEY
tomtommove_lab20:

	; * TomTom schiesst und/oder laeuft schneller *

	lda	#0
	sta	tomtomjumphighflag
	sta	keyfireok
	lda	KEYPRARR+26
	beq	tomtommove_lab34
	lda	keyfirepressed
	bne	tomtommove_lab35
	; Schuss OK (wenn nicht bereits 2 Schuesse abgegeben wurden)
	lda	#1
	sta	keyfireok
tomtommove_lab34:
	sta	keyfirepressed
tomtommove_lab35:
	lda	shot1sprite+MSPRITESTATUS
	bne	tomtommove_lab29
	lda	keyfireok
	bne	tomtommove_lab59
	jmp	tomtommove_lab36
tomtommove_lab59:
	jsr	tomtomfiresound
	lda	tomtomobensprite+MSPRITEX
	sta	shot1sprite+MSPRITEX
	lda	tomtomobensprite+MSPRITEY
	sta	shot1sprite+MSPRITEY
	lda	#0
	sta	keyfireok
	sta	shot1mvidx
	sta	shot1animlook
	lda	#SPEEDSHOTANIM
	sta	shot1animcnt
	lda	#10
	sta	tomtombacktonormalcnt
	ldx	#<shot1sprite
	ldy	#>shot1sprite
	callatm	addmsprite6502
	lda	tomtomviewdir
	bne	tomtommove_lab60
	; TomTom schiesst nach rechts -> Sprite anpassen
	lda	#<tomtomobenschuss
	sta	tomtomobensprite+MSPRITEDATA
	lda	#>tomtomobenschuss
	sta	tomtomobensprite+MSPRITEDATA+1
	; Schuss 1 fliegt nach rechts
	lda	#SHOTSPEEDX
	sta	shot1speed
	; branch always
	bne	tomtommove_lab29
tomtommove_lab60:
	; TomTom schiesst nach links -> Sprite anpassen
	lda	#<tomtomobenschussleft
	sta	tomtomobensprite+MSPRITEDATA
	lda	#>tomtomobenschussleft
	sta	tomtomobensprite+MSPRITEDATA+1
	; Schuss 1 fliegt nach links
	lda	#(256-SHOTSPEEDX)
	sta	shot1speed
tomtommove_lab29:
	; Schuss 1 fliegt
	lda	shot1sprite+MSPRITEX
	clc
	adc	shot1speed
	cmp	#SCREENWIDTH
	bcc	tomtommove_lab61
	cmp	#(256+4-SHOTWIDTH)
	bcs	tomtommove_lab61
	jmp	tomtommove_lab62
tomtommove_lab61:
	sta	shot1sprite+MSPRITEX
	jsr	getyfromx
	sec
	sbc	#SHOTHEIGTH
	sta	tomtommovetemp1
	ldy	shot1mvidx
	lda	shotmovetab,y
	cmp	#128
	bne	tomtommove_lab37
	dec	shot1mvidx
	lda	#FALLDOWNSPEED
tomtommove_lab37:
	clc
	adc	shot1sprite+MSPRITEY
	cmp	tomtommovetemp1
	bcc	tomtommove_lab38
tomtommove_lab62:
	ldx	#<shot1sprite
	ldy	#>shot1sprite
	callatm	delmsprite6502
	lda	tomtommovetemp1
tomtommove_lab38:
	inc	shot1mvidx
	sta	shot1sprite+MSPRITEY
tomtommove_lab36:
	lda	shot2sprite+MSPRITESTATUS
	bne	tomtommove_lab50
	lda	keyfireok
	beq	tomtommove_lab51
	jsr	tomtomfiresound
	lda	tomtomobensprite+MSPRITEX
	sta	shot2sprite+MSPRITEX
	lda	tomtomobensprite+MSPRITEY
	sta	shot2sprite+MSPRITEY
	lda	#0
	sta	shot2mvidx
	sta	shot2animlook
	lda	#SPEEDSHOTANIM
	sta	shot2animcnt
	lda	#10
	sta	tomtombacktonormalcnt
	ldx	#<shot2sprite
	ldy	#>shot2sprite
	callatm	addmsprite6502
	lda	tomtomviewdir
	bne	tomtommove_lab52
	; Schuss 2 fliegt nach rechts
	lda	#SHOTSPEEDX
	sta	shot2speed
	; branch always
	bne	tomtommove_lab50
tomtommove_lab52:
	; Schuss 2 fliegt nach links
	lda	#(256-SHOTSPEEDX)
	sta	shot2speed
tomtommove_lab50:
	; Schuss 2 fliegt
	lda	shot2sprite+MSPRITEX
	clc
	adc	shot2speed
	cmp	#SCREENWIDTH
	bcc	tomtommove_lab53
	cmp	#(256+4-SHOTWIDTH)
	bcs	tomtommove_lab53
	jmp	tomtommove_lab54
tomtommove_lab53:
	sta	shot2sprite+MSPRITEX
	jsr	getyfromx
	sta	tomtommovetemp1
	ldy	shot2mvidx
	lda	shotmovetab,y
	cmp	#128
	bne	tomtommove_lab55
	dec	shot2mvidx
	lda	#FALLDOWNSPEED
tomtommove_lab55:
	clc
	adc	shot2sprite+MSPRITEY
	cmp	tomtommovetemp1
	bcc	tomtommove_lab56
tomtommove_lab54:
	ldx	#<shot2sprite
	ldy	#>shot2sprite
	callatm	delmsprite6502
	lda	tomtommovetemp1
tomtommove_lab56:
	inc	shot2mvidx
	sta	shot2sprite+MSPRITEY
tomtommove_lab51:

	lda	keyfirepressed
	beq	tomtommove_lab3
	lda	#1
	sta	tomtomjumphighflag
	lda	#SCROLLSPEEDFAST
	sta	scrollspeed
	lda	#TOMTOMSPEEDFAST
	sta	tomtomspeedright
	lda	#TOMTOMSPEEDFASTL
	sta	tomtomspeedleft
	jmp	tomtommove_lab14
tomtommove_lab3:
	lda	#SCROLLSPEEDSLOW
	sta	scrollspeed
	lda	#TOMTOMSPEEDSLOW
	sta	tomtomspeedright
	lda	#TOMTOMSPEEDSLOWL
	sta	tomtomspeedleft
tomtommove_lab14:

	; * TomTom-Animation *

	dec	tomtombacktonormalcnt
	lda	tomtombacktonormalcnt
	beq	tomtommove_lab43
	lda	tomtomviewdir
	cmp	tomtomviewdirold
	beq	tomtommove_lab15
tomtommove_lab43:
	lda	tomtomviewdir
	bne	tomtommove_lab10
	lda	#<tomtomoben
	sta	tomtomobensprite+MSPRITEDATA
	lda	#>tomtomoben
	sta	tomtomobensprite+MSPRITEDATA+1
	jmp	tomtommove_lab15
tomtommove_lab10:
	lda	#<tomtomobenleft
	sta	tomtomobensprite+MSPRITEDATA
	lda	#>tomtomobenleft
	sta	tomtomobensprite+MSPRITEDATA+1
tomtommove_lab15:

	dec	tomtomanimcnt
	beq	tomtommove_lab2
	lda	tomtomviewdir
	cmp	tomtomviewdirold
	bne	tomtommove_lab2
	jmp	tomtommove_lab1
tomtommove_lab2:
	lda	tomtomobensprite+MSPRITEX
	sta	tomtomuntensprite+MSPRITEX
	lda	scrollspeed
	cmp	#SCROLLSPEEDFAST
	bne	tomtommove_lab98
	lda	#SPEEDTOMTOMANIMFAST
	bne	tomtommove_lab99
tomtommove_lab98:
	lda	#SPEEDTOMTOMANIMSLOW
tomtommove_lab99:
	sta	tomtomanimcnt
	inc	tomtomanimlook
	lda	tomtomjumpflag
	bne	tomtommove_lab28
	lda	tomtomspeedact
	beq	tomtommove_lab26
	lda	tomtomanimlook
	and	#3
	beq	tomtommove_lab11
	cmp	#1
	beq	tomtommove_lab12
	cmp	#2
	bne	tomtommove_lab28
	jmp	tomtommove_lab13
tomtommove_lab26:
	lda	tomtomanimlook
	and	#3
	beq	tomtommove_lab11
	cmp	#1
	beq	tomtommove_lab11
	jmp	tomtommove_lab13
tomtommove_lab28:
	; TomTom 4
	lda	tomtomviewdir
	bne	tomtommove_lab4
	lda	#<tomtomunten4
	sta	tomtomuntensprite+MSPRITEDATA
	lda	#>tomtomunten4
	sta	tomtomuntensprite+MSPRITEDATA+1
	jmp	tomtommove_lab5
tomtommove_lab4:
	lda	#<tomtomunten4left
	sta	tomtomuntensprite+MSPRITEDATA
	lda	#>tomtomunten4left
	sta	tomtomuntensprite+MSPRITEDATA+1
	lda	tomtomobensprite+MSPRITEX
	sec
	sbc	#(TOMTOMLOWER4W-TOMTOMLOWER1W)
	sta	tomtomuntensprite+MSPRITEX
tomtommove_lab5:
	lda	#TOMTOMLOWER4W
	sta	tomtomuntensprite+MSPRITEW
	jmp	tomtommove_lab1
tomtommove_lab11:
	; TomTom 1
	lda	tomtomviewdir
	bne	tomtommove_lab6
	lda	#<tomtomunten1
	sta	tomtomuntensprite+MSPRITEDATA
	lda	#>tomtomunten1
	sta	tomtomuntensprite+MSPRITEDATA+1
	jmp	tomtommove_lab7
tomtommove_lab6:
	lda	#<tomtomunten1left
	sta	tomtomuntensprite+MSPRITEDATA
	lda	#>tomtomunten1left
	sta	tomtomuntensprite+MSPRITEDATA+1
tomtommove_lab7:
	lda	#TOMTOMLOWER1W
	sta	tomtomuntensprite+MSPRITEW
	jmp	tomtommove_lab1
tomtommove_lab12:
	; TomTom 2
	lda	tomtomviewdir
	bne	tomtommove_lab8
	lda	#<tomtomunten2
	sta	tomtomuntensprite+MSPRITEDATA
	lda	#>tomtomunten2
	sta	tomtomuntensprite+MSPRITEDATA+1
	jmp	tomtommove_lab9
tomtommove_lab8:
	lda	#<tomtomunten2left
	sta	tomtomuntensprite+MSPRITEDATA
	lda	#>tomtomunten2left
	sta	tomtomuntensprite+MSPRITEDATA+1
	lda	tomtomobensprite+MSPRITEX
	sec
	sbc	#(TOMTOMLOWER2W-TOMTOMLOWER1W)
	sta	tomtomuntensprite+MSPRITEX
tomtommove_lab9:
	lda	#TOMTOMLOWER2W
	sta	tomtomuntensprite+MSPRITEW
	jmp	tomtommove_lab1
tomtommove_lab13:
	; TomTom 3
	lda	tomtomviewdir
	bne	tomtommove_lab16
	lda	#<tomtomunten3
	sta	tomtomuntensprite+MSPRITEDATA
	lda	#>tomtomunten3
	sta	tomtomuntensprite+MSPRITEDATA+1
	jmp	tomtommove_lab17
tomtommove_lab16:
	lda	#<tomtomunten3left
	sta	tomtomuntensprite+MSPRITEDATA
	lda	#>tomtomunten3left
	sta	tomtomuntensprite+MSPRITEDATA+1
tomtommove_lab17:
	lda	#TOMTOMLOWER3W
	sta	tomtomuntensprite+MSPRITEW

	; * Schuss1-Animation *

tomtommove_lab1:
	lda	shot1sprite+MSPRITESTATUS
	bne	tomtommove_lab85
	jmp	tomtommove_lab80
tomtommove_lab85:
	dec	shot1animcnt
	beq	tomtommove_lab57
	jmp	tomtommove_lab80
tomtommove_lab57:
	lda	#SPEEDSHOTANIM
	sta	shot1animcnt
	lda	shot1animlook
	and	#3
	beq	tomtommove_lab63
	cmp	#1
	beq	tomtommove_lab64
	cmp	#2
	beq	tomtommove_lab65
	; Hammer nach links oder rechts bewegen?
	lda	shot1speed
	bmi	tomtommove_lab81
	; Hammer 4 (nach rechts)
	lda	#<hammer4
	sta	shot1sprite+MSPRITEDATA
	lda	#>hammer4
	sta	shot1sprite+MSPRITEDATA+1
	jmp	tomtommove_lab58
tomtommove_lab81:
	; Hammer 3 (nach links)
	lda	#<hammer3
	sta	shot1sprite+MSPRITEDATA
	lda	#>hammer3
	sta	shot1sprite+MSPRITEDATA+1
	jmp	tomtommove_lab58
tomtommove_lab63:
	; Hammer nach links oder rechts bewegen?
	lda	shot1speed
	bmi	tomtommove_lab82
	; Hammer 1 (nach rechts)
	lda	#<hammer1
	sta	shot1sprite+MSPRITEDATA
	lda	#>hammer1
	sta	shot1sprite+MSPRITEDATA+1
	jmp	tomtommove_lab58
tomtommove_lab82:
	; Hammer 2 (nach links)
	lda	#<hammer2
	sta	shot1sprite+MSPRITEDATA
	lda	#>hammer2
	sta	shot1sprite+MSPRITEDATA+1
	jmp	tomtommove_lab58
tomtommove_lab64:
	; Hammer nach links oder rechts bewegen?
	lda	shot1speed
	bmi	tomtommove_lab83
	; Hammer 2 (nach rechts)
	lda	#<hammer2
	sta	shot1sprite+MSPRITEDATA
	lda	#>hammer2
	sta	shot1sprite+MSPRITEDATA+1
	jmp	tomtommove_lab58
tomtommove_lab83:
	; Hammer 1 (nach links)
	lda	#<hammer1
	sta	shot1sprite+MSPRITEDATA
	lda	#>hammer1
	sta	shot1sprite+MSPRITEDATA+1
	jmp	tomtommove_lab58
tomtommove_lab65:
	; Hammer nach links oder rechts bewegen?
	lda	shot1speed
	bmi	tomtommove_lab84
	; Hammer 3 (nach rechts)
	lda	#<hammer3
	sta	shot1sprite+MSPRITEDATA
	lda	#>hammer3
	sta	shot1sprite+MSPRITEDATA+1
	jmp	tomtommove_lab58
tomtommove_lab84:
	; Hammer 4 (nach links)
	lda	#<hammer4
	sta	shot1sprite+MSPRITEDATA
	lda	#>hammer4
	sta	shot1sprite+MSPRITEDATA+1
tomtommove_lab58:
	inc	shot1animlook
tomtommove_lab80:

	; * Schuss2-Animation *

	lda	shot2sprite+MSPRITESTATUS
	bne	tomtommove_lab95
	jmp	tomtommove_lab90
tomtommove_lab95:
	dec	shot2animcnt
	beq	tomtommove_lab77
	jmp	tomtommove_lab90
tomtommove_lab77:
	lda	#SPEEDSHOTANIM
	sta	shot2animcnt
	lda	shot2animlook
	and	#3
	beq	tomtommove_lab73
	cmp	#1
	beq	tomtommove_lab74
	cmp	#2
	beq	tomtommove_lab75
	; Hammer nach links oder rechts bewegen?
	lda	shot2speed
	bmi	tomtommove_lab91
	; Hammer 4 (nach rechts)
	lda	#<hammer4
	sta	shot2sprite+MSPRITEDATA
	lda	#>hammer4
	sta	shot2sprite+MSPRITEDATA+1
	jmp	tomtommove_lab78
tomtommove_lab91:
	; Hammer 3 (nach links)
	lda	#<hammer3
	sta	shot2sprite+MSPRITEDATA
	lda	#>hammer3
	sta	shot2sprite+MSPRITEDATA+1
	jmp	tomtommove_lab78
tomtommove_lab73:
	; Hammer nach links oder rechts bewegen?
	lda	shot2speed
	bmi	tomtommove_lab92
	; Hammer 1 (nach rechts)
	lda	#<hammer1
	sta	shot2sprite+MSPRITEDATA
	lda	#>hammer1
	sta	shot2sprite+MSPRITEDATA+1
	jmp	tomtommove_lab78
tomtommove_lab92:
	; Hammer 2 (nach links)
	lda	#<hammer2
	sta	shot2sprite+MSPRITEDATA
	lda	#>hammer2
	sta	shot2sprite+MSPRITEDATA+1
	jmp	tomtommove_lab78
tomtommove_lab74:
	; Hammer nach links oder rechts bewegen?
	lda	shot2speed
	bmi	tomtommove_lab93
	; Hammer 2 (nach rechts)
	lda	#<hammer2
	sta	shot2sprite+MSPRITEDATA
	lda	#>hammer2
	sta	shot2sprite+MSPRITEDATA+1
	jmp	tomtommove_lab78
tomtommove_lab93:
	; Hammer 1 (nach links)
	lda	#<hammer1
	sta	shot2sprite+MSPRITEDATA
	lda	#>hammer1
	sta	shot2sprite+MSPRITEDATA+1
	jmp	tomtommove_lab78
tomtommove_lab75:
	; Hammer nach links oder rechts bewegen?
	lda	shot2speed
	bmi	tomtommove_lab94
	; Hammer 3 (nach rechts)
	lda	#<hammer3
	sta	shot2sprite+MSPRITEDATA
	lda	#>hammer3
	sta	shot2sprite+MSPRITEDATA+1
	jmp	tomtommove_lab78
tomtommove_lab94:
	; Hammer 4 (nach links)
	lda	#<hammer4
	sta	shot2sprite+MSPRITEDATA
	lda	#>hammer4
	sta	shot2sprite+MSPRITEDATA+1
tomtommove_lab78:
	inc	shot2animlook
tomtommove_lab90:
	rts


tomtomdiesinit:
	; Vorbereitung Sample
	lda	#<(SNDWBOYDIESFSIZE-4)
	sta	tmpautosndcnt
	lda	#>(SNDWBOYDIESFSIZE-4)
	sta	tmpautosndcnt+1
	lda	#<(SNDWBOYDIESFMEM+768+4)
	sta	tmpautosndptr
	lda	#>(SNDWBOYDIESFMEM+768+4)
	sta	tmpautosndptr+1
	lda	#WBOYSAMPLESCONST1
	sta	tmpautosndsync
	lda	#1
	sta	newsoundeffectflag
	; TomTom stirbt
	lda	#1
	sta	tomtomdiesflag
	lda	#0
	sta	tomtomdiesmvidx
	sta	tomtomanimlook
	lda	#SPEEDTOMTOMDIESANIM
	sta	tomtomanimcnt
	lda	#TOMTOMDIESW
	sta	tomtomobensprite+MSPRITEW
	sta	tomtomuntensprite+MSPRITEW
	lda	tomtomobensprite+MSPRITEX
	sta	tomtomuntensprite+MSPRITEX
	; jump always
	bne	tomtomdies_lab6

tomtomdies:
	lda	tomtomobensprite+MSPRITEX
	jsr	getyfromx
	sta	tomtommovetemp1
	ldy	tomtomdiesmvidx
	lda	tomtomdiestab,y
	cmp	#128
	bne	tomtomdies_lab1
	dec	tomtomdiesmvidx
	lda	#FALLDOWNSPEED
tomtomdies_lab1:
	; y-Koordinate setzen
	clc
	adc	tomtomobensprite+MSPRITEY
	cmp	tomtommovetemp1
	bcs	tomtomdies_lab4
	sta	tomtomobensprite+MSPRITEY
	clc
	adc	#TOMTOMUPPERH
	sta	tomtomuntensprite+MSPRITEY
	inc	tomtomdiesmvidx
	; Animation
	dec	tomtomanimcnt
	beq	tomtomdies_lab5
	rts
tomtomdies_lab5:
	lda	#SPEEDTOMTOMDIESANIM
	sta	tomtomanimcnt
	lda	tomtomanimlook
	and	#1
	bne	tomtomdies_lab2
tomtomdies_lab6:
	lda	#<tomtomdies1oben
	sta	tomtomobensprite+MSPRITEDATA
	lda	#>tomtomdies1oben
	sta	tomtomobensprite+MSPRITEDATA+1
	lda	#<tomtomdies1unten
	sta	tomtomuntensprite+MSPRITEDATA
	lda	#>tomtomdies1unten
	sta	tomtomuntensprite+MSPRITEDATA+1
	jmp	tomtomdies_lab3
tomtomdies_lab2:
	lda	#<tomtomdies2oben
	sta	tomtomobensprite+MSPRITEDATA
	lda	#>tomtomdies2oben
	sta	tomtomobensprite+MSPRITEDATA+1
	lda	#<tomtomdies2unten
	sta	tomtomuntensprite+MSPRITEDATA
	lda	#>tomtomdies2unten
	sta	tomtomuntensprite+MSPRITEDATA+1
tomtomdies_lab3:
	inc 	tomtomanimlook
	; Schuss-Animation laeuft auch beim Sterben weiter
	jmp	tomtommove_lab1
tomtomdies_lab4:
	lda	#1
	sta	tomtomisdead
	rts


tomtomtumblesinit:
	lda	tomtomjumpflag
	bne	tomtomtumblesinit_lab1
	; Wird schon ein Sound Sample gespielt?
	lda	soundeffectflag
	bne	tomtomtumblesinit_lab4
	; Vorbereitung Sample
	lda	#<(SNDSTONEFSIZE-4)
	sta	tmpautosndcnt
	lda	#>(SNDSTONEFSIZE-4)
	sta	tmpautosndcnt+1
	lda	#<(SNDSTONEFMEM+768+4)
	sta	tmpautosndptr
	lda	#>(SNDSTONEFMEM+768+4)
	sta	tmpautosndptr+1
	lda	#WBOYSAMPLESCONST1
	sta	tmpautosndsync
	lda	#1
	sta	newsoundeffectflag
tomtomtumblesinit_lab4:
	; Energie anpassen
	lda	energycounter
	sta	energycounterold
	sec
	sbc	#4
	sta	energycounter
	jsr	adaptenergybar
	lda	#0
	sta	tomtombacktonormalcnt
	lda	#1
	sta	tomtomtumbleflag
	lda	#DURATIONOFTOMTOMTUMBLE
	sta	tomtomtumblecnt
	lda	tomtomviewdir
	bne	tomtomtumblesinit_lab2
	lda	#TOMTOMSPEEDTUMBLE
	sta	tomtomspeedact
tomtomtumblesinit_lab3:
	lda	#<tomtomtumbleoben
	sta	tomtomobensprite+MSPRITEDATA
	lda	#>tomtomtumbleoben
	sta	tomtomobensprite+MSPRITEDATA+1
	lda	#TOMTOMLOWER4W
	sta	tomtomuntensprite+MSPRITEW
	lda	#<tomtomtumbleunten
	sta	tomtomuntensprite+MSPRITEDATA
	lda	#>tomtomtumbleunten
	sta	tomtomuntensprite+MSPRITEDATA+1
tomtomtumblesinit_lab1:
	rts
tomtomtumblesinit_lab2:
	lda	#TOMTOMSPEEDTUMBLEL
	sta	tomtomspeedact
	; Gleiche Spritedaten wie beim Stolpern nach rechts (Bytes sparen)
	jmp	tomtomtumblesinit_lab3


tomtomfiresound:
	; Wird schon ein Sound Sample gespielt?
	lda	soundeffectflag
	bne	tomtomfiresound_lab1
	; Vorbereitung Sample
	lda	#<(SNDFIREFSIZE-4)
	sta	tmpautosndcnt
	lda	#>(SNDFIREFSIZE-4)
	sta	tmpautosndcnt+1
	lda	#<(SNDFIREFMEM+768+4)
	sta	tmpautosndptr
	lda	#>(SNDFIREFMEM+768+4)
	sta	tmpautosndptr+1
	lda	#WBOYSAMPLESCONST1
	sta	tmpautosndsync
	lda	#1
	sta	newsoundeffectflag
tomtomfiresound_lab1:
	rts


tomtomjumpslow:
.byt	253,253,253,253,253,253,253,253,253,254,254,255,255,0,1,1,2,2,3,3,3,3,3,3,3,3,3
tomtomjumpslowlastidx:
.byt	128
tomtomjumpfromspring:
.byt	252,252,252,252,252,252
tomtomjumpfast:
.byt	252,252,252,252,252,252,252,252,252,252,253,253,253,253,254,254,255,255,0,1,1,2,2,3,3,3,3,4,4,4,4,4,4,4,4,4,4,128
TOMTOMJUMPLASTIDX = tomtomjumpslowlastidx-tomtomjumpslow

tomtomdiestab:
.byt	253,253,253,253,254,254,254,254,254,254,254,254,255,255,128


shotmovetab:
.byt	0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,2,2,2,3,128
