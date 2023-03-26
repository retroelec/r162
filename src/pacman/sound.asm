; sound.asm, v1.2, sounds for pacman
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


#include "sndN8.inc"
#include "sndN256.inc"
SNDPAUSE = 0
SNDEND = 255
SOUNDFREQT2 = SNDOCR2
SOUNDONOFFCONST = 29

SNDEFFECTPILLEATENCNT = 2
SNDEFFECTFREQ = 200

SNDPACMANDIES1 = 120
SNDPACMANDIES2 = 140
SNDPACMANDIES3 = 160
SNDPACMANDIES4 = 180
SNDPACMANDIES5 = 200
SNDPACMANDIES6 = 220

SNDGHOSTEATEN = 200

soundinit:
	lda	#0
	sta	soundpos
	lda	soundcounter
	sta	soundactcounter
	rts


soundplay:
	dec	soundactcounter
	bne	soundplay_lab1
	lda	soundcounter
	sta	soundactcounter
	ldy	soundpos
soundplay_lab3:
	inc	soundpos
	lda	(soundptr),y
	beq	soundplay_lab2
	sta	SOUNDFREQT2
soundplay_lab1:
	rts
soundplay_lab2:
	ldy	#0
	sty	soundpos
	jmp	soundplay_lab3


sirensound:
	; Sirenen-Sound

	lda	#<sndsiren
	sta	soundptr
	lda	#>sndsiren
	sta	soundptr+1
	lda	#2
	sta	soundcounter
	bne	soundinit


frightensound:
	; FRIGHTEN-Modus-Sound

	lda	#<sndfrighten
	sta	soundptr
	lda	#>sndfrighten
	sta	soundptr+1
	lda	#1
	sta	soundcounter
	bne	soundinit


gohomesound:
	; GOHOME-Modus-Sound

	lda	#<sndgohome
	sta	soundptr
	lda	#>sndgohome
	sta	soundptr+1
	lda	#2
	sta	soundcounter
	bne	soundinit


sndsiren:
.byt	140,144,148,152,156,152,148,144,0

sndfrighten:
.byt	120,125,130,135,0

sndgohome:
.byt	80,82,84,86,88,90,92,94,96,98,0

SNDEFFECTBONUSEATENCNT = 14
sndbonus:
.byt	70,72,74,76,78,80,82,84,86,70,80,90,100,110

SNDEFFECTEXTRALIFECNT = 22
sndextralife:
.byt	140,144,140,148,140,152,0,0,0,140,150,160,144,140,0,0,0,140,150,160,144,140


pacman_start_melody_t1:
.byt	3,SNDN8B5H,SNDN8B5L,3,SNDPAUSE,SNDPAUSE,3,SNDN8B6H,SNDN8B6L,3,SNDPAUSE,SNDPAUSE,3,SNDN8FIS6H,SNDN8FIS6L,3,SNDPAUSE,SNDPAUSE,3,SNDN8DIS6H,SNDN8DIS6L,3,SNDPAUSE,SNDPAUSE,3,SNDN8B6H,SNDN8B6L,3,SNDN8FIS6H,SNDN8FIS6L,6,SNDPAUSE,SNDPAUSE,9,SNDN8DIS6H,SNDN8DIS6L,3,SNDPAUSE,SNDPAUSE,3,SNDN8C6H,SNDN8C6L,3,SNDPAUSE,SNDPAUSE,3,SNDN8C7H,SNDN8C7L,3,SNDPAUSE,SNDPAUSE,3,SNDN8G6H,SNDN8G6L,3,SNDPAUSE,SNDPAUSE,3,SNDN8E6H,SNDN8E6L,3,SNDPAUSE,SNDPAUSE,3,SNDN8C7H,SNDN8C7L,3,SNDN8G6H,SNDN8G6L,6,SNDPAUSE,SNDPAUSE,9,SNDN8E6H,SNDN8E6L,3,SNDPAUSE,SNDPAUSE
.byt	3,SNDN8B5H,SNDN8B5L,3,SNDPAUSE,SNDPAUSE,3,SNDN8B6H,SNDN8B6L,3,SNDPAUSE,SNDPAUSE,3,SNDN8FIS6H,SNDN8FIS6L,3,SNDPAUSE,SNDPAUSE,3,SNDN8DIS6H,SNDN8DIS6L,3,SNDPAUSE,SNDPAUSE,3,SNDN8B6H,SNDN8B6L,3,SNDN8FIS6H,SNDN8FIS6L,6,SNDPAUSE,SNDPAUSE,9,SNDN8DIS6H,SNDN8DIS6L,3,SNDPAUSE,SNDPAUSE,3,SNDN8DIS6H,SNDN8DIS6L,3,SNDN8E6H,SNDN8E6L,3,SNDN8F6H,SNDN8F6L,3,SNDPAUSE,SNDPAUSE,3,SNDN8F6H,SNDN8F6L,3,SNDN8FIS6H,SNDN8FIS6L,3,SNDN8G6H,SNDN8G6L,3,SNDPAUSE,SNDPAUSE,3,SNDN8G6H,SNDN8G6L,3,SNDN8GIS6H,SNDN8GIS6L,3,SNDN8A6H,SNDN8A6L,3,SNDPAUSE,SNDPAUSE,6,SNDN8B6H,SNDN8B6L,0,SNDEND

pacman_start_melody_t2:
.byt	6,SNDN256B2,12,SNDPAUSE,6,SNDN256B3,6,SNDN256B2,12,SNDPAUSE,6,SNDN256B3,6,SNDN256C3,12,SNDPAUSE,6,SNDN256C4,6,SNDN256C3,12,SNDPAUSE,6,SNDN256C4,6,SNDN256B2,12,SNDPAUSE,6,SNDN256B3,6,SNDN256B2,12,SNDPAUSE,6,SNDN256B3,6,SNDN256FIS3,6,SNDPAUSE,6,SNDN256GIS3,6,SNDPAUSE,6,SNDN256AIS3,6,SNDPAUSE,6,SNDN256B3,0,SNDEND


playmelody:
	lda	#1
	sta	durationsnd1
	sta	durationsnd2
	lda	#0
	sta	tmpptrsnd1
	sta	tmpptrsnd2
playmelody_lab1:
	dec	durationsnd1
	bne	playmelody_lab4
	; Dauer Ton (Timer 1)
	ldy	tmpptrsnd1
	lda	(melodyptr1),y
	sta	durationsnd1
	iny
	; Ton
	lda	(melodyptr1),y
	cmp	#SNDEND
	beq	playmelody_lab2
	iny
	sta	SNDOCR1AH
	lda	(melodyptr1),y
	iny
	sty	tmpptrsnd1
	sta	SNDOCR1AL
playmelody_lab4:
	dec	durationsnd2
	bne	playmelody_lab5
	; Dauer Ton (Timer 2)
	ldy	tmpptrsnd2
	lda	(melodyptr2),y
	sta	durationsnd2
	iny
	; Ton
	lda	(melodyptr2),y
	cmp	#SNDEND
	beq	playmelody_lab2
	iny
	sty	tmpptrsnd2
	sta	SNDOCR2
playmelody_lab5:
	lda	TIMER
playmelody_lab6:
	cmp	TIMER
	beq	playmelody_lab6
	jmp	playmelody_lab1
playmelody_lab2:
	rts
