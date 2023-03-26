; sdcard.asm, v1.6.2: sd card access for the r162 system
; 
; Copyright (C) 2010-2019 retroelec <retroelec42@gmail.com>
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


; CS: OC3B/SS wird bereits verwendet -> PB3 fuer CS verwenden -> Output
; DI: PB5/MOSI verwenden -> Output
; DO: PB6/MISO verwenden -> Input
; SCK: PB7/SCK verwenden -> Output


.EQU	SDCARDMAXRETRIES = 100
.EQU	SDCARDWAITFORDATA = 128


sdwritebyte:
	; Schreibe ein Byte (SD-Card)
	; Signatur sdwritebyte (in: r16; out: -; changed: -)
	; Eingabe: r16 -> Zu schreibendes Byte

	; Byte schreiben
	out	SPDR,r16
sdwritebyte_lab1:
	sbis	SPSR,SPIF
	rjmp	sdwritebyte_lab1
	ret


sdreadbyte:
	; Lese ein Byte (SD-Card)
	; Signatur sdreadbyte (in: -; out: r16; changed: r16)
	; Ausgabe: r16 -> Gelesenes Byte
	; Veraenderte Register: r16

	; Datenuebertragung initieren
	ldi	r16,255
	out	SPDR,r16
	; Byte lesen
sdreadbyte_lab1:
	sbis	SPSR,SPIF
	rjmp	sdreadbyte_lab1
	in	r16,SPDR
	ret


sdwritecmd:
	; Sende ein Kommando an die SD-Card
	; Signatur sdwritecmd (in: r16,r19-r22; out: r17,r18; changed: r16-r18)
	; Eingabe: r16 -> Kommando
	; Eingabe: r19-r22 -> Argument (r22: MSB)
	; Ausgabe: r18 -> Antwort
	; Ausgabe: r17 -> ok (!= 0) / nicht ok (== 0)
	; Veraenderte Register: r16-r18

	; SD-Karte aktivieren
	cbi	PORTB,PORTB3

	; Sende Kommando
	; sdwritebyte (in: r16; out: -; changed: -)
	rcall	sdwritebyte
	; Sende Argument
	mov	r16,r22
	; sdwritebyte (in: r16; out: -; changed: -)
	rcall	sdwritebyte
	mov	r16,r21
	; sdwritebyte (in: r16; out: -; changed: -)
	rcall	sdwritebyte
	mov	r16,r20
	; sdwritebyte (in: r16; out: -; changed: -)
	rcall	sdwritebyte
	mov	r16,r19
	; sdwritebyte (in: r16; out: -; changed: -)
	rcall	sdwritebyte
	; Sende CRC (correct value only important for CMD0 -> always send the same CRC)
	ldi	r16,0x95
	; sdwritebyte (in: r16; out: -; changed: -)
	rcall	sdwritebyte

	; Warten auf Antwort
	ldi	r17,SDCARDMAXRETRIES
sdwritecmd_lab2:
	; sdreadbyte (in: -; out: r16; changed: r16)
	rcall	sdreadbyte
	cpi	r16,255
	brne	sdwritecmd_lab3
	dec	r17
	brne	sdwritecmd_lab2
sdwritecmd_lab3:
	mov	r18,r16

	; SD-Karte deaktivieren
	sbi	PORTB,PORTB3

	; Sende 8 Clock Zyklen (SD-Karte deaktiviert)
	ldi	r16,255
	; sdwritebyte (in: r16; out: -; changed: -)
	rcall	sdwritebyte
	ret


sdinit6502:
	; <proc>
	;   <name>sdinit6502</name>
	;   <descg>Initialisierung der SD-Card</descg>
	;   <desce>initialization of SD card</desce>
	;   <output>
	;     <mparam>
	;       <name>RERRCODE6502</name>
	;       <descg>Fehler-Code (0 = OK)</descg>
	;       <desce>error code (0 = OK)</desce>
	;     </mparam>
	;   </output>
	; </proc>

	; Keine Video-Generator-Interrupts erlauben zur fehlerfreien Datenuebertragung
	videogen_disableint
	; sdinit (in: -; out: r16; changed: r16-r23)
	rcall	sdinit
	rjmp	sdreadwritesectorutil2


sdinit:
	; Initialisiere die SD-Card
	; Signatur sdinit (in: -; out: r16; changed: r16-r23)
	; Ausgabe: r16 -> ok (== 0) / nicht ok (== 255)
	; Veraenderte Register: r16-r23

	; SD-Karte deaktivieren
	sbi	PORTB,PORTB3

	; Master SPI aktivieren, clock = fOSC/128 = 125 kHz
	ldi	r16,(1<<SPE)|(1<<MSTR)|(1<<SPR0)|(1<<SPR1)
	out	SPCR,r16
	; Loeschen des SPI2X-Bit
	out	SPSR,regzero

	; Sende mindestens 74 Clock Zyklen mit dem Wert '1' an die SD-Karte
	ldi	r16,255
	ldi	r17,16
sdinit_lab1:
	; sdwritebyte (in: r16; out: -; changed: -)
	rcall	sdwritebyte
	dec	r17
	brne	sdinit_lab1

	; Sende CMD0
	ldi	r23,SDCARDMAXRETRIES
	clr	r19
	clr	r20
	clr	r21
	clr	r22
sdinit_lab5:
	ldi	r16,0x40
	; sdwritecmd (in: r16,r19-r22; out: r17,r18; changed: r16-r18)
	rcall	sdwritecmd
	tst	r17
	breq	sdinit_lab4
	cpi	r18,1
	brne	sdinit_lab4
	rjmp	sdinit_lab6
sdinit_lab4:
	dec	r23
	brne	sdinit_lab5
	rjmp	sdinit_laberror
sdinit_lab6:

	; Sende ACMD41
	ldi	r23,SDCARDMAXRETRIES
sdinit_lab2:
	ldi	r16,0x77
	; sdwritecmd (in: r16,r19-r22; out: r17,r18; changed: r16-r18)
	rcall	sdwritecmd
	tst	r17
	breq	sdinit_lab7
	cpi	r18,1
	brne	sdinit_lab7
	ldi	r16,0x69
	; sdwritecmd (in: r16,r19-r22; out: r17,r18; changed: r16-r18)
	rcall	sdwritecmd
	tst	r17
	breq	sdinit_lab7
	tst	r18
	brne	sdinit_lab7
	rjmp	sdinit_lab3
sdinit_lab7:
	dec	r23
	brne	sdinit_lab2
	rjmp	sdinit_laberror
sdinit_lab3:
.ifdef SLOWHW
	; Geschwindigkeit = fOSC/16 = 1 MHz (nicht zu schnell!)
	ldi	r16,(1<<SPE)|(1<<MSTR)|(1<<SPR0)
.else
	; Geschwindigkeit = fOSC/4
	ldi	r16,(1<<SPE)|(1<<MSTR)
.endif
	out	SPCR,r16
	clr	r16
	ret
sdinit_laberror:
	ldi	r16,255
	ret


; sdreadwritesector-Struktur:
	; <struct>
	;   <name>sdreadwritesectorstructure</name>
	;   <titleg>sdreadwritesector-Struktur</titleg>
	;   <titlee>sdreadwritesector structure</titlee>
	;   <attr>
	;     <name>nr</name>
	;     <descg>Sektornummer</descg>
	;     <desce>sector number</desce>
	;     <offset>0</offset>
	;     <size>3</size>
	;   </attr>
	;   <attr>
	;     <name>mem</name>
	;     <descg>Pointer auf den Speicherbereich (512 Bytes)</descg>
	;     <desce>pointer to the memory region (512 bytes)</desce>
	;     <offset>3</offset>
	;     <size>2</size>
	;   </attr>
	; </struct>


sdreadwritesectorutil1:
	mov	zl,regx
	mov	zh,regy
	subi	zh,(256-MEMOFF6502)
	ldd	r20,z+SDREADWRITESECTOR_NR
	ldd	r21,z+SDREADWRITESECTOR_NR+1
	ldd	r22,z+SDREADWRITESECTOR_NR+2
	ldd	r16,z+SDREADWRITESECTOR_MEM
	ldd	r17,z+SDREADWRITESECTOR_MEM+1
	mov	zl,r16
	mov	zh,r17
	subi	zh,(256-MEMOFF6502)
	; Keine Video-Generator-Interrupts erlauben zur fehlerfreien Datenuebertragung
	videogen_disableint
	ret


sdreadwritesectorutil2:
	sts	RERRCODE6502,r16
	; Video-Generator-Interrupts wieder erlauben
	; videogen_enableint (in: -; out: -; changed: r16,r18)
	jmp	videogen_enableint


sdreadsector6502:
	; <proc>
	;   <name>sdreadsector6502</name>
	;   <descg>Lesen eines Sektors von der SD-Card</descg>
	;   <desce>read a sector from SD card</desce>
	;   <input>
	;     <rparam>
	;       <name>x</name>
	;       <descg>Low-Byte des Pointers auf die &lt;a href="#sdreadwritesectorstructure"&gt;sdreadwritesector-Struktur&lt;/a&gt;</descg>
	;       <desce>low byte of the pointer to the &lt;a href="#sdreadwritesectorstructure"&gt;sdreadwritesector structure&lt;/a&gt;</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <descg>High-Byte des Pointers auf die &lt;a href="#sdreadwritesectorstructure"&gt;sdreadwritesector-Struktur&lt;/a&gt;</descg>
	;       <desce>high byte of the pointer to the &lt;a href="#sdreadwritesectorstructure"&gt;sdreadwritesector structure&lt;/a&gt;</desce>
	;     </rparam>
	;   </input>
	;   <output>
	;     <mparam>
	;       <name>RERRCODE6502</name>
	;       <descg>Fehler-Code (0 = OK)</descg>
	;       <desce>error code (0 = OK)</desce>
	;     </mparam>
	;   </output>
	; </proc>

	rcall	sdreadwritesectorutil1
	; sdreadsector (in: r20-r22,z; out: r16; changed: r16-r22,z)
	rcall	sdreadsector
	rjmp	sdreadwritesectorutil2


sdreadsector:
	; Lese einen Sektor von der SD-Card
	; Signatur sdreadsector (in: r20-r22,z; out: r16; changed: r16-r22,z)
	; Eingabe: r20-r22 -> Sektornummer (r22: MSB)
	; Eingabe: z -> Puffer (512 Bytes), um den Sektor einzulesen
	; Ausgabe: r16 -> ok (== 0) / nicht ok (== 255)
	; Veraenderte Register: r16-r22, z

	; Einzelnen Datenblock von der SD-Card anfordern
	; Adresse = 512 * Sektornummer
	clr	r19
	lsl	r20
	rol	r21
	rol	r22
	ldi	r16,0x51
	; sdwritecmd (in: r16,r19-r22; out: r17,r18; changed: r16-r18)
	rcall	sdwritecmd
	tst	r17
	breq	sdreadsector_laberror
	tst	r18
	brne	sdreadsector_laberror

	; SD-Karte aktivieren
	cbi	PORTB,PORTB3

	; Warte, bis die Daten bereitstehen
	ldi	r18,SDCARDWAITFORDATA
sdreadsector_lab2:
	clr	r17
sdreadsector_lab1:
	; sdreadbyte (in: -; out: r16; changed: r16)
	rcall	sdreadbyte
	cpi	r16,0xfe
	breq	sdreadsector_lab3
	dec	r17
	brne	sdreadsector_lab1
	dec	r18
	brne	sdreadsector_lab2
sdreadsector_laberror:
	; SD-Karte deaktivieren
	sbi	PORTB,PORTB3
	ldi	r16,255
	ret

sdreadsector_lab3:
	; Lese Daten und lege sie im Puffer ab
	clr	r17
	ldi	r18,2
sdreadsector_lab4:
	; sdreadbyte (in: -; out: r16; changed: r16)
	rcall	sdreadbyte
	st	z+,r16
	dec	r17
	brne	sdreadsector_lab4
	dec	r18
	brne	sdreadsector_lab4

	; CRC lesen (+ ignorieren)
	; sdreadbyte (in: -; out: r16; changed: r16)
	rcall	sdreadbyte
	rcall	sdreadbyte

	; SD-Karte deaktivieren
	sbi	PORTB,PORTB3

	; Sende 8 Clock Zyklen (SD-Karte deaktiviert)
	ldi	r16,255
	; sdwritebyte (in: r16; out: -; changed: -)
	rcall	sdwritebyte

	clr	r16
	ret


sdwritesector6502:
	; <proc>
	;   <name>sdwritesector6502</name>
	;   <descg>Schreiben eines Sektors auf die SD-Card</descg>
	;   <desce>write a sector to SD card</desce>
	;   <input>
	;     <rparam>
	;       <name>x</name>
	;       <descg>Low-Byte des Pointers auf die &lt;a href="#sdreadwritesectorstructure"&gt;sdreadwritesector-Struktur&lt;/a&gt;</descg>
	;       <desce>low byte of the pointer to the &lt;a href="#sdreadwritesectorstructure"&gt;sdreadwritesector structure&lt;/a&gt;</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <descg>High-Byte des Pointers auf die &lt;a href="#sdreadwritesectorstructure"&gt;sdreadwritesector-Struktur&lt;/a&gt;</descg>
	;       <desce>high byte of the pointer to the &lt;a href="#sdreadwritesectorstructure"&gt;sdreadwritesector structure&lt;/a&gt;</desce>
	;     </rparam>
	;   </input>
	;   <output>
	;     <mparam>
	;       <name>RERRCODE6502</name>
	;       <descg>Fehler-Code (0 = OK)</descg>
	;       <desce>error code (0 = OK)</desce>
	;     </mparam>
	;   </output>
	; </proc>

	rcall	sdreadwritesectorutil1
	; sdwritesector (in: r20-r22,z; out: r16; changed: r16-r22,z)
	rcall	sdwritesector
	rjmp	sdreadwritesectorutil2


sdwritesector:
	; Schreibe einen Sektor auf die SD-Card
	; Signatur sdwritesector (in: r20-r22,z; out: r16; changed: r16-r22,z)
	; Eingabe: r20-r22 -> Sektornummer (r22: MSB)
	; Eingabe: z -> Speicherbereich (512 Bytes)
	; Ausgabe: r16 -> ok (== 0) / nicht ok (== 255)
	; Veraenderte Register: r16-r22, z

	; Einzelnen Datenblock auf die SD-Card schreiben
	; Adresse = 512 * Sektornummer
	clr	r19
	lsl	r20
	rol	r21
	rol	r22
	ldi	r16,0x58
	; sdwritecmd (in: r16,r19-r22; out: r17,r18; changed: r16-r18)
	rcall	sdwritecmd
	tst	r17
	breq	sdwritesector_laberror
	tst	r18
	brne	sdwritesector_laberror

	; SD-Karte aktivieren
	cbi	PORTB,PORTB3

	; Sende Start Block Token
	ldi	r16,0xfe
	; sdwritebyte (in: r16; out: -; changed: -)
	rcall	sdwritebyte

	; Schreibe Daten
	clr	r17
	ldi	r18,2
sdwritesector_lab4:
	ld	r16,z+
	; sdwritebyte (in: r16; out: -; changed: -)
	rcall	sdwritebyte
	dec	r17
	brne	sdwritesector_lab4
	dec	r18
	brne	sdwritesector_lab4

	; Sende Dummy CRC
	ldi	r16,0xff
	; sdwritebyte (in: r16; out: -; changed: -)
	rcall	sdwritebyte
	rcall	sdwritebyte

	; Antwort pruefen
	; sdreadbyte (in: -; out: r16; changed: r16)
	rcall	sdreadbyte
	andi	r16,0x1f
	cpi	r16,5
	brne	sdwritesector_laberror

	; Warte, bis die Daten geschrieben wurden
	ldi	r18,SDCARDWAITFORDATA
sdwritesector_lab2:
	clr	r17
sdwritesector_lab1:
	; sdreadbyte (in: -; out: r16; changed: r16)
	rcall	sdreadbyte
	tst	r16
	brne	sdwritesector_lab3
	dec	r17
	brne	sdwritesector_lab1
	dec	r18
	brne	sdwritesector_lab2
sdwritesector_laberror:
	; SD-Karte deaktivieren
	sbi	PORTB,PORTB3
	ldi	r16,255
	ret

sdwritesector_lab3:
	; SD-Karte deaktivieren
	sbi	PORTB,PORTB3

	; Sende 8 Clock Zyklen (SD-Karte deaktiviert)
	ldi	r16,255
	; sdwritebyte (in: r16; out: -; changed: -)
	rcall	sdwritebyte

	clr	r16
	ret
