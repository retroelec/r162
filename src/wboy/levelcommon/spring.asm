springinstance:
	.byt	EVENTSTARTX,0,SPRINGWIDTH,SPRINGHEIGHT ; x,y,w,h
	.word	spring ; data
	.byt	0,0,0,0 ; coincredleft,coincredright,coincredup,coincreddown
	.byt	0 ; Kollisions-Detektionen aktiv
	.word	springcoincfunc ; ext1, MSPRITEENEMYCOINCFUNC
	.word	fruitkcoincfunc ; ext2, MSPRITEENEMYKCOINCFUNC
	.word	test4outofscreen ; ext3, MSPRITEENEMYMOVE
	.byt	0 ; ext4, MSPRITEENEMYISDYING
	.byt	SPRINGSPEED ; ext5, MSPRITEENEMYSPEED
	.byt	SPRINGSPEED ; ext6, MSPRITEENEMYMOVECNT
	.byt	0 ; ext7, MSPRITEENEMYSHOTDIR
	.byt	0 ; ext8, not used
	.byt	0 ; ext9, not used
	.byt	0 ; ext10, not used
	.byt	0 ; ext11, not used
	.byt	0 ; ext12, not used

createspring:
	; Sprungfeder erzeugen
	lda	#<springinstance
	sta	cfmemcopystruct+MEMCOPY6502_SRC
	lda	#>springinstance
	sta	cfmemcopystruct+MEMCOPY6502_SRC+1
	jsr	createfactory
	ldy	#MSPRITEY
	lda	actenemyfruitparam
	sta	(enemysprite),y
	rts

springcoincfunc:
	; Pointer auf die aktuelle enemy-Sprite-Struktur in actcoincsprite
	lda	tomtomobensprite+MSPRITEY
	cmp	tomtomoldobeny
	bcs	springcoincfunc_lab1
	rts
springcoincfunc_lab1:
	; Kollision "von oben"
	lda	#1
	sta	tomtomonspring
	ldy	#MSPRITEY
	lda	(actcoincsprite),y
	jmp	setyoftomtomsprite

spring:
; spring.ppm (24x16)
.byt 17, 17, 17, 17, 17, 17, 17, 17 
.byt 17, 17, 17, 17, 225, 17, 17, 17 
.byt 17, 17, 17, 17, 17, 17, 17, 30 
.byt 17, 17, 17, 17, 17, 17, 17, 17 
.byt 17, 17, 17, 17, 238, 238, 238, 228 
.byt 75, 187, 187, 244, 238, 238, 238, 238 
.byt 238, 238, 238, 191, 176, 0, 187, 191 
.byt 255, 238, 238, 238, 238, 238, 238, 11 
.byt 191, 255, 64, 11, 187, 238, 238, 238 
.byt 238, 238, 238, 228, 75, 187, 255, 244 
.byt 78, 238, 238, 238, 238, 238, 238, 191 
.byt 176, 0, 187, 191, 255, 238, 238, 238 
.byt 238, 238, 238, 11, 191, 255, 64, 11 
.byt 187, 238, 238, 238, 238, 238, 238, 228 
.byt 75, 187, 255, 244, 78, 238, 238, 238 
.byt 238, 238, 238, 191, 176, 0, 187, 191 
.byt 255, 238, 238, 238, 238, 238, 238, 11 
.byt 191, 255, 64, 11, 187, 238, 238, 238 
.byt 238, 238, 238, 228, 75, 187, 255, 244 
.byt 78, 238, 238, 238, 17, 17, 17, 17 
.byt 17, 17, 17, 17, 17, 17, 17, 17 
.byt 225, 17, 17, 17, 17, 17, 17, 17 
.byt 17, 17, 17, 30, 17, 17, 17, 17 
.byt 17, 17, 17, 17, 17, 17, 17, 17
SPRINGWIDTH = 24
SPRINGHEIGHT = 16
SPRINGSPEED = 30
