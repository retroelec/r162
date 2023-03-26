; Kompilieren
; xa wboy.asm -o wboy

#include "../atmega/6502def.inc"

SCROLLSPEEDSLOW = 3
SCROLLSPEEDFAST = 1

TOMTOMBASESPEED = 50
TOMTOMSPEEDSLOW = 60
TOMTOMSPEEDSLOWL = 256-TOMTOMSPEEDSLOW
TOMTOMSPEEDFAST = 100
TOMTOMSPEEDFASTL = 256-TOMTOMSPEEDFAST
TOMTOMSPEEDINCSTD = 5
TOMTOMSPEEDTUMBLE = 80
TOMTOMSPEEDTUMBLEL = 256-TOMTOMSPEEDTUMBLE

TOMTOMMOVEMAXNUMOFPIXS = 2
TOMTOMMINX = 4
TOMTOMMAXX = 64
TOMTOMMAXXEL = 160-TOMTOMLOWER4W
TOMTOMSTARTX = 44

TOMTOMNUMOFLIFES = 3

SCREENWIDTH = 160
SCREENHEIGHT = 200
GROUND = 200
EVENTSTARTX = 160

FALLDOWNSPEED = 4
SHOTSPEEDX = 3

SPEEDTOMTOMANIMSLOW = 4
SPEEDTOMTOMANIMFAST = 3
SPEEDTOMTOMDIESANIM = 8
DURATIONOFTOMTOMTUMBLE = 20
SPEEDSHOTANIM = 4

RIGHT = 0
LEFT = 1

TIMERENERGYCNTSTART = 65
ENERGYCOUNTERSTART = 24
ENERGYBARADR = TEXTMAPDEFAULT+40+(40-32)
ENERGYBARCOLADR = COLORMAPTXTDEFAULT+40+(40-32)

RED = 16
YELLOW = 208
PALEPINK = 176
BLACK = 0


* = START6502CODE

; Horizontales Scrolling -> Anzahl Spalten
scrollnumofcols = 10
; Horizontales Scrolling -> Temporaere Variable zur Steuerung der Geschwindigkeit
scrollcnt = scrollnumofcols+1
; Horizontales Scrolling -> Geschwindigkeit
scrollspeed = scrollcnt+1
; Horizontales Scrolling -> Flag, das bestimmt, ob am linken oder am rechten Rande eine Spalte kopiert werden muss
scrollflag = scrollspeed+1
; Horizontales Scrolling -> Pointer auf den aktuellen "Scroll-Block" (ZP-Adresse)
actscrollblk = scrollflag+1
; Zwischenstand -> Pointer auf den aktuellen "Scroll-Block"
lastsavescrollblk = actscrollblk+2
tmpsavescrollblk = lastsavescrollblk+2
; Horizontales Scrolling -> Anzahl verbleibende Spalten im aktuellen "Scroll-Block"
actscrollblkcnt = tmpsavescrollblk+2
; Horizontales Scrolling -> Scrolling an
scrollingon = actscrollblkcnt+1
; Pointer auf aktuelle Bodenhoehe (ZP-Adresse)
actgroundheightptr = scrollingon+1
; Zwischenstand -> Pointer auf aktuelle Bodenhoehe
lastsavegroundheightptr = actgroundheightptr+2
tmpsavegroundheightptr = lastsavegroundheightptr+2
; Poiner auf das Sprite-Event-Array (ZP-Adresse)
actspezarr1ptr = tmpsavegroundheightptr+2
; Zwischenstand -> Poiner auf das Sprite-Event-Array
lastsavespezarr1ptr = actspezarr1ptr+2
tmpsavespezarr1ptr = lastsavespezarr1ptr+2
; Aktuelles Sprite-Event (Feind oder Frucht)
actspriteevent = tmpsavespezarr1ptr+2
; Aktuelle(r) Feind/Frucht
actenemyfruitid = actspriteevent+1
; Parameter zu Feind/Frucht (y-Start-Position++)
actenemyfruitparam = actenemyfruitid+1

; Flag, ob die Sprung-Taste nach Betaetigung wieder "geloest" wurde
keyjumppressed = actenemyfruitparam+1
; Variable, die angibt, ob durch Druecken der Sprung-Taste ein neuer Sprung ausgeloest wurde
keyjumpok = keyjumppressed+1
; Variable, um zu pruefen, ob die Feuer-Taste nach Betaetigung wieder "geloest" wurde
keyfirepressed = keyjumpok+1
; Flag, ob durch Druecken der Schuss-Taste ein neuer Schuss ausgeloest wurde
keyfireok = keyfirepressed+1

; Variable, um die Geschwindigkeit der Bein-Animation von TomTom zu steuern
tomtomanimcnt = keyfireok+1
; Variable, um die Bein-Animation von TomTom zu steuern
tomtomanimlook = tomtomanimcnt+1
; Variable, ob TomTom nach links oder nach rechts "schaut"
tomtomviewdir = tomtomanimlook+1
; Variable, ob TomTom im letzten Zyklus nach links oder nach rechts "geschaut" hat
tomtomviewdirold = tomtomviewdir+1
; End-Geschwindigkeit von TomTom wenn nicht gescrollt wird (nach rechts)
tomtomspeedright = tomtomviewdirold+1
; End-Geschwindigkeit von TomTom wenn nicht gescrollt wird (nach links)
tomtomspeedleft = tomtomspeedright+1
; Aktuelle Geschwindigkeit von TomTom wenn nicht gescrollt wird
tomtomspeedact = tomtomspeedleft+1
; Temporaere Variable zur Steuerung der Geschwindigkeit von TomTom wenn nicht gescrollt wird
tomtomactspeed = tomtomspeedact+1
; Beschleunigung resp. "Rutschfaktor" von TomTom
tomtomspeedinc = tomtomactspeed+1
; Flag, ob TomTom einen grossen resp. kleinen Sprung ausfuehren koennte
tomtomjumphighflag = tomtomspeedinc+1
; Flag, ob TomTom springt
tomtomjumpflag = tomtomjumphighflag+1
; Index fuer das "Jump-Array"
tomtomactjumpidx = tomtomjumpflag+1
; Pointer auf das "Jump-Array" (ZP-Adresse)
tomtomjumparr = tomtomactjumpidx+1
; Aktuelle y-Position von TomTom
tomtomacty = tomtomjumparr+2
; Flag, das anzeigt, ob TomTom stirbt
tomtomdiesflag = tomtomacty+1
; Index auf das "TomTom-stirbt-Array"
tomtomdiesmvidx = tomtomdiesflag+1
; Flag, das anzeigt, dass TomTom tot ist
tomtomisdead = tomtomdiesmvidx+1
; Flag, das anzeigt, ob TomTom stolpert
tomtomtumbleflag = tomtomisdead+1
; Anzahl Zyklen, bis TomTom nach einem Stolperer wieder "normal" laeuft
tomtomtumblecnt = tomtomtumbleflag+1
; Anzahl Zyklen, bis TomTom nach einer Aktion (z.B. Schussabgabe) wieder "normal" wird (z.B. Arm wieder nach unten nimmt)
tomtombacktonormalcnt = tomtomtumblecnt+1
; Alte x-Position von TomTom (oben)
tomtomoldobenx = tomtombacktonormalcnt+1
; Alte x-Position von TomTom (unten)
tomtomolduntenx = tomtomoldobenx+1
; Alte y-Position von TomTom (oben)
tomtomoldobeny = tomtomolduntenx+1
; Flag, das anzeigt, ob TomTom auf einem "Platform"-Sprite gelandet ist
tomtomonsprite = tomtomoldobeny+1
; ID des "Platform"-Sprites, auf dem TomTom gelandet ist
tomtomonspriteid = tomtomonsprite+1
; y-Koordinate des "Platform"-Sprites, auf dem TomTom gelandet ist
tomtomonspritey = tomtomonspriteid+1
; Delta-x-Wert um den TomTom bewegt wird, wenn er auf einem "Platform"-Sprite steht
tomtomonspritedeltax = tomtomonspritey+1
; Flag, das anzeigt, ob TomTom auf einer Sprungfeder gelandet ist
tomtomonspring = tomtomonspritedeltax+1
; Maximale x-Position von TomTom
tomtommaxx = tomtomonspring+1

; Index auf das "Schuss-Array" (Schuss1)
shot1mvidx = tomtommaxx+1
; Geschwindigkeit + Richtung des Schusses (links, rechts) (Schuss1)
shot1speed = shot1mvidx+1
; Variable, um die Geschwindigkeit der Schuss1-Animation zu steuern
shot1animcnt = shot1speed+1
; Variable, um die Schuss1-Animation zu steuern
shot1animlook = shot1animcnt+1
; Index auf das "Schuss-Array" (Schuss2)
shot2mvidx = shot1animlook+1
; Geschwindigkeit + Richtung des Schusses (links, rechts) (Schuss2)
shot2speed = shot2mvidx+1
; Variable, um die Geschwindigkeit der Schuss2-Animation zu steuern
shot2animcnt = shot2speed+1
; Variable, um die Schuss2-Animation zu steuern
shot2animlook = shot2animcnt+1

; Aktuelles Autosound-Sample der Hintergrundmusik
autosndsamplenum = shot2animlook+1
; Flag, ob gerade ein Sound-Effekt abgespielt wird
soundeffectflag = autosndsamplenum+1
; Flag, ob ein neuer Sound-Effekt abgespielt werden soll
newsoundeffectflag = soundeffectflag+1
; Speicherbereich zur Zwischenspeicherung der aktuellen "Hintergrund-Musik-Werte"
saveautosndarr = newsoundeffectflag+1
; Laenge des aktuellen Soundeffekts
soundeffectlen = saveautosndarr+5
; Temporaere Variabeln fuer das Abspielen von Soundeffekten
tmpautosndcnt = soundeffectlen+2
tmpautosndptr = tmpautosndcnt+2
tmpautosndsync = tmpautosndptr+2

; Pointer auf das aktuelle Feind-Sprite (ZP-Adresse)
enemysprite = tmpautosndsync+1
; Pointer auf die Bewegungs-Funktion des aktuellen Feind-Sprites (Sprite bewegen)
actenemymove = enemysprite+2

; Temporaere Variabeln fuer diverse Funktionen
enemydyingmovetemp1 = actenemymove+2
enemydyingmovetemp2 = enemydyingmovetemp1+1
endlevelproctemp1 = enemydyingmovetemp2+1
tomtommovetemp1 = endlevelproctemp1+1
moveenemytemp1 = tomtommovetemp1+1

; Pointer auf die Coinc-Funktion des aktuellen Feind- oder Fruechte-Sprites
actcoincfunc = moveenemytemp1+1
; Pointer auf das Feind- oder Fruechte-Sprite, welches mit TomTom oder einem Schuss kollidiert ist
actcoincsprite = actcoincfunc+2
; Temporaere Variable fuer die coinc-Funktionen
tmpnumofcoincs = actcoincsprite+2

; Anzahl Leben von TomTom
tomtomlifes = tmpnumofcoincs+1

; Flag, ob Endlevel-Zone erreicht
endlevelzone = tomtomlifes+1

; Aktueller Level
level = endlevelzone+1

; Aktueller Score + Highscore
score = level+1
highscore = score+2

; Steuerungsvariablen
levelendflag = highscore+2
flagwall = levelendflag+1
gfxscrvar = flagwall+1

; Variable, um zu signalisieren, dass ein Zwischenziel gespeichert werden muss
flagsaveintermedgoal = gfxscrvar+1

; Variable, die bestimmt, in welchem Intervall der Energy-Counter dekrementiert werden soll
timerenergycnt = flagsaveintermedgoal+1
; Variable mit dem aktuellen Energy-Counter-Wert
energycounter = timerenergycnt+1
; Variable mit dem alten Energy-Counter-Wert
energycounterold = energycounter+1

; Temporaere Variable fuer die Funktion waitawhile
tmpwaitawhile = energycounterold+1

#ifdef DBG_PERF
; Debug-Variabeln
dbgmaxrow = tmpwaitawhile+1
dbgmax2row = dbgmaxrow+1
#endif


; Autostart-Programm
jmp	start
.asc	"AUTO"


loadfilestruct:
.dsb	6,0

filestruct:
.dsb	FILESTRUCTSIZE, 0

titlescreenfname:
.asc	"/DATA/WBOY/TITLESCR.PIC", 0

endingscreenfname:
.asc	"/DATA/WBOY/ENDSCR.PIC", 0

gameoverfname:
.asc	"/DATA/WBOY/GAMEOV2X.RAW", 0

loadlevelfname:
.asc	"/DATA/WBOY/LEVEL"
loadlevelnrfname:
.byt	0
.asc	".DAT", 0

memfillstructgfx:
.word	MCOLORMAPDEFAULT-16000
.byt	SCREENWIDTH,SCREENHEIGHT,0

textplayer1:
.asc	"PLAYER1"

texthigh:
.byt	127
.asc	"HIGH"
.byt	127

textlevel:
.asc	"LEVEL"


	; Haupt-Schlaufe
mainloop:
	; Warte auf VSYNC
	lda	TIMER
lab0:
	cmp	TIMER
	beq	lab0

#ifdef DBG_PERF
	; Debug-Information -> Performance-Messung
	ldx	dbgmaxrow
	ldy	#0
	callatm	itoa6502
	ldx	#1
	ldy	#24
	callatm	setcursorpos6502
	ldx	#<ITOASTRING
	ldy	#>ITOASTRING
	callatm	printstring6502
#endif

	; Sound abspielen
	lda	newsoundeffectflag
	beq	lab1
	lda	tmpautosndcnt
	sta	soundeffectlen
	lda	tmpautosndcnt+1
	sta	soundeffectlen+1
	jsr	savebgmusicparams
	lda	tmpautosndcnt
	sta	AUTOSNDCNT
	lda	tmpautosndcnt+1
	sta	AUTOSNDCNT+1
	lda	tmpautosndptr
	sta	AUTOSNDPTRP768
	lda	tmpautosndptr+1
	sta	AUTOSNDPTRP768+1
	lda	#WBOYSAMPLESTCCR2
	sta	SNDTCCR2
	lda	tmpautosndsync
	sta	AUTOSNDSYNC
	sta	AUTOSND
	sta	soundeffectflag
	lda	#0
	sta	newsoundeffectflag
	beq	lab10
lab1:
	lda	tomtomdiesflag
	bne	lab10
	lda	AUTOSND
	bne	lab10
	jsr	playbgmusic
lab10:

	; Level zu Ende?
	lda	levelendflag
	beq	lab8
	inc	level
	jsr	endlevelproc

	; Warte 1 Sekunde
	lda	#50
	jsr	waitawhile
	jmp	initnewlevel
lab8:

	; TomTom gestorben?
	lda	tomtomisdead
	beq	lab9
	; Warte 2 Sekunden
	lda	#100
	jsr	waitawhile
	lda	#' '
	dec	tomtomlifes
	beq	lab2
	ldx	tomtomlifes
	sta	TEXTMAPDEFAULT+39,x
	jmp	initlevel
lab2:
	jmp	gameover
lab9:

	; Abfrage User-Input
	lda	KEYPRESSED
	beq	lab3
	; ESC?
	cmp	#127
	bne	lab3
	jmp	quitgame
lab3:

	lda	tomtomdiesflag
	bne	lab7

	; Kollisions-Detektionen
	jsr	coinctomtom

	; Energiezaehler anpassen
	dec	timerenergycnt
	bne	lab7
	lda	energycounter
	sta	energycounterold
	lda	#TIMERENERGYCNTSTART
	sta	timerenergycnt
	dec	energycounter
	jsr	adaptenergybar

#ifdef DBG_ENERGY
	ldx	energycounter
	ldy	#0
	callatm	itoa6502
	ldx	#12
	ldy	#0
	callatm	setcursorpos6502
	ldx	#<ITOASTRING
	ldy	#>ITOASTRING
	callatm	printstring6502
#endif

	lda	energycounter
	bne	lab7
	; Tomtom stirbt
	jsr	tomtomdiesinit

lab7:
	jsr	coincshot1
	jsr	coincshot2

	; TomTom bewegen
	jsr	tomtommove

	; Feinde, Fruechte etc. bewegen und/oder loeschen
	jsr	moveenemies

#ifdef DBG_ENEMIES
	; Debug-Info
	lda	enemy1+MSPRITESTATUS
	clc
	adc	#48
	sta	TEXTMAPDEFAULT+24
	lda	enemy2+MSPRITESTATUS
	clc
	adc	#48
	sta	TEXTMAPDEFAULT+26
	lda	enemy3+MSPRITESTATUS
	clc
	adc	#48
	sta	TEXTMAPDEFAULT+28
	lda	enemy4+MSPRITESTATUS
	clc
	adc	#48
	sta	TEXTMAPDEFAULT+30
	lda	enemy5+MSPRITESTATUS
	clc
	adc	#48
	sta	TEXTMAPDEFAULT+32
	lda	enemy6+MSPRITESTATUS
	clc
	adc	#48
	sta	TEXTMAPDEFAULT+34
	lda	enemy7+MSPRITESTATUS
	clc
	adc	#48
	sta	TEXTMAPDEFAULT+36
	lda	enemy8+MSPRITESTATUS
	clc
	adc	#48
	sta	TEXTMAPDEFAULT+38
#endif

#ifdef DBG_PERF
	; Debug-Information -> Performance-Messung
	lda	VSYNCROW
	clc
	adc	#205
	cmp	dbgmax2row
	bcc	dbglab2
	sta	dbgmax2row
dbglab2:
	ldx	dbgmax2row
	ldy	#0
	callatm	itoa6502
	ldx	#20
	ldy	#24
	callatm	setcursorpos6502
	ldx	#<ITOASTRING
	ldy	#>ITOASTRING
	callatm	printstring6502
#endif

	jmp	mainloop


	; pointer actscrollblk -> |cnt|ptr-scroll-blk|
	;                         |cnt|ptr-scroll-blk|
	;                         ....
getnewscrollblock:
	; Speichern eines Zwischenziels?
	lda	flagsaveintermedgoal
	beq	getnewscrollblock_lab2
	lda	#0
	sta	flagsaveintermedgoal
	lda	gfxscrvar
	bne	getnewscrollblock_lab2
	lda	tmpsavescrollblk
	sta	lastsavescrollblk
	lda	tmpsavescrollblk+1
	sta	lastsavescrollblk+1
	lda	tmpsavegroundheightptr
	sta	lastsavegroundheightptr
	lda	tmpsavegroundheightptr+1
	sta	lastsavegroundheightptr+1
	lda	tmpsavespezarr1ptr
	sta	lastsavespezarr1ptr
	lda	tmpsavespezarr1ptr+1
	sta	lastsavespezarr1ptr+1
getnewscrollblock_lab2:
	; Aktuelle Parameter zwischenspeichern
	lda	actscrollblk
	sta	tmpsavescrollblk
	lda	actscrollblk+1
	sta	tmpsavescrollblk+1
	lda	actgroundheightptr
	sta	tmpsavegroundheightptr
	lda	actgroundheightptr+1
	sta	tmpsavegroundheightptr+1
	lda	actspezarr1ptr
	sta	tmpsavespezarr1ptr
	lda	actspezarr1ptr+1
	sta	tmpsavespezarr1ptr+1
	; Hole neuen Scroll-Block
	ldy	#0
	lda	(actscrollblk),y
	beq	getnewscrollblock_lab1
	sta	actscrollblkcnt
	iny
	lda	(actscrollblk),y
	sta	TILEMAPP768
	iny
	lda	(actscrollblk),y
	sta	TILEMAPP768+1
	lda	actscrollblk
	clc
	adc	#3
	sta	actscrollblk
	lda	actscrollblk+1
	adc	#0
	sta	actscrollblk+1
	; TILEMAPSTARTX+1 ist immer 0
	lda	#255
	sta	TILEMAPSTARTX
	rts
getnewscrollblock_lab1:
	lda	#1
	sta	levelendflag
	rts


; Prinzipielles Vorgehen beim horizontalen Scrolling

; Ausgangslage             |AABBCC|
; rechts kopieren         A|ABBCCD|D
; links kopieren         DD|BBCCDD|
; rechts kopieren       DDB|BCCDDE|E
; links kopieren       DDEE|CCDDEE|
; rechts kopieren     DDEEC|CDDEEF|F
; links kopieren     DDEEFF|DDEEFF|
; Ausgangslage             |DDEEFF|


	; VSYNC-Routine
vsyncint:
	pha
	tya
	pha
	txa
	pha

	lda	scrollingon
	beq	vsyncint_lab14
	dec	scrollcnt
	bne	vsyncint_lab14
	lda	scrollspeed
	sta	scrollcnt
	lda	scrollflag
	eor	#1
	sta	scrollflag
	beq	vsyncint_lab8
	jmp	vsyncint_lab7

vsyncint_lab1:
	; Sprites scrollen
	jsr	scrollsprites

	; ACTMCOLMAP-Pointers neu setzen (weil MCOLORMAP-Pointer veraendert wurde)
	lda	MCOLORMAPP768
	sta	ACTMCOLMAPPTRP768
	lda	MCOLORMAPP768+1
	sta	ACTMCOLMAPPTRP768+1

vsyncint_lab14:
#ifdef DBG_PERF
	; VSYNC-Routine abgearbeitet
	lda	VSYNCROW
	clc
	adc	#205
	cmp	dbgmaxrow
	bcc	dbglab1
	sta	dbgmaxrow
dbglab1:
#endif

	pla
	tax
	pla
	tay
	pla
	rti

vsyncint_lab7:
	; Spalte rechts kopieren + Pointer auf Colormap verschieben

	; TILEMAPSTARTX+1 ist immer 0
	inc	TILEMAPSTARTX
	lda	#40
	sta	TILEMCOLMAPX
	callatm	gfxcopytilecol6502

	inc	MCOLORMAPP768
	bne	vsyncint_lab5
	inc	MCOLORMAPP768+1
vsyncint_lab5:

	; Pointer auf das Bodenhoehe-Array anpassen
	inc	actgroundheightptr
	bne	vsyncint_lab12
	inc	actgroundheightptr+1
vsyncint_lab12:

	; Neue Events (Feinde, Fruechte, etc.) einblenden?
	inc	actspezarr1ptr
	bne	vsyncint_lab4
	inc	actspezarr1ptr+1
vsyncint_lab4:
	ldy	#0
	lda	(actspezarr1ptr),y
	beq	vsyncint_lab11
	jsr	createenemy
vsyncint_lab11:

	jmp	vsyncint_lab1

vsyncint_lab8:
	; Spalte links kopieren + Pointer auf Colormap verschieben
	lda	#0
	sta	TILEMCOLMAPX
	dec	MCOLORMAPP768
	bpl	vsyncint_lab2
	dec	MCOLORMAPP768+1
vsyncint_lab2:
	callatm	gfxcopytilecol6502
	inc	MCOLORMAPP768
	bne	vsyncint_lab6
	inc	MCOLORMAPP768+1
vsyncint_lab6:
	inc	MCOLORMAPP768
	bne	vsyncint_lab9
	inc	MCOLORMAPP768+1
vsyncint_lab9:
	inc	scrollnumofcols
	dec	actscrollblkcnt
	bne	vsyncint_lab10
	jsr	getnewscrollblock
vsyncint_lab10:

	; 40 Spalten kopiert?
	lda	scrollnumofcols
	cmp	#40
	beq	vsyncint_lab3
	jmp	vsyncint_lab1

vsyncint_lab3:
	; 40 Spalten kopiert -> Reset
	lda	#0
	sta	scrollnumofcols
	lda	#<(MCOLORMAPDEFAULT-16000+768)
	sta	MCOLORMAPP768
	lda	#>(MCOLORMAPDEFAULT-16000+768)
	sta	MCOLORMAPP768+1
	jmp	vsyncint_lab1


scrollsprites:
	dec	enemy1+MSPRITEX
	dec	enemy1+MSPRITEX
	dec	enemy2+MSPRITEX
	dec	enemy2+MSPRITEX
	dec	enemy3+MSPRITEX
	dec	enemy3+MSPRITEX
	dec	enemy4+MSPRITEX
	dec	enemy4+MSPRITEX
	dec	enemy5+MSPRITEX
	dec	enemy5+MSPRITEX
	dec	enemy6+MSPRITEX
	dec	enemy6+MSPRITEX
	dec	enemy7+MSPRITEX
	dec	enemy7+MSPRITEX
	dec	enemy8+MSPRITEX
	dec	enemy8+MSPRITEX
	dec	enemy9+MSPRITEX
	dec	enemy9+MSPRITEX
	dec	enemy10+MSPRITEX
	dec	enemy10+MSPRITEX
	dec	enemy11+MSPRITEX
	dec	enemy11+MSPRITEX
	dec	enemy12+MSPRITEX
	dec	enemy12+MSPRITEX
	dec	shot1sprite+MSPRITEX
	dec	shot1sprite+MSPRITEX
	dec	shot2sprite+MSPRITEX
	dec	shot2sprite+MSPRITEX
	rts


setscrsndstdvalues:
	lda	#0
	sta	MODE2ENDLINE
	lda	#1
	sta	MODE2STARTLINE
setscrsndstdvalues_lab0:
	callatm	initlistmsprites6502
	lda	#0
	sta	SNDTCCR2
	lda	#80
	sta	MCOLSCRWIDTH
	lda	#<(MCOLORMAPDEFAULT+768)
	sta	MCOLORMAPP768
	lda	#>(MCOLORMAPDEFAULT+768)
	sta	MCOLORMAPP768+1
	rts


start:
	; Initialisierungen
;	tsx
;	stx	stack

	; Initialisierungen
	jsr	initwboy

	; Starte Spiel
	jmp	initnewgame


initwboy:
	; VSYNC-Interrupt
	lda	#0
	sta	scrollingon
	lda	#<vsyncint
	sta	$FFFC
	lda	#>vsyncint
	sta	$FFFD
	lda	#16
	sta	INTMASK6502
	cli

#ifdef DBG_PERF
	; Debug
	lda	#0
	sta	dbgmaxrow
	sta	dbgmax2row
#endif

	; Titelzeilen
	lda	#0
	sta	CURONOFF
	lda	#' '
	ldx	#80
initwboy_lab1:
	sta	TEXTMAPDEFAULT-1,x
	dex
	bne	initwboy_lab1
initwboy_lab2:
	lda	textlevel,x
	sta	TEXTMAPDEFAULT,x
	inx
	cpx	#5
	bne	initwboy_lab2
	ldx	#0
initwboy_lab3:
	lda	textplayer1,x
	sta	TEXTMAPDEFAULT+26,x
	inx
	cpx	#7
	bne	initwboy_lab3
	ldx	#0
initwboy_lab5:
	lda	texthigh,x
	sta	TEXTMAPDEFAULT+11,x
	inx
	cpx	#6
	bne	initwboy_lab5
	ldx	#6
	lda	#'0'
initwboy_lab6:
	sta	TEXTMAPDEFAULT+17,x
	dex
	bne	initwboy_lab6
	lda	#240
	ldx	#80
initwboy_lab7:
	sta	COLORMAPTXTDEFAULT-1,x
	dex
	bne	initwboy_lab7
	lda	#RED
	sta	COLORMAPTXTDEFAULT+11
	sta	COLORMAPTXTDEFAULT+16
	; TomTom-Leben in rot
	ldx	#5
initwboy_lab4:
	sta	COLORMAPTXTDEFAULT+39,x
	dex
	bne	initwboy_lab4
	; Letzte Ziffer des Scores
	lda	#'0'
	sta	TEXTMAPDEFAULT+39

	; High-Score
	lda	#0
	sta	highscore
	sta	highscore+1

	; Grafik-Modus einschalten
	lda	#2
	sta	VIDEOMODE

	; Lade Sound-Samples
	jmp	loadsoundsamples

initnewgame:
	; Starte mit Level 1
levelcheatpoke:
	lda	#1
	sta	level
	lda	#0
	sta	score
	sta	score+1
	jsr	updatescore

	; Laden + Anzeigen Titel-Screen
	jsr	setscrsndstdvalues
	lda	#<filestruct
	sta	loadfilestruct+FATLOADSAVE_FILE
	lda	#>filestruct
	sta	loadfilestruct+FATLOADSAVE_FILE+1
	lda	#<titlescreenfname
	sta	loadfilestruct+FATLOADSAVE_NAME
	lda	#>titlescreenfname
	sta	loadfilestruct+FATLOADSAVE_NAME+1
	lda	#<MCOLORMAPDEFAULT
	sta	loadfilestruct+FATLOADSAVE_MEM
	lda	#>MCOLORMAPDEFAULT
	sta	loadfilestruct+FATLOADSAVE_MEM+1
	ldx	#<loadfilestruct
	ldy	#>loadfilestruct
	callatm	fatload6502
	lda	RERRCODE6502
	beq	initnewgame_lab2
initnewgame_lab3:
	jmp	quitgame
initnewgame_lab2:
	; Warte auf Tastendruck
initnewgame_lab1:
	lda	KEYPRESSED
	cmp	#127
	beq	initnewgame_lab3
	cmp	#' '
	bne	initnewgame_lab1

	; Setze Anzahl Leben beim Start des Spiels
	ldx	#TOMTOMNUMOFLIFES
	stx	tomtomlifes
	dex
	lda	#127
initnewgame_lab4:
	sta	TEXTMAPDEFAULT+39,x
	dex
	bne	initnewgame_lab4

	; Breite der Colormap
	lda	#SCREENWIDTH
	sta	MCOLSCRWIDTH

	; Grafik-Screen fuer Spiel anpassen
	lda	#16
	sta	MODE2STARTLINE
#ifdef DBG_PERF
	lda	#192
	sta	MODE2ENDLINE
#else
	lda	#200
	sta	MODE2ENDLINE
#endif

initnewlevel:
	; Anzeige Level
	lda	level
	clc
	adc	#'0'
	sta	loadlevelnrfname
	; Lade naechsten Level
	lda	#<filestruct
	sta	loadfilestruct+FATLOADSAVE_FILE
	lda	#>filestruct
	sta	loadfilestruct+FATLOADSAVE_FILE+1
	lda	#<loadlevelfname
	sta	loadfilestruct+FATLOADSAVE_NAME
	lda	#>loadlevelfname
	sta	loadfilestruct+FATLOADSAVE_NAME+1
	lda	#<leveldata
	sta	loadfilestruct+FATLOADSAVE_MEM
	lda	#>leveldata
	sta	loadfilestruct+FATLOADSAVE_MEM+1
	ldx	#<loadfilestruct
	ldy	#>loadfilestruct
	callatm	fatload6502
	lda	RERRCODE6502
	beq	initnewlevel_lab1
	; Alle Levels durchgespielt -> End-Bild laden
	lda	#100
	jsr	waitawhile
	jsr	setscrsndstdvalues_lab0
	lda	#<endingscreenfname
	sta	loadfilestruct+FATLOADSAVE_NAME
	lda	#>endingscreenfname
	sta	loadfilestruct+FATLOADSAVE_NAME+1
	lda	#<MCOLORMAPDEFAULT
	sta	loadfilestruct+FATLOADSAVE_MEM
	lda	#>MCOLORMAPDEFAULT
	sta	loadfilestruct+FATLOADSAVE_MEM+1
	ldx	#<loadfilestruct
	ldy	#>loadfilestruct
	callatm	fatload6502
	; Warte 10 Sekunden
	lda	#250
	jsr	waitawhile
	lda	#250
	jsr	waitawhile
	; Starte ein neues Spiel
	jmp	initnewgame
initnewlevel_lab1:

	; Anzeige Level-Nummer
	lda	level
	clc
	adc	#'0'
	sta	TEXTMAPDEFAULT+6

	; Start-Werte fuer Level-Pointers
	lda	leveldata+LDI_WORLDARRAY
	sta	lastsavescrollblk
	lda	leveldata+LDI_WORLDARRAY+1
	sta	lastsavescrollblk+1
	lda	leveldata+LDI_GROUNDARRAY
	sta	lastsavegroundheightptr
	lda	leveldata+LDI_GROUNDARRAY+1
	sta	lastsavegroundheightptr+1
	lda	leveldata+LDI_EVENTARRAY
	sta	lastsavespezarr1ptr
	lda	leveldata+LDI_EVENTARRAY+1
	sta	lastsavespezarr1ptr+1

initlevel:
	; Init. Level-Pointers
	lda	#0
	sta	flagsaveintermedgoal
	lda	lastsavescrollblk
	sta	actscrollblk
	lda	lastsavescrollblk+1
	sta	actscrollblk+1
	lda	#0
	sta	actscrollblkcnt
	jsr	getnewscrollblock
	lda	lastsavegroundheightptr
	sta	actgroundheightptr
	lda	lastsavegroundheightptr+1
	sta	actgroundheightptr+1
	lda	lastsavespezarr1ptr
	sta	actspezarr1ptr
	lda	lastsavespezarr1ptr+1
	sta	actspezarr1ptr+1

	; Level ist noch nicht geschafft
	lda	#0
	sta	levelendflag
	sta	endlevelzone

	; Initialisierungen fuer horizontales Scrolling
	lda	#0
	sta	scrollingon
	sta	scrollnumofcols
	sta	scrollflag
	lda	#<(MCOLORMAPDEFAULT-16000+768)
	sta	MCOLORMAPP768
	lda	#>(MCOLORMAPDEFAULT-16000+768)
	sta	MCOLORMAPP768+1

	; Initialisierungen fuer Grafik-Screen
	lda	leveldata+LDI_TILESDEF
	sta	GFXTILEDEFSP768
	lda	leveldata+LDI_TILESDEF+1
	sta	GFXTILEDEFSP768+1
	lda	#0
	sta	TILEMAPSTARTX+1
	sta	TILEMAPSTARTY
	sta	TILEMAPSTARTY+1
	sta	TILEMAPHEIGHT+1
	sta	TILEMCOLMAPX
	lda	#23
	sta	TILEMAPHEIGHT
	lda	#2
	sta	TILEMCOLMAPY
	lda	#23
	sta	TILEMCOLMAPH
	lda	#40
	sta	TILEMCOLMAPW

	; Sprites init.
	callatm	initlistmsprites6502
	lda	#MSPRITEDELETED
	sta	enemy1+MSPRITESTATUS
	sta	enemy2+MSPRITESTATUS
	sta	enemy3+MSPRITESTATUS
	sta	enemy4+MSPRITESTATUS
	sta	enemy5+MSPRITESTATUS
	sta	enemy6+MSPRITESTATUS
	sta	enemy7+MSPRITESTATUS
	sta	enemy8+MSPRITESTATUS
	sta	enemy9+MSPRITESTATUS
	sta	enemy10+MSPRITESTATUS
	sta	enemy11+MSPRITESTATUS
	sta	enemy12+MSPRITESTATUS
	sta	shot1sprite+MSPRITESTATUS
	sta	shot2sprite+MSPRITESTATUS

	; Initialisierung Sound
	lda	#0
	sta	autosndsamplenum
	sta	soundeffectflag
	sta	newsoundeffectflag

	; Diverse Variabeln initialisieren
	lda	#0
	sta	keyjumppressed
	lda	#1
	sta	flagwall

	; Refresh aller Sprites
	lda	#1
	sta	MINSPRITEIDTODRAW

	; Grafik-Screen zeichnen
	ldx	#<memfillstructgfx
	ldy	#>memfillstructgfx
	callatm	memfill6502
	lda	#81
	sta	gfxscrvar
	lda	#1
	sta	scrollspeed
	sta	scrollcnt
initlevel_lab2:
	; Warte auf VSYNC
	lda	TIMER
initlevel_lab1:
	cmp	TIMER
	beq	initlevel_lab1
	lda	#1
	sta	scrollingon
	dec	gfxscrvar
	bne	initlevel_lab2
	lda	#0
	sta	scrollingon
	lda	#SCROLLSPEEDSLOW
	sta	scrollspeed
	sta	scrollcnt

	jsr	tomtominit
	jsr	energycounterinit

	; Spiel laeuft
	jmp	mainloop


waitawhile:
	sta	tmpwaitawhile
waitawhile_lab1:
	lda	TIMER
waitawhile_lab2:
	cmp	TIMER
	beq	waitawhile_lab2
	dec	tmpwaitawhile
	bne	waitawhile_lab1
	rts


	; Game Over
gameover:
	; Lade "Game Over"-Logo
	lda	#<filestruct
	sta	loadfilestruct+FATLOADSAVE_FILE
	lda	#>filestruct
	sta	loadfilestruct+FATLOADSAVE_FILE+1
	lda	#<gameoverfname
	sta	loadfilestruct+FATLOADSAVE_NAME
	lda	#>gameoverfname
	sta	loadfilestruct+FATLOADSAVE_NAME+1
	clc
	lda	MCOLORMAPP768
	adc	#<(92*SCREENWIDTH - 768)
	sta	loadfilestruct+FATLOADSAVE_MEM
	lda	MCOLORMAPP768+1
	adc	#>(92*SCREENWIDTH - 768)
	sta	loadfilestruct+FATLOADSAVE_MEM+1
	ldx	#<loadfilestruct
	ldy	#>loadfilestruct
	callatm	fatload6502
	lda	RERRCODE6502
	beq	gameover_lab1
	jmp	quitgame
gameover_lab1:
	callatm	initlistmsprites6502
	; Warte 5 Sekunden
	lda	#250
	jsr	waitawhile
	; Start Screen
	jmp	initnewgame


	; Programm verlassen
quitgame:
	jsr	setscrsndstdvalues
	; Farben des Energybars auf Standard zuruecksetzen
	ldx	#32
	lda	#240
quitgame_lab1:
	sta	ENERGYBARCOLADR-1,x
	dex
	bne	quitgame_lab1
	; Text-Modus
	lda	#0
	sta	VIDEOMODE
	lda	#1
	sta	CURONOFF
	jmpsh


endlevelproc:
	lda	#0
	sta	scrollingon
	lda	#1
	sta	endlevelzone
	lda	#TOMTOMMAXXEL
	sta	tomtommaxx
	; Spiele Sample 1
	lda	#3
	sta	endlevelproctemp1
endlevelproc_lab1:
	lda	TIMER
endlevelproc_lab7:
	cmp	TIMER
	beq	endlevelproc_lab7
	lda	#<(SNDLEVELENDSFSIZE-4)
	sta	AUTOSNDCNT
	lda	#>(SNDLEVELENDSFSIZE-4)
	sta	AUTOSNDCNT+1
	lda	#<(SNDLEVELENDSFMEM+768+4)
	sta	AUTOSNDPTRP768
	lda	#>(SNDLEVELENDSFMEM+768+4)
	sta	AUTOSNDPTRP768+1
	lda	#WBOYSAMPLESTCCR2
	sta	SNDTCCR2
	lda	#WBOYSAMPLESCONST3
	sta	AUTOSND
	sta	AUTOSNDSYNC
endlevelproc_lab2:
	jsr	endlevelmvtt
	lda	AUTOSND
	bne	endlevelproc_lab2
	dec	endlevelproctemp1
	lda	endlevelproctemp1
	bne	endlevelproc_lab1
	; Spiele Sample 2 pro verbleibende Energie-Einheit
	lda	energycounter
	beq	endlevelproc_lab6
endlevelproc_lab3:
	lda	TIMER
endlevelproc_lab8:
	cmp	TIMER
	beq	endlevelproc_lab8
	lda	#<(SNDEATFRUITFSIZE-4)
	sta	AUTOSNDCNT
	lda	#>(SNDEATFRUITFSIZE-4)
	sta	AUTOSNDCNT+1
	lda	#<(SNDEATFRUITFMEM+768+4)
	sta	AUTOSNDPTRP768
	lda	#>(SNDEATFRUITFMEM+768+4)
	sta	AUTOSNDPTRP768+1
	lda	#WBOYSAMPLESTCCR2
	sta	SNDTCCR2
	lda	#WBOYSAMPLESCONST3
	sta	AUTOSND
	sta	AUTOSNDSYNC
endlevelproc_lab4:
	jsr	endlevelmvtt
	inc	endlevelproctemp1
	lda	endlevelproctemp1
	and	#1
	beq	endlevelproc_lab4
	lda	energycounter
	beq	endlevelproc_lab6
	jsr	endlevelupdatescore
	lda	AUTOSND
	bne	endlevelproc_lab4
	beq	endlevelproc_lab3
endlevelproc_lab6:
	rts


endlevelupdatescore:
	lda	energycounter
	sta	energycounterold
	dec	energycounter
	jsr	adaptenergybar
	clc
	lda	score
	adc	#30
	sta	score
	bcc	endlevelupdatescore_lab1
	inc	score+1
endlevelupdatescore_lab1:
	jmp	updatescore


endlevelmvtt:
	lda	TIMER
endlevelmvtt_lab1:
	cmp	TIMER
	beq	endlevelmvtt_lab1
	lda	TIMER
endlevelmvtt_lab2:
	cmp	TIMER
	beq	endlevelmvtt_lab2
	lda	tomtomobensprite+MSPRITEX
	cmp	tomtommaxx
	bcs	endlevelproc_lab6
	inc	tomtomobensprite+MSPRITEX
	inc	tomtomuntensprite+MSPRITEX
	jmp	tomtommove_lab24


#include "tomtommove.asm"
#include "enemy.asm"
#include "coinc.asm"
#include "utils.asm"
#include "sound.asm"
#include "wboysprites.asm"


leveldata:
; Aufbau einer Level-Datei

; 4 Pointers auf die TILESDEF-, WORLDARRAY-, GROUNDARRAY- und EVENTARRAY-Struktur (8 Bytes)
LDI_TILESDEF = 0
LDI_WORLDARRAY = 2
LDI_GROUNDARRAY = 4
LDI_EVENTARRAY = 6
;.dsb 8,0
; Beispiel
;.word	tilesdef+768
;.word	worldarray
;.word	groundarray-39
;.word	eventarray-1

; Enemy-Tabelle (Funktions-Pointer auf die Enemy-Create-Funktionen)
CREATEENEMYTABLE = leveldata+8
; Hier muss die "Feind-Tabelle" folgen

; Anschliessend folgen die weiteren Daten
