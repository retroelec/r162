; videogen.asm, v1.6.2: video generation for the r162 system
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


; TV-Bild-Aufbau

; 50 Bilder pro Sekunde, kein Interlace
; Zeile 0-2.5: Vortrabanten
; Zeile 2.5-5.5: Hauptimpulse
; Zeile 5.5-8: Nachtrabanten
; Zeile 8-60: schwarz
; Zeile 60-260: Bild
; Zeile 260-312: schwarz


; TV-Bildzeilen-Aufbau

; 1 Zeile -> 64 us
; 1.5 us schwarz, 4.7 us H-Sync, 5.8 us schwarz, 52 us Videodaten
; resp. 4.7 us H-Sync, 5.8 us schwarz, 52 us Videodaten, 1.5 us schwarz

; Die Ausgabe eines Pixels benoetigt 125 ns (2*62.5 ns)
; -> es koennten 416 Pixel ausgegeben werden
; -> es sollen aber nur 320 Pixel (40 Zeichen) ausgegeben werden (im Standard-Textmodus)
; -> 52 us -> 416 Pixel, 40 us -> 320 Pixel
; -> (52-40 us)/2 = 6 us schwarz vor und nach den eigentlichen Bilddaten

; Die Bilddaten werden in einer Interrupt-Routine ausgegeben.
; Fuer den Aufruf wird die Output Compare Unit A von Timer 3 verwendet.
; Waehrend der horizontalen Synchronisation (wenn die Bilddaten ausgegeben
; werden) zaehlt der Timer von 0 bis 1023.
; -> Ausgabe der Videodaten nach 4.7+5.8 us + 6 us resp. nach 16.5 us
; -> 64 us -> 1024 Takte, 16.5 us -> 264 Takte
; D.h. nach 264 Takten (ab dem Start des horizontalen
; Synchronisations-Signals) sollen die Bilddaten ausgegeben werden.
; Es werden aber noch einige Taktzyklen fuer die Vorbereitungen
; benoetigt -> Interrupt-Routine muss entsprechend vorher starten.

; Die Bilddaten werden ueber das Schieberegister 74HC165 ausgegeben.
; Das diesbezueglich benoetigte Taktsignal (8 MHz) wird von Timer 0 erzeugt.
; Clear timer on compare match (CTC) mode -> WGM01 = 1, WGM00 = 0
; Toggle bitmode (OC0 wechselt den Level bei jedem compare match)
; -> COM01 = 0, COM00 = 1
; Frequenz f(OC0) soll maximal sein (= f(CLK)/2)
; -> OCR0 = 0
; -> kein Prescaling -> CS02 = 0, CS01 = 0, CS00 = 1
; Kein Interrupt -> TOIE0 = 0, OCIE0 = 0

; Die Output Compare Unit B von Timer 3 wird fuer die Generierung der
; Synchronisationssignale verwendet.


; Horizontale Synchronisation

; Der TOP-Wert wird auf den fixen Wert 0x03FF (=1023) gesetzt
; -> f(OC3BPWM) = f(CLK)/N/(1+TOP) mit N = 1 (Prescaler-Wert)
; -> bei 16 MHz -> f(OC3BPWM) = 15625 Hz = 1/64 us
; -> Signal bei jedem Zeilenstart
; Die Output Compare Unit B wird auf den Wert 75 gesetzt
; -> 64 us -> 1024 Takte, 4.7 us H-Sync -> 75 Takte
; Fast PWM, 10 bit -> Waveform Generation Mode = Mode 7
; -> WGM33 = 0, WGM32 = 1, WGM31 = 1, WGM30 = 1
; No prescaling
; -> CS32 = 0, CS31 = 0, CS30 = 1
; Set OC3B on compare match
; -> COM3B1 = 1, COM3B0 = 1
; -> Signal:	0 ll 75 hhh...hhh 1024 | 0 ll 75 hhh...hhh 1024 | ...


; Vertikale Synchronisation

; Der TOP-Wert wird auf den fixen Wert 0x01FF (=511) gesetzt
; -> f(OC3BPWM) = f(CLK)/N/(1+TOP) mit N = 1 (Prescaler-Wert)
; -> bei 16 MHz -> f(OC3BPWM) = 31250 Hz = 1/32 us
; -> Zwei Signale pro Zeile
; Die Output Compare Unit B wird fuer die Hauptimpulse auf den Wert 75 gesetzt
; -> 32 us -> 512 Takte, 4.7 us H-Sync -> 75 Takte
; Die Output Compare Unit B wird fuer die Vor- und Nachtrabanten
; auf den Wert 38 gesetzt
; -> 32 us -> 512 Takte, 2.35 us H-Sync -> 38 Takte
; Fast PWM, 9 bit -> Waveform Generation Mode = Mode 6
; -> WGM33 = 0, WGM32 = 1, WGM31 = 1, WGM30 = 0
; No prescaling
; -> CS32 = 0, CS31 = 0, CS30 = 1
; Hauptimpulse -> clear OC3B on compare match
; -> COM3B1 = 1, COM3B0 = 0
; -> Signal:	0 hh 75 lll...lll 512 | 0 hh 75 lll...lll 512 | ...
; Vortrabanten und Nachtrabanten -> set OC3B on compare match
; -> COM3B1 = 1, COM3B0 = 1
; -> Signal:	0 ll 38 hhh...hhh 512 | 0 ll 38 hhh...hhh 512 | ...


; Interne Konstanten

; Timer-Stand innerhalb einer Zeile, zu dem die Video-Daten ausgegeben werden sollen
.EQU	STARTINROW = 264-16
; Text-Modus: Anzahl Taktzyklen bis zum Start Ausgabe der Videodaten
.EQU	NUMINITCYCTEXTMODENOCUR = 103
.EQU	NUMINITCYCTEXTMODEWITHCUR = 117
; Text-Modus2: Anzahl Taktzyklen bis zum Start Ausgabe der Videodaten
.EQU	NUMINITCYCTEXT2MODENOCUR = 103+32
.EQU	NUMINITCYCTEXT2MODEWITHCUR = 117+32
; Color-Modus: Anzahl Taktzyklen bis zum Start Ausgabe der Videodaten
.EQU	NUMINITCYCCOLMODE = 77


.MACRO	videogen_horizsync
	; Veraenderte Register: r16
	ldi	r16,(1<<COM3B1)|(1<<COM3B0)|(1<<WGM31)|(1<<WGM30)
	sts	TCCR3A,r16
	ldi	r16,75
	sts	OCR3BL,r16
.ENDMACRO


.MACRO	videogen_vertsyncprepost
	; Veraenderte Register: r16
	ldi	r16,(1<<COM3B1)|(1<<COM3B0)|(1<<WGM31)
	sts	TCCR3A,r16
	ldi	r16,38
	sts	OCR3BL,r16
.ENDMACRO


.MACRO	videogen_vertsyncmain
	; Veraenderte Register: r16
	ldi	r16,(1<<COM3B1)|(1<<WGM31)
	sts	TCCR3A,r16
	ldi	r16,75
	sts	OCR3BL,r16
.ENDMACRO


.MACRO	videogen_disableint
	; Keine Video-Generator-Interrupts erlauben zur fehlerfreien Datenuebertragung
	cli
.ENDMACRO


videogen_enableint:
	; Video-Generator-Interrupts wieder aktivieren, nachdem sie mittels videogen_disableint deaktiviert wurden
	; Signatur videogen_enableint (in: -; out: -; changed: r16,r18)
	; Veraenderte Register: r16, r18
	; Signatur videogen_initvarvsync (in: -; out: -; changed: r16,r18)
	rcall	videogen_initvarvsync
	sei
	ret


videogen_mode0:
	; Wechsle in den Textmodus
	; Signatur videogen_mode0 (in: -; out: -; changed: r16)
	; Veraenderte Register: r16

	; Aufruf der Interrupt Routine -> Output Compare Unit A
	; Die Output Compare Unit A und die Variable VGRINITCYC setzen
	sts	VIDEOMODEINT,regzero
	sts	OCR3AH,regzero
	lds	r16,CURONOFF
	tst	r16
	brne	videogen_mode0_lab1
	ldi	r16,STARTINROW-NUMINITCYCTEXTMODENOCUR
	rjmp	videogen_mode0_lab2
videogen_mode0_lab1:
	ldi	r16,STARTINROW-NUMINITCYCTEXTMODEWITHCUR
videogen_mode0_lab2:
	sts	OCR3AL,r16
	sts	VGRINITCYC,r16
	lds	r16,NUMOFROWSM0
	sts	NUMOFROWS,r16
	lds	r16,STARTROWM0
	sts	STARTROW,r16
	ldi	r16,40
	sts	NUMCHARCOLS,r16
	ret


videogen_mode1:
	; Wechsle in den Textmodus2
	; Signatur videogen_mode1 (in: -; out: -; changed: r16)
	; Veraenderte Register: r16

	; Aufruf der Interrupt Routine -> Output Compare Unit A
	; Die Output Compare Unit A und die Variable VGRINITCYC setzen
	ldi	r16,1
	sts	VIDEOMODEINT,r16
	sts	OCR3AH,regzero
	lds	r16,CURONOFF
	tst	r16
	brne	videogen_mode1_lab1
	ldi	r16,STARTINROW-NUMINITCYCTEXT2MODENOCUR
	rjmp	videogen_mode1_lab2
videogen_mode1_lab1:
	ldi	r16,STARTINROW-NUMINITCYCTEXT2MODEWITHCUR
videogen_mode1_lab2:
	sts	OCR3AL,r16
	sts	VGRINITCYC,r16
	lds	r16,NUMOFROWSM1
	sts	NUMOFROWS,r16
	lds	r16,STARTROWM1
	sts	STARTROW,r16
	ldi	r16,44
	sts	NUMCHARCOLS,r16
	ret


videogen_mode2:
	; Wechsle in den Colormodus
	; Signatur videogen_mode2 (in: -; out: -; changed: r16)
	; Veraenderte Register: r16

	; Aufruf der Interrupt Routine -> Output Compare Unit A
	; Die Output Compare Unit A und die Variable VGRINITCYC setzen
	ldi	r16,2
	sts	VIDEOMODEINT,r16
	sts	OCR3AH,regzero
	ldi	r16,STARTINROW-NUMINITCYCCOLMODE
	sts	OCR3AL,r16
	sts	VGRINITCYC,r16
	lds	r16,NUMOFROWSM0
	sts	NUMOFROWS,r16
	lds	r16,STARTROWM0
	sts	STARTROW,r16
	ret


.MACRO	videogen_inittvsync
	; Veraenderte Register: r16
	; Timer 0: clk = 16MHz/(2*1*(1+OCR0))
	out	OCR0,regzero
	; Taktsignal fuer den 74HC165
	ldi	r16,(1<<WGM01)|(1<<COM00)|(1<<CS00)
	out	TCCR0,r16
	; Die folgende Instruktion (nop) ist zeitkritisch und darf nicht entfernt werden!!!
	;  -> ungrade Anzahl Zyklen bis zur Ausgabe der Videodaten via videogen_out*-Makros
	nop
	; Initialisierung des TV-Sync.-Signals
	sts	OCR3BH,regzero
	ldi	r16,75
	sts	OCR3BL,r16
	ldi	r16,(1<<WGM32)|(1<<CS30)
	sts	TCCR3B,r16
	; Aufruf der Interrupt Routine -> Output Compare Unit A
	; Die Output Compare Unit A wurde in der Prozedur videogen_mode0 gesetzt
	; -> Output Compare A Match Interrupt Enable (OCIE3A)
	; -> Output Compare A Match Flag (OCF3A)
	ldi	r16,(1<<OCIE3A)
	sts	ETIMSK,r16
	ldi	r16,(1<<OCF3A)
	sts	ETIFR,r16
.ENDMACRO


videogen_initdivvar:
	; Initialisierung diverser Variabeln beim Reset des Computers
	; Signatur videogen_initdivvar (in: -; out: -; changed: r16)
	; Veraenderte Register: r16

	ldi	r16,200
	sts	NUMOFROWSM0,r16
	ldi	r16,60+8
	sts	STARTROWM0,r16
	ldi	r16,240
	sts	NUMOFROWSM1,r16
	ldi	r16,50+8
	sts	STARTROWM1,r16
	ldi	r16,high(CHARDEFSDEFAULT)
	sts	CHARDEFSRAM,r16
	ldi	r16,8
	sts	NUMOFCHARLINES,r16
	sts	NUMOFCHARCOLLINES,r16
	ldi	r16,low(DEBUGTEXTMAPDEFAULT)
	sts	DEBUGTEXTMAP,r16
	ldi	r16,high(DEBUGTEXTMAPDEFAULT)
	sts	DEBUGTEXTMAP+1,r16
	ldi	r16,low(DEBUGCOLORMAPTXTDEFAULT)
	sts	DEBUGCOLORMAPTXT,r16
	ldi	r16,high(DEBUGCOLORMAPTXTDEFAULT)
	sts	DEBUGCOLORMAPTXT+1,r16
	ldi	r16,low(TEXTMAPDEFAULT)
	sts	TEXTMAP,r16
	ldi	r16,high(TEXTMAPDEFAULT)
	sts	TEXTMAP+1,r16
	ldi	r16,low(COLORMAPTXTDEFAULT)
	sts	COLORMAPTXT,r16
	ldi	r16,high(COLORMAPTXTDEFAULT)
	sts	COLORMAPTXT+1,r16
	ldi	r16,low(MCOLORMAPDEFAULT)
	sts	MCOLORMAP,r16
	ldi	r16,high(MCOLORMAPDEFAULT)
	sts	MCOLORMAP+1,r16
	ldi	r16,1
	sts	CURONOFF,r16
	ldi	r16,CURSPEEDDEFAULT
	sts	CURSPEED,r16
	ldi	r16,80
	sts	MCOLSCRWIDTH,r16
	sts	MODE2STARTLINE,regzero
	sts	MODE2ENDLINE,regzero
	sts	INTERLACEONOFF,regzero
	sts	INTERLACEPHASE,regzero
	sts	TIMERINTLOADVAL,regzero
	sts	XORTXTCOLOR,regzero
	ldi	r16,25
	sts	NUMCHARROWS,r16
	ret


videogen_initvarvsync:
	; Initialisierung der Videogenerator-Variabeln in der VSync-Phase
	; Signatur videogen_initvarvsync (in: -; out: -; changed: r16,r18)
	; Veraenderte Register: r16, r18

	lds	r16,INTERLACEONOFF
	lds	r18,INTERLACEPHASE
	inc	r18
	andi	r18,1
	and	r18,r16
	sts	INTERLACEPHASE,r18
	sts	CHARLINE,regzero
	sts	CHARCOLLINE,regzero
	lds	r16,TEXTMAP
	sts	ACTTEXTPTR,r16
	lds	r16,TEXTMAP+1
	sts	ACTTEXTPTR+1,r16
	lds	r16,COLORMAPTXT
	sts	ACTCOLPTR,r16
	lds	r16,COLORMAPTXT+1
	sts	ACTCOLPTR+1,r16
	lds	r16,MCOLORMAP
	sts	ACTMCOLMAPPTR,r16
	lds	r16,MCOLORMAP+1
	sts	ACTMCOLMAPPTR+1,r16
	ldi	r16,200-8 ; -312-8
	; INTERLACEPHASE == 1 -> long frame (313 rows)
	sub	r16,r18
	lds	r18,NUMOFROWS
	add	r16,r18
	lds	r18,STARTROW
	add	r16,r18
	sts	VSYNCROW,r16
	sts	PICROW,regzero
	ret


.MACRO	videogen_outchar
	; Eingabe: zh,xl,xh,yl,yh,r19,r20,r24,r25
	; enable XMEM
	out	MCUCR,r24	; 1 Zyklus
	; read char from external SRAM
	ld	zl,x+		; 3 Zyklen
	; read color from external SRAM
	ld	r17,y+		; 3 Zyklen
	; read char data from external SRAM
	ld	r16,z		; 3 Zyklen
	; disable XMEM
	out	MCUCR,regzero	; 1 Zyklus
	eor	r17,r25		; 1 Zyklus
	; out data
	out	PORTC,r16	; 1 Zyklus
	; out color
	out	PORTA,r17	; 1 Zyklus
	; start output
	out	PORTE,r19	; 1 Zyklus
	out	PORTE,r20	; 1 Zyklus
.ENDMACRO


.MACRO	videogen_outchar_10
	videogen_outchar
	videogen_outchar
	videogen_outchar
	videogen_outchar
	videogen_outchar
	videogen_outchar
	videogen_outchar
	videogen_outchar
	videogen_outchar
	videogen_outchar
.ENDMACRO


.MACRO	videogen_outcolor
	; Eingabe: zl,zh,r18,r19,r20,r24
	; enable XMEM
	out	MCUCR,r24	; 1 Zyklus
	; read data from external SRAM
	ld	r17,z+		; 3 Zyklen
	; disable XMEM
	out	MCUCR,regzero	; 1 Zyklus
	; out data
	out	PORTA,r17	; 1 Zyklus
	; start output
	out	PORTE,r19	; 1 Zyklus
	out	PORTE,r20	; 1 Zyklus
	; enable XMEM
	out	MCUCR,r24	; 1 Zyklus
	; read data from external SRAM
	ld	r17,z+		; 3 Zyklen
	; disable XMEM
	out	MCUCR,regzero	; 1 Zyklus
	; out data
	out	PORTA,r17	; 1 Zyklus
	; start output
	out	PORTE,r18	; 1 Zyklus
	out	PORTE,r20	; 1 Zyklus
.ENDMACRO


.MACRO	videogen_outcolor_20
	videogen_outcolor
	videogen_outcolor
	videogen_outcolor
	videogen_outcolor
	videogen_outcolor
	videogen_outcolor
	videogen_outcolor
	videogen_outcolor
	videogen_outcolor
	videogen_outcolor
.ENDMACRO


.MACRO	videogen_videomodecheck
	; Veraenderte Register: r16, r17
	; Wechsel des Video-Modus?
	lds	r16,VIDEOMODE
	lds	r17,VIDEOMODESYNC
	cp	r16,r17
	breq	videogen_videomodechecklab1
	sts	VIDEOMODESYNC,r16
	tst	r16
	breq	videogen_videomodechecklab2
	cpi	r16,1
	breq	videogen_videomodechecklab3
	; videogen_mode2 (in: -; out: -; changed: r16)
	rcall	videogen_mode2
	rjmp	videogen_videomodechecklab1
videogen_videomodechecklab3:
	; videogen_mode1 (in: -; out: -; changed: r16)
	rcall	videogen_mode1
	rjmp	videogen_videomodechecklab1
videogen_videomodechecklab2:
	; videogen_mode0 (in: -; out: -; changed: r16)
	rcall	videogen_mode0
videogen_videomodechecklab1:
.ENDMACRO


.MACRO	videogen_keycheck
	; Veraenderte Register: r16-r18, z
	; Check, ob Zeichen von der Tastatur empfangen wurde
	; keybcheck (in: -; out: r16,r17; changed: r16-r18,z)
	call	keybcheck
	tst	r17
	breq	videogen_keychecklab1
	; Ja -> Zeichen in den Tastatur-Puffer
	lds	r18,KBDBUFFERPRODPTR
	cpi	r18,KEYBDBUFFERLEN
	brne	videogen_keychecklab2
	clr	r18
videogen_keychecklab2:
	ldi	zl,low(KBDBUFFER)
	ldi	zh,high(KBDBUFFER)
	add	zl,r18
	adc	zh,regzero
	st	z,r16
	inc	r18
	sts	KBDBUFFERPRODPTR,r18
videogen_keychecklab1:
	; Timer-Interrupt programmiert?
	lds	r16,TIMERINTLOADVAL
	tst	r16
	breq	videogen_keychecklab3
	; Ja, Interrupt ausloesen?
	lds	r17,TIMERINTACTVAL
	dec	r17
	brne	videogen_keychecklab4
	; Ja, 6502-Interrupt ausloesen
	ldi	r18,(1<<INT6502TIMER)
	lds	r17,INTMASK6502
	and	r18,r17
	or	regint6502,r18
	; Vorbereitung naechster Zyklus
	mov	r17,r16
videogen_keychecklab4:
	sts	TIMERINTACTVAL,r17
videogen_keychecklab3:
.ENDMACRO


videogen_timer:
	; Signatur videogen_timer (in: -; out: -; changed: r16-r19)
	; Inkrementiere Timer + Timer-Interrupt
	; Veraenderte Register: r16-r19

	; Inkrementiere Timer
	lds	r16,TIMER
	inc	r16
	sts	TIMER,r16
	brne	videogen_timerlab2
	lds	r17,TIMER+1
	inc	r17
	sts	TIMER+1,r17
videogen_timerlab2:
	ret


videogen_cleartextmap:
	; Loesche die Textmap und die Farbenmap (Text-Modus)
	; Signatur videogen_cleartextmap (in: -; out: -; changed: r16-r19,x)
	; Veraenderte Register: r16-r19, x

	lds	xl,TEXTMAP
	lds	xh,TEXTMAP+1
	ldi	r18,25
	ldi	r19,40
	ldi	r16,32
	; memfill (in: r16,r18,r19,x; out: -; changed: r17-r19)
	call	memfill
	lds	xl,COLORMAPTXT
	lds	xh,COLORMAPTXT+1
	ldi	r18,25
	ldi	r19,40
	ldi	r16,240
	; memfill (in: r16,r18,r19,x; out: -; changed: r17-r19)
	jmp	memfill


copycharmap6502:
	; <proc>
	;   <name>copycharmap6502</name>
	;   <descg>Kopieren der Charakter-Defitionen vom FLASH ins SRAM</descg>
	;   <desce>copy character definitions from FLASH to SRAM</desce>
	; </proc>


videogen_copycharmap:
	; Kopiere die Charakter-Definitionen vom Flash ins SRAM
	; Signatur videogen_copycharmap (in: -; out: -; changed: r0,r1,r16,r18,r19,x,z)
	; Veraenderte Register: r0, r1, r16, r18, r19, x, z

	ldi	zl,low(chardefs<<1)
	ldi	zh,high(chardefs<<1)
	clr	xl
	lds	xh,CHARDEFSRAM
	ldi	r19,8
videogen_copycharmap_lab5:
	; erste 33 Zeichen sind "leer"
	ldi	r18,33
videogen_copycharmap_lab1:
	st	x+,regzero
	dec	r18
	brne	videogen_copycharmap_lab1
	; 95 Zeichen
	ldi	r18,95
	mov	r0,zl
	mov	r1,zh
videogen_copycharmap_lab2:
	lpm	r16,z+
	st	x+,r16
	dec	r18
	brne	videogen_copycharmap_lab2
	; naechste 33 Zeichen sind "voll"
	ldi	r18,33
	ldi	r16,255
videogen_copycharmap_lab3:
	st	x+,r16
	dec	r18
	brne	videogen_copycharmap_lab3
	; 95 Zeichen invertiert
	ldi	r18,95
	mov	zl,r0
	mov	zh,r1
videogen_copycharmap_lab4:
	lpm	r16,z+
	com	r16
	st	x+,r16
	dec	r18
	brne	videogen_copycharmap_lab4
	dec	r19
	brne	videogen_copycharmap_lab5
	ret


videogen_init:
	; Initialisierung des Videogenerators (Aufruf aus dem Hauptprogramm)
	; Signatur videogen_init (in: -; out: -; changed: r0,r1,r16-r19,x,z)
	; Veraenderte Register: r0, r1, r16-r19, x, z

	; Variabeln initialisieren
	; videogen_initdivvar (in: -; out: -; changed: r16)
	rcall	videogen_initdivvar
	; Initialisierung des Video-Generators
	videogen_inittvsync
	; Variabeln initialisieren
	; videogen_initvarvsync (in: -; out: -; changed: r16,r18)
	rcall	videogen_initvarvsync
	; Standard-Videomode
	sts	VIDEOMODE,regzero
	; videogen_mode0 (in: -; out: -; changed: r16)
	rcall	videogen_mode0
	; Loesche / initialisiere diverse Maps
	; videogen_cleartextmap (in: -; out: -; changed: r16-r19,x)
	rcall	videogen_cleartextmap
	; Kopiere Charmap
	; videogen_copycharmap (in: -; out: -; changed: r0,r1,r16,r18,r19,x,z)
	rjmp	videogen_copycharmap


videogen_main:
	; Interrupt Routine zur Ausgabe der Video-Daten
	; und der Synchronisations-Signale.
	; Zwischen der Ausloesung des Interrupts (durch Erreichen
	; des Timer-Werts) und dem Eintreten in diese Routine
	; vergehen (mutmasslich) zwischen 7 und 12 Taktzyklen.
	; (AVR-Studio Simulator: 9-12  Taktzyklen -> auch Ein-Zyklen
	; Befehle werden beim Erreichen des Timer-Werts noch
	; abgearbeitet + pushen des Program Counter benoetigt 5 Zyklen)
	; (Datenblatt zum ATmega 162, S. 16: 7-10 Taktzyklen ->
	; Nur Multi-Zyklen Befehle werden fertig abgearbeitet
	; + pushen des Program Counter benoetigt 4 Zyklen)

	; Timer-Stand liegt zwischen VGRINITCYC+7 und VGRINITCYC+12
	; Register retten
	push	r16			; 2 Zyklen
	in	r16,SREG		; 1 Zyklus
	push	r16			; 2 Zyklen
	push	r17			; 2 Zyklen

	; Autosound: Ausgabe Daten-Byte
	lds	r16,AUTOSNDDATA		; 2 Zyklen
	lds	r17,AUTOSNDSYNC2	; 2 Zyklen
	sbrc	r17,0			; 1 Zyklus / (2 Zyklen)
	out	OCR2,r16		; 1 Zyklus

	; Timer-Stand liegt zwischen VGRINITCYC+20 und VGRINITCYC+25
	; Ausgabe Video-Daten (PICROW != 0)
	; oder Vertikal-Blanking-Signal (PICROW == 0)?
	lds	r16,PICROW 		; 2 Zyklen
	tst	r16			; 1 Zyklus
	brne	videogen_picout		; 2 Zyklen / (1 Zyklus)
	rjmp	videogen_vsync  	; (2 Zyklen)

	; Ausgabe Video-Daten
videogen_picout:
	; Timer-Stand liegt zwischen VGRINITCYC+25 und VGRINITCYC+30
	push	zl			; 2 Zyklen
	push	zh			; 2 Zyklen
	push	r18			; 2 Zyklen
	push	r19			; 2 Zyklen
	push	r20			; 2 Zyklen
	push	r24			; 2 Zyklen
	push	r25			; 2 Zyklen

	; Timer-Stand liegt zwischen VGRINITCYC+39 und VGRINITCYC+44

	; Damit die Video-Daten pro Zeile immer zum gleichen
	; Zeitpunkt ausgegeben werden, muessen bis zu 5 nops
	; ausgefuehrt werden (vgl. Kommentar oben).

	; Timer 3 lesen
	lds	zl,TCNT3L		; 2 Zyklen
	lds	zh,TCNT3H		; 2 Zyklen
	; Berechnung der Anzahl nops
	ldi	r16,low(videogen_lab1)	; 1 Zyklus
	add	zl,r16			; 1 Zyklus
	ldi	r16,high(videogen_lab1)	; 1 Zyklus
	adc	zh,r16			; 1 Zyklus
	; Timer-Stand (VGRINITCYC+44) subtrahieren
	lds	r24,VGRINITCYC		; 2 Zyklen
	ldi	r25,0			; 1 Zyklus
	adiw	r24,44			; 2 Zyklen
	sub	zl,r24			; 1 Zyklus
	sbc	zh,r25			; 1 Zyklus
	; 0-5 nops ausfuehren
	ijmp				; 2 Zyklen

	nop
	nop
	nop
	nop
	nop

videogen_lab1:
	; Timer-Stand liegt bei VGRINITCYC+61

	; Register fuer die out_*-Makros setzen
	ldi	r19,4			; 1 Zyklus
	ldi	r20,1			; 1 Zyklus
	ldi	r24,(1<<SRE)		; 1 Zyklus

	; Welcher Video-Modus?
	lds	r16,VIDEOMODEINT	; 2 Zyklen
	cpi	r16,2			; 1 Zyklus
	brlo	videogen_textmode	; 1 Zyklen / 2 Zyklus
	rjmp	videogen_colormode	; 2 Zyklen


videogen_textmode:
	push	yl			; 2 Zyklen
	push	yh			; 2 Zyklen
	push	xl			; 2 Zyklen
	push	xh			; 2 Zyklen

	; Timer-Stand liegt bei VGRINITCYC+77

	; Cursor-Blinken an?
	lds	r16,CURONOFF		; 2 Zyklen
	tst	r16			; 1 Zyklus
	breq	videogen_lab2		; 2 Zyklen / 1 Zyklus
	lds	yl,CURADDRSYNC		; 2 Zyklen
	lds	yh,CURADDRSYNC+1	; 2 Zyklen
	ld	r16,y			; 3 Zyklen
	; Cursor aktiv in aktueller Zeile?
	lds	r17,CURINACTLINE	; 2 Zyklen
	sbrc	r17,0			; 1 Zyklus / (2 Zyklen)
	; Ja -> Invertiere Zeichen
	subi	r16,128			; 1 Zyklus
	st	y,r16			; 3 Zyklen
	nop				; 1 Zyklus

videogen_lab2:
	; Cursor an: Timer-Stand liegt bei VGRINITCYC+96
	; Cursor aus: Timer-Stand liegt bei VGRINITCYC+82

	; Pointer auf anzuzeigende Zeichen 
	lds	xl,ACTTEXTPTR		; 2 Zyklen
	lds	xh,ACTTEXTPTR+1		; 2 Zyklen
	; Pointer auf die Farbe der anzuzeigende Zeichen 
	lds	yl,ACTCOLPTR		; 2 Zyklen
	lds	yh,ACTCOLPTR+1		; 2 Zyklen
	; Aktuell anzuzeigende Zeile der Zeichen holen
	lds	r16,CHARLINE		; 2 Zyklen
	; Pointer auf Zeichen-Daten (aktuelle Zeile) ermitteln
	lds	zh,CHARDEFSRAM		; 2 Zyklen
	add	zh,r16			; 1 Zyklus
	; Farb-Inverter-Register lesen
	lds	r25,XORTXTCOLOR		; 2 Zyklen

	; Cursor an: Timer-Stand liegt bei VGRINITCYC+111
	; Cursor aus: Timer-Stand liegt bei VGRINITCYC+97

	lds	r16,VIDEOMODEINT	; 2 Zyklen
	tst	r16			; 2 Zyklen
	breq	videogen_lab41		; 2 Zyklen / 1 Zyklus

	nop				; 1 Zyklus
	; Videomode 1:
	; Cursor an: Timer-Stand liegt bei VGRINITCYC+117
	; Cursor aus: Timer-Stand liegt bei VGRINITCYC+103
	; Ausgabe von 44*8 Pixeln fuer Videomode 1
	videogen_outchar
	videogen_outchar
	videogen_outchar
	videogen_outchar
videogen_lab41:
	; Videomode 0:
	; Cursor an: Timer-Stand liegt bei VGRINITCYC+115
	; Cursor aus: Timer-Stand liegt bei VGRINITCYC+101
	; Ausgabe von 40*8 Pixeln fuer Videomode 0
	videogen_outchar_10
	videogen_outchar_10
	videogen_outchar_10
	videogen_outchar_10
	
videogen_lab42:
	; Hintergrundfarbe wieder auf schwarz setzen
	out	PORTA,regzero		; 1 Zyklus
	nop				; 1 Zyklus
	nop				; 1 Zyklus
	nop				; 1 Zyklus
	nop				; 1 Zyklus
	pop	xh			; 2 Zyklen
	pop	xl			; 2 Zyklen
	pop	yh			; 2 Zyklen
	pop	yl			; 2 Zyklen
	ldi	r19,5			; 1 Zyklus
	out	PORTE,r19		; 1 Zyklus
	out	PORTE,r20		; 1 Zyklus

	; Externes RAM einblenden
	out	MCUCR,r24

	; Cursor-Blinken an?
	lds	r16,CURONOFF
	tst	r16
	breq	videogen_lab23
	; Cursor aktiv in aktueller Zeile?
	lds	r16,CURINACTLINE
	tst	r16
	breq	videogen_lab24
	; Ja -> Invertiere Zeichen
	lds	zl,CURADDRSYNC
	lds	zh,CURADDRSYNC+1
	ld	r16,z
	subi	r16,128
	st	z,r16

	; Cursor-Blinking-Vorbereitungen fuer naechste Zeile
videogen_lab24:
	lds	r17,PICROW
	mov	r16,r17
	andi	r16,7
	brne	videogen_lab17
	lds	r18,CURY
	tst	r18
	breq	videogen_lab28
	lsr	r17
	lsr	r17
	lsr	r17
	cp	r18,r17
	brne	videogen_lab17
videogen_lab22:
	lds	r16,CURCNT
	lds	r17,CURSPEED
	cp	r17,r16
	brsh	videogen_lab25
	sts	CURINACTLINE,regzero
	lsl	r17
	cp	r17,r16
	brsh	videogen_lab26
	clr	r16
	rjmp	videogen_lab27
videogen_lab23:
	rjmp	videogen_lab17
videogen_lab28:
	lds	r16,NUMOFROWS
	cp	r17,r16
	brne	videogen_lab17
	rjmp	videogen_lab22
videogen_lab25:
	; Cursor aktiv
	push	r0
	push	r1
	ldi	r17,1
	sts	CURINACTLINE,r17
	lds	r17,CURX
	ldi	r19,40
	mul	r18,r19
	add	r0,r17
	adc	r1,regzero
	lds	r19,TEXTMAP
	add	r0,r19
	lds	r19,TEXTMAP+1
	adc	r1,r19
	sts	CURADDRSYNC,r0
	sts	CURADDRSYNC+1,r1
	pop	r1
	pop	r0
videogen_lab26:
	inc	r16	
videogen_lab27:
	sts	CURCNT,r16

videogen_lab17:
	; Nacharbeiten nachdem die aktuelle Zeile ausgegeben wurden
	lds	r19,PICROW
	lds	r20,VIDEOMODESYNC
	cpi	r20,2
	brne	videogen_lab39

	; Wechsel Text-Modus <-> Multi-Color-Modus?
	lds	r17,MODE2STARTLINE
	cp	r19,r17
	brne	videogen_lab32
	; videogen_mode2 (in: -; out: -; changed: r16)
	rcall	videogen_mode2
	rjmp	videogen_lab33
videogen_lab32:
	lds	r17,MODE2ENDLINE
	cp	r19,r17
	brne	videogen_lab33
	; videogen_mode0 (in: -; out: -; changed: r16)
	rcall	videogen_mode0

videogen_lab33:
	; Color-Map -> Naechste Zeile vorbereiten
	lds	r24,ACTMCOLMAPPTR
	lds	r25,ACTMCOLMAPPTR+1
	lds	r16,MCOLSCRWIDTH
	add	r24,r16
	adc	r25,regzero
	sts	ACTMCOLMAPPTR,r24
	sts	ACTMCOLMAPPTR+1,r25

videogen_lab39:
	; Text-Map -> Naechste Zeile vorbereiten
	lds	r16,CHARLINE
	inc	r16
	lds	r17,NUMOFCHARLINES
	cp	r16,r17
	brne	videogen_lab43
	mov	r16,regzero
videogen_lab43:
	sts	CHARLINE,r16
	tst	r16
	brne	videogen_lab7
	lds	r24,ACTTEXTPTR
	lds	r25,ACTTEXTPTR+1
	lds	r17,NUMCHARCOLS
	add	r24,r17
	adc	r25,regzero
	sts	ACTTEXTPTR,r24
	sts	ACTTEXTPTR+1,r25
videogen_lab7:
	lds	r16,CHARCOLLINE
	inc	r16
	lds	r17,NUMOFCHARCOLLINES
	cp	r16,r17
	brne	videogen_lab44
	mov	r16,regzero
videogen_lab44:
	sts	CHARCOLLINE,r16
	tst	r16
	brne	videogen_lab38
	lds	r24,ACTCOLPTR
	lds	r25,ACTCOLPTR+1
	lds	r17,NUMCHARCOLS
	add	r24,r17
	adc	r25,regzero
	sts	ACTCOLPTR,r24
	sts	ACTCOLPTR+1,r25

videogen_lab38:
	; Wurden alle Zeilen dargestellt?
	lds	r17,NUMOFROWS
	cp	r19,r17
	brne	videogen_lab12
	rjmp	videogen_lab4
videogen_lab12:
	inc	r19
	sts	PICROW,r19

	; Evt. Abfrage der Tastatur
	mov	r16,r19

videogen_picexit:
	pop	r25
	pop	r24
	pop	r20
	pop	r19
	pop	r18
	pop	zh
	pop	zl

videogen_vsyncexit:
	; Abfrage der Tastatur
	andi	r16,15
	brne	videogen_lab14
	push	r18
	push	zl
	push	zh
	; Veraenderte Register -> r16-r18,z
	videogen_keycheck
	pop	zh
	pop	zl
	pop	r18
videogen_lab14:
	; Autosound: Vorbereitungen fuer das naechste Daten-Byte
	lds	r17,AUTOSND
	tst	r17
	breq	videogen_lab35
	sts	AUTOSNDSYNC2,regzero
	lds	r17,AUTOSNDSYNC
	dec	r17
	breq	videogen_lab36
	sts	AUTOSNDSYNC,r17
	rjmp	videogen_lab35
videogen_lab36:
	lds	r17,AUTOSND
	sts	AUTOSNDSYNC,r17
	ldi	r17,1
	sts	AUTOSNDSYNC2,r17
	push	zl
	push	zh
	push	r18
	in	r18,PORTD
	mov	r17,r18
	lds	r16,LOWHIMEM
	sbrc	r16,LOWHIMEMSOUND
	ori	r17,(1<<PORTD3)
	out	PORTD,r17
	lds	zl,AUTOSNDPTR
	lds	zh,AUTOSNDPTR+1
	ld	r16,z+
	sts	AUTOSNDPTR,zl
	sts	AUTOSNDPTR+1,zh
	out	PORTD,r18
	sts	AUTOSNDDATA,r16
	lds	zl,AUTOSNDCNT
	lds	zh,AUTOSNDCNT+1
	ld	r16,-z
	sts	AUTOSNDCNT,zl
	sts	AUTOSNDCNT+1,zh
	or	zl,zh
	brne	videogen_lab34
	lds	r16,AUTOSNDREPEAT
	tst	r16
	brne	videogen_lab45
	sts	AUTOSND,regzero
	sts	AUTOSNDSYNC2,regzero
	out	TCCR2,regzero
videogen_lab34:
	pop	r18
	pop	zh
	pop	zl
videogen_lab35:
	pop	r17
	pop	r16
	out	SREG,r16
	pop	r16
	reti
videogen_lab45:
	lds	r16,AUTOSNDREPEATPTR
	sts	AUTOSNDPTR,r16
	lds	r16,AUTOSNDREPEATPTR+1
	sts	AUTOSNDPTR+1,r16
	lds	r16,AUTOSNDREPEATCNT
	sts	AUTOSNDCNT,r16
	lds	r16,AUTOSNDREPEATCNT+1
	sts	AUTOSNDCNT+1,r16
	ldi	r16,1
	sts	AUTOSNDREPEATED,r16
	rjmp	videogen_lab34

videogen_lab4:
	; Alle Zeilen angezeigt -> V-Sync. Phase
	; videogen_initvarvsync (in: -; out: -; changed: r16,r18)
	rcall	videogen_initvarvsync
	sei
	videogen_videomodecheck
	; Sprites loeschen (wenn noetig)
	sts	DRAWSPRITES,regzero
	lds	r16,MINSPRITEIDTODRAW
	tst	r16
	breq	videogen_lab21
	; Wird Sprite-Liste grad manipuliert?
	lds	r16,SPRITELISTINWORK
	tst	r16
	brne	videogen_lab21
	; Sprites loeschen
	push	r21
	push	r22
	push	xl
	push	xh
	push	yl
	push	yh
	; clearoverdrivedmsprites (in: -; out: z; changed: r16-r22,x,y,z)
	call	clearoverdrivedmsprites
	sts	SPRITELISTTMPPTR,zl
	sts	SPRITELISTTMPPTR+1,zh
	pop	yh
	pop	yl
	pop	xh
	pop	xl
	pop	r22
	pop	r21
	ldi	r16,255
	sts	DRAWSPRITES,r16
videogen_lab21:
	; Vertical-Sync-Interrupt (6502) aktiviert?
	lds	r16,INTMASK6502
	andi	r16,(1<<INT6502VSYNC)
	breq	videogen_lab30
	; Ausloesen VSYNC-6502-Interrupt
	ldi	r16,(1<<INT6502VSYNC)
	or	regint6502,r16
	; Ausloesen Abfrage Tastatur
	clr	r16
	rjmp	videogen_picexit
videogen_lab30:
	; Kein VSync-Interrupt -> Sprites zeichnen (wenn noetig)
	lds	r16,DRAWSPRITES
	tst	r16
	breq	videogen_lab13
	; Sprites neu zeichnen
	push	r0
	push	r1
	push	r21
	push	r22
	push	r23
	push	xl
	push	xh
	push	yl
	push	yh
	lds	yl,SPRITELISTTMPPTR
	lds	yh,SPRITELISTTMPPTR+1
	; drawchangedmsprites (in: y; out: -; changed: r0,r1,r16-r25,x,y,z)
	call	drawchangedmsprites
	pop	yh
	pop	yl
	pop	xh
	pop	xl
	pop	r23
	pop	r22
	pop	r21
	pop	r1
	pop	r0
videogen_lab13:
	; Timer erhoehen
	; videogen_timer (in: -; out: -; changed: r16-r19)
	rcall	videogen_timer
	; Ausloesen Abfrage Tastatur
	clr	r16
	rjmp	videogen_picexit

	; Schwarzphase
videogen_vsync:
	lds	r16,VSYNCROW
	inc	r16
	sts	VSYNCROW,r16

	lds	r17,INTERLACEPHASE
	tst	r17
	brne	videogen_lab5
	; Standard resp. Bild 1 wenn Interlace (short frame)
	; Start pre-vsync?
	cpi	r16,0
	breq	videogen_lab11
	; Start main-vsync?
	cpi	r16,5
	breq	videogen_lab6
	; Start post-vsync?
	cpi	r16,10
	breq	videogen_lab11
	; Ende vsync?
	cpi	r16,14
	breq	videogen_lab8
	; Start Bild?
	lds	r17,STARTROW
videogen_lab37:
	cp	r16,r17
	breq	videogen_lab9
	rjmp	videogen_vsyncexit
videogen_lab11:
	videogen_vertsyncprepost
	rjmp	videogen_vsyncexit
videogen_lab6:
	videogen_vertsyncmain
	rjmp	videogen_vsyncexit
videogen_lab8:
	videogen_horizsync
	rjmp	videogen_vsyncexit
videogen_lab9:
	ldi	r17,1
	sts	PICROW,r17
	; Ausloesen Abfrage Tastatur
	clr	r16
	rjmp	videogen_vsyncexit

videogen_lab5:
	; Bild 2 wenn Interlace (long frame)
	; Start pre-vsync?
	cpi	r16,0
	breq	videogen_lab11
	; Start main-vsync?
	cpi	r16,6
	breq	videogen_lab6
	; Start post-vsync?
	cpi	r16,11
	breq	videogen_lab11
	; Ende vsync?
	cpi	r16,16
	breq	videogen_lab8
	; Start Bild?
	lds	r17,STARTROW
	dec	r17
	rjmp	videogen_lab37


videogen_colormode:
	; Timer-Stand liegt bei VGRINITCYC+70-8
	; Pointer auf die aktuellen Daten im externen SRAM
	lds	zl,ACTMCOLMAPPTR	; 2 Zyklen
	lds	zh,ACTMCOLMAPPTR+1	; 2 Zyklen

	; Daten aus Low- oder aus High-Memory?
	in	r25,PORTD		; 1 Zyklus
	mov	r17,r25			; 1 Zyklus
	lds	r16,LOWHIMEM		; 2 Zyklen
	sbrc	r16,LOWHIMEMVIDEO	; 2 Zyklen / 1 Zyklus
	ori	r17,(1<<PORTD3)		; 1 Zyklus
	out	PORTD,r17		; 1 Zyklus

	; Ausgabe des "Clock-Patterns"
	ldi	r16,204			; 1 Zyklus
	out	PORTC,r16		; 1 Zyklus
	; "technischer" Parameter
	ldi	r18,5			; 1 Zyklus

	; Timer-Stand liegt bei VGRINITCYC+84-8
	nop

	; Ausgabe von 80*2 Pixeln
	videogen_outcolor_20
	videogen_outcolor_20
	videogen_outcolor_20
	videogen_outcolor_20

	; Hintergrundfarbe wieder auf schwarz setzen
	out	PORTA,regzero		; 1 Zyklus
	; A16 restaurieren
	out	PORTD,r25		; 1 Zyklus
	; 3 Zyklen Zeitverzoegerung
	ld	r17,z			; 3 Zyklen
	ldi	r19,5			; 1 Zyklus
	out	PORTE,r19		; 1 Zyklus
	out	PORTE,r20		; 1 Zyklus

	; Externes RAM einblenden
	ldi	r16,(1<<SRE)
	out	MCUCR,r16

	rjmp	videogen_lab17
