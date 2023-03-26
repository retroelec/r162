; Demo program for the r162 system (create and move a sprite)

; Copyright (C) 2013 retroelec <retroelec42@gmail.com>
; 
; This program is free software; you can redistribute it and/or modify it
; under the terms of the GNU General Public License as published by the
; Free Software Foundation; either version 3 of the License, or (at your
; option) any later version.
; 
; This program is distributed in the hope that it will be useful, but
; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
; or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
; for more details.
; 
; For the complete text of the GNU General Public License see
; http://www.gnu.org/licenses/.


; sprites and vertical sync
; -------------------------
; r162 sprites are held in a sorted list and are always drawn in the vertical
; blanking interval (sprites with a lower ID are drawn first, i.e. having a
; lower priority). After the last row of the frame has been displayed, all
; drawn sprites having an ID >= MINSPRITEIDTODRAW are removed from the bitmap.
; If a sprite should be deleted, it will also be removed from the sprite list.
; If there is no vertical sync interrupt (6502 mode) immediatelly afterwards
; all sprites in the sprite list are redrawn. If the vertical sync interrupt
; (6502 mode) is enabled, the corresponding interrupt routine is executed
; before the sprites are redrawn. In any case the internal 6502 timer (TIMER)
; is incremented at the end.


; 6502 cross assembling using xa
; xa demo2.asm -o demo2

; include r162 definitions
#include "6502def.inc"

; start of code
* = START6502CODE

; autostart program
jmp	start
.asc	"AUTO"

; memfill structure to clear the multicolor map
memfillstructgfx:
.word	MCOLORMAPDEFAULT
.byt	80,200,0

; spaceship sprite (12x16)
; (width must be an even number, however the last column may be "empty")
SPACESHIPWIDTH = 12
SPACESHIPHEIGHT = 16
; sprite data
spaceshipdata:
.byt 0, 0, 15, 0, 0, 0            ;      W
.byt 0, 0, 15, 0, 0, 0            ;      W
.byt 0, 0, 255, 240, 0, 0         ;     WWW
.byt 0, 0, 255, 240, 0, 0         ;     WWW
.byt 0, 0, 255, 240, 0, 0         ;     WWW
.byt 0, 1, 255, 241, 0, 0         ;    RWWWR
.byt 0, 6, 255, 246, 0, 0         ;    BWWWB
.byt 16, 111, 241, 255, 96, 16    ; R BWWRWWB R
.byt 16, 255, 17, 31, 240, 16     ; R WWRRRWW R
.byt 240, 255, 31, 31, 240, 240   ; W WWRWRWW W
.byt 255, 255, 255, 255, 255, 240 ; WWWWWWWWWWW
.byt 255, 255, 31, 31, 255, 240   ; WWWWRWRWWWW
.byt 255, 240, 31, 16, 255, 240   ; WWW RWR WWW
.byt 255, 0, 31, 16, 15, 240      ; WW  RWR  WW
.byt 240, 0, 15, 0, 0, 240        ; W    W    W
.byt 240, 0, 15, 0, 0, 240        ; W    W    W
; sprite definitions
spaceshipsprite:
	.word	0,0 ; next,prev
	.byt	1,75,180,SPACESHIPWIDTH,SPACESHIPHEIGHT ; id,x,y,w,h
	.word	spaceshipdata,spaceshipdatabg ; data,bg
	.dsb	4,0 ; *old
	.byte	MSPRITEDELETED ; state
	.byte	0 ; black is "transparent"
	; no coinc-detection
spaceshipdatabg: ; reserve (2+w)/2*h bytes
	.dsb	(2+SPACESHIPWIDTH)/2*SPACESHIPHEIGHT,0


; start of the program
start:
	; set memory address of multicolor map
	lda	#<MCOLORMAPDEFAULT+768
	sta	MCOLORMAPP768
	lda	#>MCOLORMAPDEFAULT+768
	sta	MCOLORMAPP768+1

	; clear multicolor map
	ldx	#<memfillstructgfx
	ldy	#>memfillstructgfx
	callatm	memfill6502

	; switch to multicolor mode
	lda	#2
	sta	VIDEOMODE

	; init sprite list
	callatm	initlistmsprites6502

	; add spaceship sprite
	ldx	#<spaceshipsprite
	ldy	#>spaceshipsprite
	callatm	addmsprite6502

	; draw all sprites
	lda	#1
	sta	MINSPRITEIDTODRAW

; main loop
main:
	; wait for vsync
	lda	TIMER
mainlab1:
	cmp	TIMER
	beq	mainlab1

	; end program when pressing ESC
	lda	KEYPRESSED
	cmp	#127
	beq	quit

	; get user input (cursor keys)
	lda	KEYPRARR+11
	beq	mainlab2

	; user wants to move to the left
	dec	spaceshipsprite+MSPRITEX
	jmp	mainlab3

mainlab2:
	lda	KEYPRARR+20
	beq	mainlab3

	; user wants to move to the right
	inc	spaceshipsprite+MSPRITEX

mainlab3:
	; main loop -> wait for next vsync
	jmp	main


; quit program
quit:
	; change to text mode
	lda	#0
	sta	VIDEOMODE

	; jump back to shell
	jmpsh
