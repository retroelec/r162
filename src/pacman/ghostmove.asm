; ghostmove.asm, v1.2, main functions for ghost movement
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


GHOSTWIDTH = 7
GHOSTHEIGHT = 11

GHOSTBASESPEEDX = 100
GHOSTBASESPEEDY = 50
GHOSTSPEEDXHOME = 25
GHOSTSPEEDYHOME = 25
GHOSTSPEEDXGOHOME = 150
GHOSTSPEEDYGOHOME = 150

GHOSTGOHOMETARGETX = 19
GHOSTGOHOMETARGETY = 10
GHOSTINHOMETARGETX = 19
GHOSTINHOMETARGETY = 13
GHOSTINHOMEX = 19
GHOSTINHOMEY = 12

GHOSTDSPRX = 0+(GHOSTWIDTH-1)/2
GHOSTDSPRY = -1+(GHOSTHEIGHT-1)/2


; Ghost-Target-Zustands-Uebergaenge
;
; HOMEIN ----> HOMEOUT
; HOMEOUT ----> SCATTER
; HOMEOUT ----> CHASE
; HOMEOUT ----> FRIGHTEN
; SCATTER ----> CHASE
; SCATTER ----> FRIGHTEN
; CHASE ----> SCATTER
; CHASE ----> FRIGHTEN
; FRIGHTEN ----> SCATTER
; FRIGHTEN ----> CHASE
; FRIGHTEN ----> GOHOME
; GOHOME ----> HOMEOUT
;
; Die Ghost-Modi SCATTER, CHASE und FRIGHTEN werden auch "global" gefuehrt (Variable targetmode)


ghostmoveindir:
	; Bewege den Ghost in die angegebene Richtung und detektiere Kollisionen
	; Eingabe -> Richtung, in die sich der Ghost bewegen soll, in Register A
	; Eingabe -> Sprite-Pos. des Ghosts (ghostspritexy)
	; Eingabe -> Geschwindigkeits-Variabeln des Ghosts (ghostspeedxy, ghostactspeedxy)
	; Ausgabe -> Neue Sprite-Pos. des Ghosts (ghostspritexy)
	; Ausgabe -> Veraenderte Geschwindigkeits-Variabeln des Ghosts (ghostactspeedxy)
	; Ausgabe -> Flag, das anzeigt, ob ein Ghost sich nach der Bestimmung einer Richtung schon bewegt hat (ghostnochecktilepos)
	; Ausgabe -> Flags, ob eine Kollision detektiert wurde (collfright, collision)

	; Detektiere Kollision mit Pacman bevor der Ghost bewegt wurde
	sta	ghostactdir
	jsr	ghostmoveindir_lab3

	; Bewege den Ghost in die angegebene Richtung
	lda	ghostactdir
	cmp	#MV_UP
	bne	ghostmoveindir_lab1
	jmp	ghostmoveindir_labup
ghostmoveindir_lab1:
	cmp	#MV_DOWN
	bne	ghostmoveindir_lab2
	jmp	ghostmoveindir_labdown
ghostmoveindir_lab2:
	cmp	#MV_LEFT
	bne	ghostmoveindir_labright
	jmp	ghostmoveindir_lableft
ghostmoveindir_labright:
	;   ghostactspeedx += ghostspeedx;
	lda	ghostspeedx
	clc
	adc	ghostactspeedx
	sta	ghostactspeedx
	;   while (ghostactspeedx >= GHOSTBASESPEEDX) {
ghostmoveindir_labright1:
	lda	ghostactspeedx
	cmp	#GHOSTBASESPEEDX
	bcc	ghostmoveindir_labright2
	;     spritex++;
	inc	ghostspritex
	ldx	#0
	stx	ghostnochecktilepos
	;     ghostactspeedx -= GHOSTBASESPEEDX;
	sec
	sbc	#GHOSTBASESPEEDX
	sta	ghostactspeedx
	;     if (spritex % 3 == ((TILEWIDTH-1)/2)) break;
	lda	ghostspritex
	and	#3
	cmp	#((TILEWIDTH-1)/2)
	bne	ghostmoveindir_labright1
	;   }
ghostmoveindir_labright2:
	jmp	ghostmoveindir_lab3
ghostmoveindir_labup:
	;   ghostactspeedy += ghostspeedy;
	lda	ghostspeedy
	clc
	adc	ghostactspeedy
	sta	ghostactspeedy
	;   while (ghostactspeedy >= GHOSTBASESPEEDY) {
ghostmoveindir_labup1:
	lda	ghostactspeedy
	cmp	#GHOSTBASESPEEDY
	bcc	ghostmoveindir_labup2
	;     spritey--;
	dec	ghostspritey
	ldx	#0
	stx	ghostnochecktilepos
	;     ghostactspeedy -= GHOSTBASESPEEDY;
	sec
	sbc	#GHOSTBASESPEEDY
	sta	ghostactspeedy
	;     if (spritey % 7 == ((TILEHEIGHT-1)/2)) break;
	lda	ghostspritey
	and	#7
	cmp	#((TILEHEIGHT-1)/2)
	bne	ghostmoveindir_labup1
	;   }
ghostmoveindir_labup2:
	jmp	ghostmoveindir_lab3
ghostmoveindir_labdown:
	;   ghostactspeedy += ghostspeedy;
	lda	ghostspeedy
	clc
	adc	ghostactspeedy
	sta	ghostactspeedy
	;   while (ghostactspeedy >= GHOSTBASESPEEDY) {
ghostmoveindir_labdown1:
	lda	ghostactspeedy
	cmp	#GHOSTBASESPEEDY
	bcc	ghostmoveindir_labdown2
	;     spritey++;
	inc	ghostspritey
	ldx	#0
	stx	ghostnochecktilepos
	;     ghostactspeedy -= GHOSTBASESPEEDY;
	sec
	sbc	#GHOSTBASESPEEDY
	sta	ghostactspeedy
	;     if (spritey % 7 == ((TILEHEIGHT-1)/2)) break;
	lda	ghostspritey
	and	#7
	cmp	#((TILEHEIGHT-1)/2)
	bne	ghostmoveindir_labdown1
	;   }
ghostmoveindir_labdown2:
	jmp	ghostmoveindir_lab3
ghostmoveindir_lableft:
	;   ghostactspeedx += ghostspeedx;
	lda	ghostspeedx
	clc
	adc	ghostactspeedx
	sta	ghostactspeedx
	;   while (ghostactspeedx >= GHOSTBASESPEEDX) {
ghostmoveindir_lableft1:
	lda	ghostactspeedx
	cmp	#GHOSTBASESPEEDX
	bcc	ghostmoveindir_lab3
	;     spritex--;
	dec	ghostspritex
	ldx	#0
	stx	ghostnochecktilepos
	;     ghostactspeedx -= GHOSTBASESPEEDX;
	sec
	sbc	#GHOSTBASESPEEDX
	sta	ghostactspeedx
	;     if (spritex % 3 == ((TILEWIDTH-1)/2)) break;
	lda	ghostspritex
	and	#3
	cmp	#((TILEWIDTH-1)/2)
	bne	ghostmoveindir_lableft1
	;   }
ghostmoveindir_lab3:
	; x-Tile-Position neu bestimmen
	lda	ghostspritex
	lsr
	lsr
	sta	tmptilexpos
	; y-Tile-Position neu bestimmen
	lda	ghostspritey
	lsr
	lsr
	lsr
	sta	tmptileypos

	; Detektiere Kollision zwischen Pacman und dem aktuellen Ghost
	lda	tmptilexpos
	cmp	pactilexpos
	beq	ghostcollide_lab1
	rts
ghostcollide_lab1:
	lda	tmptileypos
	cmp	pactileypos
	beq	ghostcollide_lab2
	rts
ghostcollide_lab2:
	; Kollision mit Pacman -> Fallunterscheidung
	lda	ghosttargetmode
	cmp	#TMODE_FRIGHTEN
	beq	ghostcollide_lab3
	cmp	#TMODE_GOHOME
	bne	ghostcollide_lab4
	rts
ghostcollide_lab3:
	; Pacman frisst Ghost
	sta	collfright
	rts
ghostcollide_lab4:
	; Ghost frisst Pacman
	sta	collision
	rts


ghostgettargetdist:
	; Berechne die euklidische Distanz zwischen ghosttargettilexypos und tmptilexypos
	; Eingabe -> ghosttargettilexpos, tmptilexpos, ghosttargettileypos, tmptileypos
	; Ausgabe -> abs(ghosttargettilexpos-tmptilexpos)^2 + abs(ghosttargettileypos-tmptileypos)^2

	lda	ghosttargettilexpos
	sec
	sbc	tmptilexpos
	bcs	ghostgettargetdist_lab1
	eor	#255
	adc	#1
ghostgettargetdist_lab1:
	tax
	tay
	callatm	mul8x86502
	lda	RMUL6502
	sta	tmpdiff
	lda	RMUL6502+1
	sta	tmpdiff+1
	lda	ghosttargettileypos
	sec
	sbc	tmptileypos
	bcs	ghostgettargetdist_lab2
	eor	#255
	adc	#1
ghostgettargetdist_lab2:
	tax
	tay
	callatm	mul8x86502
	lda	tmpdiff
	clc
	adc	RMUL6502
	sta	tmpdiff
	lda	tmpdiff+1
	adc	RMUL6502+1
	sta	tmpdiff+1
	rts


getrandomnum:
	ldx	rand
	ldy	#17
	callatm	mul8x86502
	lda	RMUL6502
	clc
	adc	#1
	sta	rand
	rts


getrandomtargetpos:
	; Ausgabe -> x = 1. Zufallszahl, y = 2. Zufallszahl

	jsr	getrandomnum
getrandomtargetpos_lab2:
	cmp	#40
	bcc	getrandomtargetpos_lab1
	lsr
	jmp	getrandomtargetpos_lab2
getrandomtargetpos_lab1:
	sta	tmp1
	jsr	getrandomnum
getrandomtargetpos_lab4:
	cmp	#25
	bcc	getrandomtargetpos_lab3
	lsr
	jmp	getrandomtargetpos_lab4
getrandomtargetpos_lab3:
	ldx	tmp1
	tay
	rts


ghostmove:
	; Bewege den Ghost in Richtung Target
	; Eingabe -> Sprite-Pos. des Ghosts (ghostspritexy)
	; Eingabe -> Geschwindigkeits-Variabeln des Ghosts (ghostspeedxy, ghostactspeedxy)
	; Eingabe -> Aktuelle Richtung des Ghosts (ghostactdir)
	; Eingabe -> Ghost-Target-Position (ghosttargettilexypos)
	; Eingabe -> Ghost-Target-Modus (ghosttargetmode)
	; Eingabe -> Tile-Position des Ghosts (tmptilexypos)
	; Eingabe -> Flag, ob der aktuelle Ghost einen Richtungswechsel machen muss (ghostchangedir)
	; Eingabe -> Flag aus dem letzten Aufruf, das anzeigt, ob ein Ghost sich nach der Bestimmung einer Richtung schon bewegt hat (ghostnochecktilepos)
	; Ausgabe -> Neue Sprite-Position des Ghosts (ghostspritexy)
	; Ausgabe -> Veraenderte Geschwindigkeits-Variabeln des Ghosts (ghostspeedxy, ghostactspeedxy)
	; Ausgabe -> Aktuelle Richtung des Ghosts (ghostactdir)
	; Ausgabe -> Tile-Position des Ghosts falls die Ghost-Richtung neu bestimmt wurde (tmptilexypos)
	; Ausgabe -> Flag, ob der aktuelle Ghost einen Richtungswechsel machen muss (ghostchangedir)
	; Ausgabe -> Flag, das anzeigt, ob ein Ghost sich nach der Bestimmung einer Richtung schon bewegt hat (ghostnochecktilepos)
	; Ausgabe -> Flag, ob die aktuelle Ghost-Richtung neu bestimmt wurde (ghostnewdetdirflag)
	; Ausgabe -> Flags, ob eine Kollision detektiert wurde (collfright, collision)

	; if ((spritex & 3 == ((TILEWIDTH-1)/2)) && (spritey & 7 == ((TILEHEIGHT-1)/2))) {
	;   // Ermittle die moeglichen Ghost-Bewegungen + den Abstand zum Target
	;   ghostgetpossibledirsanddists();
	;   // Ermittle die Richtung, in die der Ghost sich bewegen soll
	;   mintargetdist = 254;
	;   if ((ghosttargetdistup < mintargetdist) && (ghostactdir != down)) {
	;     mintargetdist = ghosttargetdistup;
	;     minghostdir = MV_UP;
	;   }
	;   if ((ghosttargetdistdown < mintargetdist) && (ghostactdir != up)) {
	;     mintargetdist = ghosttargetdistdown;
	;     minghostdir = MV_DOWN;
	;   }
	;   if ((ghosttargetdistleft < mintargetdist) && (ghostactdir != right)) {
	;     mintargetdist = ghosttargetdistleft;
	;     minghostdir = MV_LEFT;
	;   }
	;   if ((ghosttargetdistright < mintargetdist) && (ghostactdir != left)) {
	;     mintargetdist = ghosttargetdistright;
	;     minghostdir = MV_RIGHT;
	;   }
	;   if (mintargetdist == 254) {
	;     if (ghostactdir == MV_LEFT) minghostdir = MV_RIGHT;
	;     else if (ghostactdir == MV_RIGHT) minghostdir = MV_LEFT;
	;     else if (ghostactdir == MV_UP) minghostdir = MV_DOWN;
	;     else minghostdir = MV_UP;
	;   }
	;   ghostmoveindir(minghostdir);
	; }
	; else
	; {
	;   ghostmoveindir(ghostactdir);
	; }

	; if ((spritex & 3 == ((TILEWIDTH-1)/2)) && (spritey & 7 == ((TILEHEIGHT-1)/2))) {
	lda	ghostspritex
	and	#3
	cmp	#((TILEWIDTH-1)/2)
	beq	ghostmove_lab2
	jmp	ghostmove_lab1
ghostmove_lab2:
	lda	ghostspritey
	and	#7
	cmp	#((TILEHEIGHT-1)/2)
	beq	ghostmove_lab3
	jmp	ghostmove_lab1
ghostmove_lab3:

	; Bewegung nach "Tile-Match" wirklich erfolgt?
	lda	ghostnochecktilepos
	beq	ghostmove_lab8
	jmp	ghostmove_lab1
ghostmove_lab8:

	; Richtungswechsel?
	lda	ghostchangedir
	beq	ghostmove_lab25
	lda	#0
	sta	ghostchangedir
	; Wechsle die aktuelle Richtung des Ghosts
	lda	ghostactdir
	cmp	#MV_UP
	bne	ghostmove_lab26
	lda	#MV_DOWN
	sta	ghostactdir
	jmp	ghostmove_lab25
ghostmove_lab26:
	cmp	#MV_DOWN
	bne	ghostmove_lab27
	lda	#MV_UP
	sta	ghostactdir
	jmp	ghostmove_lab25
ghostmove_lab27:
	cmp	#MV_LEFT
	bne	ghostmove_lab28
	lda	#MV_RIGHT
	sta	ghostactdir
	jmp	ghostmove_lab25
ghostmove_lab28:
	lda	#MV_LEFT
	sta	ghostactdir
ghostmove_lab25:

	; Bestimmung der Tile-Position des aktuellen Ghosts
	ldx	ghostspritex
	ldy	ghostspritey
	jsr	gettileposofsprite

	; Geschwindigkeit des Ghosts in Abhaengigkeit des Modus
	lda	ghosttargetmode
	cmp	#TMODE_FRIGHTEN
	bne	ghostmove_lab31
	ldy	#LDOFFGHOSTSPEEDFRIGHTEN
	lda	(actleveldefs),y
	sta	ghostspeedx
	sta	ghostspeedy
	jmp	ghostmove_lab24
ghostmove_lab31:
	cmp	#TMODE_GOHOME
	bne	ghostmove_lab32
	lda	#GHOSTSPEEDXGOHOME
	sta	ghostspeedx
	lda	#GHOSTSPEEDYGOHOME
	sta	ghostspeedy
	jmp	ghostmove_lab29
ghostmove_lab32:
	cmp	#TMODE_HOMEIN
	beq	ghostmove_lab30
	cmp	#TMODE_HOMEOUT
	beq	ghostmove_lab30
	ldy	#LDOFFGHOSTSPEEDNORMAL
	lda	(actleveldefs),y
	sta	ghostspeedx
	sta	ghostspeedy
	jmp	ghostmove_lab24
ghostmove_lab30:
	lda	#GHOSTSPEEDXHOME
	sta	ghostspeedx
	lda	#GHOSTSPEEDYHOME
	sta	ghostspeedy
	jmp	ghostmove_lab29
ghostmove_lab24:

	; Tunnel? (Ghost wird langsamer)
	ldy	#40
	lda	(tmptileposptr),y
	cmp	#TUN
	bne	ghostmove_lab29
	ldy	#LDOFFGHOSTSPEEDTUNNEL
	lda	(actleveldefs),y
	sta	ghostspeedx
	sta	ghostspeedy
ghostmove_lab29:

	; Ghost benutzt den Durchgang?
	ldy	#40
	lda	(tmptileposptr),y
	cmp	#TPO
	bne	ghostmove_lab15
	lda	tmptilexpos
	cmp	#1
	beq	ghostmove_lab16
	; Ghost benutzt den Durchgang rechts
	lda	#1
	sta	tmptilexpos
	lda	#(1*TILEWIDTH)+((TILEWIDTH-1)/2)+1
	sta	ghostspritex
	ldy	#0
	sty	ghostnewdetdirflag
	rts
ghostmove_lab16:
	; Ghost benutzt den Durchgang links
	lda	#38
	sta	tmptilexpos
	lda	#(38*TILEWIDTH)+((TILEWIDTH-1)/2)-1
	sta	ghostspritex
	ldy	#0
	sty	ghostnewdetdirflag
	rts
ghostmove_lab15:

	; Ermittle die moeglichen Ghost-Bewegungen + den Abstand zum Target
	; Distanzen zum Target
	lda	#255
	sta	ghosttargetdistup+1
	ldy	#0
	lda	(tmptileposptr),y
	; Ghost kann die rosa Schranke nur von unten durchqueren
	; (ausser im GOHOME-Modus)
	cmp	#NOWALLGHOSTUP
	bcc	ghostmove_lab11
	dec	tmptileypos
	jsr	ghostgettargetdist
	lda	tmpdiff
	sta	ghosttargetdistup
	lda	tmpdiff+1
	sta	ghosttargetdistup+1
	inc	tmptileypos
ghostmove_lab11:
	lda	#255
	sta	ghosttargetdistdown+1
	ldy	#80
	lda	(tmptileposptr),y
	cmp	#NOWALL
	bcc	ghostmove_lab12
	inc	tmptileypos
	jsr	ghostgettargetdist
	lda	tmpdiff
	sta	ghosttargetdistdown
	lda	tmpdiff+1
	sta	ghosttargetdistdown+1
	dec	tmptileypos
ghostmove_lab12:
	lda	#255
	sta	ghosttargetdistleft+1
	ldy	#39
	lda	(tmptileposptr),y
	cmp	#NOWALL
	bcc	ghostmove_lab13
	dec	tmptilexpos
	jsr	ghostgettargetdist
	lda	tmpdiff
	sta	ghosttargetdistleft
	lda	tmpdiff+1
	sta	ghosttargetdistleft+1
	inc	tmptilexpos
ghostmove_lab13:
	lda	#255
	sta	ghosttargetdistright+1
	ldy	#41
	lda	(tmptileposptr),y
	cmp	#NOWALL
	bcc	ghostmove_lab14
	inc	tmptilexpos
	jsr	ghostgettargetdist
	lda	tmpdiff
	sta	ghosttargetdistright
	lda	tmpdiff+1
	sta	ghosttargetdistright+1
	dec	tmptilexpos
ghostmove_lab14:
	;   // Ermittle die Richtung, in die der Ghost sich bewegen soll
	;   mintargetdist = 254;
	lda	#254
	sta	mintargetdist+1
	;   if ((ghosttargetdistup < mintargetdist) && (ghostactdir != down)) {
	lda	ghostactdir
	cmp	#MV_DOWN
	beq	ghostmove_lab4
	lda	mintargetdist+1
	cmp	ghosttargetdistup+1
	bcc	ghostmove_lab4
	bne	ghostmove_lab9
	lda	mintargetdist
	cmp	ghosttargetdistup
	bcc	ghostmove_lab4
ghostmove_lab9:
	;     mintargetdist = ghosttargetdistup;
	lda	ghosttargetdistup
	sta	mintargetdist
	lda	ghosttargetdistup+1
	sta	mintargetdist+1
	;     minghostdir = MV_UP;
	ldx	#MV_UP
	;   }
ghostmove_lab4:
	;   if ((ghosttargetdistdown < mintargetdist) && (ghostactdir != up)) {
	lda	ghostactdir
	cmp	#MV_UP
	beq	ghostmove_lab5
	lda	mintargetdist+1
	cmp	ghosttargetdistdown+1
	bcc	ghostmove_lab5
	bne	ghostmove_lab10
	lda	mintargetdist
	cmp	ghosttargetdistdown
	bcc	ghostmove_lab5
ghostmove_lab10:
	;     mintargetdist = ghosttargetdistdown;
	lda	ghosttargetdistdown
	sta	mintargetdist
	lda	ghosttargetdistdown+1
	sta	mintargetdist+1
	;     minghostdir = MV_DOWN;
	ldx	#MV_DOWN
	;   }
ghostmove_lab5:
	;   if ((ghosttargetdistleft < mintargetdist) && (ghostactdir != right)) {
	lda	ghostactdir
	cmp	#MV_RIGHT
	beq	ghostmove_lab6
	lda	mintargetdist+1
	cmp	ghosttargetdistleft+1
	bcc	ghostmove_lab6
	bne	ghostmove_lab17
	lda	mintargetdist
	cmp	ghosttargetdistleft
	bcc	ghostmove_lab6
ghostmove_lab17:
	;     mintargetdist = ghosttargetdistleft;
	lda	ghosttargetdistleft
	sta	mintargetdist
	lda	ghosttargetdistleft+1
	sta	mintargetdist+1
	;     minghostdir = MV_LEFT;
	ldx	#MV_LEFT
	;   }
ghostmove_lab6:
	;   if ((ghosttargetdistright < mintargetdist) && (ghostactdir != left)) {
	lda	ghostactdir
	cmp	#MV_LEFT
	beq	ghostmove_lab7
	lda	mintargetdist+1
	cmp	ghosttargetdistright+1
	bcc	ghostmove_lab7
	bne	ghostmove_lab18
	lda	mintargetdist
	cmp	ghosttargetdistright
	bcc	ghostmove_lab7
ghostmove_lab18:
	;     mintargetdist = ghosttargetdistright;
	lda	ghosttargetdistright
	sta	mintargetdist
	lda	ghosttargetdistright+1
	sta	mintargetdist+1
	;     minghostdir = MV_RIGHT;
	ldx	#MV_RIGHT
	;   }
ghostmove_lab7:
	;   if (mintargetdist == 254) {
	lda	mintargetdist+1
	cmp	#254
	beq	ghostmove_lab20
ghostmove_lab19:
	;   ghostmoveindir(minghostdir);
	; }
	lda	#1
	sta	ghostnochecktilepos
	txa
	jsr	ghostmoveindir
	; Aktuelle Ghost-Richtung wurde neu bestimmt
	ldy	#0
	sty	ghostnewdetdirflag
	rts
ghostmove_lab1:
	; else
	; {
	;   ghostmoveindir(ghostactdir);
	; }
	lda	ghostactdir
	jsr	ghostmoveindir
	; Aktuelle Ghost-Richtung wurde nicht neu bestimmt
	ldy	#1
	sty	ghostnewdetdirflag
	rts
ghostmove_lab20:
	lda	ghostactdir
	;     if (ghostactdir == MV_LEFT) minghostdir = MV_RIGHT;
	cmp	#MV_LEFT
	bne	ghostmove_lab21
	ldx	#MV_RIGHT
	jmp	ghostmove_lab19
ghostmove_lab21:
	;     else if (ghostactdir == MV_RIGHT) minghostdir = MV_LEFT;
	cmp	#MV_RIGHT
	bne	ghostmove_lab22
	ldx	#MV_LEFT
	jmp	ghostmove_lab19
ghostmove_lab22:
	;     else if (ghostactdir == MV_UP) minghostdir = MV_DOWN;
	cmp	#MV_UP
	bne	ghostmove_lab23
	ldx	#MV_DOWN
	jmp	ghostmove_lab19
ghostmove_lab23:
	;     else minghostdir = MV_UP;
	ldx	#MV_UP
	jmp	ghostmove_lab19
