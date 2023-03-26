fireinstance:
	.byt	EVENTSTARTX,0,FIREWIDTH,FIREHEIGHT ; x,y,w,h
	.word	fire1 ; data
	.byt	2,2,4,0 ; coincredleft,coincredright,coincredup,coincreddown
	.byt	0 ; Kollisions-Detektionen aktiv
	.word	tomtomdiesinit ; ext1, MSPRITEENEMYCOINCFUNC
	.word	fruitkcoincfunc ; ext2, MSPRITEENEMYKCOINCFUNC
	.word	animfire ; ext3, MSPRITEENEMYMOVE
	.byt	0 ; ext4, MSPRITEENEMYISDYING
	.byt	FIRESPEED ; ext5, MSPRITEENEMYSPEED
	.byt	FIRESPEED ; ext6, MSPRITEENEMYMOVECNT
	.byt	0 ; ext7, MSPRITEENEMYSHOTDIR
	.byt	0 ; ext8, not used
	.byt	0 ; ext9, not used
	.byt	0 ; ext10, MSPRITEENEMYANIMLOOK
	.byt	0 ; ext11, not used
	.byt	0 ; ext12, not used

createfire:
	; Feuer erzeugen
	lda	#<fireinstance
	sta	cfmemcopystruct+MEMCOPY6502_SRC
	lda	#>fireinstance
	sta	cfmemcopystruct+MEMCOPY6502_SRC+1
	jsr	createfactory
	lda	#EVENTSTARTX
	jsr	getyfromx
	sec
	sbc	#FIREHEIGHT
	ldy	#MSPRITEY
	sta	(enemysprite),y
	rts

animfire:
	; Test auf "ausserhalb" Bildschirm
	jsr	test4outofscreen2
	; Feuer animieren
	ldy	#MSPRITEENEMYANIMLOOK
	lda	(enemysprite),y
	eor	#1
	sta	(enemysprite),y
	beq	animfire_lab1
	ldy	#MSPRITEDATA
	lda	#<fire1
	sta	(enemysprite),y
	iny
	lda	#>fire1
	sta	(enemysprite),y
	rts
animfire_lab1:
	ldy	#MSPRITEDATA
	lda	#<fire3
	sta	(enemysprite),y
	iny
	lda	#>fire3
	sta	(enemysprite),y
	rts

fire1:
; fire1sprite.ppm (14x22)
.byt 238, 238, 225, 30, 238, 238, 238, 238 
.byt 238, 229, 21, 238, 238, 238, 238, 21 
.byt 225, 17, 238, 238, 238, 238, 17, 81 
.byt 17, 238, 238, 238, 238, 17, 17, 81 
.byt 85, 30, 238, 238, 17, 21, 81, 17 
.byt 21, 238, 85, 21, 21, 149, 21, 17 
.byt 238, 17, 21, 89, 149, 85, 17, 85 
.byt 17, 25, 89, 153, 153, 81, 85, 17 
.byt 25, 153, 153, 153, 81, 17, 17, 89 
.byt 153, 153, 153, 145, 17, 81, 89, 153 
.byt 153, 153, 149, 17, 225, 89, 153, 217 
.byt 153, 149, 21, 17, 89, 157, 221, 217 
.byt 149, 30, 17, 89, 157, 223, 221, 153 
.byt 30, 17, 25, 157, 255, 221, 153, 94 
.byt 225, 21, 157, 255, 221, 149, 94, 238 
.byt 21, 157, 223, 217, 81, 30, 238, 17 
.byt 157, 223, 217, 81, 94, 238, 81, 21 
.byt 221, 149, 17, 238, 238, 229, 81, 153 
.byt 85, 94, 238, 238, 229, 17, 85, 17 
.byt 238, 238

fire3:
; fire3sprite.ppm (14x22)
.byt 238, 238, 238, 229, 238, 238, 238, 238 
.byt 238, 238, 225, 238, 238, 238, 238, 238 
.byt 238, 17, 238, 238, 238, 238, 85, 225 
.byt 17, 238, 238, 238, 238, 21, 225, 21 
.byt 238, 81, 238, 229, 17, 17, 17, 225 
.byt 21, 238, 229, 17, 17, 81, 17, 30 
.byt 238, 229, 17, 21, 81, 17, 17, 238 
.byt 21, 21, 21, 149, 21, 17, 238, 81 
.byt 21, 89, 149, 85, 17, 238, 81, 25 
.byt 153, 153, 149, 17, 225, 225, 89, 153 
.byt 217, 149, 17, 21, 225, 89, 157, 221 
.byt 153, 81, 30, 81, 89, 157, 253, 217 
.byt 149, 30, 81, 153, 221, 255, 217, 149 
.byt 30, 225, 89, 221, 255, 221, 149, 94 
.byt 225, 89, 221, 255, 221, 81, 238, 229 
.byt 89, 221, 255, 221, 85, 238, 238, 25 
.byt 157, 255, 217, 85, 238, 238, 229, 157 
.byt 253, 149, 30, 238, 238, 238, 85, 153 
.byt 85, 238, 238, 238, 229, 81, 85, 17 
.byt 238, 238
FIREWIDTH = 14
FIREHEIGHT = 22
FIRESPEED = 5
