; time_t _systime (void);
; /* Similar to time(), but:
;  *   - Is not ISO C
;  *   - Does not take the additional pointer
;  *   - Does not set errno when returning -1
;  */
;

.include	"6502defcc.inc"
.include        "time.inc"
.include        "r162.inc"

;----------------------------------------------------------------------------
.code

.proc	__systime
	lda	TIMER
	sta	RMUL6502
	lda	TIMER+1
	sta	RMUL6502+1
	; calc seconds
	lda	#50
	sta	RMUL6502+2
	lda	#0
	sta	RMUL6502+3
	callatm	div16x166502
	; calc minutes + seconds
	lda	#60
	sta	RMUL6502+2
	callatm	div16x166502
	lda	RMUL6502+2
	sta	TM + tm::tm_sec
	lda	RMUL6502
	sta	TM + tm::tm_min
	lda	#20
	sta	TM + tm::tm_hour
	lda	#<TM
	ldx	#>TM
	jmp	_mktime
.endproc

;----------------------------------------------------------------------------
; TM struct with date set to 2014-01-01
.data

TM:    	.word           0       ; tm_sec
        .word           0       ; tm_min
        .word           0       ; tm_hour
        .word           1       ; tm_mday
        .word           0       ; tm_mon
        .word           114     ; tm_year
        .word           0       ; tm_wday
        .word           0       ; tm_yday
        .word           0       ; tm_isdst

