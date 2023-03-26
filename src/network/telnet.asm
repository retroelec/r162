#include "6502def.inc"

; SPI message data ptr
data = 0
; string compare ptr
cmpstr = 2
; console read buffer
data2 = 4
; log activated?
logflag = 6
; number of chars in console read buffer
numchars = 7
; echo flag for read console
echo = 8
; pointer to next argument
argptr = 9

CMD_CONSOLEREAD = 6
CMD_CONSOLEWRITE = 7

; start of code
* = START6502CODE


; autostart program
jmp	start
.asc	"AUTO"

#include "spi.asm"


msgpassword:
	.asc	"Password: "
	.byt	0

msgtready:
	.byt	$54,$59,$44,$52
msgsready:
	.asc	"sready"
	.byt	0
msgcmdnotvalid:
	.asc	"command not valid"
	.byt	0


getnextarg:
	ldy	#0
getnextarg_lab10:
	inc	argptr
	bne	getnextarg_lab11
	inc	argptr+1
getnextarg_lab11:
	lda	(argptr),y
	bne	getnextarg_lab10
	inc	argptr
	bne	getnextarg_lab12
	inc	argptr+1
getnextarg_lab12:
	rts


; start of the program
start:
	; send "telnet ready"
	lda	#<msgtready
	sta	data
	lda	#>msgtready
	sta	data+1
	jsr	delay
	jsr	writeSpiStatus

	; wait for sready
	lda	#<buffer
	sta	data
	lda	#>buffer
	sta	data+1
	jsr	delay
	jsr	readSpiBuffer
	lda	#<msgsready
	sta	cmpstr
	lda	#>msgsready
	sta	cmpstr+1
	jsr	cmpstring
	bne	start
	ldx	#<msgsready
	ldy	#>msgsready
	callatm	printstring6502
	callatm	println6502

	; send ip
	lda	#<SHELLBUFFER
	sta	argptr
	lda	#>SHELLBUFFER
	sta	argptr+1
	jsr	getnextarg
	lda	argptr
	sta	data
	lda	argptr+1
	sta	data+1
	jsr	delay
	jsr	writeSpiBuffer

	; init.
	lda	#0
	sta	logflag
	sta	numchars
	lda	#1
	sta	echo
	lda	#<buffer
	sta	data
	lda	#>buffer
	sta	data+1
	lda	#<buffer2
	sta	data2
	lda	#>buffer2
	sta	data2+1

	; wait for cmd from ESP or input from user
lab11:
	; process user input
	jsr	processuserinput
lab12:
	; commands initiated by ESP
	ldy	#0
	tya
	sta	(data),y
	jsr	delay
	jsr	readSpiStatus
	ldy	#0
	lda	(data),y
	ora	#0
	beq	lab11
	cmp	#CMD_CONSOLEWRITE
	beq	cmdconswrite
	jmp	lab11


msgconswritefound:
	.asc	"console write command issued"
	.byt	0

cmdconswrite:
	lda	logflag
	beq	cmdconswrite_lab2
	ldx	#<msgconswritefound
	ldy	#>msgconswritefound
	callatm	printstring6502
	callatm	println6502
cmdconswrite_lab2:
	; receive data
	jsr	delay
	jsr	readSpiBuffer
	; received string "Password:"?
	lda	#<msgpassword
	sta	cmpstr
	lda	#>msgpassword
	sta	cmpstr+1
	jsr	cmpstring
	bne	cmdconswrite_lab3
	lda	#0
	sta	echo
cmdconswrite_lab3:
	; print data
	ldx	data
	ldy	data+1
	callatm	printstring6502
	jmp	lab11


processuisendpackage:
	dey
	lda	(data2),y
	sta	(data),y
	cpy	#0
	bne	processuisendpackage
	jsr	delay
	jsr	delay
	jsr	delay
	jmp	writeSpiBuffer

processuserinput:
	ldy	numchars
	; read byte from stdin
	callatm	getchnowait6502
	lda	RGETCH6502
	bne	processuserinput_lab2
	rts
processuserinput_lab2:
	ldx	echo
	beq	processuserinput_lab7
	callatm	printchar6502
processuserinput_lab7:
	sta	(data2),y
	cmp	#10
	beq	processuserinput_lab4
	iny
	sty	numchars
	bne	processuserinput_lab5
	dey
	dey
	dey
processuserinput_lab4:
	lda	#13
	sta	(data2),y
	iny
	lda	#10
	sta	(data2),y
	iny
	tya
	sta	numchars
	; send number of bytes read
	ldy	#1
	sta	(data),y
	dey
	lda	#CMD_CONSOLEREAD
	sta	(data),y
	jsr	delay
	jsr	writeSpiStatus
processuserinput_lab1:
	lda	numchars
	cmp	#32
	bcc	processuserinput_lab6
	sec
	sbc	#32
	sta	numchars
	; send data
	ldy	#32
	jsr	processuisendpackage
	jmp	processuserinput_lab1
processuserinput_lab6:
	; send last package
	tay
	jsr	processuisendpackage
	lda	#0
	sta	numchars
	lda	#1
	sta	echo
processuserinput_lab5:
	rts


buffer:
buffer2 = buffer + 256
