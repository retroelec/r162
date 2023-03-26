.include	"6502defcc.inc"
.include	"r162.inc"

.export		_clock
.importzp	sreg

.proc	_clock
	; clear the timer high 16 bits
	ldy	#$00
	sty	sreg
	sty	sreg+1
	; read the timer
	lda	TIMER
	ldx	TIMER+1
	rts
.endproc
