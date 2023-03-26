; msprite.asm, v1.6: sprite system for the r162 system
; 
; Copyright (C) 2010-2017 retroelec <retroelec42@gmail.com>
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


; Besonderheiten:
; - Wenn Sprites in der VSync-Routine mittels delmsprite6502 geloescht werden,
;   so werden diese effektiv erst waehrend der naechsten VSync-Phase geloescht
; - Nachdem Sprites mittels delmsprite6502 geloescht wurden, darf das Sprite
;   erst "wiederverwendet" werden, nachdem die naechste VSync-Phase initiert
;   wurde. Dabei wird der Status des Sprites auf MSPRITEDELETED gesetzt
;   (dieser Status kann im 6502-Code abgefragt werden).
; - Wenn Sprites mit "hoeherer" ID (bez. MINSPRITEIDTODRAW) in der
;   VSync-Routine mittels addmsprite6502 hinzugefuegt werden, so werden die
;   Sprites noch in der gleichen VSync-Phase gezeichnet.


; msprite-Struktur:
	; <struct>
	;   <name>mspritestructure</name>
	;   <titleg>msprite-Struktur</titleg>
	;   <titlee>msprite structure</titlee>
	;   <attr>
	;     <name>nodenext</name>
	;     <descg>Next-Pointer (intern)</descg>
	;     <desce>next pointer (internal)</desce>
	;     <offset>0</offset>
	;     <size>2</size>
	;   </attr>
	;   <attr>
	;     <name>nodeprev</name>
	;     <descg>Prev-Pointer (intern)</descg>
	;     <desce>prev pointer (internal)</desce>
	;     <offset>2</offset>
	;     <size>2</size>
	;   </attr>
	;   <attr>
	;     <name>id</name>
	;     <descg>ID des Sprites</descg>
	;     <desce>sprite id</desce>
	;     <offset>4</offset>
	;     <size>1</size>
	;   </attr>
	;   <attr>
	;     <name>x</name>
	;     <descg>x-Position des Sprites</descg>
	;     <desce>x position of sprite</desce>
	;     <offset>5</offset>
	;     <size>1</size>
	;   </attr>
	;   <attr>
	;     <name>y</name>
	;     <descg>y-Position des Sprites</descg>
	;     <desce>y position of sprite</desce>
	;     <offset>6</offset>
	;     <size>1</size>
	;   </attr>
	;   <attr>
	;     <name>w</name>
	;     <descg>Breite des Sprites</descg>
	;     <desce>width of sprite</desce>
	;     <offset>7</offset>
	;     <size>1</size>
	;   </attr>
	;   <attr>
	;     <name>h</name>
	;     <descg>Hoehe des Sprites</descg>
	;     <desce>height of sprite</desce>
	;     <offset>8</offset>
	;     <size>1</size>
	;   </attr>
	;   <attr>
	;     <name>spritedata</name>
	;     <descg>Pointer auf Sprite-Daten</descg>
	;     <desce>pointer to sprite data</desce>
	;     <offset>9</offset>
	;     <size>2</size>
	;   </attr>
	;   <attr>
	;     <name>spritebgdata</name>
	;     <descg>Pointer auf einen Speicherbereich, um den Hintergrund zu speichern</descg>
	;     <desce>pointer to a memory region to save the background</desce>
	;     <offset>11</offset>
	;     <size>2</size>
	;   </attr>
	;   <attr>
	;     <name>startposold</name>
	;     <descg>Pointer auf die (alte) Position des Sprites innerhalb der Multi-Colormap (intern)</descg>
	;     <desce>pointer to the (old) position of the sprite inside the multi color map (internal)</desce>
	;     <offset>13</offset>
	;     <size>2</size>
	;   </attr>
	;   <attr>
	;     <name>wbytesold</name>
	;     <descg>(Alte) Breite des Sprites in Bytes (intern)</descg>
	;     <desce>(old) width of sprite in bytes (internal)</desce>
	;     <offset>15</offset>
	;     <size>1</size>
	;   </attr>
	;   <attr>
	;     <name>hold</name>
	;     <descg>(Alte) Hoehe des Sprites (intern)</descg>
	;     <desce>(old) height of sprite (internal)</desce>
	;     <offset>16</offset>
	;     <size>1</size>
	;   </attr>
	;   <attr>
	;     <name>status</name>
	;     <descg>Status des Sprites (TOADD, TODRAW, TODEL)</descg>
	;     <desce>state of sprite (TOADD, TODRAW, TODEL)</desce>
	;     <offset>17</offset>
	;     <size>1</size>
	;   </attr>
	;   <attr>
	;     <name>transparency</name>
	;     <descg>Farbe, die als "transparent" interpretiert werden soll</descg>
	;     <desce>transparent color of sprite</desce>
	;     <offset>18</offset>
	;     <size>1</size>
	;   </attr>
	;   <attr>
	;     <name>coincredleft</name>
	;     <descg>Anzahl Pixel, um welche die Detektionsflaeche in horizontaler Richtung (links) reduziert wird</descg>
	;     <desce>number of pixels to reduce the detection area in horizontal direction (left)</desce>
	;     <offset>19</offset>
	;     <size>1</size>
	;   </attr>
	;   <attr>
	;     <name>coincredright</name>
	;     <descg>Anzahl Pixel, um welche die Detektionsflaeche in horizontaler Richtung (rechts) reduziert wird</descg>
	;     <desce>number of pixels to reduce the detection area in horizontal direction (right)</desce>
	;     <offset>20</offset>
	;     <size>1</size>
	;   </attr>
	;   <attr>
	;     <name>coincredup</name>
	;     <descg>Anzahl Pixel, um welche die Detektionsflaeche in vertikaler Richtung (oben) reduziert wird</descg>
	;     <desce>number of pixels to reduce the detection area in vertical direction (above)</desce>
	;     <offset>21</offset>
	;     <size>1</size>
	;   </attr>
	;   <attr>
	;     <name>coincreddown</name>
	;     <descg>Anzahl Pixel, um welche die Detektionsflaeche in vertikaler Richtung (unten) reduziert wird</descg>
	;     <desce>number of pixels to reduce the detection area in vertical direction (bottom)</desce>
	;     <offset>22</offset>
	;     <size>1</size>
	;   </attr>
	;   <attr>
	;     <name>nocoincdetect</name>
	;     <descg>Flag, ob Kollisionen mit diesem Sprite detektiert werden sollen</descg>
	;     <desce>flag if collisions with this sprite should be detected</desce>
	;     <offset>23</offset>
	;     <size>1</size>
	;   </attr>
	;   <attr>
	;     <name>numcoinc</name>
	;     <descg>Anzahl Sprites, mit denen dieses Sprite kollidiert ist</descg>
	;     <desce>number of sprites this sprite collided with</desce>
	;     <offset>24</offset>
	;     <size>1</size>
	;   </attr>
	;   <attr>
	;     <name>coincarr</name>
	;     <descg>Array der Sprite-IDs, mit denen dieses Sprite kollidiert ist</descg>
	;     <desce>array of sprite IDs this sprite collided with</desce>
	;     <offset>25</offset>
	;     <size>depends on the number of sprites with nocoincdetect == false</size>
	;   </attr>
	; </struct>


mspritedraw_lab10:
	ldi	r16,MSPRITETOADD
	std	y+MSPRITESTATUS,r16
	ret


mspritedraw:
	; Zeichnen eines Multi-Color-Sprites
	; Signatur mspritedraw (in: y; out: -; changed: r0,r1,r13-r25,x,y,z)
	; Eingabe: y -> Pointer auf die Sprite-Struktur
	; Veraenderte Register: r0, r1, r13-r25, x, y, z

	; Parameter holen
	ldd	xl,y+MSPRITEDATA
	ldd	xh,y+MSPRITEDATA+1
	subi	xh,(256-MEMOFF6502)
	ldd	zl,y+MSPRITEBGDATA
	ldd	zh,y+MSPRITEBGDATA+1
	subi	zh,(256-MEMOFF6502)
	ldd	r19,y+MSPRITEX
	ldd	r20,y+MSPRITEY
	ldd	r17,y+MSPRITEW
	ldd	r18,y+MSPRITEH
	; Start-Position ermitteln + Pruefungen bez. Sichtbarkeit
	lds	r16,NUMOFROWS
	cp	r20,r16
	brlo	mspritedraw_lab39
	; y-Position nicht im sichtbaren Bereich
	; Pruefung, ob Sprite teilweise ueber den oberen Rand hinausreicht
	neg	r20
	cp	r20,r18
	brsh	mspritedraw_lab10
	; Sprite teilweise sichtbar
	mov	r21,r17
	inc	r21
	lsr	r21
	mul	r20,r21
	add	xl,r0
	adc	xh,r1
	sub	r18,r20
	clr	r20
mspritedraw_lab39:
	sub	r16,r20
	cp	r16,r18
	brsh	mspritedraw_lab34
	; Sprite teilweise sichtbar, (y+h)-Position nicht im sichtbaren Bereich
	mov	r18,r16
mspritedraw_lab34:
	clr	r25
	cpi	r19,160
	brlo	mspritedraw_lab37
	; x-Position nicht im sichtbaren Bereich
	; Pruefung, ob Sprite teilweise ueber den linken Rand hinausreicht
	mov	r25,r19
	neg	r25
	cp	r25,r17
	brsh	mspritedraw_lab10
	; Sprite teilweise sichtbar
	andi	r19,1
	add	r25,r19
	sub	r17,r25
	breq	mspritedraw_lab10
	lsr	r25
	add	xl,r25
	adc	xh,regzero
mspritedraw_lab37:
	ldi	r16,160
	sub	r16,r19
	cp	r16,r17
	brsh	mspritedraw_lab35
	; Sprite teilweise sichtbar, (x+w)-Position nicht im sichtbaren Bereich
	sub	r17,r16
	mov	r25,r17
	lsr	r25
	mov	r17,r16
mspritedraw_lab35:
	; mcolmap + MCOLSCRWIDTH*y + x/2
	lds	r21,MCOLORMAP
	lds	r22,MCOLORMAP+1
	lds	r16,MCOLSCRWIDTH
	mul	r16,r20
	add	r21,r0
	adc	r22,r1
	mov	r16,r19
	lsr	r16
	add	r21,r16
	adc	r22,regzero
	ldd	r15,y+MSPRITETRANSPARENCY
	mov	r14,r15
	swap	r14
	std	y+MSPRITESTARTPOSOLD,r21
	std	y+MSPRITESTARTPOSOLD+1,r22
	std	y+MSPRITEHOLD,r18
	mov	r16,r17
	inc	r16
	sbrc	r19,0
	inc	r16
	lsr	r16
	std	y+MSPRITEWBYTESOLD,r16
	mov	yl,r21
	mov	yh,r22
	; High-Memory?
	in	r13,PORTD
	lds	r16,LOWHIMEM
	sbrc	r16,LOWHIMEMVIDEO
	himemon
	lds	r20,MCOLSCRWIDTH
	mov	r24,r17
	; Bestimme die Anzahl zu kopierende Bytes pro Zeile
	; -> (w+1)/2
	inc	r17
	lsr	r17
	; Bestimme die Anzahl Bytes fuer Positionierung auf naechste Zeile
	sub	r20,r17
	; Fallunterscheidung: x%2 == 0 oder 1?
	andi	r19,1
	brne	mspritedraw_lab1
	; x%2 == 0
mspritedraw_lab3:
	; Bearbeite naechste Zeile
	mov	r19,r17
mspritedraw_lab4:
	; Sprite-Daten kopieren + Hintergrund retten
	; Anzahl zu reservierende Bytes fuer den Hintergrund: ((1+w)/2)*h
	ld	r16,x+
	ld	r23,y
	st	z+,r23
	mov	r22,r16
	andi	r22,240
	cp	r22,r14
	breq	mspritedraw_lab23
mspritedraw_lab25:
	mov	r22,r16
	andi	r22,15
	cp	r22,r15
	breq	mspritedraw_lab24
mspritedraw_lab26:
	st	y+,r16
mspritedraw_lab2:
	dec	r19
	brne	mspritedraw_lab4
	; Positionierung auf naechste Zeile
	add	xl,r25
	adc	xh,regzero
	add	yl,r20
	adc	yh,regzero
	dec	r18
	brne	mspritedraw_lab3
	out	PORTD,r13
	ret
mspritedraw_lab23:
	andi	r16,15
	mov	r22,r23
	andi	r22,240
	or	r16,r22
	rjmp	mspritedraw_lab25
mspritedraw_lab24:
	andi	r16,240
	andi	r23,15
	or	r16,r23
	rjmp	mspritedraw_lab26
mspritedraw_lab1:
	; x%2 == 1
	mov	r19,r17
	; Am Anfang der Zeile kommt das "linke" Pixel vom Hintergrund
	ld	r21,y
	andi	r21,240
mspritedraw_lab6:
	; Ein Pixel des "vorherigen" Sprite-Daten-Bytes resp.
	; das entsprechende Hintergrund-Pixel ist in r21
	; Sprite-Daten kopieren + Hintergrund retten
	ld	r16,x+
	ld	r23,y
	st	z+,r23
	swap	r16
	mov	r22,r16
	andi	r22,15
	cp	r22,r15
	breq	mspritedraw_lab21
mspritedraw_lab11:
	cp	r21,r14
	breq	mspritedraw_lab22
mspritedraw_lab12:
	or	r22,r21
	st	y+,r22
	andi	r16,240
	mov	r21,r16
	dec	r19
	brne	mspritedraw_lab6
	; Wenn w%2 == 0 dann muss am Ende der Spritezeile ein "halbes" Byte kopiert werden
	andi	r24,1
	brne	mspritedraw_lab8
	; Kopieren eines einzelnen Pixels am Ende einer Spritezeile
	ld	r16,y
	st	z+,r16
	cp	r21,r14
	breq	mspritedraw_lab5
	andi	r16,15
	or	r16,r21
mspritedraw_lab5:
	st	y,r16
mspritedraw_lab8:
	; Positionierung auf naechste Zeile
	add	xl,r25
	adc	xh,regzero
	add	yl,r20
	adc	yh,regzero
	dec	r18
	brne	mspritedraw_lab1
	out	PORTD,r13
	ret
mspritedraw_lab21:
	mov	r22,r23
	andi	r22,15
	rjmp	mspritedraw_lab11
mspritedraw_lab22:
	mov	r21,r23
	andi	r21,240
	rjmp	mspritedraw_lab12


mspriteclear:
	; Loeschen eines Multi-Color-Sprites
	; Signatur mspriteclear (in: x,y; out: -; changed: r16-r20,r22,x,y)
	; Eingabe: x -> Pointer auf den Hintergrund-Speicherbereich
	; Eingabe: y -> Pointer auf die Sprite-Struktur
	; Veraenderte Register: r16-r20, r22, x, y

	; Parameter holen
	ldd	r19,y+MSPRITESTARTPOSOLD
	ldd	r20,y+MSPRITESTARTPOSOLD+1
	ldd	r17,y+MSPRITEWBYTESOLD
	ldd	r18,y+MSPRITEHOLD
	mov	yl,r19
	mov	yh,r20
	; High-Memory?
	in	r22,PORTD
	lds	r16,LOWHIMEM
	sbrc	r16,LOWHIMEMVIDEO
	himemon
	lds	r20,MCOLSCRWIDTH
	sub	r20,r17
	; Restauriere Hintergrund
mspriteclear_lab1:
	mov	r19,r17
mspriteclear_lab2:
	ld	r16,x+
	st	y+,r16
	dec	r19
	brne	mspriteclear_lab2
	add	yl,r20
	adc	yh,regzero
	dec	r18
	brne	mspriteclear_lab1
	out	PORTD,r22
	ret


addmsprite6502:
	; <proc>
	;   <name>addmsprite6502</name>
	;   <descg>Hinzufuegen eines Sprites in die Sprite-Liste</descg>
	;   <desce>add a sprite to the sprite list</desce>
	;   <input>
	;     <rparam>
	;       <name>x</name>
	;       <descg>Low-Byte des Pointers auf die &lt;a href="#mspritestructure"&gt;msprite-Struktur&lt;/a&gt;</descg>
	;       <desce>low byte of the pointer to the &lt;a href="#mspritestructure"&gt;msprite structure&lt;/a&gt;</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <descg>High-Byte des Pointers auf die &lt;a href="#mspritestructure"&gt;msprite-Struktur&lt;/a&gt;</descg>
	;       <desce>high byte of the pointer to the &lt;a href="#mspritestructure"&gt;msprite structure&lt;/a&gt;</desce>
	;     </rparam>
	;   </input>
	; </proc>

	; Sprite-Struktur ergaenzen
	mov	zl,regx
	mov	zh,regy
	subi	zh,(256-MEMOFF6502)
	ldi	r16,MSPRITETOADD
	std	z+MSPRITESTATUS,r16
	; Sprite in Liste einfuegen
	ldi	r18,low(SPRITELIST)
	ldi	r19,high(SPRITELIST)
	push	yl
	push	yh
	sts	SPRITELISTINWORK,regmemoff6502
	; listinsert (in: r18,r19,z; out: -; changed: r16,r17,r20,x,y)
	call	listinsert
	sts	SPRITELISTINWORK,regzero
	pop	yh
	pop	yl
	ret


delmsprite6502:
	; <proc>
	;   <name>delmsprite6502</name>
	;   <descg>Loeschen eines Sprites aus der Sprite-Liste</descg>
	;   <desce>remove a sprite from the sprite list</desce>
	;   <input>
	;     <rparam>
	;       <name>x</name>
	;       <descg>Low-Byte des Pointers auf die &lt;a href="#mspritestructure"&gt;msprite-Struktur&lt;/a&gt;</descg>
	;       <desce>low byte of the pointer to the &lt;a href="#mspritestructure"&gt;msprite structure&lt;/a&gt;</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <descg>High-Byte des Pointers auf die &lt;a href="#mspritestructure"&gt;msprite-Struktur&lt;/a&gt;</descg>
	;       <desce>high byte of the pointer to the &lt;a href="#mspritestructure"&gt;msprite structure&lt;/a&gt;</desce>
	;     </rparam>
	;   </input>
	; </proc>

	; Markierung setzen, um das Sprite aus der Liste zu loeschen
	mov	zl,regx
	mov	zh,regy
	subi	zh,(256-MEMOFF6502)
	ldd	r16,z+MSPRITESTATUS
	cpi	r16,MSPRITETOADD
	breq	delmsprite6502_lab1
	ldi	r16,MSPRITETODEL
delmsprite6502_lab2:
	std	z+MSPRITESTATUS,r16
	ret
delmsprite6502_lab1:
	ldi	r16,MSPRITETODELNOTDRAWN
	rjmp	delmsprite6502_lab2


initlistmsprites6502:
	; <proc>
	;   <name>initlistmsprites6502</name>
	;   <descg>Initialisierung der Sprite-Liste</descg>
	;   <desce>initialize the sprite list</desce>
	; </proc>


initlistmsprites:
	; Sprite-Liste initialisieren
	; Signatur initlistmsprites (in: -; out: -; changed: r16,z)
	; Veraenderte Register: r16, z

	ldi	zl,low(SPRITELIST)
	ldi	zh,high(SPRITELIST)
	ldi	r16,255
	sts	SPRITELISTINWORK,r16
	; listinit (in: z; out: -; changed: z)
	call	listinit
	sts	MINSPRITEIDTODRAW,regzero
	sts	SPRITELISTINWORK,regzero
	sts	DRAWSPRITES,regzero
	ret


clearoverdrivedmsprites:
	; Loescht alle Sprites mit einer ID >= MINSPRITEIDTODRAW
	; Signatur clearoverdrivedmsprites (in: -; out: z; changed: r16-r22,x,y,z)
	; Ausgabe: z -> Pointer auf den zuletzt bearbeiteten Knoten
	; Veraenderte Register: r16-r22, x, y, z
	; Pseudocode:
	;   void clearoverdrivedmsprites(minid) {
	;     actnode = spritelistdummynode->prev;
	;     while (actnode != spritelistdummynode) {
	;       if (actnode->id < minid) return;
	;       mspriteclear(actnode);
	;       actnode = actnode->prev;
	;     }
	;   }

	ldi	zl,low(SPRITELIST)
	ldi	zh,high(SPRITELIST)
	lds	r21,MINSPRITEIDTODRAW
clearoverdrivedmsprites_lab1:
	; actnode = spritelistdummynode->prev;
	; resp. actnode = actnode->prev;
	ldd	r16,z+LISTNODEPREV
	ldd	r17,z+LISTNODEPREV+1
	mov	zl,r16
	mov	zh,r17
	; if (actnode == list) return;
	cpi	zl,low(SPRITELIST)
	brne	clearoverdrivedmsprites_lab2
	cpi	zh,high(SPRITELIST)
	breq	clearoverdrivedmsprites_lab3
clearoverdrivedmsprites_lab2:
	; if (actnode->id < minid) return;
	ldd	r16,z+MSPRITEID
	cp	r16,r21
	brlo	clearoverdrivedmsprites_lab3
	ldd	r16,z+MSPRITESTATUS
	cpi	r16,MSPRITETOADD
	breq	clearoverdrivedmsprites_lab4
	cpi	r16,MSPRITETODELNOTDRAWN
	breq	clearoverdrivedmsprites_lab5
	; mspriteclear(actnode);
	mov	yl,zl
	mov	yh,zh
	ldd	xl,y+MSPRITEBGDATA
	ldd	xh,y+MSPRITEBGDATA+1
	subi	xh,(256-MEMOFF6502)
	; mspriteclear (in: x,y; out: -; changed: r16-r20,r22,x,y)
	rcall	mspriteclear
	ldd	r16,z+MSPRITESTATUS
	cpi	r16,MSPRITETODRAW
	breq	clearoverdrivedmsprites_lab1
clearoverdrivedmsprites_lab5:
	; Loesche Sprite aus Liste
	; MSPRITEDELETED = 0 -> regzero
	std	z+MSPRITESTATUS,regzero
	; listremove (in: z; out: y,z; changed: r16,r17,y,z)
	call	listremove
	rjmp	clearoverdrivedmsprites_lab1
clearoverdrivedmsprites_lab3:
	ldd	r16,z+LISTNODENEXT
	ldd	r17,z+LISTNODENEXT+1
	mov	zl,r16
	mov	zh,r17
	ret
clearoverdrivedmsprites_lab4:
	ldi	r16,MSPRITETODRAW
	std	z+MSPRITESTATUS,r16
	rjmp	clearoverdrivedmsprites_lab1


drawchangedmsprites:
	; Zeichnet ab einem bestimmten Sprite alle folgenden Sprites der Liste
	; Signatur drawchangedmsprites (in: y; out: -; changed: r0,r1,r16-r25,x,y,z)
	; Eingabe: y -> Pointer auf das erste zu zeichnende Sprite
	; Veraenderte Register: r0, r1, r16-r25, x, y, z
	; Pseudocode:
	;   void drawchangedmsprites(actsprite) {
	;     while (actsprite != spritelistdummynode) {
	;       mspritedraw(actsprite);
	;       actsprite = actsprite->next;
	;     }
	;   }

	push	r13
	push	r14
	push	r15
drawchangedmsprites_lab1:
	; if (actsprite == spritelistdummynode) return;
	cpi	yl,low(SPRITELIST)
	brne	drawchangedmsprites_lab2
	cpi	yh,high(SPRITELIST)
	breq	drawchangedmsprites_lab3
drawchangedmsprites_lab2:
	ldd	r16,y+MSPRITESTATUS
	cpi	r16,MSPRITETOADD
	brne	drawchangedmsprites_lab4
	; Sprite mit "genug hoher" ID wurde im VSync-Interrupt hinzugefuegt
	; -> Sprite kann gezeichnet werden
	; -> Status muss auf TODRAW gesetzt werden
	ldi	r16,MSPRITETODRAW
	std	y+MSPRITESTATUS,r16
drawchangedmsprites_lab4:
	push	yl
	push	yh
	; mspritedraw (in: y; out: -; changed: r0,r1,r13-r25,x,y,z)
	rcall	mspritedraw
	pop	yh
	pop	yl
	; actsprite = actsprite->next;
	ldd	r16,y+LISTNODENEXT
	ldd	r17,y+LISTNODENEXT+1
	mov	yl,r16
	mov	yh,r17
	rjmp	drawchangedmsprites_lab1
drawchangedmsprites_lab3:
	pop	r15
	pop	r14
	pop	r13
	ret


; Kollisionserkennung
; -------------------
;
; Koordinate x:
;   - Kollision von Sprite1 mit Sprite0 von links: x0A <= x1B < x0B
;     -> ax*bx, ax: x1B >= x0A, bx: x1B < x0B
;   - Kollision von Sprite1 mit Sprite0 von rechts: x0A <= x1A < x0B
;     -> cx*dx, cx: x1A >= x0A, dx: x1A < x0B
;   - Sprite1 umschliesst Sprite0: x1A <= x0A && x1B >= x0B
;     -> ex*fx, ex: x1A <= x0A, fx: x1B >= x0B
;  (- Sprite0 umschliesst Sprite1 ist bereits in ax*bx und cx*dx enthalten)
; Koordinate y: analog Koordinate x
;
;	     (x1A,y1A)
;	        [--------------]
;	        |              |
;	        |              |
;	        |              |
;    (x0A,y0A)  |              |
;       [-------|----]         |
;       |       |    |         |
;       |       |    |         |
;       |       |    |         |
;       |       |    |         |
;       |       |    |         |
;       |       |    |         |
;       |       [----|---------]
;       |            |      (x1B,y1B)
;       |            |
;       |            |
;       [------------]
;                 (x0B,y0B)
;
; Kollisions-Bedingung:
; (ax*bx + cx*dx + ex*fx) * (ay*by + cy*dy + ey*fy)

coincmsprite6502:
	; <proc>
	;   <name>coincmsprite6502</name>
	;   <descg>Detektieren von Kollisionen zwischen einem bestimmten Sprite und allen anderen Sprites</descg>
	;   <desce>detect collisions of a certain sprite with all other sprites</desce>
	;   <input>
	;     <rparam>
	;       <name>x</name>
	;       <descg>Low-Byte des Pointers auf die &lt;a href="#mspritestructure"&gt;msprite-Struktur&lt;/a&gt;</descg>
	;       <desce>low byte of the pointer to the &lt;a href="#mspritestructure"&gt;msprite structure&lt;/a&gt;</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <descg>High-Byte des Pointers auf die &lt;a href="#mspritestructure"&gt;msprite-Struktur&lt;/a&gt;</descg>
	;       <desce>high byte of the pointer to the &lt;a href="#mspritestructure"&gt;msprite structure&lt;/a&gt;</desce>
	;     </rparam>
	;   </input>
	; </proc>

	push	yl
	push	yh
	; Pointer auf Sprite-Struktur in y
	mov	yl,regx
	mov	yh,regy
	subi	yh,(256-MEMOFF6502)
	; Anzahl Kollisionen auf 0 setzen
	std	y+MSPRITENUMCOINC,regzero
	; Sprite-ID in r15
	ldd	r15,y+MSPRITEID
	; x0A in r16, x0B in r17
	ldd	r16,y+MSPRITEX
	ldd	r17,y+MSPRITEW
	add	r17,r16
	ldd	r22,y+MSPRITECOINCREDLEFT
	add	r16,r22
	ldd	r22,y+MSPRITECOINCREDRIGHT
	sub	r17,r22
	; Sicherstellen, dass x0A <= x0B
	cp	r17,r16
	brsh	coincmsprite_lab11
	clr	r16
coincmsprite_lab11:
	; y0A in r20, y0B in r21
	ldd	r20,y+MSPRITEY
	ldd	r21,y+MSPRITEH
	add	r21,r20
	ldd	r22,y+MSPRITECOINCREDUP
	add	r20,r22
	ldd	r22,y+MSPRITECOINCREDDOWN
	sub	r21,r22
	; Sicherstellen, dass y0A <= y0B
	cp	r21,r20
	brsh	coincmsprite_lab12
	clr	r20
coincmsprite_lab12:
	; Sprite-Liste durchgehen
	ldi	zl,low(SPRITELIST)
	ldi	zh,high(SPRITELIST)
coincmsprite_lab1:
	ldd	r18,z+LISTNODENEXT
	ldd	r19,z+LISTNODENEXT+1
	cpi	r18,low(SPRITELIST)
	brne	coincmsprite_lab2
	cpi	r19,high(SPRITELIST)
	brne	coincmsprite_lab2
	rjmp	coincmsprite_lab3
coincmsprite_lab2:
	mov	zl,r18
	mov	zh,r19
	; Keine Sprite-Kollisions-Detektion gewuenscht?
	ldd	r14,z+MSPRITENOCOINCDETECT
	cp	r14,regzero
	brne	coincmsprite_lab1
	; "Eigenes" Sprite?
	ldd	r14,z+MSPRITEID
	cp	r14,r15
	breq	coincmsprite_lab1
	; (ax*bx + cx*dx + ex*fx) == wahr?
	ldd	r18,z+MSPRITEX
	ldd	r19,z+MSPRITEW
	add	r19,r18
	ldd	r22,z+MSPRITECOINCREDLEFT
	add	r18,r22
	ldd	r22,z+MSPRITECOINCREDRIGHT
	sub	r19,r22
	; Sicherstellen, dass x1A <= x1B
	cp	r19,r18
	brsh	coincmsprite_lab13
	clr	r18
coincmsprite_lab13:
	; x0A -> r16, x0B -> r17, x1A -> r18, x1B -> r19
	; ax -> x1B >= x0A -> r19 >= r16
	cp	r19,r16
	brlo	coincmsprite_lab4
	; bx -> x1B < x0B -> r19 < r17
	cp	r19,r17
	brsh	coincmsprite_lab4
	; ax*bx wahr
	rjmp	coincmsprite_lab5
coincmsprite_lab4:
	; cx -> x1A >= x0A -> r18 >= r16
	cp	r18,r16
	brlo	coincmsprite_lab9
	; dx -> x1A < x0B -> r18 < r17
	cp	r18,r17
	brsh	coincmsprite_lab9
	rjmp	coincmsprite_lab5
	; cx*dx wahr
coincmsprite_lab9:
	; ex -> x1A <= x0A -> r18 <= r16
	cp	r16,r18
	brlo	coincmsprite_lab1
	; fx -> x1B >= x0B -> r19 >= r17
	cp	r19,r17
	brlo	coincmsprite_lab1
	; ex*fx wahr
coincmsprite_lab5:
	; ax*bx + cx*dx + ex*fx = wahr
	; (ay*by + cy*dy + ey*fy) == wahr?
	ldd	r18,z+MSPRITEY
	ldd	r19,z+MSPRITEH
	add	r19,r18
	ldd	r22,z+MSPRITECOINCREDUP
	add	r18,r22
	ldd	r22,z+MSPRITECOINCREDDOWN
	sub	r19,r22
	; Sicherstellen, dass y1A <= y1B
	cp	r19,r18
	brsh	coincmsprite_lab14
	clr	r18
coincmsprite_lab14:
	; y0A -> r20, y0B -> r21, y1A -> r18, y1B -> r19
	; ay -> y1B >= y0A -> r19 >= r20
	cp	r19,r20
	brlo	coincmsprite_lab7
	; by -> y1B < y0B -> r19 < r21
	cp	r19,r21
	brsh	coincmsprite_lab7
	; ay*by wahr
	rjmp	coincmsprite_lab8
coincmsprite_lab7:
	; cy -> y1A >= y0A -> r18 >= r20
	cp	r18,r20
	brlo	coincmsprite_lab10
	; dy -> y1A < y0B -> r18 < r21
	cp	r18,r21
	brsh	coincmsprite_lab10
	rjmp	coincmsprite_lab8
	; cx*dx wahr
coincmsprite_lab10:
	; ey -> y1A <= y0A -> r18 <= r20
	cp	r20,r18
	brlo	coincmsprite_lab1
	; fy -> y1B >= y0B -> r19 >= r21
	cp	r19,r21
	brlo	coincmsprite_lab1
	; ey*fy wahr
coincmsprite_lab8:
	; (ax*bx + cx*dx + ex*fx) * (ay*by + cy*dy + ey*fy) = wahr
	ldd	r22,y+MSPRITENUMCOINC
	add	yl,r22
	adc	yh,regzero
	std	y+MSPRITECOINCARR,r14
	sub	yl,r22
	sbc	yh,regzero
	inc	r22
	std	y+MSPRITENUMCOINC,r22
coincmsprite_lab6:
	rjmp	coincmsprite_lab1
coincmsprite_lab3:
	pop	yh
	pop	yl
	ret
