.include	"6502defcc.inc"

.export _clearscreen, _copyblockl, _copyblockr
.import popax

; void clearscreen(void);
_clearscreen:
	ldx	#<memfillstructtext
	ldy	#>memfillstructtext
	callatm	memfill6502
	rts

memfillstructtext:
.word	TEXTMAPDEFAULT
.byt	40,25,0


; void __fastcall__ copyblockl(char *srcaddr, char *destaddr, ushort len);
_copyblockl:
	; get parameter len (in a/x)
	sta	memcopystruct+4
	stx	memcopystruct+5
	; get parameter destaddr (on stack)
	jsr	popax
	sta	memcopystruct+2
	stx	memcopystruct+3
	; get parameter srcaddr (on stack)
	jsr	popax
	sta	memcopystruct+0
	stx	memcopystruct+1
	; copy
	ldx	#<memcopystruct
	ldy	#>memcopystruct
	callatm	memcopy6502
	rts

; void __fastcall__ copyblockr(char *srcaddr, char *destaddr, ushort len);
_copyblockr:
	; get parameter len (in a/x)
	sta	memcopystruct+4
	stx	memcopystruct+5
	; get parameter destaddr (on stack)
	jsr	popax
	sta	memcopystruct+2
	stx	memcopystruct+3
	; get parameter srcaddr (on stack)
	jsr	popax
	sta	memcopystruct+0
	stx	memcopystruct+1
	; copy
	ldx	#<memcopystruct
	ldy	#>memcopystruct
	callatm	memcopyr6502
	rts

memcopystruct:
.word	0,0,0
