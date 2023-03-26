; shell.asm: shell for the r162 system
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


.EQU	NUMOFSHELLCMDS = 11
.EQU	SHELLSDCARDERROR = 100
.EQU	OPCODEJMP = 76

cmdnotfounderror:
	.db	"cmd not found", 10, 0, 0

cmdillegalnumargserror:
	.db	"ill. arg", 10, 0

cmdfaterror:
	.db	"err. ", 0

cmdnamecd:
	.db	"cd", 0, 0
cmdnamefsinit:
	.db	"fsinit", 0, 0
cmdnameload:
	.db	"load", 0, 0
cmdnamels:
	.db	"ls", 0, 0
cmdnamepeek:
	.db	"peek", 0, 0
cmdnamepoke:
	.db	"poke", 0, 0
cmdnamereset:
	.db	"reset", 0
cmdnamesave:
	.db	"save", 0, 0
cmdnamesys:
	.db	"sys", 0
cmdnamespilo:
	.db	"spilo", 0
cmdnamespihi:
	.db	"spihi", 0

cmdnamearr:
	.dw	cmdnamecd,cmdnamefsinit,cmdnameload,cmdnamels,cmdnamepeek,cmdnamepoke,cmdnamereset,cmdnamesave,cmdnamesys,cmdnamespilo,cmdnamespihi

cmdactionarr:
	rjmp	cmdcd
	rjmp	cmdfsinit
	rjmp	cmdload
	rjmp	cmdls
	rjmp	cmdpeek
	rjmp	cmdpoke
	rjmp	cmdreset
	rjmp	cmdsave
	rjmp	cmdsys
	rjmp	cmdspilo
	rjmp	cmdspihi


shell:
	; shellwait4input (in: -; out: r17; changed: r16-r20,x,y,z)
	rcall	shellwait4input
	; Bekannter Befehl?
	ldi	zl,low(cmdnamearr<<1)
	ldi	zh,high(cmdnamearr<<1)
	clr	r20
shell_lab3:
	ldi	xl,low(SHELLBUFFER)
	ldi	xh,high(SHELLBUFFER)
	lpm	r16,z+
	lpm	r18,z+
	mov	r0,zl
	mov	r1,zh
	lsl	r16
	rol	r18
	mov	zl,r16
	mov	zh,r18
	mov	r2,r17
	ldi	r18,255
	clr	r19
	; Achtung: Bei Gleichheit der beiden Strings zeigt x auf die Position hinter
	;          dem 1. String bei der aktuellen Implementierung von strncmp
	;          (undocumented feature)!
	; strncmp (in: r18,r19,x,z; out: r16; changed: r16-r18,x,z)
	call	strncmp
	mov	r17,r2
	tst	r16
	breq	shell_lab4
	mov	zl,r0
	mov	zh,r1
	inc	r20
	cpi	r20,NUMOFSHELLCMDS
	brne	shell_lab3
	lds	r16,FATFSOK
	tst	r16
	brne	shell_lab1
shell_lab2:
	; Nein -> Ausgabe "command not found"
	ldi	zl,low(cmdnotfounderror<<1)
	ldi	zh,high(cmdnotfounderror<<1)
	; printstringflash (in: z; out: -; changed: r16-r20,x,y,z)
	call	printstringflash
	rjmp	shell
shell_lab4:
	; x -> Pointer auf das 1. Argument
	; r17 -> Anzahl Argumente + 1
	; Bekannter Befehl -> ausfuehren
	ldi	zl,low(cmdactionarr)
	ldi	zh,high(cmdactionarr)
	add	zl,r20
	adc	zh,regzero
	ijmp
shell_lab1:
	; Kommando-String in Grossbuchstaben
	ldi	xl,low(SHELLBUFFER)
	ldi	xh,high(SHELLBUFFER)
shell_lab7:
	ld	r16,x+
	tst	r16
	breq	shell_lab8
	cpi	r16,'a'
	brlo	shell_lab7
	cpi	r16,'z'+1
	brsh	shell_lab7
	subi	r16,'a'-'A'
	st	-x,r16
	ld	r16,x+
	rjmp	shell_lab7
shell_lab8:
	rcall	shellloadprg
	tst	r17
	breq	shell_lab6
	; Kommando-String in Kleinbuchstaben
	ldi	xl,low(SHELLBUFFER)
	ldi	xh,high(SHELLBUFFER)
shell_lab17:
	ld	r16,x+
	tst	r16
	breq	shell_lab18
	cpi	r16,'A'
	brlo	shell_lab17
	cpi	r16,'Z'+1
	brsh	shell_lab17
	subi	r16,'A'-'a'
	st	-x,r16
	ld	r16,x+
	rjmp	shell_lab17
shell_lab18:
	rcall	shellloadprg
	tst	r17
	brne	shell_lab2
shell_lab6:
	; Autostart-Programm?
	lds	xl,FATLOADSTARTADDR
	lds	xh,FATLOADSTARTADDR+1
	; shellcheckautostart (in: x; out: r16,y; changed: r16,x,y)
	rcall	shellcheckautostart
	tst	r16
	breq	shell_lab2
	; Starte Programm
	jmp	start6502


shellwait4input:
	; wait for user input
	; Signatur shellwait4input (in: -; out: r17; changed: r16-r20,x,y,z)
	; Ausgabe: SHELLBUFFER -> command including arguments
	; Ausgabe: SHELLNUMARGS -> number or arguments
	; Ausgabe: r17 -> number or arguments
	; Veraenderte Register: r16-r20, x, y, z

	; Warten auf Tastatur-Eingabe
	; getchwait (in: -; out: r16; changed: r16,r17,z)
	call	getchwait
	; printchar (in: r18; out: -; changed: r16,r17,r19,r20,x,y,z)
	mov	r18,r16
	call	printchar
	; Return gedrueckt?
	cpi	r18,10
	brne	shellwait4input
	; Return gedrueckt -> aktuelle Zeile auswerten (im Shell-Puffer ablegen)
	lds	xl,ACTCURADDR
	lds	xh,ACTCURADDR+1
	lds	r16,NUMCHARCOLS
	sub	xl,r16
	sbci	xh,0
	ldi	zl,low(SHELLBUFFER)
	ldi	zh,high(SHELLBUFFER)
	clr	r17
shellwait4input_lab10:
	ld	r18,x+
	cpi	r18,' '
	brne	shellwait4input_lab12
shellwait4input_lab14:
	dec	r16
	brne	shellwait4input_lab10
	rjmp	shellwait4input_lab13
shellwait4input_lab12:
	inc	r17
shellwait4input_lab15:
	st	z+,r18
	dec	r16
	breq	shellwait4input_lab13
	ld	r18,x+
	cpi	r18,' '
	breq	shellwait4input_lab16
	rjmp	shellwait4input_lab15
shellwait4input_lab16:
	st	z+,regzero
	rjmp	shellwait4input_lab14
shellwait4input_lab13:
	sts	SHELLNUMARGS,r17
	; keine Eingabe?
	tst	r17
	breq	shellwait4input
	ret


shellloadprg:
	; Versuche, das Programm im BIN-Verzeichnis zu finden und laden
	ldi	xl,low(SYSBINDIRNAME)
	ldi	xh,high(SYSBINDIRNAME)
	rcall	shellloadexe
	tst	r17
	breq	shellloadprg_lab1
	; Versuche, das Programm im aktuellen Verzeichnis zu finden und laden
	ldi	xl,low(SHELLBUFFER)
	ldi	xh,high(SHELLBUFFER)
	rcall	shellloadexe
shellloadprg_lab1:
	ret

shellloadexe:
	; Ladet das angegebene Programm
	; Signatur shellloadexe (in: x; out: r17; changed: r16,x,y)
	; Eingabe: x -> Pointer auf den Namen des Programms (inkl. Pfad)
	; Ausgabe: r17 -> Error-Code resp. 0 (= ok)
	; Veraenderte Register: r0-r4, r6-r25, x, y, z)
	clr	zl
	clr	zh
	ldi	yl,low(SYSFILESTRUCT)
	ldi	yh,high(SYSFILESTRUCT)
	sts	LOWHIMEM,regzero
	; fatload (in: x,y,z; out: r17; changed: r0-r4,r6-r25,x,z)
	jmp	fatload


shellcheckautostart:
	; Prueft, ob das geladene Programm automatisch gestartet werden soll
	; Signatur shellcheckautostart (in: x; out: r16,y; changed: r16,x,y)
	; Eingabe: x -> Pointer auf den Speicher des geladenen Programms
	; Ausgabe: y -> Adresse des Programmstarts, wenn ein Autostart-Programm vorliegt
	; Ausgabe: r16 -> Autostart-Programm (!= 0) resp. kein Autostart-Programm (== 0)
	; Veraenderte Register: r16, x, y

	ld	r16,x+
	cpi	r16,OPCODEJMP
	brne	shellcheckautostart_lab1
	ld	yl,x+
	ld	yh,x+
	subi	yh,(256-MEMOFF6502)
	ld	r16,x+
	cpi	r16,'A'
	brne	shellcheckautostart_lab1
	ld	r16,x+
	cpi	r16,'U'
	brne	shellcheckautostart_lab1
	ld	r16,x+
	cpi	r16,'T'
	brne	shellcheckautostart_lab1
	ld	r16,x+
	cpi	r16,'O'
	brne	shellcheckautostart_lab1
	ret
shellcheckautostart_lab1:
	clr	r16
	ret


cmdfsinit:
	; Initialisierung des FAT-Dateisystems
	; fatinit (in: -; out: r17; changed: r0-r4,r13-r22,x,z)
	call	fatinit
	tst	r17
	brne	cmdprinterror
	rjmp	shell


cmdprinterror:
	ldi	zl,low(cmdfaterror<<1)
	ldi	zh,high(cmdfaterror<<1)
	push	r17
	; printstringflash (in: z; out: -; changed: r16-r20,x,y,z)
	call	printstringflash
	pop	r17
	mov	r18,r17
	; btoa (in: r18; out: -; changed: r16-r21,z)
	call	btoa
	ldi	r18,low(ITOASTRING)
	ldi	r19,high(ITOASTRING)
	; printstring (in: r18,r19; out: -; changed: r16-r20,x,y,z)
	call	printstring
	; println (in: -; out: -; changed: r16,r17,r19,r20,x,y,z)
	call	println
	rjmp	shell


cmdls:
	; Inhaltsverzeichnis auslisten
	cpi	r17,1
	breq	cmdls_lab1
	; fatsaveactdir (in: -; out: -; changed: r16,r24-r25,z)
	call	fatsaveactdir
	; fatcd (in: x; out: r17; changed: r0-r4,r6,r9-r25,x,y,z)
	call	fatcd
	tst	r17
	brne	cmdprinterror
	; fatls (in: -; out: r17; changed: r0-r4,r7-r25,x,y,z)
	call	fatls
	tst	r17
	brne	cmdprinterror
	; fatrestoreactdir (in: -; out: -; changed: r16,r24-r25,x,z)
	call	fatrestoreactdir
	rjmp	shell
cmdls_lab1:
	; fatls (in: -; out: r17; changed: r0-r4,r7-r25,x,y,z)
	call	fatls
	tst	r17
	brne	cmdprinterror
	rjmp	shell


cmdcd:
	; Verzeichnis wechseln
	cpi	r17,1
	breq	cmdcd_lab1
	; fatsaveactdir (in: -; out: -; changed: r16,r24-r25,z)
	call	fatsaveactdir
	; x zeigt auf das 1. Argument
	; fatcd (in: x; out: r17; changed: r0-r4,r6,r9-r25,x,y,z)
	call	fatcd
	tst	r17
	brne	cmdcd_lab2
	rjmp	shell
cmdcd_lab1:
	; go to root directory
	sts	FATROOTDIRFLAG,regzero
	rjmp	shell
cmdcd_lab2:
	; fatrestoreactdir (in: -; out: -; changed: r16,r24-r25,x,z)
	call	fatrestoreactdir
	rjmp	cmdprinterror


cmdload:
	clr	zl
	clr	zh
	; x zeigt auf das 1. Argument
	mov	yl,xl
	mov	yh,xh
	; Pruefe Anzahl Argumente
	cpi	r17,2
	brlo	cmdillegalnumargs
	breq	cmdload_lab3
cmdload_lab4:
	ld	r16,x+
	tst	r16
	brne	cmdload_lab4
	; x zeigt auf das 2. Argument
	; atoi (in: x; out: r17,r18,x; changed: r0-r4,r16-r19,x)
	call	atoi
	mov	zl,r17
	mov	zh,r18
cmdload_lab3:
	; Datei laden
	mov	xl,yl
	mov	xh,yh
	; fatload (in: x,y,z; out: r17; changed: r0-r4,r6-r25,x,z)
	ldi	yl,low(SYSFILESTRUCT)
	ldi	yh,high(SYSFILESTRUCT)
	call	fatload
	tst	r17
	brne	cmdload_lab1
	lds	xl,FATLOADSTARTADDR
	lds	xh,FATLOADSTARTADDR+1
	; shellcheckautostart (in: x; out: r16,y; changed: r16,x,y)
	rcall	shellcheckautostart
	tst	r16
	breq	cmdload_lab10
	jmp	start6502
cmdload_lab10:
	rjmp	shell
cmdload_lab1:
	rjmp	cmdprinterror


cmdsave:
	ldi	zl,low(START6502CODE)
	ldi	zh,high(START6502CODE)
	; Pruefe Anzahl Argumente
	cpi	r17,2
	brlo	cmdillegalnumargs
	breq	cmdsave_lab3
	; x zeigt auf das 1. Argument
	mov	yl,xl
	mov	yh,xh
cmdsave_lab2:
	ld	r16,x+
	tst	r16
	brne	cmdsave_lab2
	; x zeigt auf das 2. Argument
	; atoi (in: x; out: r17,r18,x; changed: r0-r4,r16-r19,x)
	call	atoi
	mov	zl,r17
	mov	zh,r18
	mov	xl,yl
	mov	xh,yh
cmdsave_lab3:
	; Datei speichern
	; fatsave (in: x,y,z; out: r17; changed: r0-r4,r7-r25,x,z)
	ldi	yl,low(SYSFILESTRUCT)
	ldi	yh,high(SYSFILESTRUCT)
	call	fatsave
	tst	r17
	brne	cmdsave_lab1
	rjmp	shell
cmdsave_lab1:
	rjmp	cmdprinterror


cmdillegalnumargs:
	ldi	zl,low(cmdillegalnumargserror<<1)
	ldi	zh,high(cmdillegalnumargserror<<1)
	; printstringflash (in: z; out: -; changed: r16-r20,x,y,z)
	call	printstringflash
	rjmp	shell


cmdpeek:
	; Pruefe Anzahl Argumente
	cpi	r17,2
	brne	cmdillegalnumargs
	rcall	cmdpeek1
	rjmp	shell
cmdpeek1:
	; Signatur cmdpeek1 (in: x; out: -; changed: r0-r4,r16-r20,x,y,z)
	; x zeigt auf das 1. Argument
	; atoi (in: x; out: r17,r18,x; changed: r0-r4,r16-r19,x)
	call	atoi
	subi	r18,(256-MEMOFF6502)
	mov	zl,r17
	mov	zh,r18
	ld	r18,z
	; btoa (in: r18; out: -; changed: r16-r21,z)
	call	btoa
	ldi	r18,low(ITOASTRING)
	ldi	r19,high(ITOASTRING)
	; printstring (in: r18,r19; out: -; changed: r16-r20,x,y,z)
	call	printstring
	; println (in: -; out: -; changed: r16,r17,r19,r20,x,y,z)
	jmp	println


cmdpoke:
	; Pruefe Anzahl Argumente
	cpi	r17,3
	brne	cmdillegalnumargs
	rcall	cmdpoke1
	rjmp	shell
cmdpoke1:
	; Signatur cmdpoke1 (in: x; out: -; changed: r0-r4,r16-r19,x,z)
	; x zeigt auf das 1. Argument
	; atoi (in: x; out: r17,r18,x; changed: r0-r4,r16-r19,x)
	call	atoi
	subi	r18,(256-MEMOFF6502)
	mov	zl,r17
	mov	zh,r18
	; x zeigt auf das 2. Argument
	; atoi (in: x; out: r17,r18,x; changed: r0-r4,r16-r19,x)
	call	atoi
	st	z,r17
	ret


cmdsys:
	; Pruefe Anzahl Argumente
	cpi	r17,2
	brne	cmdillegalnumargs
	; x zeigt auf das 1. Argument
	; atoi (in: x; out: r17,r18,x; changed: r0-r4,r16-r19,x)
	call	atoi
	subi	r18,(256-MEMOFF6502)
	mov	yl,r17
	mov	yh,r18
	; Emulation 6502-Prozessor starten
	; start6502 (in: y; out: -; changed: r2-r4,r7,r8,r16-r19,r25,x,y,z,++)
	jmp	start6502


cmdreset:
	jmp	reset_lab0


cmdspilo:
	call	spienable6502
	rjmp	shell


cmdspihi:
	call	spidisable6502
	rjmp	shell
