nativeinstance:
	.byt	EVENTSTARTX,0,NATIVE1WIDTH,NATIVE1HEIGHT ; x,y,w,h
	.word	native1 ; data
	.byt	1,1,2,0 ; coincredleft,coincredright,coincredup,coincreddown
	.byt	0 ; Kollisions-Detektionen aktiv
	.word	tomtomdiesinit ; ext1, MSPRITEENEMYCOINCFUNC
	.word	nativekcoincfunc ; ext2, MSPRITEENEMYKCOINCFUNC
	.word	movenative ; ext3, MSPRITEENEMYMOVE
	.byt	0 ; ext4, MSPRITEENEMYISDYING
	.byt	NATIVESPEED ; ext5, MSPRITEENEMYSPEED
	.byt	NATIVESPEED ; ext6, MSPRITEENEMYMOVECNT
	.byt	0 ; ext7, MSPRITEENEMYSHOTDIR
	.byt	0 ; ext8, MSPRITEENEMYMVTABIDX
	.byt	10 ; ext9, MSPRITEENEMYSCORE
	.byt	0 ; ext10, MSPRITEENEMYANIMLOOK
	.byt	0 ; ext11, not used
	.byt	0 ; ext12, not used

createnative:
	; Native erzeugen
	lda	#<nativeinstance
	sta	cfmemcopystruct+MEMCOPY6502_SRC
	lda	#>nativeinstance
	sta	cfmemcopystruct+MEMCOPY6502_SRC+1
	jsr	createfactory
	lda	#EVENTSTARTX
	jmp	movenative_lab2

movenative:
	; Test auf "ausserhalb" Bildschirm
	jsr	test4outofscreen2
	ldy	#MSPRITEENEMYISDYING
	lda	(enemysprite),y
	bne	movenative_lab3
	; Native bewegen
	; x- und y-Position bestimmen
	ldy	#MSPRITEX
	lda	(enemysprite),y
	sec
	sbc	#1
	sta	(enemysprite),y
movenative_lab2:
	jsr	getyfromx_lab0
	cmp	#GROUND
	beq	movenative_lab8
	sta	moveenemytemp1
	; Aussehen des Native
	ldy	#MSPRITEENEMYANIMLOOK
	lda	(enemysprite),y
	clc
	adc	#1
	sta	(enemysprite),y
	and	#4
	beq	movenative_lab1
	ldy	#MSPRITEW
	lda	#NATIVE1WIDTH
	sta	(enemysprite),y
	ldy	#MSPRITEH
	lda	#NATIVE1HEIGHT
	sta	(enemysprite),y
	ldy	#MSPRITEY
	lda	moveenemytemp1
	sec
	sbc	#NATIVE1HEIGHT
	sta	(enemysprite),y
	ldy	#MSPRITEDATA
	lda	#<native1
	sta	(enemysprite),y
	ldy	#MSPRITEDATA+1
	lda	#>native1
	sta	(enemysprite),y
movenative_lab8:
	rts
movenative_lab1:
	ldy	#MSPRITEW
	lda	#NATIVE2WIDTH
	sta	(enemysprite),y
	ldy	#MSPRITEH
	lda	#NATIVE2HEIGHT
	sta	(enemysprite),y
	ldy	#MSPRITEY
	lda	moveenemytemp1
	sec
	sbc	#NATIVE2HEIGHT
	sta	(enemysprite),y
	ldy	#MSPRITEDATA
	lda	#<native2
	sta	(enemysprite),y
	ldy	#MSPRITEDATA+1
	lda	#>native2
	sta	(enemysprite),y
	rts
movenative_lab3:
	jmp	enemytype1dying

nativekcoincfunc:
	ldy	#MSPRITEW
	lda	#NATIVE3WIDTH
	sta	(actcoincsprite),y
	ldy	#MSPRITEH
	lda	#NATIVE3HEIGHT
	sta	(actcoincsprite),y
	ldy	#MSPRITEDATA
	lda	#<native3
	sta	(actcoincsprite),y
	ldy	#MSPRITEDATA+1
	lda	#>native3
	sta	(actcoincsprite),y
	jmp	enemykcoincfunc


native1:
; native1sprite.ppm (10x24)
.byt 238, 238, 233, 238, 238, 238, 238, 153 
.byt 153, 238, 238, 238, 101, 238, 238, 238 
.byt 102, 34, 70, 238, 230, 34, 34, 0 
.byt 110, 230, 34, 34, 32, 78, 226, 34 
.byt 34, 34, 46, 100, 146, 153, 34, 32 
.byt 228, 6, 68, 70, 96, 233, 182, 153 
.byt 66, 96, 230, 146, 84, 34, 32, 230 
.byt 17, 2, 0, 14, 238, 34, 34, 0 
.byt 238, 238, 98, 32, 6, 238, 34, 34 
.byt 0, 2, 38, 32, 34, 32, 2, 34 
.byt 96, 34, 32, 0, 38, 238, 102, 68 
.byt 68, 238, 228, 157, 221, 221, 78, 101 
.byt 153, 217, 157, 148, 228, 153, 148, 153 
.byt 68, 238, 66, 2, 70, 110, 238, 98 
.byt 34, 14, 238, 238, 230, 34, 36, 238
NATIVE1WIDTH = 10
NATIVE1HEIGHT = 24

native2:
; native2sprite.ppm (12x24)
.byt 238, 238, 238, 158, 238, 238, 238, 238 
.byt 153, 158, 238, 238, 238, 238, 230, 94 
.byt 238, 238, 238, 238, 98, 36, 238, 238 
.byt 238, 226, 34, 32, 14, 238, 238, 98 
.byt 34, 34, 6, 238, 230, 34, 34, 34 
.byt 34, 110, 98, 41, 146, 153, 34, 38 
.byt 102, 105, 9, 9, 38, 38, 102, 105 
.byt 153, 153, 38, 38, 226, 38, 82, 150 
.byt 34, 46, 238, 34, 17, 34, 0, 238 
.byt 238, 226, 34, 34, 14, 238, 98, 238 
.byt 34, 32, 238, 38, 98, 34, 32, 2 
.byt 34, 38, 34, 2, 34, 34, 2, 34 
.byt 230, 34, 34, 34, 2, 110, 238, 230 
.byt 102, 100, 78, 238, 238, 102, 157, 221 
.byt 148, 238, 238, 34, 153, 221, 153, 78 
.byt 238, 34, 89, 153, 98, 36, 230, 32 
.byt 73, 68, 98, 32, 98, 32, 228, 238 
.byt 238, 38, 96, 6, 238, 238, 238, 238
NATIVE2WIDTH = 12
NATIVE2HEIGHT = 24

native3:
; native3sprite.ppm (12x23)
.byt 238, 238, 238, 238, 153, 238, 238, 238 
.byt 238, 137, 238, 238, 238, 238, 230, 32 
.byt 73, 238, 238, 238, 34, 34, 0, 238 
.byt 238, 230, 34, 34, 0, 78, 238, 226 
.byt 34, 34, 0, 14, 238, 226, 34, 0 
.byt 0, 6, 238, 226, 34, 0, 0, 6 
.byt 238, 226, 34, 0, 0, 6, 238, 226 
.byt 34, 32, 0, 14, 238, 226, 34, 32 
.byt 0, 78, 238, 238, 34, 32, 0, 110 
.byt 238, 238, 98, 0, 6, 238, 238, 238 
.byt 230, 2, 110, 238, 238, 238, 226, 34 
.byt 38, 238, 238, 238, 98, 32, 6, 238 
.byt 238, 238, 102, 68, 70, 238, 102, 238 
.byt 153, 221, 212, 78, 2, 38, 153, 221 
.byt 221, 142, 2, 34, 73, 221, 148, 78 
.byt 96, 0, 4, 153, 2, 14, 238, 238 
.byt 238, 73, 34, 32, 238, 238, 238, 228 
.byt 226, 32
NATIVE3WIDTH = 12
NATIVE3HEIGHT = 23
NATIVESPEED = 2
