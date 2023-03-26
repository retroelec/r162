rollingstoneinstance:
	.byt	EVENTSTARTX,0,ROLLINGSTONE1WIDTH,ROLLINGSTONE1HEIGHT ; x,y,w,h
	.word	rollingstone1 ; data
	.byt	1,1,2,0 ; coincredleft,coincredright,coincredup,coincreddown
	.byt	0 ; Kollisions-Detektionen aktiv
	.word	tomtomdiesinit ; ext1, MSPRITEENEMYCOINCFUNC
	.word	stonekcoincfunc ; ext2, MSPRITEENEMYKCOINCFUNC
	.word	moverollingstone ; ext3, MSPRITEENEMYMOVE
	.byt	0 ; ext4, MSPRITEENEMYISDYING
	.byt	ROLLINGSTONESPEED ; ext5, MSPRITEENEMYSPEED
	.byt	ROLLINGSTONESPEED ; ext6, MSPRITEENEMYMOVECNT
	.byt	0 ; ext7, MSPRITEENEMYSHOTDIR
	.byt	0 ; ext8, not used
	.byt	0 ; ext9, not used
	.byt	0 ; ext10, MSPRITEENEMYANIMLOOK
	.byt	0 ; ext11, not used
	.byt	0 ; ext12, not used

createrollingstone:
	; Rollender Stein erzeugen
	lda	#<rollingstoneinstance
	sta	cfmemcopystruct+MEMCOPY6502_SRC
	lda	#>rollingstoneinstance
	sta	cfmemcopystruct+MEMCOPY6502_SRC+1
	jsr	createfactory
	lda	#EVENTSTARTX
	jmp	moverollingstone_lab2

moverollingstone:
	; Test auf "ausserhalb" Bildschirm
	jsr	test4outofscreen2
	; x- und y-Position bestimmen
	ldy	#MSPRITEX
	lda	(enemysprite),y
	sec
	sbc	#1
	sta	(enemysprite),y
moverollingstone_lab2:
	jsr	getyfromx_lab0
	cmp	#GROUND
	beq	moverollingstone_lab8
	sta	moveenemytemp1
	; Aussehen des Steins
	ldy	#MSPRITEENEMYANIMLOOK
	lda	(enemysprite),y
	eor	#1
	sta	(enemysprite),y
	beq	moverollingstone_lab1
	ldy	#MSPRITEW
	lda	#ROLLINGSTONE1WIDTH
	sta	(enemysprite),y
	ldy	#MSPRITEH
	lda	#ROLLINGSTONE1HEIGHT
	sta	(enemysprite),y
	ldy	#MSPRITEY
	lda	moveenemytemp1
	sec
	sbc	#ROLLINGSTONE1HEIGHT
	sta	(enemysprite),y
	ldy	#MSPRITEDATA
	lda	#<rollingstone1
	sta	(enemysprite),y
	ldy	#MSPRITEDATA+1
	lda	#>rollingstone1
	sta	(enemysprite),y
	rts
moverollingstone_lab1:
	ldy	#MSPRITEW
	lda	#ROLLINGSTONE2WIDTH
	sta	(enemysprite),y
	ldy	#MSPRITEH
	lda	#ROLLINGSTONE2HEIGHT
	sta	(enemysprite),y
	ldy	#MSPRITEY
	lda	moveenemytemp1
	sec
	sbc	#ROLLINGSTONE2HEIGHT
	sta	(enemysprite),y
	ldy	#MSPRITEDATA
	lda	#<rollingstone2
	sta	(enemysprite),y
	ldy	#MSPRITEDATA+1
	lda	#>rollingstone2
	sta	(enemysprite),y
	rts
moverollingstone_lab8:
	jmp	deleteactenemy

rollingstone1:
; rollingstone1sprite.ppm (18x23)
.byt 238, 238, 238, 238, 239, 255, 238, 238 
.byt 238, 238, 238, 238, 255, 255, 255, 254 
.byt 238, 238, 238, 238, 239, 255, 251, 159 
.byt 255, 254, 238, 238, 238, 255, 153, 185 
.byt 155, 191, 255, 238, 238, 235, 185, 153 
.byt 153, 153, 155, 255, 238, 238, 233, 153 
.byt 153, 153, 153, 153, 255, 238, 238, 153 
.byt 153, 153, 153, 149, 153, 191, 190, 238 
.byt 89, 153, 153, 153, 153, 89, 191, 254 
.byt 101, 153, 187, 153, 159, 251, 149, 155 
.byt 254, 101, 153, 153, 85, 191, 255, 185 
.byt 153, 191, 101, 153, 153, 153, 153, 191 
.byt 249, 153, 255, 21, 85, 153, 153, 153 
.byt 155, 185, 153, 187, 85, 85, 153, 153 
.byt 153, 155, 153, 185, 149, 85, 85, 153 
.byt 153, 153, 155, 153, 155, 181, 85, 85 
.byt 85, 89, 153, 153, 89, 155, 149, 101 
.byt 85, 85, 85, 89, 153, 153, 153, 85 
.byt 101, 85, 85, 85, 85, 89, 153, 149 
.byt 85, 101, 85, 85, 85, 85, 89, 153 
.byt 149, 94, 228, 85, 85, 85, 85, 89 
.byt 149, 85, 94, 230, 85, 85, 85, 85 
.byt 85, 85, 85, 238, 238, 85, 85, 85 
.byt 85, 85, 85, 85, 238, 238, 101, 85 
.byt 85, 85, 85, 85, 94, 238, 238, 230 
.byt 21, 85, 85, 85, 85, 238, 238
ROLLINGSTONE1WIDTH = 18
ROLLINGSTONE1HEIGHT = 23
ROLLINGSTONESPEED = 1

rollingstone2:
; rollingstone2sprite.ppm (16x22)
.byt 238, 238, 239, 255, 254, 238, 238, 238 
.byt 238, 238, 239, 255, 255, 255, 238, 238 
.byt 238, 239, 255, 255, 187, 187, 254, 238 
.byt 238, 187, 153, 251, 249, 153, 255, 238 
.byt 238, 153, 153, 153, 153, 153, 159, 238 
.byt 235, 89, 153, 153, 155, 153, 155, 190 
.byt 101, 89, 153, 153, 153, 153, 153, 254 
.byt 101, 89, 149, 153, 185, 153, 155, 254 
.byt 101, 89, 149, 89, 191, 153, 255, 187 
.byt 85, 89, 153, 155, 255, 249, 185, 255 
.byt 85, 153, 153, 153, 155, 249, 185, 255 
.byt 85, 89, 149, 153, 153, 185, 153, 155 
.byt 85, 89, 89, 153, 153, 153, 153, 153 
.byt 85, 85, 89, 153, 153, 153, 153, 153 
.byt 85, 85, 85, 153, 153, 153, 153, 149 
.byt 101, 85, 85, 89, 153, 85, 153, 85 
.byt 101, 85, 85, 85, 85, 153, 85, 85 
.byt 230, 85, 85, 85, 85, 85, 85, 94 
.byt 230, 85, 85, 85, 85, 85, 85, 238 
.byt 234, 101, 85, 85, 85, 85, 94, 238 
.byt 238, 101, 85, 85, 85, 85, 94, 238 
.byt 238, 238, 85, 85, 85, 85, 238, 238
ROLLINGSTONE2WIDTH = 16
ROLLINGSTONE2HEIGHT = 22
