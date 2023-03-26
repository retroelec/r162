; inky.asm, v1.2, individual functions for inky
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
INKYID = 5
; Scatter-Target
INKYSCATTERTARGETX = 38
INKYSCATTERTARGETY = 24
; Start-Position
INKYSTARTPOSX = 16
INKYSTARTPOSY = 12
INKYSTARTX = (INKYSTARTPOSX*TILEWIDTH)+((TILEWIDTH-1)/2)
INKYSTARTY = (INKYSTARTPOSY*TILEHEIGHT)+((TILEHEIGHT-1)/2)
; Anzahl Sekunden, bis Inky das Ghost-Haus verlaesst
INKYTIMEGOOUTOFHOME = 6


inkysetinittargetmode:
	lda	#TMODE_HOMEIN
	sta	inkytargetmode
	sta	inkyoldtargetmode
	lda	#GHOSTINHOMETARGETX
	sta	inkyfixedtargetxpos
	lda	#GHOSTINHOMETARGETY
	sta	inkyfixedtargetypos
	rts


inkygetchasetarget:
	lda	inkyactdir
	cmp	#MV_LEFT
	bne	inkygetchasetarget_lab13
	lda	pactilexpos
	cmp	#2
	bcc	inkygetchasetarget_lab17
	sec
	sbc	#2
inkygetchasetarget_lab17:
	sta	tmp1
	lda	pactileypos
	sta	tmp2
	jmp	inkygetchasetarget_lab1
inkygetchasetarget_lab13:
	cmp	#MV_RIGHT
	bne	inkygetchasetarget_lab14
	lda	pactilexpos
	cmp	#38
	bcs	inkygetchasetarget_lab18
	clc
	adc	#2
inkygetchasetarget_lab18:
	sta	tmp1
	lda	pactileypos
	sta	tmp2
	jmp	inkygetchasetarget_lab1
inkygetchasetarget_lab14:
	cmp	#MV_UP
	bne	inkygetchasetarget_lab15
	lda	pactileypos
	cmp	#2
	bcc	inkygetchasetarget_lab19
	sec
	sbc	#2
inkygetchasetarget_lab19:
	sta	tmp2
	lda	pactilexpos
	sta	tmp1
	jmp	inkygetchasetarget_lab1
inkygetchasetarget_lab15:
	lda	pactileypos
	cmp	#38
	bcs	inkygetchasetarget_lab20
	clc
	adc	#2
inkygetchasetarget_lab20:
	sta	tmp2
	lda	pactilexpos
	sta	tmp1
	jmp	inkygetchasetarget_lab1
inkygetchasetarget_lab1:
	; Target-X-Pos. -> tmp1 - (blinkytilexpos-tmp1) = 2*tmp1 - blinkytilexpos
	; Target-Y-Pos. -> tmp2 - (blinkytileypos-tmp1) = 2*tmp2 - blinkytileypos
	lda	tmp1
	asl
	sec
	sbc	blinkytilexpos
	bcs	inkygetchasetarget_lab2
	lda	#0
inkygetchasetarget_lab2:
	cmp	#40
	bcc	inkygetchasetarget_lab4
	lda	#39
inkygetchasetarget_lab4:
	sta	ghosttargettilexpos
	lda	tmp2
	asl
	sec
	sbc	blinkytileypos
	bcs	inkygetchasetarget_lab3
	lda	#0
inkygetchasetarget_lab3:
	cmp	#25
	bcc	inkygetchasetarget_lab5
	lda	#24
inkygetchasetarget_lab5:
	sta	ghosttargettileypos
	rts
