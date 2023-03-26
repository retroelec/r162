; pinky.asm, v1.2, individual functions for pinky
; 
; Copyright (C) 2011-2013 retroelec <retroelec@freenet.ch>
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
; www.gnu.org/licenses/.


; Sprite-ID
PINKYID = 4
; Scatter-Target
PINKYSCATTERTARGETX = 4
PINKYSCATTERTARGETY = 0
; Start-Position
PINKYSTARTPOSX = 19
PINKYSTARTPOSY = 12
PINKYSTARTX = (PINKYSTARTPOSX*TILEWIDTH)+((TILEWIDTH-1)/2)
PINKYSTARTY = (PINKYSTARTPOSY*TILEHEIGHT)+((TILEHEIGHT-1)/2)
; Anzahl Sekunden, bis Pinky das Ghost-Haus verlaesst
PINKYTIMEGOOUTOFHOME = 0


pinkysetinittargetmode:
	lda	#TMODE_HOMEIN
	sta	pinkytargetmode
	sta	pinkyoldtargetmode
	lda	#GHOSTINHOMETARGETX
	sta	pinkyfixedtargetxpos
	lda	#GHOSTINHOMETARGETY
	sta	pinkyfixedtargetypos
	rts


pinkygetchasetarget:
	lda	pinkyactdir
	cmp	#MV_LEFT
	bne	pinkygetchasetarget_lab13
	lda	pactilexpos
	cmp	#4
	bcc	pinkygetchasetarget_lab17
	sec
	sbc	#4
pinkygetchasetarget_lab17:
	sta	ghosttargettilexpos
	lda	pactileypos
	sta	ghosttargettileypos
	rts
pinkygetchasetarget_lab13:
	cmp	#MV_RIGHT
	bne	pinkygetchasetarget_lab14
	lda	pactilexpos
	cmp	#36
	bcs	pinkygetchasetarget_lab18
	clc
	adc	#4
pinkygetchasetarget_lab18:
	sta	ghosttargettilexpos
	lda	pactileypos
	sta	ghosttargettileypos
	rts
pinkygetchasetarget_lab14:
	cmp	#MV_UP
	bne	pinkygetchasetarget_lab15
	lda	pactilexpos
	sta	ghosttargettilexpos
	lda	pactileypos
	cmp	#4
	bcc	pinkygetchasetarget_lab19
	sec
	sbc	#4
pinkygetchasetarget_lab19:
	sta	ghosttargettileypos
	rts
pinkygetchasetarget_lab15:
	lda	pactilexpos
	sta	ghosttargettilexpos
	lda	pactileypos
	cmp	#36
	bcs	pinkygetchasetarget_lab20
	clc
	adc	#4
pinkygetchasetarget_lab20:
	sta	ghosttargettileypos
	rts
