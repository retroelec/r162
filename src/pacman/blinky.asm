; blinky.asm, v1.2, individual functions for blinky
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
BLINKYID = 3
; Scatter-Target
BLINKYSCATTERTARGETX = 35
BLINKYSCATTERTARGETY = 0
; Start-Position
BLINKYSTARTPOSX = 19
BLINKYSTARTPOSY = 10
BLINKYSTARTX = (BLINKYSTARTPOSX*TILEWIDTH)+((TILEWIDTH-1)/2)
BLINKYSTARTY = (BLINKYSTARTPOSY*TILEHEIGHT)+((TILEHEIGHT-1)/2)
; Anzahl Sekunden, bis Blinky das Ghost-Haus verlaesst
BLINKYTIMEGOOUTOFHOME = 0


blinkysetinittargetmode:
	lda	#TMODE_SCATTER
	sta	blinkytargetmode
	sta	blinkyoldtargetmode
	rts


blinkygetchasetarget:
	lda	pactilexpos
	sta	ghosttargettilexpos
	lda	pactileypos
	sta	ghosttargettileypos
	rts
