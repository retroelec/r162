; util.asm, v1.6: utility functions for the r162 system
; 
; Copyright (C) 2010-2017 retroelec <retroelec42@gmail.com>
; Exception: Routine div16x166502 is adapted from the ATMEL Applicate Note
;            "AVR200: Multiply and Divide Routines".
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


strncmp:
	; Vergleichen von zwei Strings
	; Signatur strncmp (in: r18,r19,x,z; out: r16; changed: r16-r18,x,z)
	; Eingabe: x -> Pointer auf den 1. String (str1)
	; Eingabe: z -> Pointer auf den 2. String (str2)
	; Eingabe: r18 -> n
	; Eingabe: r19 -> 2. String (z) vom Flash- (r19 == 0) oder vom SRAM-Speicher (r19 != 0) holen
	; Ausgabe: r16 -> str1 > str2 (== 1) / str1 < str2 (== 255) / str1 == str2 (== 0)
	; Veraenderte Register: r16-r18, x, z

	tst	r18
	breq	strncmp_lab3
	dec	r18
	ld	r16,x+
	tst	r19
	breq	strncmp_lab6
	ld	r17,z+
	rjmp	strncmp_lab4
strncmp_lab6:
	lpm	r17,z+
strncmp_lab4:
	cp	r16,r17
	; r16 < r17 -> lab2
	brlo	strncmp_lab2
	; r16 > r17 -> lab1
	brne	strncmp_lab1
	tst	r16
	breq	strncmp_lab5
	rjmp	strncmp
strncmp_lab1:
	ldi	r16,1
	ret
strncmp_lab2:
	ldi	r16,255
	ret
strncmp_lab3:
	clr	r16
strncmp_lab5:
	ret


mul8x86502:
	; <proc>
	;   <name>mul8x86502</name>
	;   <desce>multiplication of two unsigned 8 bit values</desce>
	;   <input>
	;     <rparam>
	;       <name>x</name>
	;       <desce>value 1</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <desce>value 2</desce>
	;     </rparam>
	;   </input>
	;   <output>
	;     <mparam>
	;       <name>RMUL6502</name>
	;       <desce>result (16 bit value)</desce>
	;     </mparam>
	;   </output>
	; </proc>

	mul	regx,regy
	sts	RMUL6502,r0
	sts	RMUL6502+1,r1
	ret


mul16x16mod6502:
	; <proc>
	;   <name>mul16x16mod6502</name>
	;   <descg>Multiplikation von zwei 16-Bit-Werten modulo 2^16</descg>
	;   <desce>multiplication of two 16 bit values modulo 2^16</desce>
	;   <input>
	;     <mparam>
	;       <name>RMUL6502</name>
	;       <descg>Wert 1 (16-Bit-Zahl)</descg>
	;       <desce>value 1 (16 bit value)</desce>
	;     </mparam>
	;     <mparam>
	;       <name>RMUL6502+2</name>
	;       <descg>Wert 2 (16-Bit-Zahl)</descg>
	;       <desce>value 2 (16 bit value)</desce>
	;     </mparam>
	;   </input>
	;   <output>
	;     <mparam>
	;       <name>RMUL6502</name>
	;       <descg>Resultat (16-Bit-Wert)</descg>
	;       <desce>result (16 bit value)</desce>
	;     </mparam>
	;   </output>
	; </proc>

	lds	r16,RMUL6502
	lds	r17,RMUL6502+1
	lds	r18,RMUL6502+2
	lds	r19,RMUL6502+3
	mul	r16,r18
	mov	r20,r0
	mov	r21,r1
	mul	r17,r18
	add	r21,r0
	mul	r16,r19
	add	r21,r0
	sts	RMUL6502,r20
	sts	RMUL6502+1,r21
	ret


div16x166502:
	; <proc>
	;   <name>div16x166502</name>
	;   <descg>Division eines 16-Bit-Werts (Dividend) durch einen 16-Bit-Wert (Divisor)</descg>
	;   <desce>division of a 16 bit value (dividend) by a  16 bit value (divisor)</desce>
	;   <input>
	;     <mparam>
	;       <name>RMUL6502</name>
	;       <descg>Dividend (16-Bit-Zahl)</descg>
	;       <desce>dividend (16 bit value)</desce>
	;     </mparam>
	;     <mparam>
	;       <name>RMUL6502+2</name>
	;       <descg>Divisor (16-Bit-Zahl)</descg>
	;       <desce>divisor (16 bit value)</desce>
	;     </mparam>
	;   </input>
	;   <output>
	;     <mparam>
	;       <name>RMUL6502</name>
	;       <descg>Quotient der Division (16-Bit-Wert)</descg>
	;       <desce>quotient of division (16 bit value)</desce>
	;     </mparam>
	;     <mparam>
	;       <name>RMUL6502+2</name>
	;       <descg>Rest der Division (16-Bit-Wert)</descg>
	;       <desce>remainder of division (16 bit value)</desce>
	;     </mparam>
	;   </output>
	; </proc>

	; Routine von AVR ("div16u" - 16/16 Bit Unsigned Division)
	lds	r16,RMUL6502
	lds	r17,RMUL6502+1
	lds	r18,RMUL6502+2
	lds	r19,RMUL6502+3
	clr	r14
	sub	r15,r15
	ldi	r20,17
div16x166502_lab1:
	rol	r16
	rol	r17
	dec	r20
	brne	div16x166502_lab2
	sts	RMUL6502,r16
	sts	RMUL6502+1,r17
	sts	RMUL6502+2,r14
	sts	RMUL6502+3,r15
	ret
div16x166502_lab2:
	rol	r14
	rol	r15
	sub	r14,r18
	sbc	r15,r19
	brcc	div16x166502_lab3
	add	r14,r18
	adc	r15,r19
	clc
	rjmp	div16x166502_lab1
div16x166502_lab3:
	sec
	rjmp	div16x166502_lab1


mul8x16:
	; Multiplikation eines 1-Byte-Werts mit einem 2-Byte-Wert
	; Signatur mul8x16 (in: r16-r18; out: r2-r4; changed: r0-r4)
	; Eingabe: r16 -> 8-Bit-Zahl
	; Eingabe; r17-r18 -> 16-Bit-Zahl
	; Ausgabe: r2-r4 -> 24-Bit-Zahl
	; Veraenderte Register: r0-r4

	mul	r16,r17
	mov	r2,r0
	mov	r3,r1
	mul	r16,r18
	mov	r4,r1
	add	r3,r0
	brcc	mul8x16_lab1
	inc	r4
mul8x16_lab1:
	ret


atoi6502:
	; <proc>
	;   <name>atoi6502</name>
	;   <descg>Zeichenkette in eine Ganzzahl umwandeln</descg>
	;   <desce>convert a string to an integer</desce>
	;   <input>
	;     <rparam>
	;       <name>x</name>
	;       <descg>Low-Byte des Pointers auf die Zeichenkette</descg>
	;       <desce>low byte of the pointer to the string</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <descg>High-Byte des Pointers auf die Zeichenkette</descg>
	;       <desce>high byte of the pointer to the string</desce>
	;     </rparam>
	;   </input>
	;   <output>
	;     <mparam>
	;       <name>RATOI6502</name>
	;       <descg>Ganzzahl (16-Bit-Wert)</descg>
	;       <desce>integer (16 bit value)</desce>
	;     </mparam>
	;   </output>
	; </proc>

	mov	xl,regx
	mov	xh,regy
	subi	xh,(256-MEMOFF6502)
	push	r2
	push	r3
	push	r4
	rcall	atoi
	pop	r4
	pop	r3
	pop	r2
	sts	RATOI6502,r17
	sts	RATOI6502+1,r18
	ret


atoi:
	; String in einen 2-Byte-Wert umwandeln
	; Signatur atoi (in: x; out: r17,r18,x; changed: r0-r4,r16-r19,x)
	; Eingabe: x -> Pointer auf String
	; Ausgabe: r17, r18 -> 2-Byte-Wert
	; Ausgabe: x -> Ende String
	; Veraenderte Register: r0-r4, r16-r19, x
	; Pseudocode:
        ;   atoi(str) {
        ;     tmp = 0;
        ;     num = 0;
        ;     loop:
        ;       if (*str == 0) return num;
        ;       tmp = *str-'0';
        ;       num = num*10;
        ;       num = num+tmp;
        ;       str++;
        ;     goto loop;
        ;   }

	ldi	r16,10
	ldi	r17,0
	ldi	r18,0
atoi_lab1:
	ld	r19,x+
	tst	r19
	breq	atoi_lab2
	subi	r19,'0'
	; mul8x16 (in: r16-r18; out: r2-r4; changed: r0-r4)
	rcall	mul8x16
	mov	r17,r2
	mov	r18,r3
	add	r17,r19
	adc	r18,regzero
	rjmp	atoi_lab1
atoi_lab2:
	ret


itoa6502:
	; <proc>
	;   <name>itoa6502</name>
	;   <descg>Ganzzahl in eine Zeichenkette umwandeln</descg>
	;   <desce>convert an integer to a string</desce>
	;   <input>
	;     <rparam>
	;       <name>x</name>
	;       <descg>Low-Byte der Ganzzahl (16-Bit-Wert)</descg>
	;       <desce>low byte of the integer (16 bit value)</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <descg>High-Byte der Ganzzahl (16-Bit-Wert)</descg>
	;       <desce>high byte of the integer (16 bit value)</desce>
	;     </rparam>
	;   </input>
	;   <output>
	;     <mparam>
	;       <name>ITOASTRING</name>
	;       <descg>Zeiger auf die Zeichenkette</descg>
	;       <desce>pointer to the string</desce>
	;     </mparam>
	;   </output>
	; </proc>

	mov	r18,regx
	mov	r19,regy


itoa:
	; 2-Byte-Wert in einen String umwandeln
	; Signatur itoa (in: r18,r19; out: -; changed: r16-r21,z)
	; Eingabe: r18, r19 -> 16-Bit-Zahl, die in einen String umgewandelt werden soll
	; Veraenderte Register: r16-r21, z

	clr	r21
itoa_lab6:
	ldi	zl,low(ITOASTRING)
	ldi	zh,high(ITOASTRING)
	ldi	r16,low(10000)
	ldi	r17,high(10000)
	rcall	itoa_lab1
	ldi	r16,low(1000)
	ldi	r17,high(1000)
	rcall	itoa_lab1
itoa_lab5:
	ldi	r16,100
	clr	r17
	rcall	itoa_lab1
	ldi	r16,10
	rcall	itoa_lab1
	ldi	r21,1
	ldi	r16,1
	rcall	itoa_lab1
	st	z+,regzero
	ret
itoa_lab1:
	ldi	r20,'0'-1
itoa_lab2:
	inc	r20
	sub	r18,r16
	sbc	r19,r17
	brcc	itoa_lab2
	add	r18,r16
	adc	r19,r17
	cpi	r21,1
	breq	itoa_lab4
	cpi	r20,'0'
	breq	itoa_lab3
	ldi	r21,1
itoa_lab4:
	st	z+,r20
itoa_lab3:
	ret


itoaformat6502:
	; <proc>
	;   <name>itoaformat6502</name>
	;   <descg>Ganzzahl in eine Zeichenkette umwandeln (mit fuehrenden Nullen formatiert)</descg>
	;   <desce>convert an integer to a string (formatted with leading zeros)</desce>
	;   <input>
	;     <rparam>
	;       <name>x</name>
	;       <descg>Low-Byte der Ganzzahl (16-Bit-Wert)</descg>
	;       <desce>low byte of the integer (16 bit value)</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <descg>High-Byte der Ganzzahl (16-Bit-Wert)</descg>
	;       <desce>high byte of the integer (16 bit value)</desce>
	;     </rparam>
	;   </input>
	;   <output>
	;     <mparam>
	;       <name>ITOASTRING</name>
	;       <descg>Zeiger auf die Zeichenkette</descg>
	;       <desce>pointer to the string</desce>
	;     </mparam>
	;   </output>
	; </proc>

	mov	r18,regx
	mov	r19,regy


itoaformat:
	; 2-Byte-Wert in einen String umwandeln (mit fuehrenden Nullen formatiert)
	; Signatur itoaformat (in: r18,r19; out: -; changed: r16-r21,z)
	; Eingabe: r18, r19 -> 16-Bit-Zahl, die in einen String umgewandelt werden soll
	; Veraenderte Register: r16-r21, z

	ldi	r21,1
	rjmp	itoa_lab6


btoa:
	; 1-Byte-Wert in einen String umwandeln
	; Signatur btoa (in: r18; out: -; changed: r16-r21,z)
	; Eingabe: r18 -> 8-Bit-Zahl, die in einen String umgewandelt werden soll
	; Veraenderte Register: r16-r21, z

	clr	r21
btoa_lab1:
	ldi	zl,low(ITOASTRING)
	ldi	zh,high(ITOASTRING)
	clr	r19
	rjmp	itoa_lab5


; memfill6502-Struktur:
	; <struct>
	;   <name>memfill6502structure</name>
	;   <titleg>memfill6502-Struktur</titleg>
	;   <titlee>memfill6502 structure</titlee>
	;   <attr>
	;     <name>memptr</name>
	;     <descg>Pointer auf den Speicherbereich</descg>
	;     <desce>pointer to the memory region</desce>
	;     <offset>0</offset>
	;     <size>2</size>
	;   </attr>
	;   <attr>
	;     <name>n</name>
	;     <descg>Anzahl Bytes</descg>
	;     <desce>number of bytes</desce>
	;     <offset>2</offset>
	;     <size>1</size>
	;   </attr>
	;   <attr>
	;     <name>m</name>
	;     <descg>Anzahl Elemente</descg>
	;     <desce>number of elements</desce>
	;     <offset>3</offset>
	;     <size>1</size>
	;   </attr>
	;   <attr>
	;     <name>const</name>
	;     <descg>Konstanter Wert</descg>
	;     <desce>constant value</desce>
	;     <offset>4</offset>
	;     <size>1</size>
	;   </attr>
	; </struct>


memfill6502:
	; <proc>
	;   <name>memfill6502</name>
	;   <descg>Befuellen eines n*m Bytes Speicherblocks mit einem konstanten Wert (Low- oder High-Mem)</descg>
	;   <desce>fill a n*m bytes memory block with a constant value (low- or high-mem)</desce>
	;   <input>
	;     <rparam>
	;       <name>x</name>
	;       <descg>Low-Byte des Pointers auf die &lt;a href="#memfill6502structure"&gt;memfill6502-Struktur&lt;/a&gt;</descg>
	;       <desce>low byte of the pointer to the &lt;a href="#memfill6502structure"&gt;memfill6502 structure&lt;/a&gt;</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <descg>High-Byte des Pointers auf die &lt;a href="#memfill6502structure"&gt;memfill6502-Struktur&lt;/a&gt;</descg>
	;       <desce>high byte of the pointer to the &lt;a href="#memfill6502structure"&gt;memfill6502 structure&lt;/a&gt;</desce>
	;     </rparam>
	;   </input>
	; </proc>

	in	r22,PORTD
	lds	r16,LOWHIMEM
	sbrc	r16,LOWHIMEMUTIL
	himemon
	mov	zl,regx
	mov	zh,regy
	subi	zh,(256-MEMOFF6502)
	ldd	xl,z+MEMFILL6502_MEMPTR
	ldd	xh,z+MEMFILL6502_MEMPTR+1
	subi	xh,(256-MEMOFF6502)
	ldd	r18,z+MEMFILL6502_N
	ldd	r19,z+MEMFILL6502_M
	ldd	r16,z+MEMFILL6502_CONST
	rcall	memfill
	out	PORTD,r22
	ret


memfill:
	; Befuellen eines n*m grossen Speicherblocks mit einem konstanten Wert
	; Signatur memfill (in: r16,r18,r19,x; out: -; changed: r17-r19)
	; Eingabe: x -> Speicherstart
	; Eingabe: r18 -> n
	; Eingabe: r19 -> m
	; Eingabe: r16 -> Konstante
	; Veraenderte Register: r17-r19

	mov	r17,r19
memfill_lab1:
	mov	r19,r17
memfill_lab2:
	st	x+,r16
	dec	r19
	brne	memfill_lab2
	dec	r18
	brne	memfill_lab1
	ret


; memcopy6502-Struktur:
	; <struct>
	;   <name>memcopy6502structure</name>
	;   <titleg>memcopy6502-Struktur</titleg>
	;   <titlee>memcopy6502 structure</titlee>
	;   <attr>
	;     <name>src</name>
	;     <descg>Pointer auf den Quell-Speicherbereich</descg>
	;     <desce>pointer to the source memory region</desce>
	;     <offset>0</offset>
	;     <size>2</size>
	;   </attr>
	;   <attr>
	;     <name>dest</name>
	;     <descg>Pointer auf den Ziel-Speicherbereich</descg>
	;     <desce>pointer to the destination memory region</desce>
	;     <offset>2</offset>
	;     <size>2</size>
	;   </attr>
	;   <attr>
	;     <name>n</name>
	;     <descg>Anzahl Bytes</descg>
	;     <desce>number of bytes</desce>
	;     <offset>4</offset>
	;     <size>2</size>
	;   </attr>
	; </struct>


memcopyutil:
	in	r22,PORTD
	lds	r16,LOWHIMEM
	sbrc	r16,LOWHIMEMUTIL
	himemon
memcopyutil2:
	mov	zl,regx
	mov	zh,regy
	subi	zh,(256-MEMOFF6502)
	ldd	xl,z+MEMCOPY6502_DEST
	ldd	xh,z+MEMCOPY6502_DEST+1
	subi	xh,(256-MEMOFF6502)
	ldd	r24,z+MEMCOPY6502_N
	ldd	r25,z+MEMCOPY6502_N+1
	ldd	r16,z+MEMCOPY6502_SRC
	ldd	r17,z+MEMCOPY6502_SRC+1
	mov	zl,r16
	mov	zh,r17
	subi	zh,(256-MEMOFF6502)
	ret


memcopy6502:
	; <proc>
	;   <name>memcopy6502</name>
	;   <descg>Kopieren eines Speicherblocks (Low- oder High-Mem)</descg>
	;   <desce>copy a memory block (low- or high-mem)</desce>
	;   <input>
	;     <rparam>
	;       <name>x</name>
	;       <descg>Low-Byte des Pointers auf die &lt;a href="#memcopy6502structure"&gt;memcopy6502-Struktur&lt;/a&gt;</descg>
	;       <desce>low byte of the pointer to the &lt;a href="#memcopy6502structure"&gt;memcopy6502 structure&lt;/a&gt;</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <descg>High-Byte des Pointers auf die &lt;a href="#memcopy6502structure"&gt;memcopy6502-Struktur&lt;/a&gt;</descg>
	;       <desce>high byte of the pointer to the &lt;a href="#memcopy6502structure"&gt;memcopy6502 structure&lt;/a&gt;</desce>
	;     </rparam>
	;   </input>
	; </proc>

	push	r25
	rcall	memcopyutil
	rcall	memcopy
	pop	r25
	out	PORTD,r22
	ret


memcopy:
	; Kopieren eines Speicherblocks
	; Signatur memcopy (in: r24-r25,x,z; out: -; changed: r16,r24-r25,x,z)
	; Eingabe: z -> Pointer auf Quelldaten
	; Eingabe: x -> Pointer auf Zieldaten
	; Eingabe: r24-r25 -> Anzahl zu kopierende Bytes
	; Veraenderte Register: r16, r24-r25, x, z

	ld	r16,z+
	st	x+,r16
	sbiw	r24,1
	brne	memcopy
	ret


memcopyr6502:
	; <proc>
	;   <name>memcopyr6502</name>
	;   <descg>Kopieren eines Speicherblocks (hoechste Adresse wird zuerst kopiert) (Low- oder High-Mem)</descg>
	;   <desce>copy a memory block (highest address will be copied first) (low- or high-mem)</desce>
	;   <input>
	;     <rparam>
	;       <name>x</name>
	;       <descg>Low-Byte des Pointers auf die &lt;a href="#memcopy6502structure"&gt;memcopy6502-Struktur&lt;/a&gt;</descg>
	;       <desce>low byte of the pointer to the &lt;a href="#memcopy6502structure"&gt;memcopy6502 structure&lt;/a&gt;</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <descg>High-Byte des Pointers auf die &lt;a href="#memcopy6502structure"&gt;memcopy6502-Struktur&lt;/a&gt;</descg>
	;       <desce>high byte of the pointer to the &lt;a href="#memcopy6502structure"&gt;memcopy6502 structure&lt;/a&gt;</desce>
	;     </rparam>
	;   </input>
	; </proc>

	push	r25
	rcall	memcopyutil
	rcall	memcopyr
	pop	r25
	out	PORTD,r22
	ret


memcopyr:
	; Kopieren eines Speicherblocks (in umgekehrter Reihenfolge)
	; Signatur memcopyr (in: r24-r25,x,z; out: -; changed: r16,r24-r25,x,z)
	; Eingabe: z -> Pointer auf Quelldaten
	; Eingabe: x -> Pointer auf Zieldaten
	; Eingabe: r24-r25 -> Anzahl zu kopierende Bytes
	; Veraenderte Register: r16, r24-r25, x, z

	add	zl,r24
	adc	zh,r25
	add	xl,r24
	adc	xh,r25
memcopyr_lab1:
	ld	r16,-z
	st	-x,r16
	sbiw	r24,1
	brne	memcopyr_lab1
	ret


memcopylowhi6502:
	; <proc>
	;   <name>memcopylowhi6502</name>
	;   <descg>Kopieren eines Speicherblocks aus dem Low-Memory ins High-Memory</descg>
	;   <desce>copy a memory block from low memory to high memory</desce>
	;   <input>
	;     <rparam>
	;       <name>x</name>
	;       <descg>Low-Byte des Pointers auf die &lt;a href="#memcopy6502structure"&gt;memcopy6502-Struktur&lt;/a&gt;</descg>
	;       <desce>low byte of the pointer to the &lt;a href="#memcopy6502structure"&gt;memcopy6502 structure&lt;/a&gt;</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <descg>High-Byte des Pointers auf die &lt;a href="#memcopy6502structure"&gt;memcopy6502-Struktur&lt;/a&gt;</descg>
	;       <desce>high byte of the pointer to the &lt;a href="#memcopy6502structure"&gt;memcopy6502 structure&lt;/a&gt;</desce>
	;     </rparam>
	;   </input>
	; </proc>

	in	r22,PORTD
	push	r25
	rcall	memcopyutil2
memcopylowhi6502_lab1:
	himemoff
	ld	r16,z+
	himemon
	st	x+,r16
	sbiw	r24,1
	brne	memcopylowhi6502_lab1
	pop	r25
	out	PORTD,r22
	ret


memcopyhilow6502:
	; <proc>
	;   <name>memcopyhilow6502</name>
	;   <descg>Kopieren eines Speicherblocks aus dem High-Memory ins Low-Memory</descg>
	;   <desce>copy a memory block from high memory to low memory</desce>
	;   <input>
	;     <rparam>
	;       <name>x</name>
	;       <descg>Low-Byte des Pointers auf die &lt;a href="#memcopy6502structure"&gt;memcopy6502-Struktur&lt;/a&gt;</descg>
	;       <desce>low byte of the pointer to the &lt;a href="#memcopy6502structure"&gt;memcopy6502 structure&lt;/a&gt;</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <descg>High-Byte des Pointers auf die &lt;a href="#memcopy6502structure"&gt;memcopy6502-Struktur&lt;/a&gt;</descg>
	;       <desce>high byte of the pointer to the &lt;a href="#memcopy6502structure"&gt;memcopy6502 structure&lt;/a&gt;</desce>
	;     </rparam>
	;   </input>
	; </proc>

	in	r22,PORTD
	push	r25
	rcall	memcopyutil2
memcopyhilow6502_lab1:
	himemon
	ld	r16,z+
	himemoff
	st	x+,r16
	sbiw	r24,1
	brne	memcopyhilow6502_lab1
	pop	r25
	out	PORTD,r22
	ret
