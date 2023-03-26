.include	"6502defcc.inc"
.include	"r162.inc"

.constructor	initmainargs, 24
.import		__argc, __argv

MAXARGS = 10

; Get possible command-line arguments. Goes into the special INIT segment,
; which may be reused after the startup code is run

.segment        "INIT"

initmainargs:
	lda	SHELLNUMARGS
	sta	__argc
	sta	TMP1
	inc	TMP1
	ldx	#255
	ldy	#0
	sty	__argc+1
initmainargs_lab2:
	inx
	txa
	clc
	adc	#<SHELLBUFFER
	sta	argv,y
	iny
	lda	#0
	adc	#>SHELLBUFFER
	sta	argv,y
	iny
	dec	TMP1
	beq	initmainargs_lab3
initmainargs_lab1:
	lda	SHELLBUFFER,x
	beq	initmainargs_lab2
	inx
	bne	initmainargs_lab1	; branch always
initmainargs_lab3:
	lda	#<argv
	ldx	#>argv
	sta	__argv
	stx	__argv+1
	rts

.data
argv:	.res MAXARGS*2
