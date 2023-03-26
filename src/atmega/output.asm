; output.asm, v1.6: text output functions for the r162 system
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


setcursorpos6502:
	; <proc>
	;   <name>setcursorpos6502</name>
	;   <descg>Setze die Cursor-Position</descg>
	;   <desce>set cursor position</desce>
	;   <input>
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

	mov	r18,regx
	mov	r19,regy


setcursorpos:
	; Setze die Cursor-Position
	; Signatur setcursorpos (in: r18,r19; out: -; changed: r0,r1,r16)
	; Eingabe: r18 -> x-Position
	; Eingabe: r19 -> y-Position
	; Veraenderte Register: r0, r1, r16

	lds	r16,NUMCHARCOLS
	mul	r19,r16
	add	r0,r18
	adc	r1,regzero
	lds	r16,TEXTMAP
	add	r0,r16
	lds	r16,TEXTMAP+1
	adc	r1,r16
	sts	ACTCURADDR,r0
	sts	ACTCURADDR+1,r1
	sts	CURX,r18
	sts	CURY,r19
	ret


cursorleft6502:
	; <proc>
	;   <name>cursorleft6502</name>
	;   <descg>Bewegung des Cursors nach links</descg>
	;   <desce>move cursor to the left</desce>
	; </proc>

cursorleft:
	; Bewegung des Cursors nach links
	; Signatur cursorleft (in: -; out: -; changed: x)
	; Veraenderte Register: x

	lds	xl,CURX
	tst	xl
	breq	cursorleft_lab1
cursorleft_lab4:
	dec	xl
	sts	CURX,xl
	lds	xl,ACTCURADDR
	lds	xh,ACTCURADDR+1
	sbiw	xl,1
	sts	ACTCURADDR,xl
	sts	ACTCURADDR+1,xh
cursorleft_lab3:
	ret
cursorleft_lab1:
	lds	xl,CURY
	tst	xl
	breq	cursorleft_lab3
	dec	xl
	sts	CURY,xl
	lds	xl,NUMCHARCOLS
	rjmp	cursorleft_lab4


cursorright6502:
	; <proc>
	;   <name>cursorright6502</name>
	;   <descg>Bewegung des Cursors nach rechts</descg>
	;   <desce>move cursor to the right</desce>
	; </proc>


cursorright:
	; Bewegung des Cursors nach rechts
	; Signatur cursorright (in: -; out: -; changed: x)
	; Veraenderte Register: x

	lds	xl,CURX
	inc	xl
	lds	xh,NUMCHARCOLS
	cp	xl,xh
	breq	cursorright_lab1
	sts	CURX,xl
cursorright_lab4:
	lds	xl,ACTCURADDR
	lds	xh,ACTCURADDR+1
	adiw	xl,1
	sts	ACTCURADDR,xl
	sts	ACTCURADDR+1,xh
cursorright_lab3:
	ret
cursorright_lab1:
	lds	xl,CURY
	inc	xl
	lds	xh,NUMCHARROWS
	cp	xl,xh
	breq	cursorright_lab3
	sts	CURY,xl
	sts	CURX,regzero
	rjmp	cursorright_lab4


cursorup6502:
	; <proc>
	;   <name>cursorup6502</name>
	;   <descg>Bewegung des Cursors nach oben</descg>
	;   <desce>move cursor up</desce>
	; </proc>


cursorup:
	; Bewegung des Cursors nach oben
	; Signatur cursorup (in: -; out: -; changed: x)
	; Veraenderte Register: x

	lds	xl,CURY
	tst	xl
	breq	cursorup_lab3
	dec	xl
	sts	CURY,xl
	lds	xl,ACTCURADDR
	lds	xh,NUMCHARCOLS
	sub	xl,xh
	sts	ACTCURADDR,xl
	lds	xh,ACTCURADDR+1
	sbc	xh,regzero
	sts	ACTCURADDR+1,xh
cursorup_lab3:
	ret


cursordown6502:
	; <proc>
	;   <name>cursordown6502</name>
	;   <descg>Bewegung des Cursors nach unten</descg>
	;   <desce>move cursor down</desce>
	; </proc>


cursordown:
	; Bewegung des Cursors nach unten
	; Signatur cursordown (in: -; out: -; changed: x)
	; Veraenderte Register: x

	lds	xl,CURY
	inc	xl
	lds	xh,NUMCHARROWS
	cp	xl,xh
	breq	cursordown_lab3
	sts	CURY,xl
	lds	xl,ACTCURADDR
	lds	xh,NUMCHARCOLS
	add	xl,xh
	sts	ACTCURADDR,xl
	lds	xh,ACTCURADDR+1
	adc	xh,regzero
	sts	ACTCURADDR+1,xh
cursordown_lab3:
	ret


scrollup6502:
	; <proc>
	;   <name>scrollup6502</name>
	;   <descg>Eine Zeile nach oben scrollen im Text-Modus</descg>
	;   <desce>scroll one line up in text mode</desce>
	; </proc>

	push	yl
	push	yh
	rcall	scrollup
	pop	yh
	pop	yl
	ret


scrollup:
	; Eine Zeile nach oben scrollen
	; Signatur scrollup (in: -; out: -; changed: r16,17,r19,y,z)
	; Veraenderte Register: r16, r17, r19, y, z

	lds	r16,PAGERACTIVE
	tst	r16
	brne	scrollup_lab5
scrollup_lab6:
	lds	zl,TEXTMAP
	lds	zh,TEXTMAP+1
	mov	yl,zl
	mov	yh,zh
	lds	r16,NUMCHARCOLS
	add	yl,r16
	adc	yh,regzero
	lds	r19,NUMCHARROWS
	dec	r19
scrollup_lab1:
	lds	r16,NUMCHARCOLS
scrollup_lab2:
	ld	r17,y+
	st	z+,r17
	dec	r16
	brne	scrollup_lab2
	dec	r19
	brne	scrollup_lab1
scrollup_lab4:
	lds	r16,NUMCHARCOLS
	ldi	r17,' '
scrollup_lab3:
	st	z+,r17
	dec	r16
	brne	scrollup_lab3
	ret
scrollup_lab5:
	lds	r16,PAGERCNT
	inc	r16
	sts	PAGERCNT,r16
	lds	r17,NUMCHARROWS
	cp	r16,r17
	brne	scrollup_lab6
	sts	PAGERCNT,regzero
	; getchwait (in: -; out: r16; changed: r16,r17,z)
	call	getchwait
	cpi	r16,'q'
	breq	scrollup_lab8
	cpi	r16,10
	brne	scrollup_lab6
	lds	r16,NUMCHARROWS
	dec	r16
	sts	PAGERCNT,r16
	rjmp	scrollup_lab6
scrollup_lab8:
	sts	PAGERBREAK,r16
	ret


println6502:
	; <proc>
	;   <name>println6502</name>
	;   <descg>Setze den Cursor auf den Anfang der naechsten Zeile</descg>
	;   <desce>set cursor to the beginning of the next line</desce>
	; </proc>

	push	yl
	push	yh
	rcall	println
	pop	yh
	pop	yl
	ret


println:
	; Sprung auf naechste Zeile
	; Signatur println (in: -; out: -; changed: r16,r17,r19,r20,x,y,z)
	; Veraenderte Register: r16, r17, r19, r20, x, y, z

	lds	xl,ACTCURADDR
	lds	xh,ACTCURADDR+1
	lds	r20,CURX
	lds	r17,NUMCHARCOLS
	sub	r17,r20
	sts	CURX,regzero
	lds	r16,CURY
	inc	r16
	lds	r19,NUMCHARROWS
	cp	r16,r19
	breq	println_lab1
	sts	CURY,r16
	add	xl,r17
	adc	xh,regzero
println_lab2:
	sts	ACTCURADDR,xl
	sts	ACTCURADDR+1,xh
	ret	
println_lab1:
	; scrollup (in: -; out: -; changed: r16,17,r19,y,z)
	rcall	scrollup
	sub	xl,r20
	sbc	xh,regzero
	rjmp	println_lab2


printchar6502:
	; <proc>
	;   <name>printchar6502</name>
	;   <descg>Zeichen an der aktuellen Cursor-Position ausgeben</descg>
	;   <desce>output character at the actual cursor position</desce>
	;   <input>
	;     <rparam>
	;       <name>a</name>
	;       <descg>Zeichen</descg>
	;       <desce>character</desce>
	;     </rparam>
	;   </input>
	; </proc>

	push	yl
	push	yh
	mov	r18,rega
	rcall	printchar
	pop	yh
	pop	yl
	ret


printcharnoctrl6502:
	; <proc>
	;   <name>printcharnoctrl6502</name>
	;   <descg>Zeichen (aber kein "Kontroll-Zeichen") an der aktuellen Cursor-Position ausgeben</descg>
	;   <desce>output character (but no "control character") at the actual cursor position</desce>
	;   <input>
	;     <rparam>
	;       <name>a</name>
	;       <descg>Zeichen</descg>
	;       <desce>character</desce>
	;     </rparam>
	;   </input>
	; </proc>

	push	yl
	push	yh
	mov	r18,rega
	rcall	printcharnoctrl
	pop	yh
	pop	yl
	ret


printchar:
	; Zeichen auf dem Bildschirm ausgeben
	; Signatur printchar (in: r18; out: -; changed: r16,r17,r19,r20,x,y,z)
	; Eingabe: r18 -> Zeichen, das an der aktuellen Cursor-Position ausgegeben werden soll
 	; Veraenderte Register: r16, r17, r19, r20, x, y, z

	cpi	r18,32
	brsh	printcharnoctrl
	cpi	r18,10
	; println (in: -; out: -; changed: r16,r17,r19,r20,x,y,z)
	breq	println
	cpi	r18,KEYCURLEFT
	breq	printchar_lab5
	cpi	r18,KEYCURDOWN
	breq	printchar_lab6
	cpi	r18,KEYCURRIGHT
	breq	printchar_lab7
	cpi	r18,KEYCURUP
	breq	printchar_lab8
	cpi	r18,KEYBACKSPACE
	breq	printchar_lab9
	cpi	r18,KEYTAB
	breq	printchar_lab4
	ret


printcharnoctrl:
	; Zeichen auf dem Bildschirm ausgeben (aber keine "Kontroll-Zeichen")
	; Signatur printcharnoctrl (in: r18; out: -; changed: r16,r17,r19,x,y,z)
	; Eingabe: r18 -> Zeichen, das an der aktuellen Cursor-Position ausgegeben werden soll
 	; Veraenderte Register: r16, r17, r19, x, y, z

	lds	xl,ACTCURADDR
	lds	xh,ACTCURADDR+1
	; actual cursor position at the last position of screen?
	lds	r16,NUMCHARROWS
	dec	r16
	lds	r17,CURY
	cp	r16,r17
	brne	printchar_lab1
	lds	r16,NUMCHARCOLS
	dec	r16
	lds	r17,CURX
	cp	r16,r17
	brne	printchar_lab1
	; scrollup (in: -; out: -; changed: r16,17,r19,y,z)
	rcall	scrollup
	lds	r16,NUMCHARCOLS
	sub	xl,r16
	sbc	xh,regzero
printchar_lab1:
	st	x+,r18
	sts	ACTCURADDR,xl
	sts	ACTCURADDR+1,xh
	lds	xl,CURX
	inc	xl
	lds	r16,NUMCHARCOLS
	cp	xl,r16
	breq	printchar_lab2
	sts	CURX,xl
	ret
printchar_lab2:
	sts	CURX,regzero
	lds	xl,CURY
	inc	xl
	lds	r16,NUMCHARROWS
	cp	xl,r16
	breq	printchar_lab3
	sts	CURY,xl
printchar_lab3:
	ret
printchar_lab5:
	; cursorleft (in: -; out: -; changed: x)
	rjmp	cursorleft
printchar_lab6:
	; cursordown (in: -; out: -; changed: x)
	rjmp	cursordown
printchar_lab7:
	; cursorright (in: -; out: -; changed: x)
	rjmp	cursorright
printchar_lab8:
	; cursorup (in: -; out: -; changed: x)
	rjmp	cursorup
printchar_lab9:
	; backspace
	; cursorleft (in: -; out: -; changed: x)
	rcall	cursorleft
	lds	xl,ACTCURADDR
	lds	xh,ACTCURADDR+1
	ldi	r16,32
	st	x,r16
	ret
printchar_lab4:
	ldi	r18,' '
	rcall	printcharnoctrl
	rjmp	printcharnoctrl


printstring6502:
	; <proc>
	;   <name>printstring6502</name>
	;   <descg>Zeichenkette an der aktuellen Cursor-Position ausgeben</descg>
	;   <desce>output string at the actual cursor position</desce>
	;   <input>
	;     <rparam>
	;       <name>x</name>
	;       <descg>Low-Byte des Zeigers auf die Zeichenkette</descg>
	;       <desce>low byte of the pointer to the string</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <descg>High-Byte des Zeigers auf die Zeichenkette</descg>
	;       <desce>high byte of the pointer to the string</desce>
	;     </rparam>
	;   </input>
	; </proc>

	push	yl
	push	yh
	mov	zl,regx
	mov	zh,regy
	subi	zh,(256-MEMOFF6502)
	rcall	printstring_lab0
	pop	yh
	pop	yl
	ret


printstring:
	; Ausgabe des Strings auf dem Bildschirm
	; Signatur printstring (in: r18,r19; out: -; changed: r16-r20,x,y,z)
	; Eingabe: r18, r19 -> String, der an der aktuellen Cursor-Position ausgegeben werden soll
	; Veraenderte Register: r16-r20, x, y, z

	mov	zl,r18
	mov	zh,r19
printstring_lab0:
	ld	r18,z+
	tst	r18
	breq	printstring_lab1
	push	zl
	push	zh
	; printchar (in: r18; out: -; changed: r16,r17,r19,r20,x,y,z)
	rcall	printchar
	pop	zh
	pop	zl
	rjmp	printstring_lab0
printstring_lab1:
	ret


printstringflash:
	; Ausgabe des Strings auf dem Bildschirm
	; Signatur printstringflash (in: z; out: -; changed: r16-r20,x,y,z)
	; Eingabe: z -> String, der an der aktuellen Cursor-Position ausgegeben werden soll
	; Veraenderte Register: r16-r20, x, y, z

	lpm	r18,z+
	tst	r18
	breq	printstringflash_lab1
	push	zl
	push	zh
	; printchar (in: r18; out: -; changed: r16,r17,r19,r20,x,y,z)
	rcall	printchar
	pop	zh
	pop	zl
	rjmp	printstringflash
printstringflash_lab1:
	ret
