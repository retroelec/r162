; pacmove.asm, v1.2, functions for pacman movement
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


PACID = 2
PACHOMETILEX = 19
PACHOMETILEY = 18
PACWIDTH = 6
PACHEIGHT = 10
PACDSPRX = 0+(PACWIDTH-1)/2
PACDSPRY = -1+(PACHEIGHT-1)/2
PACSTARTX = (PACHOMETILEX*TILEWIDTH)+3
PACSTARTY = (PACHOMETILEY*TILEHEIGHT)+((TILEHEIGHT-1)/2)

PACBASESPEEDX = 100
PACBASESPEEDY = 50


pacinit:
	; Initialisiere Sprite-Struktur (nicht fixe Attribute)
	lda	#PACSTARTX-PACDSPRX
	sta	pacmansprite+MSPRITEX
	lda	#PACSTARTY-PACDSPRY
	sta	pacmansprite+MSPRITEY
	lda	#<pacspritedataleft3
	sta	pacmansprite+MSPRITEDATA
	lda	#>pacspritedataleft3
	sta	pacmansprite+MSPRITEDATA+1
	; Initialisiere Bewegungs-Variabeln
	lda	#PACHOMETILEX
	sta	pactilexpos
	lda	#PACHOMETILEY
	sta	pactileypos
	lda	#MV_X
	sta	pacactxy
	lda	#MV_LEFT
	sta	pacactdir
	lda	#0
	sta	pacwanteddir
	ldy	#LDOFFPACSPEED
	lda	(actleveldefs),y
	sta	pacspeedx
	sta	pacspeedy
	lda	#0
	sta	pacactspeedy
	sta	pacactspeedx
	lda	#PACSTARTX
	sta	pacspritex
	lda	#PACSTARTY
	sta	pacspritey
	rts


; Funktion Pacman will nach oben
pacmoveup1:
	; Ausgabe ->  Bewegung moeglich (x = 1) resp. nicht moeglich (x = 0)
	; int pacmoveup1() {
	;   if (checkwall(spritex, spritey, -40, &tile) >= NOWALL) {
	;     pacactxy = y;
	;     pacmoveup2() {
	;       pacactdir = up;
	;       pacmoveup3() {
	;         moveup();
	;       }
	;     }
	;     return 1;
	;   }
	;   else {
	;     return 0;
	;   }
	; }
	; if (checkwall(spritex, spritey, -40, &tile) >= NOWALL) {
	ldy	#0
	lda	(tmptileposptr),y
	cmp	#NOWALL
	bcc	pacmoveup_lab6
	;   pacactxy = y;
	lda	#MV_Y
	sta	pacactxy
	; Rueckgabewert setzen (Bewegung moeglich)
	ldx	#1
pacmoveup2:
	;   pacactdir = up;
	lda	#MV_UP
	sta	pacactdir
pacmoveup3:
	;   pacactspeedy += pacspeedy;
	lda	pacspeedy
	clc
	adc	pacactspeedy
	sta	pacactspeedy
	;   while (pacactspeedy >= PACBASESPEEDY) {
pacmoveup_lab1:
	lda	pacactspeedy
	cmp	#PACBASESPEEDY
	bcc	pacmoveup_lab2
	;     spritey--;
	dec	pacmansprite+MSPRITEY
	dec	pacspritey
	;     pacactspeedy -= PACBASESPEEDY;
	sec
	sbc	#PACBASESPEEDY
	sta	pacactspeedy
	;     if (spritey % 7 == ((TILEHEIGHT-1)/2)) break;
	lda	pacspritey
	and	#7
	cmp	#((TILEHEIGHT-1)/2)
	bne	pacmoveup_lab1
	;   }
pacmoveup_lab2:
	; y-Tile-Position neu bestimmen
	lda	pacspritey
	lsr
	lsr
	lsr
	sta	pactileypos
	; Setze die korrekten Sprite-Daten (0,1 -> Data1, ...)
	lda	pacspritey
	and	#7
	cmp	#2
	bcc	pacmoveup_lab3
	cmp	#4
	bcc	pacmoveup_lab4
	cmp	#6
	bcc	pacmoveup_lab5
	; Data4
	lda	#<pacspritedataup4
	sta	pacmansprite+MSPRITEDATA
	lda	#>pacspritedataup4
	sta	pacmansprite+MSPRITEDATA+1
	rts
pacmoveup_lab3:
	; Data1
	lda	#<pacspritedataup1
	sta	pacmansprite+MSPRITEDATA
	lda	#>pacspritedataup1
	sta	pacmansprite+MSPRITEDATA+1
	rts
pacmoveup_lab4:
	; Data2
	lda	#<pacspritedataup2
	sta	pacmansprite+MSPRITEDATA
	lda	#>pacspritedataup2
	sta	pacmansprite+MSPRITEDATA+1
	rts
pacmoveup_lab5:
	; Data3
	lda	#<pacspritedataup3
	sta	pacmansprite+MSPRITEDATA
	lda	#>pacspritedataup3
	sta	pacmansprite+MSPRITEDATA+1
	rts
pacmoveup_lab6:
	; Rueckgabewert setzen (Bewegung nicht moeglich)
	ldx	#0
	rts


; Funktion Pacman will nach unten
pacmovedown1:
	; Ausgabe ->  Bewegung moeglich (x = 1) resp. nicht moeglich (x = 0)
	; int pacmovedown1() {
	;   if (checkwall(spritex, spritey, 40, &tile) >= NOWALL) {
	;     pacactxy = y;
	;     pacmovedown2() {
	;       pacactdir = down;
	;       pacmovedown3() {
	;         movedown();
	;       }
	;     }
	;     return 1;
	;   }
	;   else {
	;     return 0;
	;   }
	; }
	; if (checkwall(spritex, spritey, 40, &tile) >= NOWALL) {
	ldy	#80
	lda	(tmptileposptr),y
	cmp	#NOWALL
	bcc	pacmovedown_lab6
	;   pacactxy = y;
	lda	#MV_Y
	sta	pacactxy
	; Rueckgabewert setzen (Bewegung moeglich)
	ldx	#1
pacmovedown2:
	;   pacactdir = down;
	lda	#MV_DOWN
	sta	pacactdir
pacmovedown3:
	;   pacactspeedy += pacspeedy;
	lda	pacspeedy
	clc
	adc	pacactspeedy
	sta	pacactspeedy
	;   while (pacactspeedy >= PACBASESPEEDY) {
pacmovedown_lab1:
	lda	pacactspeedy
	cmp	#PACBASESPEEDY
	bcc	pacmovedown_lab2
	;     spritey++;
	inc	pacmansprite+MSPRITEY
	inc	pacspritey
	;     pacactspeedy -= PACBASESPEEDY;
	sec
	sbc	#PACBASESPEEDY
	sta	pacactspeedy
	;     if (spritey % 7 == ((TILEHEIGHT-1)/2)) break;
	lda	pacspritey
	and	#7
	cmp	#((TILEHEIGHT-1)/2)
	bne	pacmovedown_lab1
	;   }
pacmovedown_lab2:
	; y-Tile-Position neu bestimmen
	lda	pacspritey
	lsr
	lsr
	lsr
	sta	pactileypos
	; Setze die korrekten Sprite-Daten (0,1 -> Data1, ...)
	lda	pacspritey
	and	#7
	cmp	#2
	bcc	pacmovedown_lab3
	cmp	#4
	bcc	pacmovedown_lab4
	cmp	#6
	bcc	pacmovedown_lab5
	; Data4
	lda	#<pacspritedatadown4
	sta	pacmansprite+MSPRITEDATA
	lda	#>pacspritedatadown4
	sta	pacmansprite+MSPRITEDATA+1
	rts
pacmovedown_lab3:
	; Data1
	lda	#<pacspritedatadown1
	sta	pacmansprite+MSPRITEDATA
	lda	#>pacspritedatadown1
	sta	pacmansprite+MSPRITEDATA+1
	rts
pacmovedown_lab4:
	; Data2
	lda	#<pacspritedatadown2
	sta	pacmansprite+MSPRITEDATA
	lda	#>pacspritedatadown2
	sta	pacmansprite+MSPRITEDATA+1
	rts
pacmovedown_lab5:
	; Data3
	lda	#<pacspritedatadown3
	sta	pacmansprite+MSPRITEDATA
	lda	#>pacspritedatadown3
	sta	pacmansprite+MSPRITEDATA+1
	rts
pacmovedown_lab6:
	; Rueckgabewert setzen (Bewegung nicht moeglich)
	ldx	#0
	rts


; Funktion Pacman will nach links
pacmoveleft1:
	; Ausgabe ->  Bewegung moeglich (x = 1) resp. nicht moeglich (x = 0)
	; int pacmoveleft1() {
	;   if (checkwall(spritex, spritey, -1, &tile) >= NOWALL) {
	;     pacactxy = x;
	;     pacmoveleft2() {
	;       pacactdir = left;
	;       pacmoveleft3() {
	;         moveleft();
	;       }
	;     }
	;     return 1;
	;   }
	;   else {
	;     return 0;
	;   }
	; }
	; if (checkwall(spritex, spritey, -1, &tile) >= NOWALL) {
	ldy	#39
	lda	(tmptileposptr),y
	cmp	#NOWALL
	bcc	pacmoveleft_lab6
	;   pacactxy = x;
	lda	#MV_X
	sta	pacactxy
	; Rueckgabewert setzen (Bewegung moeglich)
	ldx	#1
pacmoveleft2:
	;   pacactdir = left;
	lda	#MV_LEFT
	sta	pacactdir
pacmoveleft3:
	;   pacactspeedx += pacspeedx;
	lda	pacspeedx
	clc
	adc	pacactspeedx
	sta	pacactspeedx
	;   while (pacactspeedx >= PACBASESPEEDX) {
pacmoveleft_lab1:
	lda	pacactspeedx
	cmp	#PACBASESPEEDX
	bcc	pacmoveleft_lab2
	;     spritex--;
	dec	pacmansprite+MSPRITEX
	dec	pacspritex
	;     pacactspeedx -= PACBASESPEEDX;
	sec
	sbc	#PACBASESPEEDX
	sta	pacactspeedx
	;     if (spritex % 3 == ((TILEWIDTH-1)/2)) break;
	lda	pacspritex
	and	#3
	cmp	#((TILEWIDTH-1)/2)
	bne	pacmoveleft_lab1
	;   }
pacmoveleft_lab2:
	; x-Tile-Position neu bestimmen
	lda	pacspritex
	lsr
	lsr
	sta	pactilexpos
	; Setze die korrekten Sprite-Daten (0,1 -> Data1, ...)
	lda	pacspritex
	and	#3
	beq	pacmoveleft_lab3
	cmp	#1
	beq	pacmoveleft_lab4
	cmp	#2
	beq	pacmoveleft_lab5
	; Data4
	lda	#<pacspritedataleft4
	sta	pacmansprite+MSPRITEDATA
	lda	#>pacspritedataleft4
	sta	pacmansprite+MSPRITEDATA+1
	rts
pacmoveleft_lab3:
	; Data1
	lda	#<pacspritedataleft1
	sta	pacmansprite+MSPRITEDATA
	lda	#>pacspritedataleft1
	sta	pacmansprite+MSPRITEDATA+1
	rts
pacmoveleft_lab4:
	; Data2
	lda	#<pacspritedataleft2
	sta	pacmansprite+MSPRITEDATA
	lda	#>pacspritedataleft2
	sta	pacmansprite+MSPRITEDATA+1
	rts
pacmoveleft_lab5:
	; Data3
	lda	#<pacspritedataleft3
	sta	pacmansprite+MSPRITEDATA
	lda	#>pacspritedataleft3
	sta	pacmansprite+MSPRITEDATA+1
	rts
pacmoveleft_lab6:
	; Rueckgabewert setzen (Bewegung nicht moeglich)
	ldx	#0
	rts


; Funktion Pacman will nach rechts
pacmoveright1:
	; Ausgabe ->  Bewegung moeglich (x = 1) resp. nicht moeglich (x = 0)
	; int pacmoveright1() {
	;   if (checkwall(spritex, spritey, 1, &tile) >= NOWALL) {
	;     pacactxy = x;
	;     pacmoveright2() {
	;       pacactdir = right;
	;       pacmoveright3() {
	;         moveright();
	;       }
	;     }
	;     return 1;
	;   }
	;   else {
	;     return 0;
	;   }
	; }
	; if (checkwall(spritex, spritey, 1, &tile) >= NOWALL) {
	ldy	#41
	lda	(tmptileposptr),y
	cmp	#NOWALL
	bcc	pacmoveright_lab6
	;   pacactxy = x;
	lda	#MV_X
	sta	pacactxy
	; Rueckgabewert setzen (Bewegung moeglich)
	ldx	#1
pacmoveright2:
	;   pacactdir = right;
	lda	#MV_RIGHT
	sta	pacactdir
pacmoveright3:
	;   pacactspeedx += pacspeedx;
	lda	pacspeedx
	clc
	adc	pacactspeedx
	sta	pacactspeedx
	;   while (pacactspeedx >= PACBASESPEEDX) {
pacmoveright_lab1:
	lda	pacactspeedx
	cmp	#PACBASESPEEDX
	bcc	pacmoveright_lab2
	;     spritex++;
	inc	pacmansprite+MSPRITEX
	inc	pacspritex
	;     pacactspeedx -= PACBASESPEEDX;
	sec
	sbc	#PACBASESPEEDX
	sta	pacactspeedx
	;     if (spritex % 3 == ((TILEWIDTH-1)/2)) break;
	lda	pacspritex
	and	#3
	cmp	#((TILEWIDTH-1)/2)
	bne	pacmoveright_lab1
	;   }
pacmoveright_lab2:
	; x-Tile-Position neu bestimmen
	lda	pacspritex
	lsr
	lsr
	sta	pactilexpos
	; Setze die korrekten Sprite-Daten (0,1 -> Data1, ...)
	lda	pacspritex
	and	#3
	beq	pacmoveright_lab3
	cmp	#1
	beq	pacmoveright_lab4
	cmp	#2
	beq	pacmoveright_lab5
	; Data4
	lda	#<pacspritedataright4
	sta	pacmansprite+MSPRITEDATA
	lda	#>pacspritedataright4
	sta	pacmansprite+MSPRITEDATA+1
	rts
pacmoveright_lab3:
	; Data1
	lda	#<pacspritedataright1
	sta	pacmansprite+MSPRITEDATA
	lda	#>pacspritedataright1
	sta	pacmansprite+MSPRITEDATA+1
	rts
pacmoveright_lab4:
	; Data2
	lda	#<pacspritedataright2
	sta	pacmansprite+MSPRITEDATA
	lda	#>pacspritedataright2
	sta	pacmansprite+MSPRITEDATA+1
	rts
pacmoveright_lab5:
	; Data3
	lda	#<pacspritedataright3
	sta	pacmansprite+MSPRITEDATA
	lda	#>pacspritedataright3
	sta	pacmansprite+MSPRITEDATA+1
	rts
pacmoveright_lab6:
	; Rueckgabewert setzen (Bewegung nicht moeglich)
	ldx	#0
	rts


pacmove:
	; if ((spritex & 3 == ((TILEWIDTH-1)/2)) && (spritey & 7 == ((TILEHEIGHT-1)/2))) {
	;   if (pacwanteddir == up) {
	;     moveok = pacmoveup1();
	;     if (! moveok) goto pacmoveinactdir
	;   }
	;   else if (pacwanteddir == down) {
	;     moveok = pacmovedown1();
	;     if (! moveok) goto pacmoveinactdir
	;   }
	;   else if (pacwanteddir == left) {
	;     moveok = pacmoveleft1();
	;     if (! moveok) goto pacmoveinactdir
	;   }
	;   else if (pacwanteddir == right) {
	;     moveok = pacmoveright1();
	;     if (! moveok) goto pacmoveinactdir
	;   }
	;   else {
	;     pacmoveinactdir:
	;     if (pacactxy == y) {
	;       if (pacactdir == up) pacmoveup1();
	;       else pacmovedown1();
	;     }
	;     else {
	;       if (pacactdir == left) pacmoveleft1();
	;       else pacmoveright1();
	;     }
	;   }
	;   pacwanteddir = 0;
	; }
	; else if (pacactxy == y) {
	;   if (pacwanteddir == up) pacmoveup2();
	;   else if (pacwanteddir == down) pacmovedown2();
	;   else {
	;     if (pacactdir == up) moveup();
	;     else movedown();
	;   }
	; }
	; else { // (pacactxy == x)
	;   if (pacwanteddir == left) pacmoveleft2();
	;   else if (pacwanteddir == right) pacmoveright2();
	;   else {
	;     if (pacactdir == left) moveleft();
	;     else moveright();
	;   }
	; }

	; if ((spritex & 3 == ((TILEWIDTH-1)/2)) && (spritey & 7 == ((TILEHEIGHT-1)/2))) {
	lda	pacspritex
	and	#3
	cmp	#((TILEWIDTH-1)/2)
	beq	pacmove_lab2
	jmp	pacmove_lab1
pacmove_lab2:
	lda	pacspritey
	and	#7
	cmp	#((TILEHEIGHT-1)/2)
	beq	pacmove_lab3
	jmp	pacmove_lab1
pacmove_lab3:

	; Ermittle "Tile-Position" von Pacman
	ldx	pacspritex
	ldy	pacspritey
	jsr	gettileposofsprite
	lda	tmptilexpos
	sta	pactilexpos
	lda	tmptileypos
	sta	pactileypos

	; Demo-Modus -> Evt. neue Richtung ermitteln
	lda	demomode
	beq	pacmove_lab35
	lda	pacactdir
	cmp	#MV_UP
	bne	pacmove_lab30
pacmove_lab33:
	; Demo-Modus -> Ist Pacman noch an der gleichen Position wie bei der letzten Prufung?
	lda	pactileypos
	cmp	demopactileyoldpos
	beq	pacmove_lab35
	ldy	#39
	lda	(tmptileposptr),y
	cmp	#NOWALL
	bcs	pacmove_lab31
	ldy	#41
	lda	(tmptileposptr),y
	cmp	#NOWALL
	bcs	pacmove_lab31
	jmp	pacmove_lab29
pacmove_lab30:
	cmp	#MV_DOWN
	bne	pacmove_lab32
	jmp	pacmove_lab33
pacmove_lab32:
	cmp	#MV_LEFT
	bne	pacmove_lab34
pacmove_lab36:
	; Demo-Modus -> Ist Pacman noch an der gleichen Position wie bei der letzten Prufung?
	lda	pactilexpos
	cmp	demopactilexoldpos
	beq	pacmove_lab35
	ldy	#0
	lda	(tmptileposptr),y
	cmp	#NOWALL
	bcs	pacmove_lab31
	ldy	#80
	lda	(tmptileposptr),y
	cmp	#NOWALL
	bcs	pacmove_lab31
	jmp	pacmove_lab29
pacmove_lab34:
	cmp	#MV_RIGHT
	bne	pacmove_lab29
	jmp	pacmove_lab36
pacmove_lab31:
	ldy	demomovepos
	lda	(demomoveptr),y
	sta	pacwanteddir
	inc	demomovepos
pacmove_lab29:
	lda	pactilexpos
	sta	demopactilexoldpos
	lda	pactileypos
	sta	demopactileyoldpos
pacmove_lab35:

	; Pruefe, ob Pacman eine Pille gefressen hat
	ldy	#40
	lda	(tmptileposptr),y
	cmp	#PIL
	bne	pacmove_lab24
	; Tile auf "leer" setzen
	lda	#EPI
	sta	(tmptileposptr),y
	lda	pactilexpos
	sta	deltilexpos
	lda	pactileypos
	sta	deltileypos
	; Signale setzen
	lda	#1
	sta	delpill
	lda	#SNDEFFECTPILLEATENCNT
	sta	pillsoundeffect
	; Anzahl Pillen dekrementieren
	dec	numofpillsleft
	bne	pacmove_lab11
	lda	#0
	sta	notlevelend
pacmove_lab11:
	; Score erhoehen
	inc	score
	bne	pacmove_lab25
	inc	score+1
pacmove_lab25:
	; Wenn Pacman eine Pille frisst, dann bleibt er fuer einen "Takt" stehen
	jmp	updatescore
pacmove_lab24:

	; Pruefe, ob Pacman eine Super-Pille gefressen hat
	cmp	#SPI
	bne	pacmove_lab7
	; Tile auf "leer" setzen
	lda	#EPI
	sta	(tmptileposptr),y
	lda	pactilexpos
	sta	deltilexpos
	lda	pactileypos
	sta	deltileypos
	; Signale setzen
	lda	#1
	sta	delpill
	sta	spilleaten
	; Reset Punkte-Zaehler
	lda	#0
	sta	ghosteatpts
	; Globaler Ghost-Modus aendern
	lda	targetmode
	cmp	#TMODE_FRIGHTEN
	beq	pacmove_lab16
	sta	oldtargetmode
	jsr	frightensound
pacmove_lab16:
	lda	#0
	sta	pactimer2
	lda	#TMODE_FRIGHTEN
	sta	targetmode
	; Geschwindigkeit von Pacman aendern
	ldy	#LDOFFPACFRIGHTENSPEED
	lda	(actleveldefs),y
	sta	pacspeedx
	sta	pacspeedy
	; Score erhoehen
	lda	score
	clc
	adc	#5
	sta	score
	bcc	pacmove_lab28
	inc	score+1
pacmove_lab28:
	; Wenn Pacman eine Super-Pille frisst, dann bleibt er fuer einen "Takt" stehen
	jmp	updatescore
pacmove_lab7:

	; Benutzt Pacman den Tunnel?
	cmp	#TPO
	bne	pacmove_lab5
	lda	pactilexpos
	cmp	#1
	beq	pacmove_lab9
	; Pacman benutzt den Durchgang rechts
	lda	#1
	sta	pactilexpos
	lda	#(1*TILEWIDTH)+((TILEWIDTH-1)/2)+1
	sta	pacspritex
	lda	#(1*TILEWIDTH)+((TILEWIDTH-1)/2)+1-PACDSPRX
	sta	pacmansprite+MSPRITEX
	rts
pacmove_lab9:
	; Pacman benutzt den Durchgang links
	lda	#38
	sta	pactileypos
	lda	#(38*TILEWIDTH)+((TILEWIDTH-1)/2)-1
	sta	pacspritex
	lda	#(38*TILEWIDTH)+((TILEWIDTH-1)/2)-1-PACDSPRX
	sta	pacmansprite+MSPRITEX
	rts
pacmove_lab5:

	cmp	#BON
	bne	pacmove_lab26
	jsr	clearbonussymbol1
	ldy	#LDOFFBONUSPTSSPRITE
	lda	(actleveldefs),y
	sta	bonussprite+MSPRITEDATA
	iny
	lda	(actleveldefs),y
	sta	bonussprite+MSPRITEDATA+1
	iny
	lda	(actleveldefs),y
	sta	bonussprite+MSPRITEW
	iny
	lda	(actleveldefs),y
	sta	bonussprite+MSPRITEH
	lda	#SHOWBONUSPTSCNT
	sta	bonusshowpoints
	lda	#SNDEFFECTBONUSEATENCNT
	sta	bonussoundeffect
	; Score erhoehen
	ldy	#LDOFFBONUSPTS
	lda	(actleveldefs),y
	clc
	adc	score
	sta	score
	iny
	lda	(actleveldefs),y
	adc	score+1
	sta	score+1
	jsr	updatescore
pacmove_lab26:

	; Pacman bewegen
	;   if (pacwanteddir == up) {
	lda	pacwanteddir
	cmp	#MV_UP
	bne	pacmove_lab4
	jsr	pacmoveup1
	cpx	#0
	beq	pacmoveinactdir
	jmp	pacmove_lab15
pacmove_lab4:
	;   else if (pacwanteddir == down) {
	cmp	#MV_DOWN
	bne	pacmove_lab6
	jsr	pacmovedown1
	cpx	#0
	beq	pacmoveinactdir
	jmp	pacmove_lab15
pacmove_lab6:
	;   else if (pacwanteddir == left) {
	cmp	#MV_LEFT
	bne	pacmove_lab8
	jsr	pacmoveleft1
	cpx	#0
	beq	pacmoveinactdir
	jmp	pacmove_lab15
pacmove_lab8:
	;   else if (pacwanteddir == right) {
	cmp	#MV_RIGHT
	bne	pacmove_lab10
	jsr	pacmoveright1
	cpx	#0
	beq	pacmoveinactdir
	jmp	pacmove_lab15
pacmove_lab10:
pacmoveinactdir:
	;     else if (pacactxy == y) {
	lda	pacactxy
	cmp	#MV_Y
	bne	pacmove_lab12
	;       if (pacactdir == up) pacmoveup1();
	lda	pacactdir
	cmp	#MV_UP
	bne	pacmove_lab13
	jsr	pacmoveup1
	jmp	pacmove_lab15
pacmove_lab13:
	;       else pacmovedown1();
	jsr	pacmovedown1
	jmp	pacmove_lab15
pacmove_lab12:
	;       if (pacactdir == left) pacmoveleft1();
	lda	pacactdir
	cmp	#MV_LEFT
	bne	pacmove_lab14
	jsr	pacmoveleft1
	jmp	pacmove_lab15
pacmove_lab14:
	;       else pacmoveright1();
	jsr	pacmoveright1
pacmove_lab15:
	;   pacwanteddir = 0;
	lda	#0
	sta	pacwanteddir
	rts
pacmove_lab1:
	; else if (pacactxy == y) {
	lda	pacactxy
	cmp	#MV_Y
	bne	pacmove_lab17
	;   if (pacwanteddir == up) pacmoveup2();
	lda	pacwanteddir
	cmp	#MV_UP
	bne	pacmove_lab18
	jmp	pacmoveup2
pacmove_lab18:
	;   else if (pacwanteddir == down) pacmovedown2();
	cmp	#MV_DOWN
	bne	pacmove_lab19
	jmp	pacmovedown2
pacmove_lab19:
	;     if (pacactdir == up) moveup();
	lda	pacactdir
	cmp	#MV_UP
	bne	pacmove_lab20
	jmp	pacmoveup3
pacmove_lab20:
	;     else movedown();
	jmp	pacmovedown3
	; else { // (pacactxy == x)
pacmove_lab17:
	;   if (pacwanteddir == left) goto labmoveleft2;
	lda	pacwanteddir
	cmp	#MV_LEFT
	bne	pacmove_lab21
	jmp	pacmoveleft2
pacmove_lab21:
	;   else if (pacwanteddir == right) goto labmoveright2;
	cmp	#MV_RIGHT
	bne	pacmove_lab22
	jmp	pacmoveright2
pacmove_lab22:
	;     if (pacactdir == left) moveleft();
	lda	pacactdir
	cmp	#MV_LEFT
	bne	pacmove_lab23
	jmp	pacmoveleft3
pacmove_lab23:
	;     else moveright();
	jmp	pacmoveright3


pacmandies:
	; Pacman stirbt

	; Entferne die Ghost-Sprites + das Bonus-Sprite falls vorhanden
	ldx	#<blinkysprite
	ldy	#>blinkysprite
	callatm	delmsprite6502
	ldx	#<pinkysprite
	ldy	#>pinkysprite
	callatm	delmsprite6502
	ldx	#<inkysprite
	ldy	#>inkysprite
	callatm	delmsprite6502
	ldx	#<clydesprite
	ldy	#>clydesprite
	callatm	delmsprite6502
	lda	bonusvisible
	beq	pacmandies_lab1
	jsr	clearbonussymbol
pacmandies_lab1:
	; Pacman stirbt
	lda	#SNDPACMANDIES1
	sta	SOUNDFREQT2
	lda	#25
	jsr	waitawhile
	lda	#<pacmandies1
	sta	pacmansprite+MSPRITEDATA
	lda	#>pacmandies1
	sta	pacmansprite+MSPRITEDATA+1
	lda	#SNDPACMANDIES2
	sta	SOUNDFREQT2
	lda	#25
	jsr	waitawhile
	lda	#<pacmandies2
	sta	pacmansprite+MSPRITEDATA
	lda	#>pacmandies2
	sta	pacmansprite+MSPRITEDATA+1
	lda	#SNDPACMANDIES3
	sta	SOUNDFREQT2
	lda	#25
	jsr	waitawhile
	lda	#<pacmandies3
	sta	pacmansprite+MSPRITEDATA
	lda	#>pacmandies3
	sta	pacmansprite+MSPRITEDATA+1
	lda	#SNDPACMANDIES4
	sta	SOUNDFREQT2
	lda	#25
	jsr	waitawhile
	lda	#<pacmandies4
	sta	pacmansprite+MSPRITEDATA
	lda	#>pacmandies4
	sta	pacmansprite+MSPRITEDATA+1
	lda	#SNDPACMANDIES5
	sta	SOUNDFREQT2
	lda	#25
	jsr	waitawhile
	lda	#<pacmandies5
	sta	pacmansprite+MSPRITEDATA
	lda	#>pacmandies5
	sta	pacmansprite+MSPRITEDATA+1
	lda	#SNDPACMANDIES6
	sta	SOUNDFREQT2
	lda	#25
	jsr	waitawhile
	ldx	#<pacmansprite
	ldy	#>pacmansprite
	callatm	delmsprite6502
	lda	#2
	jsr	waitawhile
	lda	#0
	sta	SOUNDFREQT2
	rts


pacmansprite:
	.word	0,0 ; next,prev
	.byt	PACID,PACSTARTX-PACDSPRX,PACSTARTY-PACDSPRY,PACWIDTH,PACHEIGHT ; id,x,y,w,h
	.word	pacspritedataleft3,pacmansprite1databg ; data,bg
	.dsb	4,0 ; *old
	.byte	MSPRITEDELETED ; status
	.byte	0 ; schwarz ist "transparent"
	; no coinc-detection
