; keyboard.asm, v1.6: keyboard functions for the r162 system
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


; Zustands-Bits des Keyboard-Zustands
.EQU	KBDSTATE_SHIFT = 0
.EQU	KBDSTATE_ALT = 1
.EQU	KBDSTATE_CTRL = 2
.EQU	KBDSTATE_CAPSLOCK = 3
.EQU	KBDSTATE_EXTCODE = 4
.EQU	KBDSTATE_IGNORE = 5


keybinit6502:
	; <proc>
	;   <name>keybinit6502</name>
	;   <descg>Initialisierung der Tastatur-Schnittstelle</descg>
	;   <desce>initialize keyboard interface</desce>
	; </proc>


keybinit:
	; Initialisierung der Tastatur-Schnittstelle
	; Signatur keybinit (in: -; out: -; changed: r16,z)
	; Veraenderte Register: r16, z

	; Variablen initialisieren
	sts	KBDSTATE,regzero
	sts	KEYPRESSED,regzero
	ldi	zl,low(KEYPRARR)
	ldi	zh,high(KEYPRARR)
	ldi	r16,32
keybinit_lab1:
	st	z+,regzero
	dec	r16
	brne	keybinit_lab1
	; Initialisiere Tastatur-Buffer
	sts	KBDBUFFERPRODPTR,regzero
	sts	KBDBUFFERCONSPTR,regzero
	; Initialisiere USART fuer Tastatur-Verbindung
	out	UCSR1A,regzero
	; Empfaenger einschalten
	ldi	r16,(1<<RXEN)
	out	UCSR1B,r16
	; sync. operation, odd parity, 1 stop bit, 8 bit
	ldi	r16,(1<<URSEL1)|(1<<UMSEL1)|(1<<UPM11)|(1<<UPM10)|(1<<UCSZ11)|(1<<UCSZ10)
	out	UCSR1C,r16
	ret


keybcheck:
	; Pruefen, ob eine Taste gedrueckt wurde -> wenn ja, dann wird der zugehoerige ASCII-Code zurueckgeliefert
	; Signatur keybcheck (in: -; out: r16,r17; changed: r16-r18,z)
	; Ausgabe: r17 -> != 0, wenn ein Zeichen von der Tastatur empfangen wurde
	; Ausgabe: r16 -> Gelesenes Zeichen
	; Veraenderte Register: r16-r18, z

	; loesche Key-Pressed-Flag
	clr	r17
	; Code von der Tastatur empfangen?
	in	zl,UCSR1A
	sbrs	zl,RXC1
	; nein, return
	ret
	; ja, verarbeite Code
	in	zl,UDR1
	lds	r18,KBDSTATE
	cpi	zl,0xf0
	breq	keybcheck_ignorenext
	sbrc	r18,KBDSTATE_IGNORE
	rjmp	keybcheck_ignorethis
	cpi	zl,0xe0
	breq	keybcheck_nextextended
	cpi	zl,0x12
	breq	keybcheck_shift
	cpi	zl,0x59
	breq	keybcheck_shift
	cpi	zl,0x11
	breq	keybcheck_alt
	cpi	zl,0x14
	breq	keybcheck_ctrl
	cpi	zl,0x58
	breq	keybcheck_capslock
	; wurde alt + Taste gedrueckt?
	sbrc	r18,KBDSTATE_ALT
	rjmp	keybcheck_lab1
	; wurde ctrl + Taste gedrueckt?
	sbrc	r18,KBDSTATE_CTRL
	rjmp	keybcheck_lab2
	; Key-Pressed-Array anpassen (Adresse 256)
	ldi	zh,high(KEYPRARR)
	mov	r16,zl
	andi	zl,31
	st	z,zh
	mov	zl,r16
	; wurde shift + Taste gedrueckt?
	clr	r16
	sbrc	r18,KBDSTATE_SHIFT
	ldi	r16,128
	; wurde eine "extended" Taste gedrueckt?
	sbrc	r18,KBDSTATE_EXTCODE
	ldi	r16,128
	; "ASCII"-Zeichen ermitteln
	ldi	zh,high(KEYBMAP<<1)
	add	zl,r16
	lpm	r16,z
	; capslock aktiv?
	sbrc	r18,KBDSTATE_CAPSLOCK
	rjmp	keybcheck_lab17
keybcheck_lab18:
	sts	KEYPRESSED,r16
keybcheck_lab5:
	; setze Key-Pressed-Flag
	ldi	r17,1
keybcheck_lab4:
	; loesche extcode-Flag
	andi	r18,~(1<<KBDSTATE_EXTCODE)
	; loesche ignore-Flag
	andi	r18,~(1<<KBDSTATE_IGNORE)
keybcheck_lab3:
 	; speichere Flags
	sts	KBDSTATE,r18
	ret
keybcheck_ignorethis:
	cpi	zl,0x12
	breq	keybcheck_lab11
	cpi	zl,0x59
	breq	keybcheck_lab11
	cpi	zl,0x11
	breq	keybcheck_lab12
	cpi	zl,0x14
	breq	keybcheck_lab13
	; Key-Pressed-Array anpassen (Adresse 256)
	ldi	zh,high(KEYPRARR)
	andi	zl,31
	st	z,regzero
	rjmp	keybcheck_lab4
keybcheck_lab11:
	andi	r18,~(1<<KBDSTATE_SHIFT)
	rjmp	keybcheck_lab4
keybcheck_lab12:
	andi	r18,~(1<<KBDSTATE_ALT)
	rjmp	keybcheck_lab4
keybcheck_lab13:
	andi	r18,~(1<<KBDSTATE_CTRL)
	rjmp	keybcheck_lab4
keybcheck_ignorenext:
	sts	KEYPRESSED,regzero
	ori	r18,(1<<KBDSTATE_IGNORE)
	rjmp	keybcheck_lab3
keybcheck_nextextended:
	ori	r18,(1<<KBDSTATE_EXTCODE)
	rjmp	keybcheck_lab3
keybcheck_shift:
	ori	r18,(1<<KBDSTATE_SHIFT)
	rjmp	keybcheck_lab3
keybcheck_alt:
	ori	r18,(1<<KBDSTATE_ALT)
	rjmp	keybcheck_lab3
keybcheck_ctrl:
	ori	r18,(1<<KBDSTATE_CTRL)
	rjmp	keybcheck_lab3
keybcheck_capslock:
	ldi	r16,(1<<KBDSTATE_CAPSLOCK)
	eor	r18,r16
	rjmp	keybcheck_lab3
keybcheck_lab19:
	rjmp	keybcheck_lab18
keybcheck_lab1:
	; alt + 2 -> @
	cpi	zl,0x1e
	brne	keybcheck_lab7
	ldi	r16,'@'
	rjmp	keybcheck_lab5
keybcheck_lab7:
	; alt + 3 -> #
	cpi	zl,0x26
	brne	keybcheck_lab4
	ldi	r16,'#'
	rjmp	keybcheck_lab5
keybcheck_lab2:
	lds	r16,CPUMODE
	tst	r16
	brne	keybcheck_lab10
	; ctrl-Tasten im ATMega-Modus
	; ctrl + t -> text mode
	cpi	zl,0x2c
	brne	keybcheck_lab9
	sts	VIDEOMODE,regzero
	rjmp	keybcheck_lab4
keybcheck_lab9:
	; ctrl + m -> color mode
	cpi	zl,0x3a
	brne	keybcheck_lab4
	ldi	r16,2
	sts	VIDEOMODE,r16
	rjmp	keybcheck_lab4
	; ctrl-Tasten im 6502-Modus
keybcheck_lab10:
	; ctrl + d ->  Interrupt
	cpi	zl,0x23
	brne	keybcheck_lab16
	ldi	r16,(1<<INT6502CTRLD)
	lds	zl,INTMASK6502
	and	r16,zl
	or	regint6502,r16
	rjmp	keybcheck_lab4
keybcheck_lab16:
	; ctrl + Esc ->  Shell
	cpi	zl,0x76
	brne	keybcheck_lab6
	ldi	r16,(1<<INT6502CTRLS)
	or	regint6502,r16
	rjmp	keybcheck_lab4
keybcheck_lab6:
	mov	r16,zl
	subi	r16,128
	rjmp	keybcheck_lab5
keybcheck_lab17:
	cpi	r16,'a'
	brlo	keybcheck_lab19
	cpi	r16,'z'+1
	brsh	keybcheck_lab19
	subi	r16,32
	rjmp	keybcheck_lab19


getchwait6502:
	; <proc>
	;   <name>getchwait6502</name>
	;   <descg>Lese das naechste Zeichen von der Tastatur (wartet bis eine Taste gedrueckt wird)</descg>
	;   <desce>read the next character from keyboard (waits until a key is pressed)</desce>
	;   <output>
	;     <mparam>
	;       <name>RGETCH6502</name>
	;       <descg>Zeichen</descg>
	;       <desce>character</desce>
	;     </mparam>
	;   </output>
	; </proc>

	rcall	getchwait
	sts	RGETCH6502,r16
	ret


getchwait:
	; ASCII-Code der naechsten Tastatur-Eingabe holen - wartet bis eine Taste gedrueckt wurde
	; Signatur getchwait (in: -; out: r16; changed: r16,r17,z)
	; Ausgabe: r16 -> ASCII-Code
	; Veraenderte Register: r16, r17, z

getchwait_lab1:
	; getchnowait (in: -; out: r16; changed: r16,r17,z)
	rcall	getchnowait
	tst	r16
	breq	getchwait_lab1
	ret


getchnowait6502:
	; <proc>
	;   <name>getchnowait6502</name>
	;   <descg>Lese ein Zeichen von der Tastatur, falls eine Taste gedrueckt wird</descg>
	;   <desce>read a character from keyboard if a key is pressed</desce>
	;   <output>
	;     <mparam>
	;       <name>RGETCH6502</name>
	;       <descg>Zeichen</descg>
	;       <desce>character</desce>
	;     </mparam>
	;   </output>
	; </proc>

	rcall	getchnowait
	sts	RGETCH6502,r16
	ret


getchnowait:
	; ASCII-Code der naechsten Tastatur-Eingabe holen - wartet nicht bis eine Taste gedrueckt wurde
	; Signatur getchnowait (in: -; out: r16; changed: r16,r17,z)
	; Ausgabe: r16 -> ASCII-Code oder 0, wenn keine Taste gedrueckt wurde
	; Veraenderte Register: r16, r17, z

	; Tastatur-Eingabe?
	lds	r16,KBDBUFFERPRODPTR
	lds	r17,KBDBUFFERCONSPTR
	cp	r16,r17
	ldi	r16,0
	breq	getchnowait_lab2
	; Ja -> Zeichen holen
	cpi	r17,KEYBDBUFFERLEN
	brne	getchnowait_lab1
	clr	r17
getchnowait_lab1:
	ldi	zl,low(KBDBUFFER)
	ldi	zh,high(KBDBUFFER)
	add	zl,r17
	adc	zh,regzero
	ld	r16,z
	inc	r17
	sts	KBDBUFFERCONSPTR,r17
getchnowait_lab2:
	ret
