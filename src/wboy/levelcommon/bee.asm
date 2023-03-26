beeinstance:
	.byt	EVENTSTARTX,0,BEE1WIDTH,BEE1HEIGHT ; x,y,w,h
	.word	bee1 ; data
	.byt	1,1,2,2 ; coincredleft,coincredright,coincredup,coincreddown
	.byt	0 ; Kollisions-Detektionen aktiv
	.word	tomtomdiesinit ; ext1, MSPRITEENEMYCOINCFUNC
	.word	enemykcoincfunc ; ext2, MSPRITEENEMYKCOINCFUNC
	.word	movebee ; ext3, MSPRITEENEMYMOVE
	.byt	0 ; ext4, MSPRITEENEMYISDYING
	.byt	BEESPEED ; ext5, MSPRITEENEMYSPEED
	.byt	BEESPEED ; ext6, MSPRITEENEMYMOVECNT
	.byt	0 ; ext7, MSPRITEENEMYSHOTDIR
	.byt	0 ; ext8, MSPRITEENEMYMVTABIDX
	.byt	10 ; ext9, MSPRITEENEMYSCORE
	.byt	0 ; ext10, MSPRITEENEMYANIMLOOK
	.byt	0 ; ext11, not used
	.byt	0 ; ext12, not used

createbee:
	; Biene erzeugen
	lda	#<beeinstance
	sta	cfmemcopystruct+MEMCOPY6502_SRC
	lda	#>beeinstance
	sta	cfmemcopystruct+MEMCOPY6502_SRC+1
	jsr	createfactory
	ldy	#MSPRITEY
	lda	actenemyfruitparam
	sta	(enemysprite),y
	rts

movebeetable:
	.byt	255,254,254,253,253,253,253,254,254,255,0,0,1,2,2,3,3,3,3,2,2,1,128

movebee:
	; Test auf "ausserhalb" Bildschirm
	jsr	test4outofscreen2
	ldy	#MSPRITEENEMYISDYING
	lda	(enemysprite),y
	beq	movebee_lab5
	ldy	#MSPRITEY
	lda	(enemysprite),y
	clc
	adc	#FALLDOWNSPEED
	cmp	#GROUND
	bcc	movebee_lab6
	jmp	deleteactenemy
movebee_lab6:
	sta	(enemysprite),y
	rts
movebee_lab5:
	; Biene bewegen
	; x-Position bestimmen
	ldy	#MSPRITEX
	lda	(enemysprite),y
	sec
	sbc	#1
	sta	(enemysprite),y
	; y-Position bestimmen
	ldy	#MSPRITEENEMYMVTABIDX
	lda	(enemysprite),y
	tay
movebee_lab2:
	lda	movebeetable,y
	cmp	#128
	bne	movebee_lab1
	ldy	#0
	beq	movebee_lab2
movebee_lab1:
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
	; Aussehen der Biene
	ldy	#MSPRITEENEMYANIMLOOK
	lda	(enemysprite),y
	eor	#1
	sta	(enemysprite),y
	beq	movebee_lab3
	ldy	#MSPRITEW
	lda	#BEE1WIDTH
	sta	(enemysprite),y
	ldy	#MSPRITEDATA
	lda	#<bee1
	sta	(enemysprite),y
	ldy	#MSPRITEDATA+1
	lda	#>bee1
	sta	(enemysprite),y
	rts
movebee_lab3:
	ldy	#MSPRITEW
	lda	#BEE2WIDTH
	sta	(enemysprite),y
	ldy	#MSPRITEDATA
	lda	#<bee2
	sta	(enemysprite),y
	ldy	#MSPRITEDATA+1
	lda	#>bee2
	sta	(enemysprite),y
	rts

bee1:
; bee1.ppm (8x20)
.byt 233, 158, 238, 238, 158, 153, 238, 238 
.byt 233, 233, 238, 238, 233, 9, 238, 238 
.byt 225, 209, 238, 238, 29, 17, 30, 254 
.byt 29, 17, 31, 255, 237, 209, 85, 255 
.byt 237, 149, 85, 80, 238, 89, 144, 14 
.byt 238, 233, 89, 153, 238, 229, 85, 14 
.byt 238, 237, 89, 144, 238, 237, 221, 144 
.byt 238, 224, 13, 144, 238, 221, 208, 144 
.byt 238, 0, 9, 14, 238, 221, 217, 14 
.byt 239, 85, 144, 14, 238, 0, 14, 238
BEE1WIDTH = 8
BEE1HEIGHT = 20

bee2:
; bee2.ppm (10x20)
.byt 233, 158, 238, 238, 238, 158, 153, 238 
.byt 238, 238, 233, 233, 254, 238, 239, 233 
.byt 9, 240, 238, 255, 225, 209, 224, 239 
.byt 255, 29, 17, 16, 255, 240, 29, 17 
.byt 16, 255, 14, 237, 209, 80, 240, 233 
.byt 237, 149, 85, 14, 158, 238, 89, 144 
.byt 153, 238, 238, 233, 89, 14, 238, 238 
.byt 229, 85, 14, 238, 238, 237, 89, 144 
.byt 238, 238, 237, 221, 144, 238, 238, 224 
.byt 13, 144, 238, 238, 221, 208, 144, 238 
.byt 238, 0, 9, 14, 238, 238, 221, 217 
.byt 14, 238, 239, 85, 144, 14, 238, 238 
.byt 0, 14, 238, 238
BEE2WIDTH = 10
BEE2HEIGHT = 20
BEESPEED = 2
