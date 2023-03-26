; Maximaler Speed-Wert fuer Feinde:
;  - Sprite kann bis zu 2+sp Pixel pro Zyklus (1/50s) "wandern",
;    wobei sp=1 fuer snail, bee und sp=0 fuer stone, fruits
;  - Detektion fuer "ausserhalb Bildschirm" -> x > 160 && x < (256-Spritebreite)
;  -> Detektionsbereich -> 96-Spritebreite
;  -> Anzahl Zyklen fuer Detektionsbereich -> (96-Spritebreite)/(2+sp)

OBJECTSSPEED = 35
NMOBJECTSWIDTH = 12
ENEMYDIESSPEED = 1
FRUITSPEED = OBJECTSSPEED
SIGNWIDTH = 16
SIGNHEIGHT = 16
SIGNSPEED = OBJECTSSPEED
CREATEFRUITSHIFT = 4
SCOREHEIGHT=9


createenemy:
	sta	actenemyfruitid
	; Hole 2. Parameter
	inc	actspezarr1ptr
	bne	createenemy_lab13
	inc	actspezarr1ptr+1
createenemy_lab13:
	ldy	#0
	lda	(actspezarr1ptr),y
	sta	actenemyfruitparam
	; Sprite 1 frei?
	lda	enemy1+MSPRITESTATUS
	bne	createenemy_lab1
	; Ja -> Sprite erzeugen
	lda	#<enemy1
	sta	enemysprite
	lda	#>enemy1
	sta	enemysprite+1
	jsr	createenemylauncher
	ldx	#<enemy1
	ldy	#>enemy1
	callatm	addmsprite6502
	rts
createenemy_lab1:
	; Sprite 2 frei?
	lda	enemy2+MSPRITESTATUS
	bne	createenemy_lab2
	; Ja -> Sprite erzeugen
	lda	#<enemy2
	sta	enemysprite
	lda	#>enemy2
	sta	enemysprite+1
	jsr	createenemylauncher
	ldx	#<enemy2
	ldy	#>enemy2
	callatm	addmsprite6502
	rts
createenemy_lab2:
	; Sprite 3 frei?
	lda	enemy3+MSPRITESTATUS
	bne	createenemy_lab3
	; Ja -> Sprite erzeugen
	lda	#<enemy3
	sta	enemysprite
	lda	#>enemy3
	sta	enemysprite+1
	jsr	createenemylauncher
	ldx	#<enemy3
	ldy	#>enemy3
	callatm	addmsprite6502
	rts
createenemy_lab3:
	; Sprite 4 frei?
	lda	enemy4+MSPRITESTATUS
	bne	createenemy_lab4
	; Ja -> Sprite erzeugen
	lda	#<enemy4
	sta	enemysprite
	lda	#>enemy4
	sta	enemysprite+1
	jsr	createenemylauncher
	ldx	#<enemy4
	ldy	#>enemy4
	callatm	addmsprite6502
	rts
createenemy_lab4:
	; Sprite 5 frei?
	lda	enemy5+MSPRITESTATUS
	bne	createenemy_lab5
	; Ja -> Sprite erzeugen
	lda	#<enemy5
	sta	enemysprite
	lda	#>enemy5
	sta	enemysprite+1
	jsr	createenemylauncher
	ldx	#<enemy5
	ldy	#>enemy5
	callatm	addmsprite6502
	rts
createenemy_lab5:
	; Sprite 6 frei?
	lda	enemy6+MSPRITESTATUS
	bne	createenemy_lab6
	; Ja -> Sprite erzeugen
	lda	#<enemy6
	sta	enemysprite
	lda	#>enemy6
	sta	enemysprite+1
	jsr	createenemylauncher
	ldx	#<enemy6
	ldy	#>enemy6
	callatm	addmsprite6502
	rts
createenemy_lab6:
	; Sprite 7 frei?
	lda	enemy7+MSPRITESTATUS
	bne	createenemy_lab7
	; Ja -> Sprite erzeugen
	lda	#<enemy7
	sta	enemysprite
	lda	#>enemy7
	sta	enemysprite+1
	jsr	createenemylauncher
	ldx	#<enemy7
	ldy	#>enemy7
	callatm	addmsprite6502
	rts
createenemy_lab7:
	; Sprite 8 frei?
	lda	enemy8+MSPRITESTATUS
	bne	createenemy_lab8
	; Ja -> Sprite erzeugen
	lda	#<enemy8
	sta	enemysprite
	lda	#>enemy8
	sta	enemysprite+1
	jsr	createenemylauncher
	ldx	#<enemy8
	ldy	#>enemy8
	callatm	addmsprite6502
	rts
createenemy_lab8:
	; Sprite 9 frei?
	lda	enemy9+MSPRITESTATUS
	bne	createenemy_lab9
	; Ja -> Sprite erzeugen
	lda	#<enemy9
	sta	enemysprite
	lda	#>enemy9
	sta	enemysprite+1
	jsr	createenemylauncher
	ldx	#<enemy9
	ldy	#>enemy9
	callatm	addmsprite6502
	rts
createenemy_lab9:
	; Sprite 10 frei?
	lda	enemy10+MSPRITESTATUS
	bne	createenemy_lab10
	; Ja -> Sprite erzeugen
	lda	#<enemy10
	sta	enemysprite
	lda	#>enemy10
	sta	enemysprite+1
	jsr	createenemylauncher
	ldx	#<enemy10
	ldy	#>enemy10
	callatm	addmsprite6502
	rts
createenemy_lab10:
	; Sprite 11 frei?
	lda	enemy11+MSPRITESTATUS
	bne	createenemy_lab11
	; Ja -> Sprite erzeugen
	lda	#<enemy11
	sta	enemysprite
	lda	#>enemy11
	sta	enemysprite+1
	jsr	createenemylauncher
	ldx	#<enemy11
	ldy	#>enemy11
	callatm	addmsprite6502
	rts
createenemy_lab11:
	; Sprite 12 frei?
	lda	enemy12+MSPRITESTATUS
	bne	createenemy_lab12
	; Ja -> Sprite erzeugen
	lda	#<enemy12
	sta	enemysprite
	lda	#>enemy12
	sta	enemysprite+1
	jsr	createenemylauncher
	ldx	#<enemy12
	ldy	#>enemy12
	callatm	addmsprite6502
	; Keine Sprites mehr frei
createenemy_lab12:
	rts


createenemylauncher:
	; Feind-Typ (Schnecke, Biene, etc.) in actenemyfruitid
	dec	actenemyfruitid
	lda	actenemyfruitid
	asl
	tax
	lda	CREATEENEMYTABLE+1,x
	pha
	lda	CREATEENEMYTABLE,x
	pha
	rts


cfmemcopystruct:
.dsb	6,0

createfactory:
	; Kopiere x,y,w,h,data
	lda	enemysprite
	clc
	adc	#5
	sta	cfmemcopystruct+MEMCOPY6502_DEST
	lda	enemysprite+1
	adc	#0
	sta	cfmemcopystruct+MEMCOPY6502_DEST+1
	lda	#6
	sta	cfmemcopystruct+MEMCOPY6502_N
	lda	#0
	sta	cfmemcopystruct+MEMCOPY6502_N+1
	ldx	#<cfmemcopystruct
	ldy	#>cfmemcopystruct
	callatm	memcopy6502
	; Kopiere coincredleft,coincredright,coincredup,coincreddown,
	;         collisiondetectflag, ext1-ext12
	lda	cfmemcopystruct+MEMCOPY6502_SRC
	clc
	adc	#6
	sta	cfmemcopystruct+MEMCOPY6502_SRC
	lda	cfmemcopystruct+MEMCOPY6502_SRC+1
	adc	#0
	sta	cfmemcopystruct+MEMCOPY6502_SRC+1
createfactory_lab0:
	lda	enemysprite
	clc
	adc	#19
	sta	cfmemcopystruct+MEMCOPY6502_DEST
	lda	enemysprite+1
	adc	#0
	sta	cfmemcopystruct+MEMCOPY6502_DEST+1
	lda	#SIZEOFCF2COPY
	sta	cfmemcopystruct+MEMCOPY6502_N
	ldx	#<cfmemcopystruct
	ldy	#>cfmemcopystruct
	callatm	memcopy6502
	rts


moveenemies:
	; Feind-Sprite aktiv?
	lda	enemy1+MSPRITESTATUS
	beq	moveenemies_lab1
	; Feind-Sprite bewegen?
	dec	enemy1+MSPRITEENEMYMOVECNT
	bne	moveenemies_lab1
	lda	#<enemy1
	sta	enemysprite
	lda	#>enemy1
	sta	enemysprite+1
	lda	enemy1+MSPRITEENEMYSPEED
	sta	enemy1+MSPRITEENEMYMOVECNT
	jsr	subenemymove
moveenemies_lab1:

	; Feind-Sprite aktiv?
	lda	enemy2+MSPRITESTATUS
	beq	moveenemies_lab2
	; Feind-Sprite bewegen?
	dec	enemy2+MSPRITEENEMYMOVECNT
	bne	moveenemies_lab2
	lda	#<enemy2
	sta	enemysprite
	lda	#>enemy2
	sta	enemysprite+1
	lda	enemy2+MSPRITEENEMYSPEED
	sta	enemy2+MSPRITEENEMYMOVECNT
	jsr	subenemymove
moveenemies_lab2:

	; Feind-Sprite aktiv?
	lda	enemy3+MSPRITESTATUS
	beq	moveenemies_lab3
	; Feind-Sprite bewegen?
	dec	enemy3+MSPRITEENEMYMOVECNT
	bne	moveenemies_lab3
	lda	#<enemy3
	sta	enemysprite
	lda	#>enemy3
	sta	enemysprite+1
	lda	enemy3+MSPRITEENEMYSPEED
	sta	enemy3+MSPRITEENEMYMOVECNT
	jsr	subenemymove
moveenemies_lab3:

	; Feind-Sprite aktiv?
	lda	enemy4+MSPRITESTATUS
	beq	moveenemies_lab4
	; Feind-Sprite bewegen?
	dec	enemy4+MSPRITEENEMYMOVECNT
	bne	moveenemies_lab4
	lda	#<enemy4
	sta	enemysprite
	lda	#>enemy4
	sta	enemysprite+1
	lda	enemy4+MSPRITEENEMYSPEED
	sta	enemy4+MSPRITEENEMYMOVECNT
	jsr	subenemymove
moveenemies_lab4:

	; Feind-Sprite aktiv?
	lda	enemy5+MSPRITESTATUS
	beq	moveenemies_lab5
	; Feind-Sprite bewegen?
	dec	enemy5+MSPRITEENEMYMOVECNT
	bne	moveenemies_lab5
	lda	#<enemy5
	sta	enemysprite
	lda	#>enemy5
	sta	enemysprite+1
	lda	enemy5+MSPRITEENEMYSPEED
	sta	enemy5+MSPRITEENEMYMOVECNT
	jsr	subenemymove
moveenemies_lab5:

	; Feind-Sprite aktiv?
	lda	enemy6+MSPRITESTATUS
	beq	moveenemies_lab6
	; Feind-Sprite bewegen?
	dec	enemy6+MSPRITEENEMYMOVECNT
	bne	moveenemies_lab6
	lda	#<enemy6
	sta	enemysprite
	lda	#>enemy6
	sta	enemysprite+1
	lda	enemy6+MSPRITEENEMYSPEED
	sta	enemy6+MSPRITEENEMYMOVECNT
	jsr	subenemymove
moveenemies_lab6:

	; Feind-Sprite aktiv?
	lda	enemy7+MSPRITESTATUS
	beq	moveenemies_lab7
	; Feind-Sprite bewegen?
	dec	enemy7+MSPRITEENEMYMOVECNT
	bne	moveenemies_lab7
	lda	#<enemy7
	sta	enemysprite
	lda	#>enemy7
	sta	enemysprite+1
	lda	enemy7+MSPRITEENEMYSPEED
	sta	enemy7+MSPRITEENEMYMOVECNT
	jsr	subenemymove
moveenemies_lab7:

	; Feind-Sprite aktiv?
	lda	enemy8+MSPRITESTATUS
	beq	moveenemies_lab8
	; Feind-Sprite bewegen?
	dec	enemy8+MSPRITEENEMYMOVECNT
	bne	moveenemies_lab8
	lda	#<enemy8
	sta	enemysprite
	lda	#>enemy8
	sta	enemysprite+1
	lda	enemy8+MSPRITEENEMYSPEED
	sta	enemy8+MSPRITEENEMYMOVECNT
	jsr	subenemymove
moveenemies_lab8:

	; Feind-Sprite aktiv?
	lda	enemy9+MSPRITESTATUS
	beq	moveenemies_lab9
	; Feind-Sprite bewegen?
	dec	enemy9+MSPRITEENEMYMOVECNT
	bne	moveenemies_lab9
	lda	#<enemy9
	sta	enemysprite
	lda	#>enemy9
	sta	enemysprite+1
	lda	enemy9+MSPRITEENEMYSPEED
	sta	enemy9+MSPRITEENEMYMOVECNT
	jsr	subenemymove
moveenemies_lab9:

	; Feind-Sprite aktiv?
	lda	enemy10+MSPRITESTATUS
	beq	moveenemies_lab10
	; Feind-Sprite bewegen?
	dec	enemy10+MSPRITEENEMYMOVECNT
	bne	moveenemies_lab10
	lda	#<enemy10
	sta	enemysprite
	lda	#>enemy10
	sta	enemysprite+1
	lda	enemy10+MSPRITEENEMYSPEED
	sta	enemy10+MSPRITEENEMYMOVECNT
	jsr	subenemymove
moveenemies_lab10:

	; Feind-Sprite aktiv?
	lda	enemy11+MSPRITESTATUS
	beq	moveenemies_lab11
	; Feind-Sprite bewegen?
	dec	enemy11+MSPRITEENEMYMOVECNT
	bne	moveenemies_lab11
	lda	#<enemy11
	sta	enemysprite
	lda	#>enemy11
	sta	enemysprite+1
	lda	enemy11+MSPRITEENEMYSPEED
	sta	enemy11+MSPRITEENEMYMOVECNT
	jsr	subenemymove
moveenemies_lab11:

	; Feind-Sprite aktiv?
	lda	enemy12+MSPRITESTATUS
	beq	moveenemies_lab12
	; Feind-Sprite bewegen?
	dec	enemy12+MSPRITEENEMYMOVECNT
	bne	moveenemies_lab12
	lda	#<enemy12
	sta	enemysprite
	lda	#>enemy12
	sta	enemysprite+1
	lda	enemy12+MSPRITEENEMYSPEED
	sta	enemy12+MSPRITEENEMYMOVECNT
	jsr	subenemymove
moveenemies_lab12:
	rts


subenemymove:
	ldy	#MSPRITEENEMYMOVE
	lda	(enemysprite),y
	sta	actenemymove
	iny
	lda	(enemysprite),y
	sta	actenemymove+1
	jmp	(actenemymove)


enemykcoincfunc:
	; Wird schon ein Sound Sample gespielt?
	lda	soundeffectflag
	bne	enemykcoincfunc_lab1
	; Vorbereitung Sample
	lda	#<(SNDENEMYDIESFSIZE-4)
	sta	tmpautosndcnt
	lda	#>(SNDENEMYDIESFSIZE-4)
	sta	tmpautosndcnt+1
	lda	#<(SNDENEMYDIESFMEM+768+4)
	sta	tmpautosndptr
	lda	#>(SNDENEMYDIESFMEM+768+4)
	sta	tmpautosndptr+1
	lda	#WBOYSAMPLESCONST1
	sta	tmpautosndsync
	lda	#1
	sta	newsoundeffectflag
enemykcoincfunc_lab1:
	; Punkte anpassen
	clc
	ldy	#MSPRITEENEMYSCORE
	lda	(actcoincsprite),y
	adc	score
	sta	score
	bcc	enemykcoincfunc_lab2
	inc	score+1
enemykcoincfunc_lab2:
	jsr	updatescore
	; Pointer auf die aktuelle enemy-Sprite-Struktur in actcoincsprite
	; Feind stirbt
	ldy	#MSPRITEENEMYMVTABIDX
	lda	#0
	sta	(actcoincsprite),y
	ldy	#MSPRITEENEMYISDYING
	lda	#1
	sta	(actcoincsprite),y
	; "schneller Tod"
	ldy	#MSPRITEENEMYSPEED
	lda	#ENEMYDIESSPEED
	sta	(actcoincsprite),y
	ldy	#MSPRITEENEMYMOVECNT
	sta	(actcoincsprite),y
	lda	#1
	rts


; deltax, deltay, deltax, deltay, ...
enemytype1dyingtableright:
	.byt	2,254,2,254,2,254,2,254,2,254,1,2,1,2,1,2,1,2,1,2,128,128
enemytype1dyingtableleft:
	.byt	254,254,254,254,254,254,254,254,254,254,255,2,255,2,255,2,255,2,255,2,128,128

enemytype1dying:
	; Sterben von Typ1-Feinden (Schnecke, Schlange, ...)
	ldy	#MSPRITEENEMYSHOTDIR
	lda	(enemysprite),y
	bmi	enemytype1dying_lab1
	; Feind wird nach rechts geschleudert
	ldy	#MSPRITEENEMYMVTABIDX
	lda	(enemysprite),y
	tay
	lda	enemytype1dyingtableright,y
	sta	enemydyingmovetemp1
	lda	enemytype1dyingtableright+1,y
	jmp	enemydyingmove
enemytype1dying_lab1:
	; Typ1-Feind wird nach links geschleudert
	ldy	#MSPRITEENEMYMVTABIDX
	lda	(enemysprite),y
	tay
	lda	enemytype1dyingtableleft,y
	sta	enemydyingmovetemp1
	lda	enemytype1dyingtableleft+1,y


enemydyingmove:
	; a-Register -> deltaY-Wert aus der Enemy-Dying-Tabelle
	; y-Register -> Index in der Enemy-Dying-Tabelle
	; enemydyingmovetemp1 -> deltaX aus der Enemy-Dying-Tabelle
	sta	enemydyingmovetemp2
	cmp	#128
	bne	enemydyingmove_lab4
	lda	#0
	sta	enemydyingmovetemp1
	lda	#FALLDOWNSPEED
	sta	enemydyingmovetemp2
	; jump always
	bne	enemydyingmove_lab1
enemydyingmove_lab4:
	iny
	iny
enemydyingmove_lab1:
	tya
	ldy	#MSPRITEENEMYMVTABIDX
	sta	(enemysprite),y
	ldy	#MSPRITEX
	lda	(enemysprite),y
	clc
	adc	enemydyingmovetemp1
	sta	(enemysprite),y
	jsr	getyfromx_lab0
	sta	enemydyingmovetemp1
	ldy	#MSPRITEY
	lda	(enemysprite),y
	clc
	adc	enemydyingmovetemp2
	cmp	enemydyingmovetemp1
	bcs	enemydyingmove_lab5
	sta	(enemysprite),y
	rts
enemydyingmove_lab5:
	ldx	enemysprite
	ldy	enemysprite+1
	callatm	delmsprite6502
	rts


commonfruitinstance:
	.byt	0,0,0,0 ; coincredleft,coincredright,coincredup,coincreddown
	.byt	0 ; Kollisions-Detektionen aktiv
	.word	fruitcoincfunc ; ext1, MSPRITEENEMYCOINCFUNC
	.word	fruitkcoincfunc ; ext2, MSPRITEENEMYKCOINCFUNC
	.word	movefruit ; ext3, MSPRITEENEMYMOVE
	.byt	0 ; ext4, MSPRITEENEMYISDYING
	.byt	FRUITSPEED ; ext5, MSPRITEENEMYSPEED
	.byt	FRUITSPEED ; ext6, MSPRITEENEMYMOVECNT
	.byt	0 ; ext7, MSPRITEENEMYSHOTDIR, MSPRITEFRUITSCOREWIDTH
	.byt	5 ; ext8, MSPRITEFRUITTIMER
	.byt	0 ; ext9, MSPRITEFRUITTIMER2
	.byt	0 ; ext10, MSPRITEFRUITSCORE
	.word	0 ; ext11+ext12, MSPRITEFRUITSCOREDATA

commoncreatefruit:
	ldy	#MSPRITEX
	lda	#EVENTSTARTX-CREATEFRUITSHIFT*8
	sta	(enemysprite),y
	lda	#<commonfruitinstance
	sta	cfmemcopystruct+MEMCOPY6502_SRC
	lda	#>commonfruitinstance
	sta	cfmemcopystruct+MEMCOPY6502_SRC+1
	jmp	createfactory_lab0

movefruit:
	; Test auf "ausserhalb" Bildschirm
	jsr	test4outofscreen2
	; Wurde Frucht bereits gegessen oder ist sie am Verschwinden?
	ldy	#MSPRITEENEMYISDYING
	lda	(enemysprite),y
	bne	movefruit_lab5
	; Zeit der Frucht abgelaufen?
	ldy	#MSPRITEFRUITTIMER
	lda	(enemysprite),y
	sec
	sbc	#1
	beq	movefruit_lab4
	sta	(enemysprite),y
	rts
movefruit_lab5:
	; Zeit der gegessenen Frucht abgelaufen?
	ldy	#MSPRITEFRUITTIMER2
	lda	(enemysprite),y
	sec
	sbc	#1
	bne	movefruit_lab2
	jmp	deleteactenemy
movefruit_lab2:
	sta	(enemysprite),y
	rts
movefruit_lab4:
	ldy	#MSPRITEENEMYISDYING
	lda	#1
	sta	(enemysprite),y
	ldy	#MSPRITEFRUITTIMER2
	lda	#1
	sta	(enemysprite),y
	ldy	#MSPRITEW
	lda	#FRUITDISAPPEARSWIDTH
	sta	(enemysprite),y
	ldy	#MSPRITEH
	lda	#FRUITDISAPPEARSHEIGHT
	sta	(enemysprite),y
	ldy	#MSPRITEDATA
	lda	#<fruitdisappears
	sta	(enemysprite),y
	iny
	lda	#>fruitdisappears
	sta	(enemysprite),y
	rts

fruitcoincfunc:
	; Pointer auf die aktuelle enemy-Sprite-Struktur in actcoincsprite
	; Frucht wurde gegessen
	ldy	#MSPRITEENEMYISDYING
	lda	#1
	sta	(actcoincsprite),y
	; Breite der Score-Daten (dynamisch)
	ldy	#MSPRITEFRUITSCOREWIDTH
	lda	(actcoincsprite),y
	ldy	#MSPRITEW
	sta	(actcoincsprite),y
	; Hoehe der Score-Daten (fix)
	ldy	#MSPRITEH
	lda	#SCOREHEIGHT
	sta	(actcoincsprite),y
	; Score-Daten
	ldy	#MSPRITEFRUITSCOREDATA
	lda	(actcoincsprite),y
	ldy	#MSPRITEDATA
	sta	(actcoincsprite),y
	ldy	#MSPRITEFRUITSCOREDATA+1
	lda	(actcoincsprite),y
	ldy	#MSPRITEDATA+1
	sta	(actcoincsprite),y
	; Setze Timer2 (Achtung -> MSPRITEFRUITTIMER2 == MSPRITEFRUITSCOREWIDTH)
	ldy	#MSPRITEFRUITTIMER2
	lda	#2
	sta	(actcoincsprite),y
	; Spiele Sample
	lda	soundeffectflag
	bne	fruitcoincfunc_lab2
	; Vorbereitung Sample
	lda	#<(SNDEATFRUITFSIZE-4)
	sta	tmpautosndcnt
	lda	#>(SNDEATFRUITFSIZE-4)
	sta	tmpautosndcnt+1
	lda	#<(SNDEATFRUITFMEM+768+4)
	sta	tmpautosndptr
	lda	#>(SNDEATFRUITFMEM+768+4)
	sta	tmpautosndptr+1
	lda	#WBOYSAMPLESCONST1
	sta	tmpautosndsync
	lda	#1
	sta	newsoundeffectflag
fruitcoincfunc_lab2:
	; Energie anpassen
	lda	energycounter
	sta	energycounterold
	clc
	adc	#3
	sta	energycounter
	jsr	adaptenergybar
	; Punkte anpassen
	clc
	ldy	#MSPRITEFRUITSCORE
	lda	(actcoincsprite),y
	adc	score
	sta	score
	bcc	fruitcoincfunc_lab1
	inc	score+1
fruitcoincfunc_lab1:
	jmp	updatescore

fruitkcoincfunc:
	lda	#0
	rts

stonekcoincfunc:
	; Pointer auf die aktuelle enemy-Sprite-Struktur in actcoincsprite
	lda	#1
	rts


commonsigninstance:
	.byt	EVENTSTARTX,0,SIGNWIDTH,SIGNHEIGHT ; x,y,w,h
	.word	0 ; data
	.byt	0,0,0,0 ; coincredleft,coincredright,coincredup,coincreddown
	.byt	0 ; Kollisions-Detektionen aktiv
	.word	fruitkcoincfunc ; ext1, MSPRITEENEMYCOINCFUNC
	.word	fruitkcoincfunc ; ext2, MSPRITEENEMYKCOINCFUNC
	.word	test4outofscreen ; ext3, MSPRITEENEMYMOVE
	.byt	0 ; ext4, MSPRITEENEMYISDYING
	.byt	SIGNSPEED ; ext5, MSPRITEENEMYSPEED
	.byt	SIGNSPEED ; ext6, MSPRITEENEMYMOVECNT
	.byt	0 ; ext7, MSPRITEENEMYSHOTDIR
	.byt	0 ; ext8, not used
	.byt	0 ; ext9, not used
	.byt	0 ; ext10, not used
	.byt	0 ; ext11, not used
	.byt	0 ; ext12, not used

commoncreatesign:
	lda	#1
	sta	flagsaveintermedgoal
commoncreatesign_lab0:
	lda	#<commonsigninstance
	sta	cfmemcopystruct+MEMCOPY6502_SRC
	lda	#>commonsigninstance
	sta	cfmemcopystruct+MEMCOPY6502_SRC+1
	jsr	createfactory
	ldy	#MSPRITEY
	lda	actenemyfruitparam
	sec
	sbc	#SIGNHEIGHT-8
	sta	(enemysprite),y
	rts

createsignstart:
	jsr	commoncreatesign_lab0
	ldy	#MSPRITEDATA
	lda	#<signstart
	sta	(enemysprite),y
	iny
	lda	#>signstart
	sta	(enemysprite),y
	rts

createsign2:
	jsr	commoncreatesign
	ldy	#MSPRITEDATA
	lda	#<sign2
	sta	(enemysprite),y
	iny
	lda	#>sign2
	sta	(enemysprite),y
	rts

createsign3:
	jsr	commoncreatesign
	ldy	#MSPRITEDATA
	lda	#<sign3
	sta	(enemysprite),y
	iny
	lda	#>sign3
	sta	(enemysprite),y
	rts

createsign4:
	jsr	commoncreatesign
	ldy	#MSPRITEDATA
	lda	#<sign4
	sta	(enemysprite),y
	iny
	lda	#>sign4
	sta	(enemysprite),y
	rts

createsigngoal:
	jsr	commoncreatesign_lab0
	ldy	#MSPRITEDATA
	lda	#<signgoal
	sta	(enemysprite),y
	iny
	lda	#>signgoal
	sta	(enemysprite),y
	rts


test4outofscreen:
	ldy	#MSPRITEW
	lda	(enemysprite),y
	eor	#255
	sta	moveenemytemp1
	ldy	#MSPRITEX
	lda	(enemysprite),y
	cmp	#EVENTSTARTX+1
	bcc	test4outofscreen_lab1
	cmp	moveenemytemp1
	bcs	test4outofscreen_lab1
deleteactenemy:
	ldx	enemysprite
	ldy	enemysprite+1
	callatm	delmsprite6502
test4outofscreen_lab1:
	rts

test4outofscreen2:
	ldy	#MSPRITEW
	lda	(enemysprite),y
	eor	#255
	sta	moveenemytemp1
	ldy	#MSPRITEX
	lda	(enemysprite),y
	cmp	#EVENTSTARTX+1
	bcc	test4outofscreen2_lab1
	cmp	moveenemytemp1
	bcs	test4outofscreen2_lab1
	ldx	enemysprite
	ldy	enemysprite+1
	callatm	delmsprite6502
	pla
	pla
test4outofscreen2_lab1:
	rts


setyoftomtomsprite:
	sec
	sbc	#TOMTOMUPPERH+TOMTOMLOWERH
	sta	tomtomobensprite+MSPRITEY
	clc
	adc	#TOMTOMUPPERH
	sta	tomtomuntensprite+MSPRITEY
	rts
