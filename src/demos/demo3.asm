START6502CODE = 2512
MCOLORMAPDEFAULT = 46208
MSPRITETRANSPARENCY = 18
MCOLORMAPP768 = 65144
VIDEOMODE = 65156
TIMER = 65130
KEYPRESSED = 65057
MSPRITEID = 4
MSPRITEX = 5
MSPRITEY = 6
MSPRITEW = 7
MSPRITEH = 8
MSPRITEDATA = 9
MSPRITEBGDATA = 11
MSPRITESTATUS = 17
MSPRITEDELETED = 0
RMUL6502 = 65294

initlistmsprites6502 = 72
addmsprite6502 = 68
mul8x86502 = 20
memfill6502 = 32

callatm = 255

; start of code
* = START6502CODE

NUMOFSPRITES = 10

; random number
rand = 10
; pointer to the actual sprite
actsprite = 11

; autostart program
jmp	start
.asc	"AUTO"

; memfill structure to clear the multicolor map
memfillstructgfx:
.word	MCOLORMAPDEFAULT
.byt	80,200,0

; sprite definitions
SPRITEW = 6
SPRITEH = 10
; demo3sprite.ppm (6x10)
demo3spritedata:
.byt 0, 221, 0, 13, 204, 208, 220, 17 
.byt 205, 220, 17, 205, 220, 17, 205, 220 
.byt 17, 205, 220, 17, 205, 220, 17, 205 
.byt 13, 204, 208, 0, 221, 0
spritesdefstart:
demo3sprite:
	.word	0,0 ; next,prev
	.byt	1,75,180,SPRITEW,SPRITEH ; id,x,y,w,h
	.word	demo3spritedata,demo3spritebg ; data,bg
	.byt	0,0,0,0 ; *old
	.byt	MSPRITEDELETED ; state
	.byt	0 ; black is "transparent"
	; no coinc-detection
	.byt	0,0 ; speedx, speedy
demo3spritebg: ; reserve (2+w)/2*h bytes
	.dsb	40
sprite1defend:
spritesize = sprite1defend-spritesdefstart
spritebgoffset = demo3spritebg-demo3sprite
	.dsb	(NUMOFSPRITES-1)*spritesize
SPEEDX = MSPRITETRANSPARENCY+1
SPEEDY = SPEEDX+1

; start of the program
start:
	; set memory address of multicolor map
	lda	#<(MCOLORMAPDEFAULT+768)
	sta	MCOLORMAPP768
	lda	#>(MCOLORMAPDEFAULT+768)
	sta	MCOLORMAPP768+1

	; clear multicolor map
	ldx	#<memfillstructgfx
	ldy	#>memfillstructgfx
	.byt	callatm,memfill6502

	; switch to multicolor mode
	lda	#2
	sta	VIDEOMODE

	; init sprite list
	.byt	callatm,initlistmsprites6502

	; init. sprites
	jsr	initsprites

; main loop
main:
	; wait for vsync
	lda	TIMER
mainlab1:
	cmp	TIMER
	beq	mainlab1

	; move sprites
	jsr	movesprites

	; end program when pressing ESC
	lda	KEYPRESSED
	cmp	#127
	beq	quit

	; main loop -> wait for next vsync
	jmp	main

; quit program
quit:
	; change to text mode
	lda	#0
	sta	VIDEOMODE

	; jump back to shell
	jmpsh

initsprites:
	lda	#51
	sta	rand
	lda	#<spritesdefstart
	sta	actsprite
	lda	#>spritesdefstart
	sta	actsprite+1
	; sprite ID in x
	ldx	#1
initsprites_lab1:
	; init sprite
	ldy	#MSPRITEID
	txa
	sta	(actsprite),y
	ldy	#MSPRITEX
	jsr	getrandxpos
	sta	(actsprite),y
	ldy	#MSPRITEY
	jsr	getrandypos
	sta	(actsprite),y
	ldy	#MSPRITEW
	lda	#SPRITEW
	sta	(actsprite),y
	ldy	#MSPRITEH
	lda	#SPRITEH
	sta	(actsprite),y
	ldy	#MSPRITEDATA
	lda	#<demo3spritedata
	sta	(actsprite),y
	ldy	#MSPRITEDATA+1
	lda	#>demo3spritedata
	sta	(actsprite),y
	ldy	#MSPRITEBGDATA
	clc
	lda	actsprite
	adc	#spritebgoffset
	sta	(actsprite),y
	ldy	#MSPRITEBGDATA+1
	lda	actsprite+1
	adc	#0
	sta	(actsprite),y
	ldy	#MSPRITESTATUS
	lda	#MSPRITEDELETED
	sta	(actsprite),y
	ldy	#MSPRITETRANSPARENCY
	lda	#0
	sta	(actsprite),y
	jsr	getrandspeed
	ldy	#SPEEDX
	sta	(actsprite),y
	jsr	getrandspeed
	ldy	#SPEEDY
	sta	(actsprite),y
	txa
	ldx	actsprite
	ldy	actsprite+1
	.byt	callatm,addmsprite6502
	tax
	; next sprite
	cpx	#NUMOFSPRITES
	beq	initsprites_lab2
	inx
	clc
	lda	actsprite
	adc	#<spritesize
	sta	actsprite
	lda	actsprite+1
	adc	#>spritesize
	sta	actsprite+1
	jmp	initsprites_lab1
initsprites_lab2:
	rts

movesprites:
	lda	#<spritesdefstart
	sta	actsprite
	lda	#>spritesdefstart
	sta	actsprite+1
	ldx	#NUMOFSPRITES
movesprites_lab1:
	ldy	#SPEEDX
	lda	(actsprite),y
	ldy	#MSPRITEX
	clc
	adc	(actsprite),y
	sta	(actsprite),y
	ldy	#SPEEDY
	lda	(actsprite),y
	ldy	#MSPRITEY
	clc
	adc	(actsprite),y
	sta	(actsprite),y
	clc
	lda	actsprite
	adc	#<spritesize
	sta	actsprite
	lda	actsprite+1
	adc	#>spritesize
	sta	actsprite+1
	dex
	bne	movesprites_lab1
	rts

getrandomnum:
	txa
	ldx	rand
	ldy	#17
	.byt	callatm,mul8x86502
	tax
	lda	RMUL6502
	clc
	adc	#129
	sta	rand
	rts

getrandspeed:
	jsr	getrandomnum
	and	#3
	beq	getrandspeed_lab1
	cmp	#1
	beq	getrandspeed_lab2
	cmp	#2
	beq	getrandspeed_lab3
	lda	#2
	rts
getrandspeed_lab1:
	lda	#254
	rts
getrandspeed_lab2:
	lda	#255
	rts
getrandspeed_lab3:
	lda	#1
	rts

getrandxpos:
	jsr	getrandomnum
	cmp	#(160-SPRITEW)
	bcc	getrandxpos_lab1
	lsr
getrandxpos_lab1:
	rts

getrandypos:
	jsr	getrandomnum
	cmp	#(200-SPRITEH)
	bcc	getrandypos_lab1
	lsr
getrandypos_lab1:
	rts
