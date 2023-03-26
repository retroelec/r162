snailinstance:
	.byt	EVENTSTARTX,0,SNAIL1WIDTH,SNAIL1HEIGHT ; x,y,w,h
	.word	snail1 ; data
	.byt	1,1,2,0 ; coincredleft,coincredright,coincredup,coincreddown
	.byt	0 ; Kollisions-Detektionen aktiv
	.word	tomtomdiesinit ; ext1, MSPRITEENEMYCOINCFUNC
	.word	snailkcoincfunc ; ext2, MSPRITEENEMYKCOINCFUNC
	.word	movesnail ; ext3, MSPRITEENEMYMOVE
	.byt	0 ; ext4, MSPRITEENEMYISDYING
	.byt	SNAILSPEED ; ext5, MSPRITEENEMYSPEED
	.byt	SNAILSPEED ; ext6, MSPRITEENEMYMOVECNT
	.byt	0 ; ext7, MSPRITEENEMYSHOTDIR
	.byt	0 ; ext8, MSPRITEENEMYMVTABIDX
	.byt	1 ; ext9, MSPRITEENEMYSCORE
	.byt	0 ; ext10, MSPRITEENEMYANIMLOOK
	.byt	0 ; ext11, not used
	.byt	0 ; ext12, not used

createsnail:
	; Schnecke erzeugen
	lda	#<snailinstance
	sta	cfmemcopystruct+MEMCOPY6502_SRC
	lda	#>snailinstance
	sta	cfmemcopystruct+MEMCOPY6502_SRC+1
	jsr	createfactory
	lda	#EVENTSTARTX
	jmp	movesnail_lab2

movesnail:
	; Test auf "ausserhalb" Bildschirm
	jsr	test4outofscreen2
	ldy	#MSPRITEENEMYISDYING
	lda	(enemysprite),y
	bne	movesnail_lab3
	; Schnecke bewegen
	; x- und y-Position bestimmen
	ldy	#MSPRITEX
	lda	(enemysprite),y
	sec
	sbc	#1
	sta	(enemysprite),y
movesnail_lab2:
	jsr	getyfromx_lab0
	cmp	#GROUND
	beq	movesnail_lab8
	sta	moveenemytemp1
	; Aussehen der Schnecke
	ldy	#MSPRITEENEMYANIMLOOK
	lda	(enemysprite),y
	eor	#1
	sta	(enemysprite),y
	beq	movesnail_lab1
	ldy	#MSPRITEH
	lda	#SNAIL1HEIGHT
	sta	(enemysprite),y
	ldy	#MSPRITEY
	lda	moveenemytemp1
	sec
	sbc	#SNAIL1HEIGHT
	sta	(enemysprite),y
	ldy	#MSPRITEDATA
	lda	#<snail1
	sta	(enemysprite),y
	ldy	#MSPRITEDATA+1
	lda	#>snail1
	sta	(enemysprite),y
movesnail_lab8:
	rts
movesnail_lab1:
	ldy	#MSPRITEH
	lda	#SNAIL2HEIGHT
	sta	(enemysprite),y
	ldy	#MSPRITEY
	lda	moveenemytemp1
	sec
	sbc	#SNAIL2HEIGHT
	sta	(enemysprite),y
	ldy	#MSPRITEDATA
	lda	#<snail2
	sta	(enemysprite),y
	ldy	#MSPRITEDATA+1
	lda	#>snail2
	sta	(enemysprite),y
	rts
movesnail_lab3:
	jmp	enemytype1dying

snailkcoincfunc:
	ldy	#MSPRITEH
	lda	#SNAILDIESHEIGHT
	sta	(actcoincsprite),y
	ldy	#MSPRITEDATA
	lda	#<snaildies
	sta	(actcoincsprite),y
	ldy	#MSPRITEDATA+1
	lda	#>snaildies
	sta	(actcoincsprite),y
	jmp	enemykcoincfunc


snail1:
; snail1.ppm (12x20)
.byt 157, 153, 217, 238, 238, 238, 240, 255 
.byt 15, 238, 238, 238, 255, 255, 255, 238 
.byt 238, 238, 238, 144, 14, 238, 238, 238 
.byt 238, 157, 13, 238, 238, 238, 238, 157 
.byt 221, 238, 238, 238, 238, 157, 221, 0 
.byt 14, 238, 224, 157, 0, 1, 17, 238 
.byt 224, 157, 1, 17, 17, 30, 224, 157 
.byt 1, 16, 1, 30, 224, 157, 1, 1 
.byt 16, 30, 9, 157, 1, 1, 16, 30 
.byt 9, 221, 1, 1, 16, 30, 9, 221 
.byt 1, 1, 16, 30, 9, 221, 1, 1 
.byt 16, 30, 9, 221, 1, 16, 16, 30 
.byt 9, 221, 1, 17, 16, 30, 9, 221 
.byt 0, 17, 0, 29, 9, 221, 208, 0 
.byt 1, 29, 224, 157, 221, 221, 221, 221
SNAIL1WIDTH = 12
SNAIL1HEIGHT = 20

snail2:
; snail2.ppm (12x16)
.byt 157, 153, 217, 238, 238, 238, 240, 255 
.byt 15, 238, 238, 238, 255, 255, 255, 0 
.byt 14, 238, 224, 157, 0, 1, 17, 238 
.byt 224, 157, 1, 17, 17, 30, 224, 157 
.byt 1, 16, 1, 30, 224, 157, 1, 1 
.byt 16, 30, 9, 157, 1, 1, 16, 30 
.byt 9, 221, 1, 1, 16, 30, 9, 221 
.byt 1, 1, 16, 30, 9, 221, 1, 1 
.byt 16, 30, 9, 221, 1, 16, 16, 30 
.byt 9, 221, 1, 17, 16, 30, 9, 221 
.byt 0, 17, 0, 29, 9, 221, 208, 0 
.byt 1, 29, 224, 157, 221, 221, 221, 221
SNAIL2WIDTH = 12
SNAIL2HEIGHT = 16

snaildies:
; snaildiessprite.ppm (12x13)
.byt 238, 238, 225, 17, 238, 238, 238, 238 
.byt 17, 17, 27, 238, 238, 225, 17, 17 
.byt 17, 126, 238, 225, 17, 17, 17, 30 
.byt 238, 17, 17, 0, 1, 27, 238, 17 
.byt 16, 68, 64, 27, 238, 17, 16, 65 
.byt 64, 17, 238, 17, 16, 17, 64, 17 
.byt 229, 17, 17, 0, 16, 17, 81, 17 
.byt 17, 17, 16, 17, 17, 1, 17, 17 
.byt 1, 21, 16, 0, 17, 17, 17, 94 
.byt 228, 0, 1, 17, 94, 238
SNAILDIESWIDTH = 12
SNAILDIESHEIGHT = 13
SNAILSPEED = 15
