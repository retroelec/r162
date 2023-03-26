dbgprintstringram:
	; Ausgabe des Strings aus dem SRAM auf dem Bildschirm
	; Signatur dbgprintstringram (in: r18,r19; out: -; changed: r18,r19)
	; Eingabe: r18, r19 -> String, der an der aktuellen Cursor-Position ausgegeben werden soll
	; Veraenderte Register: r18, r19

	push	r16
	in	r16,SREG
	push	r16
	push	r17
	push	r20
	push	xl
	push	xh
	push	yl
	push	yh
	push	zl
	push	zh
	; printstring (in: r18,r19; out: -; changed: r16-r20,x,y,z)
	call	printstring
	pop	zh
	pop	zl
	pop	yh
	pop	yl
	pop	xh
	pop	xl
	pop	r20
	pop	r17
	pop	r16
	out	SREG,r16
	pop	r16
	ret

dbgprintstringflash:
	; Ausgabe des Strings aus dem FLASH auf dem Bildschirm
	; Signatur dbgprintstringflash (in: z; out: -; changed: z)
	; Eingabe: z -> String, der an der aktuellen Cursor-Position ausgegeben werden soll
	; Veraenderte Register: z

	push	r16
	in	r16,SREG
	push	r16
	push	r17
	push	r18
	push	r19
	push	r20
	push	xl
	push	xh
	push	yl
	push	yh
	; printstringflash (in: z; out: -; changed: r16-r20,x,y,z)
	call	printstringflash
	pop	yh
	pop	yl
	pop	xh
	pop	xl
	pop	r20
	pop	r19
	pop	r18
	pop	r17
	pop	r16
	out	SREG,r16
	pop	r16
	ret


dbgprintbyte:
	; Ausgabe eines Byte-Werts auf dem Bildschirm
	; Signatur dbgprintbyte (in: r18; out: -; changed: -)
	; Eingabe: r18 -> Wert, der an der aktuellen Cursor-Position ausgegeben werden soll

	push	r16
	push	zl
	push	zh
	push	xl
	push	xh
	push	yl
	push	yh
	push	r17
	push	r18
	push	r19
	push	r20
	push	r21
	; btoa (in: r18; out: -; changed: r16-r21,z)
	call	btoa
	ldi	r18,low(ITOASTRING)
	ldi	r19,high(ITOASTRING)
	; printstring (in: r18,r19; out: -; changed: r16-r20,x,y,z)
	call	printstring
	ldi	r18,' '
	; printchar (in: r18; out: -; changed: r16,r17,r19,r20,x,y,z)
	call	printchar
	pop	r21
	pop	r20
	pop	r19
	pop	r18
	pop	r17
	pop	yh
	pop	yl
	pop	xh
	pop	xl
	pop	zh
	pop	zl
	pop	r16
	ret


dbgcalccuraddr:
	; Berechne die zur angegebenen Position korrespondierende Bildschirm-Adresse
	; Signatur dbgcalccuraddr (in: r16,r17; out: r0,r1; changed: r0,r1,r18)
	; Eingabe: r16 -> x-Position
	; Eingabe: r17 -> y-Position
	; Ausgabe: r0, r1 -> Zur angegebenen Position korrespondierende Bildschirm-Adresse
	; Veraenderte Register: r0, r1, r18

	ldi	r18,40
	mul	r17,r18
	add	r0,r16
	adc	r1,regzero
	lds	r18,TEXTMAP
	add	r0,r18
	lds	r18,TEXTMAP+1
	adc	r1,r18
	ret


dbgprintchxy:
	; Zeichen an einer bestimmten Position auf dem Bildschirm ausgeben
	; Signatur dbgprintchxy (in: r16,r17,r19; out: -; changed: r0,r1,r18,x)
	; Eingabe: r16 -> x-Position
	; Eingabe: r17 -> y-Position
	; Eingabe: r19 -> Zeichen, das ausgegeben werden soll
	; Veraenderte Register: r0, r1, r18, x

	; dbgcalccuraddr (in: r16,r17; out: r0,r1; changed: r0,r1,r18)
	rcall	dbgcalccuraddr
	mov	xl,r0
	mov	xh,r1
	st	x+,r19
	ret


dbgprintstrxy:
	; String an einer bestimmten Position auf dem Bildschirm ausgeben
	; Signatur dbgprintstrxy (in: r16,r17,r20,z; out: -; changed: r0,r1,r18,x,z)
	; Eingabe: r16 -> x-Position
	; Eingabe: r17 -> y-Position
	; Eingabe: r20 -> String vom Flash- (r20 == 0) oder vom SRAM-Speicher (r20 != 0) holen
	; Eingabe: z -> String, der an der angegebenen Position ausgegeben werden soll
	; Veraenderte Register: r0, r1, r18, x, z

	; dbgcalccuraddr (in: r16,r17; out: r0,r1; changed: r0,r1,r18)
	rcall	dbgcalccuraddr
	mov	xl,r0
	mov	xh,r1
dbgprintstrxy_lab1:
	tst	r20
	breq	dbgprintstrxy_lab2
	ld	r18,z+
	rjmp	dbgprintstrxy_lab3
dbgprintstrxy_lab2:
	lpm	r18,z+
dbgprintstrxy_lab3:
	tst	r18
	breq	dbgprintstrxy_lab4
	st	x+,r18
	rjmp	dbgprintstrxy_lab1
dbgprintstrxy_lab4:
	ret
