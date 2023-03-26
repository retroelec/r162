; clyde.asm, v1.2, individual functions for clyde
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
CLYDEID = 6
; Scatter-Target
CLYDESCATTERTARGETX = 1
CLYDESCATTERTARGETY = 24
; Start-Position
CLYDESTARTPOSX = 22
CLYDESTARTPOSY = 12
CLYDESTARTX = (CLYDESTARTPOSX*TILEWIDTH)+((TILEWIDTH-1)/2)
CLYDESTARTY = (CLYDESTARTPOSY*TILEHEIGHT)+((TILEHEIGHT-1)/2)
; Anzahl Sekunden, bis Clyde das Ghost-Haus verlaesst
CLYDETIMEGOOUTOFHOME = 16


clydesetinittargetmode:
	lda	#TMODE_HOMEIN
	sta	clydetargetmode
	sta	clydeoldtargetmode
	lda	#GHOSTINHOMETARGETX
	sta	clydefixedtargetxpos
	lda	#GHOSTINHOMETARGETY
	sta	clydefixedtargetypos
	rts


clydegetchasetarget:
	; Pacman-Target setzen
	lda	pactilexpos
	sta	ghosttargettilexpos
	lda	pactileypos
	sta	ghosttargettileypos
	; Euklidische Distanz zwischen Clyde und Pacman berechnen
	lda	clydetilexpos
	sta	tmptilexpos
	lda	clydetileypos
	sta	tmptileypos
	jsr	ghostgettargetdist
	lda	tmpdiff
	cmp	#64
	bcs	clydegetchasetarget_lab1
	; Scatter-Target setzen
	lda	CLYDESCATTERTARGETX
	sta	ghosttargettilexpos
	lda	CLYDESCATTERTARGETY
	sta	ghosttargettileypos
clydegetchasetarget_lab1:
	rts
