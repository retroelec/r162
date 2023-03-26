; anonym.asm, v1.2, generated functions for anonym
; 
; Copyright (C) 2011-2013 retroelec <retroelec@freenet.ch>
; 
; This program is free software; you can redistribute it and/or modify it
; under the terms of the GNU General Public License as published by the
; Free Software Foundation; either version 3 of the License, or (at your
; option) any later version.
; 
; This program is distributed in the hope that it will be useful, but
; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
; or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
; for more details.
; 
; For the complete text of the GNU General Public License see
; www.gnu.org/licenses/.


anonyminit:
	; Initialisierungen fuer Ghost Anonym

	lda	#ANONYMSTARTX-GHOSTDSPRX
	sta	anonymsprite+MSPRITEX
	lda	#ANONYMSTARTY-GHOSTDSPRY
	sta	anonymsprite+MSPRITEY
	lda	#<anonymdataleft1
	sta	anonymsprite+MSPRITEDATA
	lda	#>anonymdataleft1
	sta	anonymsprite+MSPRITEDATA+1
	lda	#ANONYMSTARTPOSX
	sta	anonymtilexpos
	lda	#ANONYMSTARTPOSY
	sta	anonymtileypos
	lda	#MV_LEFT
	sta	anonymactdir
	lda	#0
	sta	anonymactspeedy
	sta	anonymactspeedx
	sta	anonymnochecktilepos
	sta	anonymchangedir
	jmp	anonymsetinittargetmode


anonymmove:
	; Bewegung des Ghosts Anonym

	lda	anonymactdir
	sta	ghostactdir
	lda	anonymtargetmode
	cmp	#TMODE_GOHOME
	bne	anonymmove_lab48
	jmp	anonymmove_lab45
anonymmove_lab48:

	; Muss ein Wechsel des Ghost-spezifischen Target-Modus von HOMEIN nach HOMEOUT durchgefuehrt werden (aufgrund eines Timer-Events)?
	lda	anonymtargetmode
	cmp	#TMODE_HOMEIN
	bne	anonymmove_lab46
	lda	pactimer1
	cmp	#ANONYMTIMEGOOUTOFHOME
	bcc	anonymmove_lab46
	lda	#TMODE_HOMEOUT
	sta	anonymtargetmode
	lda	#GHOSTGOHOMETARGETX
	sta	anonymfixedtargetxpos
	lda	#GHOSTGOHOMETARGETY
	sta	anonymfixedtargetypos
anonymmove_lab46:

	; Muss ein Wechsel des Ghost-spezifischen Target-Modus (SCATTER, CHASE, FRIGHTEN) durchgefuehrt werden (aufgrund eines Timer-Events)?
	lda	changedtargetmode
	beq	anonymmove_lab43
	cmp	#1
	bne	anonymmove_lab44
	; FRIGHTEN-Modus abgelaufen
	lda	anonymoldtargetmode
	cmp	#TMODE_HOMEOUT
	beq	anonymmove_lab63
	sta	anonymtargetmode
	jmp	anonymmove_lab43
anonymmove_lab63:
	lda	targetmode
	sta	anonymtargetmode
	jmp	anonymmove_lab43
anonymmove_lab44:
	; Wechsel zwischen SCATTER- und CHASE-Modus
	lda	anonymtargetmode
	cmp	#TMODES_CHASESCATTER
	bcs	anonymmove_lab43
	lda	targetmode
	sta	anonymtargetmode
	sta	anonymchangedir
anonymmove_lab43:

	; Wurde von Pacman eine Super-Pille gefressen?
	; -> wenn ja, dann muss der Ghost-spezifische Target-Modus angepasst werden
	lda	spilleaten
	beq	anonymmove_lab45
	lda	anonymtargetmode
	cmp	#TMODE_FRIGHTEN
	beq	anonymmove_lab38
	sta	anonymoldtargetmode
anonymmove_lab38:
	lda	anonymtargetmode
	cmp	#TMODES_CHASESCATTER
	bcs	anonymmove_lab42
	jsr	getrandomtargetpos
	stx	anonymfixedtargetxpos
	sty	anonymfixedtargetypos
anonymmove_lab42:
	lda	targetmode
	sta	anonymtargetmode
	sta	anonymchangedir
anonymmove_lab45:

	; Bestimme das Target von Anonym
	lda	anonymtargetmode
	sta	ghosttargetmode
	cmp	#TMODE_CHASE
	bne	anonymmove_lab32
	jsr	anonymgetchasetarget
	jmp	anonymmove_lab14
anonymmove_lab32:
	cmp	#TMODE_SCATTER
	bne	anonymmove_lab13
	lda	#ANONYMSCATTERTARGETX
	sta	ghosttargettilexpos
	lda	#ANONYMSCATTERTARGETY
	sta	ghosttargettileypos
	jmp	anonymmove_lab14
anonymmove_lab13:
	lda	anonymfixedtargetxpos
	sta	ghosttargettilexpos
	lda	anonymfixedtargetypos
	sta	ghosttargettileypos
anonymmove_lab14:

	; Bestimme die neue Position von Anonym (Aufruf von ghostmove)
	lda	anonymchangedir
	sta	ghostchangedir
	lda	anonymspeedy
	sta	ghostspeedy
	lda	anonymspeedx
	sta	ghostspeedx
	lda	anonymactspeedy
	sta	ghostactspeedy
	lda	anonymactspeedx
	sta	ghostactspeedx
	lda	anonymnochecktilepos
	sta	ghostnochecktilepos
	lda	anonymtilexpos
	sta	tmptilexpos
	lda	anonymtileypos
	sta	tmptileypos
	lda	anonymsprite+MSPRITEX
	clc
	adc	#GHOSTDSPRX
	sta	ghostspritex
	lda	anonymsprite+MSPRITEY
	clc
	adc	#GHOSTDSPRY
	sta	ghostspritey
	jsr	ghostmove
	lda	tmptilexpos
	sta	anonymtilexpos
	lda	tmptileypos
	sta	anonymtileypos
	lda	ghostspritex
	sec
	sbc	#GHOSTDSPRX
	sta	anonymsprite+MSPRITEX
	lda	ghostspritey
	sec
	sbc	#GHOSTDSPRY
	sta	anonymsprite+MSPRITEY
	lda	ghostactdir
	sta	anonymactdir
	lda	ghostchangedir
	sta	anonymchangedir
	lda	ghostspeedy
	sta	anonymspeedy
	lda	ghostspeedx
	sta	anonymspeedx
	lda	ghostactspeedy
	sta	anonymactspeedy
	lda	ghostactspeedx
	sta	anonymactspeedx
	lda	ghostnochecktilepos
	sta	anonymnochecktilepos

	; Gab es im FRIGHTEN-Modus eine Kollision?
	lda	collfright
	bne	anonymmove_lab56
	jmp	anonymmove_lab30
anonymmove_lab56:
	lda	#0
	sta	collfright
	; Ja, Modus aendern + Fixed-Target setzen
	lda	#TMODE_GOHOME
	sta	anonymtargetmode
	lda	#GHOSTGOHOMETARGETX
	sta	anonymfixedtargetxpos
	lda	#GHOSTGOHOMETARGETY
	sta	anonymfixedtargetypos
	; Punkte anzeigen + warten
	lda	#0
	sta	SOUNDFREQT2
	lda	#10
	jsr	waitawhile
	lda	#<ghostempty
	sta	anonymsprite+MSPRITEDATA
	lda	#>ghostempty
	sta	anonymsprite+MSPRITEDATA+1
	lda	pacmansprite+MSPRITEDATA
	sta	tmp1
	lda	pacmansprite+MSPRITEDATA+1
	sta	tmp2
	lda	#<pacmanempty
	sta	pacmansprite+MSPRITEDATA
	lda	#>pacmanempty
	sta	pacmansprite+MSPRITEDATA+1
	ldx	anonymsprite+MSPRITEX
	ldy	anonymsprite+MSPRITEY
	; Punkte werden bei jedem Ghost verdoppelt
	inc	ghosteatpts
	lda	ghosteatpts
	cmp	#1
	bne	anonymmove_lab49
	; Score erhoehen
	lda	score
	clc
	adc	#20
	sta	score
	bcc	anonymmove_lab52
	inc	score+1
anonymmove_lab52:
	stx	pts200sprite+MSPRITEX
	sty	pts200sprite+MSPRITEY
	ldx	#<pts200sprite
	ldy	#>pts200sprite
	jmp	anonymmove_lab12
anonymmove_lab49:
	cmp	#2
	bne	anonymmove_lab50
	; Score erhoehen
	lda	score
	clc
	adc	#40
	sta	score
	bcc	anonymmove_lab53
	inc	score+1
anonymmove_lab53:
	stx	pts400sprite+MSPRITEX
	sty	pts400sprite+MSPRITEY
	ldx	#<pts400sprite
	ldy	#>pts400sprite
	jmp	anonymmove_lab12
anonymmove_lab50:
	cmp	#3
	bne	anonymmove_lab51
	; Score erhoehen
	lda	score
	clc
	adc	#80
	sta	score
	bcc	anonymmove_lab54
	inc	score+1
anonymmove_lab54:
	stx	pts800sprite+MSPRITEX
	sty	pts800sprite+MSPRITEY
	ldx	#<pts800sprite
	ldy	#>pts800sprite
	jmp	anonymmove_lab12
anonymmove_lab51:
	; Score erhoehen
	lda	score
	clc
	adc	#160
	sta	score
	bcc	anonymmove_lab55
	inc	score+1
anonymmove_lab55:
	stx	pts1600sprite+MSPRITEX
	sty	pts1600sprite+MSPRITEY
	ldx	#<pts1600sprite
	ldy	#>pts1600sprite
anonymmove_lab12:
	callatm	addmsprite6502
	jsr	updatescore
	ldy	#SNDGHOSTEATEN
	ldx	#50
anonymmove_lab41:
	lda	TIMER
anonymmove_lab40:
	cmp	TIMER
	beq	anonymmove_lab40
	dey
	sty	SOUNDFREQT2
	dex
	bne	anonymmove_lab41
	lda	ghosteatpts
	cmp	#1
	bne	anonymmove_lab58
	ldx	#<pts200sprite
	ldy	#>pts200sprite
	callatm	delmsprite6502
	jmp	anonymmove_lab57
anonymmove_lab58:
	cmp	#2
	bne	anonymmove_lab59
	ldx	#<pts400sprite
	ldy	#>pts400sprite
	callatm	delmsprite6502
	jmp	anonymmove_lab57
anonymmove_lab59:
	cmp	#3
	bne	anonymmove_lab60
	ldx	#<pts800sprite
	ldy	#>pts800sprite
	callatm	delmsprite6502
	jmp	anonymmove_lab57
anonymmove_lab60:
	ldx	#<pts1600sprite
	ldy	#>pts1600sprite
	callatm	delmsprite6502
anonymmove_lab57:
	lda	tmp1
	sta	pacmansprite+MSPRITEDATA
	lda	tmp2
	sta	pacmansprite+MSPRITEDATA+1
	jmp	gohomesound
anonymmove_lab30:

	; Fuer die Modi HOMEOUT und GOHOME muss geprueft werden, ob das Target-Tile erreicht wurde
	lda	ghostnewdetdirflag
	bne	anonymmove_lab22
	lda	anonymtargetmode
	cmp	#TMODE_HOMEOUT
	beq	anonymmove_lab15
	cmp	#TMODE_GOHOME
	beq	anonymmove_lab15
	jmp	anonymmove_lab22
anonymmove_lab15:
	lda	anonymfixedtargetxpos
	cmp	anonymtilexpos
	bne	anonymmove_lab22
	lda	anonymfixedtargetypos
	cmp	anonymtileypos
	bne	anonymmove_lab22
	; Target-Tile wurde erreicht -> Modus aendern
	lda	anonymtargetmode
	cmp	#TMODE_HOMEOUT
	bne	anonymmove_lab47
	; Laufrichtung des Ghosts ist "nach links"
	lda	#MV_LEFT
	sta	anonymactdir
	lda	targetmode
	cmp	#TMODE_FRIGHTEN
	beq	anonymmove_lab39
	sta	anonymtargetmode
	jmp	anonymmove_lab33
anonymmove_lab47:
	; bisher -> GOHOME, neu -> HOMEOUT
	lda	#GHOSTINHOMEX
	sta	anonymtilexpos
	lda	#GHOSTINHOMEY
	sta	anonymtileypos
	lda	#((GHOSTINHOMEX*TILEWIDTH)+((TILEWIDTH-1)/2)-GHOSTDSPRX)
	sta	anonymsprite+MSPRITEX
	lda	#((GHOSTINHOMEY*TILEHEIGHT)+((TILEHEIGHT-1)/2)-GHOSTDSPRY)
	sta	anonymsprite+MSPRITEY
	lda	#TMODE_HOMEOUT
	sta	anonymtargetmode
	lda	targetmode
	cmp	#TMODE_FRIGHTEN
	bne	anonymmove_lab61
	jsr	frightensound
	jmp	anonymmove_lab62
anonymmove_lab61:
	jsr	sirensound
anonymmove_lab62:
	jmp	anonymmove_lab33
anonymmove_lab39:
	lda	oldtargetmode
	sta	anonymtargetmode
	jmp	anonymmove_lab33
anonymmove_lab22:

	; Setze die korrekten Sprite-Daten (0,1 -> Data1, ...)
	lda	anonymtargetmode
	cmp	#TMODE_FRIGHTEN
	bne	anonymmove_lab16
	jmp	anonymmove_lab17
anonymmove_lab16:
	cmp	#TMODE_GOHOME
	bne	anonymmove_lab33
	jmp	anonymmove_lab34
anonymmove_lab33:
	lda	anonymactdir
	cmp	#MV_UP
	bne	anonymmove_lab1
	; Ghost geht nach oben
	lda	ghostspritey
	and	#7
	cmp	#4
	bcc	anonymmove_lab4
anonymmove_lab5:
	; Data2
	lda	#<anonymdataup2
	sta	anonymsprite+MSPRITEDATA
	lda	#>anonymdataup2
	sta	anonymsprite+MSPRITEDATA+1
	rts
anonymmove_lab4:
	; Data1
	lda	#<anonymdataup1
	sta	anonymsprite+MSPRITEDATA
	lda	#>anonymdataup1
	sta	anonymsprite+MSPRITEDATA+1
	rts
anonymmove_lab1:
	cmp	#MV_DOWN
	bne	anonymmove_lab2
	; Ghost geht nach unten
	lda	ghostspritey
	and	#7
	cmp	#4
	bcc	anonymmove_lab6
anonymmove_lab7:
	; Data2
	lda	#<anonymdatadown2
	sta	anonymsprite+MSPRITEDATA
	lda	#>anonymdatadown2
	sta	anonymsprite+MSPRITEDATA+1
	rts
anonymmove_lab6:
	; Data1
	lda	#<anonymdatadown1
	sta	anonymsprite+MSPRITEDATA
	lda	#>anonymdatadown1
	sta	anonymsprite+MSPRITEDATA+1
	rts
anonymmove_lab2:
	cmp	#MV_LEFT
	bne	anonymmove_lab3
	; Ghost geht nach links
	lda	ghostspritex
	and	#3
	cmp	#2
	bcc	anonymmove_lab8
anonymmove_lab9:
	; Data2
	lda	#<anonymdataleft2
	sta	anonymsprite+MSPRITEDATA
	lda	#>anonymdataleft2
	sta	anonymsprite+MSPRITEDATA+1
	rts
anonymmove_lab8:
	; Data1
	lda	#<anonymdataleft1
	sta	anonymsprite+MSPRITEDATA
	lda	#>anonymdataleft1
	sta	anonymsprite+MSPRITEDATA+1
	rts
anonymmove_lab3:
	; Ghost geht nach rechts
	lda	ghostspritex
	and	#3
	cmp	#2
	bcc	anonymmove_lab10
anonymmove_lab11:
	; Data2
	lda	#<anonymdataright2
	sta	anonymsprite+MSPRITEDATA
	lda	#>anonymdataright2
	sta	anonymsprite+MSPRITEDATA+1
	rts
anonymmove_lab10:
	; Data1
	lda	#<anonymdataright1
	sta	anonymsprite+MSPRITEDATA
	lda	#>anonymdataright1
	sta	anonymsprite+MSPRITEDATA+1
	rts
anonymmove_lab17:
	ldy	#LDOFFGHOSTFRIGHTENBLINK
	lda	pactimer2
	cmp	(actleveldefs),y
	bcc	anonymmove_lab24
	and	#1
	beq	anonymmove_lab25
anonymmove_lab24:
	lda	ghostactdir
	cmp	#MV_UP
	beq	anonymmove_lab18
	cmp	#MV_DOWN
	bne	anonymmove_lab19
anonymmove_lab18:
	; Ghost geht nach oben oder unten
	lda	ghostspritey
	and	#7
	cmp	#4
	bcc	anonymmove_lab20
anonymmove_lab23:
	; Data2
	lda	#<ghostfrighten2
	sta	anonymsprite+MSPRITEDATA
	lda	#>ghostfrighten2
	sta	anonymsprite+MSPRITEDATA+1
	rts
anonymmove_lab20:
	; Data1
	lda	#<ghostfrighten1
	sta	anonymsprite+MSPRITEDATA
	lda	#>ghostfrighten1
	sta	anonymsprite+MSPRITEDATA+1
	rts
anonymmove_lab19:
	lda	ghostactdir
	cmp	#MV_LEFT
	beq	anonymmove_lab21
	cmp	#MV_RIGHT
	beq	anonymmove_lab21
	rts
anonymmove_lab21:
	; Ghost geht nach links oder rechts
	lda	ghostspritex
	and	#3
	cmp	#2
	bcc	anonymmove_lab20
	jmp	anonymmove_lab23
anonymmove_lab25:
	lda	ghostactdir
	cmp	#MV_UP
	beq	anonymmove_lab26
	cmp	#MV_DOWN
	bne	anonymmove_lab27
anonymmove_lab26:
	; Ghost geht nach oben oder unten
	lda	ghostspritey
	and	#7
	cmp	#4
	bcc	anonymmove_lab28
anonymmove_lab31:
	; Data2
	lda	#<ghostfrighten4
	sta	anonymsprite+MSPRITEDATA
	lda	#>ghostfrighten4
	sta	anonymsprite+MSPRITEDATA+1
	rts
anonymmove_lab28:
	; Data1
	lda	#<ghostfrighten3
	sta	anonymsprite+MSPRITEDATA
	lda	#>ghostfrighten3
	sta	anonymsprite+MSPRITEDATA+1
	rts
anonymmove_lab27:
	lda	ghostactdir
	cmp	#MV_LEFT
	beq	anonymmove_lab29
	cmp	#MV_RIGHT
	beq	anonymmove_lab29
	rts
anonymmove_lab29:
	; Ghost geht nach links oder rechts
	lda	ghostspritex
	and	#3
	cmp	#2
	bcc	anonymmove_lab28
	jmp	anonymmove_lab31
anonymmove_lab34:
	lda	ghostactdir
	cmp	#MV_UP
	bne	anonymmove_lab35
	; Ghost geht nach oben
	lda	#<ghosteyesup
	sta	anonymsprite+MSPRITEDATA
	lda	#>ghosteyesup
	sta	anonymsprite+MSPRITEDATA+1
	rts
anonymmove_lab35:
	cmp	#MV_DOWN
	bne	anonymmove_lab36
	; Ghost geht nach unten
	lda	#<ghosteyesdown
	sta	anonymsprite+MSPRITEDATA
	lda	#>ghosteyesdown
	sta	anonymsprite+MSPRITEDATA+1
	rts
anonymmove_lab36:
	cmp	#MV_LEFT
	bne	anonymmove_lab37
	; Ghost geht nach links
	lda	#<ghosteyesleft
	sta	anonymsprite+MSPRITEDATA
	lda	#>ghosteyesleft
	sta	anonymsprite+MSPRITEDATA+1
	rts
anonymmove_lab37:
	; Ghost geht nach rechts
	lda	#<ghosteyesright
	sta	anonymsprite+MSPRITEDATA
	lda	#>ghosteyesright
	sta	anonymsprite+MSPRITEDATA+1
	rts


anonymsprite:
	.word	0,0 ; next,prev
	.byt	ANONYMID,ANONYMSTARTX-GHOSTDSPRX,ANONYMSTARTY-GHOSTDSPRY,GHOSTWIDTH,GHOSTHEIGHT ; id,x,y,w,h
	.word	anonymdataleft1,anonymdatabg ; data,bg
	.dsb	4,0 ; *old
	.byte	MSPRITEDELETED ; status
	.byte	0 ; schwarz ist "transparent"
	; no coinc-detection
