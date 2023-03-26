.include	"6502defcc.inc"
.include	"r162.inc"

.export	_clrscr, _kbhit, _gotoxy, _cputc, _cputcxy, _cgetc, _textcolor, _bgcolor, _wherex, _wherey
.import	popa


; void clrscr (void);
; Clear the whole screen and put the cursor into the top left corner
_clrscr:
	ldx	#<memfillstructtext
	ldy	#>memfillstructtext
	callatm	memfill6502
	ldx	#0
	ldy	#0
	callatm	setcursorpos6502
	ldx	#<memfillstructcolor
	ldy	#>memfillstructcolor
	callatm	memfill6502
	rts
memfillstructtext:
.word	TEXTMAPDEFAULT
.byt	40,25,32
memfillstructcolor:
.word	COLORMAPTXTDEFAULT
.byt	40,25,240

; unsigned char kbhit (void);
; Return true if there's a key waiting, return false if not
_kbhit:
	callatm	getchnowait6502
	; return value in a/x
	ldx	#0
	lda	RGETCH6502
	bne	@L0
	lda	#0
	rts
@L0:
	lda	#1
	rts

; void __fastcall__ gotox (unsigned char x);
; Set the cursor to the specified X position, leave the Y position untouched

; void __fastcall__ gotoy (unsigned char y);
; Set the cursor to the specified Y position, leave the X position untouched

; void __fastcall__ gotoxy (unsigned char x, unsigned char y);
; Set the cursor to the specified position
_gotoxy:
	sta	TMP1
	jsr 	popa
	tax
	ldy	TMP1
	callatm	setcursorpos6502
	rts

; unsigned char wherex (void);
; Return the X position of the cursor
_wherex:
	; return value in a/x
	ldx	#0
	lda	CURX
	rts

; unsigned char wherey (void);
; Return the Y position of the cursor
_wherey:
	; return value in a/x
	ldx	#0
	lda	CURY
	rts

; void __fastcall__ cputcxy (unsigned char x, unsigned char y, char c);
; Same as "gotoxy (x, y); cputc (c);"
_cputcxy:
	pha	    		; Save C
	jsr	popa		; Get Y
	jsr	_gotoxy		; Set cursor, drop x
	pla			; Restore C

; void __fastcall__ cputc (char c);
; Output one character at the current cursor position
_cputc:
	callatm	printchar6502
	lda	COLORONOFF
	beq	@L0
	ldx	CURY
	ldy	#SCRXSIZE
	callatm	mul8x86502
	lda	#<COLORMAPTXTDEFAULT
	clc
	adc	RMUL6502
	sta	TMP1
	lda	#>COLORMAPTXTDEFAULT
	adc	RMUL6502+1
	sta	TMP1+1
	ldy	CURX
	dey
	lda	COLORFG
	ora	COLORBG
	sta	(TMP1),y
@L0:
	rts

; void __fastcall__ cputs (const char* s);
; Output a NUL-terminated string at the current cursor position
; -> implemented in conio/cputs.s

; void __fastcall__ cputsxy (unsigned char x, unsigned char y, const char* s);
; Same as "gotoxy (x, y); puts (s);"

; int cprintf (const char* format, ...);
; Like printf(), but uses direct screen output

; int __fastcall__ vcprintf (const char* format, va_list ap);
; Like vprintf(), but uses direct screen output

; char cgetc (void);
; Return a character from the keyboard. If there is no character available,
; the function waits until the user does press a key. If cursor is set to
; 1 (see below), a blinking cursor is displayed while waiting.
_cgetc:
	callatm	getchwait6502
	; return value in a/x
	ldx	#0
	lda	RGETCH6502
	rts

; int cscanf (const char* format, ...);
; Like scanf(), but uses direct keyboard input

; int __fastcall__ vcscanf (const char* format, va_list ap);
; Like vscanf(), but uses direct keyboard input

; unsigned char __fastcall__ cursor (unsigned char onoff);
; If onoff is 1, a cursor is displayed when waiting for keyboard input. If
; onoff is 0, the cursor is hidden when waiting for keyboard input. The
; function returns the old cursor setting.

; unsigned char __fastcall__ revers (unsigned char onoff);
; Enable/disable reverse character display. This may not be supported by
; the output device. Return the old setting.

; unsigned char __fastcall__ textcolor (unsigned char color);
; Set the color for text output. The old color setting is returned.
_textcolor:
	tax
	lda	#1
	sta	COLORONOFF
	lda	COLORFG
	stx	COLORFG
	ldx	#0
	rts

; unsigned char __fastcall__ bgcolor (unsigned char color);
; Set the color for the background. The old color setting is returned.
_bgcolor:
	tax
	lda	#1
	sta	COLORONOFF
	lda	COLORBG
	stx	COLORBG
	ldx	#0
	rts

; unsigned char __fastcall__ bordercolor (unsigned char color);
; Set the color for the border. The old color setting is returned.

; void __fastcall__ chline (unsigned char length);
; Output a horizontal line with the given length starting at the current
; cursor position.


; void __fastcall__ chlinexy (unsigned char x, unsigned char y, unsigned char length);
; Same as "gotoxy (x, y); chline (length);"

; void __fastcall__ cvline (unsigned char length);
; Output a vertical line with the given length at the current cursor position.


; void __fastcall__ cvlinexy (unsigned char x, unsigned char y, unsigned char length);
; Same as "gotoxy (x, y); cvline (length);"

; void __fastcall__ cclear (unsigned char length);
; Clear part of a line (write length spaces).

; void __fastcall__ cclearxy (unsigned char x, unsigned char y, unsigned char length);
; Same as "gotoxy (x, y); cclear (length);"

; void __fastcall__ screensize (unsigned char* x, unsigned char* y);
; Return the current screen size.
