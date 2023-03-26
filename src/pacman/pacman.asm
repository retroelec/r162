; pacman.asm, v1.2, main program for pacman
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


; Kompilieren + Dekompilieren:	
; xa pacman.asm -o pacman -l pacman.lst
; dxa -a enabled -l pacman.lst pacman -g 9d0 > pacman.dis


#include "6502def.inc"


* = START6502CODE


; Globale Konstanten

MV_X = 0
MV_Y = 1
MV_UP = 1
MV_DOWN = 2
MV_LEFT = 4
MV_RIGHT = 8

TILEWIDTH = 4
TILEHEIGHT = 8

TMODE_CHASE = 1
TMODE_SCATTER = 2
TMODE_HOMEOUT = 3
TMODE_FRIGHTEN = 4
TMODE_HOMEIN = 5
TMODE_GOHOME = 6
TMODES_CHASESCATTER = 3

SPILLBLINKITER = 10
SHOWBONUSPTSCNT = 50
NUMOFLEVELS = 10

TIME1SHOWBONUSSYMBOL = 12
TIME1REMOVEBONUSSYMBOL = 22
TIME2SHOWBONUSSYMBOL = 62
TIME2REMOVEBONUSSYMBOL = 72

TEXTMAPPTR = MCOLORMAPDEFAULT-1000


; Variabeln

; Position des aktuellen Sprites in der Tilemap (ZP-Adresse)
tmptileposptr = 10
; Tile-X-Position des aktuellen Sprites
tmptilexpos = tmptileposptr+2
; Tile-Y-Position des aktuellen Sprites
tmptileypos = tmptilexpos+1
; Zeiger auf aktuelle Level-Definitionen (ZP-Adresse)
actleveldefs = tmptileypos+1
; Tile-X-Position der zu loeschenden Pille
deltilexpos = actleveldefs+2
; Tile-Y-Position der zu loeschenden Pille
deltileypos = deltilexpos+1
; Flag, das anzeigt, ob Pacman eine Pille oder Super-Pille gefressen hat und diese entfernt werden muss (im VSYNC-Interrupt)
delpill = deltileypos+1
; Flag, das anzeigt, ob eine Super-Pille gefressen wurde
spilleaten = delpill+1
; Flag, ob das Bonus-Symbols angezeigt wird
bonusvisible = spilleaten+1
; Position, an der das Bonus-Icon gezeichnet wird (x-Koordinate)
bonusiconpos = bonusvisible+1
; Anzahl noch vorhandener Pillen
numofpillsleft = bonusiconpos+1
; Wechsel des globalen Target-Modus aufgrund Timer-Events
; 0 -> Kein Wechsel
; 1 -> FRIGHTEN-Modus abgelaufen
; 2 -> Wechsel zwischen SCATTER- und CHASE-Modus
changedtargetmode = numofpillsleft+1
; Anzahl Leben
lifesleft = changedtargetmode+1
; Flag, ob es eine Kollision gegeben hat (nicht FRIGHTEN-Modus)
collision = lifesleft+1
; Flag, ob es eine Kollision im FRIGHTEN-Modus gegeben hat
collfright = collision+1
; Anzahl Punkte, die Pacman beim Essen eines Ghost erhaelt
ghosteatpts = collfright+1
; Level fertig (alle Pillen gefressen)?
notlevelend = ghosteatpts+1
; Aktuelle Zufallszahl
rand = notlevelend+1
; Offset innerhalb der Ghost-Scatter-Chase-Tabelle
ghostmodeptr = rand+1
; Globaler Ghost-Target-Modus
targetmode = ghostmodeptr+1
; Alter Ghost-Modus beim Wechsel auf TMODE_FRIGHTEN
oldtargetmode = targetmode+1
; Temporaere Variable fuer die Funktion waitawhile
tmpwaitawhile = oldtargetmode+1
; Temporaere Variable fuer Timer1
tmptimer1 = tmpwaitawhile+1
; Temporaere Variable fuer Timer2
tmptimer2 = tmptimer1+1
; Temporaere Variable fuer Timer3
tmptimer3 = tmptimer2+1
; Timer1
pactimer1 = tmptimer3+1
; Timer2
pactimer2 = pactimer1+1
; Timer3
pactimer3 = pactimer2+1
; Pointer auf die abzuspielenden Toene (auf das Sound-Array) (ZP-Adresse)
soundptr = pactimer3+1
; Anzahl Aufrufe der Sound-Funktion bis ein neuer Ton gespielt wird
soundcounter = soundptr+2
; Variable, die auf die aktuelle Position im Sound-Array zeigt
soundpos = soundcounter+1
; Variable, die die Anzahl der Aufrufe der Sound-Funktion zaehlt
soundactcounter = soundpos+1
; Variable, die die Dauer eines Pillen-Sound-Effekts beinhaltet
pillsoundeffect = soundactcounter+1
; Variable, die die Dauer eines Bonus-Sound-Effekts beinhaltet
bonussoundeffect = pillsoundeffect+1
; Pointer auf den Bonus-Sound (ZP-Adresse)
bonussoundptr = bonussoundeffect+1
; Pointer auf die abzuspielende Timer1-Melody (ZP-Adresse)
melodyptr1 = bonussoundptr+2
; Pointer auf die abzuspielende Timer2-Melody (ZP-Adresse)
melodyptr2 = melodyptr1+2
; Dauer des aktuellen Tones der Timer1-Melody
durationsnd1 = melodyptr2+2
; Dauer des aktuellen Tones der Timer2-Melody
durationsnd2 = durationsnd1+1
; Temporaere Variable fuer Timer1
tmpptrsnd1 = durationsnd2+1
; Temporaere Variable fuer Timer2
tmpptrsnd2 = tmpptrsnd1+1
; Zaehler, mit dem die Blink-Frequenz der Super-Pillen gesteuert wird
spillblinkcnt = tmpptrsnd2+1
; Blinken der Super-Pillen -> Aktuell dargestelltes Tile (EPI oder SPI)
spillblinktile = spillblinkcnt+1
; Score
score = spillblinktile+1
; Flag, ob das Bonus-Leben schon erhalten wurde
gotbonuslife = score+2
; Variable, die die Dauer eines Extra-Life-Sound-Effekts beinhaltet
extralifesoundeffect = gotbonuslife+1
; Pointer auf den Bonus-Sound (ZP-Adresse)
extralifesoundptr = extralifesoundeffect+1
; High-Score
highscore = extralifesoundptr+2
; Flag, welches anzeigt, ob die Start-Melodie gespielt werden muss
flagplaystartmelody = highscore+2
; Variable, die die Dauer der Bonus-Punkte-Anzeige beinhaltet
bonusshowpoints = flagplaystartmelody+1
; Demo-Modus-Flag
demomode = bonusshowpoints+1
; Variable, die auf die aktuelle Position im Bewegungs-Array zeigt
demomovepos = demomode+1
; Pointer auf das Bewegungs-Array (ZP-Adresse)
demomoveptr = demomovepos+1
; Demo-Modus -> Alte Tile-X-Position von Pacman
demopactilexoldpos = demomoveptr+2
; Demo-Modus -> Alte Tile-Y-Position von Pacman
demopactileyoldpos = demopactilexoldpos+1
; Aktueller Level
actlevel = demopactileyoldpos+1
; Credits
credits = actlevel+1
; Erhoehung des Credits -> Sound + Warten bis naechste Erhoehung akzeptiert wird
creditsound = credits+1
; Stack-Pointer Ebene 0
stack = creditsound+1

; Tile-X-Position von Pacman
pactilexpos = stack+1
; Tile-Y-Position von Pacman
pactileypos = pactilexpos+1
; Aktuelle Bewegungsachse von Pacman
pacactxy = pactileypos+1
; Aktuelle Richtung von Pacman
pacactdir = pacactxy+1
; Gewuenschte Richtung von Pacman
pacwanteddir = pacactdir+1
; Sprite-X-Position von Pacman
pacspritex = pacwanteddir+1
; Sprite-Y-Position des aktuellen Ghosts
pacspritey = pacspritex+1
; Geschwindigkeit von Pacman in y-Richtung
pacspeedy = pacspritey+1
; Temporaere Variable (Geschwindigkeit von Pacman in y-Richtung)
pacactspeedy = pacspeedy+1
; Geschwindigkeit von Pacman in x-Richtung
pacspeedx = pacactspeedy+1
; Temporaere Variable (Geschwindigkeit von Pacman in x-Richtung)
pacactspeedx = pacspeedx+1

; Sprite-X-Position des aktuellen Ghosts
ghostspritex = pacactspeedx+1
; Sprite-Y-Position des aktuellen Ghosts
ghostspritey = ghostspritex+1
; Aktuelle Richtung des aktuellen Ghosts
ghostactdir = ghostspritey+1
; Target-Modus des aktuellen Ghosts
ghosttargetmode = ghostactdir+1
; Geschwindigkeit des aktuellen Ghosts in y-Richtung
ghostspeedy = ghosttargetmode+1
; Temporaere Variable (Geschwindigkeit des aktuellen Ghosts in y-Richtung)
ghostactspeedy = ghostspeedy+1
; Geschwindigkeit des aktuellen Ghosts in x-Richtung
ghostspeedx = ghostactspeedy+1
; Temporaere Variable (Geschwindigkeit des aktuellen Ghosts in x-Richtung)
ghostactspeedx = ghostspeedx+1
; Flag, das anzeigt, ob ein Ghost sich nach der Bestimmung einer Richtung schon bewegt hat
ghostnochecktilepos = ghostactspeedx+1
; Flag, ob die aktuelle Ghost-Richtung neu bestimmt wurde
ghostnewdetdirflag = ghostnochecktilepos+1
; Abstand des Ghosts zum Target bei Bewegung nach oben
ghosttargetdistup = ghostnewdetdirflag+1
; Abstand des Ghosts zum Target bei Bewegung nach unten
ghosttargetdistdown = ghosttargetdistup+2
; Abstand des Ghosts zum Target bei Bewegung nach links
ghosttargetdistleft = ghosttargetdistdown+2
; Abstand des Ghosts zum Target bei Bewegung nach rechts
ghosttargetdistright = ghosttargetdistleft+2
; Minimaler Abstand einer Ghost-Position zum Target
mintargetdist = ghosttargetdistright+2
; Temporaere Variable zur Berechnung des Abstandes eines Ghosts zum Target
tmpdiff = mintargetdist+2
; Tile-X-Position des Ghost-Targets
ghosttargettilexpos = tmpdiff+2
; Tile-Y-Position des Ghost-Targets
ghosttargettileypos = ghosttargettilexpos+1
; Flag, ob der aktuelle Ghost einen Richtungswechsel machen muss
ghostchangedir = ghosttargettileypos+1

; function char2tile -> color of tiles
c2tcoldata = ghostchangedir+1
; function char2tile -> pointer to tile definitions
c2ttiledata = c2tcoldata+1
; function char2tile -> pointer to char definitions
c2tchardefs = c2ttiledata+2
; function char2tile -> temporary counter
c2tcnt = c2tchardefs+2
; function char2tile -> temporary char data
c2tchardata = c2tcnt+1
; function char2tile -> temporary tile data
c2ttmpdata = c2tchardata+1

; Temporaere Variabeln
tmp1 = c2ttmpdata+1
tmp2 = tmp1+1
; Temporaerer Pointer (ZP-Adresse)
tmpptr = tmp2+1

; Start Block mit Variablen fuer Blinky (generierte Variablen)
blinkystartblock = tmpptr+2
#include "blinkyvars.asm"

; Start Block mit Variablen fuer Pinky (generierte Variablen)
pinkystartblock = blinkyendblock
#include "pinkyvars.asm"

; Start Block mit Variablen fuer Inky (generierte Variablen)
inkystartblock = pinkyendblock
#include "inkyvars.asm"

; Start Block mit Variablen fuer Clyde (generierte Variablen)
clydestartblock = inkyendblock
#include "clydevars.asm"


; Autostart-Programm
jmp	start
.asc	"AUTO"


start:
	; Initialisierungen
	tsx
	stx	stack
	jsr	initpacman

	; Starte Intro
	jmp	intro


; Cheat-Register
cheat:
.byt	0


mainloop:
	; Haupt-Schlaufe

	; Warte auf VSYNC
	lda	TIMER
lab0:
	cmp	TIMER
	beq	lab0

	; Timer aktualisieren
	inc	tmptimer3
	lda	tmptimer3
	cmp	#50
	bne	lab22
	inc	pactimer3
	lda	#0
	sta	tmptimer3
lab22:
	lda	targetmode
	cmp	#TMODE_FRIGHTEN
	bne	lab13
	inc	tmptimer2
	lda	tmptimer2
	cmp	#10
	bne	lab14
	inc	pactimer2
	lda	#0
	sta	tmptimer2
lab13:
	inc	tmptimer1
	lda	tmptimer1
	cmp	#50
	bne	lab14
	inc	pactimer1
	lda	#0
	sta	tmptimer1
lab14:

	; Spezielle Tasten (Spiel beenden, pausieren, etc.)
	jsr	checkkeys

	; Level beendet?
	lda	notlevelend
	bne	lab10
	lda	#0
	sta	SOUNDFREQT2
	; Warte 2 Sekunden
	lda	#100
	jsr	waitawhile
	jmp	initnewlevel
lab10:

	; Demo-Modus?
	lda	demomode
	bne	lab4

	; User-Eingabe
	lda	KEYPRARR+11
	beq	lab1
	; User will nach links
	lda	#MV_LEFT
	sta	pacwanteddir
	jmp	lab4
lab1:
	lda	KEYPRARR+18
	beq	lab2
	; User will nach unten
	lda	#MV_DOWN
	sta	pacwanteddir
	jmp	lab4
lab2:
	lda	KEYPRARR+20
	beq	lab3
	; User will nach rechts
	lda	#MV_RIGHT
	sta	pacwanteddir
	jmp	lab4
lab3:
	lda	KEYPRARR+21
	beq	lab4
	; User will nach oben
	lda	#MV_UP
	sta	pacwanteddir
lab4:

	; Bestimmung des globalen Ghost-Target-Modus
	lda	targetmode
	cmp	#TMODE_FRIGHTEN
	bne	lab16
	ldy	#LDOFFGHOSTFRIGHTENDURATION
	lda	(actleveldefs),y
	cmp	pactimer2
	bne	lab7
	; Zeit im FRIGHTEN-Modus abgelaufen
	ldy	#LDOFFPACSPEED
	lda	(actleveldefs),y
	sta	pacspeedx
	sta	pacspeedy
	lda	oldtargetmode
	sta	targetmode
	lda	#1
	sta	changedtargetmode
	jsr	sirensound
	jmp	lab7
lab16:
	; Wechsel zwischen SCATTER- und CHASE-Modus?
	ldy	ghostmodeptr
	cpy	#7
	beq	lab7
	lda	(actleveldefs),y
	cmp	pactimer1
	bne	lab7
	inc	ghostmodeptr
	lda	targetmode
	cmp	#TMODE_SCATTER
	bne	lab8
	lda	#TMODE_CHASE
	jmp	lab9	
lab8:
	lda	#TMODE_SCATTER
lab9:
	sta	targetmode
	lda	#2
	sta	changedtargetmode
lab7:

	; Bonus-Symbol anzeigen?
	lda	pactimer3
	cmp	#TIME1SHOWBONUSSYMBOL
	bne	lab23
lab26:
	lda	bonusvisible
	bne	lab25
	; Zeige Bonus-Symbol
	ldy	#LDOFFBONUSSPRITE
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
	ldx	#<bonussprite
	ldy	#>bonussprite
	callatm	addmsprite6502
	lda	#BON
	sta	bonuspos1
	sta	bonuspos2
	lda	#1
	sta	bonusvisible
	jmp	lab25
lab23:
	cmp	#TIME1REMOVEBONUSSYMBOL
	bne	lab24
lab27:
	lda	bonusvisible
	beq	lab25
	jsr	clearbonussymbol
	jmp	lab25
lab24:
	cmp	#TIME2SHOWBONUSSYMBOL
	beq	lab26
	cmp	#TIME2REMOVEBONUSSYMBOL
	beq	lab27
lab25:

	; Bewege Pacman
	jsr	pacmove

	; Bewege Blinky
	jsr	blinkymove

	; Bewege Pinky
	jsr	pinkymove

	; Bewege Inky
	jsr	inkymove

	; Bewege Clyde
	jsr	clydemove

	; Diverse Variabeln zuruecksetzen, nachdem alle Ghosts bewegt wurden
	lda	#0
	sta	spilleaten
	sta	changedtargetmode

	; Pruefung auf Kollisionen
	lda	collision
	bne	lab5
lab6:

	; Blinken der Super-Pillen
	jsr	spillblink

	; Sirenen-Sound + Sound-Effekte
	lda	demomode
	bne	lab18
	jsr	soundplay
	lda	pillsoundeffect
	beq	lab15
	dec	pillsoundeffect
	lda	#SNDEFFECTFREQ
	sta	SOUNDFREQT2
lab15:
	ldy	bonussoundeffect
	beq	lab30
	dec	bonussoundeffect
	lda	(bonussoundptr),y
	sta	SOUNDFREQT2
lab30:
	ldy	extralifesoundeffect
	beq	lab18
	dec	extralifesoundeffect
	lda	(extralifesoundptr),y
	sta	SOUNDFREQT2

	; Anzeige Bonus-Punkte
lab18:
	lda	bonusshowpoints
	beq	lab32
	dec	bonusshowpoints
	cmp	#1
	bne	lab32
	ldx	#<bonussprite
	ldy	#>bonussprite
	callatm	delmsprite6502
lab32:

	; Debug-Information -> Performance-Messung
	;ldx	VSYNCROW
	;ldy	#0
	;callatm	itoa6502
	;ldx	#30
	;ldy	#0
	;callatm	setcursorpos6502
	;ldx	#<ITOASTRING
	;ldy	#>ITOASTRING
	;callatm	printstring6502

	jmp	mainloop

lab5:
	; Kollision erfolgt -> Pacman stirbt
	lda	demomode
	bne	lab12
	lda	cheat
	and	#2
	beq	lab12
	lda	#0
	sta	collision
	jmp	lab6
lab12:
	lda	#0
	sta	SOUNDFREQT2
	lda	#50
	jsr	waitawhile
	jsr	pacmandies
	lda	demomode
	beq	lab11
	jmp	intro
lab11:
	lda	cheat
	and	#4
	bne	lab17
	dec	lifesleft
	lda	lifesleft
	beq	lab28
lab17:
	jmp	initlevel
lab28:
	; Drucke GAME OVER
	ldx	#16
	ldy	#10
	lda	#<gameovertilestring1
	sta	tmpptr
	lda	#>gameovertilestring1
	sta	tmpptr+1
	jsr	gfxprintstring
	ldx	#16
	ldy	#14
	lda	#<gameovertilestring2
	sta	tmpptr
	lda	#>gameovertilestring2
	sta	tmpptr+1
	jsr	gfxprintstring
	lda	#100
	jsr	waitawhile
	lda	credits
	bne	lab33
	jmp	intro
lab33:
	jmp	showstartscreen


initpacman:
	; Grundlegende Initialisierungen

	; Grafik-Modus einschalten
	lda	#<MCOLORMAPDEFAULT+768
	sta	MCOLORMAPP768
	lda	#>MCOLORMAPDEFAULT+768
	sta	MCOLORMAPP768+1
	lda	#2
	sta	VIDEOMODE
	lda	#16
	sta	MODE2STARTLINE
	lda	#200
	sta	MODE2ENDLINE
	lda	#0
	sta	CURONOFF

	; Tiles-Definitionen setzen
	lda	#<tilesdef+768
	sta	GFXTILEDEFSP768
	lda	#>tilesdef+768
	sta	GFXTILEDEFSP768+1

	; Farbe der Text-Map auf den Standardbereich legen
	lda	#<COLORMAPTXTDEFAULT+768
	sta	COLORMAPTXTP768
	lda	#>COLORMAPTXTDEFAULT+768
	sta	COLORMAPTXTP768+1

	; Text-Map auf einen anderen Speicherbereich umbiegen
	lda	#<TEXTMAPPTR+768
	sta	TEXTMAPP768
	lda	#>TEXTMAPPTR+768
	sta	TEXTMAPP768+1
	ldx	#0
	ldy	#0
	callatm	setcursorpos6502

	; VSYNC-Routine
	lda	#<vsyncint
	sta	$FFFC
	lda	#>vsyncint
	sta	$FFFD

	; VSYNC-Interrupt einschalten
	lda	#16
	sta	INTMASK6502
	cli

	; Text-Screen loeschen
	ldx	#<memfillstructtext
	ldy	#>memfillstructtext
	callatm	memfill6502

	; High-Score + Credits auf 0 setzen
	lda	#0
	sta	highscore
	sta	highscore+1
	sta	credits
	sta	creditsound

	; Score + High-Score anzeigen
	ldx	#7
	ldy	#0
	callatm setcursorpos6502
	ldx	#<text1uphiscore
	ldy	#>text1uphiscore
	callatm	printstring6502
	lda	#'0'
	sta	TEXTMAPPTR+49
	sta	TEXTMAPPTR+63
	lda	#0
	sta	score
	sta	score+1
	jsr	updatescore_lab0

	; Erzeuge "Grafik-Text-Charakter"
	jsr	getgfxchars

	; Initialisierung Bonus-Sound
	lda	#<sndbonus
	sta	bonussoundptr
	lda	#>sndbonus
	sta	bonussoundptr+1

	; Initialisierung Extra-Life-Sound
	lda	#<sndextralife
	sta	extralifesoundptr
	lda	#>sndextralife
	sta	extralifesoundptr+1
	rts


initnewgame:
	; Initialisierungen fuer ein neues Spiel

	; Diverses
	lda	#1
	sta	flagplaystartmelody
	lda	#2
	sta	VIDEOMODE
	lda	#36
	sta	bonusiconpos
	jsr	clearlastline
	lda	#0
	sta	gotbonuslife
	sta	extralifesoundeffect

	; Aktueller Level setzen
	lda	#0
	sta	actlevel
	lda	#<INITLEVELDEFS
	sta	actleveldefs
	lda	#>INITLEVELDEFS
	sta	actleveldefs+1

	; Score auf 0 setzen
	lda	#0
	sta	score
	sta	score+1
	jsr	updatescore

	; Anzahl Leben setzen
	lda	#3
	sta	lifesleft


initnewlevel:
	; Initialisierungen fuer einen neuen Level

	; Bildschirm loeschen
	callatm	initlistmsprites6502
	ldx	#<memfillstructgfx2
	ldy	#>memfillstructgfx2
	callatm	memfill6502

	; Diverses
	lda	#SPILLBLINKITER
	sta	spillblinkcnt
	lda	#0
	sta	numofpillsleft

	; Initialisierung Timer 3
	sta	tmptimer3
	sta	pactimer3

	; Aktuelle Level-Definitionen setzen
	lda	actlevel
	cmp	#NUMOFLEVELS
	bne	initnewlevel_lab33
	jmp	endofgame
initnewlevel_lab33:
	inc	actlevel
	lda	actleveldefs
	clc
	adc	#SIZEOFLEVELDEFS
	sta	actleveldefs
	bcc	initnewlevel_lab31
	inc	actleveldefs+1
initnewlevel_lab31:
	; Super-Pillen im Labyrinth setzen
	lda	#SPI
	sta	spill1pos
	sta	spill2pos
	sta	spill3pos
	sta	spill4pos

	; Pillen im Labyrinth setzen
	ldx	#4
	lda	#<level1
	sta	tmptileposptr
	lda	#>level1
	sta	tmptileposptr+1
	ldy	#0
initnewlevel_lab12:
	lda	(tmptileposptr),y
	cmp	#EPI
	bne	initnewlevel_lab3
	lda	#PIL
	sta	(tmptileposptr),y
initnewlevel_lab3:
	dey
	bne	initnewlevel_lab12
initnewlevel_lab2:
	inc	tmptileposptr+1
	dex
	cpx	#1
	beq	initnewlevel_lab1
	cpx	#0
	beq	initnewlevel_lab10
	jmp	initnewlevel_lab12
initnewlevel_lab1:
	ldy	#232
	jmp	initnewlevel_lab12
initnewlevel_lab10:

	; Grafik-Screen zeichnen
	lda	#<level1+768
	sta	TILEMAPP768
	lda	#>level1+768
	sta	TILEMAPP768+1
	lda	#40
	sta	TILEMAPWIDTH
	sta	TILEMCOLMAPW
	lda	#24
	sta	TILEMCOLMAPH
	lda	#0
	sta	TILEMCOLMAPX
	sta	TILEMCOLMAPY
	sta	TILEMAPSTARTX
	sta	TILEMAPSTARTY
	sta	TILEMAPSTARTY+1
initnewlevel_lab4:
	callatm	gfxcopytilerow6502
	inc	TILEMAPSTARTY
	inc	TILEMCOLMAPY
	lda	TILEMCOLMAPY
	cmp	#24
	bne	initnewlevel_lab4

	; Bonus-Icon
	ldy	#LDOFFBONUSICON+1
	lda	(actleveldefs),y
	ldy	#24
	ldx	bonusiconpos
	callatm	gfxcopytile6502
	ldy	#LDOFFBONUSICON
	lda	(actleveldefs),y
	ldy	#24
	dex
	callatm	gfxcopytile6502
	dex
	stx	bonusiconpos


initlevel:
	; Initialisierungen fuer den aktuellen Level (auch nach einem Tod von Pacman)

	; Diverses
	lda	#3
	sta	rand
	sta	notlevelend
	lda	#0
	sta	delpill
	sta	collision
	sta	collfright
	sta	spilleaten
	sta	bonusvisible
	sta	changedtargetmode
	sta	pillsoundeffect
	sta	bonussoundeffect

	; Initialisierung Timer1+2
	sta	tmptimer1
	sta	tmptimer2
	sta	pactimer1
	sta	pactimer2

	; Initialisierung globaler Target-Modus
	sta	ghostmodeptr
	lda	#TMODE_SCATTER
	sta	targetmode

	; Sprites
	jsr	pacinit
	jsr	blinkyinit
	jsr	pinkyinit
	jsr	inkyinit
	jsr	clydeinit
	callatm	initlistmsprites6502
	ldx	#<pacmansprite
	ldy	#>pacmansprite
	callatm	addmsprite6502
	ldx	#<blinkysprite
	ldy	#>blinkysprite
	callatm	addmsprite6502
	ldx	#<pinkysprite
	ldy	#>pinkysprite
	callatm	addmsprite6502
	ldx	#<inkysprite
	ldy	#>inkysprite
	callatm	addmsprite6502
	ldx	#<clydesprite
	ldy	#>clydesprite
	callatm	addmsprite6502

	; Sprites ab ID 1 anzeigen
	lda	#1
	sta	MINSPRITEIDTODRAW

	; Pacman-Icons
	jsr	displaypacicons

	; Demo-Modus?
	lda	demomode
	beq	initlevel_lab1
	; Drucke GAME OVER im Demo-Modus
	ldx	#16
	ldy	#10
	lda	#<gameovertilestring1
	sta	tmpptr
	lda	#>gameovertilestring1
	sta	tmpptr+1
	jsr	gfxprintstring
	ldx	#16
	ldy	#14
	lda	#<gameovertilestring2
	sta	tmpptr
	lda	#>gameovertilestring2
	sta	tmpptr+1
	jsr	gfxprintstring
	jmp	initlevel_lab2
initlevel_lab1:

	; Anzeige READY
	ldx	#14
	ldy	#14
	lda	#<readytilestring
	sta	tmpptr
	lda	#>readytilestring
	sta	tmpptr+1
	jsr	gfxprintstring
	; Spiele Start-Melodie (beim Spiel-Start)
	lda	flagplaystartmelody
	beq	initlevel_lab29
	lda	#0
	sta	flagplaystartmelody
	lda	#64
	sta	SNDTCCR1A
	; N = 8
	lda	#10
	sta	SNDTCCR1B
	; N = 256
	lda	#30
	sta	SNDTCCR2
	lda	#<pacman_start_melody_t1
	sta	melodyptr1
	lda	#>pacman_start_melody_t1
	sta	melodyptr1+1
	lda	#<pacman_start_melody_t2
	sta	melodyptr2
	lda	#>pacman_start_melody_t2
	sta	melodyptr2+1
	jsr	playmelody
	lda	#0
	sta	SNDTCCR1A
	sta	SNDTCCR1B
	lda	#SOUNDONOFFCONST
	sta	SNDTCCR2
	jmp	initlevel_lab34
initlevel_lab29:
	; oder warte 2 Sekunden
	lda	#0
	sta	SOUNDFREQT2
	lda	#100
	jsr	waitawhile
initlevel_lab34:
	; Anzeige READY wieder entfernen
	ldx	#14
	ldy	#14
	lda	#<cleartilestring
	sta	tmpptr
	lda	#>cleartilestring
	sta	tmpptr+1
	jsr	gfxprintstring

	; Sirenen-Sound
	jsr	sirensound

initlevel_lab2:
	jmp	mainloop


endofgame:
	lda	#0
	sta	SNDTCCR2

	; Warte 1 Sekunde
	lda	#50
	jsr	waitawhile

	; Bildschirm loeschen
	callatm	initlistmsprites6502
	ldx	#<memfillstructgfx
	ldy	#>memfillstructgfx
	callatm	memfill6502

	; Drucke CONGRATULATIONS!
	ldx	#3
	ldy	#8
	lda	#<endofgametilestring1
	sta	tmpptr
	lda	#>endofgametilestring1
	sta	tmpptr+1
	jsr	gfxprintstring

	; Drucke YOU FINISHED
	ldx	#5
	ldy	#15
	lda	#<endofgametilestring2
	sta	tmpptr
	lda	#>endofgametilestring2
	sta	tmpptr+1
	jsr	gfxprintstring

	; Drucke THE LAST LEVEL!
	ldx	#3
	ldy	#17
	lda	#<endofgametilestring3
	sta	tmpptr
	lda	#>endofgametilestring3
	sta	tmpptr+1
	jsr	gfxprintstring

	; Warte 10 Sekunden
	lda	#250
	jsr	waitawhile
	lda	#250
	jsr	waitawhile


intro:
	; Sound aus + Bildschirm loeschen
	lda	#0
	sta	SNDTCCR2
	ldx	#<memfillstructgfx
	ldy	#>memfillstructgfx
	callatm	memfill6502

	; Sprites ab ID 1 anzeigen
	lda	#1
	sta	MINSPRITEIDTODRAW

	; Demo-Modus
	lda	#1
	sta	demomode
	lda	#0
	sta	demomovepos
	lda	#<demomovetab
	sta	demomoveptr
	lda	#>demomovetab
	sta	demomoveptr+1

	; Warte 1 Sekunde
	lda	#50
	jsr	waitawhile
	; Drucke CHARACTER / NICKNAME
	ldx	#0
	ldy	#4
	lda	#<introtilestring1
	sta	tmpptr
	lda	#>introtilestring1
	sta	tmpptr+1
	jsr	gfxprintstring

	; Warte 1 Sekunde
	lda	#50
	jsr	waitawhile
	; Blinky anzeigen
	lda	#0
	sta	blinkysprite+MSPRITEX
	lda	#6*8
	sta	blinkysprite+MSPRITEY
	lda	#<blinkydataright1
	sta	blinkysprite+MSPRITEDATA
	lda	#>blinkydataright1
	sta	blinkysprite+MSPRITEDATA+1
	ldx	#<blinkysprite
	ldy	#>blinkysprite
	callatm	addmsprite6502
	; Warte 0.5 Sekunden
	lda	#25
	jsr	waitawhile
	; Drucke SHADOW
	ldx	#3
	ldy	#6
	lda	#<introtilestring2
	sta	tmpptr
	lda	#>introtilestring2
	sta	tmpptr+1
	jsr	gfxprintstring
	; Warte 0.5 Sekunden
	lda	#25
	jsr	waitawhile
	; Drucke "BLINKY"
	ldx	#22
	ldy	#6
	lda	#<introtilestring3
	sta	tmpptr
	lda	#>introtilestring3
	sta	tmpptr+1
	jsr	gfxprintstring

	; Warte 1 Sekunde
	lda	#50
	jsr	waitawhile
	; Pinky anzeigen
	lda	#0
	sta	pinkysprite+MSPRITEX
	lda	#8*8
	sta	pinkysprite+MSPRITEY
	lda	#<pinkydataright1
	sta	pinkysprite+MSPRITEDATA
	lda	#>pinkydataright1
	sta	pinkysprite+MSPRITEDATA+1
	ldx	#<pinkysprite
	ldy	#>pinkysprite
	callatm	addmsprite6502
	; Warte 0.5 Sekunden
	lda	#25
	jsr	waitawhile
	; Drucke SPEEDY
	ldx	#3
	ldy	#8
	lda	#<introtilestring4
	sta	tmpptr
	lda	#>introtilestring4
	sta	tmpptr+1
	jsr	gfxprintstring
	; Warte 0.5 Sekunden
	lda	#25
	jsr	waitawhile
	; Drucke "PINKY"
	ldx	#22
	ldy	#8
	lda	#<introtilestring5
	sta	tmpptr
	lda	#>introtilestring5
	sta	tmpptr+1
	jsr	gfxprintstring

	; Warte 1 Sekunde
	lda	#50
	jsr	waitawhile
	; Inky anzeigen
	lda	#0
	sta	inkysprite+MSPRITEX
	lda	#10*8
	sta	inkysprite+MSPRITEY
	lda	#<inkydataright1
	sta	inkysprite+MSPRITEDATA
	lda	#>inkydataright1
	sta	inkysprite+MSPRITEDATA+1
	ldx	#<inkysprite
	ldy	#>inkysprite
	callatm	addmsprite6502
	; Warte 0.5 Sekunden
	lda	#25
	jsr	waitawhile
	; Drucke BASHFUL
	ldx	#3
	ldy	#10
	lda	#<introtilestring6
	sta	tmpptr
	lda	#>introtilestring6
	sta	tmpptr+1
	jsr	gfxprintstring
	; Warte 0.5 Sekunden
	lda	#25
	jsr	waitawhile
	; Drucke "INKY"
	ldx	#22
	ldy	#10
	lda	#<introtilestring7
	sta	tmpptr
	lda	#>introtilestring7
	sta	tmpptr+1
	jsr	gfxprintstring

	; Warte 1 Sekunde
	lda	#50
	jsr	waitawhile
	; Clyde anzeigen
	lda	#0
	sta	clydesprite+MSPRITEX
	lda	#12*8
	sta	clydesprite+MSPRITEY
	lda	#<clydedataright1
	sta	clydesprite+MSPRITEDATA
	lda	#>clydedataright1
	sta	clydesprite+MSPRITEDATA+1
	ldx	#<clydesprite
	ldy	#>clydesprite
	callatm	addmsprite6502
	; Warte 0.5 Sekunden
	lda	#25
	jsr	waitawhile
	; Drucke POKEY
	ldx	#3
	ldy	#12
	lda	#<introtilestring8
	sta	tmpptr
	lda	#>introtilestring8
	sta	tmpptr+1
	jsr	gfxprintstring
	; Warte 0.5 Sekunden
	lda	#25
	jsr	waitawhile
	; Drucke "CLYDE"
	ldx	#22
	ldy	#12
	lda	#<introtilestring9
	sta	tmpptr
	lda	#>introtilestring9
	sta	tmpptr+1
	jsr	gfxprintstring

	; Warte 0.5 Sekunden
	lda	#25
	jsr	waitawhile
	; Drucke Copyright-Vermerk
	ldx	#8
	ldy	#20
	lda	#<introtilestring10
	sta	tmpptr
	lda	#>introtilestring10
	sta	tmpptr+1
	jsr	gfxprintstring
	ldx	#11
	ldy	#22
	lda	#<introtilestring11
	sta	tmpptr
	lda	#>introtilestring11
	sta	tmpptr+1
	jsr	gfxprintstring

	; Warte 2 Sekunden
	lda	#100
	jsr	waitawhile
	; Starte Demo
	jmp	initnewgame


color1textline:
	; Eingabe -> y = Zeile die eingefaerbt werden soll
	; Eingabe -> a = Farbcode
	sta	tmp1
	lda	#<COLORMAPTXTDEFAULT
	sta	tmptileposptr
	lda	#>COLORMAPTXTDEFAULT
	sta	tmptileposptr+1
	ldx	#40
	callatm	mul8x86502
	clc
	lda	RMUL6502
	adc	tmptileposptr
	sta	tmptileposptr
	lda	RMUL6502+1
	adc	tmptileposptr+1
	sta	tmptileposptr+1
	lda	tmp1
	ldy	#40
color1textline_lab1:
	sta	(tmptileposptr),y
	dey
	bne	color1textline_lab1
	rts


showstartscreen:
	lda	#1
	sta	demomode
	lda	#0
	sta	VIDEOMODE
	ldx	#10
	ldy	#8
	callatm setcursorpos6502
	ldx	#<startscreentext1
	ldy	#>startscreentext1
	callatm	printstring6502
	ldy	#8
	lda	#144
	jsr	color1textline
	ldx	#12
	ldy	#11
	callatm setcursorpos6502
	ldx	#<startscreentext2
	ldy	#>startscreentext2
	callatm	printstring6502
	ldy	#11
	lda	#224
	jsr	color1textline
	ldx	#6
	ldy	#14
	callatm setcursorpos6502
	ldx	#<startscreentext3
	ldy	#>startscreentext3
	callatm	printstring6502
	ldy	#14
	lda	#80
	jsr	color1textline
	ldx	#8
	ldy	#17
	callatm setcursorpos6502
	ldx	#<startscreentext4
	ldy	#>startscreentext4
	callatm	printstring6502
	ldy	#17
	lda	#176
	jsr	color1textline
	ldx	#7
	ldy	#24
	callatm setcursorpos6502
	ldx	#<startscreentext5
	ldy	#>startscreentext5
	callatm	printstring6502
	ldx	credits
	ldy	#0
	callatm	itoa6502
	ldx	#15
	ldy	#24
	callatm setcursorpos6502
	ldx	#<ITOASTRING
	ldy	#>ITOASTRING
	callatm	printstring6502
	; Initialisierung Sound
	lda	#SOUNDONOFFCONST
	sta	SNDTCCR2
showstartscreen_lab1:
	lda	#1
	jsr	waitawhile
	jmp	showstartscreen_lab1


waitawhile:
	sta	tmpwaitawhile
waitawhile_lab1:
	lda	TIMER
waitawhile_lab2:
	cmp	TIMER
	beq	waitawhile_lab2
	jsr	checkkeys
	dec	tmpwaitawhile
	bne	waitawhile_lab1
	rts


quitgame:
	; Standard Text-Map
	lda	#<TEXTMAPDEFAULT+768
	sta	TEXTMAPP768
	lda	#>TEXTMAPDEFAULT+768
	sta	TEXTMAPP768+1
	; Farben der Text-Map auf weiss
	ldy	#8
	lda	#240
	jsr	color1textline
	ldy	#11
	lda	#240
	jsr	color1textline
	ldy	#14
	lda	#240
	jsr	color1textline
	ldy	#17
	lda	#240
	jsr	color1textline
	; Diverses
	ldx	#0
	ldy	#20
	callatm	setcursorpos6502
	lda	#0
	sta	VIDEOMODE
	sta	SNDTCCR2
	sta	MODE2STARTLINE
	sta	MODE2ENDLINE
	lda	#1
	sta	CURONOFF
	jmpsh


pausegame:
	lda	#0
	sta	SOUNDFREQT2
pausegame_lab1:
	lda	KEYPRESSED
	; Spiel beenden?
	cmp	#127
	bne	pausegame_lab2
	; Spiel beenden
	ldx	stack
	txs
	jmp	quitgame
pausegame_lab2:
	; Spiel wieder aufnehmen?
	cmp	#'c'
	bne	pausegame_lab1
	rts


checkkeys:
	lda	KEYPRESSED
	; Spiel beenden?
	cmp	#127
	bne	checkkeys_lab1
	; Spiel beenden
	ldx	stack
	txs
	jmp	quitgame
checkkeys_lab1:
	; Spiel pausieren?
	cmp	#'p'
	bne	checkkeys_lab3
	; Spiel pausieren
	jmp	pausegame
checkkeys_lab3:
	lda	creditsound
	beq	checkkeys_lab2
	dec	creditsound
	and	#254
	sta	SOUNDFREQT2
	jmp	checkkeys_lab4
checkkeys_lab2:
	; Credits erhoehen?
	lda	KEYPRESSED
	cmp	#'5'
	bne	checkkeys_lab4
	inc	credits
	lda	#50
	sta	creditsound
	; Demo-Modus?
	lda	demomode
	beq	checkkeys_lab4
	; Ja -> Warte auf Start
	ldx	stack
	txs
	jmp	showstartscreen
checkkeys_lab4:
	; Spiel starten?
	lda	KEYPRESSED
	cmp	#'1'
	bne	checkkeys_lab5
	; Demo-Modus?
	lda	demomode
	beq	checkkeys_lab5
	lda	credits
	beq	checkkeys_lab5
	dec	credits
	ldx	stack
	txs
	lda	#0
	sta	demomode
	jmp	initnewgame
checkkeys_lab5:
	; Cheat "Naechster Level"
	lda	demomode
	bne	checkkeys_lab6
	lda	cheat
	and	#1
	beq	checkkeys_lab6
	lda	KEYPRESSED
	cmp	#'n'
	bne	checkkeys_lab6
	lda	#0
	sta	notlevelend
checkkeys_lab6:
	rts


clearlastline:
	ldx	#39
	ldy	#24
	lda	#EMP
clearlastline_lab1:
	callatm	gfxcopytile6502
	dex
	bne	clearlastline_lab1
	rts


displaypacicons:
	; Pacman-Icons loeschen
	lda	#4
	sta	tmp1
	ldx	#3
	ldy	#24
	lda	#EMP
displaypacicons_lab3:
	dec	tmp1
	beq	displaypacicons_lab4
	callatm	gfxcopytile6502
	inx
	inx
	jmp	displaypacicons_lab3
displaypacicons_lab4:
	; Pacman-Icons neu zeichnen
	lda	lifesleft
	sta	tmp1
	ldx	#3
	ldy	#24
	lda	#PACICON
displaypacicons_lab1:
	dec	tmp1
	beq	displaypacicons_lab2
	callatm	gfxcopytile6502
	inx
	inx
	jmp	displaypacicons_lab1
displaypacicons_lab2:
	rts


clearbonussymbol:
	; Loesche Bonus-Symbol

	ldx	#<bonussprite
	ldy	#>bonussprite
	callatm	delmsprite6502
clearbonussymbol1:
	lda	#EMP
	sta	bonuspos1
	sta	bonuspos2
	lda	#0
	sta	bonusvisible
	rts


gettileposofsprite:
	; Bestimmung der Tile-Position des aktuellen Sprites
	; Eingabe -> x = Sprite-x-Position, y = Sprite-y-Position
	; Ausgabe -> tmptilexpos, tmptileypos, tmptileposptr

	; level1
	lda	#<level1
	sta	tmptileposptr
	lda	#>level1
	sta	tmptileposptr+1
	; level1 + (y/8-1)*40
	tya
	lsr
	lsr
	lsr
	tay
	sty	tmptileypos
	dey
	stx	tmp1
	ldx	#40
	callatm	mul8x86502
	ldx	tmp1
	clc
	lda	RMUL6502
	adc	tmptileposptr
	sta	tmptileposptr
	lda	RMUL6502+1
	adc	tmptileposptr+1
	sta	tmptileposptr+1
	; level1 + (y/8-1)*40 + x/4
	txa
	lsr
	lsr
	sta	tmptilexpos
	clc
	adc	tmptileposptr
	sta	tmptileposptr
	bcc	gettileposofsprite_lab1
	inc	tmptileposptr+1
gettileposofsprite_lab1:
	rts


vsyncint:
	pha
	lda	delpill
	bne	vsyncint_lab2
vsyncint_lab1:
	pla
	rti
vsyncint_lab2:
	txa
	pha
	tya
	pha
	lda	#0
	sta	delpill
	; Tiledaten loeschen
	ldx	deltilexpos
	ldy	deltileypos
	lda	#EPI
	callatm	gfxcopytile6502
	pla
	tay
	pla
	tax
	jmp	vsyncint_lab1


spillblink:
	dec	spillblinkcnt
	lda	spillblinkcnt
	bne	spillblink_lab1
	lda	#SPILLBLINKITER
	sta	spillblinkcnt
	lda	spillblinktile
	cmp	#EPI
	beq	spillblink_lab2
	lda	#EPI
	jmp	spillblink_lab3
spillblink_lab1:
	rts
spillblink_lab2:
	lda	#SPI
spillblink_lab3:
	sta	spillblinktile
	lda	spill1pos
	cmp	#SPI
	bne	spillblink_lab4
	ldx	#SPILL1TILEXPOS
	ldy	#SPILL1TILEYPOS
	lda	spillblinktile
	callatm	gfxcopytile6502
spillblink_lab4:
	lda	spill2pos
	cmp	#SPI
	bne	spillblink_lab5
	ldx	#SPILL2TILEXPOS
	ldy	#SPILL2TILEYPOS
	lda	spillblinktile
	callatm	gfxcopytile6502
spillblink_lab5:
	lda	spill3pos
	cmp	#SPI
	bne	spillblink_lab6
	ldx	#SPILL3TILEXPOS
	ldy	#SPILL3TILEYPOS
	lda	spillblinktile
	callatm	gfxcopytile6502
spillblink_lab6:
	lda	spill4pos
	cmp	#SPI
	bne	spillblink_lab7
	ldx	#SPILL4TILEXPOS
	ldy	#SPILL4TILEYPOS
	lda	spillblinktile
	callatm	gfxcopytile6502
spillblink_lab7:
	rts


updatescore:
	lda	demomode
	bne	updatescore_lab1
updatescore_lab0:
	ldx	score
	ldy	score+1
	callatm	itoaformat6502
	; Bonus-Leben schon erhalten?
	lda	gotbonuslife
	bne	updatescore_lab3
	; Score >= 10000?
	cpy	#3
	bcc	updatescore_lab3
	cpx	#232
	bcc	updatescore_lab3
	inc	lifesleft
	lda	#SNDEFFECTEXTRALIFECNT
	sta	extralifesoundeffect
	lda	#1
	sta	gotbonuslife
	jsr	displaypacicons
updatescore_lab3:
	ldx	#4
	ldy	#1
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
	ldy	#1
	callatm setcursorpos6502
	ldx	#<ITOASTRING
	ldy	#>ITOASTRING
	callatm	printstring6502
updatescore_lab1:
	rts


gfxprintstring:
	; Drucke einen Tile-String im Multi-Color-Modus (auf einer Zeile)
	; Eingabe -> x = Start-x-Position, y = Start-y-Position
	; Eingabe -> tmpptr = Pointer auf den Tile-String (mit 0 beendet)

	sty	tmp1
	ldy	#0
gfxprintstring_lab1:
	sty	tmp2
	lda	(tmpptr),y
	beq	gfxprintstring_lab2
	ldy	tmp1
	callatm	gfxcopytile6502
	inx
	clc
	adc	#1
	callatm	gfxcopytile6502
	inx
	ldy	tmp2
	iny
	jmp	gfxprintstring_lab1
gfxprintstring_lab2:
	rts


char2tile:
	; copy the definition of a character to 2 tiles
	; in reg A -> ascii code to convert
	; in c2ttiledata -> pointer to tile definitions (to be filled)
	; in c2tcoldata -> color of tiles
	sta	c2tchardefs
	lda	#>CHARDEFSDEFAULT
	sta	c2tchardefs+1
	lda	#8
	sta	c2tcnt
	ldx	#0
	ldy	#0
char2tile_lab6:
	lda	(c2tchardefs,x)
	sta	c2tchardata
	jsr	char2tile_lab5
	lda	c2ttmpdata
	sta	(c2ttiledata),y
	iny
	jsr	char2tile_lab5
	lda	c2ttmpdata
	sta	(c2ttiledata),y
	tya
	clc
	adc	#15
	tay
	jsr	char2tile_lab5
	lda	c2ttmpdata
	sta	(c2ttiledata),y
	iny
	jsr	char2tile_lab5
	lda	c2ttmpdata
	sta	(c2ttiledata),y
	tya
	sec
	sbc	#15
	tay
	inc	c2tchardefs+1
	dec	c2tcnt
	bne	char2tile_lab6
	rts
char2tile_lab5:
	lda	c2tchardata
	rol
	sta	c2tchardata
	bcc	char2tile_lab1
	lda	c2tcoldata
	and	#240
	sta	c2ttmpdata
	jmp	char2tile_lab2
char2tile_lab1:
	lda	c2tcoldata
	asl
	asl
	asl
	asl
	sta	c2ttmpdata
char2tile_lab2:
	lda	c2tchardata
	rol
	sta	c2tchardata
	bcc	char2tile_lab3
	lda	c2tcoldata
	lsr
	lsr
	lsr
	lsr
	ora	c2ttmpdata
	sta	c2ttmpdata
	rts
char2tile_lab3:
	lda	c2tcoldata
	and	#15
	ora	c2ttmpdata
	sta	c2ttmpdata
	rts


getgfxchars:
	; Transformiere ausgewaehlte Text-Modus-Charakter in Grafik-Charakter

	lda	#TILECHARSCOLOR
	sta	c2tcoldata
	lda	#<tilesdef+TILECHARSTARTNR*16
	sta	c2ttiledata
	lda	#>tilesdef+TILECHARSTARTNR*16
	sta	c2ttiledata+1
	; Transformiere SPC (32), ! (33) und " (34)
	lda	#3
	sta	tmp1
	lda	#32
	sta	tmp2
	jsr	getgfxchars_lab1
	; Transformiere / (47) bis 9 (57)
	lda	#11
	sta	tmp1
	lda	#47
	sta	tmp2
	jsr	getgfxchars_lab1
	; Transformiere A (65) bis Z (90)
	lda	#26
	sta	tmp1
	lda	#65
	sta	tmp2
getgfxchars_lab1:
	jsr	char2tile
	clc
	lda	c2ttiledata
	adc	#32
	sta	c2ttiledata
	lda	c2ttiledata+1
	adc	#0
	sta	c2ttiledata+1
	inc	tmp2
	lda	tmp2
	dec	tmp1
	bne	getgfxchars_lab1
	rts


BONUSTILEX = 19
BONUSTILEY = 14
BONUSPOSX = BONUSTILEX*TILEWIDTH
BONUSPOSY = BONUSTILEY*TILEHEIGHT-1

bonussprite:
	.word	0,0 ; next,prev
	.byt	1,BONUSPOSX,BONUSPOSY,8,11 ; id,x,y,w,h
	.word	cherrydata,bonusdatabg ; data,bg
	.dsb	4,0 ; *old
	.byte	1 ; status
	.byte	0 ; schwarz ist "transparent"
	; no coinc-detection

pts200sprite:
	.word	0,0 ; next,prev
	.byt	20,0,0,11,8 ; id,x,y,w,h
	.word	pts200data,ptsdatabg ; data,bg
	.dsb	4,0 ; *old
	.byte	1 ; status
	.byte	0 ; schwarz ist "transparent"
	; no coinc-detection

pts400sprite:
	.word	0,0 ; next,prev
	.byt	21,0,0,11,8 ; id,x,y,w,h
	.word	pts400data,ptsdatabg ; data,bg
	.dsb	4,0 ; *old
	.byte	1 ; status
	.byte	0 ; schwarz ist "transparent"
	; no coinc-detection

pts800sprite:
	.word	0,0 ; next,prev
	.byt	22,0,0,11,8 ; id,x,y,w,h
	.word	pts800data,ptsdatabg ; data,bg
	.dsb	4,0 ; *old
	.byte	1 ; status
	.byte	0 ; schwarz ist "transparent"
	; no coinc-detection

pts1600sprite:
	.word	0,0 ; next,prev
	.byt	23,0,0,13,8 ; id,x,y,w,h
	.word	pts1600data,ptsdatabg ; data,bg
	.dsb	4,0 ; *old
	.byte	1 ; status
	.byte	0 ; schwarz ist "transparent"
	; no coinc-detection


text1uphiscore:
.asc	"1UP    HIGH SCORE",0
startscreentext1:
.asc	"PUSH START BUTTON",0
startscreentext2:
.asc	"1 PLAYER ONLY",0
startscreentext3:
.asc	"BONUS PAC-MAN FOR 10000 PTS",0
startscreentext4:
.asc	"Copyright by RETROELEC",0
startscreentext5:
.asc	"CREDIT",0


cleartilestring:
.byt	CSP,CSP,CSP,CSP,CSP,CSP,0
readytilestring:
.byt	CHR,CHE,CHA,CHD,CHY,CEX,0
gameovertilestring1:
.byt	CHG,CHA,CHM,CHE,0
gameovertilestring2:
.byt	CHO,CHV,CHE,CHR,0
endofgametilestring1:
.byt	CHC,CHO,CHN,CHG,CHR,CHA,CHT,CHU,CHL,CHA,CHT,CHI,CHO,CHN,CHS,CEX,0
endofgametilestring2:
.byt	CHY,CHO,CHU,CSP,CHF,CHI,CHN,CHI,CHS,CHH,CHE,CHD,0
endofgametilestring3:
.byt	CHT,CHH,CHE,CSP,CHL,CHA,CHS,CHT,CSP,CHL,CHE,CHV,CHE,CHL,CEX,0
introtilestring1:
.byt	CHC,CHH,CHA,CHR,CHA,CHC,CHT,CHE,CHR,CSP,CSL,CSP,CHN,CHI,CHC,CHK,CHN,CHA,CHM,CHE,0
introtilestring2:
.byt	CHS,CHH,CHA,CHD,CHO,CHW,0
introtilestring3:
.byt	CQU,CHB,CHL,CHI,CHN,CHK,CHY,CQU,0
introtilestring4:
.byt	CHS,CHP,CHE,CHE,CHD,CHY,0
introtilestring5:
.byt	CQU,CHP,CHI,CHN,CHK,CHY,CQU,0
introtilestring6:
.byt	CHB,CHA,CHS,CHH,CHF,CHU,CHL,0
introtilestring7:
.byt	CQU,CHI,CHN,CHK,CHY,CQU,0
introtilestring8:
.byt	CHP,CHO,CHK,CHE,CHY,0
introtilestring9:
.byt	CQU,CHC,CHL,CHY,CHD,CHE,CQU,0
introtilestring10:
.byt	CHC,CHO,CHP,CHY,CHR,CHI,CHG,CHH,CHT,CSP,CHB,CHY,0
introtilestring11:
.byt	CHR,CHE,CHT,CHR,CHO,CHE,CHL,CHE,CHC,0


memfillstructgfx:
.word	MCOLORMAPDEFAULT
.byt	80,200,0

memfillstructgfx2:
.word	MCOLORMAPDEFAULT
.byt	80,192,0

memfillstructtext:
.word	TEXTMAPPTR
.byt	40,25,32


demomovetab:
.byt	MV_LEFT,MV_DOWN,MV_RIGHT,MV_DOWN,MV_RIGHT,MV_RIGHT,MV_UP,MV_LEFT,MV_UP,MV_RIGHT
.byt	MV_UP,MV_LEFT,MV_UP,MV_UP,MV_UP,MV_LEFT,MV_LEFT,MV_LEFT,MV_LEFT,MV_LEFT
.byt	MV_LEFT,MV_UP,MV_RIGHT,MV_DOWN,MV_RIGHT,MV_DOWN,MV_RIGHT,MV_DOWN,MV_RIGHT,MV_UP
.byt	MV_RIGHT,MV_UP,MV_RIGHT,MV_RIGHT,MV_UP,MV_LEFT,MV_LEFT,MV_DOWN,MV_LEFT,MV_UP
.byt	MV_LEFT,MV_DOWN,MV_DOWN,MV_DOWN,MV_DOWN,MV_LEFT,MV_DOWN,MV_RIGHT,MV_DOWN,MV_RIGHT
.byt	MV_UP,MV_UP,MV_RIGHT,MV_RIGHT,MV_DOWN,MV_RIGHT,MV_RIGHT,MV_DOWN,MV_LEFT,MV_DOWN
.byt	MV_LEFT,MV_LEFT,MV_UP,MV_RIGHT,MV_RIGHT,MV_UP


; Definitionen Level 1
level1defs:
; Ghost-Scatter-Chase-Tabelle
; Anzahl Sekunden bis zum naechsten Modus-Wechsel (Scatter - Chase - Scatter - ...)
.byt	7,27,34,54,59,79,84,255
level1defsghostfrightenduration:
; Dauer des Frighten-Modus (Anzahl Fuenftel-Sekunden)
.byt	6*5
level1defsghostfrightenblink:
; Zeitpunkt im Frighten-Modus, ab dem der Ghost anfaengt zu blinken
.byt	4*5
level1defsghostspeedfrighten:
; Geschwindigkeit des Ghosts im FRIGHTEN-Modus
.byt	31
level1defsghostspeednormal:
; Geschwindigkeit des Ghosts im SCATTER oder CHASE-Modus
.byt	47
level1defsghostspeedtunnel:
; Geschwindigkeit des Ghosts im Tunnel
.byt	25
level1defspacspeed:
; Geschwindigkeit von Pacman
.byt	50
level1defspacfrightenspeed:
; Geschwindigkeit von Pacman im Frighten-Modus
.byt	56
level1defsbonussprite:
; Spritedaten des Bonus-Sprites
.word	cherrydata
; Dimension des Bonus-Sprites
.byt	8,11
level1defsbonusptssprite:
; Spritedaten des Bonus-Punkte-Sprites
.word	pts100data
; Dimension des Bonus-Punkte-Sprites
.byt	12,8
level1defsbonuspts:
; Bonus-Punkte (dividiert durch 10)
.byte	10,0
level1defsbonusicon:
; Bonus-Icon
.byte	CHERRYICON2,CHERRYICON1
level1defsend:

LDOFFGHOSTFRIGHTENDURATION = level1defsghostfrightenduration-level1defs
LDOFFGHOSTFRIGHTENBLINK = level1defsghostfrightenblink-level1defs
LDOFFGHOSTSPEEDFRIGHTEN = level1defsghostspeedfrighten-level1defs
LDOFFGHOSTSPEEDNORMAL = level1defsghostspeednormal-level1defs
LDOFFGHOSTSPEEDTUNNEL = level1defsghostspeedtunnel-level1defs
LDOFFPACSPEED = level1defspacspeed-level1defs
LDOFFPACFRIGHTENSPEED = level1defspacfrightenspeed-level1defs
LDOFFBONUSSPRITE = level1defsbonussprite-level1defs
LDOFFBONUSPTSSPRITE = level1defsbonusptssprite-level1defs
LDOFFBONUSPTS = level1defsbonuspts-level1defs
LDOFFBONUSICON = level1defsbonusicon-level1defs
SIZEOFLEVELDEFS = level1defsend-level1defs
INITLEVELDEFS = level1defs-SIZEOFLEVELDEFS

; Definitionen Level 2
; Ghost-Scatter-Chase-Tabelle
; Anzahl Sekunden bis zum naechsten Modus-Wechsel (Scatter - Chase - Scatter - ...)
.byt	7,27,34,54,59,58,58,255
; Dauer des Frighten-Modus (Anzahl Fuenftel-Sekunden)
.byt	5*5
; Zeitpunkt im Frighten-Modus, ab dem der Ghost anfaengt zu blinken
.byt	3*5
; Geschwindigkeit des Ghosts im FRIGHTEN-Modus
.byt	34
; Geschwindigkeit des Ghosts im SCATTER oder CHASE-Modus
.byt	53
; Geschwindigkeit des Ghosts im Tunnel
.byt	28
; Geschwindigkeit von Pacman
.byt	56
; Geschwindigkeit von Pacman im Frighten-Modus
.byt	59
; Spritedaten des Bonus-Sprites
.word	strawberrydata
; Dimension des Bonus-Sprites
.byt	8,11
; Spritedaten des Bonus-Punkte-Sprites
.word	pts300data
; Dimension des Bonus-Punkte-Sprites
.byt	12,8
; Bonus-Punkte (dividiert durch 10)
.byte	30,0
; Bonus-Icon
.byte	STRAWBERRYICON2,STRAWBERRYICON1

; Definitionen Level 3
; Ghost-Scatter-Chase-Tabelle
; Anzahl Sekunden bis zum naechsten Modus-Wechsel (Scatter - Chase - Scatter - ...)
.byt	7,27,34,54,59,58,58,255
; Dauer des Frighten-Modus (Anzahl Fuenftel-Sekunden)
.byt	4*5
; Zeitpunkt im Frighten-Modus, ab dem der Ghost anfaengt zu blinken
.byt	2*5
; Geschwindigkeit des Ghosts im FRIGHTEN-Modus
.byt	34
; Geschwindigkeit des Ghosts im SCATTER oder CHASE-Modus
.byt	53
; Geschwindigkeit des Ghosts im Tunnel
.byt	28
; Geschwindigkeit von Pacman
.byt	56
; Geschwindigkeit von Pacman im Frighten-Modus
.byt	59
; Spritedaten des Bonus-Sprites
.word	peachdata
; Dimension des Bonus-Sprites
.byt	8,11
; Spritedaten des Bonus-Punkte-Sprites
.word	pts500data
; Dimension des Bonus-Punkte-Sprites
.byt	12,8
; Bonus-Punkte (dividiert durch 10)
.byte	50,0
; Bonus-Icon
.byte	PEACHICON2,PEACHICON1

; Definitionen Level 4
; Ghost-Scatter-Chase-Tabelle
; Anzahl Sekunden bis zum naechsten Modus-Wechsel (Scatter - Chase - Scatter - ...)
.byt	5,25,30,50,55,54,54,255
; Dauer des Frighten-Modus (Anzahl Fuenftel-Sekunden)
.byt	4*5
; Zeitpunkt im Frighten-Modus, ab dem der Ghost anfaengt zu blinken
.byt	2*5
; Geschwindigkeit des Ghosts im FRIGHTEN-Modus
.byt	38
; Geschwindigkeit des Ghosts im SCATTER oder CHASE-Modus
.byt	56
; Geschwindigkeit des Ghosts im Tunnel
.byt	31
; Geschwindigkeit von Pacman
.byt	59
; Geschwindigkeit von Pacman im Frighten-Modus
.byt	59
; Spritedaten des Bonus-Sprites
.word	appledata
; Dimension des Bonus-Sprites
.byt	8,11
; Spritedaten des Bonus-Punkte-Sprites
.word	pts700data
; Dimension des Bonus-Punkte-Sprites
.byt	12,8
; Bonus-Punkte (dividiert durch 10)
.byte	70,0
; Bonus-Icon
.byte	APPLEICON2,APPLEICON1

; Definitionen Level 5
; Ghost-Scatter-Chase-Tabelle
; Anzahl Sekunden bis zum naechsten Modus-Wechsel (Scatter - Chase - Scatter - ...)
.byt	5,25,30,50,55,54,54,255
; Dauer des Frighten-Modus (Anzahl Fuenftel-Sekunden)
.byt	3*5
; Zeitpunkt im Frighten-Modus, ab dem der Ghost anfaengt zu blinken
.byt	5
; Geschwindigkeit des Ghosts im FRIGHTEN-Modus
.byt	38
; Geschwindigkeit des Ghosts im SCATTER oder CHASE-Modus
.byt	56
; Geschwindigkeit des Ghosts im Tunnel
.byt	31
; Geschwindigkeit von Pacman
.byt	59
; Geschwindigkeit von Pacman im Frighten-Modus
.byt	59
; Spritedaten des Bonus-Sprites
.word	grapesdata
; Dimension des Bonus-Sprites
.byt	8,11
; Spritedaten des Bonus-Punkte-Sprites
.word	pts1000data
; Dimension des Bonus-Punkte-Sprites
.byt	14,8
; Bonus-Punkte (dividiert durch 10)
.byte	100,0
; Bonus-Icon
.byte	GRAPESICON2,GRAPESICON1

; Definitionen Level 6
; Ghost-Scatter-Chase-Tabelle
; Anzahl Sekunden bis zum naechsten Modus-Wechsel (Scatter - Chase - Scatter - ...)
.byt	5,25,30,50,55,54,54,255
; Dauer des Frighten-Modus (Anzahl Fuenftel-Sekunden)
.byt	2*5
; Zeitpunkt im Frighten-Modus, ab dem der Ghost anfaengt zu blinken
.byt	0
; Geschwindigkeit des Ghosts im FRIGHTEN-Modus
.byt	38
; Geschwindigkeit des Ghosts im SCATTER oder CHASE-Modus
.byt	59
; Geschwindigkeit des Ghosts im Tunnel
.byt	31
; Geschwindigkeit von Pacman
.byt	63
; Geschwindigkeit von Pacman im Frighten-Modus
.byt	63
; Spritedaten des Bonus-Sprites
.word	galaxiandata
; Dimension des Bonus-Sprites
.byt	8,11
; Spritedaten des Bonus-Punkte-Sprites
.word	pts2000data
; Dimension des Bonus-Punkte-Sprites
.byt	16,8
; Bonus-Punkte (dividiert durch 10)
.byte	200,0
; Bonus-Icon
.byte	GALAXIANICON2,GALAXIANICON1

; Definitionen Level 7
; Ghost-Scatter-Chase-Tabelle
; Anzahl Sekunden bis zum naechsten Modus-Wechsel (Scatter - Chase - Scatter - ...)
.byt	5,25,30,50,55,54,54,255
; Dauer des Frighten-Modus (Anzahl Fuenftel-Sekunden)
.byt	2*5
; Zeitpunkt im Frighten-Modus, ab dem der Ghost anfaengt zu blinken
.byt	0
; Geschwindigkeit des Ghosts im FRIGHTEN-Modus
.byt	38
; Geschwindigkeit des Ghosts im SCATTER oder CHASE-Modus
.byt	59
; Geschwindigkeit des Ghosts im Tunnel
.byt	31
; Geschwindigkeit von Pacman
.byt	63
; Geschwindigkeit von Pacman im Frighten-Modus
.byt	63
; Spritedaten des Bonus-Sprites
.word	belldata
; Dimension des Bonus-Sprites
.byt	8,11
; Spritedaten des Bonus-Punkte-Sprites
.word	pts3000data
; Dimension des Bonus-Punkte-Sprites
.byt	16,8
; Bonus-Punkte (dividiert durch 10)
.byte	44,1
; Bonus-Icon
.byte	BELLICON2,BELLICON1

; Definitionen Level 8
; Ghost-Scatter-Chase-Tabelle
; Anzahl Sekunden bis zum naechsten Modus-Wechsel (Scatter - Chase - Scatter - ...)
.byt	5,25,30,50,55,54,54,255
; Dauer des Frighten-Modus (Anzahl Fuenftel-Sekunden)
.byt	5
; Zeitpunkt im Frighten-Modus, ab dem der Ghost anfaengt zu blinken
.byt	0
; Geschwindigkeit des Ghosts im FRIGHTEN-Modus
.byt	38
; Geschwindigkeit des Ghosts im SCATTER oder CHASE-Modus
.byt	59
; Geschwindigkeit des Ghosts im Tunnel
.byt	31
; Geschwindigkeit von Pacman
.byt	63
; Geschwindigkeit von Pacman im Frighten-Modus
.byt	63
; Spritedaten des Bonus-Sprites
.word	belldata
; Dimension des Bonus-Sprites
.byt	8,11
; Spritedaten des Bonus-Punkte-Sprites
.word	pts3000data
; Dimension des Bonus-Punkte-Sprites
.byt	16,8
; Bonus-Punkte (dividiert durch 10)
.byte	44,1
; Bonus-Icon
.byte	BELLICON2,BELLICON1

; Definitionen Level 9
; Ghost-Scatter-Chase-Tabelle
; Anzahl Sekunden bis zum naechsten Modus-Wechsel (Scatter - Chase - Scatter - ...)
.byt	5,25,30,50,55,54,54,255
; Dauer des Frighten-Modus (Anzahl Fuenftel-Sekunden)
.byt	0
; Zeitpunkt im Frighten-Modus, ab dem der Ghost anfaengt zu blinken
.byt	0
; Geschwindigkeit des Ghosts im FRIGHTEN-Modus
.byt	38
; Geschwindigkeit des Ghosts im SCATTER oder CHASE-Modus
.byt	59
; Geschwindigkeit des Ghosts im Tunnel
.byt	31
; Geschwindigkeit von Pacman
.byt	63
; Geschwindigkeit von Pacman im Frighten-Modus
.byt	63
; Spritedaten des Bonus-Sprites
.word	keydata
; Dimension des Bonus-Sprites
.byt	8,11
; Spritedaten des Bonus-Punkte-Sprites
.word	pts5000data
; Dimension des Bonus-Punkte-Sprites
.byt	16,8
; Bonus-Punkte (dividiert durch 10)
.byte	244,1
; Bonus-Icon
.byte	KEYICON2,KEYICON1

; Definitionen Level 10
; Ghost-Scatter-Chase-Tabelle
; Anzahl Sekunden bis zum naechsten Modus-Wechsel (Scatter - Chase - Scatter - ...)
.byt	5,25,30,50,55,54,54,255
; Dauer des Frighten-Modus (Anzahl Fuenftel-Sekunden)
.byt	0
; Zeitpunkt im Frighten-Modus, ab dem der Ghost anfaengt zu blinken
.byt	0
; Geschwindigkeit des Ghosts im FRIGHTEN-Modus
.byt	44
; Geschwindigkeit des Ghosts im SCATTER oder CHASE-Modus
.byt	69
; Geschwindigkeit des Ghosts im Tunnel
.byt	38
; Geschwindigkeit von Pacman
.byt	69
; Geschwindigkeit von Pacman im Frighten-Modus
.byt	69
; Spritedaten des Bonus-Sprites
.word	keydata
; Dimension des Bonus-Sprites
.byt	8,11
; Spritedaten des Bonus-Punkte-Sprites
.word	pts5000data
; Dimension des Bonus-Punkte-Sprites
.byt	16,8
; Bonus-Punkte (dividiert durch 10)
.byte	244,1
; Bonus-Icon
.byte	KEYICON2,KEYICON1

#include "pacmove.asm"

#include "ghostmove.asm"

#include "sound.asm"

#include "blinky.asm"
#include "blinkygen.asm"

#include "pinky.asm"
#include "pinkygen.asm"

#include "inky.asm"
#include "inkygen.asm"

#include "clyde.asm"
#include "clydegen.asm"

#include "spritedata.data"

; Zuletzt die Daten der Tiles
; -> muss am Ende stehen, weil zusaetzliche Tiles generiert werden
#include "level1.data"
