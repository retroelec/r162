WBOYSAMPLESTCCR2 = 105
WBOYSAMPLESCONST1 = 2
WBOYSAMPLESCONST2 = 4
WBOYSAMPLESCONST3 = 5
SNDEFFECTCONST = 2

SNDWBOYS1FSIZE = 33628
SNDWBOYS2FSIZE = 16622
SNDEATFRUITFSIZE = 1332
SNDFIREFSIZE = 1458
SNDJUMPFSIZE = 1480
SNDWBOYDIESFSIZE = 2708
SNDENEMYDIESFSIZE = 1572
SNDSTONEFSIZE = 1390
SNDLEVELENDSFSIZE = 2022

SNDWBOYS1FMEM = TEXTMAPDEFAULT
SNDWBOYS2FMEM = SNDWBOYS1FMEM+SNDWBOYS1FSIZE
SNDEATFRUITFMEM = SNDWBOYS2FMEM+SNDWBOYS2FSIZE
SNDFIREFMEM = SNDEATFRUITFMEM+SNDEATFRUITFSIZE
SNDJUMPFMEM = SNDFIREFMEM+SNDFIREFSIZE
SNDWBOYDIESFMEM = SNDJUMPFMEM+SNDJUMPFSIZE
SNDENEMYDIESFMEM = SNDWBOYDIESFMEM+SNDWBOYDIESFSIZE
SNDSTONEFMEM = SNDENEMYDIESFMEM+SNDENEMYDIESFSIZE
SNDLEVELENDSFMEM = SNDSTONEFMEM+SNDSTONEFSIZE


sndwboys1fname:
.asc	"/DATA/WBOY/SNDWB1.ASD", 0
sndwboys2fname:
.asc	"/DATA/WBOY/SNDWB2.ASD", 0
sndeatfruitfname:
.asc	"/DATA/WBOY/SNDEATF.ASD", 0
sndfirefname:
.asc	"/DATA/WBOY/SNDFIRE.ASD", 0
sndjumpfname:
.asc	"/DATA/WBOY/SNDJUMP.ASD", 0
sndwboydiesfname:
.asc	"/DATA/WBOY/SNDWBD.ASD", 0
sndenemydiesfname:
.asc	"/DATA/WBOY/SNDENED.ASD", 0
sndstonefname:
.asc	"/DATA/WBOY/SNDSTONE.ASD", 0
sndlevelendsfname:
.asc	"/DATA/WBOY/SNDENDL.ASD", 0


loadsoundsamples:
	; Hi-Memory FS
	lda	#(1<<LOWHIMEMFS)
	sta	LOWHIMEM

	; Lade Sample 1
	lda	#<filestruct
	sta	loadfilestruct+FATLOADSAVE_FILE
	lda	#>filestruct
	sta	loadfilestruct+FATLOADSAVE_FILE+1
	lda	#<sndwboys1fname
	sta	loadfilestruct+FATLOADSAVE_NAME
	lda	#>sndwboys1fname
	sta	loadfilestruct+FATLOADSAVE_NAME+1
	lda	#<SNDWBOYS1FMEM
	sta	loadfilestruct+FATLOADSAVE_MEM
	lda	#>SNDWBOYS1FMEM
	sta	loadfilestruct+FATLOADSAVE_MEM+1
	ldx	#<loadfilestruct
	ldy	#>loadfilestruct
	callatm	fatload6502
	lda	RERRCODE6502
	beq	loadsoundsamples_lab1
	jmp	loaddataerror
loadsoundsamples_lab1:

	; Lade Sample 2
	lda	#<sndwboys2fname
	sta	loadfilestruct+FATLOADSAVE_NAME
	lda	#>sndwboys2fname
	sta	loadfilestruct+FATLOADSAVE_NAME+1
	lda	#<SNDWBOYS2FMEM
	sta	loadfilestruct+FATLOADSAVE_MEM
	lda	#>SNDWBOYS2FMEM
	sta	loadfilestruct+FATLOADSAVE_MEM+1
	ldx	#<loadfilestruct
	ldy	#>loadfilestruct
	callatm	fatload6502
	lda	RERRCODE6502
	beq	loadsoundsamples_lab2
	jmp	loaddataerror
loadsoundsamples_lab2:

	; Lade Sound-Effekt-Samples
	lda	#<sndeatfruitfname
	sta	loadfilestruct+FATLOADSAVE_NAME
	lda	#>sndeatfruitfname
	sta	loadfilestruct+FATLOADSAVE_NAME+1
	lda	#<SNDEATFRUITFMEM
	sta	loadfilestruct+FATLOADSAVE_MEM
	lda	#>SNDEATFRUITFMEM
	sta	loadfilestruct+FATLOADSAVE_MEM+1
	ldx	#<loadfilestruct
	ldy	#>loadfilestruct
	callatm	fatload6502
	lda	RERRCODE6502
	beq	loadsoundsamples_lab3
	jmp	loaddataerror
loadsoundsamples_lab3:

	lda	#<sndfirefname
	sta	loadfilestruct+FATLOADSAVE_NAME
	lda	#>sndfirefname
	sta	loadfilestruct+FATLOADSAVE_NAME+1
	lda	#<SNDFIREFMEM
	sta	loadfilestruct+FATLOADSAVE_MEM
	lda	#>SNDFIREFMEM
	sta	loadfilestruct+FATLOADSAVE_MEM+1
	ldx	#<loadfilestruct
	ldy	#>loadfilestruct
	callatm	fatload6502
	lda	RERRCODE6502
	beq	loadsoundsamples_lab4
	jmp	loaddataerror
loadsoundsamples_lab4:

	lda	#<sndjumpfname
	sta	loadfilestruct+FATLOADSAVE_NAME
	lda	#>sndjumpfname
	sta	loadfilestruct+FATLOADSAVE_NAME+1
	lda	#<SNDJUMPFMEM
	sta	loadfilestruct+FATLOADSAVE_MEM
	lda	#>SNDJUMPFMEM
	sta	loadfilestruct+FATLOADSAVE_MEM+1
	ldx	#<loadfilestruct
	ldy	#>loadfilestruct
	callatm	fatload6502
	lda	RERRCODE6502
	beq	loadsoundsamples_lab5
	jmp	loaddataerror
loadsoundsamples_lab5:

	lda	#<sndwboydiesfname
	sta	loadfilestruct+FATLOADSAVE_NAME
	lda	#>sndwboydiesfname
	sta	loadfilestruct+FATLOADSAVE_NAME+1
	lda	#<SNDWBOYDIESFMEM
	sta	loadfilestruct+FATLOADSAVE_MEM
	lda	#>SNDWBOYDIESFMEM
	sta	loadfilestruct+FATLOADSAVE_MEM+1
	ldx	#<loadfilestruct
	ldy	#>loadfilestruct
	callatm	fatload6502
	lda	RERRCODE6502
	beq	loadsoundsamples_lab6
	jmp	loaddataerror
loadsoundsamples_lab6:

	lda	#<sndenemydiesfname
	sta	loadfilestruct+FATLOADSAVE_NAME
	lda	#>sndenemydiesfname
	sta	loadfilestruct+FATLOADSAVE_NAME+1
	lda	#<SNDENEMYDIESFMEM
	sta	loadfilestruct+FATLOADSAVE_MEM
	lda	#>SNDENEMYDIESFMEM
	sta	loadfilestruct+FATLOADSAVE_MEM+1
	ldx	#<loadfilestruct
	ldy	#>loadfilestruct
	callatm	fatload6502
	lda	RERRCODE6502
	beq	loadsoundsamples_lab7
	jmp	loaddataerror
loadsoundsamples_lab7:

	lda	#<sndstonefname
	sta	loadfilestruct+FATLOADSAVE_NAME
	lda	#>sndstonefname
	sta	loadfilestruct+FATLOADSAVE_NAME+1
	lda	#<SNDSTONEFMEM
	sta	loadfilestruct+FATLOADSAVE_MEM
	lda	#>SNDSTONEFMEM
	sta	loadfilestruct+FATLOADSAVE_MEM+1
	ldx	#<loadfilestruct
	ldy	#>loadfilestruct
	callatm	fatload6502
	lda	RERRCODE6502
	beq	loadsoundsamples_lab9
	jmp	loaddataerror
loadsoundsamples_lab9:

	lda	#<sndlevelendsfname
	sta	loadfilestruct+FATLOADSAVE_NAME
	lda	#>sndlevelendsfname
	sta	loadfilestruct+FATLOADSAVE_NAME+1
	lda	#<SNDLEVELENDSFMEM
	sta	loadfilestruct+FATLOADSAVE_MEM
	lda	#>SNDLEVELENDSFMEM
	sta	loadfilestruct+FATLOADSAVE_MEM+1
	ldx	#<loadfilestruct
	ldy	#>loadfilestruct
	callatm	fatload6502
	lda	RERRCODE6502
	beq	loadsoundsamples_lab8
	jmp	loaddataerror
loadsoundsamples_lab8:

	; Initialisiere Auto-Sound
	lda	#(1<<LOWHIMEMSOUND)
	sta	LOWHIMEM
	rts


playbgmusic:
	; Sound einschalten
	lda	#WBOYSAMPLESTCCR2
	sta	SNDTCCR2

	lda	soundeffectflag
	bne	playbgmusic_lab2

playbgmusic_lab3:
	inc	autosndsamplenum
	lda	autosndsamplenum
	cmp	#5
	bcs	playbgmusic_lab1

	; play sample 1
	lda	#<(SNDWBOYS1FSIZE-4)
	sta	AUTOSNDCNT
	lda	#>(SNDWBOYS1FSIZE-4)
	sta	AUTOSNDCNT+1
	lda	#<(SNDWBOYS1FMEM+768+4)
	sta	AUTOSNDPTRP768
	lda	#>(SNDWBOYS1FMEM+768+4)
	sta	AUTOSNDPTRP768+1
	lda	#WBOYSAMPLESCONST1
	sta	AUTOSND
	sta	AUTOSNDSYNC
	rts

playbgmusic_lab1:
	lda	#0
	sta	autosndsamplenum

	; play sample 2
	lda	#<(SNDWBOYS2FSIZE-4)
	sta	AUTOSNDCNT
	lda	#>(SNDWBOYS2FSIZE-4)
	sta	AUTOSNDCNT+1
	lda	#<(SNDWBOYS2FMEM+768+4)
	sta	AUTOSNDPTRP768
	lda	#>(SNDWBOYS2FMEM+768+4)
	sta	AUTOSNDPTRP768+1
	lda	#WBOYSAMPLESCONST2
	sta	AUTOSND
	sta	AUTOSNDSYNC
	rts

playbgmusic_lab2:
	; Es wurde gerade ein Sound-Effekt abgespielt
	lda	#0
	sta	soundeffectflag
	lda	saveautosndarr
	sta	AUTOSNDCNT
	ora	saveautosndarr+1
	beq	playbgmusic_lab3
	lda	saveautosndarr+1
	sta	AUTOSNDCNT+1
	lda	saveautosndarr+2
	sta	AUTOSNDPTRP768
	lda	saveautosndarr+3
	sta	AUTOSNDPTRP768+1
	lda	saveautosndarr+4
	sta	AUTOSND
	rts


savebgmusicparams:
	lda	soundeffectlen+1
	cmp	AUTOSNDCNT+1
	bcs	savebgmusicparams_lab1
	; Laenge der Hintergrundmelodie um die Laenge des Soundeffekts verkuerzen
	sec
	lda	AUTOSNDCNT
	sbc	soundeffectlen
	sta	saveautosndarr
	lda	AUTOSNDCNT+1
	sbc	soundeffectlen+1
	sta	saveautosndarr+1
	clc
	lda	AUTOSNDPTRP768
	adc	soundeffectlen
	sta	saveautosndarr+2
	lda	AUTOSNDPTRP768+1
	adc	soundeffectlen+1
	sta	saveautosndarr+3
	lda	AUTOSND
	sta	saveautosndarr+4
	rts
savebgmusicparams_lab1:
	; Laenge des Soundeffekts ist groesser oder fast gleich gross wie die Laenge der Hintergrundmelodie
	; -> naechstes Sample der Hintergrundmelodie abspielen (wenn Soundeffekt beendet ist)
	lda	#0
	sta	saveautosndarr
	lda	#0
	sta	saveautosndarr+1
	rts
