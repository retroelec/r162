.include	"6502defcc.inc"
.include	"r162.inc"

.export	_r162load, _r162multicolmode, _r162textmode, _r162getjoykey, _r162getbytetime, _r162startbeep, _r162stopbeep, _r162sleep

.import	popa, popax

FATLSSTR_FILE = TMP1		; 2 Bytes
FATLSSTR_NAME = TMP3		; 2 Bytes
FATLSSTR_MEM = TMP5		; 2 Bytes
ACTLOWHIMEM = TMP7

; pointer to the file struct
fileptr:
	.res	6


.proc   _r162load
	; int __fastcall__ r162load(char* filename, unsigned char lohimem, unsigned char* addr);

	; get parameter addr (in a/x)
	sta	FATLSSTR_MEM
	stx	FATLSSTR_MEM+1

	; get parameter lohimem (on stack)
	lda	LOWHIMEM
	sta	ACTLOWHIMEM
	jsr	popa
	; low- or hi-memory FS
	ora	#0
	beq	@L1
	lda	#(1<<LOWHIMEMFS)
@L1:
	sta	LOWHIMEM

	; get filename
	jsr	popax
	sta	FATLSSTR_NAME
	stx	FATLSSTR_NAME+1

	; file struct
	lda	fileptr
	sta	FATLSSTR_FILE
	lda	fileptr+1
	sta	FATLSSTR_FILE+1

	; load file
	ldx	#<FATLSSTR_FILE
	ldy	#>FATLSSTR_FILE
	callatm fatload6502

	; return
	lda	ACTLOWHIMEM
	sta	LOWHIMEM
	lda	RERRCODE6502
	tax
	rts
.endproc


.proc   _r162multicolmode
	; void __fastcall__ r162multicolmode(unsigned char* addr, unsigned char startline, unsigned char endline);

	; get parameter endline (in a)
	sta	MODE2ENDLINE

	; get parameter startline (on stack)
	jsr	popa
	sta	MODE2STARTLINE

	; get addr
	jsr	popax
	clc
	adc	#<768
	sta	MCOLORMAPP768
	txa
	adc	#>768
	sta	MCOLORMAPP768+1

	; multicolor-data from hi-memory
	lda	#(1<<LOWHIMEMVIDEO)
	sta	LOWHIMEM

	; switch to multicolor mode
	lda	#2
	sta	VIDEOMODE

	; return
	rts
.endproc


.proc   _r162textmode
	; void r162textmode();

	; switch to text mode
	lda	#0
	sta	VIDEOMODE

	; return
	rts
.endproc


JOYKEYUP = 1
JOYKEYDOWN = 2
JOYKEYLEFT = 4
JOYKEYRIGHT = 8
JOYKEYY = 16
JOYKEYX = 32
JOYKEYC = 64
JOYKEYESC = 128

.proc   _r162getjoykey
	; unsigned char r162getjoykey();

	lda	#0
	sta	RGETCH6502
	lda	KEYPRARR+21
	beq	@L1
	lda	#JOYKEYUP
	sta	RGETCH6502
@L1:
	lda	KEYPRARR+18
	beq	@L2
	lda	#JOYKEYDOWN
	ora	RGETCH6502
	sta	RGETCH6502
@L2:
	lda	KEYPRARR+11
	beq	@L3
	lda	#JOYKEYLEFT
	ora	RGETCH6502
	sta	RGETCH6502
@L3:
	lda	KEYPRARR+20
	beq	@L4
	lda	#JOYKEYRIGHT
	ora	RGETCH6502
	sta	RGETCH6502
@L4:
	lda	KEYPRARR+26
	beq	@L5
	lda	#JOYKEYY
	ora	RGETCH6502
	sta	RGETCH6502
@L5:
	lda	KEYPRARR+2
	beq	@L6
	lda	#JOYKEYX
	ora	RGETCH6502
	sta	RGETCH6502
@L6:
	lda	KEYPRARR+22
	beq	@L7
	lda	#JOYKEYESC
	ora	RGETCH6502
	sta	RGETCH6502
@L7:
	lda	KEYPRARR+1
	beq	@L8
	lda	#JOYKEYC
	ora	RGETCH6502
	sta	RGETCH6502
@L8:
	ldx	#0
	lda	RGETCH6502
	rts
.endproc


.proc   _r162getbytetime
	; unsigned char r162getbytetime();

	lda	TIMER
	rts
.endproc


.proc   _r162startbeep
	; void __fastcall__ r162startbeep(unsigned char sndconst);

	sta	SNDOCR2
	lda	#30
	sta	SNDTCCR2
	rts
.endproc


.proc   _r162stopbeep
	; void r162stopbeep();

	lda	#0
	sta	SNDTCCR2
	rts
.endproc


TICKS = TMP1		; 2 Bytes

.proc   _r162sleep
	; void __fastcall__ r162sleep(int ticks);

	; get parameter ticks (in a/x)
	sta	TICKS
	txa
	sta	TICKS+1
	bne	@L1
	lda	TICKS
	cmp	#2
	bcc	@L4
@L1:
	lda	TIMER
	clc
	adc	TICKS
	sta	TICKS
	lda	TIMER+1
	adc	TICKS+1
	sta	TICKS+1
@L2:
	lda	TIMER+1
	cmp	TICKS+1
	bne	@L2
@L3:
	lda	TIMER
	cmp	TICKS
	bne	@L3
@L4:
	rts
.endproc
