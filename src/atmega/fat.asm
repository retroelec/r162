; fat.asm, v1.6.2: FAT functions for the r162 system
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


; Funktionen, bei denen die Video-Generator-Interrupts ausgeschaltet werden:
;   fatinit, fatls, fatcd, fatopen6502,
;   fatreadnextsector6502, fatwritenextsector6502,
;   fatload, fatsave,
;   fatrmorextcc6502

; Funktionen, bei denen ein SD-Karten-Zugriff erfolgt:
;   fatinit, fatdiriter, fatgetnextsect,
;   fatreadnextsector, fatwritenextsector,
;   fatrmorextcc6502

; Wichtige Informationen des Bootsektors
.EQU	BOOT_NUMRESSEKL = 0x0e
.EQU	BOOT_NUMBYTESPERSEKL = 0x0b
.EQU	BOOT_NUMFATCOPIES = 0x10
.EQU	BOOT_NUMSEKPERFATL = 0x16
.EQU	BOOT_BIOSSIGNL = 0x1fe
.EQU	BOOT_FATVARIANT = 0x36
.EQU	BOOT_MAXNUMENTRIESINROOTDIRL = 17
.EQU	BOOT_NUMSECTPERCLUSTER = 13

; Wichtige Informationen des Master Boot Records
.EQU	MASTERBOOT_BOOTSEKT = 0x1c6
.EQU	MASTERBOOT_BIOSSIGNL = 0x1fe

; Wichtige Informationen eines Directory-Eintrags
.EQU	FATDIR_ATTR = 11
.EQU	FATDIR_STARTCLUST = 26
.EQU	FATDIR_SIZE = 28

; ID des FAT-Datei-Systems
FAT16ID:
	.db	"FAT16", 0
; String zur Kennzeichnung eines Verzeichnisses
FATDIRSTR:
	.db	"<dir>", 0


fatinit_lab2:
	rjmp	fatinit_lab1

fatinit:
	; Initialisierung des FAT-Dateisystems
	; Signatur fatinit (in: -; out: r17; changed: r0-r4,r13-r22,x,z)
	; Ausgabe: r17 -> Error-Code resp. 0 (= ok)
	; Veraenderte Register: r0-r4, r13-r22, x, z

	sts	FATFSOK,regzero

	; Keine Video-Generator-Interrupts erlauben zur fehlerfreien Datenuebertragung
	videogen_disableint

	; Initialisierung der SD-Card
	; sdinit (in: -; out: r16; changed: r16-r23)
	call	sdinit
	ldi	r17,FATERRSDCARD
	tst	r16
	brne	fatinit_lab2

	; Lese Master Boot Record oder Bootsektor
	clr	r13
	clr	r14
	clr	r15
	clr	r20
	clr	r21
	clr	r22
	ldi	zl,low(FATBUFFER)
	ldi	zh,high(FATBUFFER)
	; sdreadsector (in: r20-r22,z; out: r16; changed: r16-r22,z)
	call	sdreadsector
	ldi	r17,FATERRREADMBR
	tst	r16
	brne	fatinit_lab2

	; Master Boot Record oder Bootsektor?
	ldi	xl,low(FATBUFFER+BOOT_FATVARIANT)
	ldi	xh,high(FATBUFFER+BOOT_FATVARIANT)
	ldi	zl,low(FAT16ID<<1)
	ldi	zh,high(FAT16ID<<1)
	ldi	r18,3
	clr	r19
	; strncmp (in: r18,r19,x,z; out: r16; changed: r16-r18,x,z)
	call	strncmp
	tst	r16
	breq	fatinit_lab4

	; Ist dies ein gueltiger Master Boot Record?
	ldi	r17,FATERRINVALIDMBR
	ldi	zl,low(FATBUFFER+MASTERBOOT_BIOSSIGNL)
	ldi	zh,high(FATBUFFER+MASTERBOOT_BIOSSIGNL)
	ld	r16,z+
	cpi	r16,0x55
	brne	fatinit_lab2
	ld	r16,z+
	cpi	r16,0xaa
	brne	fatinit_lab2

	; Bestimme Sektor-Nummer des Bootsektors
	ldi	zl,low(FATBUFFER+MASTERBOOT_BOOTSEKT)
	ldi	zh,high(FATBUFFER+MASTERBOOT_BOOTSEKT)
	ld	r20,z+
	ld	r21,z+
	ld	r22,z+
	mov	r13,r20
	mov	r14,r21
	mov	r15,r22

	; Lese Bootsektor
	ldi	zl,low(FATBUFFER)
	ldi	zh,high(FATBUFFER)
	; sdreadsector (in: r20-r22,z; out: r16; changed: r16-r22,z)
	call	sdreadsector
	ldi	r17,FATERRREADBOOT
	tst	r16
	brne	fatinit_lab2

fatinit_lab4:
	; Ist dies ein gueltiger Bootsektor?
	ldi	r17,FATERRINVALIDBOOT
	ldi	zl,low(FATBUFFER+BOOT_BIOSSIGNL)
	ldi	zh,high(FATBUFFER+BOOT_BIOSSIGNL)
	ld	r16,z+
	cpi	r16,0x55
fatinit_lab3:
	brne	fatinit_lab2
	ld	r16,z+
	cpi	r16,0xaa
	brne	fatinit_lab3

	; FAT16?
	ldi	xl,low(FATBUFFER+BOOT_FATVARIANT)
	ldi	xh,high(FATBUFFER+BOOT_FATVARIANT)
	ldi	zl,low(FAT16ID<<1)
	ldi	zh,high(FAT16ID<<1)
	ldi	r18,5
	clr	r19
	; strncmp (in: r18,r19,x,z; out: r16; changed: r16-r18,x,z)
	call	strncmp
	ldi	r17,FATERRINVALIDFATSYS
	tst	r16
	brne	fatinit_lab1

	; 512 Bytes pro Sektor?
	ldi	r17,FATERRINVALIDBYTESPERSECT
	ldi	zl,low(FATBUFFER)
	ldi	zh,high(FATBUFFER)
	ldd	r16,z+BOOT_NUMBYTESPERSEKL
	tst	r16
	brne	fatinit_lab1
	ldd	r16,z+BOOT_NUMBYTESPERSEKL+1
	cpi	r16,2
	brne	fatinit_lab1

	; Bestimme Start-Sektor-Nummer der FAT
	ldi	xl,low(FATFATSTARTSECNR)
	ldi	xh,high(FATFATSTARTSECNR)
	ldd	r16,z+BOOT_NUMRESSEKL
	add	r13,r16
	ldd	r16,z+BOOT_NUMRESSEKL+1
	adc	r14,r16
	adc	r15,regzero
	st	x+,r13
	st	x+,r14
	st	x+,r15

	; Bestimme Start-Sektor-Nummer des Stammverzeichnisses
	ldd	r16,z+BOOT_NUMFATCOPIES
	ldd	r17,z+BOOT_NUMSEKPERFATL
	sts	FATNUMSECFAT,r17
	ldd	r18,z+BOOT_NUMSEKPERFATL+1
	sts	FATNUMSECFAT+1,r18
	; mul8x16 (in: r16-r18; out: r2-r4; changed: r0-r4)
	call	mul8x16
	add	r2,r13
	adc	r3,r14
	adc	r4,r15
	st	x+,r2
	st	x+,r3
	st	x+,r4

	; Bestimme Anzahl Sektoren des Stammverzeichnisses und die Start-Sektor-Nummer des Datenbereichs
	ldd	r16,z+BOOT_MAXNUMENTRIESINROOTDIRL
	ldd	r17,z+BOOT_MAXNUMENTRIESINROOTDIRL+1
	lsr	r17
	ror	r16
	lsr	r17
	ror	r16
	lsr	r17
	ror	r16
	lsr	r17
	ror	r16
	st	x+,r16
	st	x+,r17
	add	r2,r16
	adc	r3,r17
	adc	r4,regzero
	st	x+,r2
	st	x+,r3
	st	x+,r4

	; Bestimme Anzahl Sektoren pro Cluster
	ldd	r16,z+BOOT_NUMSECTPERCLUSTER
	st	x+,r16

	; Nach der Initialisierung befindet man sich im Stammverzeichnis
	sts	FATROOTDIRFLAG,regzero

	ldi	r17,0
	ldi	r16,1
	sts	FATFSOK,r16
fatinit_lab1:
	; Video-Generator-Interrupts wieder erlauben
	; videogen_enableint (in: -; out: -; changed: r16,r18)
	jmp	videogen_enableint


fatgetnextsect:
	; Ermittelt den naechsten Sektor der Datei (Aktualisierung des aktuellen Sektors in der Datei-Struktur)
	; Signatur fatgetnextsect (in: y; out: r17; changed: r0-r4,r16-r22,z)
	; Eingabe: y -> Pointer auf die Datei-Struktur
	; Ausgabe: r17 -> Error- resp. Info-Code resp. 0 (= ok)
	; Veraenderte Register: r0-r4, r16-r22, z

	; Naechster Sektor im aktuellen Cluster?
	ldd	r17,y+FILEACTSECTINCLUST
	lds	r16,FATNUMSECPERCLUST
	cpi	r17,255
	breq	fatgetnextsect_lab4
	inc	r17
	cp	r17,r16
	brsh	fatgetnextsect_lab1
	; Ja, inkrementiere aktuellen Sektor
	std	y+FILEACTSECTINCLUST,r17
	ldi	r17,1
	ldd	r16,y+FILEACTSECT
	add	r16,r17
	std	y+FILEACTSECT,r16
	ldd	r16,y+FILEACTSECT+1
	adc	r16,regzero
	std	y+FILEACTSECT+1,r16
	ldd	r16,y+FILEACTSECT+2
	adc	r16,regzero
	std	y+FILEACTSECT+2,r16
	ldi	r17,0
	ret
fatgetnextsect_lab4:
	ldd	r17,y+FILESTARTCLUST
	std	y+FILENEXTCLUST,r17
	ldd	r17,y+FILESTARTCLUST+1
	std	y+FILENEXTCLUST+1,r17
fatgetnextsect_lab1:
	; Naechster Cluster -> aktueller Cluster
	ldd	r17,y+FILENEXTCLUST
	ldd	r18,y+FILENEXTCLUST+1
	cpi	r17,248
	brlo	fatgetnextsect_lab3
	cpi	r18,255
	brne	fatgetnextsect_lab3
	ldi	r17,FATINFOLASTCLUST
	ret
fatgetnextsect_lab3:
	; Naechster Sektor im naechsten Cluster
	std	y+FILEACTSECTINCLUST,regzero
	subi	r17,2
	sbc	r18,regzero
	; Ermitteln des aktuellen Sektors
	; mul8x16 (in: r16-r18; out: r2-r4; changed: r0-r4)
	call	mul8x16
	lds	r16,FATDATASTARTSECNR
	add	r2,r16
	lds	r16,FATDATASTARTSECNR+1
	adc	r3,r16
	lds	r16,FATDATASTARTSECNR+2
	adc	r4,r16
	std	y+FILEACTSECT,r2
	std	y+FILEACTSECT+1,r3
	std	y+FILEACTSECT+2,r4
	; Lese FAT-Block, in dem der Wert des aktuellen Clusters festgehalten ist
	ldi	zl,low(FATFATSTARTSECNR)
	ldi	zh,high(FATFATSTARTSECNR)
	ldd	r18,y+FILENEXTCLUST+1
	ld	r20,z+
	; 256 Eintraege pro FAT-Block
	; -> nur High-Byte von y+FILENEXTCLUST wird benoetigt zur Bestimmung des Sektors
	add	r20,r18
	ld	r21,z+
	adc	r21,regzero
	ld	r22,z+
	adc	r22,regzero
	ldi	zl,low(FATBUFFER)
	ldi	zh,high(FATBUFFER)
	; sdreadsector (in: r20-r22,z; out: r16; changed: r16-r22,z)
	call	sdreadsector
	ldi	r17,FATERRREADFAT
	tst	r16
	brne	fatgetnextsect_lab2
	; Bestimme naechsten Cluster
	ldi	zl,low(FATBUFFER)
	ldi	zh,high(FATBUFFER)
	ldd	r17,y+FILENEXTCLUST
	; 256 Eintraege pro FAT-Block
	; -> nur Low-Byte von y+FILENEXTCLUST wird benoetigt zur Bestimmung des Eintrags
	lsl	r17
	adc	zh,regzero
	; Wenn Register zl == 0 ist, dann kann es bei der folgenden Addition keinen Ueberlauf geben
	; -> adc zh,regzero ist ueberfluessig
	add	zl,r17
	ld	r17,z+
	ld	r18,z+
	std	y+FILENEXTCLUST,r17
	std	y+FILENEXTCLUST+1,r18
	ldi	r17,0
fatgetnextsect_lab2:
	ret


fatrmorextcc6502:
	; <proc>
	;   <name>fatrmorextcc6502</name>
	;   <descg>"Support-Funktion": Fuer eine Datei einen neuen Clusters allozieren oder die Cluster-Kette "loeschen" (Register (a,x,y) bleiben *nicht* erhalten!)</descg>
	;   <desce>"support function": allocate a new cluster for a file or remove cluster chain (registers (a,x,y) are *not* preserved!)</desce>
	;   <input>
	;     <rparam>
	;       <name>x</name>
	;       <descg>Low-Byte des Pointers auf die &lt;a href="#fatloadsavestructure"&gt;fatloadsave-Struktur&lt;/a&gt;</descg>
	;       <desce>low byte of the pointer to the &lt;a href="#fatloadsavestructure"&gt;fatloadsave structure&lt;/a&gt;</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <descg>High-Byte des Pointers auf die &lt;a href="#fatloadsavestructure"&gt;fatloadsave-Struktur&lt;/a&gt;</descg>
	;       <desce>high byte of the pointer to the &lt;a href="#fatloadsavestructure"&gt;fatloadsave structure&lt;/a&gt;</desce>
	;     </rparam>
	;     <mparam>
	;       <name>FATEMPTYCLUST6502</name>
	;       <descg>Ermittelter leerer Cluster (Nummer)</descg>
	;       <desce>determined empty cluster (number)</desce>
	;     </mparam>
	;     <mparam>
	;       <name>FATRMFLAG6502</name>
	;       <descg>Flag, das signalisiert, ob die Cluster-Kette geloescht oder erweitert werden soll</descg>
	;       <desce>flag to signal if the cluster chain should be removed or extended</desce>
	;     </mparam>
	;   </input>
	;   <output>
	;     <mparam>
	;       <name>RERRCODE6502</name>
	;       <descg>Neuen Cluster alloz.: 0 = OK, FATINFOLASTCLUST = Info. -> Start-Cluster muss ausserhalb von fatrmorextcc6502 gesetzt werden&lt;br&gt;"Loeschen" der Cluster-Kette: groesser gleich 248 = OK, FATINFOLASTCLUST = Datei war schon "leer"</descg>
	;       <desce>allocate a new cluster: 0 = OK, FATINFOLASTCLUST = info. -> start cluster must be set outside of fatrmorextcc6502 (nothing done)&lt;br&gt;remove cluster chain: greater or equal 248 = OK, FATINFOLASTCLUST = file already "empty"</desce>
	;     </mparam>
	;   </output>
	; </proc>

	push	yl
	push	yh
	; do not save register r2-r4 -> 6502 registers a, x, y will be changed!
	mov	zl,regx
	mov	zh,regy
	add	zh,regmemoff6502
	ldd	yl,z+FATLOADSAVE_FILE
	ldd	yh,z+FATLOADSAVE_FILE+1
	add	yh,regmemoff6502
	; Keine Video-Generator-Interrupts erlauben zur fehlerfreien Datenuebertragung
	videogen_disableint

	; init. to start from "start cluster"
	ldi	r17,255
	std	y+FILEACTSECTINCLUST,r17

fatrmorextcc6502_lab1:
	; fatgetnextsect (in: y; out: r17; changed: r0-r4,r16-r22,z)
	rcall	fatgetnextsect
	; undocumented output: r20-r22, z
	cpi	r17,FATINFOLASTCLUST
	breq	fatrmorextcc6502_lab2
	tst	r17
	brne	fatrmorextcc6502_lab2

	; test for end of "cluster chain"
	ldd	r17,y+FILENEXTCLUST
	ldd	r18,y+FILENEXTCLUST+1
	cpi	r17,248
	brlo	fatrmorextcc6502_lab3
	cpi	r18,255
	brne	fatrmorextcc6502_lab3

	; end of "cluster chain" reached
	lds	r16,FATRMFLAG6502
	tst	r16
	brne	fatrmorextcc6502_lab2
	; alloc. cluster -> fill buffer
	lds	r18,FATEMPTYCLUST6502+1
	std	y+FILENEXTCLUST+1,r18
	st	-z,r18
	lds	r17,FATEMPTYCLUST6502
	std	y+FILENEXTCLUST,r17
	st	-z,r17
	; write buffer
	rcall	fatrmorextcc6502_lab5
	ldi	r17,FATERRWRITE
	tst	r16
	brne	fatrmorextcc6502_lab2
	; set correct position in file
	ldi	r17,254
	std	y+FILEACTSECTINCLUST,r17
	clr	r17

fatrmorextcc6502_lab2:
	; Video-Generator-Interrupts wieder erlauben
	; videogen_enableint (in: -; out: -; changed: r16,r18)
	call	videogen_enableint
	pop	yh
	pop	yl
fatrmorextcc6502_lab6:
	sts	RERRCODE6502,r17
	ret

fatrmorextcc6502_lab3:
	; end not reached yet, continue
	lds	r16,FATRMFLAG6502
	tst	r16
	breq	fatrmorextcc6502_lab4
	; remove cluster
	ldi	r16,255
	st	-z,r16
	st	-z,r16
	rcall	fatrmorextcc6502_lab5
	ldi	r17,FATERRWRITE
	tst	r16
	brne	fatrmorextcc6502_lab2
fatrmorextcc6502_lab4:
	; next cluster
	ldi	r17,254
	std	y+FILEACTSECTINCLUST,r17
	rjmp	fatrmorextcc6502_lab1

fatrmorextcc6502_lab5:
	; write buffer
	lsr	r22
	ror	r21
	ror	r20
	ldi	zl,low(FATBUFFER)
	ldi	zh,high(FATBUFFER)
	; sdwritesector (in: r20-r22,z; out: r16; changed: r16-r22,z)
	jmp	sdwritesector


fatcpmem:
	; Kopiere einen String
	; Signatur fatcpmem (in: x,z; out: x; changed: r16,x,z)
	; Eingabe: x -> Pointer auf den Ziel-Bereich
	; Eingabe: z -> Pointer auf den Quell-Bereich
	; Ausgabe: x -> Pointer auf das Ende des kopierten Strings
	; Veraenderte Register: r16, x, z
	ld	r16,z+
	st	x+,r16
	tst	r16
	brne	fatcpmem
	ld	r16,-x
	ret


fatdiriter_lab9:
	sts	FATFSOK,regzero
	ret

fatdiriter:
	; Iteration ueber ein Verzeichnis
	; Signatur fatdiriter List-Modus (in: r23; out: r17; changed: r0-r4,r7-r22,r24-r25,x,y,z)
	; Signatur fatdiriter Such-Modus (in: r23; out: r17,y; changed: r0-r4,r9-r22,r24-r25,x,y,z)
	; Eingabe: r23 -> Modus: == 0 -> List-Modus, == 1 -> Such-Modus (Nach der zu suchenden Datei in FATDIRITERNAME, Pointer auf Datei-Struktur in FATDIRITERFILE), == 2 -> Spezial-Modus (Suche nach leerem Dateieintrag)
	; Ausgabe: r17 -> Error-Code resp. 0 (= ok)
	; Ausgabe (Such-Modus): y -> Pointer auf Datei-Struktur
	; Ausgabe (Such-Modus): r2 -> Dateiattribute
	; Veraenderte Register: r0-r4, r7-r22, r24-r25, x, y, z

	; Vorbereitungen fuer den List-Modus
	tst	r23
	brne	fatdiriter_lab27
	sts	FATLSBUF,regzero
	ldi	r16,low(FATLSBUF)
	mov	r7,r16
	ldi	r16,high(FATLSBUF)
	mov	r8,r16
fatdiriter_lab27:
	; Stammverzeichnis?
	lds	r16,FATROOTDIRFLAG
	tst	r16
	brne	fatdiriter_lab24
	; Aktuelles Verzeichnis ist das Stammverzeichnisses
	ldi	zl,low(FATROOTSTARTSECNR)
	ldi	zh,high(FATROOTSTARTSECNR)
	; Hole Start-Sektor-Nummer + Anzahl Sektoren des Verzeichnisses
	ld	r20,z+
	ld	r21,z+
	ld	r22,z+
	ld	r11,z+
	ld	r12,z+
	; Anzahl aktuell eingelesener Sektoren gleich 0
	clr	r24
	clr	r25
fatdiriter_lab4:
	; Rette aktuelle Sektor-Nummer
	mov	r13,r20
	mov	r14,r21
	mov	r15,r22
	rjmp	fatdiriter_lab26
fatdiriter_lab24:
	; Aktuelles Verzeichnis ist ein "normales" Verzeichnis
	ldi	yl,low(FATACTDIR)
	ldi	yh,high(FATACTDIR)
	ldi	r16,255
	std	y+FILEACTSECTINCLUST,r16
fatdiriter_lab25:
	; Aktuelles Verzeichnis ist ein "normales" Verzeichnis
	ldi	yl,low(FATACTDIR)
	ldi	yh,high(FATACTDIR)
	; fatgetnextsect (in: y; out: r17; changed: r0-r4,r16-r22,z)
	rcall	fatgetnextsect
	cpi	r17,FATINFOLASTCLUST
	breq	fatdiriter_lab28
	tst	r17
	brne	fatdiriter_lab9
	ldd	r20,y+FILEACTSECT
	ldd	r21,y+FILEACTSECT+1
	ldd	r22,y+FILEACTSECT+2
fatdiriter_lab26:
	sts	FATOPENACTSECT6502,r20
	sts	FATOPENACTSECT6502+1,r21
	sts	FATOPENACTSECT6502+2,r22
	; Lese aktuellen Sektor
	ldi	zl,low(FATBUFFER)
	ldi	zh,high(FATBUFFER)
	; sdreadsector (in: r20-r22,z; out: r16; changed: r16-r22,z)
	call	sdreadsector
	ldi	r17,FATERRDI1
	tst	r16
	brne	fatdiriter_lab9
	ldi	zl,low(FATBUFFER)
	ldi	zh,high(FATBUFFER)
	clr	r3
fatdiriter_lab3:
	sts	FATOPENACTENTRY6502,r3
	; Test, ob dies der letzte Eintrag ist
	ld	r17,z
	tst	r17
	brne	fatdiriter_lab28
	rjmp	fatdiriter_lab1
fatdiriter_lab28:
	; Spezial-Eintrag?
	ldd	r16,z+FATDIR_ATTR
	cpi	r16,15
	breq	fatdiriter_lab18
	; Geloeschter Eintrag?
	cpi	r17,229
	breq	fatdiriter_lab31
	mov	r2,r16
	tst	r23
	brne	fatdiriter_lab20
	; List-Modus -> Ermittle Dateigroesse
	ldd	r9,z+FATDIR_SIZE
	ldd	r10,z+FATDIR_SIZE+1
fatdiriter_lab20:
	cpi	r23,2
	breq	fatdiriter_lab18
	; Extrahiere den Datei-Namen
	push	zl
	push	zh
	ldi	xl,low(FATENTRYNAME)
	ldi	xh,high(FATENTRYNAME)
	ldi	r18,8
fatdiriter_lab10:
	ld	r16,z+
	cpi	r16,' '
	breq	fatdiriter_lab11
	st	x+,r16
	dec	r18
	brne	fatdiriter_lab10
	rjmp	fatdiriter_lab14
fatdiriter_lab15:
	ld	r16,z+
fatdiriter_lab11:
	dec	r18
	brne	fatdiriter_lab15
fatdiriter_lab14:
	ld	r16,z
	cpi	r16,' '
	breq	fatdiriter_lab12
	ldi	r16,'.'
	st	x+,r16
	ldi	r18,3
fatdiriter_lab13:
	ld	r16,z+
	cpi	r16,' '
	breq	fatdiriter_lab12
	st	x+,r16
	dec	r18
	brne	fatdiriter_lab13
fatdiriter_lab12:
	st	x,regzero
	cpi	r23,1
	brne	fatdiriter_lab19
	rjmp	fatdiriter_lab7
fatdiriter_lab31:
	cpi	r23,2
	breq	fatdiriter_lab32
fatdiriter_lab18:
	rjmp	fatdiriter_lab2
fatdiriter_lab19:
	; List-Modus
	mov	xl,r7
	mov	xh,r8
	mov	r16,r2
	andi	r16,16
	brne	fatdiriter_lab17
	mov	r18,r9
	mov	r19,r10
	; itoaformat (in: r18,r19; out: -; changed: r16-r21,z)
	call itoaformat
	ldi	zl,low(ITOASTRING)
	ldi	zh,high(ITOASTRING)
	; fatcpmem (in: x,z; out: x; changed: r16,x,z)
	rcall	fatcpmem
	rjmp	fatdiriter_lab23
fatdiriter_lab17:
	ldi	zl,low(FATDIRSTR<<1)
	ldi	zh,high(FATDIRSTR<<1)
fatdiriter_lab29:
	lpm	r16,z+
	st	x+,r16
	tst	r16
	brne	fatdiriter_lab29
fatdiriter_lab23:
	ldi	r17,4
	ldi	r16,' '
fatdiriter_lab30:
	st	x+,r16
	dec	r17
	brne	fatdiriter_lab30
	ldi	zl,low(FATENTRYNAME)
	ldi	zh,high(FATENTRYNAME)
	; fatcpmem (in: x,z; out: x; changed: r16,x,z)
	rcall	fatcpmem
	ldi	r16,10
	st	x+,r16
	st	x+,regzero
	st	x,regzero
	mov	r7,xl
	mov	r8,xh
fatdiriter_lab6:
	pop	zh
	pop	zl
fatdiriter_lab2:
	; Naechster Eintrag
	adiw	zl,32
	inc	r3
	; Alle Eintraege des aktuellen Sektors abgearbeitet?
	mov	r16,r3
	cpi	r16,16
	brne	fatdiriter_lab16
	lds	r16,FATROOTDIRFLAG
	tst	r16
	brne	fatdiriter_lab21
	; Ja - Wurden bereits alle Sektoren des Stammverzeichnisses abgearbeitet?
	adiw	r24,1
	cp	r24,r11
	brne	fatdiriter_lab5
	cp	r25,r12
	brne	fatdiriter_lab5
fatdiriter_lab1:
	cpi	r23,1
	breq	fatdiriter_lab22
fatdiriter_lab32:
	ldi	r17,0
	ret
fatdiriter_lab22:
	ldi	r17,FATERRFNF
	ret
fatdiriter_lab16:
	rjmp	fatdiriter_lab3
fatdiriter_lab21:
	rjmp	fatdiriter_lab25
fatdiriter_lab5:
	; Stammverzeichnis: Naechster Sektor lesen
	mov	r20,r13
	mov	r21,r14
	mov	r22,r15
	inc	r20
	brne	fatdiriter_lab8
	inc	r21
	brne	fatdiriter_lab8
	inc	r22
fatdiriter_lab8:
	rjmp	fatdiriter_lab4
fatdiriter_lab7:
	; Such-Modus
	ldi	zl,low(FATENTRYNAME)
	ldi	zh,high(FATENTRYNAME)
	lds	xl,FATDIRITERNAME
	lds	xh,FATDIRITERNAME+1
	ldi	r18,12
	ldi	r19,1
	; strncmp (in: r18,r19,x,z; out: r16; changed: r16-r18,x,z)
	call	strncmp
	tst	r16
	brne	fatdiriter_lab6
	pop	zh
	pop	zl
	; Datei gefunden -> Befuellen der Datei-Struktur
	lds	yl,FATDIRITERFILE
	lds	yh,FATDIRITERFILE+1
	ldd	r16,z+FATDIR_STARTCLUST
	std	y+FILESTARTCLUST,r16
	ldd	r16,z+FATDIR_STARTCLUST+1
	std	y+FILESTARTCLUST+1,r16
	ldi	r16,255
	std	y+FILEACTSECTINCLUST,r16
	ldd	r16,z+FATDIR_SIZE
	std	y+FILEMODSIZE,r16
	ldd	r16,z+FATDIR_SIZE+1
	mov	r17,r16
	andi	r16,1
	std	y+FILEMODSIZE+1,r16
	ldd	r18,z+FATDIR_SIZE+2
	ldd	r19,z+FATDIR_SIZE+3
	lsr	r19
	ror	r18
	ror	r17
	std	y+FILEDIVSIZE,r17
	std	y+FILEDIVSIZE+1,r18
	ldi	r17,0
	ret


fatsaveactdir:
	; Rette das aktuelle Verzeichnis
	; Signatur fatsaveactdir (in: -; out: -; changed: r16,r24-r25,z)
	; Veraenderte Register: r16, r24-r25, z

	lds	r16,FATROOTDIRFLAG
	sts	FATTMPROOTDIRFLAG,r16
	tst	r16
	breq	fatsaveactdir_lab1
	push	xl
	push	xh
	ldi	zl,low(FATACTDIR)
	ldi	zh,high(FATACTDIR)
	ldi	xl,low(FATTMPACTDIR)
	ldi	xh,high(FATTMPACTDIR)
	ldi	r24,FILESTRUCTSIZE
	clr	r25
	; memcopy (in: r24-r25,x,z; out: -; changed: r16,r24-r25,x,z)
	call	memcopy
	pop	xh
	pop	xl
fatsaveactdir_lab1:
	ret


fatrestoreactdir:
	; Restauriere das aktuelle Verzeichnis
	; Signatur fatrestoreactdir (in: -; out: -; changed: r16,r24-r25,x,z)
	; Veraenderte Register: r16, r24-r25, x, z

	lds	r16,FATTMPROOTDIRFLAG
	sts	FATROOTDIRFLAG,r16
	tst	r16
	breq	fatrestoreactdir_lab1
	ldi	zl,low(FATTMPACTDIR)
	ldi	zh,high(FATTMPACTDIR)
	ldi	xl,low(FATACTDIR)
	ldi	xh,high(FATACTDIR)
	ldi	r24,FILESTRUCTSIZE
	clr	r25
	; memcopy (in: r24-r25,x,z; out: -; changed: r16,r24-r25,x,z)
	jmp	memcopy
fatrestoreactdir_lab1:
	ret


fatchksavereg:
	sts	REG2,r2
	sts	REG3,r3
	sts	REG4,r4
	sts	REG7,r7
	sts	REG8,r8
	sts	REG25,r25
	sts	REGYL,yl
	sts	REGYH,yh
	ldi	r17,FATERRFSNOTINIT
	lds	r16,FATFSOK
	tst	r16
	ret

fatrestorereg:
	sts	RERRCODE6502,r17
	lds	r2,REG2
	lds	r3,REG3
	lds	r4,REG4
	lds	r7,REG7
	lds	r8,REG8
	lds	r25,REG25
	lds	yl,REGYL
	lds	yh,REGYH
	ret


fatls6502:
	; <proc>
	;   <name>fatls6502</name>
	;   <desce>list the actual directory</desce>
	;   <output>
	;     <mparam>
	;       <name>FATLSBUF</name>
	;       <desce>start of fatls buffer</desce>
	;     </mparam>
	;     <mparam>
	;       <name>RERRCODE6502</name>
	;       <desce>error code (0 = OK)</desce>
	;     </mparam>
	;   </output>
	; </proc>

	rcall	fatchksavereg
	breq	fatls6502_lab1
	rcall	fatls0
fatls6502_lab1:
	rjmp	fatrestorereg


fatls:
	; Ausgabe eines Verzeichnisses
	; Signatur fatls (in: -; out: r17; changed: r0-r4,r7-r25,x,y,z)
	; Ausgabe: r17 -> Error-Code resp. 0 (= ok)
	; Veraenderte Register: r0-r4, r7-r25, x, y, z

	ldi	r17,FATERRFSNOTINIT
	lds	r16,FATFSOK
	tst	r16
	breq	fatls_lab1
	rcall	fatls0
	tst	r17
	brne	fatls_lab1
	; "Seitenweises" Anzeigen der Dateien / Verzeichnisse
	mov	r15,r17
	lds	r21,PAGERACTIVE
	ldi	r16,1
	sts	PAGERACTIVE,r16
	sts	PAGERBREAK,regzero
	ldi	r16,24
	lds	zl,CURY
	sub	r16,zl
	sts	PAGERCNT,r16
	ldi	zl,low(FATLSBUF)
	ldi	zh,high(FATLSBUF)
fatls_lab2:
	; Undokumentierte Eigenschaften von printstring:
	; - z zeigt nach dem Aufruf auf das Ende des Strings
	; - printstring_lab0 muss das Register z uebergeben werden (statt r18, r19)
	; printstring_lab0 (in: z; out: z; changed: r16-r20,x,y,z)
	call	printstring_lab0
	lds	r16,PAGERBREAK
	tst	r16
	brne	fatls_lab3
	ld	r16,z
	tst	r16
	brne	fatls_lab2
fatls_lab3:
	sts	PAGERACTIVE,r21
	mov	r17,r15
fatls_lab1:
	ret

fatls0:
	; Keine Video-Generator-Interrupts erlauben zur fehlerfreien Datenuebertragung
	videogen_disableint
	clr	r23
	; fatdiriter List-Modus (in: r23; out: r17; changed: r0-r4,r7-r22,r24-r25,x,y,z)
	rcall	fatdiriter
	; Video-Generator-Interrupts wieder erlauben
	; videogen_enableint (in: -; out: -; changed: r16,r18)
	jmp	videogen_enableint


fatcd6502:
	; <proc>
	;   <name>fatcd6502</name>
	;   <desce>change directory</desce>
	;   <input>
	;     <rparam>
	;       <name>x</name>
	;       <desce>low byte of the pointer to the directory name</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <desce>high byte of the pointer to the directory name</desce>
	;     </rparam>
	;   </input>
	;   <output>
	;     <mparam>
	;       <name>RERRCODE6502</name>
	;       <desce>error code (0 = OK)</desce>
	;     </mparam>
	;   </output>
	; </proc>

	rcall	fatchksavereg
	breq	fatcd6502_lab1
	mov	xl,regx
	mov	xh,regy
	add	xh,regmemoff6502
	rcall	fatcd
fatcd6502_lab1:
	rjmp	fatrestorereg


fatcd:
	; Wechseln des aktiven Verzeichnisses
	; Signatur fatcd (in: x; out: r17; changed: r0-r4,r6,r9-r25,x,y,z)
	; Eingabe: x -> Name des Verzeichnisses
	; Ausgabe: r17 -> Error-Code resp. 0 (= ok)
	; Veraenderte Register: r0-r4, r6, r9-r25, x, y, z

	ldi	r17,FATERRFSNOTINIT
	lds	r16,FATFSOK
	tst	r16
	breq	fatls_lab1
	clr	r17
	; Keine Video-Generator-Interrupts erlauben zur fehlerfreien Datenuebertragung
	videogen_disableint
	ld	r16,x
	cpi	r16,'/'
	brne	fatcd_lab2
	; go to root directory
	sts	FATROOTDIRFLAG,regzero
fatcd_lab5:
	ld	r16,x+
fatcd_lab2:
	; in x position after a / (or at the beginnig)
	ld	r16,x
	tst	r16
	breq	fatcd_lab1
	sts	FATDIRITERNAME,xl
	sts	FATDIRITERNAME+1,xh
	clr	r6
fatcd_lab3:
	ld	r16,x+
	tst	r16
	breq	fatcd_lab4
	cpi	r16,'/'
	brne	fatcd_lab3
	mov	r6,r16
fatcd_lab4:
	st	-x,regzero
	ldi	yl,low(FATACTDIR)
	ldi	yh,high(FATACTDIR)
	sts	FATDIRITERFILE,yl
	sts	FATDIRITERFILE+1,yh
	ldi	r23,1
	push	xl
	push	xh
	; fatdiriter Such-Modus (in: r23; out: r17,y,r2; changed: r0-r4,r9-r22,r24-r25,x,y,z)
	rcall	fatdiriter
	pop	xh
	pop	xl
	; in r6 \0 or /
	st	x,r6
	tst	r17
	brne	fatcd_lab1
	; kein "cd" in eine Datei
	mov	r16,r2
	andi	r16,16
	breq	fatcd_lab8
	ldi	r16,1
	sts	FATROOTDIRFLAG,r16
	tst	r6
	brne	fatcd_lab5
fatcd_lab1:
	; Video-Generator-Interrupts wieder erlauben
	; videogen_enableint (in: -; out: -; changed: r16,r18)
	jmp	videogen_enableint
fatcd_lab8:
	ldi	r17,255
	jmp	videogen_enableint


; fatloadsave-Struktur:
	; <struct>
	;   <name>fatloadsavestructure</name>
	;   <titleg>fatloadsave-Struktur</titleg>
	;   <titlee>fatloadsave structure</titlee>
	;   <attr>
	;     <name>file</name>
	;     <descg>Pointer auf die Datei-Struktur (12 Bytes)</descg>
	;     <desce>pointer to the file structure (12 bytes)</desce>
	;     <offset>0</offset>
	;     <size>2</size>
	;   </attr>
	;   <attr>
	;     <name>name</name>
	;     <descg>Pointer auf den Datei-Namen</descg>
	;     <desce>pointer to the file name</desce>
	;     <offset>2</offset>
	;     <size>2</size>
	;   </attr>
	;   <attr>
	;     <name>mem</name>
	;     <descg>Pointer auf den Speicherbereich</descg>
	;     <desce>pointer to the memory region</desce>
	;     <offset>4</offset>
	;     <size>2</size>
	;   </attr>
	; </struct>


fatopen6502:
	; <proc>
	;   <name>fatopen6502</name>
	;   <descg>Oeffnen einer Datei</descg>
	;   <desce>open a file</desce>
	;   <input>
	;     <rparam>
	;       <name>x</name>
	;       <descg>Low-Byte des Pointers auf die &lt;a href="#fatloadsavestructure"&gt;fatloadsave-Struktur&lt;/a&gt;</descg>
	;       <desce>low byte of the pointer to the &lt;a href="#fatloadsavestructure"&gt;fatloadsave structure&lt;/a&gt;</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <descg>High-Byte des Pointers auf die &lt;a href="#fatloadsavestructure"&gt;fatloadsave-Struktur&lt;/a&gt;</descg>
	;       <desce>high byte of the pointer to the &lt;a href="#fatloadsavestructure"&gt;fatloadsave structure&lt;/a&gt;</desce>
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

	rcall	fatchksavereg
	breq	fatopen6502_lab1
	mov	zl,regx
	mov	zh,regy
	add	zh,regmemoff6502
	ldd	xl,z+FATLOADSAVE_NAME
	ldd	xh,z+FATLOADSAVE_NAME+1
	add	xh,regmemoff6502
	ldd	yl,z+FATLOADSAVE_FILE
	ldd	yh,z+FATLOADSAVE_FILE+1
	add	yh,regmemoff6502
	; Keine Video-Generator-Interrupts erlauben zur fehlerfreien Datenuebertragung
	videogen_disableint
	; fatopen (in: x,y; out: r17; changed: r0-r4,r9-r25,x,z)
	rcall	fatopen
	; Video-Generator-Interrupts wieder erlauben
	; videogen_enableint (in: -; out: -; changed: r16,r18)
	call	videogen_enableint
fatopen6502_lab1:
	rjmp	fatrestorereg


fatopen:
	; Oeffnen einer Datei
	; Signatur fatopen (in: x,y; out: r17; changed: r0-r4,r9-r25,x,z)
	; Eingabe: x -> Name der zu suchenden Datei
	; Eingabe: y -> Pointer auf die Datei-Struktur
	; Ausgabe: r17 -> Error-Code resp. 0 (= ok)
	; Veraenderte Register: r0-r4, r9-r25, x, z

	; fatsaveactdir (in: -; out: -; changed: r16,r24-r25,z)
	rcall	fatsaveactdir
	mov	zl,xl
	mov	zh,xh
	ldi	r17,1
fatopen_lab1:
	ld	r16,z+
	inc	r17
	tst	r16
	brne	fatopen_lab1
fatopen_lab2:
	dec	r17
	breq	fatopen_lab3
	ld	r16,-z
	cpi	r16,'/'
	brne	fatopen_lab2
	st	z,regzero
	push	zl
	push	zh
	; fatcd (in: x; out: r17; changed: r0-r4,r6,r9-r25,x,y,z)
	push	yl
	push	yh
	push	r6
	rcall	fatcd
	; Video-Generator-Interrupts wurden am Ende von fatcd eingeschaltet
	; -> sofort wieder ausschalten
	videogen_disableint
	pop	r6
	pop	yh
	pop	yl
	pop	zh
	pop	zl
	ldi	r16,'/'
	st	z+,r16
	tst	r17
	brne	fatopen_lab4
fatopen_lab3:
	sts	FATDIRITERNAME,zl
	sts	FATDIRITERNAME+1,zh
	sts	FATDIRITERFILE,yl
	sts	FATDIRITERFILE+1,yh
	ldi	r23,1
	ld	r16,z
	tst	r16
	brne	fatopen_lab5
	ldi	r23,2
fatopen_lab5:
	; fatdiriter Such-Modus (in: r23; out: r17,y,r2; changed: r0-r4,r9-r22,r24-r25,x,y,z)
	rcall	fatdiriter
	cpi	r23,1
	brne	fatopen_lab4
	; kein "open" eines Verzeichnisses
	mov	r16,r2
	andi	r16,16
	or	r17,r16
fatopen_lab4:
	; fatrestoreactdir (in: -; out: -; changed: r16,r24-r25,x,z)
	rjmp	fatrestoreactdir


fatreadnextsector6502:
	; <proc>
	;   <name>fatreadnextsector6502</name>
	;   <desce>read the next sector of the file (low- or high-mem)</desce>
	;   <input>
	;     <rparam>
	;       <name>x</name>
	;       <desce>low byte of the pointer to the &lt;a href="#fatloadsavestructure"&gt;fatloadsave structure&lt;/a&gt;</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <desce>high byte of the pointer to the &lt;a href="#fatloadsavestructure"&gt;fatloadsave structure&lt;/a&gt;</desce>
	;     </rparam>
	;     <rparam>
	;       <name>a</name>
	;       <desce>"safe" mode (= 0) or "vsync" mode (!= 0)</desce>
	;     </rparam>
	;   </input>
	;   <output>
	;     <mparam>
	;       <name>RERRCODE6502</name>
	;       <desce>error resp. info code (0 = OK, 8 = FATINFOLASTCLUST)</desce>
	;     </mparam>
	;   </output>
	; </proc>

	ldi	r17,FATERRFSNOTINIT
	lds	r16,FATFSOK
	tst	r16
	breq	fatreadnextsector6502_lab1
	mov	r16,regmemoff6502
	push	yl
	push	yh
	push	r3
	push	r4
	push	r7
	push	r8
	push	r2
	mov	zl,regx
	mov	zh,regy
	add	zh,regmemoff6502
	ldd	r7,z+FATLOADSAVE_MEM
	ldd	r8,z+FATLOADSAVE_MEM+1
	add	r8,r16
	ldd	yl,z+FATLOADSAVE_FILE
	ldd	yh,z+FATLOADSAVE_FILE+1
	add	yh,r16
	; Keine Video-Generator-Interrupts erlauben zur fehlerfreien Datenuebertragung
	tst	rega
	brne	fatreadnextsector6502_lab3
	videogen_disableint
fatreadnextsector6502_lab3:
	; fatreadnextsector (in: r7,r8,y; out: r17; changed: r0-r4,r16-r23,z)
	rcall	fatreadnextsector
	; restore register a
	pop	r2
	; Video-Generator-Interrupts wieder erlauben
	tst	rega
	brne	fatreadnextsector6502_lab5
	call	videogen_enableint
fatreadnextsector6502_lab5:
	pop	r8
	pop	r7
	pop	r4
	pop	r3
	pop	yh
	pop	yl
fatreadnextsector6502_lab1:
	sts	RERRCODE6502,r17
	ret


fatreadnextsector:
	; Lesen des naechsten Sektors einer Datei
	; Signatur fatreadnextsector (in: r7,r8,y; out: r17; changed: r0-r4,r16-r23,z)
	; Eingabe: r7,r8 -> Pointer auf den Speicher
	; Eingabe: y -> Pointer auf die Datei-Struktur
	; Ausgabe: r17 -> Error- resp. Info-Code resp. 0 (= ok)
	; Veraenderte Register: r0-r4, r16-r23, z

	; fatgetnextsect (in: y; out: r17; changed: r0-r4,r16-r22,z)
	rcall	fatgetnextsect
	cpi	r17,FATINFOLASTCLUST
	breq	fatreadnextsector_lab2
	tst	r17
	brne	fatreadnextsector_lab1
	ldd	r20,y+FILEACTSECT
	ldd	r21,y+FILEACTSECT+1
	ldd	r22,y+FILEACTSECT+2
	mov	zl,r7
	mov	zh,r8
	; High-Memory?
	in	r23,PORTD
	lds	r16,LOWHIMEM
	sbrc	r16,LOWHIMEMFS
	himemon
	; sdreadsector (in: r20-r22,z; out: r16; changed: r16-r22,z)
	call	sdreadsector
	out	PORTD,r23
	ldi	r17,FATERRREAD
	tst	r16
	brne	fatreadnextsector_lab1
	clr	r17
fatreadnextsector_lab2:
	ret
fatreadnextsector_lab1:
	sts	FATFSOK,regzero
	ret


fatwritenextsector6502:
	; <proc>
	;   <name>fatwritenextsector6502</name>
	;   <descg>Schreiben des naechsten Sektors der Datei (Low- oder High-Mem)</descg>
	;   <desce>write the next sector of the file (low- or high-mem)</desce>
	;   <input>
	;     <rparam>
	;       <name>x</name>
	;       <descg>Low-Byte des Pointers auf die &lt;a href="#fatloadsavestructure"&gt;fatloadsave-Struktur&lt;/a&gt;</descg>
	;       <desce>low byte of the pointer to the &lt;a href="#fatloadsavestructure"&gt;fatloadsave structure&lt;/a&gt;</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <descg>High-Byte des Pointers auf die &lt;a href="#fatloadsavestructure"&gt;fatloadsave-Struktur&lt;/a&gt;</descg>
	;       <desce>high byte of the pointer to the &lt;a href="#fatloadsavestructure"&gt;fatloadsave structure&lt;/a&gt;</desce>
	;     </rparam>
	;   </input>
	;   <output>
	;     <mparam>
	;       <name>RERRCODE6502</name>
	;       <descg>Fehler- resp. Info-Code (0 = OK)</descg>
	;       <desce>error resp. info code (0 = OK)</desce>
	;     </mparam>
	;   </output>
	; </proc>

	rcall	fatchksavereg
	breq	fatwritenextsector6502_lab1
	mov	r16,regmemoff6502
	mov	zl,regx
	mov	zh,regy
	add	zh,regmemoff6502
	ldd	r7,z+FATLOADSAVE_MEM
	ldd	r8,z+FATLOADSAVE_MEM+1
	add	r8,r16
	ldd	yl,z+FATLOADSAVE_FILE
	ldd	yh,z+FATLOADSAVE_FILE+1
	add	yh,r16
	; Keine Video-Generator-Interrupts erlauben zur fehlerfreien Datenuebertragung
	videogen_disableint
	; fatwritenextsector (in: r7,r8,y; out: r17; changed: r0-r4,r16-r23,z)
	rcall	fatwritenextsector
	; Video-Generator-Interrupts wieder erlauben
	; videogen_enableint (in: -; out: -; changed: r16,r18)
	call	videogen_enableint
fatwritenextsector6502_lab1:
	rjmp	fatrestorereg


fatwritenextsector:
	; Schreiben des naechsten Sektors einer Datei
	; Signatur fatwritenextsector (in: r7,r8,y; out: r17; changed: r0-r4,r16-r23,z)
	; Eingabe: r7,r8 -> Pointer auf den Speicher
	; Eingabe: y -> Pointer auf die Datei-Struktur
	; Ausgabe: r17 -> Error- resp. Info-Code resp. 0 (= ok)
	; Veraenderte Register: r0-r4, r16-r23, z

	; fatgetnextsect (in: y; out: r17; changed: r0-r4,r16-r22,z)
	rcall	fatgetnextsect
	cpi	r17,FATINFOLASTCLUST
	breq	fatwritenextsector_lab2
	tst	r17
	brne	fatwritenextsector_lab1
	ldd	r20,y+FILEACTSECT
	ldd	r21,y+FILEACTSECT+1
	ldd	r22,y+FILEACTSECT+2
	mov	zl,r7
	mov	zh,r8
	; High-Memory?
	in	r23,PORTD
	lds	r16,LOWHIMEM
	sbrc	r16,LOWHIMEMFS
	himemon
	; sdwritesector (in: r20-r22,z; out: r16; changed: r16-r22,z)
	call	sdwritesector
	out	PORTD,r23
	ldi	r17,FATERRWRITE
	tst	r16
	brne	fatwritenextsector_lab1
	clr	r17
fatwritenextsector_lab2:
	ret
fatwritenextsector_lab1:
	sts	FATFSOK,regzero
	ret


fatgetstartmem:
	; Ermittle die Startadresse
	; Signatur fatgetstartmem (in: -; out: r7,r8,r17; changed: r17,z)
	; Ausgabe: r7, r8 -> Startadresse
	; Ausgabe: r17 -> Startadresse im Programm hinterlegt = 0, sonst = 1
	; Veraenderte Register: r17, z

	ldi	zl,low(FATBUFFER)
	ldi	zh,high(FATBUFFER)
	ldd	r17,z+7
	cpi	r17,'L'
	brne	fatgetstartmem_lab1
	ldd	r17,z+8
	cpi	r17,'O'
	brne	fatgetstartmem_lab1
	ldd	r17,z+9
	cpi	r17,'A'
	brne	fatgetstartmem_lab1
	ldd	r17,z+10
	cpi	r17,'D'
	brne	fatgetstartmem_lab1
	ldd	r7,z+11
	ldd	r8,z+12
	clr	r17
	ret
fatgetstartmem_lab1:
	ldi	r17,1
	ret


fatloadsaveutil:
	mov	zl,regx
	mov	zh,regy
	add	zh,regmemoff6502
	ldd	xl,z+FATLOADSAVE_NAME
	ldd	xh,z+FATLOADSAVE_NAME+1
	add	xh,regmemoff6502
	ldd	r18,z+FATLOADSAVE_MEM
	ldd	r19,z+FATLOADSAVE_MEM+1
	add	r19,regmemoff6502
	ldd	yl,z+FATLOADSAVE_FILE
	ldd	yh,z+FATLOADSAVE_FILE+1
	add	yh,regmemoff6502
	mov	zl,r18
	mov	zh,r19
fatload_lab6:
	ret


fatload6502:
	; <proc>
	;   <name>fatload6502</name>
	;   <descg>Lade eine Datei in den Hauptspeicher (Low- oder High-Mem)</descg>
	;   <desce>load a file to memory (low- or high-mem)</desce>
	;   <input>
	;     <rparam>
	;       <name>x</name>
	;       <descg>Low-Byte des Pointers auf die &lt;a href="#fatloadsavestructure"&gt;fatloadsave-Struktur&lt;/a&gt;</descg>
	;       <desce>low byte of the pointer to the &lt;a href="#fatloadsavestructure"&gt;fatloadsave structure&lt;/a&gt;</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <descg>High-Byte des Pointers auf die &lt;a href="#fatloadsavestructure"&gt;fatloadsave-Struktur&lt;/a&gt;</descg>
	;       <desce>high byte of the pointer to the &lt;a href="#fatloadsavestructure"&gt;fatloadsave structure&lt;/a&gt;</desce>
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

	rcall	fatchksavereg
	breq	fatload6502_lab1
	rcall	fatloadsaveutil
	; fatload (in: x,y,z; out: r17; changed: r0-r4,r6-r25,x,z)
	push	r6
	rcall	fatload
	pop	r6
fatload6502_lab1:
	rjmp	fatrestorereg


fatload:
	; Laden einer Datei in den Hauptspeicher
	; Signatur fatload (in: x,y,z; out: r17; changed: r0-r4,r6-r25,x,z)
	; Eingabe: x -> Datei-Name
	; Eingabe: y -> Pointer auf die Datei-Struktur
	; Eingabe: z -> Pointer auf den Speicher oder NULL
	; Ausgabe: r17 -> Error-Code resp. 0 (= ok)
	; Veraenderte Register: r0-r4, r6-r25, x, z

	; Pseudocode:
	;   fatload {
	;     fopen();
	;     divcnt = 0;
	;     if (startmem != NULL) {
	;       actmem = startmem;
	;     }
	;     else if (filedivsize > 0) {
	;       sect = getnextsect();
	;       readsector(sect, FATBUFFER);
	;       actmem = getStartmem(FATBUFFER);
	;       copymem(actmem, FATBUFFER, 512);
	;       actmem += 512;
	;       divcnt++;
	;     }
	;     while (divcnt < filedivsize) {
	;       sect = getnextsect();
	;       readsector(sect, actmem);
	;       actmem += 512;
	;       divcnt++;
	;     }
	;     if (filemodsize > 0) {
	;       sect = getnextsect();
	;       readsector(sect, FATBUFFER);
	;       if ((filedivsize == 0) && (startmem == NULL)) {
	;         actmem = getStartmem(FATBUFFER);
	;       }
	;       copymem(actmem, FATBUFFER, filemodsize);
	;     }
	;   }

	ldi	r17,FATERRFSNOTINIT
	lds	r16,FATFSOK
	tst	r16
	breq	fatload_lab6

	; Keine Video-Generator-Interrupts erlauben zur fehlerfreien Datenuebertragung
	videogen_disableint

	; actmem = startmem;
	mov	r7,zl
	mov	r8,zh
	sts	FATLOADSTARTADDR,r7
	sts	FATLOADSTARTADDR+1,r8
	or	zl,zh
	mov	r6,zl

	; Datei oeffnen
	; fatopen (in: x,y; out: r17; changed: r0-r4,r9-r25,x,z)
	rcall	fatopen
	tst	r17
	brne	fatload_lab7

	; divcnt = 0
	mov	r12,regzero
	mov	r13,regzero

	; filedivsize
	ldd	r10,y+FILEDIVSIZE
	ldd	r11,y+FILEDIVSIZE+1

	; startmem == NULL?
	tst	r6
	brne	fatload_lab2
	; filedivsize > 0?
	mov	r16,r10
	or	r16,r11
	breq	fatload_lab2
	inc	r6

	; Ersten Sektor lesen
	ldi	zl,low(FATBUFFER)
	ldi	zh,high(FATBUFFER)
	mov	r7,zl
	mov	r8,zh
	; fatreadnextsector (in: r7,r8,y; out: r17; changed: r0-r4,r16-r23,z)
	rcall	fatreadnextsector
	tst	r17
	brne	fatload_lab7

	; actmem = getStartmem(FATBUFFER);
	; copymem(actmem, FATBUFFER, 512);
	clr	r24
	ldi	r25,2
	rcall	fatloadcopy2mem

	; actmem += 512;
	inc	r8
	inc	r8

	; divcnt = 1;
	inc	r12

fatload_lab2:
	cp	r12,r10
	brne	fatload_lab5
	cp	r13,r11
	breq	fatload_lab4
fatload_lab5:

	; Naechsten Sektor lesen
	; fatreadnextsector (in: r7,r8,y; out: r17; changed: r0-r4,r16-r23,z)
	rcall	fatreadnextsector
	tst	r17
fatload_lab7:
	brne	fatload_lab3

	; actmem += 512;
	inc	r8
	inc	r8

	; divcnt++
	inc	r12
	brne	fatload_lab1
	inc	r13
fatload_lab1:
	rjmp	fatload_lab2

fatload_lab4:
	; filemodsize > 0?
	ldd	r24,y+FILEMODSIZE
	ldd	r25,y+FILEMODSIZE+1
	mov	r16,r24
	or	r16,r25
	breq	fatload_lab9

	; Letzten Sektor lesen
	mov	xl,r7
	mov	xh,r8
	ldi	zl,low(FATBUFFER)
	ldi	zh,high(FATBUFFER)
	mov	r7,zl
	mov	r8,zh
	; fatreadnextsector (in: r7,r8,y; out: r17; changed: r0-r4,r16-r23,z)
	rcall	fatreadnextsector
	tst	r17
	brne	fatload_lab3

	; filedivsize == 0 && startmem == NULL?
	tst	r6
	brne	fatload_lab8
	rcall	fatloadcopy2mem
	rjmp	fatload_lab9
fatload_lab8:
	rcall	fatloadcopy2mem_lab2

fatload_lab9:
	ldi	r17,0
fatload_lab3:
	; Video-Generator-Interrupts wieder erlauben
	; videogen_enableint (in: -; out: -; changed: r16,r18)
	jmp	videogen_enableint

fatloadcopy2mem:
	; fatgetstartmem (in: -; out: r7,r8,r17; changed: r17,z)
	rcall	fatgetstartmem
	tst	r17
	breq	fatloadcopy2mem_lab1
	ldi	zl,low(START6502CODE)
	ldi	zh,high(START6502CODE)
	mov	r7,zl
	mov	r8,zh
fatloadcopy2mem_lab1:
	sts	FATLOADSTARTADDR,r7
	sts	FATLOADSTARTADDR+1,r8
	mov	xl,r7
	mov	xh,r8
fatloadcopy2mem_lab2:
	ldi	zl,low(FATBUFFER)
	ldi	zh,high(FATBUFFER)
	; High-Memory?
	in	r23,PORTD
	lds	r16,LOWHIMEM
	sbrc	r16,LOWHIMEMFS
	himemon
	; memcopy (in: r24-r25,x,z; out: -; changed: r16,r24-r25,x,z)
	call	memcopy
	out	PORTD,r23
	ret


fatsave6502:
	; <proc>
	;   <name>fatsave6502</name>
	;   <descg>Speichere einen Speicherblocks in eine Datei (Low- oder High-Mem)</descg>
	;   <desce>save memory block to file (low- or high-mem)</desce>
	;   <input>
	;     <rparam>
	;       <name>x</name>
	;       <descg>Low-Byte des Pointers auf die &lt;a href="#fatloadsavestructure"&gt;fatloadsave-Struktur&lt;/a&gt;</descg>
	;       <desce>low byte of the pointer to the &lt;a href="#fatloadsavestructure"&gt;fatloadsave structure&lt;/a&gt;</desce>
	;     </rparam>
	;     <rparam>
	;       <name>y</name>
	;       <descg>High-Byte des Pointers auf die &lt;a href="#fatloadsavestructure"&gt;fatloadsave-Struktur&lt;/a&gt;</descg>
	;       <desce>high byte of the pointer to the &lt;a href="#fatloadsavestructure"&gt;fatloadsave structure&lt;/a&gt;</desce>
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

	rcall	fatchksavereg
	breq	fatsave6502_lab1
	rcall	fatloadsaveutil
	; fatsave (in: x,y,z; out: r17; changed: r0-r4,r7-r25,x,z)
	rcall	fatsave
fatsave6502_lab1:
	rjmp	fatrestorereg


fatsave:
	; Speichern des Hauptspeichers in eine Datei
	; Signatur fatsave (in: x,y,z; out: r17; changed: r0-r4,r7-r25,x,z)
	; Eingabe: x -> Datei-Name
	; Eingabe: y -> Pointer auf die Datei-Struktur
	; Eingabe: z -> Pointer auf den Speicher
	; Ausgabe: r17 -> Error-Code resp. 0 (= ok)
	; Veraenderte Register: r0-r4, r7-r25, x, z

	; Pseudocode:
	;   fatsave {
	;     divcnt = 0;
	;     actmem = startmem;
	;     if (filemodsize > 0) filedivsize++;
	;     while (divcnt < filedivsize) {
	;       sect = getnextsect();
	;       writesector(sect, actmem);
	;       actmem += 512
	;       divcnt++;
	;     }
	;   }

	ldi	r17,FATERRFSNOTINIT
	lds	r16,FATFSOK
	tst	r16
	breq	fatsave_lab7

	; Keine Video-Generator-Interrupts erlauben zur fehlerfreien Datenuebertragung
	videogen_disableint

	; actmem = startmem;
	mov	r7,zl
	mov	r8,zh

	; Datei oeffnen
	; fatopen (in: x,y; out: r17; changed: r0-r4,r9-r25,x,z)
	rcall	fatopen
	tst	r17
	brne	fatsave_lab3

	; filedivsize (aufgerundet)
	ldd	r10,y+FILEDIVSIZE
	ldd	r11,y+FILEDIVSIZE+1
	ldd	r12,y+FILEMODSIZE
	ldd	r13,y+FILEMODSIZE+1
	or	r12,r13
	breq	fatsave_lab6
	inc	r10
	brne	fatsave_lab6
	inc	r11

fatsave_lab6:
	; divcnt = 0
	mov	r12,regzero
	mov	r13,regzero

fatsave_lab2:
	cp	r12,r10
	brne	fatsave_lab5
	cp	r13,r11
	breq	fatsave_lab4
fatsave_lab5:

	; Naechsten Sektor schreiben
	; fatwritenextsector (in: r7,r8,y; out: r17; changed: r0-r4,r16-r23,z)
	rcall	fatwritenextsector
	tst	r17
	brne	fatsave_lab3

	; actmem += 512;
	inc	r8
	inc	r8

	; divcnt++
	inc	r12
	brne	fatsave_lab1
	inc	r13
fatsave_lab1:
	rjmp	fatsave_lab2

fatsave_lab4:
	ldi	r17,0
fatsave_lab3:
	; Video-Generator-Interrupts wieder erlauben
	; videogen_enableint (in: -; out: -; changed: r16,r18)
	jmp	videogen_enableint
fatsave_lab7:
	ret
