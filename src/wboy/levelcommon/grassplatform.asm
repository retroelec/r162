grassplatforminstance:
	.byt	EVENTSTARTX,0,GRASSPLATFORMWIDTH,GRASSPLATFORMHEIGHT ; x,y,w,h
	.word	grassplatform ; data
	.byt	0,0,0,0 ; coincredleft,coincredright,coincredup,coincreddown
	.byt	0 ; Kollisions-Detektionen aktiv
	.word	platformcoincfunc ; ext1, MSPRITEENEMYCOINCFUNC
	.word	fruitkcoincfunc ; ext2, MSPRITEENEMYKCOINCFUNC
	.word	moveplatform ; ext3, MSPRITEENEMYMOVE
	.byt	0 ; ext4, MSPRITEENEMYISDYING
	.byt	PLATFORMSPEED ; ext5, MSPRITEENEMYSPEED
	.byt	PLATFORMSPEED ; ext6, MSPRITEENEMYMOVECNT
	.byt	0 ; ext7, MSPRITEENEMYSHOTDIR
	.byt	127+20 ; ext8, MSPRITEPLATFORMCNT
	.byt	0 ; ext9, MSPRITEPLATFORMDIR
	.byt	0 ; ext10, not used
	.byt	0 ; ext11, not used
	.byt	0 ; ext12, not used

creategrassplatform:
	; Grass-Platform erzeugen
	lda	#<grassplatforminstance
	sta	cfmemcopystruct+MEMCOPY6502_SRC
	lda	#>grassplatforminstance
	sta	cfmemcopystruct+MEMCOPY6502_SRC+1
	jsr	createfactory
	jmp	createplatformcommon

grassplatform:
; grassplatformsprite.ppm (38x14)
.byt 238, 78, 64, 64, 78, 228, 4, 224 
.byt 4, 228, 4, 4, 238, 64, 78, 64 
.byt 238, 68, 238, 228, 132, 140, 136, 132 
.byt 72, 200, 72, 200, 72, 196, 136, 68 
.byt 140, 132, 140, 68, 140, 78, 232, 72 
.byt 140, 132, 140, 72, 200, 136, 204, 72 
.byt 200, 76, 132, 140, 196, 136, 132, 140 
.byt 142, 72, 72, 140, 196, 140, 72, 196 
.byt 140, 204, 72, 204, 72, 196, 140, 196 
.byt 132, 200, 140, 196, 72, 136, 140, 200 
.byt 140, 136, 196, 140, 204, 76, 204, 136 
.byt 200, 140, 136, 196, 204, 76, 196, 68 
.byt 136, 140, 200, 140, 72, 200, 136, 200 
.byt 140, 204, 72, 196, 140, 136, 200, 140 
.byt 72, 196, 64, 136, 136, 68, 72, 72 
.byt 132, 72, 200, 136, 196, 68, 132, 136 
.byt 72, 200, 76, 68, 132, 224, 72, 64 
.byt 68, 80, 4, 68, 4, 132, 132, 68 
.byt 69, 68, 68, 84, 132, 4, 0, 14 
.byt 228, 0, 4, 148, 153, 68, 4, 149 
.byt 0, 4, 153, 73, 180, 68, 155, 4 
.byt 64, 153, 14, 238, 68, 68, 148, 89 
.byt 68, 84, 153, 73, 73, 153, 95, 153 
.byt 153, 251, 73, 149, 148, 238, 238, 238 
.byt 64, 73, 73, 84, 148, 89, 73, 153 
.byt 180, 159, 73, 153, 249, 153, 68, 78 
.byt 238, 238, 238, 238, 68, 4, 148, 68 
.byt 68, 73, 148, 148, 153, 89, 153, 68 
.byt 68, 238, 238, 238, 238, 238, 238, 238 
.byt 228, 68, 64, 68, 73, 84, 148, 84 
.byt 68, 68, 238, 238, 238, 238, 238, 238 
.byt 238, 238, 238, 238, 238, 238, 68, 64 
.byt 68, 0, 14, 238, 238, 238, 238, 238 
.byt 238, 238
GRASSPLATFORMWIDTH = 38
GRASSPLATFORMHEIGHT = 14
