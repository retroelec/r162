.include	"6502defcc.inc"
.include	"r162.inc"

.export	_tgi_load, _tgi_load_driver, _tgi_unload, _tgi_install, _tgi_uninstall, _tgi_init, _tgi_done, _tgi_clear, _tgi_getxres, _tgi_getmaxx, _tgi_getyres, _tgi_getmaxy, _tgi_getcolorcount, _tgi_getmaxcolor
.export _tgi_getcolor, _tgi_setcolor, _tgi_setbgcolor, _tgi_getpixel, _tgi_setpixel, _tgi_line, _tgi_bar, _tgi_outtext, _tgi_outtextxy
.import	popa, popax

TILECHARSCOLOR = 240

PARAM1 = TMP3
PARAM2 = TMP4
TMPPTR = TMP5
C2TCOLDATA = TMP7
C2TTILEDATA = TMP8
C2TCHARDEFS = TMP10
C2TCNT = TMP12
C2TCHARDATA = TMP13
C2TTMPDATA = TMP14

;----------------------------------------------------------------------------
.code

; void __fastcall__ tgi_load (unsigned char mode);
; /* Load and install the matching driver for the given mode. Will just load
;  * the driver and check if loading was successul. Will not switch to gaphics
;  * mode.
;  */
.proc	_tgi_load
	jmp	_tgi_install
.endproc


; void __fastcall__ tgi_load_driver (const char* name);
; /* Load and install the given driver. This function is identical to tgi_load
;  * with the only difference that the name of the driver is specified
;  * explicitly.
;  */
.proc	_tgi_load_driver
	jmp	_tgi_install
.endproc


; void __fastcall__ tgi_unload (void);
; /* Uninstall, then unload the currently loaded driver. Will call tgi_done if
;  * necessary.
;  */
.proc	_tgi_unload
	jmp	_tgi_uninstall
.endproc


; void __fastcall__ tgi_install (void* driver);
; /* Install an already loaded driver. */
.proc	_tgi_install
	; tile for "graphic chars"
	lda	#<tilesdef
	sta	C2TTILEDATA
	lda	#>tilesdef
	sta	C2TTILEDATA+1
	lda	#<(tilesdef+768)
	sta	GFXTILEDEFSP768
	lda	#>(tilesdef+768)
	sta	GFXTILEDEFSP768+1
	; clear multicolor screen
	lda	#<(MCOLORMAPDEFAULT+768)
	sta	MCOLORMAPP768
	lda	#>(MCOLORMAPDEFAULT+768)
	sta	MCOLORMAPP768+1
	; set default draw color
	lda	#15
	sta	DPCOLOR
	lda	#0
	sta	DPBGCOLOR
	rts
.endproc


; void __fastcall__ tgi_uninstall (void);
; /* Uninstall the currently loaded driver but do not unload it. Will call
;  * tgi_done if necessary.
;  */
.proc	_tgi_uninstall
	jmp	_tgi_done
.endproc


; void __fastcall__ tgi_init (void);
; /* Initialize the already loaded graphics driver. */
.proc	_tgi_init
	; switch to multi color mode
	lda	#2
	sta	VIDEOMODE
	rts
.endproc


; void __fastcall__ tgi_done (void);
; /* End graphics mode, switch back to text mode. Will NOT uninstall or unload
;  * the driver!
;  */
.proc	_tgi_done
	; switch to text mode
	lda	#0
	sta	VIDEOMODE
	rts
.endproc


;void __fastcall__ tgi_clear (void);
;/* Clear the drawpage. */
.proc	_tgi_clear
	ldx	#<memfillstructgfx
	ldy	#>memfillstructgfx
	callatm	memfill6502
	rts
memfillstructgfx:
.word	MCOLORMAPDEFAULT
.byt	80,200,0
.endproc


; unsigned __fastcall__ tgi_getxres (void);
; /* Return the resolution in X direction. */
.proc	_tgi_getxres
	ldx	#0
	lda	#160
	rts
.endproc


; unsigned __fastcall__ tgi_getmaxx (void);
; /* Return the maximum x coordinate. The resolution in x direction is
;  * getmaxx() + 1
;  */
.proc	_tgi_getmaxx
	ldx	#0
	lda	#159
	rts
.endproc


; unsigned __fastcall__ tgi_getyres (void);
; /* Return the resolution in Y direction. */
.proc	_tgi_getyres
	ldx	#0
	lda	#200
	rts
.endproc


; unsigned __fastcall__ tgi_getmaxy (void);
; /* Return the maximum y coordinate. The resolution in y direction is
;  * getmaxy() + 1
;  */
.proc	_tgi_getmaxy
	ldx	#0
	lda	#199
	rts
.endproc


; unsigned char __fastcall__ tgi_getcolorcount (void);
; /* Get the number of available colors. */
.proc	_tgi_getcolorcount
	ldx	#0
	lda	#16
	rts
.endproc


; unsigned char __fastcall__ tgi_getmaxcolor (void);
; /* Return the maximum supported color number (the number of colors would
;  * then be getmaxcolor()+1).
;  */
.proc	_tgi_getmaxcolor
	ldx	#0
	lda	#15
	rts
.endproc


; unsigned char __fastcall__ tgi_getcolor (void);
; /* Return the current drawing color. */
.proc	_tgi_getcolor
	ldx	#0
	lda	DPCOLOR
	rts
.endproc


; void __fastcall__ tgi_setcolor (unsigned char color);
; /* Set the current drawing color. */
.proc	_tgi_setcolor
	sta	DPCOLOR
	rts
.endproc


; void __fastcall__ tgi_setbgcolor (unsigned char color);
; /* Set the current background drawing color. */
.proc	_tgi_setbgcolor
	sta	DPBGCOLOR
	rts
.endproc


; unsigned char __fastcall__ tgi_getpixel (int x, int y);
; /* Get the color value of a pixel. */
.proc	_tgi_getpixel
	; get parameter y (in a/x)
	sta	PARAM1

	; get parameter x (on stack)
	jsr	popax
	sta	PARAM2

	; tmpptr = MCOLORMAP+MCOLSCRWIDTH*y+x/2
	lsr
	sta	TMP1
	ldx	PARAM1
	ldy	MCOLSCRWIDTH
	callatm	mul8x86502
	lda	MCOLORMAPP768
	clc
	adc	RMUL6502
	sta	TMPPTR
	lda	MCOLORMAPP768+1
	adc	RMUL6502+1
	sec
	sbc	#>768
	sta	TMPPTR+1
	lda	TMPPTR
	clc
	adc	TMP1
	sta	TMPPTR
	lda	TMPPTR+1
	adc	#0
	sta	TMPPTR+1
	; x&1 = ?
	ldx	#0
	lda	PARAM2
	and	#15
	bne	@L2
	; x&1 == 0 -> return swap(*tmpptr & 240)
	lda	(TMPPTR,x)
	and	#240
	; swap byte
	ldx	#4
@L1:
	cmp	#128
	rol
	dex
	bne	@L1
	rts
@L2:
	; x&1 == 1 -> return (*tmpptr & 15)
	lda	(TMPPTR,x)
	and	#15
	rts
.endproc


; void __fastcall__ tgi_setpixel (int x, int y);
; /* Plot a pixel in the current drawing color. */
.proc	_tgi_setpixel
	; get parameter y (in a/x)
	sta	TMP1

	; get parameter x (on stack)
	jsr	popax

	tax
	ldy	TMP1
	lda	DPCOLOR
	callatm	setpixel6502
	rts
.endproc


; void __fastcall__ tgi_line (int x1, int y1, int x2, int y2);
; /* Draw a line in the current drawing color. The graphics cursor will
;  * be set to x2/y2 by this call.
; */
.proc	_tgi_line
	; get parameter y2 (in a/x)
	sta	DRAWLINEENDY
	sta	GRCURY

	; get parameter x2 (on stack)
	jsr	popax
	sta	DRAWLINEENDX
	sta	GRCURX

	; get parameter y1 (on stack)
	jsr	popax
	sta	TMP1

	; get parameter x1 (on stack)
	jsr	popax

	tax
	ldy	TMP1
	lda	DPCOLOR
	callatm	drawline6502
	rts
.endproc


; void __fastcall__ tgi_lineto (int x2, int y2);
; /* Draw a line in the current drawing color from the graphics cursor to the
;  * new end point. The graphics cursor will be updated to x2/y2.
; */
.proc	_tgi_lineto
	; get parameter y2 (in a/x)
	sta	DRAWLINEENDY
	ldy	GRCURY
	sty	TMP1
	sta	GRCURY

	; get parameter x2 (on stack)
	jsr	popax
	sta	DRAWLINEENDX
	ldx	GRCURX
	sta	GRCURX

	ldy	TMP1
	lda	DPCOLOR
	callatm	drawline6502
	rts
.endproc


; void __fastcall__ tgi_bar (int x1, int y1, int x2, int y2);
; /* Draw a bar (a filled rectangle) using the current color. */
.proc	_tgi_bar
	; get parameter y2 (in a/x)
	sta	TMP1

	; get parameter x2 (on stack)
	jsr	popax
	sta	DRAWLINEENDX

	; get parameter y1 (on stack)
	jsr	popax
	sta	DRAWLINEENDY

	; get parameter x1 (on stack)
	jsr	popax
	tax

	; number of lines
	lda	TMP1
	sec
	sbc	DRAWLINEENDY
	sta	TMP1
	inc	TMP1

	; draw lines
	lda	DPCOLOR
@L1:
	ldy	DRAWLINEENDY
	callatm	drawline6502
	inc	DRAWLINEENDY
	dec	TMP1
	bne	@L1
	rts
.endproc


; void __fastcall__ tgi_outtext (const char* s);
; /* Output text at the current graphics cursor position. The graphics cursor
;  * is moved to the end of the text.
;  */
_tgi_outtext:
	; get parameter s (in a/x)
	sta	TMPPTR
	stx	TMPPTR+1
	jmp	gfxprintstring


; void __fastcall__ tgi_outtextxy (int x, int y, const char* s);
; /* Output text at the given cursor position. The graphics cursor is moved to
; * the end of the text.
; */
.proc	_tgi_outtextxy
	; get parameter s (in a/x)
	sta	TMPPTR
	stx	TMPPTR+1

	; get parameter y (on stack)
	jsr	popax
	sta	GRCURY

	; get parameter x (on stack)
	jsr	popax
	sta	GRCURX

	jmp	gfxprintstring
.endproc


.proc	gfxprintstring
	; print a string in multi color mode
	; input -> TMPPTR = pointer to the string

	lda	GRCURX
	lsr
	lsr
	lsr
	tax
	lda	GRCURY
	lsr
	lsr
	lsr
	tay
	lda	DPCOLOR
	asl
	asl
	asl
	asl
	ora	DPBGCOLOR
	sta	C2TCOLDATA
	sty	TMP1
	ldy	#0
gfxprintstring_lab1:
	stx	TMP3
	sty	TMP2
	lda	(TMPPTR),y
	beq	gfxprintstring_lab2
	jsr	char2tile
	lda	GRCURX
	clc
	adc	#8
	sta	GRCURX
	lda	GRCURY
	clc
	adc	#8
	sta	GRCURY
	lda	#0
	ldy	TMP1
	ldx	TMP3
	callatm	gfxcopytile6502
	inx
	lda	#1
	callatm	gfxcopytile6502
	inx
	ldy	TMP2
	iny
	jmp	gfxprintstring_lab1
gfxprintstring_lab2:
	rts
.endproc


.proc	char2tile
	; copy the definition of a character to 2 tiles
	; in reg A -> ascii code to convert
	; in C2TTILEDATA -> pointer to tile definitions (to be filled)
	; in C2TCOLDATA -> color of tiles
	sta	C2TCHARDEFS
	lda	#>CHARDEFSDEFAULT
	sta	C2TCHARDEFS+1
	lda	#8
	sta	C2TCNT
	ldx	#0
	ldy	#0
char2tile_lab6:
	lda	(C2TCHARDEFS,x)
	sta	C2TCHARDATA
	jsr	char2tile_lab5
	lda	C2TTMPDATA
	sta	(C2TTILEDATA),y
	iny
	jsr	char2tile_lab5
	lda	C2TTMPDATA
	sta	(C2TTILEDATA),y
	tya
	clc
	adc	#15
	tay
	jsr	char2tile_lab5
	lda	C2TTMPDATA
	sta	(C2TTILEDATA),y
	iny
	jsr	char2tile_lab5
	lda	C2TTMPDATA
	sta	(C2TTILEDATA),y
	tya
	sec
	sbc	#15
	tay
	inc	C2TCHARDEFS+1
	dec	C2TCNT
	bne	char2tile_lab6
	rts
char2tile_lab5:
	lda	C2TCHARDATA
	rol
	sta	C2TCHARDATA
	bcc	char2tile_lab1
	lda	C2TCOLDATA
	and	#240
	sta	C2TTMPDATA
	jmp	char2tile_lab2
char2tile_lab1:
	lda	C2TCOLDATA
	asl
	asl
	asl
	asl
	sta	C2TTMPDATA
char2tile_lab2:
	lda	C2TCHARDATA
	rol
	sta	C2TCHARDATA
	bcc	char2tile_lab3
	lda	C2TCOLDATA
	lsr
	lsr
	lsr
	lsr
	ora	C2TTMPDATA
	sta	C2TTMPDATA
	rts
char2tile_lab3:
	lda	C2TCOLDATA
	and	#15
	ora	C2TTMPDATA
	sta	C2TTMPDATA
	rts
.endproc


;----------------------------------------------------------------------------
.data

DPCOLOR:
	.byte	0
DPBGCOLOR:
	.byte	0
GRCURX:
	.byte	0
GRCURY:
	.byte	0

tilesdef:
	.res	32 ; reserve space for one tile (for "graphic chars")
