stoneinstance:
	.byt	EVENTSTARTX,0,STONEWIDTH,STONEHEIGHT ; x,y,w,h
	.word	stone ; data
	.byt	1,1,2,0 ; coincredleft,coincredright,coincredup,coincreddown
	.byt	0 ; Kollisions-Detektionen aktiv
	.word	stonecoincfunc ; ext1, MSPRITEENEMYCOINCFUNC
	.word	stonekcoincfunc ; ext2, MSPRITEENEMYKCOINCFUNC
	.word	test4outofscreen ; ext3, MSPRITEENEMYMOVE
	.byt	0 ; ext4, MSPRITEENEMYISDYING
	.byt	STONESPEED ; ext5, MSPRITEENEMYSPEED
	.byt	STONESPEED ; ext6, MSPRITEENEMYMOVECNT
	.byt	0 ; ext7, MSPRITEENEMYSHOTDIR
	.byt	0 ; ext8, not used
	.byt	0 ; ext9, not used
	.byt	0 ; ext10, not used
	.byt	0 ; ext11, not used
	.byt	0 ; ext12, not used

createstone:
	; Stein erzeugen
	lda	#<stoneinstance
	sta	cfmemcopystruct+MEMCOPY6502_SRC
	lda	#>stoneinstance
	sta	cfmemcopystruct+MEMCOPY6502_SRC+1
	jsr	createfactory
	lda	#EVENTSTARTX
	jsr	getyfromx
	sec
	sbc	#STONEHEIGHT
	ldy	#MSPRITEY
	sta	(enemysprite),y
	rts

stonecoincfunc:
	lda	tomtomtumbleflag
	beq	stonecoincfunc_lab1
	rts
stonecoincfunc_lab1:	
	jmp	tomtomtumblesinit

stone:
; stone.ppm (12x20)
.byt 238, 224, 0, 14, 238, 238, 238, 9 
.byt 144, 0, 238, 238, 238, 9, 176, 11 
.byt 14, 238, 238, 9, 187, 11, 14, 238 
.byt 224, 153, 187, 11, 176, 238, 224, 11 
.byt 187, 9, 176, 238, 11, 11, 187, 9 
.byt 187, 14, 11, 11, 187, 176, 187, 14 
.byt 0, 176, 187, 176, 187, 14, 11, 176 
.byt 191, 176, 187, 14, 11, 176, 185, 0 
.byt 144, 0, 9, 176, 144, 0, 0, 0 
.byt 9, 187, 0, 191, 0, 176, 9, 176 
.byt 11, 187, 176, 176, 9, 176, 187, 187 
.byt 187, 240, 9, 0, 185, 191, 187, 176 
.byt 9, 0, 153, 187, 176, 176, 0, 9 
.byt 153, 185, 0, 176, 0, 0, 153, 144 
.byt 0, 0, 224, 0, 0, 0, 0, 0
STONEWIDTH = 12
STONEHEIGHT = 20
STONESPEED = OBJECTSSPEED
