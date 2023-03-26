fishinstance:
	.byt	EVENTSTARTX,0,FISH1WIDTH,FISH1HEIGHT ; x,y,w,h
	.word	fish1 ; data
	.byt	1,1,2,2 ; coincredleft,coincredright,coincredup,coincreddown
	.byt	0 ; Kollisions-Detektionen aktiv
	.word	tomtomdiesinit ; ext1, MSPRITEENEMYCOINCFUNC
	.word	enemykcoincfunc ; ext2, MSPRITEENEMYKCOINCFUNC
	.word	movefish ; ext3, MSPRITEENEMYMOVE
	.byt	0 ; ext4, MSPRITEENEMYISDYING
	.byt	FISHSPEED ; ext5, MSPRITEENEMYSPEED
	.byt	FISHSPEED ; ext6, MSPRITEENEMYMOVECNT
	.byt	0 ; ext7, MSPRITEENEMYSHOTDIR
	.byt	0 ; ext8, MSPRITEENEMYMVTABIDX
	.byt	10 ; ext9, MSPRITEENEMYSCORE
	.byt	0 ; ext10, MSPRITEENEMYANIMLOOK
	.byt	0 ; ext11, not used
	.byt	0 ; ext12, not used

createfish:
	; Fisch erzeugen
	lda	#<fishinstance
	sta	cfmemcopystruct+MEMCOPY6502_SRC
	lda	#>fishinstance
	sta	cfmemcopystruct+MEMCOPY6502_SRC+1
	jsr	createfactory
	ldy	#MSPRITEY
	lda	actenemyfruitparam
	sta	(enemysprite),y
	rts

movefishtable:
	.byt	254,254,252,252,249,249,249,252,252,254,254,0,0,2,2,4,4,7,7,7,4,4,2,2,128

movefish:
	; Test auf "ausserhalb" Bildschirm
	jsr	test4outofscreen2
	ldy	#MSPRITEENEMYISDYING
	lda	(enemysprite),y
	beq	movefish_lab5
	ldy	#MSPRITEY
	lda	(enemysprite),y
	clc
	adc	#FALLDOWNSPEED
	cmp	#GROUND
	bcc	movefish_lab6
	jmp	deleteactenemy
movefish_lab6:
	sta	(enemysprite),y
	rts
movefish_lab5:
	; Fisch bewegen
	; x-Position bestimmen
	ldy	#MSPRITEX
	lda	(enemysprite),y
	sec
	sbc	#2
	sta	(enemysprite),y
	; y-Position bestimmen
	ldy	#MSPRITEENEMYMVTABIDX
	lda	(enemysprite),y
	tay
movefish_lab2:
	lda	movefishtable,y
	cmp	#128
	bne	movefish_lab1
	ldy	#0
	beq	movefish_lab2
movefish_lab1:
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
	; Aussehen des Fischs
	ldy	#MSPRITEENEMYANIMLOOK
	lda	(enemysprite),y
	clc
	adc	#1
	sta	(enemysprite),y
	and	#8
	beq	movefish_lab3
	ldy	#MSPRITEW
	lda	#FISH1WIDTH
	sta	(enemysprite),y
	ldy	#MSPRITEH
	lda	#FISH1HEIGHT
	sta	(enemysprite),y
	ldy	#MSPRITEDATA
	lda	#<fish1
	sta	(enemysprite),y
	ldy	#MSPRITEDATA+1
	lda	#>fish1
	sta	(enemysprite),y
	rts
movefish_lab3:
	ldy	#MSPRITEW
	lda	#FISH2WIDTH
	sta	(enemysprite),y
	ldy	#MSPRITEH
	lda	#FISH2HEIGHT
	sta	(enemysprite),y
	ldy	#MSPRITEDATA
	lda	#<fish2
	sta	(enemysprite),y
	ldy	#MSPRITEDATA+1
	lda	#>fish2
	sta	(enemysprite),y
	rts


fish1:
; fish1sprite.ppm (30x21)
.byt 238, 238, 238, 238, 238, 238, 238, 170 
.byt 166, 110, 238, 238, 238, 238, 238, 238 
.byt 238, 238, 238, 238, 238, 106, 166, 102 
.byt 166, 110, 238, 238, 238, 238, 238, 238 
.byt 238, 238, 238, 230, 102, 102, 106, 170 
.byt 110, 238, 238, 238, 238, 238, 238, 238 
.byt 238, 238, 166, 102, 106, 106, 170, 110 
.byt 238, 238, 238, 238, 238, 238, 238, 238 
.byt 234, 166, 106, 106, 102, 166, 166, 238 
.byt 238, 238, 238, 238, 238, 238, 238, 166 
.byt 102, 166, 106, 166, 106, 166, 238, 238 
.byt 238, 238, 238, 238, 238, 234, 102, 102 
.byt 166, 166, 166, 102, 106, 238, 238, 238 
.byt 238, 238, 238, 238, 102, 187, 102, 102 
.byt 166, 166, 106, 106, 110, 238, 238, 238 
.byt 238, 238, 230, 107, 75, 102, 102, 102 
.byt 102, 102, 166, 106, 238, 238, 238, 234 
.byt 166, 102, 107, 91, 102, 102, 102, 102 
.byt 102, 106, 166, 238, 238, 238, 102, 110 
.byt 191, 255, 255, 255, 251, 102, 102, 102 
.byt 102, 166, 238, 238, 238, 238, 238, 75 
.byt 255, 255, 255, 255, 255, 251, 187, 102 
.byt 102, 238, 238, 238, 238, 238, 230, 68 
.byt 255, 255, 255, 255, 255, 255, 187, 102 
.byt 174, 233, 221, 238, 238, 238, 238, 68 
.byt 95, 255, 255, 255, 255, 255, 187, 106 
.byt 157, 217, 238, 238, 238, 238, 238, 100 
.byt 68, 68, 191, 255, 255, 255, 185, 153 
.byt 70, 238, 238, 238, 238, 238, 238, 238 
.byt 238, 68, 68, 75, 187, 185, 148, 238 
.byt 238, 238, 238, 238, 238, 238, 238, 238 
.byt 238, 238, 228, 68, 73, 221, 238, 238 
.byt 238, 238, 238, 238, 238, 238, 238, 238 
.byt 238, 238, 238, 228, 157, 238, 238, 238 
.byt 238, 238, 238, 238, 238, 238, 238, 238 
.byt 238, 238, 228, 157, 222, 238, 238, 238 
.byt 238, 238, 238, 238, 238, 238, 238, 238 
.byt 238, 238, 69, 221, 238, 238, 238, 238 
.byt 238, 238, 238, 238, 238, 238, 238, 238 
.byt 238, 228, 4
FISH1WIDTH = 30
FISH1HEIGHT = 21

fish2:
; fish2sprite.ppm (30x14)

.byt 238, 238, 238, 238, 238, 110, 238, 230 
.byt 110, 238, 238, 238, 238, 222, 238, 238 
.byt 238, 238, 238, 230, 102, 166, 102, 102 
.byt 110, 238, 238, 233, 222, 238, 238, 238 
.byt 238, 238, 230, 106, 102, 102, 170, 102 
.byt 238, 238, 237, 222, 238, 110, 238, 238 
.byt 238, 102, 106, 106, 106, 106, 170, 110 
.byt 238, 237, 158, 238, 230, 110, 238, 102 
.byt 102, 166, 106, 166, 102, 106, 110, 238 
.byt 153, 238, 238, 238, 102, 102, 187, 102 
.byt 102, 166, 170, 106, 170, 174, 238, 233 
.byt 222, 238, 238, 230, 102, 84, 102, 102 
.byt 102, 102, 102, 102, 102, 166, 185, 221 
.byt 238, 238, 238, 235, 85, 182, 102, 102 
.byt 102, 102, 102, 102, 107, 181, 157, 222 
.byt 238, 235, 187, 255, 187, 187, 102, 102 
.byt 102, 102, 102, 191, 102, 89, 153, 238 
.byt 228, 75, 191, 255, 255, 187, 187, 102 
.byt 187, 191, 182, 238, 100, 84, 238, 238 
.byt 228, 75, 255, 255, 255, 255, 255, 255 
.byt 251, 70, 238, 238, 110, 238, 238, 238 
.byt 230, 75, 255, 255, 255, 255, 245, 70 
.byt 238, 238, 238, 238, 238, 238, 238, 238 
.byt 230, 68, 255, 255, 180, 70, 238, 238 
.byt 238, 238, 238, 238, 238, 238, 238, 238 
.byt 238, 64, 0, 78, 238, 238, 238, 238 
.byt 238, 238
FISH2WIDTH = 30
FISH2HEIGHT = 14
FISHSPEED = 2
