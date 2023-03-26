.include	"6502defcc.inc"
.include	"r162.inc"

.export	_initscr, _endwin, _start_color, _init_pair, _COLOR_PAIR, _attron, _attroff, _defch, _echo, _noecho, _getch, _getstr, _clrtoeol, _scrl, _beep, _nodelay, _curs_set, _inch, _box, _stdscr
.import	popa, popax, _clrscr

COLOR = TMP1
DATA = TMP2
CH = TMP4
CHDEF = TMP5
DEST = TMP2
SRC = TMP4
N = TMP6

; extern void* stdscr;
_stdscr:

; void* initscr(void);
_initscr:
	jsr	_clrscr
	lda	#0
	sta	NONBLOCKONOFF
	lda	#1
	sta	CURONOFF
	rts

; int endwin(void);
_endwin:
	jsr	_clrscr
	callatm	copycharmap6502
	lda	#1
	sta	CURONOFF
	rts

; void start_color(void);
_start_color:
	lda	#1
	sta	COLORONOFF
	rts

; void __fastcall__ init_pair(unsigned char nr, unsigned char fgcolor, unsigned char bgcolor);
_init_pair:
	; color in COLOR
	sta	COLOR
	jsr 	popa
	asl
	asl
	asl
	asl
	ora	COLOR
	sta	COLOR
	; save color
	jsr 	popa
	tax
	lda	COLOR
	sta	CURSESCOLORS,x
	rts

;unsigned char __fastcall__ COLOR_PAIR(unsigned char nr);
_COLOR_PAIR:
	tax
	lda	CURSESCOLORS,x
	ldx	#0
	rts

;void __fastcall__ attron(unsigned char color);
_attron:
	tax
	and	#240
	sta	COLORFG
	txa
	and	#15
	sta	COLORBG
	rts

;void __fastcall__ attroff(unsigned char color);
_attroff:
	; ignore argument
	lda	#STDCOLOR
	sta	COLORFG
	lda	#0
	sta	COLORBG
	rts


;int echo(void);
_echo:
	lda	#1
	sta	ECHOONOFF
	lda	#0
	tax
	rts


;int noecho(void);
_noecho:
	lda	#0
	sta	ECHOONOFF
	tax
	rts


;void __fastcall__ defch(unsigned char ch, unsigned char* data);
_defch:
	; get parameter data (in a/x)
	sta	DATA
	stx	DATA+1

	; get parameter ch (on stack)
	jsr	popa
	sta	CH

	; copy data to "character definiton ram"
	lda	#0
	clc
	adc	CH
	sta	CHDEF
	lda	#>CHARDEFSDEFAULT
	adc	#7
	sta	CHDEF+1
	ldy	#7
	ldx	#0
_defch1:
	lda	(DATA),y
	sta	(CHDEF,x)
	dec	CHDEF+1
	dey
	bpl	_defch1
	rts


;int getch(void);
_getch:
	lda	NONBLOCKONOFF
	bne	_getch4
	callatm	getchwait6502
_getch5:
	lda	ECHOONOFF
	beq	_getch1
	lda	RGETCH6502
	cmp	#10
	beq	_getch2
_getch3:
	callatm	printchar6502
_getch1:
	; return value in a/x
	ldx	#0
	lda	RGETCH6502
	rts
_getch2:
	ldx	CURY
	cpx	#24
	bne	_getch3
	tya
	pha
	ldx	#0
	ldy	#24
	callatm	setcursorpos6502
	pla
	tay
	jmp	_getch1
_getch4:
	callatm	getchnowait6502
	jmp	_getch5


;void __fastcall__ getstr(char* str);
_getstr:
	; get parameter data (in a/x)
	sta	DATA
	stx	DATA+1
	ldy	#255
_getstr1:
	iny
	jsr	_getch
	sta	(DATA),y
	cmp	#10
	bne	_getstr1
	lda	#0
	sta	(DATA),y
	rts


;int clrtoeol(void);
_clrtoeol:
	lda	ACTCURADDRP768
	sta	DEST
	lda	ACTCURADDRP768+1
	sec
	sbc	#3
	sta	DEST+1
	lda	#40
	sec
	sbc	CURX
	tay
	dey
	lda	#' '
_clrtoeol_lab1:
	sta	(DEST),y
	dey
	bne	_clrtoeol_lab1
	; return value in a/x
	lda	#0
	tax
	rts


;int __fastcall__ scrl(int n);
_scrl:
	; get parameter data (in a/x)
	sta	N
	stx	N+1
	; N < 0?
	lda	N+1
	bmi	_scrl_lab10
	; N >= 0
	lda	N
_scrl_lab2:
	beq	_scrl_lab1
	callatm	scrollup6502
	dec	N
	jmp	_scrl_lab2
_scrl_lab1:
	; return value in a/x
	lda	#0
	tax
	rts
_scrl_lab10:
	; N < 0
	eor	#255
	clc
	adc	#1
	sta	N
_scrl_lab20:
	; scroll 1 line
	; init.
	clc
	lda	TEXTMAPP768
	adc	#<(959-768)
	sta	SRC
	lda	TEXTMAPP768+1
	adc	#>(959-768)
	sta	SRC+1
	clc
	lda	TEXTMAPP768
	adc	#<(999-768)
	sta	DEST
	lda	TEXTMAPP768+1
	adc	#>(999-768)
	sta	DEST+1
	lda	#24
	sta	N+1
	; scroll
	ldy	#0
_scrl_lab12:
	ldx	#40
_scrl_lab11:
	lda	(SRC),y
	sta	(DEST),y
	lda	SRC
	bne	_scrl_lab13
	dec	SRC+1
_scrl_lab13:
	dec	SRC
	lda	DEST
	bne	_scrl_lab14
	dec	DEST+1
_scrl_lab14:
	dec	DEST
	dex
	bne	_scrl_lab11
	dec	N+1
	bne	_scrl_lab12
	; clear first line
	lda	#' '
	ldy	#39
	lda	TEXTMAPP768
	sta	DEST
	lda	TEXTMAPP768+1
	sec
	sbc	#3
	sta	DEST+1
_scrl_lab15:
	sta	(DEST),y
	dey
	bpl	_scrl_lab15
	; scroll next line
	dec	N
	bne	_scrl_lab20
	jmp	_scrl_lab1


;int beep(void);
_beep:
	lda	#30
	sta	SNDTCCR2
	lda	#50
	sta	SNDOCR2
	ldy	#30
_beep_lab2:
	ldx	#0
_beep_lab1:
	dex
	bne	_beep_lab1
	dey
	bne	_beep_lab2
	lda	#0
	sta	SNDTCCR2
	; return value in a/x
	tax
	rts


;int __fastcall__ nodelay(void *, bool bf);
_nodelay:
	; get parameter bf (in a)
	sta	NONBLOCKONOFF

	; get void parameter (on stack)
	jsr	popax

	lda	#0
	tax
	rts


;int __fastcall__ curs_set(int n);
_curs_set:
	sta	CURONOFF
	rts


; char inch (void);
; Return the character at the current cursor position
_inch:
	lda	ACTCURADDRP768
	sta	DEST
	lda	ACTCURADDRP768+1
	sec
	sbc	#3
	sta	DEST+1
	; return value in a/x
	ldx	#0
	lda	(DEST,x)
	rts


;int __fastcall__ box(void*, char vch, char hch);
_box:
	; get hch (in a)
	sta	CH
	; get vch (in a)
	jsr 	popa
	sta	CH+1
	; get void parameter (on stack)
	jsr	popax

	; top horizontal line
	lda	TEXTMAPP768
	sta	DEST
	lda	TEXTMAPP768+1
	sec
	sbc	#3
	sta	DEST+1
	ldy	#39
	lda	CH
_box_lab1:
	sta	(DEST),y
	dey
	bpl	_box_lab1

	; left and right vertical line
	ldx	#23
_box_lab2:
	clc
	lda	DEST
	adc	#40
	sta	DEST
	lda	DEST+1
	adc	#0
	sta	DEST+1
	lda	CH+1
	ldy	#0
	sta	(DEST),y
	ldy	#39
	sta	(DEST),y
	dex
	bne	_box_lab2

	; bottom horizontal line
	ldy	#39
	lda	CH
_box_lab3:
	sta	(DEST),y
	dey
	bpl	_box_lab3

	; return
	lda	#0
	tax
	rts
