; graphics.asm, v1.6.2: graphic functions for the r162 system
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


; Variabeln:

; Tilemap:
;  TILEMAP: Pointer auf die Tilemap
;  TILEMAPSTARTX: x-Start-Position innerhalb der Tilemap
;  TILEMAPSTARTY: y-Start-Position innerhalb der Tilemap
;  TILEMAPWIDTH: Breite der Tilemap, z.B. 40
;  TILEMAPHEIGHT: Hoehe der Tilemap, z.B. 25

; Multi-Colormap:
;  TILEMCOLMAPX: x-Start-Position der Tile-Daten in der Multi-Colormap, z.B. 0
;  TILEMCOLMAPY: y-Start-Position der Tile-Daten in der Multi-Colormap, z.B. 0
;  TILEMCOLMAPW: Breite der Tile-Daten in der Multi-Colormap, z.B. 40
;  TILEMCOLMAPH: Hoehe der Tile-Daten in der Multi-Colormap, z.B. 25

; Tiles-Definitionen:
;  GFXTILEDEFS: Pointer auf die Tiles-Definitionen


gfxlowhimem:
	in	r22,PORTD
	lds	r16,LOWHIMEM
	sbrc	r16,LOWHIMEMVIDEO
	himemon
	ret


gfxgetstartpos:
	; Start-Position innerhalb der Multi-Colormap bestimmen
	; Signatur gfxgetstartpos (in: r17,r18; out: y; changed: r0-r4,r16-r18,y)
	; Eingabe: r17 -> y-Position (0..24)
	; Eingabe: r18 -> x-Position (0..39)
	; Ausgabe: y -> Pointer auf Start-Position innerhalb der Grafikmap
	; Veraenderte Register: r0-r4, r16-r18, y

	; Bestimme Start-Position innerhalb der Multi-Colormap
	; -> mapptr + MCOLSCRWIDTH*8*y + x
	lds	yl,MCOLORMAP
	lds	yh,MCOLORMAP+1
	lsl	r18
	add	yl,r18
	adc	yh,regzero
	lds	r18,MCOLSCRWIDTH
	mul	r17,r18
	mov	r17,r0
	mov	r18,r1
	ldi	r16,8
	; mul8x16 (in: r16-r18; out: r2-r4; changed: r0-r4)
	call	mul8x16
	add	yl,r2
	adc	yh,r3
	ret


gfxcopytile6502:
	; <proc>
	;   <name>gfxcopytile6502</name>
	;   <descg>Kopieren eines Tiles in die Multi-Colormap (Low- oder High-Mem)</descg>
	;   <desce>copy a tile to the multi colormap (low- or high-mem)</desce>
	;   <input>
	;     <rparam>
	;       <name>a</name>
	;       <descg>Tile-Nummer</descg>
	;       <desce>tile number</desce>
	;     </rparam>
	;     <rparam>
	;       <name>x</name>
	;       <descg>x-Position (0..39)</descg>
	;       <desce>x position (0..39)</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <descg>y-Position (0..24)</descg>
	;       <desce>y position (0..24)</desce>
	;     </rparam>
	;   </input>
	; </proc>

	rcall	gfxlowhimem
	mov	r20,yl
	mov	r21,yh
	mov	r13,r2
	mov	r14,r3
	mov	r15,r4
	mov	r18,regx
	mov	r17,regy
	mov	r19,rega
	; gfxcopytile (in: r17,r18,r19; out: -; changed: r0-r4,r16-r18,y,z)
	rcall	gfxcopytile
	mov	yl,r20
	mov	yh,r21
	mov	r2,r13
	mov	r3,r14
	mov	r4,r15
	out	PORTD,r22
	ret

gfxcopytile:
	; Kopiere ein Tile in die Multi-Colormap
	; Signatur gfxcopytile (in: r17,r18,r19; out: -; changed: r0-r4,r16-r18,y,z)
	; Eingabe: r17 -> y-Position (0..24)
	; Eingabe: r18 -> x-Position (0..39)
	; Eingabe: r19 -> Tile-Nummer
	; Veraenderte Register: r0-r4, r16-r18, y, z

	; Start-Position innerhalb der Multi-Colormap bestimmen
	; gfxgetstartpos (in: r17,r18; out: y; changed: r0-r4,r16-r18,y)
	rcall	gfxgetstartpos
gfxcopytile_lab0:
	; Signatur gfxcopytile_lab0 (in: r19,y; out: -; changed: r0,r1,r16-r18,y,z)
	; Eingabe: r19 -> Tile-Nummer
	; Eingabe: y -> Pointer auf Start-Position innerhalb der Grafikmap
	; Veraenderte Register: r0, r1, r16-r18, y, z
	; Pointer auf Quell-Daten
	lds	zl,GFXTILEDEFS
	lds	zh,GFXTILEDEFS+1
	ldi	r16,16
	mul	r16,r19
	add	zl,r0
	adc	zh,r1
	; Daten kopieren
	ldi	r16,8
	lds	r18,MCOLSCRWIDTH
	subi	r18,2
gfxcopytile_lab1:
	ld	r17,z+
	st	y+,r17
	ld	r17,z+
	st	y+,r17
	add	yl,r18
	adc	yh,regzero
	dec	r16
	brne	gfxcopytile_lab1
	ret


gfxcopytilecol6502:
	; <proc>
	;   <name>gfxcopytilecol6502</name>
	;   <descg>Kopieren einer Tile-Spalte in die Multi-Colormap (Low- oder High-Mem)</descg>
	;   <desce>copy a tile column to the multi colormap (low- or high-mem)</desce>
	; </proc>

	rcall	gfxlowhimem
	mov	r20,yl
	mov	r21,yh
	mov	r12,r2
	mov	r13,r3
	mov	r14,r4
	; gfxcopytilecol (in: -; out: -; changed: r0-r4,r15-r19,x,y,z)
	rcall	gfxcopytilecol
	mov	yl,r20
	mov	yh,r21
	mov	r2,r12
	mov	r3,r13
	mov	r4,r14
	out	PORTD,r22
	ret

gfxcopytilecol:
	; Kopiere eine Tile-Spalte in die Multi-Colormap
	; Signatur gfxcopytilecol (in: -; out: -; changed: r0-r4,r15-r19,x,y,z)
	; Veraenderte Register: r0-r4, r15-r19, x, y, z

	; Ermitteln Parameter
	; Voraussetzung: TILEMAPHEIGHT < 256 !!!
	lds	xl,TILEMAP
	lds	xh,TILEMAP+1
	lds	r16,TILEMAPHEIGHT
	lds	r17,TILEMAPSTARTX
	lds	r18,TILEMAPSTARTX+1
	; mul8x16 (in: r16-r18; out: r2-r4; changed: r0-r4)
	call	mul8x16
	add	xl,r2
	adc	xh,r3
	lds	r16,TILEMAPSTARTY
	add	xl,r16
	adc	xh,regzero
	; Start-Position innerhalb der Multi-Colormap bestimmen
	lds	r17,TILEMCOLMAPY
	lds	r18,TILEMCOLMAPX
	; gfxgetstartpos (in: r17,r18; out: y; changed: r0-r4,r16-r18,y)
	rcall	gfxgetstartpos
	; Iterationen
	lds	r15,TILEMCOLMAPH
gfxcopytilecol_lab1:
	ld	r19,x+
	; gfxcopytile_lab0 (in: r19,y; out: -; changed: r0,r1,r16-r18,y,z)
	rcall	gfxcopytile_lab0
	dec	r15
	brne	gfxcopytilecol_lab1
	ret


gfxcopytilerow6502:
	; <proc>
	;   <name>gfxcopytilerow6502</name>
	;   <descg>Kopieren einer Tile-Zeile in die Multi-Colormap (Low- oder High-Mem)</descg>
	;   <desce>copy a tile row to the multi colormap (low- or high-mem)</desce>
	; </proc>

	rcall	gfxlowhimem
	mov	r21,yl
	mov	r23,yh
	mov	r11,r2
	mov	r12,r3
	mov	r20,r4
	; gfxcopytilerow (in: -; out: -; changed: r0-r4,r13-r19,x,y,z)
	rcall	gfxcopytilerow
	mov	yl,r21
	mov	yh,r23
	mov	r2,r11
	mov	r3,r12
	mov	r4,r20
	out	PORTD,r22
	ret

gfxcopytilerow:
	; Kopiere eine Tile-Zeile in die Multi-Colormap
	; Signatur gfxcopytilerow (in: -; out: -; changed: r0-r4,r13-r19,x,y,z)
	; Veraenderte Register: r0-r4, r13-r19, x, y, z

	; Ermitteln Parameter
	; Voraussetzung: TILEMAPWIDTH < 256 !!!
	lds	xl,TILEMAP
	lds	xh,TILEMAP+1
	lds	r16,TILEMAPWIDTH
	lds	r17,TILEMAPSTARTY
	lds	r18,TILEMAPSTARTY+1
	; mul8x16 (in: r16-r18; out: r2-r4; changed: r0-r4)
	call	mul8x16
	add	xl,r2
	adc	xh,r3
	lds	r16,TILEMAPSTARTX
	add	xl,r16
	adc	xh,regzero
	; Start-Position innerhalb der Multi-Colormap bestimmen
	lds	r17,TILEMCOLMAPY
	lds	r18,TILEMCOLMAPX
	; gfxgetstartpos (in: r17,r18; out: y; changed: r0-r4,r16-r18,y)
	rcall	gfxgetstartpos
	; Iterationen
	lds	r15,TILEMCOLMAPW
gfxcopytilerow_lab1:
	mov	r13,yl
	mov	r14,yh
	ld	r19,x+
	; gfxcopytile_lab0 (in: r19,y; out: -; changed: r0,r1,r16-r18,y,z)
	rcall	gfxcopytile_lab0
	mov	yl,r13
	mov	yh,r14
	adiw	yl,2
	dec	r15
	brne	gfxcopytilerow_lab1
	ret


setpixel6502:
	; <proc>
	;   <name>setpixel6502</name>
	;   <descg>Setzen eines Pixels in der Multi-Colormap (Low- oder High-Mem)</descg>
	;   <desce>set a pixel in the multi colormap (low- or high-mem)</desce>
	;   <input>
	;     <rparam>
	;       <name>a</name>
	;       <descg>Farbe (0-15)</descg>
	;       <desce>color (0-15)</desce>
	;     </rparam>
	;     <rparam>
	;       <name>x</name>
	;       <descg>x-Position</descg>
	;       <desce>x position</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <descg>y-Position</descg>
	;       <desce>y position</desce>
	;     </rparam>
	;   </input>
	; </proc>

	rcall	gfxlowhimem
	mov	r16,regx
	mov	r17,regy
	mov	r13,rega
	rcall	setpixel
	out	PORTD,r22
	ret

setpixel:
	; r16 -> x, r17 -> y, r13 -> color
	; changed: r0,r1,r20,r21,z
	lds	zl,MCOLORMAP
	lds	zh,MCOLORMAP+1
	lds	r20,MCOLSCRWIDTH
	mul	r17,r20
	add	zl,r0
	adc	zh,r1
	mov	r20,r16
	lsr	r20
	add	zl,r20
	adc	zh,regzero
	ld	r20,z
	mov	r21,r16
	andi	r21,1
	brne	setpixel_lab1
	swap	r13
	andi	r20,15
	or	r20,r13
	swap	r13
	st	z,r20
	ret
setpixel_lab1:
	andi	r20,240
	or	r20,r13
	st	z,r20
	ret


drawline6502:
	; <proc>
	;   <name>drawline6502</name>
	;   <descg>Zeichne eine Linie in der Multi-Colormap (Low- oder High-Mem)</descg>
	;   <desce>draw a line to the multi colormap (low- or high-mem)</desce>
	;   <input>
	;     <rparam>
	;       <name>a</name>
	;       <descg>Farbe (0-15)</descg>
	;       <desce>color (0-15)</desce>
	;     </rparam>
	;     <rparam>
	;       <name>x</name>
	;       <descg>x-Start-Position</descg>
	;       <desce>x start position</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <descg>y-Start-Position</descg>
	;       <desce>y start position</desce>
	;     </rparam>
	;     <mparam>
	;       <name>DRAWLINEENDX</name>
	;       <descg>x-End-Position</descg>
	;       <desce>x end position</desce>
	;     </mparam>
	;     <mparam>
	;       <name>DRAWLINEENDY</name>
	;       <descg>y-End-Position</descg>
	;       <desce>y end position</desce>
	;     </mparam>
	;   </input>
	; </proc>

	rcall	gfxlowhimem
	mov	r16,regx
	mov	r17,regy
	lds	r18,DRAWLINEENDX
	lds	r19,DRAWLINEENDY
	mov	r13,rega

drawline:
	; void line(int x0, int y0, int x1, int y1, byte color)
	; {
	;   int dx = abs(x1-x0), sx = x0<x1 ? 1 : -1;
	;   int dy = abs(y1-y0), sy = y0<y1 ? 1 : -1;
	;   int err = dx-dy, e2;
	;   while(1){
	;     setpixel(x0, y0, color);
	;     if (x0==x1 && y0==y1) break;
	;     e2 = 2*err;
	;     if (e2 > -dy) { err -= dy; x0 += sx; }
	;     if (e2 < dx) { err += dx; y0 += sy; }
	;   }
	; }

	; r16 -> x0, r17 -> y0, r18 -> x1, r19 -> y1, r13 -> color
	; r14 -> dx, r15 -> dy, r24 -> sx, r23 -> sy
	; r9,r10 -> err, r26,r27 -> e2

	;   int dx = abs(x1-x0), sx = x0<x1 ? 1 : -1;
	cp	r18,r16
	brlo	drawline_lab1
	; x1 >= x0
	mov	r14,r18
	sub	r14,r16
	ldi	r24,1
	rjmp	drawline_lab2
drawline_lab1:
	; x1 < x0
	mov	r14,r16
	sub	r14,r18
	ldi	r24,-1
drawline_lab2:
	;   int dy = abs(y1-y0), sy = y0<y1 ? 1 : -1;
	cp	r19,r17
	brlo	drawline_lab3
	; y1 >= y0
	mov	r15,r19
	sub	r15,r17
	ldi	r23,1
	rjmp	drawline_lab4
drawline_lab3:
	; y1 < y0
	mov	r15,r17
	sub	r15,r19
	ldi	r23,-1
drawline_lab4:
	;   int err = dx-dy;
	mov	r9,r14
	clr	r10
	sub	r9,r15
	sbc	r10,regzero
	;   while(1){
drawline_lab5:
	;     setpixel(x0, y0, color);
	rcall	setpixel
	;     if (x0==x1 && y0==y1) break;
	cp	r16,r18
	brne	drawline_lab6
	cp	r17,r19
	breq	drawline_lab7
drawline_lab6:
	;     e2 = 2*err;
	mov	r26,r9
	mov	r27,r10
	lsl	r26
	rol	r27
	;     if (e2 > -dy) { err -= dy; x0 += sx; }
	sbrs	r27,7
	rjmp	drawline_lab8 ; -> e2 > -dy
	; e2 < 0
	cpi	r27,255
	brne	drawline_lab9 ; -> e2 < -dy
	neg	r15
	cp	r15,r26
	brsh	drawline_lab12 ; -> e2 <= -dy
	neg	r15
drawline_lab8:
	; e2 > -dy
	sub	r9,r15
	sbc	r10,regzero
	add	r16,r24
	rjmp	drawline_lab9
drawline_lab12:
	neg	r15
drawline_lab9:
	;     if (e2 < dx) { err += dx; y0 += sy; }
	sbrc	r27,7
	rjmp	drawline_lab10 ; -> e2 < dx
	; e2 > 0
	tst	r27
	brne	drawline_lab11 ; -> e2 > dx
	cp	r26,r14
	brsh	drawline_lab11 ; -> e2 >= dx
drawline_lab10:
	; e2 < dx
	add	r9,r14
	adc	r10,regzero
	add	r17,r23
drawline_lab11:
	rjmp	drawline_lab5
drawline_lab7:
	out	PORTD,r22
	ret


; copyblock6502-Struktur:
	; <struct>
	;   <name>copyblock6502structure</name>
	;   <titleg>copyblock6502-Struktur</titleg>
	;   <titlee>copyblock6502 structure</titlee>
	;   <attr>
	;     <name>src</name>
	;     <descg>Pointer auf den Quell-Speicherbereich</descg>
	;     <desce>pointer to the source memory block</desce>
	;     <offset>0</offset>
	;     <size>2</size>
	;   </attr>
	;   <attr>
	;     <name>dest</name>
	;     <descg>Pointer auf den Ziel-Speicherbereich</descg>
	;     <desce>pointer to the destination memory block</desce>
	;     <offset>2</offset>
	;     <size>2</size>
	;   </attr>
	;   <attr>
	;     <name>wsrc</name>
	;     <descg>Breite des Quell-Speicherblocks</descg>
	;     <desce>width of source memory block</desce>
	;     <offset>4</offset>
	;     <size>1</size>
	;   </attr>
	;   <attr>
	;     <name>hsrc</name>
	;     <descg>Hoehe des Quell-Speicherblocks</descg>
	;     <desce>height of source memory block</desce>
	;     <offset>5</offset>
	;     <size>1</size>
	;   </attr>
	;   <attr>
	;     <name>modwsrc</name>
	;     <descg>Quell-Speicherblock: Anzahl Bytes, die bis zur naechsten Zeile ueberlesen werden muessen</descg>
	;     <desce>source memory block: number of bytes to skip to read the next line</desce>
	;     <offset>6</offset>
	;     <size>1</size>
	;   </attr>
	;   <attr>
	;     <name>modwdest</name>
	;     <descg>Ziel-Speicherblock: Anzahl Bytes, die bis zur naechsten Zeile ueberlesen werden muessen</descg>
	;     <desce>destination memory block: number of bytes to skip to write the next line</desce>
	;     <offset>7</offset>
	;     <size>1</size>
	;   </attr>
	; </struct>


copyblock6502:
	; <proc>
	;   <name>copyblock6502</name>
	;   <descg>Kopieren eines Datenblocks</descg>
	;   <desce>copy a data block</desce>
	;   <input>
	;     <rparam>
	;       <name>x</name>
	;       <descg>Low-Byte des Pointers auf die &lt;a href="#copyblock6502structure"&gt;copyblock6502-Struktur&lt;/a&gt;</descg>
	;       <desce>low byte of the pointer to the &lt;a href="#copyblock6502structure"&gt;copyblock6502 structure&lt;/a&gt;</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <descg>High-Byte des Pointers auf die &lt;a href="#copyblock6502structure"&gt;copyblock6502-Struktur&lt;/a&gt;</descg>
	;       <desce>high byte of the pointer to the &lt;a href="#copyblock6502structure"&gt;copyblock6502 structure&lt;/a&gt;</desce>
	;     </rparam>
	;   </input>
	; </proc>

	mov	zl,regx
	mov	zh,regy
	subi	zh,(256-MEMOFF6502)
	ldd	xl,z+COPYBLOCK6502_SRC
	ldd	xh,z+COPYBLOCK6502_SRC+1
	subi	xh,(256-MEMOFF6502)
	ldd	r19,z+COPYBLOCK6502_WSRC
	ldd	r20,z+COPYBLOCK6502_HSRC
	ldd	r21,z+COPYBLOCK6502_MODWSRC
	ldd	r22,z+COPYBLOCK6502_MODWDEST
	ldd	r16,z+COPYBLOCK6502_DEST
	ldd	r17,z+COPYBLOCK6502_DEST+1
	mov	zl,r16
	mov	zh,r17
	subi	zh,(256-MEMOFF6502)
	; copy block
copyblock_lab3:
	mov	r16,r19
copyblock_lab1:
	ld	r17,x+
	st	z+,r17
	dec	r16
	brne	copyblock_lab1
	add	xl,r21
	adc	xh,regzero
	add	zl,r22
	adc	zh,regzero
	dec	r20
	brne    copyblock_lab3
	ret


; copychars6502-Struktur:
	; <struct>
	;   <name>copychars6502structure</name>
	;   <titleg>copychars6502-Struktur</titleg>
	;   <titlee>copychars6502 structure</titlee>
	;   <attr>
	;     <name>src</name>
	;     <descg>Pointer auf den Quell-Speicherbereich</descg>
	;     <desce>pointer to the source memory block</desce>
	;     <offset>0</offset>
	;     <size>2</size>
	;   </attr>
	;   <attr>
	;     <name>deststartchar</name>
	;     <descg>Start char im Ziel-Speicherblock</descg>
	;     <desce>start char in destination memory block</desce>
	;     <offset>2</offset>
	;     <size>1</size>
	;   </attr>
	;   <attr>
	;     <name>numchars</name>
	;     <descg>Anzahl zu kopierende chars</descg>
	;     <desce>number of chars to copy</desce>
	;     <offset>3</offset>
	;     <size>1</size>
	;   </attr>
	; </struct>


copychars6502:
	; <proc>
	;   <name>copychars6502</name>
	;   <descg>Kopieren von Char-Daten (C64 Style nach R162 Style)</descg>
	;   <desce>copy char data (C64 style to R162 style)</desce>
	;   <input>
	;     <rparam>
	;       <name>x</name>
	;       <descg>Low-Byte des Pointers auf die &lt;a href="#copychars6502structure"&gt;copychars6502-Struktur&lt;/a&gt;</descg>
	;       <desce>low byte of the pointer to the &lt;a href="#copychars6502structure"&gt;copychars6502 structure&lt;/a&gt;</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <descg>High-Byte des Pointers auf die &lt;a href="#copychars6502structure"&gt;copychars6502-Struktur&lt;/a&gt;</descg>
	;       <desce>high byte of the pointer to the &lt;a href="#copychars6502structure"&gt;copychars6502 structure&lt;/a&gt;</desce>
	;     </rparam>
	;   </input>
	; </proc>

	mov	zl,regx
	mov	zh,regy
	subi	zh,(256-MEMOFF6502)
	ldd	xl,z+COPYCHARS6502_SRC
	ldd	xh,z+COPYCHARS6502_SRC+1
	subi	xh,(256-MEMOFF6502)
	ldd	r18,z+COPYCHARS6502_DESTSTARTCHAR
	ldd	r19,z+COPYCHARS6502_NUMCHARS
	; copy chars
	mov	zl,r18
copychars_lab3:
	lds	zh,CHARDEFSRAM
	lds	r17,NUMOFCHARLINES
copychars_lab1:
	ld	r16,x+
	st	z,r16
	inc	zh
	dec	r17
	brne	copychars_lab1
	inc	zl
	dec	r19
	brne    copychars_lab3
	ret


; vic20multicolmapping6502-Struktur:
	; <struct>
	;   <name>vic20multicolmapping6502structure</name>
	;   <titlee>vic20multicolmapping6502 structure</titlee>
	;   <attr>
	;     <name>screenptr</name>
	;     <desce>pointer to VIC20 screen memory</desce>
	;     <offset>0</offset>
	;     <size>2</size>
	;   </attr>
	;   <attr>
	;     <name>charpage</name>
	;     <desce>high byte of VIC20 char data (page aligned)</desce>
	;     <offset>2</offset>
	;     <size>1</size>
	;   </attr>
	;   <attr>
	;     <name>coltabpage</name>
	;     <desce>high byte of color table (page aligned)</desce>
	;     <offset>3</offset>
	;     <size>1</size>
	;   </attr>
	;   <attr>
	;     <name>numofrows</name>
	;     <desce>number of rows to process</desce>
	;     <offset>4</offset>
	;     <size>1</size>
	;   </attr>
	;   <attr>
	;     <name>destmap</name>
	;     <desce>pointer to R162 multicolor memory</desce>
	;     <offset>5</offset>
	;     <size>2</size>
	;   </attr>
	; </struct>


vic20multicolmapping6502:
	; <proc>
	;   <name>vic20multicolmapping6502</name>
	;   <descg>Kopieren der VIC20 Multicolor-Map auf die R162 Multicolor-Map</descg>
	;   <desce>copy VIC20 multi color map to R162 multi color map</desce>
	;   <input>
	;     <rparam>
	;       <name>x</name>
	;       <descg>Low-Byte des Pointers auf die &lt;a href="#vic20multicolmapping6502structure"&gt;vic20multicolmapping6502-Struktur&lt;/a&gt;</descg>
	;       <desce>low byte of the pointer to the &lt;a href="#vic20multicolmapping6502structure"&gt;vic20multicolmapping6502 structure&lt;/a&gt;</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <descg>High-Byte des Pointers auf die &lt;a href="#vic20multicolmapping6502structure"&gt;vic20multicolmapping6502-Struktur&lt;/a&gt;</descg>
	;       <desce>high byte of the pointer to the &lt;a href="#vic20multicolmapping6502structure"&gt;vic20multicolmapping6502 structure&lt;/a&gt;</desce>
	;     </rparam>
	;   </input>
	; </proc>

	mov	r13,yl
	mov	r14,yh
	mov	zl,regx
	mov	zh,regy
	subi	zh,(256-MEMOFF6502)
	; pointer to VIC20 screen map in x
	ldd	xl,z+VIC20MULTICOLMAPPING_SCREENPTR
	ldd	xh,z+VIC20MULTICOLMAPPING_SCREENPTR+1
	subi	xh,(256-MEMOFF6502)
	; high byte of VIC20 char data in r15 (page aligned)
	ldd	r15,z+VIC20MULTICOLMAPPING_CHARPAGE
	add	r15,regmemoff6502
	; high byte of color table in r20 (page aligned)
	ldd	r20,z+VIC20MULTICOLMAPPING_COLTABPAGE
	subi	r20,(256-MEMOFF6502)
	; number of rows to process in r22
	; -> process all rows in several vsync phases
	;    by limiting NUMOFROWS and adapting SCREENPTR
	ldd	r22,z+VIC20MULTICOLMAPPING_NUMOFROWS
	; pointer to multicol map in z
	ldd	r18,z+VIC20MULTICOLMAPPING_DESTMAP
	ldd	r19,z+VIC20MULTICOLMAPPING_DESTMAP+1
	mov	zl,r18
	mov	zh,r19
	subi	zh,(256-MEMOFF6502)
	lds	r23,NUMOFCHARLINES
	ldi	r16,80
	mul	r23,r16
	mov	r18,r0
	mov	r19,r1
	subi	r18,low(44)
	sbci	r19,high(44)
vic20multicolmapping_lab2:
	; number of VIC20 columns in r21
	ldi	r21,22
vic20multicolmapping_lab1:
	; save registers
	mov	r9,zl
	mov	r10,zh
	; get char from VIC20 screen mem
	ld	r16,x+
	; -> get pointer to VIC20 char data in y
	mul	r16,r23
	mov	yl,r0
	mov	yh,r15
	add	yh,r1
	; save registers
	mov	r11,xl
	mov	r12,xh
	; color table in x
	mov	xh,r20
	; copy char data of actual char to multicolor map
	mov	r24,r23
vic20multicolmapping_lab3:
	; get one line of char data
	ld	xl,y+
	mov	r16,xl
	; extract first half byte
	andi	xl,0xf0
	swap	xl
	; write to graphic color map
	ld	r17,x
	st	z+,r17
	; extract second half byte
	mov	xl,r16
	andi	xl,0x0f
	; write to graphic color map
	ld	r17,x
	st	z+,r17
	; next line
	ldi	r16,80-2
	add	zl,r16
	adc	zh,regzero
	dec	r24
	brne	vic20multicolmapping_lab3
	; restore registers
	mov	zl,r9
	mov	zh,r10
	mov	xl,r11
	mov	xh,r12
	; next char in the same row
	adiw	zl,2
	dec	r21
	brne	vic20multicolmapping_lab1
	; next row
	add	zl,r18
	adc	zh,r19
	dec	r22
	brne	vic20multicolmapping_lab2
	mov	yl,r13
	mov	yh,r14
	ret
