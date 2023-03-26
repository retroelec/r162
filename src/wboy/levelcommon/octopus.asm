WATERSURFACE = GROUND-4*8
OCTOPUSSTARTY = WATERSURFACE
OCTOPUSMINY = MSPRITEENEMYSPEZ1
OCTOPUSMVDIR = MSPRITEENEMYSPEZ2

octopusinstance:
	.byt	EVENTSTARTX,OCTOPUSSTARTY,OCTOPUS2WIDTH,OCTOPUS2HEIGHT ; x,y,w,h
	.word	octopus2 ; data
	.byt	1,1,2,2 ; coincredleft,coincredright,coincredup,coincreddown
	.byt	0 ; Kollisions-Detektionen aktiv
	.word	tomtomdiesinit ; ext1, MSPRITEENEMYCOINCFUNC
	.word	enemykcoincfunc ; ext2, MSPRITEENEMYKCOINCFUNC
	.word	moveoctopus ; ext3, MSPRITEENEMYMOVE
	.byt	0 ; ext4, MSPRITEENEMYISDYING
	.byt	OCTOPUSSPEED ; ext5, MSPRITEENEMYSPEED
	.byt	OCTOPUSSPEED ; ext6, MSPRITEENEMYMOVECNT
	.byt	0 ; ext7, MSPRITEENEMYSHOTDIR
	.byt	0 ; ext8, MSPRITEENEMYMVTABIDX (0 = "Free-Fall-Modus")
	.byt	15 ; ext9, MSPRITEENEMYSCORE
	.byt	0 ; ext10, MSPRITEENEMYANIMLOOK
	.byt	0 ; ext11, OCTOPUSMINY
	.byt	0 ; ext12, OCTOPUSMVDIR (0 = nach oben)

createoctopus:
	; Tintenfisch erzeugen
	lda	#<octopusinstance
	sta	cfmemcopystruct+MEMCOPY6502_SRC
	lda	#>octopusinstance
	sta	cfmemcopystruct+MEMCOPY6502_SRC+1
	jsr	createfactory
	ldy	#OCTOPUSMINY
	sec
	sbc	#OCTOPUSTABLEMODEDELTAY
	lda	actenemyfruitparam
	sta	(enemysprite),y
	rts

moveoctopustable:
	.byt	0,253,253,254,254,0,2,2,3,3,128
OCTOPUSTABLEMODEDELTAY = 15

moveoctopus:
	; Test auf "ausserhalb" Bildschirm
	jsr	test4outofscreen2
	ldy	#MSPRITEENEMYISDYING
	lda	(enemysprite),y
	beq	moveoctopus_lab5
	ldy	#MSPRITEY
	lda	(enemysprite),y
	clc
	adc	#5
	cmp	#WATERSURFACE
	bcc	moveoctopus_lab6
	jmp	deleteactenemy
moveoctopus_lab6:
	sta	(enemysprite),y
	rts
moveoctopus_lab5:
	; "Table-Modus" oder "Free-Fall-Modus"?
	ldy	#MSPRITEENEMYMVTABIDX
	lda	(enemysprite),y
	beq	moveoctopus_lab10
	; "Table-Modus"
	tay
moveoctopus_lab12:
	lda	moveoctopustable,y
	cmp	#128
	bne	moveoctopus_lab11
	; Wechsel auf "Free-Fall-Modus"
	ldy	#MSPRITEENEMYMVTABIDX
	lda	#0
	sta	(enemysprite),y
	; jump always
	beq	moveoctopus_lab10
moveoctopus_lab11:
	sta	moveenemytemp1
	iny
	tya
	ldy	#MSPRITEENEMYMVTABIDX
	sta	(enemysprite),y
	ldy	#MSPRITEY
	lda	(enemysprite),y
	clc
	adc	moveenemytemp1
	sta	(enemysprite),y
	rts
moveoctopus_lab10:
	; "Free-Fall-Modus"
	ldy	#OCTOPUSMVDIR
	lda	(enemysprite),y
	bne	moveoctopus_lab1
	; Bewegung nach oben
	ldy	#MSPRITEY
	lda	(enemysprite),y
	sec
	sbc	#5
	sta	(enemysprite),y
	sta	moveenemytemp1
	ldy	#OCTOPUSMINY
	lda	(enemysprite),y
	cmp	moveenemytemp1
	bcs	moveoctopus_lab7
	rts
moveoctopus_lab7:
	; Wechsel auf "Table-Modus" + Richtungsaenderung fuer "Falldown"
	ldy	#OCTOPUSMVDIR
	sta	(enemysprite),y
	ldy	#MSPRITEENEMYMVTABIDX
	lda	#1
	sta	(enemysprite),y
	rts
moveoctopus_lab1:
	; Bewegung nach unten
	ldy	#MSPRITEY
	lda	(enemysprite),y
	clc
	adc	#5
	cmp	#OCTOPUSSTARTY
	bcc	moveoctopus_lab4
	; Richtungsaenderung -> nach oben
	ldy	#MSPRITEH
	lda	#OCTOPUS2HEIGHT
	sta	(enemysprite),y
	ldy	#MSPRITEW
	lda	#OCTOPUS2WIDTH
	sta	(enemysprite),y
	ldy	#MSPRITEDATA
	lda	#<octopus2
	sta	(enemysprite),y
	ldy	#MSPRITEDATA+1
	lda	#>octopus2
	sta	(enemysprite),y
	ldy	#OCTOPUSMVDIR
	lda	#0
	sta	(enemysprite),y
	rts
moveoctopus_lab4:
	sta	(enemysprite),y
	; Animation des Tintenfischs beim Runterfallen
	ldy	#MSPRITEENEMYANIMLOOK
	lda	(enemysprite),y
	eor	#1
	sta	(enemysprite),y
	beq	moveoctopus_lab3
	ldy	#MSPRITEH
	lda	#OCTOPUS1HEIGHT
	sta	(enemysprite),y
	ldy	#MSPRITEW
	lda	#OCTOPUS1WIDTH
	sta	(enemysprite),y
	ldy	#MSPRITEDATA
	lda	#<octopus1
	sta	(enemysprite),y
	ldy	#MSPRITEDATA+1
	lda	#>octopus1
	sta	(enemysprite),y
moveoctopus_lab8:
	rts
moveoctopus_lab3:
	ldy	#MSPRITEH
	lda	#OCTOPUS3HEIGHT
	sta	(enemysprite),y
	ldy	#MSPRITEW
	lda	#OCTOPUS3WIDTH
	sta	(enemysprite),y
	ldy	#MSPRITEDATA
	lda	#<octopus3
	sta	(enemysprite),y
	ldy	#MSPRITEDATA+1
	lda	#>octopus3
	sta	(enemysprite),y
	rts

octopus1:
; octopus1sprite.ppm (14x21)
.byt 238, 238, 238, 225, 30, 238, 238, 238 
.byt 238, 225, 17, 17, 94, 238, 238, 238 
.byt 17, 17, 21, 94, 238, 238, 238, 17 
.byt 17, 21, 190, 238, 238, 238, 17, 85 
.byt 17, 81, 238, 238, 235, 187, 255, 81 
.byt 17, 238, 238, 239, 255, 255, 81, 17 
.byt 238, 238, 224, 176, 255, 81, 17, 238 
.byt 238, 81, 91, 251, 17, 17, 238, 225 
.byt 17, 17, 17, 17, 30, 238, 225, 17 
.byt 17, 17, 17, 30, 238, 229, 17, 17 
.byt 17, 17, 94, 30, 229, 225, 17, 17 
.byt 17, 229, 30, 225, 238, 17, 17, 21 
.byt 225, 30, 225, 30, 17, 17, 30, 81 
.byt 238, 225, 17, 17, 17, 17, 17, 30 
.byt 238, 17, 17, 17, 17, 17, 17, 238 
.byt 17, 17, 17, 17, 17, 78, 21, 20 
.byt 17, 17, 17, 30, 238, 17, 30, 81 
.byt 17, 17, 30, 238, 238, 238, 30, 238 
.byt 30, 30, 238
OCTOPUS1WIDTH = 14
OCTOPUS1HEIGHT = 21

octopus2:
; octopus2sprite.ppm (10x25)
.byt 238, 238, 225, 21, 238, 238, 238, 17 
.byt 17, 94, 238, 225, 17, 21, 94, 238 
.byt 225, 17, 17, 181, 238, 113, 91, 17 
.byt 81, 238, 5, 15, 177, 17, 238, 255 
.byt 255, 177, 17, 238, 255, 255, 177, 17 
.byt 225, 21, 255, 81, 17, 17, 17, 17 
.byt 17, 30, 17, 17, 17, 17, 30, 229 
.byt 17, 17, 17, 94, 238, 225, 17, 17 
.byt 238, 238, 225, 17, 21, 238, 238, 225 
.byt 17, 30, 238, 238, 81, 17, 17, 238 
.byt 238, 17, 17, 17, 238, 238, 17, 17 
.byt 17, 238, 229, 17, 17, 17, 238, 238 
.byt 225, 17, 17, 94, 238, 81, 17, 17 
.byt 238, 238, 225, 17, 30, 238, 238, 225 
.byt 17, 30, 238, 238, 238, 21, 94, 238 
.byt 238, 238, 94, 238, 238
OCTOPUS2WIDTH = 10
OCTOPUS2HEIGHT = 25

octopus3:
; octopus3sprite.ppm (12x22)
.byt 238, 238, 225, 17, 238, 238, 238, 238 
.byt 17, 17, 30, 238, 238, 225, 17, 17 
.byt 85, 238, 238, 225, 17, 17, 85, 238 
.byt 238, 229, 91, 81, 17, 94, 238, 255 
.byt 255, 245, 17, 94, 238, 240, 240, 245 
.byt 17, 94, 238, 255, 255, 245, 17, 94 
.byt 225, 17, 255, 241, 17, 94, 17, 17 
.byt 17, 17, 17, 238, 81, 17, 17, 17 
.byt 21, 238, 229, 17, 17, 17, 30, 238 
.byt 238, 225, 17, 17, 94, 238, 238, 228 
.byt 17, 17, 238, 238, 238, 225, 17, 17 
.byt 94, 238, 238, 17, 17, 17, 30, 238 
.byt 238, 17, 17, 17, 17, 238, 229, 17 
.byt 17, 17, 17, 30, 229, 17, 17, 17 
.byt 20, 17, 225, 17, 17, 17, 65, 94 
.byt 229, 85, 238, 84, 17, 238, 238, 238 
.byt 238, 94, 30, 238
OCTOPUS3WIDTH = 12
OCTOPUS3HEIGHT = 22
OCTOPUSSPEED = 2
