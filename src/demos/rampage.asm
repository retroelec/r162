; Kompilieren
; xa rampage.asm -o rampage

#include "6502def.inc"

georgemovedata = 10
georgemovedatatmp = georgemovedata+1
waitcounteras = georgemovedatatmp+1


* = START6502CODE

; Autostart-Programm
jmp	start
.asc	"AUTO"


loadfilestruct:
.dsb	6,0

filestruct:
.dsb	FILESTRUCTSIZE, 0

bgfname:
.asc	"/DATA/DEMO/RAMPAGE.PIC", 0

sndfname:
.asc	"/DATA/DEMO/RAMPAGE.ASD", 0

SIZEOFASD = 40516
ASDCONST = 1
LENPAUSEAS = 150


start:
	; Grafik-Modus einschalten
	lda	#<MCOLORMAPDEFAULT+768
	sta	MCOLORMAPP768
	lda	#>MCOLORMAPDEFAULT+768
	sta	MCOLORMAPP768+1
	lda	#2
	sta	VIDEOMODE

	; Lade das Hintergrund-Bild
	lda	#<filestruct
	sta	loadfilestruct+FATLOADSAVE_FILE
	lda	#>filestruct
	sta	loadfilestruct+FATLOADSAVE_FILE+1
	lda	#<bgfname
	sta	loadfilestruct+FATLOADSAVE_NAME
	lda	#>bgfname
	sta	loadfilestruct+FATLOADSAVE_NAME+1
	lda	#<MCOLORMAPDEFAULT
	sta	loadfilestruct+FATLOADSAVE_MEM
	lda	#>MCOLORMAPDEFAULT
	sta	loadfilestruct+FATLOADSAVE_MEM+1
	ldx	#<loadfilestruct
	ldy	#>loadfilestruct
	callatm	fatload6502
	lda	RERRCODE6502
	beq	lab30
	jmp	quitgame
lab30:

	; Lade Sound-Sample ins Hi-Memory
	lda	#(1<<LOWHIMEMFS)
	sta	LOWHIMEM
	lda	#<filestruct
	sta	loadfilestruct+FATLOADSAVE_FILE
	lda	#>filestruct
	sta	loadfilestruct+FATLOADSAVE_FILE+1
	lda	#<sndfname
	sta	loadfilestruct+FATLOADSAVE_NAME
	lda	#>sndfname
	sta	loadfilestruct+FATLOADSAVE_NAME+1
	lda	#<TEXTMAPDEFAULT
	sta	loadfilestruct+FATLOADSAVE_MEM
	lda	#>TEXTMAPDEFAULT
	sta	loadfilestruct+FATLOADSAVE_MEM+1
	ldx	#<loadfilestruct
	ldy	#>loadfilestruct
	callatm	fatload6502
	lda	#0
	sta	LOWHIMEM
	lda	RERRCODE6502
	beq	lab31
	jmp	quitgame
lab31:

	; Initialisiere Auto-Sound
	lda	#(1<<LOWHIMEMSOUND)
	sta	LOWHIMEM

	; Sprite anzeigen
	callatm	initlistmsprites6502
	ldx	#<georgesprite
	ldy	#>georgesprite
	callatm	addmsprite6502
	lda	#1
	sta	MINSPRITEIDTODRAW

	; Initialisierung George
	lda	#255
	sta	georgemovedata
	lda	#0
	sta	georgemovedatatmp

	jmp	main


quitgame:
	lda	#0
	sta	VIDEOMODE
	jmpsh


main:
	; Warte auf VSYNC
	lda	TIMER
lab0:
	cmp	TIMER
	beq	lab0

	lda	KEYPRESSED
	cmp	#127
	beq	quitgame

	; Spiele Sound-Sample
	lda	AUTOSND
	bne	lab32
	dec	waitcounteras
	bne	lab32
	lda	#LENPAUSEAS
	sta	waitcounteras
	lda	#<(SIZEOFASD-4)
	sta	AUTOSNDCNT
	lda	#>(SIZEOFASD-4)
	sta	AUTOSNDCNT+1
	lda	#<(TEXTMAPDEFAULT+768+4)
	sta	AUTOSNDPTRP768
	lda	#>(TEXTMAPDEFAULT+768+4)
	sta	AUTOSNDPTRP768+1
	lda	#105
	sta	SNDTCCR2
	lda	#ASDCONST
	sta	AUTOSND
	sta	AUTOSNDSYNC
lab32:

	; User-Eingabe
	lda	KEYPRARR+11
	beq	lab1
	; User will nach links
	inc	georgemovedatatmp
	lda	georgemovedatatmp
	cmp	#3
	bne	lab15
	lda	#0
	sta	georgemovedatatmp
	inc	georgemovedata
lab15:
	lda	georgemovedata
	cmp	#3
	bcc	lab13
	lda	#0
	sta	georgemovedata
lab13:
	cmp	#0
	bne	lab10
	lda	#52
	sta	georgesprite+MSPRITEW
	lda	#<georgedata_mr1
	sta	georgesprite+MSPRITEDATA
	lda	#>georgedata_mr1
	sta	georgesprite+MSPRITEDATA+1
	jmp	lab14
lab10:
	cmp	#1
	bne	lab11
	lda	#52
	sta	georgesprite+MSPRITEW
	lda	#<georgedata_mr2
	sta	georgesprite+MSPRITEDATA
	lda	#>georgedata_mr2
	sta	georgesprite+MSPRITEDATA+1
	jmp	lab14
lab11:
	lda	#50
	sta	georgesprite+MSPRITEW
	lda	#<georgedata_mr3
	sta	georgesprite+MSPRITEDATA
	lda	#>georgedata_mr3
	sta	georgesprite+MSPRITEDATA+1
lab14:
	dec	georgesprite+MSPRITEX
	jmp	lab5

lab1:
	lda	KEYPRARR+20
	beq	lab3
	; User will nach rechts
	inc	georgemovedatatmp
	lda	georgemovedatatmp
	cmp	#3
	bne	lab16
	lda	#0
	sta	georgemovedatatmp
	inc	georgemovedata
lab16:
	lda	georgemovedata
	cmp	#3
	bcc	lab23
	lda	#0
	sta	georgemovedata
lab23:
	cmp	#0
	bne	lab20
	lda	#52
	sta	georgesprite+MSPRITEW
	lda	#<georgedata_mr1
	sta	georgesprite+MSPRITEDATA
	lda	#>georgedata_mr1
	sta	georgesprite+MSPRITEDATA+1
	jmp	lab24
lab20:
	cmp	#1
	bne	lab21
	lda	#52
	sta	georgesprite+MSPRITEW
	lda	#<georgedata_mr2
	sta	georgesprite+MSPRITEDATA
	lda	#>georgedata_mr2
	sta	georgesprite+MSPRITEDATA+1
	jmp	lab24
lab21:
	lda	#50
	sta	georgesprite+MSPRITEW
	lda	#<georgedata_mr3
	sta	georgesprite+MSPRITEDATA
	lda	#>georgedata_mr3
	sta	georgesprite+MSPRITEDATA+1
lab24:
	inc	georgesprite+MSPRITEX
	jmp	lab5

lab3:
	; User bleibt stehen (bzw. links - rechts)
	lda	#42
	sta	georgesprite+MSPRITEW
	lda	#<georgedata_mr0
	sta	georgesprite+MSPRITEDATA
	lda	#>georgedata_mr0
	sta	georgesprite+MSPRITEDATA+1


	lda	KEYPRARR+18
	beq	lab2
	; User will nach unten
	inc	georgesprite+MSPRITEY
	jmp	lab5
lab2:
	lda	KEYPRARR+21
	beq	lab5
	; User will nach oben
	dec	georgesprite+MSPRITEY
lab5:
	jmp	main


memfillstructgfx:
.word	MCOLORMAPDEFAULT
.byt	80,200,255


georgesprite:
	.word	0,0 ; next,prev
	.byt	1,40,100,42,96 ; id,x,y,w,h
	.word	georgedata_mr0,georgdatabg ; data,bg
	.dsb	4,0 ; *old
	.byte	MSPRITEDELETED ; state
	.byte	15 ; weiss ist "transparent"
	; no coinc-detection

#include "rampagedata/georgesprites.data"

georgdatabg: ; (2+w)/2*h -> (2+52)/2*96
;	.dsb	2592,0
