#include "6502def.inc"

; SPI message data ptr
data = 0
; string compare ptr
cmpstr = 2
; mode (open file)
mode = 4
; number of bytes
numofbytes = 5
; log activated?
logflag = 6

CMD_OPEN = 1
CMD_READ = 2
CMD_WRITE = 3
CMD_CLOSE = 4
CMD_SIZE = 5
CMD_LS = 8
CMD_CD = 9
CMD_TOGGLELOG = 10

; start of code
* = START6502CODE


; autostart program
jmp	start
.asc	"AUTO"

#include "file.asm"
#include "spi.asm"

msgmready:
	.byt	$46,$59,$44,$52
msgsready:
	.asc	"sready"
	.byt	0
msgcmdnotvalid:
	.asc	"command not valid"
	.byt	0


; start of the program
start:
	; send mready
	lda	#<msgmready
	sta	data
	lda	#>msgmready
	sta	data+1
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

	; init.
	lda	#0
	sta	logflag
	jsr	_initfs
	lda	#<buffer
	sta	data
	lda	#>buffer
	sta	data+1

	; wait for cmd
lab11:
	ldy	#0
	tya
	sta	(data),y
	jsr	delay
	jsr	readSpiStatus
	ldy	#0
	lda	(data),y
	ora	#0
	beq	lab11
	cmp	#CMD_OPEN
	beq	labcmdopen
	cmp	#CMD_READ
	beq	labcmdread
	cmp	#CMD_WRITE
	beq	labcmdwrite
	cmp	#CMD_CLOSE
	beq	labcmdclose
	cmp	#CMD_SIZE
	beq	labcmdsize
	cmp	#CMD_LS
	beq	labcmdls
	cmp	#CMD_CD
	beq	labcmdcd
	cmp	#CMD_TOGGLELOG
	beq	labcmdtogglelog
	; not a valid command
	ldx	#<msgcmdnotvalid
	ldy	#>msgcmdnotvalid
	callatm	printstring6502
	callatm	println6502
	clc
	adc	#48
	callatm	printchar6502
	jmp	lab11
labcmdread:
	jmp	labcmdread0
labcmdwrite:
	jmp	labcmdwrite0
labcmdclose:
	jmp	labcmdclose0
labcmdsize:
	jmp	labcmdsize0
labcmdls:
	jmp	labcmdls0
labcmdcd:
	jmp	labcmdcd0
labcmdtogglelog:
	jmp	labcmdtogglelog0


msgopenfound:
	.asc	"open command issued"
	.byt	0

msgopenerror:
	.asc	"error opening file"
	.byt	0

labcmdopen:
	lda	logflag
	beq	labcmdopen_lab2
	ldx	#<msgopenfound
	ldy	#>msgopenfound
	callatm	printstring6502
	callatm	println6502
labcmdopen_lab2:
	; save mode
	ldy	#1
	lda	(data),y
	sta	mode
	; receive file name
	jsr	delay
	jsr	readSpiBuffer
	; open file
	lda	data
	sta	FATLSSTR_NAME
	lda	data+1
	sta	FATLSSTR_NAME+1
	lda	mode
	sta	MODE
	jsr	_open
	; file descriptor in reg a
	ldy	#1
	sta	(data),y
	cmp	#255
	bne	labcmdopen_lab1
	ldx	#<msgopenerror
	ldy	#>msgopenerror
	callatm	printstring6502
	callatm	println6502
labcmdopen_lab1:
	; send file descriptor
	ldy	#0
	tya
	sta	(data),y
	jsr	delay
	jsr	writeSpiStatus
	jmp	lab11


msgreadfound:
	.asc	"read command issued"
	.byt	0

msgreaderror:
	.asc	"error reading file"
	.byt	0

labcmdread0:
	lda	logflag
	beq	labcmdread_lab2
	ldx	#<msgreadfound
	ldy	#>msgreadfound
	callatm	printstring6502
	callatm	println6502
labcmdread_lab2:
	; get file descriptor
	ldy	#1
	lda	(data),y
	sta	FD
	; get number of bytes to read
	iny
	lda	(data),y
	sta	COUNT
	lda	#0
	sta	COUNT+1
	sta	COUNT+2
	; read file
	lda	data
	sta	MEMCPYSTR_DEST
	lda	data+1
	sta	MEMCPYSTR_DEST+1
	jsr	_read
	sta	numofbytes
	; number of bytes read in reg a
	cmp	#255
	bne	labcmdread_lab1
	ldx	#<msgreaderror
	ldy	#>msgreaderror
	callatm	printstring6502
	callatm	println6502
labcmdread_lab1:
	; send data
	jsr	writeSpiBuffer
	; send number of bytes read
	ldy	#0
	tya
	sta	(data),y
	iny
	lda	numofbytes
	sta	(data),y
	jsr	delay
	jsr	writeSpiStatus
	jmp	lab11


msgwritefound:
	.asc	"write command issued"
	.byt	0

msgwriteerror:
	.asc	"error writing file"
	.byt	0

labcmdwrite0:
	lda	logflag
	beq	labcmdwrite_lab2
	ldx	#<msgwritefound
	ldy	#>msgwritefound
	callatm	printstring6502
	callatm	println6502
labcmdwrite_lab2:
	; get file descriptor
	ldy	#1
	lda	(data),y
	sta	FD
	; get number of bytes to write
	iny
	lda	(data),y
	sta	COUNT
	lda	#0
	sta	COUNT+1
	sta	COUNT+2
	; receive data
	jsr	delay
	jsr	readSpiBuffer
	; write file
	lda	data
	sta	MEMCPYSTR_SRC
	lda	data+1
	sta	MEMCPYSTR_SRC+1
	jsr	_write
	sta	numofbytes
	; number of bytes written in reg a
	cmp	#255
	bne	labcmdwrite_lab1
	ldx	#<msgwriteerror
	ldy	#>msgwriteerror
	callatm	printstring6502
	callatm	println6502
labcmdwrite_lab1:
	; send number of bytes written
	ldy	#1
	lda	numofbytes
	sta	(data),y
	dey
	tya
	sta	(data),y
	jsr	writeSpiStatus
	jmp	lab11


msgclosefound:
	.asc	"close command issued"
	.byt	0

msgcloseerror:
	.asc	"error closing file"
	.byt	0

labcmdclose0:
	lda	logflag
	beq	labcmdclose_lab2
	ldx	#<msgclosefound
	ldy	#>msgclosefound
	callatm	printstring6502
	callatm	println6502
labcmdclose_lab2:
	; get file descriptor
	ldy	#1
	lda	(data),y
	sta	FILEDESCRIPTOR
	; close file
	jsr	_close
	; error code in reg a
	ldy	#1
	sta	(data),y
	cmp	#255
	bne	labcmdclose_lab1
	ldx	#<msgcloseerror
	ldy	#>msgcloseerror
	callatm	printstring6502
	callatm	println6502
labcmdclose_lab1:
	ldy	#0
	tya
	sta	(data),y
	; send error code
	jsr	delay
	jsr	writeSpiStatus
	jmp	lab11


msgsizefound:
	.asc	"size command issued"
	.byt	0

labcmdsize0:
	lda	logflag
	beq	labcmdsize_lab2
	ldx	#<msgsizefound
	ldy	#>msgsizefound
	callatm	printstring6502
	callatm	println6502
labcmdsize_lab2:
	; get file descriptor
	ldy	#1
	lda	(data),y
	; size file
	jsr	_getsize
	; size in SIZE
	ldy	#1
	lda	SIZE
	sta	(data),y
	iny
	lda	SIZE+1
	sta	(data),y
	iny
	lda	SIZE+2
	sta	(data),y
	ldy	#0
	tya
	sta	(data),y
	; send error code
	jsr	delay
	jsr	writeSpiStatus
	jmp	lab11


msglsfound:
	.asc	"ls command issued"
	.byt	0

labcmdls0:
	lda	logflag
	beq	labcmdls_lab2
	ldx	#<msglsfound
	ldy	#>msglsfound
	callatm	printstring6502
	callatm	println6502
labcmdls_lab2:
	lda	#<FATLSBUF
	sta	data
	lda	#>FATLSBUF+1
	sta	data+1
	callatm	fatls6502
	lda	RERRCODE6502
	beq	labcmdls_lab10
labcmdls_lab15:
	lda    #0
	tay
	sta	(data),y
	iny
	sta	(data),y
labcmdls_lab10:
	; send data package
	jsr	delay
	jsr	delay
	jsr	writeSpiBuffer
	ldy    #0
labcmdls_lab12:
	lda	(data),y
	beq	labcmdls_lab11
	iny
labcmdls_lab14:
	cpy	#32
	bne	labcmdls_lab12
	tya
	clc
	adc	data
	sta	data
	lda	data+1
	adc	#0
	sta	data+1
	jmp	labcmdls_lab10
labcmdls_lab13:
	lda	#<buffer
	sta	data
	lda	#>buffer
	sta	data+1
	jmp	lab11
labcmdls_lab11:
	iny
	cpy	#32
	beq	labcmdls_lab15
	lda	(data),y
	beq	labcmdls_lab13
	bne	labcmdls_lab14


msgcdfound:
	.asc	"cd command issued"
	.byt	0

labcmdcd0:
	lda	logflag
	beq	labcmdcd_lab2
	ldx	#<msgcdfound
	ldy	#>msgcdfound
	callatm	printstring6502
	callatm	println6502
labcmdcd_lab2:
	; receive dir name
	jsr	delay
	jsr	readSpiBuffer
	; cd dir
	lda	data
	tax
	lda	data+1
	tay
	callatm	fatcd6502
	; send file descriptor
	ldy	#0
	tya
	sta	(data),y
	iny
	lda	RERRCODE6502
	sta	(data),y
	jsr	delay
	jsr	writeSpiStatus
	jmp	lab11


msgtogglelog:
	.asc	"activate/deactivate logging"
	.byt	0

labcmdtogglelog0:
	ldx	#<msgtogglelog
	ldy	#>msgtogglelog
	callatm	printstring6502
	callatm	println6502
	; toggle flag
	lda	logflag
	eor	#1
	sta	logflag
	jmp	lab11


buffer:
