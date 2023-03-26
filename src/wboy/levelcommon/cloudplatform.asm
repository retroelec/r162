cloudplatforminstance:
	.byt	EVENTSTARTX,0,CLOUDPLATFORMWIDTH,CLOUDPLATFORMHEIGHT ; x,y,w,h
	.word	cloudplatform ; data
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

createcloudplatform:
	; Cloud-Platform erzeugen
	lda	#<cloudplatforminstance
	sta	cfmemcopystruct+MEMCOPY6502_SRC
	lda	#>cloudplatforminstance
	sta	cfmemcopystruct+MEMCOPY6502_SRC+1
	jsr	createfactory
	jmp	createplatformcommon

cloudplatform:
; cloudplatformsprite.ppm (38x15)
.byt 238, 238, 238, 238, 238, 239, 254, 238 
.byt 238, 238, 238, 238, 238, 238, 238, 238 
.byt 238, 238, 238, 238, 238, 255, 238, 235 
.byt 255, 255, 254, 238, 239, 255, 238, 238 
.byt 239, 255, 238, 238, 255, 238, 238, 239 
.byt 255, 254, 239, 255, 255, 255, 238, 255 
.byt 255, 254, 238, 255, 255, 254, 255, 255 
.byt 254, 238, 255, 255, 255, 255, 255, 255 
.byt 255, 255, 255, 255, 255, 255, 255, 255 
.byt 255, 255, 255, 254, 235, 255, 255, 255 
.byt 255, 255, 255, 255, 255, 255, 255, 255 
.byt 255, 255, 255, 255, 255, 255, 255, 235 
.byt 255, 255, 255, 255, 255, 255, 255, 255 
.byt 255, 255, 255, 255, 255, 255, 255, 255 
.byt 255, 255, 238, 255, 255, 255, 255, 255 
.byt 255, 255, 255, 255, 255, 255, 255, 255 
.byt 255, 255, 255, 255, 255, 239, 255, 255 
.byt 255, 255, 255, 255, 255, 255, 255, 255 
.byt 255, 255, 255, 255, 255, 255, 255, 255 
.byt 255, 255, 255, 255, 255, 255, 255, 255 
.byt 255, 255, 255, 255, 255, 255, 255, 255 
.byt 255, 255, 244, 255, 255, 255, 255, 255 
.byt 255, 255, 255, 255, 255, 255, 255, 255 
.byt 255, 255, 255, 255, 255, 244, 79, 255 
.byt 255, 255, 255, 255, 255, 255, 255, 255 
.byt 255, 255, 255, 255, 251, 255, 255, 251 
.byt 238, 228, 191, 255, 255, 191, 255, 255 
.byt 255, 251, 255, 255, 255, 255, 255, 180 
.byt 191, 190, 68, 238, 238, 68, 191, 251 
.byt 75, 255, 255, 255, 238, 191, 255, 244 
.byt 79, 244, 238, 228, 78, 238, 238, 238 
.byt 238, 68, 78, 228, 239, 255, 244, 238 
.byt 75, 251, 78, 228, 78, 238, 238, 238 
.byt 238, 238, 238, 238, 238, 238, 238, 224 
.byt 0, 78, 238, 228, 4, 238, 238, 238 
.byt 238, 238, 238, 238, 238
CLOUDPLATFORMWIDTH = 38
CLOUDPLATFORMHEIGHT = 15
