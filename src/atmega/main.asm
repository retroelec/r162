; main.asm, v1.6.4: initialization of the r162 system
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

; if the hardware is not working properly (especially SD card access) you can uncomment the following line
; .define SLOWHW

.include "m162def.inc"

.CSEG

	; Interrupt-Tabelle
.ORG  0x0
	; RESET
	jmp	reset
	jmp	interruptnotsupported
	jmp	interruptnotsupported
	jmp	interruptnotsupported
	jmp	interruptnotsupported
	jmp	interruptnotsupported
	jmp	interruptnotsupported
	; TIMER3 COMPA
	jmp	videogen_main

interruptnotsupported:
	reti


.include "globals.asm"
.include "videogen.asm"
.include "cpu6502.asm"
.include "util.asm"
.include "list.asm"
.include "output.asm"
.include "keyboard.asm"
.include "sdcard.asm"
.include "fat.asm"
.include "msprite.asm"
.include "graphics.asm"
.include "shell.asm"
.include "spi.asm"

.include "chardefs.inc"


; Initialisierungen

reset:
	; disable interrupts
	cli

	; wait some time
	clr	r16
	clr	r17
.ifdef SLOWHW
	ldi	r18,40
.else
	ldi	r18,20
.endif
reset_lab1:
	dec	r16
	brne	reset_lab1
	dec	r17
	brne	reset_lab1
	dec	r18
	brne	reset_lab1
reset_lab0:

	; Stack-Pointer setzen
	ldi	r16,high(STACKSTART)
	out	SPH,r16
	ldi	r16,low(STACKSTART)
	out	SPL,r16

	; Register regzero setzen
	clr	regzero

	; Port A auf Ausgang setzen
	; Port A wird (auch) zum Setzen der Farbinformationen verwendet
	ldi	r16,255
	out	DDRA,r16

	; OC0+OC2+OC3B+PB3+MOSI+SCK (PB0+PB1+PB4+PB3+PB5+PB7) auf Ausgang setzen
	ldi	r16,(1<<DDB0)|(1<<DDB1)|(1<<DDB3)|(1<<DDB4)|(1<<DDB5)|(1<<DDB7)
	out	DDRB,r16

        ; Pull-up Widerstand aktivieren fuer Input-Signal RXD1 (PB2) + MISO (PB6)
	; (Tastatur sendet Daten wenn sowohl KBD Data und KBD Clock High-Pegel haben)
	ldi	r16,(1<<PORTB2)|(1<<PORTB6)
	out	PORTB,r16

	; Port C auf Ausgang setzen
	; Port C wird (auch) zur Ausgabe der Bildschirm-Daten verwendet
	ldi	r16,255
	out	DDRC,r16

	; PD3 (= A16) + PD5 (= OC1A) + PD1 (= SPI CS) auf Ausgang setzen
	ldi	r16,(1<<DDD3)|(1<<DDD5)|(1<<DDD1)
	out	DDRD,r16

        ; Pull-up Widerstand aktivieren fuer das Input-Signal XCHK1 (PD2),
	; das CS Signal fuer das externe SPI (PD1) und die
	; unbenutzten Pins PD0, PD4
	; (Tastatur sendet Daten wenn sowohl KBD Data und KBD Clock High-Pegel haben)
	ldi	r16,(1<<PORTD0)|(1<<PORTD1)|(1<<PORTD2)|(1<<PORTD4)
	out	PORTD,r16

	; Port E auf Ausgang setzen
	ldi	r16,255
	out	DDRE,r16

	; Setzen des Clock Prescale Registers (Clock Division Faktor = 1)
	; -> 16 MHz Takt auch wenn CKDIV8 des Fuse Low Bytes auf 0 gesetzt ist
	ldi	r16,(1<<CLKPCE)
	sts	CLKPR,r16
	sts	CLKPR,regzero

	; Externes RAM einblenden
	ldi	r16,(1<<SRE)
	out	MCUCR,r16

	; Default: Alle Daten aus Low-Memory
	sts	LOWHIMEM,regzero

	; Initialisierung der Tastatur
	; keybinit (in: -; out: -; changed: r16,z)
	call	keybinit

	; Initialisierung des Video-Generators
	call	initlistmsprites
	call	videogen_init

	; Diverse Initialisierungen
	; setcursorpos (in: r18,r19; out: -; changed: r0,r1,r16)
	clr	r18
	clr	r19
	call	setcursorpos
	sts	PAGERACTIVE,regzero
	sts	AUTOSND,regzero
	sts	AUTOSNDSYNC2,regzero
	sts	AUTOSNDREPEAT,regzero
	out	TCCR2,regzero
	out	TCCR1A,regzero
	out	TCCR1B,regzero
	sts	DEBUGONOFF,regzero
	sts	DEBUGCURX,regzero
	sts	DEBUGCURY,regzero
	ldi	r16,low(DEBUGBPARRAYDEFAULT)
	sts	DEBUGBPARRAYPTR,r16
	ldi	r16,high(DEBUGBPARRAYDEFAULT)
	sts	DEBUGBPARRAYPTR+1,r16

	; Initialisierung des CPU-Modus
	sts	CPUMODE,regzero

	; Initialisierung des FAT-Dateisystems
	; fatinit (in: -; out: r17; changed: r0-r4,r13-r22,x,z)
	call	fatinit

	; Interrupts einschalten
	sei

	; Ausgabe Begruessungstext
	ldi	zl,low(stringr162<<1)
	ldi	zh,high(stringr162<<1)
	; printstringflash (in: z; out: -; changed: r16-r20,x,y,z)
	call	printstringflash

	; Uebergabe Kontrolle an Shell
	ldi	xl,low(SYSBINDIRNAME)
	ldi	xh,high(SYSBINDIRNAME)
	ldi	r16,'/'
	st	x+,r16
	ldi	r16,'B'
	st	x+,r16
	ldi	r16,'I'
	st	x+,r16
	ldi	r16,'N'
	st	x+,r16
	ldi	r16,'/'
	st	x+,r16
	jmp	shell


stringr162:
	.db	"r162 v1.6.4", 10, 0, 0


.include "cpu6502jmptab.inc"
.include "keybmap.inc"
