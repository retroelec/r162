; cpu6502.asm, v1.6.1: 6502 emulation for the r162 system
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


; - Der PC des 6502 befindet sich im y-Register.
; - Beim Zugriff auf den Speicher wird die Adresse korrigiert, indem 3*256 zur 6502-Adresse dazuaddiert wird.
; - Beim BCD-Modus werden die Flags N, V, Z nicht "korrekt" emuliert
; - 6502 Stack:
;   - post-decremented
;   - bei einer Adresse wird zuerst das High-Byte gepusht
; - Die folgenden Register duerfen "ausserhalb" der 6502-Emulation nicht veraendert werden: r2-r8, r25, y

.DEF	rega = r2
.DEF	regx = r3
.DEF	regy = r4
.DEF	regsr = r25
.DEF	regsp = r7

.DEF	regtemp = r16
.DEF	regtemp2 = r17

.EQU	sregD = 6
.EQU	sregI = 5
.EQU	sregB = 4
.EQU	sregV = 3
.EQU	sregN = 2
.EQU	sregZ = 1
.EQU	sregC = 0

.EQU	sregN6502 = 7
.EQU	sregV6502 = 6
.EQU	sreg16502 = 5
.EQU	sregB6502 = 4
.EQU	sregD6502 = 3
.EQU	sregI6502 = 2
.EQU	sregZ6502 = 1
.EQU	sregC6502 = 0

.EQU	MEMOFF6502 = 3


.MACRO	modeZeropage
	ld	zl,y+
	ldi	zh,MEMOFF6502
.ENDMACRO

.MACRO	modeZeropageX
	modeZeropage
	add	zl,regx
.ENDMACRO

.MACRO	modeZeropageY
	modeZeropage
	add	zl,regy
.ENDMACRO

.MACRO	modeAbsolute
	ld	zl,y+
	ld	zh,y+
	add	zh,regmemoff6502
.ENDMACRO

.MACRO	modeAbsoluteX
	ld	zl,y+
	ld	zh,y+
	add	zl,regx
	adc	zh,regmemoff6502
.ENDMACRO

.MACRO	modeAbsoluteY
	ld	zl,y+
	ld	zh,y+
	add	zl,regy
	adc	zh,regmemoff6502
.ENDMACRO

.MACRO	modeIndirectX
	ldi	xh,MEMOFF6502
	ld	xl,y+
	add	xl,regx
	ld	zl,x+
	ld	zh,x+
	add	zh,regmemoff6502
.ENDMACRO

.MACRO	modeIndirectY
	ldi	xh,MEMOFF6502
	ld	xl,y+
	ld	zl,x+
	ld	zh,x+
	add	zl,regy
	adc	zh,regmemoff6502
.ENDMACRO

.MACRO setNZ
	in	regtemp,SREG
	andi	regsr,~(1<<sregZ|1<<sregN)
	andi	regtemp,(1<<sregZ|1<<sregN)
	or	regsr,regtemp
	jmp	main6502
.ENDMACRO

.MACRO setNZC
	in	regtemp,SREG
	andi	regsr,~(1<<sregZ|1<<sregN|1<<sregC)
	andi	regtemp,(1<<sregZ|1<<sregN|1<<sregC)
	or	regsr,regtemp
	jmp	main6502
.ENDMACRO

.MACRO setVNZC
	in	regtemp,SREG
	andi	regsr,~(1<<sregV|1<<sregN|1<<sregZ|1<<sregC)
	andi	regtemp,(1<<sregV|1<<sregN|1<<sregZ|1<<sregC)
	or	regsr,regtemp
	jmp	main6502
.ENDMACRO

.MACRO atestandsetNZ
	tst	rega
	setNZ
.ENDMACRO

.MACRO xtestandsetNZ
	tst	regx
	setNZ
.ENDMACRO

.MACRO ytestandsetNZ
	tst	regy
	setNZ
.ENDMACRO

cmd6502nop:
	rjmp	main6502

cmd6502ldaImmediate:
	ld	rega,y+
	atestandsetNZ

cmd6502ldaZeropage:
	modeZeropage
	ld	rega,z
	atestandsetNZ

cmd6502ldaZeropageX:
	modeZeropageX
	ld	rega,z
	atestandsetNZ

cmd6502ldaAbsolute:
	modeAbsolute
	ld	rega,z
	atestandsetNZ

cmd6502ldaAbsoluteX:
	modeAbsoluteX
	ld	rega,z
	atestandsetNZ

cmd6502ldaAbsoluteY:
	modeAbsoluteY
	ld	rega,z
	atestandsetNZ

cmd6502ldaIndirectX:
	modeIndirectX
	ld	rega,z
	atestandsetNZ

cmd6502ldaIndirectY:
	modeIndirectY
	ld	rega,z
	atestandsetNZ

cmd6502ldxImmediate:
	ld	regx,y+
	xtestandsetNZ

cmd6502ldxZeropage:
	modeZeropage
	ld	regx,z
	xtestandsetNZ

cmd6502ldxZeropageY:
	modeZeropageY
	ld	regx,z
	xtestandsetNZ

cmd6502ldxAbsolute:
	modeAbsolute
	ld	regx,z
	xtestandsetNZ

cmd6502ldxAbsoluteY:
	modeAbsoluteY
	ld	regx,z
	xtestandsetNZ

cmd6502ldyImmediate:
	ld	regy,y+
	ytestandsetNZ

cmd6502ldyZeropage:
	modeZeropage
	ld	regy,z
	ytestandsetNZ

cmd6502ldyZeropageX:
	modeZeropageX
	ld	regy,z
	ytestandsetNZ

cmd6502ldyAbsolute:
	modeAbsolute
	ld	regy,z
	ytestandsetNZ

cmd6502ldyAbsoluteX:
	modeAbsoluteX
	ld	regy,z
	ytestandsetNZ

cmd6502staZeropage:
	modeZeropage
	st	z,rega
	rjmp	main6502

cmd6502staZeropageX:
	modeZeropageX
	st	z,rega
	rjmp	main6502

cmd6502staAbsolute:
	modeAbsolute
	st	z,rega
	rjmp	main6502

cmd6502staAbsoluteX:
	modeAbsoluteX
	st	z,rega
	rjmp	main6502

cmd6502staAbsoluteY:
	modeAbsoluteY
	st	z,rega
	rjmp	main6502

cmd6502staIndirectX:
	modeIndirectX
	st	z,rega
	rjmp	main6502

cmd6502staIndirectY:
	modeIndirectY
	st	z,rega
	rjmp	main6502

cmd6502stxZeropage:
	modeZeropage
	st	z,regx
	rjmp	main6502

cmd6502stxZeropageY:
	modeZeropageY
	st	z,regx
	rjmp	main6502

cmd6502stxAbsolute:
	modeAbsolute
	st	z,regx
	rjmp	main6502

cmd6502styZeropage:
	modeZeropage
	st	z,regy
	rjmp	main6502

cmd6502styZeropageX:
	modeZeropageX
	st	z,regy
	rjmp	main6502

cmd6502styAbsolute:
	modeAbsolute
	st	z,regy
	rjmp	main6502

cmd6502tax:
	mov	regX,regA
	xtestandsetNZ

cmd6502txa:
	mov	regA,regX
	atestandsetNZ

cmd6502tay:
	mov	regY,regA
	ytestandsetNZ

cmd6502tya:
	mov	regA,regY
	atestandsetNZ

cmd6502tsx:
	mov	regX,regSP
	xtestandsetNZ

cmd6502txs:
	mov	regSP,regX
	rjmp	main6502

.MACRO setCarry
	clc
	sbrc	regsr,sregC
	sec
.ENDMACRO

.MACRO adcbase
	sbrc	regsr,sregD
	rjmp	adcbasebcd_lab1
	setCarry
	adc	rega,regtemp
	setVNZC
.ENDMACRO

; adc BCD:
; AL = (A & $0F) + (B & $0F) + C
; If AL >= $0A, then AL = ((AL + $06) & $0F) + $10
; A = (A & $F0) + (B & $F0) + AL
; Note that A can be >= $100 at this point
; If (A >= $A0), then A = A + $60
; The accumulator result is the lower 8 bits of A
; The carry result is 1 if A >= $100, and is 0 if A < $100
adcbasebcd_lab1:
	; char al = (a&0x0f)+(b&0x0f)+c; // al in regtemp2
	mov	zl,regtemp
	andi	zl,0x0f
	mov	regtemp2,rega
	andi	regtemp2,0x0f
	setCarry
	adc	regtemp2,zl
	; if (al >= 0x0a) al = ((al+0x06)&0x0f)+0x10;
	cpi	regtemp2,0x0a
	brlo	adcbasebcd_lab2
	subi	regtemp2,(0x100-0x06)
	andi	regtemp2,0x0f
	subi	regtemp2,(0x100-0x10)
adcbasebcd_lab2:
	; a2 = (a&0xf0)+(b&0xf0)+al;
	mov	zl,rega
	andi	zl,0xf0
	clr	zh
	andi	regtemp,0xf0
	add	zl,regtemp
	adc	zh,regzero
	add	zl,regtemp2
	adc	zh,regzero
	; if (a2 >= 0xa0) a2 = a2+0x60;
	andi	regsr,~(1<<sregV|1<<sregN|1<<sregZ|1<<sregC)
	tst	zh
	brne	adcbasebcd_lab3
	cpi	zl,0xa0
	brsh	adcbasebcd_lab3
adcbasebcd_lab4:
	mov	rega,zl
	tst	rega
	in	regtemp,SREG
	andi	regtemp,(1<<sregV|1<<sregN|1<<sregZ)
	or	regsr,regtemp
	jmp	main6502
adcbasebcd_lab3:
	ldi	regtemp,0x60
	add	zl,regtemp
	adc	zh,regzero
	; set carry
	ori	regsr,(1<<sregC)
	rjmp	adcbasebcd_lab4

cmd6502adcImmediate:
	ld	regtemp,y+
	adcbase

cmd6502adcZeropage:
	modeZeropage
	ld	regtemp,z
	adcbase

cmd6502adcZeropageX:
	modeZeropageX
	ld	regtemp,z
	adcbase

cmd6502adcAbsolute:
	modeAbsolute
	ld	regtemp,z
	adcbase

cmd6502adcAbsoluteX:
	modeAbsoluteX
	ld	regtemp,z
	adcbase

cmd6502adcAbsoluteY:
	modeAbsoluteY
	ld	regtemp,z
	adcbase

cmd6502adcIndirectX:
	modeIndirectX
	ld	regtemp,z
	adcbase

cmd6502adcIndirectY:
	modeIndirectY
	ld	regtemp,z
	adcbase

.MACRO setCarryInv
	sec
	sbrc	regsr,sregC
	clc
.ENDMACRO

.MACRO sbcbase
	sbrc	regsr,sregD
	rjmp	sbcbasebcd_lab1
	com	regtemp
	setCarry
	adc	rega,regtemp
	setVNZC
.ENDMACRO

; sbc BCD:
; AL = (A & $0F) - (B & $0F) + C-1
; A = A - B + C-1
; If A < 0, then A = A - $60
; If AL < 0, then A = A - $06
; The accumulator result is the lower 8 bits of A
sbcbasebcd_lab1:
	; char al = (a&0x0f)-(b&0x0f)+c-1; // al in regtemp2
	mov	zl,regtemp
	andi	zl,0x0f
	mov	regtemp2,rega
	andi	regtemp2,0x0f
	setCarryInv
	sbc	regtemp2,zl
	; int a2 = a-b+c-1;
	mov	zl,rega
	clr	zh
	setCarryInv
	sbc	zl,regtemp
	sbc	zh,regzero
	; if (a2 < 0) a2 -= 0x60;
	andi	regsr,~(1<<sregV|1<<sregN|1<<sregZ|1<<sregC)
	; set carry
	ori	regsr,(1<<sregC)
	tst	zh
	breq	sbcbasebcd_lab2
	subi	zl,0x60
	sbc	zh,regzero
	; clear carry
	andi	regsr,~(1<<sregC)
sbcbasebcd_lab2:
	; if (al < 0) a2 -= 0x06;
	tst	regtemp2
	brpl	sbcbasebcd_lab3
	sbiw	zl,0x06
sbcbasebcd_lab3:
	mov	rega,zl
	tst	rega
	in	regtemp,SREG
	andi	regtemp,(1<<sregV|1<<sregN|1<<sregZ)
	or	regsr,regtemp
	jmp	main6502

cmd6502sbcImmediate:
	ld	regtemp,y+
	sbcbase

cmd6502sbcZeropage:
	modeZeropage
	ld	regtemp,z
	sbcbase

cmd6502sbcZeropageX:
	modeZeropageX
	ld	regtemp,z
	sbcbase

cmd6502sbcAbsolute:
	modeAbsolute
	ld	regtemp,z
	sbcbase

cmd6502sbcAbsoluteX:
	modeAbsoluteX
	ld	regtemp,z
	sbcbase

cmd6502sbcAbsoluteY:
	modeAbsoluteY
	ld	regtemp,z
	sbcbase

cmd6502sbcIndirectX:
	modeIndirectX
	ld	regtemp,z
	sbcbase

cmd6502sbcIndirectY:
	modeIndirectY
	ld	regtemp,z
	sbcbase

cmd6502andImmediate:
	ld	regtemp,y+
	and	rega,regtemp
	setNZ

cmd6502andZeropage:
	modeZeropage
	ld	regtemp,z
	and	rega,regtemp
	setNZ

cmd6502andZeropageX:
	modeZeropageX
	ld	regtemp,z
	and	rega,regtemp
	setNZ

cmd6502andAbsolute:
	modeAbsolute
	ld	regtemp,z
	and	rega,regtemp
	setNZ

cmd6502andAbsoluteX:
	modeAbsoluteX
	ld	regtemp,z
	and	rega,regtemp
	setNZ

cmd6502andAbsoluteY:
	modeAbsoluteY
	ld	regtemp,z
	and	rega,regtemp
	setNZ

cmd6502andIndirectX:
	modeIndirectX
	ld	regtemp,z
	and	rega,regtemp
	setNZ

cmd6502andIndirectY:
	modeIndirectY
	ld	regtemp,z
	and	rega,regtemp
	setNZ

cmd6502oraImmediate:
	ld	regtemp,y+
	or	rega,regtemp
	setNZ

cmd6502oraZeropage:
	modeZeropage
	ld	regtemp,z
	or	rega,regtemp
	setNZ

cmd6502oraZeropageX:
	modeZeropageX
	ld	regtemp,z
	or	rega,regtemp
	setNZ

cmd6502oraAbsolute:
	modeAbsolute
	ld	regtemp,z
	or	rega,regtemp
	setNZ

cmd6502oraAbsoluteX:
	modeAbsoluteX
	ld	regtemp,z
	or	rega,regtemp
	setNZ

cmd6502oraAbsoluteY:
	modeAbsoluteY
	ld	regtemp,z
	or	rega,regtemp
	setNZ

cmd6502oraIndirectX:
	modeIndirectX
	ld	regtemp,z
	or	rega,regtemp
	setNZ

cmd6502oraIndirectY:
	modeIndirectY
	ld	regtemp,z
	or	rega,regtemp
	setNZ

cmd6502eorImmediate:
	ld	regtemp,y+
	eor	rega,regtemp
	setNZ

cmd6502eorZeropage:
	modeZeropage
	ld	regtemp,z
	eor	rega,regtemp
	setNZ

cmd6502eorZeropageX:
	modeZeropageX
	ld	regtemp,z
	eor	rega,regtemp
	setNZ

cmd6502eorAbsolute:
	modeAbsolute
	ld	regtemp,z
	eor	rega,regtemp
	setNZ

cmd6502eorAbsoluteX:
	modeAbsoluteX
	ld	regtemp,z
	eor	rega,regtemp
	setNZ

cmd6502eorAbsoluteY:
	modeAbsoluteY
	ld	regtemp,z
	eor	rega,regtemp
	setNZ

cmd6502eorIndirectX:
	modeIndirectX
	ld	regtemp,z
	eor	rega,regtemp
	setNZ

cmd6502eorIndirectY:
	modeIndirectY
	ld	regtemp,z
	eor	rega,regtemp
	setNZ

.MACRO bitbase
	ld	regtemp,z
	mov	regtemp2,regtemp
	and	regtemp,rega
	in	regtemp,SREG
	andi	regsr,~(1<<sregV|1<<sregN|1<<sregZ)
	andi	regtemp,1<<sregZ
	sbrc	regtemp2,7
	ori	regtemp,1<<sregN
	sbrc	regtemp2,6
	ori	regtemp,1<<sregV
	or	regsr,regtemp
	rjmp	main6502
.ENDMACRO

cmd6502bitZeropage:
	modeZeropage
	bitbase

cmd6502bitAbsolute:
	modeAbsolute
	bitbase

.MACRO setNZCcmp
	in	regtemp,SREG
	mov	regtemp2,regtemp
	andi	regsr,~(1<<sregN|1<<sregZ|1<<sregC)
	andi	regtemp,(1<<sregN|1<<sregZ)
	andi	regtemp2,1<<sregC
	brne	setNZCcmp_lab1
	ori	regtemp,1<<sregC
setNZCcmp_lab1:
	or	regsr,regtemp
	rjmp	main6502
.ENDMACRO

.MACRO cmpbase
	cp	rega,regtemp
	setNZCcmp
.ENDMACRO

.MACRO cpxbase
	cp	regx,regtemp
	setNZCcmp
.ENDMACRO

.MACRO cpybase
	cp	regy,regtemp
	setNZCcmp
.ENDMACRO

cmd6502cmpImmediate:
	ld	regtemp,y+
	cmpbase

cmd6502cmpZeropage:
	modeZeropage
	ld	regtemp,z
	cmpbase

cmd6502cmpZeropageX:
	modeZeropageX
	ld	regtemp,z
	cmpbase

cmd6502cmpAbsolute:
	modeAbsolute
	ld	regtemp,z
	cmpbase

cmd6502cmpAbsoluteX:
	modeAbsoluteX
	ld	regtemp,z
	cmpbase

cmd6502cmpAbsoluteY:
	modeAbsoluteY
	ld	regtemp,z
	cmpbase

cmd6502cmpIndirectX:
	modeIndirectX
	ld	regtemp,z
	cmpbase

cmd6502cmpIndirectY:
	modeIndirectY
	ld	regtemp,z
	cmpbase

cmd6502cpxImmediate:
	ld	regtemp,y+
	cpxbase

cmd6502cpxZeropage:
	modeZeropage
	ld	regtemp,z
	cpxbase

cmd6502cpxAbsolute:
	modeAbsolute
	ld	regtemp,z
	cpxbase

cmd6502cpyImmediate:
	ld	regtemp,y+
	cpybase

cmd6502cpyZeropage:
	modeZeropage
	ld	regtemp,z
	cpybase

cmd6502cpyAbsolute:
	modeAbsolute
	ld	regtemp,z
	cpybase

cmd6502beq:
	ld	regtemp,y+
	sbrc	regsr,sregZ
	rjmp	cmd6502branch_lab1
	rjmp	main6502

cmd6502bne:
	ld	regtemp,y+
	sbrs	regsr,sregZ
	rjmp	cmd6502branch_lab1
	rjmp	main6502

cmd6502bcs:
	ld	regtemp,y+
	sbrc	regsr,sregC
	rjmp	cmd6502branch_lab1
	rjmp	main6502

cmd6502bcc:
	ld	regtemp,y+
	sbrs	regsr,sregC
	rjmp	cmd6502branch_lab1
	rjmp	main6502

cmd6502bmi:
	ld	regtemp,y+
	sbrc	regsr,sregN
	rjmp	cmd6502branch_lab1
	rjmp	main6502

cmd6502bpl:
	ld	regtemp,y+
	sbrs	regsr,sregN
	rjmp	cmd6502branch_lab1
	rjmp	main6502

cmd6502bvs:
	ld	regtemp,y+
	sbrc	regsr,sregV
	rjmp	cmd6502branch_lab1
	rjmp	main6502

cmd6502bvc:
	ld	regtemp,y+
	sbrs	regsr,sregV
	rjmp	cmd6502branch_lab1
	rjmp	main6502
cmd6502branch_lab1:
	tst	regtemp
	brpl	cmd6502branch_lab2
	neg	regtemp
	sub	yl,regtemp
	sbc	yh,regzero
	rjmp	main6502
cmd6502branch_lab2:
	add	yl,regtemp
	adc	yh,regzero
	rjmp	main6502

cmd6502jmpAbsolute:
	modeAbsolute
	mov	yl,zl
	mov	yh,zh
	rjmp	main6502

cmd6502jmpIndirect:
	modeAbsolute
	ld	yl,z
	inc	zl
	ld	yh,z
	add	yh,regmemoff6502
	rjmp	main6502

.MACRO	incbase
	ld	regtemp,z
	inc	regtemp
	st	z,regtemp
	setNZ
.ENDMACRO

cmd6502incZeropage:
	modeZeropage
	incbase

cmd6502incZeropageX:
	modeZeropageX
	incbase

cmd6502incAbsolute:
	modeAbsolute
	incbase

cmd6502incAbsoluteX:
	modeAbsoluteX
	incbase

cmd6502inx:
	inc	regx
	setNZ

cmd6502iny:
	inc	regy
	setNZ

.MACRO	decbase
	ld	regtemp,z
	dec	regtemp
	st	z,regtemp
	setNZ
.ENDMACRO

cmd6502decZeropage:
	modeZeropage
	decbase

cmd6502decZeropageX:
	modeZeropageX
	decbase

cmd6502decAbsolute:
	modeAbsolute
	decbase

cmd6502decAbsoluteX:
	modeAbsoluteX
	decbase

cmd6502dex:
	dec	regx
	setNZ

cmd6502dey:
	dec	regy
	setNZ

cmd6502clc:
	andi	regsr,~(1<<sregC)
	rjmp	main6502

cmd6502sec:
	ori	regsr,(1<<sregC)
	rjmp	main6502

cmd6502cld:
	andi	regsr,~(1<<sregD)
	rjmp	main6502

cmd6502sed:
	ori	regsr,(1<<sregD)
	rjmp	main6502

cmd6502cli:
	andi	regsr,~(1<<sregI)
	rjmp	main6502

cmd6502sei:
	ori	regsr,(1<<sregI)
	rjmp	main6502

cmd6502clv:
	andi	regsr,~(1<<sregV)
	rjmp	main6502

.MACRO	aslbase
	ld	regtemp,z
	lsl	regtemp
	st	z,regtemp
	setNZC
.ENDMACRO

cmd6502aslA:
	lsl	rega
	setNZC

cmd6502aslZeropage:
	modeZeropage
	aslbase

cmd6502aslZeropageX:
	modeZeropageX
	aslbase

cmd6502aslAbsolute:
	modeAbsolute
	aslbase

cmd6502aslAbsoluteX:
	modeAbsoluteX
	aslbase

.MACRO	lsrbase
	ld	regtemp,z
	lsr	regtemp
	st	z,regtemp
	setNZC
.ENDMACRO

cmd6502lsrA:
	lsr	rega
	setNZC

cmd6502lsrZeropage:
	modeZeropage
	lsrbase

cmd6502lsrZeropageX:
	modeZeropageX
	lsrbase

cmd6502lsrAbsolute:
	modeAbsolute
	lsrbase

cmd6502lsrAbsoluteX:
	modeAbsoluteX
	lsrbase

.MACRO	rolbase
	setCarry
	ld	regtemp,z
	rol	regtemp
	st	z,regtemp
	setNZC
.ENDMACRO

cmd6502rolA:
	setCarry
	rol	rega
	setNZC

cmd6502rolZeropage:
	modeZeropage
	rolbase

cmd6502rolZeropageX:
	modeZeropageX
	rolbase

cmd6502rolAbsolute:
	modeAbsolute
	rolbase

cmd6502rolAbsoluteX:
	modeAbsoluteX
	rolbase

.MACRO	rorbase
	setCarry
	ld	regtemp,z
	ror	regtemp
	st	z,regtemp
	setNZC
.ENDMACRO

cmd6502rorA:
	setCarry
	ror	rega
	setNZC

cmd6502rorZeropage:
	modeZeropage
	rorbase

cmd6502rorZeropageX:
	modeZeropageX
	rorbase

cmd6502rorAbsolute:
	modeAbsolute
	rorbase

cmd6502rorAbsoluteX:
	modeAbsoluteX
	rorbase

cmd6502jsr:
	; Ermittle Zieladresse
	ld	regtemp,y+
	ld	regtemp2,y
	add	regtemp2,regmemoff6502
	; 6502-Stack-Pointer im z-Register
	mov	zl,regsp
	ldi	zh,MEMOFF6502+1
	; Push aktuelle Adresse auf 6502-Stack
	sub	yh,regmemoff6502
	st	z,yh
	dec	zl
	st	z,yl
	dec	zl
	mov	regsp,zl
	; Setze Zieladresse
	mov	yl,regtemp
	mov	yh,regtemp2
	rjmp	main6502

.MACRO	flagsatmto6502
	mov	regtemp,regsr
	andi	regtemp,(1<<sregZ|1<<sregC|1<<sregB)
	ori	regtemp,(1<<sreg16502)
	sbrc	regsr,sregN
	ori	regtemp,(1<<sregN6502)
	sbrc	regsr,sregV
	ori	regtemp,(1<<sregV6502)
	sbrc	regsr,sregI
	ori	regtemp,(1<<sregI6502)
	sbrc	regsr,sregD
	ori	regtemp,(1<<sregD6502)
.ENDMACRO

.MACRO	flags6502toatm
	mov	regsr,regtemp
	andi	regsr,(1<<sregZ|1<<sregC|1<<sregB)
	sbrc	regtemp,sregN6502
	ori	regsr,(1<<sregN)
	sbrc	regtemp,sregV6502
	ori	regsr,(1<<sregV)
	sbrc	regtemp,sregI6502
	ori	regsr,(1<<sregI)
	sbrc	regtemp,sregD6502
	ori	regsr,(1<<sregD)
.ENDMACRO

cmd6502pha:
	ldi	zh,MEMOFF6502+1
	mov	zl,regsp
	st	z,rega
	dec	regsp
	rjmp	main6502

cmd6502php:
	flagsatmto6502
	ldi	zh,MEMOFF6502+1
	mov	zl,regsp
	st	z,regtemp
	dec	regsp
	rjmp	main6502

cmd6502pla:
	inc	regsp
	ldi	zh,MEMOFF6502+1
	mov	zl,regsp
	ld	rega,z
	atestandsetNZ

cmd6502plp:
	inc	regsp
	ldi	zh,MEMOFF6502+1
	mov	zl,regsp
	ld	regtemp,z
	flags6502toatm
	rjmp	main6502

cmd6502brk:
	; Setze B-flag
	ori	regsr,(1<<sregB)
	; Ueberlese ein Byte
	ld	regtemp,y+
	; BRK-Vektor
	ldi	zl,low(CPU6502FFFE)
	ldi	zh,high(CPU6502FFFE)
	; Springe zur Interrupt-Routine
	rjmp	interrupt6502_lab1

cmd6502rti:
	; 6502-Stack-Pointer im z-Register
	mov	zl,regsp
	ldi	zh,MEMOFF6502+1
	; Hole Statusregister vom Stack
	inc	zl
	ld	regtemp,z
	inc	zl
	flags6502toatm
	; Hole Ruecksprungadresse vom Stack
	ld	yl,z
	inc	zl
	ld	yh,z
	add	yh,regmemoff6502
	mov	regsp,zl
	; Ruecksprung aus dem VSync-Interrupt?
	lds	regtemp,INVSYNC
	tst	regtemp
	breq	cmd6502rti_lab1
	; Ja
	sts	INVSYNC,regzero
	; -> Sprites zeichnen (wenn noetig)
	lds	regtemp,DRAWSPRITES
	tst	regtemp
	breq	cmd6502rti_lab2
	push	r25
	push	yl
	push	yh
	lds	yl,SPRITELISTTMPPTR
	lds	yh,SPRITELISTTMPPTR+1
	; drawchangedmsprites (in: y; out: -; changed: r0,r1,r16-r25,x,y,z)
	call	drawchangedmsprites
	pop	yh
	pop	yl
	pop	r25
	sts	SPRITELISTINWORK,regzero
cmd6502rti_lab2:
	; Timer erhoehen
	; videogen_timer (in: -; out: -; changed: r16-r19)
	call	videogen_timer
cmd6502rti_lab1:
	rjmp	main6502

cmd6502rts:
	; 6502-Stack-Pointer im z-Register
	mov	zl,regsp
	ldi	zh,MEMOFF6502+1
	; Hole Ruecksprungadresse vom Stack
	inc	zl
	ld	yl,z
	inc	zl
	ld	yh,z
	add	yh,regmemoff6502
	adiw	yl,1
	mov	regsp,zl
	rjmp	main6502

ILLEGALOPCODE:
	.db	"ill. opc", 10, 0

cmd6502illegal:
	rcall	cmd6502dbgoutput
	; Print Fehlermeldung
	ldi	zl,low(ILLEGALOPCODE<<1)
	ldi	zh,high(ILLEGALOPCODE<<1)
	; printstringflash (in: z; out: -; changed: r16-r20,x,y,z)
	call	printstringflash

cmd6502shell:
	; CPU-Modus pruefen
	lds	regtemp,CPUMODE
	dec	regtemp
	sts	CPUMODE,regtemp
	brne	cmd6502rts
	jmp	shell

start6502:
	; Start des 6502-Emulators
	; Signatur start6502 (in: y; out: -; changed: r2-r4,r7,r8,r16-r19,r25,x,y,z,++)
	; Eingabe: y -> Pointer auf den Programm-Start (6502-Code)
	; Veraenderte Register: r2-r4, r7, r8, r16-r19, r25, x, y, z, ++

	; Register regmemoff6502 setzen
	ldi	regtemp,MEMOFF6502
	mov	regmemoff6502,regtemp
	; Setze SP
	ldi	regtemp,255
	mov	regsp,regtemp
	; init. sprite list
	; initlistmsprites (in: -; out: -; changed: r16,z)
	call	initlistmsprites
	; Setze Interrupt-Register
	clr	regint6502
	lds	regtemp,DEBUGONOFF
	sbrs	regtemp,0
	breq	start6502_lab1
	ldi	regtemp,(1<<INT6502DEBUG)
	mov	regint6502,regtemp
	sts	DEBUGSINGLESTEP,regzero
	lds	zl,DEBUGBPARRAYPTR
	lds	zh,DEBUGBPARRAYPTR+1
	st	z+,yl
	st	z+,yh
	st	z+,regzero
	st	z+,regzero
	lds	xl,DEBUGTEXTMAP
	lds	xh,DEBUGTEXTMAP+1
	ldi	r18,25
	ldi	r19,40
	ldi	r16,32
	; memfill (in: r16,r18,r19,x; out: -; changed: r17-r19)
	call	memfill
	lds	xl,DEBUGCOLORMAPTXT
	lds	xh,DEBUGCOLORMAPTXT+1
	ldi	r18,25
	ldi	r19,40
	ldi	r16,240
	; memfill (in: r16,r18,r19,x; out: -; changed: r17-r19)
	call	memfill
start6502_lab1:
	; Setze Interrupt-Maske (alle maskierbaren Interrupts ausschalten)
	sts	INTMASK6502,regzero
	; Ein RESET setzt das I-flag
	ldi	regsr,(1<<sregI)
	; Variabeln initialisieren
	ldi	regtemp,1
	sts	CPUMODE,regtemp
	sts	INVSYNC,regzero
	ldi	regtemp,255
	sts	BLOCKILVSYNCINT,regtemp
main6502:
	tst	regint6502
	brne	interrupt6502
main6502_lab1:
	ldi	zh,high(CMD6502JMPTAB<<1)
	ld	zl,y+
	lsl	zl
	adc	zh,regzero
	lpm	regtemp,z+
	lpm	regtemp2,z+
	movw	zl,regtemp
	ijmp

; Interrupt-Quelle  Interrupt-Vektor  Non-Maskable  Bit
; CTRL-Esc (Shell)  -                 x             7
; Debug             -                 x             6
; BRK               FFFE              x             -
; VSYNC             FFFC              x             4
; CTRL-D            FFFA                            3
; TIMER             FFF8                            2

interrupt6502:
	; Bit 7 des Interrupt-Registers bestimmt, ob ein CTRL-Esc-Interrupt vorliegt
	sbrc	regint6502,INT6502CTRLS
	rjmp	interrupt6502_lab7
	; Bit 6 des Interrupt-Registers bestimmt, ob ein Debug-Interrupt vorliegt
	sbrc	regint6502,INT6502DEBUG
	rjmp	interrupt6502_lab5
interrupt6502_lab25:
	; Loesche B-flag
	andi	regsr,~(1<<sregB)
	; Bit 4 des Interrupt-Registers bestimmt, ob ein VSYNC-Interrupt vorliegt
	sbrc	regint6502,INT6502VSYNC
	rjmp	interrupt6502_lab4
	; Folgende Interrupts sind Maskable-Interrupts
	sbrc	regsr,sregI
	rjmp	interrupt6502_lab8
	; Bit 3 des Interrupt-Registers bestimmt, ob ein CTRL-D-Interrupt vorliegt
	sbrc	regint6502,INT6502CTRLD
	rjmp	interrupt6502_lab3
	; Bit 2 des Interrupt-Registers bestimmt, ob ein TIMER-Interrupt vorliegt
	sbrc	regint6502,INT6502TIMER
	rjmp	interrupt6502_lab2
	; Unbekannte Interrupt-Quelle (Code duerfte nie hier durchkommen)
	rcall	cmd6502dbgoutput
interrupt6502_lab8:
	; interrupts disabled
	mov	regtemp,regint6502
	andi	regtemp,~(1<<INT6502CTRLD|1<<INT6502TIMER)
	mov	regint6502,regtemp
	rjmp	main6502_lab1
interrupt6502_lab7:
	; * CTRL-Esc-Interrupt *
	lds	regtemp,DEBUGONOFF
	sbrs	regtemp,0
	rjmp	cmd6502shell
	; Sprung in die Debug-Shell
	ldi	regtemp,low(~(1<<INT6502CTRLS))
	and	regint6502,regtemp
	rjmp	interrupt6502_lab23
interrupt6502_lab4:
	; * VSYNC-Interrupt *
	; already executing a VSYNC interrupt?
	lds	regtemp,INVSYNC
	lds	regtemp2,BLOCKILVSYNCINT
	and	regtemp,regtemp2
	breq	interrupt6502_lab32
	; yes, do not execute another VSYNC interrupt
	ldi	regtemp,~(1<<INT6502VSYNC)
	and	regint6502,regtemp
	rjmp	main6502_lab1
interrupt6502_lab32:
	sts	INVSYNC,regint6502
	ldi	regtemp,~(1<<INT6502VSYNC)
	and	regint6502,regtemp
	ldi	zl,low(CPU6502FFFC)
	ldi	zh,high(CPU6502FFFC)
	rjmp	interrupt6502_lab1
interrupt6502_lab3:
	; * CTRL-D-Interrupt *
	ldi	regtemp,~(1<<INT6502CTRLD)
	and	regint6502,regtemp
	ldi	zl,low(CPU6502FFFA)
	ldi	zh,high(CPU6502FFFA)
	rjmp	interrupt6502_lab1
interrupt6502_lab2:
	; * TIMER-Interrupt *
	ldi	regtemp,~(1<<INT6502TIMER)
	and	regint6502,regtemp
	ldi	zl,low(CPU6502FFF8)
	ldi	zh,high(CPU6502FFF8)
interrupt6502_lab1:
	; Alle "normalen" Interrupts
	ld	regtemp,z+
	ld	regtemp2,z+
	add	regtemp2,regmemoff6502
	; 6502-Stack-Pointer im z-Register
	mov	zl,regsp
	ldi	zh,MEMOFF6502+1
	; Push aktuelle Adresse auf 6502-Stack
	sub	yh,regmemoff6502
	st	z,yh
	dec	zl
	st	z,yl
	dec	zl
	; Setze PC auf den Start der Interrupt-Routine
	mov	yl,regtemp
	mov	yh,regtemp2
	; Push Status auf 6502-Stack
	flagsatmto6502
	st	z,regtemp
	dec	zl
	mov	regsp,zl
	; clear D-flag
	andi	regsr,~(1<<sregD)
	; Setze Interrupt Disable Flag
	ori	regsr,(1<<sregI)
	; Interrupt-Routine abarbeiten
	rjmp	main6502_lab1
interrupt6502_lab20:
	rjmp	interrupt6502_lab27
interrupt6502_lab5:
	; * Debug-Interrupt *
	lds	r16,DEBUGSINGLESTEP
	tst	r16
	brne	interrupt6502_lab23
	lds	zl,DEBUGBPARRAYPTR
	lds	zh,DEBUGBPARRAYPTR+1
interrupt6502_lab10:
	ld	xl,z+
	ld	xh,z+
	mov	r16,xl
	or	r16,xh
	breq	interrupt6502_lab20
	; PC on breakpoint address?
	cp	xl,yl
	brne	interrupt6502_lab10
	cp	xh,yh
	brne	interrupt6502_lab10
interrupt6502_lab23:
	; yes, show debug console
	lds	r16,TEXTMAP
	sts	DEBUGSAVETEXTMAP,r16
	lds	r16,DEBUGTEXTMAP
	sts	TEXTMAP,r16
	lds	r16,TEXTMAP+1
	sts	DEBUGSAVETEXTMAP+1,r16
	lds	r16,DEBUGTEXTMAP+1
	sts	TEXTMAP+1,r16
	lds	r16,COLORMAPTXT
	sts	DEBUGSAVECOLORMAPTXT,r16
	lds	r16,DEBUGCOLORMAPTXT
	sts	COLORMAPTXT,r16
	lds	r16,COLORMAPTXT+1
	sts	DEBUGSAVECOLORMAPTXT+1,r16
	lds	r16,DEBUGCOLORMAPTXT+1
	sts	COLORMAPTXT+1,r16
	lds	r16,CURX
	sts	DEBUGSAVECURX,r16
	lds	r18,DEBUGCURX
	sts	CURX,r18
	lds	r16,CURY
	sts	DEBUGSAVECURY,r16
	lds	r19,DEBUGCURY
	sts	CURY,r19
	; setcursorpos (in: r18,r19; out: -; changed: r0,r1,r16)
	call	setcursorpos
	lds	r16,VIDEOMODE
	sts	DEBUGSAVEVIDEOMODE,r16
	sts	VIDEOMODE,regzero
	rcall	cmd6502dbgoutput
	sts	DEBUGSINGLESTEP,regzero
	; wait for user input
	mov	r14,yl
	mov	r15,yh
	mov	r9,r2
	mov	r10,r3
	mov	r11,r4
interrupt6502_lab11:
	; shellwait4input (in: -; out: r17; changed: r16-r20,x,y,z)
	call	shellwait4input
	; interpret commands
	ldi	xl,low(SHELLBUFFER)
	ldi	xh,high(SHELLBUFFER)
	ld	r16,x+
	cpi	r16,'l'
	breq	interrupt6502_lab12
	cpi	r16,'b'
	breq	interrupt6502_lab14
	cpi	r16,'m'
	breq	interrupt6502_lab30
	cpi	r16,'f'
	breq	interrupt6502_lab31
	cpi	r16,'x'
	breq	interrupt6502_lab17
	cpi	r16,'s'
	breq	interrupt6502_lab24
	cpi	r16,'t'
	breq	interrupt6502_lab29
	cpi	r16,'q'
	breq	interrupt6502_lab28
	cpi	r16,'d'
	breq	interrupt6502_lab21
	rjmp	interrupt6502_lab11
interrupt6502_lab28:
	; debug quit command
	rjmp	cmd6502shell
interrupt6502_lab29:
	; debug "single step + clear interrupts" command
	ldi	r16,(1<<INT6502DEBUG)
	mov	regint6502,r16
interrupt6502_lab24:
	; debug "single step" command
	ldi	r16,1
	sts	DEBUGSINGLESTEP,r16
interrupt6502_lab17:
	; debug "exit shell" command
	rjmp	interrupt6502_lab16
interrupt6502_lab30:
	; debug peek command
	cpi	r17,2
	brne	interrupt6502_lab11
	ld	r16,x+
	; cmdpeek1 (in: x; out: -; changed: r0-r4,r16-r20,x,y,z)
	call	cmdpeek1
	rjmp	interrupt6502_lab11
interrupt6502_lab31:
	; debug poke command
	cpi	r17,3
	brne	interrupt6502_lab11
	ld	r16,x+
	; cmdpoke1 (in: x; out: -; changed: r0-r4,r16-r19,x,z)
	call	cmdpoke1
	rjmp	interrupt6502_lab11
interrupt6502_lab12:
	; debug list command
	lds	zl,DEBUGBPARRAYPTR
	lds	zh,DEBUGBPARRAYPTR+1
interrupt6502_lab13:
	ld	r18,z+
	ld	r19,z+
	mov	r16,r18
	or	r16,r19
	breq	interrupt6502_lab11
	mov	r12,zl
	mov	r13,zh
	subi	r19,MEMOFF6502
	; itoa (in: r18,r19; out: -; changed: r16-r21,z)
	call	itoa
	ldi	r18,low(ITOASTRING)
	ldi	r19,high(ITOASTRING)
	; printstring (in: r18,r19; out: -; changed: r16-r20,x,y,z)
	call	printstring
	; println (in: -; out: -; changed: r16,r17,r19,r20,x,y,z)
	call	println
	mov	zl,r12
	mov	zh,r13
	rjmp	interrupt6502_lab13
interrupt6502_lab14:
	; debug set breakpoint command
	cpi	r17,2
	breq	interrupt6502_lab9
	rjmp	interrupt6502_lab11
interrupt6502_lab9:
	; debugshellgetintarg (in: x; out: r17,r18,x; changed: r0-r4,r16-r19,x)
	rcall	debugshellgetintarg
	; go to end of debug breakpoint list
	lds	zl,DEBUGBPARRAYPTR
	lds	zh,DEBUGBPARRAYPTR+1
interrupt6502_lab15:
	ld	r16,z+
	ld	r19,z+
	or	r16,r19
	brne	interrupt6502_lab15
	st	z+,regzero
	st	z,regzero
	ld	r16,-z
	; add new breakpoint to list
	st	-z,r18
	st	-z,r17
	rjmp	interrupt6502_lab11
interrupt6502_lab21:
	; debug delete breakpoint command
	cpi	r17,2
	breq	interrupt6502_lab22
	rjmp	interrupt6502_lab11
interrupt6502_lab22:
	; debugshellgetintarg (in: x; out: r17,r18,x; changed: r0-r4,r16-r19,x)
	rcall	debugshellgetintarg
	; search for breakpoint in the list
	lds	zl,DEBUGBPARRAYPTR
	lds	zh,DEBUGBPARRAYPTR+1
interrupt6502_lab19:
	ld	r16,z+
	ld	r19,z+
	cp	r16,r17
	brne	interrupt6502_lab19
	cp	r19,r18
	brne	interrupt6502_lab19
	; breakpoint to delete found
	mov	xl,zl
	mov	xh,zh
	subi	zl,2
interrupt6502_lab18:
	ld	r16,x+
	ld	r19,x+
	st	z+,r16
	st	z+,r19
	or	r16,r19
	brne	interrupt6502_lab18
	rjmp	interrupt6502_lab11
interrupt6502_lab16:
	; restore video
	lds	r16,TEXTMAP
	sts	DEBUGTEXTMAP,r16
	lds	r16,DEBUGSAVETEXTMAP
	sts	TEXTMAP,r16
	lds	r16,TEXTMAP+1
	sts	DEBUGTEXTMAP+1,r16
	lds	r16,DEBUGSAVETEXTMAP+1
	sts	TEXTMAP+1,r16
	lds	r16,COLORMAPTXT
	sts	DEBUGCOLORMAPTXT,r16
	lds	r16,DEBUGSAVECOLORMAPTXT
	sts	COLORMAPTXT,r16
	lds	r16,COLORMAPTXT+1
	sts	DEBUGCOLORMAPTXT+1,r16
	lds	r16,DEBUGSAVECOLORMAPTXT+1
	sts	COLORMAPTXT+1,r16
	lds	r16,CURX
	sts	DEBUGCURX,r16
	lds	r18,DEBUGSAVECURX
	sts	CURX,r18
	lds	r16,CURY
	sts	DEBUGCURY,r16
	lds	r19,DEBUGSAVECURY
	sts	CURY,r19
	; setcursorpos (in: r18,r19; out: -; changed: r0,r1,r16)
	call	setcursorpos
	lds	r16,DEBUGSAVEVIDEOMODE
	sts	VIDEOMODE,r16
	mov	yl,r14
	mov	yh,r15
	mov	r2,r9
	mov	r3,r10
	mov	r4,r11
interrupt6502_lab27:
	mov	r16,regint6502
	andi	r16,~(1<<INT6502DEBUG)
	brne	interrupt6502_lab26
	rjmp	main6502_lab1
interrupt6502_lab26:
	rjmp	interrupt6502_lab25

debugshellgetintarg:
	; get integer argument for the debug shell
	; signatur debugshellgetintarg (in: x; out: r17,r18,x; changed: r0-r4,r16-r19,x)
	; input: x -> pointer to argument string, must have at least 1 preceding space
	; output: r17, r18 -> argument as a 16 bit number
	; changed registers: r0-r4, r16-r19, x

	ld	r16,x+
	; atoi (in: x; out: r17,r18,x; changed: r0-r4,r16-r19,x)
	call	atoi
	subi	r18,(256-MEMOFF6502)
	ret

PCSTR:
	.db	"PC=", 0
ASTR:
	.db	" A=", 0
XSTR:
	.db	" X=", 0
YSTR:
	.db	" Y=", 0
SPSTR:
	.db	" P=", 0
SRSTR:
	.db	" S=", 0

cmd6502dbgoutput_lab2:
	; btoa (in: r18; out: -; changed: r16-r21,z)
	call	btoa
cmd6502dbgoutput_lab3:
	ldi	r18,low(ITOASTRING)
	ldi	r19,high(ITOASTRING)
	; printstring (in: r18,r19; out: -; changed: r16-r20,x,y,z)
	call	printstring
	ret
cmd6502dbgoutput:
	push	yl
	push	yh
	; print PC
	ldi	zl,low(PCSTR<<1)
	ldi	zh,high(PCSTR<<1)
	mov	r21,yl
	mov	r22,yh
	; printstringflash (in: z; out: -; changed: r16-r20,x,y,z)
	call	printstringflash
	mov	r18,r21
	mov	r19,r22
	sub	r19,regmemoff6502
	; itoa (in: r18,r19; out: -; changed: r16-r21,z)
	call	itoa
	rcall	cmd6502dbgoutput_lab3
	; print A
	ldi	zl,low(ASTR<<1)
	ldi	zh,high(ASTR<<1)
	; printstringflash (in: z; out: -; changed: r16-r20,x,y,z)
	call	printstringflash
	mov	r18,rega
	rcall	cmd6502dbgoutput_lab2
	; print X
	ldi	zl,low(XSTR<<1)
	ldi	zh,high(XSTR<<1)
	; printstringflash (in: z; out: -; changed: r16-r20,x,y,z)
	call	printstringflash
	mov	r18,regx
	rcall	cmd6502dbgoutput_lab2
	; print Y
	ldi	zl,low(YSTR<<1)
	ldi	zh,high(YSTR<<1)
	; printstringflash (in: z; out: -; changed: r16-r20,x,y,z)
	call	printstringflash
	mov	r18,regy
	rcall	cmd6502dbgoutput_lab2
	; print SP
	ldi	zl,low(SPSTR<<1)
	ldi	zh,high(SPSTR<<1)
	; printstringflash (in: z; out: -; changed: r16-r20,x,y,z)
	call	printstringflash
	mov	r18,regsp
	rcall	cmd6502dbgoutput_lab2
	; print SR
	ldi	zl,low(SRSTR<<1)
	ldi	zh,high(SRSTR<<1)
	; printstringflash (in: z; out: -; changed: r16-r20,x,y,z)
	call	printstringflash
	mov	r18,regsr
	rcall	cmd6502dbgoutput_lab2
	; println (in: -; out: -; changed: r16,r17,r19,r20,x,y,z)
	call	println
	pop	yh
	pop	yl
	ret

cmd6502debug:
	rcall	cmd6502dbgoutput
	rjmp	main6502

CMDATM6502TAB:
	.dw	setcursorpos6502,cursorleft6502,cursorright6502,cursorup6502,cursordown6502,scrollup6502 ; 6
	.dw	println6502,printchar6502,printcharnoctrl6502,printstring6502 ; 4
	.dw	mul8x86502,mul16x16mod6502,div16x166502,atoi6502,itoa6502,itoaformat6502 ; 6
	.dw	memfill6502,memcopy6502,memcopyr6502,memcopylowhi6502,memcopyhilow6502 ; 5
	.dw	keybinit6502,getchwait6502,getchnowait6502 ; 3
	.dw	sdinit6502,sdreadsector6502,sdwritesector6502 ; 3
	.dw	fatload6502,fatsave6502,fatopen6502,fatreadnextsector6502,fatwritenextsector6502,fatrmorextcc6502 ; 6
	.dw	copycharmap6502 ; 1
	.dw	addmsprite6502,delmsprite6502,initlistmsprites6502,coincmsprite6502 ; 4
	.dw	gfxcopytile6502,gfxcopytilecol6502,gfxcopytilerow6502,setpixel6502,drawline6502 ; 5
	.dw	copyblock6502,copychars6502,vic20multicolmapping6502 ; 3
	.dw	spi6502,spienable6502,spidisable6502 ; 3
	.dw	fatls6502,fatcd6502 ; 2

cmd6502atmega:
	ldi	zl,low(CMDATM6502TAB<<1)
	ldi	zh,high(CMDATM6502TAB<<1)
	ld	regtemp,y+
	add	zl,regtemp
	adc	zh,regzero
	lpm	regtemp,z+
	lpm	regtemp2,z+
	movw	zl,regtemp
	icall
	rjmp	main6502
