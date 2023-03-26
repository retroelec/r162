; *** common ***

sreg = $11
TMP1            = $13          ; temp. var
TMP2            = $14          ; temp. var
TMP3            = $15          ; temp. var
TMP4            = $16          ; temp. var
TMP5            = $17          ; temp. var
TMP6            = $18          ; temp. var
TMP7            = $19          ; temp. var
TMP8            = $1A          ; temp. var
TMP9            = $1B          ; temp. var
TMP10           = $1C          ; temp. var
TMP11           = $1D          ; temp. var
TMP12           = $1E          ; temp. var
TMP13           = $1F          ; temp. var
TMP14           = $20          ; temp. var
TMP15           = $21          ; temp. var
TMP16           = $22          ; temp. var
TMP17           = $23          ; temp. var
TMP18           = $24          ; temp. var
TMP19           = $25          ; temp. var
TMP20           = $26          ; temp. var
TMP21           = $27          ; temp. var
TMP22           = $28          ; temp. var
TMP23           = $29          ; temp. var
TMP24           = $2A          ; temp. var
TMP25           = $2B          ; temp. var
TMP26           = $2C          ; temp. var
TMP27           = $2D          ; temp. var
TMP28           = $2E          ; temp. var
TMP29           = $2F          ; temp. var
TMP30           = $30          ; temp. var
TMP31           = $31          ; temp. var
TMP32           = $32          ; temp. var
TMP33           = $33          ; temp. var
TMP34           = $34          ; temp. var
TMP35           = $35          ; temp. var
TMP36           = $36          ; temp. var
TMP37           = $37          ; temp. var
TMP38           = $38          ; temp. var
TMP39           = $39          ; temp. var
TMP40           = $3A          ; temp. var
TMP41           = $3B          ; temp. var
TMP42           = $3C          ; temp. var

O_RDONLY = $01
O_WRONLY = $02

; maximum number of file descriptors
MAX_FDS = 3

; common variables
FATLSSTR_FILE = TMP1		; 2 Bytes
FATLSSTR_NAME = TMP3		; 2 Bytes
FATLSSTR_MEM = TMP5		; 2 Bytes
MODE = TMP7			; 1 Byte
FILEDESCRIPTOR = TMP8		; 1 Byte
AVAIL = TMP12			; 3 Bytes
SDRWSECTSTRUCT = TMP26		; 5 Bytes
BUFFER = TMP31			; 2 Bytes

; internal file structure
SIZEOFFILE = 535
FILE_FD = 0
FILE_ACTSECTINCLUST = 7
FILE_MODSIZE = 8
FILE_DIVSIZE = 10
FILE_MODE = 12
FILE_AVAILMODSIZE = 13
FILE_AVAILDIVSIZE = 15
FILE_DIRENTRYSECT = 17
FILE_DIRENTRYENTRY = 20
FILE_BUFFERIDX = 21
FILE_BUFFER = 23

; pointers to the file struct of the files
fdptr:	.word file1,file2,file3

; table to manage free files
fdtab:	.dsb MAX_FDS,0
; file structs
file1:	.dsb SIZEOFFILE,0
file2:	.dsb SIZEOFFILE,0
file3:	.dsb SIZEOFFILE,0


; *** open ***

SAVECHAR = TMP9
SAVECHARIDX = TMP10
FLAGISDOT = TMP17
NAMEPTRIDX = TMP18
BUFPTRIDX = TMP19

; *** read, write, seek ***

SEEK_CUR = 0
SEEK_END = 1
SEEK_SET = 2

FD = TMP8			; 1 Byte
NEWBUFFERIDX = TMP9		; 3 Bytes
COUNT = TMP15			; 3 Bytes
MEMCPYSTR_SRC = TMP18		; 6 Bytes
MEMCPYSTR_DEST = TMP18+2
MEMCPYSTR_N = TMP18+4
NUM = TMP24			; 2 Bytes
TEMP1 = TMP33			; 1 Byte
NUMSECFAT = TMP36		; 2 Bytes

OFFSET = COUNT			; 3 Bytes
TEMP = COUNT			; 3 Bytes
SIZE = TMP18			; 3 Bytes
ACTPOS = TMP21			; 3 Bytes
WHENCE = TMP24			; 1 Byte



; *** common ***

_initfs:
	; init. file system
	; in -> -
	; out -> -

	lda	#0
	tax
initfs_lab1:
	sta	fdtab,x
	inx
	cpx	#MAX_FDS
	bne	initfs_lab1
	rts


getfpfromfd:
	; get file pointer from file descriptor
	; in -> file descriptor in register a
	; out -> file pointer in FATLSSTR_FILE

	sec
	sbc	#3
	asl
	tax
	lda	fdptr,x
	sta	FATLSSTR_FILE
	lda	fdptr+1,x
	sta	FATLSSTR_FILE+1
	rts


freefd:
	; free file descriptor in register a
	; in -> file descriptor
	; out -> -

	sec
	sbc	#3
	tax
	lda	#0
	sta	fdtab,x
	rts


readdirentrysect:
	; read sector with directory entry
	; error code in RERRCODE6502

	ldy	#FILE_DIRENTRYSECT
	lda	(FATLSSTR_FILE),y
	sta	SDRWSECTSTRUCT+SDREADWRITESECTOR_NR
	iny
	lda	(FATLSSTR_FILE),y
	sta	SDRWSECTSTRUCT+SDREADWRITESECTOR_NR+1
	iny
	lda	(FATLSSTR_FILE),y
	sta	SDRWSECTSTRUCT+SDREADWRITESECTOR_NR+2
	lda	#<FATBUFFER
	sta	SDRWSECTSTRUCT+SDREADWRITESECTOR_MEM
	lda	#>FATBUFFER
	sta	SDRWSECTSTRUCT+SDREADWRITESECTOR_MEM+1
	ldx	#<SDRWSECTSTRUCT
	ldy	#>SDRWSECTSTRUCT
	callatm	sdreadsector6502
	lda	#<FATBUFFER
	sta	BUFFER
	lda	#>FATBUFFER
	sta	BUFFER+1
	ldy	#FILE_DIRENTRYENTRY
	lda	(FATLSSTR_FILE),y
	tay
	ldx	#32
	callatm	mul8x86502
	clc
	lda	RMUL6502
	adc	#<FATBUFFER
	sta	BUFFER
	lda	RMUL6502+1
	adc	#>FATBUFFER
	sta	BUFFER+1


writedirentrysect:
	; write sector with directory entry
	ldx	#<SDRWSECTSTRUCT
	ldy	#>SDRWSECTSTRUCT
	callatm	sdwritesector6502
	rts


__allocnewclust:
	; output -> cluster number in FATEMPTYCLUST6502
	; error code in RERRCODE6502

	; search for an empty cluster
	lda	#0
	sta	FATEMPTYCLUST6502+1
	lda	FATNUMSECFAT
	sta	NUMSECFAT
	lda	FATNUMSECFAT+1
	sta	NUMSECFAT+1
	lda	FATFATSTARTSECNR
	sta	SDRWSECTSTRUCT+SDREADWRITESECTOR_NR
	lda	FATFATSTARTSECNR+1
	sta	SDRWSECTSTRUCT+SDREADWRITESECTOR_NR+1
	lda	FATFATSTARTSECNR+2
	sta	SDRWSECTSTRUCT+SDREADWRITESECTOR_NR+2
	lda	#<FATBUFFER
	sta	SDRWSECTSTRUCT+SDREADWRITESECTOR_MEM
	lda	#>FATBUFFER
	sta	SDRWSECTSTRUCT+SDREADWRITESECTOR_MEM+1

lab20:
	ldx	#<SDRWSECTSTRUCT
	ldy	#>SDRWSECTSTRUCT
	callatm	sdreadsector6502
	lda	RERRCODE6502
	beq	lab21
	rts
lab21:
	lda	#<FATBUFFER
	sta	BUFFER
	lda	#>FATBUFFER
	sta	BUFFER+1
	ldx	#0
lab1:
	ldy	#0
	lda	(BUFFER),y
	sta	TEMP1
	iny
	lda	(BUFFER),y
	ora	TEMP1
	beq	lab4
	inc	BUFFER
	bne	lab2
	inc	BUFFER+1
lab2:
	inc	BUFFER
	bne	lab3
	inc	BUFFER+1
lab3:
	inx
	bne	lab1

	; no empty cluster found in this sector
	; -> read next FAT sector
	lda	NUMSECFAT
	bne	lab5
	lda	NUMSECFAT+1
	beq	lab6
	dec	NUMSECFAT+1
lab5:
	dec	NUMSECFAT
	inc	SDRWSECTSTRUCT+SDREADWRITESECTOR_NR
	bne	lab7
	inc	SDRWSECTSTRUCT+SDREADWRITESECTOR_NR+1
	bne	lab7
	sta	SDRWSECTSTRUCT+SDREADWRITESECTOR_NR+2
lab7:
	inc	FATEMPTYCLUST6502+1
	jmp	lab20
lab6:
	; no empty cluster found -> error
	lda	#255
	sta	RERRCODE6502
	rts

lab4:
	; empty cluster found -> occupy
	stx	FATEMPTYCLUST6502
	lda	#255
	sta	(BUFFER),y
	dey
	sta	(BUFFER),y
	ldx	#<SDRWSECTSTRUCT
	ldy	#>SDRWSECTSTRUCT
	callatm	sdwritesector6502
	rts


__addnewclusttofile:
	; output -> error code in RERRCODE6502

	; read sector with directory entry
	jsr	readdirentrysect
	lda	RERRCODE6502
	beq	lab31
	rts
lab31:

	lda	#0
	sta	FATRMFLAG6502
	ldx	#<FATLSSTR_FILE
	ldy	#>FATLSSTR_FILE
	callatm	fatrmorextcc6502
	lda	RERRCODE6502
	cmp	#FATINFOLASTCLUST
	beq	lab32
	rts

lab32:
	; extend file entry structure, set start cluster
	lda	FATEMPTYCLUST6502
	ldy	#26
	sta	(BUFFER),y
	ldy	#FILESTARTCLUST
	sta	(FATLSSTR_FILE),y
	lda	FATEMPTYCLUST6502+1
	ldy	#27
	sta	(BUFFER),y
	ldy	#FILESTARTCLUST+1
	sta	(FATLSSTR_FILE),y

	; write sector with directory entry
	jmp	writedirentrysect


__writesizetofile:
	; output -> error code in RERRCODE6502

	; read sector with directory entry
	jsr	readdirentrysect
	lda	RERRCODE6502
	beq	lab33
	rts
lab33:

	; file size
	jsr	__getsize
	ldy	#28
	lda	SIZE
	sta	(BUFFER),y
	iny
	lda	SIZE+1
	sta	(BUFFER),y
	iny
	lda	SIZE+2
	sta	(BUFFER),y

	; write sector with directory entry
	jmp	writedirentrysect


__writesector:
	ldx	#<FATLSSTR_FILE
	ldy	#>FATLSSTR_FILE
	callatm	fatwritenextsector6502
	lda	RERRCODE6502
	beq	lab41
	cmp	#FATINFOLASTCLUST
	bne	lab41
	; last cluster -> extend file
	jsr	__allocnewclust
	lda	RERRCODE6502
	bne	lab41
	jsr	__addnewclusttofile
	lda	RERRCODE6502
	beq	lab42
	cmp	#FATINFOLASTCLUST
	beq	lab42
	rts
lab42:
	ldx	#<FATLSSTR_FILE
	ldy	#>FATLSSTR_FILE
	callatm	fatwritenextsector6502
lab41:
	rts


; *** open ***

_open:
	; int __fastcall__ open(const char* name, int flags, ...);
	; input -> MODE, FATLSSTR_NAME

	; test for valid file name
	ldy	#255
labopen31:
	iny
	lda	(FATLSSTR_NAME),y
	bne	labopen31
	tya
	beq	labopen0
	dey
	lda	(FATLSSTR_NAME),y
	cmp	#'/'
	beq	labopen0

	; test mode
	lda	MODE
	cmp	#O_RDONLY
	beq	labopen1
	cmp	#O_WRONLY
	beq	labopen1
	; mode not allowed

labopen0:
	; error -> return -1
	lda	#$FF
	tax
	rts

labopen1:
	; get free file descriptor
	ldx	#0
	clc
labopen6:
	lda	fdtab,x
	beq	labopen7
	inx
	cpx	#MAX_FDS
	bcc	labopen6
	jmp	labopen0
labopen7:
	txa
	adc	#3
	sta	fdtab,x
	sta	FILEDESCRIPTOR

	; open file
	jsr	getfpfromfd
        ldx     #<FATLSSTR_FILE
        ldy     #>FATLSSTR_FILE
        callatm fatopen6502
        lda     RERRCODE6502
        beq     labopen2
	lda	MODE
	cmp	#O_WRONLY
	bne	labopen9
	cmp	#FATERRFNF
	beq	labopen8
labopen9:
	jsr	freefd
	jmp	labopen0
labopen8:
	; create a new file
	jmp	labopen10
labopen2:
	; init. file structure
	ldy	#FILE_MODE
	lda	MODE
	sta	(FATLSSTR_FILE),y
	cmp	#O_WRONLY
	beq	labopen15
	; read mode only -> set available bytes
	ldy	#FILE_DIVSIZE
	lda	(FATLSSTR_FILE),y
	ldy	#FILE_AVAILDIVSIZE
	sta	(FATLSSTR_FILE),y
	ldy	#FILE_DIVSIZE+1
	lda	(FATLSSTR_FILE),y
	ldy	#FILE_AVAILDIVSIZE+1
	sta	(FATLSSTR_FILE),y
	ldy	#FILE_MODSIZE
	lda	(FATLSSTR_FILE),y
	ldy	#FILE_AVAILMODSIZE
	sta	(FATLSSTR_FILE),y
	ldy	#FILE_MODSIZE+1
	lda	(FATLSSTR_FILE),y
	ldy	#FILE_AVAILMODSIZE+1
	sta	(FATLSSTR_FILE),y
	jmp	labopen16
labopen15:
	; write mode only -> set size to 0
	lda	#0
	ldy	#FILE_MODSIZE
	sta	(FATLSSTR_FILE),y
	iny
	sta	(FATLSSTR_FILE),y
	ldy	#FILE_DIVSIZE
	sta	(FATLSSTR_FILE),y
	iny
	sta	(FATLSSTR_FILE),y
	; write mode only -> set dir. entry info
	lda	FATOPENACTSECT6502
	ldy	#FILE_DIRENTRYSECT
	sta	(FATLSSTR_FILE),y
	lda	FATOPENACTSECT6502+1
	iny
	sta	(FATLSSTR_FILE),y
	lda	FATOPENACTSECT6502+2
	iny
	sta	(FATLSSTR_FILE),y
	lda	FATOPENACTENTRY6502
	ldy	#FILE_DIRENTRYENTRY
	sta	(FATLSSTR_FILE),y
labopen16:
	; read + write mode -> set buffer index
	ldy	#FILE_BUFFERIDX
	lda	#0
	sta	(FATLSSTR_FILE),y
	iny
	lda	MODE
	cmp	#O_RDONLY
	beq	labopen4
	lda	#0
	sta	(FATLSSTR_FILE),y
	; branch always
	beq	labopen5
labopen4:
	lda	#2
	sta	(FATLSSTR_FILE),y
labopen5:

	; return file descriptor
	lda	FILEDESCRIPTOR
	ldx	#0
	rts

labopen10:
	; get file name position (without directory path)
	ldy	#0
	; search end of filename (incl. path)
labopen27:
	iny
	beq	labopen30
	lda	(FATLSSTR_NAME),y
	bne	labopen27
	; search backwards for '/'
labopen28:
	dey
	beq	labopen29
	lda	(FATLSSTR_NAME),y
	cmp	#'/'
	bne	labopen28
	iny
labopen29:
	sty	SAVECHARIDX

	; search for an empty entry
	lda	(FATLSSTR_NAME),y
	sta	SAVECHAR
	lda	#0
	sta	(FATLSSTR_NAME),y
        ldx     #<FATLSSTR_FILE
        ldy     #>FATLSSTR_FILE
	callatm	fatopen6502
	ldy	SAVECHARIDX
	lda	SAVECHAR
	sta	(FATLSSTR_NAME),y
	lda	RERRCODE6502
	beq	labopen17
labopen30:
	jmp	labopen9
labopen17:

	; fill empty entry
	ldx	#32
	ldy	FATOPENACTENTRY6502
	callatm	mul8x86502
	clc
	lda	RMUL6502
	adc	#<FATBUFFER
	sta	BUFFER
	lda	RMUL6502+1
	adc	#>FATBUFFER
	sta	BUFFER+1
	; name of file
	ldy	SAVECHARIDX
	jsr	__setfilename
	; init. other fields
	lda	#0
	ldy	#11
labopen12:
	sta	(BUFFER),y
	iny
	cpy	#32
	bne	labopen12
	; creation date 2013-12-01
	lda	#129
	ldy	#16
	sta	(BUFFER),y
	lda	#67
	iny
	sta	(BUFFER),y
	; access date 2013-12-01
	lda	#129
	ldy	#18
	sta	(BUFFER),y
	lda	#67
	iny
	sta	(BUFFER),y
	; change date 2013-12-01
	lda	#129
	ldy	#24
	sta	(BUFFER),y
	lda	#67
	iny
	sta	(BUFFER),y
	; init. start cluster
	lda	#255
	ldy	#26
	sta	(BUFFER),y
	iny
	sta	(BUFFER),y

	; write sector with directory entry
	lda	FATOPENACTSECT6502
	sta	SDRWSECTSTRUCT+SDREADWRITESECTOR_NR
	lda	FATOPENACTSECT6502+1
	sta	SDRWSECTSTRUCT+SDREADWRITESECTOR_NR+1
	lda	FATOPENACTSECT6502+2
	sta	SDRWSECTSTRUCT+SDREADWRITESECTOR_NR+2
	lda	#<FATBUFFER
	sta	SDRWSECTSTRUCT+SDREADWRITESECTOR_MEM
	lda	#>FATBUFFER
	sta	SDRWSECTSTRUCT+SDREADWRITESECTOR_MEM+1
	ldx	#<SDRWSECTSTRUCT
	ldy	#>SDRWSECTSTRUCT
	callatm	sdwritesector6502
	lda	RERRCODE6502
	beq	labopen13
	jmp	labopen9
labopen13:
	; open created file
        ldx     #<FATLSSTR_FILE
        ldy     #>FATLSSTR_FILE
        callatm fatopen6502
        lda     RERRCODE6502
        beq     labopen14
	jmp	labopen9
labopen14:
	jmp	labopen2


__setfilename:
	sty	NAMEPTRIDX
	ldy	#0
	sty	BUFPTRIDX
lab52:
	; set file name
	ldy	NAMEPTRIDX
	lda	(FATLSSTR_NAME),y
	beq	lab51
	cmp	#'.'
	beq	lab51
	ldy	BUFPTRIDX
	sta	(BUFFER),y
	inc	NAMEPTRIDX
	inc	BUFPTRIDX
	ldy	BUFPTRIDX
	cpy	#8
	bne	lab52
	ldy	NAMEPTRIDX
	lda	(FATLSSTR_NAME),y
	cmp	#'.'
	beq	lab53
	jmp	lab56
lab51:
	sta	FLAGISDOT
	lda	#' '
	ldy	BUFPTRIDX
lab54:
	sta	(BUFFER),y
	iny
	cpy	#8
	bne	lab54
	sty	BUFPTRIDX
	lda	FLAGISDOT
	beq	lab56
lab53:
	inc	NAMEPTRIDX
	ldy	NAMEPTRIDX
	lda	(FATLSSTR_NAME),y
	beq	lab56
	ldy	BUFPTRIDX
	sta	(BUFFER),y
	inc	BUFPTRIDX
	cpy	#10
	bne	lab53
	rts
lab56:
	lda	#' '
	ldy	BUFPTRIDX
lab59:
	sta	(BUFFER),y
	iny
	cpy	#11
	bne	lab59
	rts


; *** close ***

_close:
	; int __fastcall__ close(int fd);
	; input -> FILEDESCRIPTOR

	; get file from fd
	lda	FILEDESCRIPTOR
	cmp	#3
	bcc	lab62
	jsr	getfpfromfd

	; mode -> read or write?
	ldy	#FILE_MODE
	lda	(FATLSSTR_FILE),y
	cmp	#O_RDONLY
	beq	lab61

	; write mode -> write buffer to file
	lda	FATLSSTR_FILE
	clc
	adc	#FILE_BUFFER
	sta	FATLSSTR_MEM
	lda	FATLSSTR_FILE+1
	adc	#0
	sta	FATLSSTR_MEM+1
	jsr	__writesector
	lda	RERRCODE6502
	bne	lab62
	; set size of file
	jsr	__writesizetofile
	lda	RERRCODE6502
	bne	lab62

lab61:
	; free file descriptor
	lda	FILEDESCRIPTOR
	jsr	freefd

	; return OK
	lda	#0
	tax
	rts

lab62:
	; free file descriptor
	lda	FILEDESCRIPTOR
	jsr	freefd

	; return ERROR
	lda	#$FF
	tax
	rts


; *** read, write, seek ***

__getwritedest:
	; fp->buffer + fp->bufferidx in MEMCPYSTR_DEST
	lda	FATLSSTR_FILE
	clc
	adc	#FILE_BUFFER
	sta	MEMCPYSTR_DEST
	lda	FATLSSTR_FILE+1
	adc	#0
	sta	MEMCPYSTR_DEST+1
	ldy	#FILE_BUFFERIDX
	lda	MEMCPYSTR_DEST
	clc
	adc	(FATLSSTR_FILE),y
	sta	MEMCPYSTR_DEST
	iny
	lda	MEMCPYSTR_DEST+1
	adc	(FATLSSTR_FILE),y
	sta	MEMCPYSTR_DEST+1
	rts


__getreadsrc:
	; fp->buffer + fp->bufferidx in MEMCPYSTR_SRC
	lda	FATLSSTR_FILE
	clc
	adc	#FILE_BUFFER
	sta	MEMCPYSTR_SRC
	lda	FATLSSTR_FILE+1
	adc	#0
	sta	MEMCPYSTR_SRC+1
	ldy	#FILE_BUFFERIDX
	lda	MEMCPYSTR_SRC
	clc
	adc	(FATLSSTR_FILE),y
	sta	MEMCPYSTR_SRC
	iny
	lda	MEMCPYSTR_SRC+1
	adc	(FATLSSTR_FILE),y
	sta	MEMCPYSTR_SRC+1
	rts


__getparams:
	; get parameter count (in a/x)
	sta	COUNT
	stx	COUNT+1
	lda	#0
	sta	COUNT+2

	; get parameter buf (on stack)
	pla
	tax
	pla
	ldy	MODE
	beq	lab71
	sta     MEMCPYSTR_SRC
	stx     MEMCPYSTR_SRC+1
	; branch always
	bne	lab72
lab71:
	sta     MEMCPYSTR_DEST
	stx     MEMCPYSTR_DEST+1
lab72:

	; get parameter fd (on stack)
	pla
	tax
	pla
	sta	FD
	rts


__getavail:
	; int avail = 512*(fp->availdivsize) + fp->availmodsize;
	ldy	#FILE_AVAILMODSIZE
	lda	(FATLSSTR_FILE),y
	sta	AVAIL
	ldy	#FILE_AVAILDIVSIZE
	lda	(FATLSSTR_FILE),y
	asl
	ldy	#FILE_AVAILMODSIZE+1
	ora	(FATLSSTR_FILE),y
	sta	AVAIL+1
	ldy	#FILE_AVAILDIVSIZE+1
	lda	(FATLSSTR_FILE),y
	rol
	sta	AVAIL+2
	rts


;int readwriteseek6502(int fd, char* buf, int count, int mode) {
;  int i;
;  struct file6502* file;
;  int newbufferidx;
;  int avail;
;  int size;
;
;  i = fd-3;
;  file = fdptr[i];
;  if (mode != 1) {
;    avail = 512*(file->availdivsize) + file->availmodsize;
;    if (avail < count) count = avail;
;  }
;  newbufferidx = file->bufferidx + count;
;  while (newbufferidx >= 512) {
;    if (mode == 0)
;      // read
;      memcpy(buf, file->buffer + file->bufferidx, 512 - file->bufferidx);
;    else if (mode == 1)
;      // write
;      memcpy(file->buffer + file->bufferidx, buf, 512 - file->bufferidx);
;    buf += 512 - file->bufferidx;
;    if ((mode == 0) || (mode == 2))
;      // read
;      fread(file->buffer, 512, 1, file->f);
;    else if (mode == 1)
;      // write
;      fwrite(file->buffer, 512, 1, file->f);
;    file->bufferidx = 0;
;    newbufferidx -= 512;
;  }
;  if (mode == 0)
;    // read
;    memcpy(buf, file->buffer + file->bufferidx, newbufferidx - file->bufferidx);
;  else if (mode == 1)
;    // write
;    memcpy(file->buffer + file->bufferidx, buf, newbufferidx - file->bufferidx);
;  file->bufferidx = newbufferidx;
;  if (mode != 1) {
;    avail -= count;
;    file->availdivsize = avail/512;
;    file->availmodsize = avail%512;
;  }
;  else {
;    size = 512*(file->divsize) + file->modsize;
;    size += count;
;    file->divsize = size/512;
;    file->modsize = size%512;
;  }
;  return count;
;}

__readwriteseek:
	; get file from fd
	lda	FD
	jsr	getfpfromfd

	; test if file is NULL
	lda	FATLSSTR_FILE
	ora	FATLSSTR_FILE+1
	bne	labF1

labF0:
	; error -> return -1
	lda	#$FF
	tax
	rts

labF16:
	; end of file -> return 0
	tax
	rts

labF1:
	; if (mode != 1) {
	lda	MODE
	cmp	#1
	beq	labF20

	jsr	__getavail

	; avail == 0?
	lda	AVAIL
	ora	AVAIL+1
	ora	AVAIL+2
	beq	labF16

	; if (avail < count) count = avail;
	lda	COUNT+2
	cmp	AVAIL+2
	bcc	labF20
	bne	labF22
	lda	AVAIL+2
	bne	labF20
	lda	COUNT+1
	cmp	AVAIL+1
	bcc	labF20
	bne	labF22
	lda	AVAIL
	cmp	COUNT
	bcs	labF20
labF22:
	lda	AVAIL+2
	sta	COUNT+2
	lda	AVAIL+1
	sta	COUNT+1
	lda	AVAIL
	sta	COUNT
	; }
labF20:

	; int newbufferidx = fp->bufferidx + count;
	ldy	#FILE_BUFFERIDX
	lda	(FATLSSTR_FILE),y
	clc
	adc	COUNT
	sta	NEWBUFFERIDX
	iny
	lda	(FATLSSTR_FILE),y
	adc	COUNT+1
	sta	NEWBUFFERIDX+1
	lda	#0
	adc	COUNT+2
	sta	NEWBUFFERIDX+2

	; while (newbufferidx >= 512) {
labF2:
	lda	NEWBUFFERIDX+2
	bne	labF3
	lda	NEWBUFFERIDX+1
	cmp	#2
	bcs	labF3
	jmp	labF10
labF3:

	; (512 - fp->bufferidx) > 0?
	ldy	#FILE_BUFFERIDX
	lda	#0
	sec
	sbc	(FATLSSTR_FILE),y
	sta	MEMCPYSTR_N
	iny
	lda	#2
	sbc	(FATLSSTR_FILE),y
	sta	MEMCPYSTR_N+1
	ora	MEMCPYSTR_N
	beq	labF14

	; read or write or seek?
	lda	MODE
	beq	labF4
	cmp	#1
	bne	labF14

	; write
	;   memcpy(fp->buffer + fp->bufferidx, buf, 512 - fp->bufferidx);
	jsr	__getwritedest
	jmp	labF5

labF4:
	; read
	;   memcpy(buf, fp->buffer + fp->bufferidx, 512 - fp->bufferidx);
	jsr	__getreadsrc

labF5:
	ldx	#<MEMCPYSTR_SRC
	ldy	#>MEMCPYSTR_SRC
	callatm	memcopy6502

	;   buf += 512 - fp->bufferidx;
	lda	MODE
	beq	labF13
	lda	MEMCPYSTR_SRC
	clc
	adc	MEMCPYSTR_N
	sta	MEMCPYSTR_SRC
	lda	MEMCPYSTR_SRC+1
	adc	MEMCPYSTR_N+1
	sta	MEMCPYSTR_SRC+1
	jmp	labF14
labF13:
	lda	MEMCPYSTR_DEST
	clc
	adc	MEMCPYSTR_N
	sta	MEMCPYSTR_DEST
	lda	MEMCPYSTR_DEST+1
	adc	MEMCPYSTR_N+1
	sta	MEMCPYSTR_DEST+1
labF14:

	;   write(fp->buffer, 512, fp->f);
	; resp.
	;   read(fp->buffer, 512, fp->f);
	lda	FATLSSTR_FILE
	clc
	adc	#FILE_BUFFER
	sta	FATLSSTR_MEM
	lda	FATLSSTR_FILE+1
	adc	#0
	sta	FATLSSTR_MEM+1

	; read or write?
	lda	MODE
	cmp	#1
	bne	labF6

	; write
	jsr	__writesector
	jmp	labF7

labF6:
	; read
	ldx	#<FATLSSTR_FILE
	ldy	#>FATLSSTR_FILE
	lda	#0
	callatm	fatreadnextsector6502

labF7:
	lda	RERRCODE6502
	beq	labF15
	cmp	#FATINFOLASTCLUST
	beq	labF15
labF30:
	; error -> return -1
	jmp	labF0

labF15:
	;   fp->bufferidx = 0;
	ldy	#FILE_BUFFERIDX
	lda	#0
	sta	(FATLSSTR_FILE),y
	iny
	sta	(FATLSSTR_FILE),y

	;   newbufferidx -= 512;
	lda	NEWBUFFERIDX+1
	sec
	sbc	#2
	sta	NEWBUFFERIDX+1
	lda	NEWBUFFERIDX+2
	sbc	#0
	sta	NEWBUFFERIDX+2
	; }
	jmp	labF2

labF10:
	; (newbufferidx - fp->bufferidx) > 0? (newbufferidx < 512)!
	ldy	#FILE_BUFFERIDX
	lda	NEWBUFFERIDX
	sec
	sbc	(FATLSSTR_FILE),y
	sta	MEMCPYSTR_N
	iny
	lda	NEWBUFFERIDX+1
	sbc	(FATLSSTR_FILE),y
	sta	MEMCPYSTR_N+1
	ora	MEMCPYSTR_N
	beq	labF17

	; read or write or seek?
	lda	MODE
	beq	labF8
	cmp	#1
	bne	labF17

	; write
	; memcpy(fp->buffer + fp->bufferidx, buf, newbufferidx - fp->bufferidx);
	jsr	__getwritedest
	jmp	labF9

labF8:
	; read
	; memcpy(buf, fp->buffer + fp->bufferidx, newbufferidx - fp->bufferidx);
	jsr	__getreadsrc

labF9:
	ldx	#<MEMCPYSTR_SRC
	ldy	#>MEMCPYSTR_SRC
	callatm	memcopy6502

labF17:
	; fp->bufferidx = newbufferidx;
	ldy	#FILE_BUFFERIDX
	lda	NEWBUFFERIDX
	sta	(FATLSSTR_FILE),y
	iny
	lda	NEWBUFFERIDX+1
	sta	(FATLSSTR_FILE),y

	; if (mode != 1) {
	lda	MODE
	cmp	#1
	beq	labF18

	; avail -= count;
	lda	AVAIL
	sec
	sbc	COUNT
	sta	AVAIL
	lda	AVAIL+1
	sbc	COUNT+1
	sta	AVAIL+1
	lda	AVAIL+2
	sbc	COUNT+2
	sta	AVAIL+2

	; fp->availdivsize = avail/512;
	; fp->availmodsize = avail%512;
	lda	AVAIL+2
	lsr
	ldy	#FILE_AVAILDIVSIZE+1
	sta	(FATLSSTR_FILE),y
	lda	AVAIL+1
	ror
	ldy	#FILE_AVAILDIVSIZE
	sta	(FATLSSTR_FILE),y
	lda	#0
	rol
	ldy	#FILE_AVAILMODSIZE+1
	sta	(FATLSSTR_FILE),y
	lda	AVAIL
	ldy	#FILE_AVAILMODSIZE
	sta	(FATLSSTR_FILE),y
	jmp	labF19

	; else {
labF18:
	;   size = 512*(file->divsize) + file->modsize;
	jsr	__getsize

	;   size += count;
	lda	SIZE
	clc
	adc	COUNT
	sta	SIZE
	lda	SIZE+1
	adc	COUNT+1
	sta	SIZE+1
	lda	SIZE+2
	adc	COUNT+2
	sta	SIZE+2

	; fp->divsize = size/512;
	; fp->modsize = size%512;
	lda	SIZE+2
	lsr
	ldy	#FILE_DIVSIZE+1
	sta	(FATLSSTR_FILE),y
	lda	SIZE+1
	ror
	ldy	#FILE_DIVSIZE
	sta	(FATLSSTR_FILE),y
	lda	#0
	rol
	ldy	#FILE_MODSIZE+1
	sta	(FATLSSTR_FILE),y
	lda	SIZE
	ldy	#FILE_MODSIZE
	sta	(FATLSSTR_FILE),y
labF19:

	; return count; (only for read and write)
	lda	COUNT
	ldx	COUNT+1
	rts


;int read6502(int fd, char* buf, int count) {
;  if ((fd < 0) || (fd > MAX_FDS+3)) return -1;
;  return readwriteseek6502(fd, buf, count, 0);
;}

_read:
	; int __fastcall__ read(int fd, void* buf, unsigned count);

	ldy	#0
	sty	MODE
	; input -> COUNT, MEMCPYSTR_DEST, FD
	; jsr	__getparams

	; file read or read from stdin?
	lda	FD
	cmp	#3
	bcs	labR4
	lda	FD
	bne	labR2

	; copy COUNT to NUM
	lda	COUNT
	sta	NUM
	lda	COUNT+1
	sta	NUM+1

	; count == 0?
	ora	COUNT
	beq	labR3

	; read byte from stdin
	ldy	#0
labR0:
	callatm	getchwait6502
	lda	RGETCH6502
	callatm	printchar6502
	sta	(MEMCPYSTR_DEST),y
	inc	MEMCPYSTR_DEST
	bne	labR1
	inc	MEMCPYSTR_DEST+1
labR1:

	; next byte
	dec	COUNT
	bne	labR0
	lda	COUNT+1
	beq	labR3
	dec	COUNT+1
	jmp	labR0

labR3:
	; return number of bytes read
	lda	NUM
	ldx	NUM+1
	rts

labR2:
	; invalid file descriptor
	; error -> return -1
	lda	#$FF
	tax
	rts

labR4:
	cmp	#(MAX_FDS+3)
	bcs	labR2
	jmp	__readwriteseek


;int write6502(int fd, char* buf, int count) {
;  if ((fd < 0) || (fd > MAX_FDS+3)) return -1;
;  return readwriteseek6502(fd, buf, count, 1);
;}

_write:
	; int __fastcall__ write(int fd, void* buf, unsigned count);

	ldy	#1
	sty	MODE
	; input -> COUNT, MEMCPYSTR_SRC, FD
	; jsr	__getparams

	; file write or write to stdout/stderr?
	lda	FD
	beq	labW2
	cmp	#3
	bcs	labW4

	; copy COUNT to NUM
	lda	COUNT
	sta	NUM
	lda	COUNT+1
	sta	NUM+1

	; count == 0?
	ora	COUNT
	beq	labW3

	; write byte to stdout or stderr
	ldy	#0
labW0:
	lda	(MEMCPYSTR_SRC),y
	inc	MEMCPYSTR_SRC
	bne	labW1
	inc	MEMCPYSTR_SRC+1
labW1:
	callatm	printchar6502

	; next byte
	dec	COUNT
	bne	labW0
	lda	COUNT+1
	beq	labW3
	dec	COUNT+1
	jmp	labW0

labW3:
	; return number of bytes written
	lda	NUM
	ldx	NUM+1
	rts

labW2:
	; invalid file descriptor
	; error -> return -1
	lda	#$FF
	tax
	rts

labW4:
	cmp	#(MAX_FDS+3)
	bcs	labW2
	jmp	__readwriteseek


;void rewind6502(struct file6502* file) {
;  int flags;
;
;  rewind(file->f);
;
;  flags = file->mode;
;  if (flags == O_RDONLY) {
;    file->bufferidx = 512;
;  }
;  else if (flags == O_WRONLY) {
;    file->bufferidx = 0;
;  }
;  file->availdivsize = file->divsize;
;  file->availmodsize = file->modsize;
;}

__rewind:
	;  rewind(file->f);
	lda	#255
	ldy	#FILE_ACTSECTINCLUST
	sta	(FATLSSTR_FILE),y

	;  flags = file->mode;
	ldy	#FILE_MODE
	lda	(FATLSSTR_FILE),y
	;  if (flags == O_RDONLY) {
	cmp	#O_RDONLY
	bne	lab73
	;    file->bufferidx = 512;
	ldy	#FILE_BUFFERIDX
	lda	#0
	sta	(FATLSSTR_FILE),y
	iny
	lda	#2
	sta	(FATLSSTR_FILE),y
	;  }
	; branch always
	bne	lab74
lab73:
	;  else if (flags == O_WRONLY) {
	;    file->bufferidx = 0;
	ldy	#FILE_BUFFERIDX
	lda	#0
	sta	(FATLSSTR_FILE),y
	iny
	sta	(FATLSSTR_FILE),y
	;  }
lab74:
	;  file->availdivsize = file->divsize;
	ldy	#FILE_DIVSIZE
	lda	(FATLSSTR_FILE),y
	ldy	#FILE_AVAILDIVSIZE
	sta	(FATLSSTR_FILE),y
	ldy	#FILE_DIVSIZE+1
	lda	(FATLSSTR_FILE),y
	ldy	#FILE_AVAILDIVSIZE+1
	sta	(FATLSSTR_FILE),y
	;  file->availmodsize = file->modsize;
	ldy	#FILE_MODSIZE
	lda	(FATLSSTR_FILE),y
	ldy	#FILE_AVAILMODSIZE
	sta	(FATLSSTR_FILE),y
	ldy	#FILE_MODSIZE+1
	lda	(FATLSSTR_FILE),y
	ldy	#FILE_AVAILMODSIZE+1
	sta	(FATLSSTR_FILE),y
	rts


;int getsize6502(struct file6502* file) {
;  int size = 512*file->divsize + file->modsize;
;  return size;
;}

__getsize:
	; long size = 512*file->divsize + file->modsize;
	ldy	#FILE_MODSIZE
	lda	(FATLSSTR_FILE),y
	sta	SIZE
	ldy	#FILE_DIVSIZE
	lda	(FATLSSTR_FILE),y
	asl
	ldy	#FILE_MODSIZE+1
	ora	(FATLSSTR_FILE),y
	sta	SIZE+1
	ldy	#FILE_DIVSIZE+1
	lda	(FATLSSTR_FILE),y
	rol
	sta	SIZE+2
	rts


_getsize:
	; long __fastcall__ getsize(int fd);

	jsr	getfpfromfd
	jsr	__getsize
	lda	#0
	sta	sreg+1
	lda	SIZE+2
	sta	sreg
	ldx	SIZE+1
	lda	SIZE
	rts


;int getactpos6502(struct file6502* file) {
;  int actpos = 512*(file->divsize - file->availdivsize)
;    + file->modsize - file->availmodsize;
;  return actpos;
;}

__getintvars:
	jsr	__getsize
	jsr	__getavail
	sec
	lda	SIZE+2
	sbc	AVAIL+2
	sta	ACTPOS+2
	lda	SIZE+1
	sbc	AVAIL+1
	sta	ACTPOS+1
	lda	SIZE
	sbc	AVAIL
	sta	ACTPOS
	rts

#ifdef ENABLE_LSEEK
;long lseek6502(int fd, long offset, int whence) {
;  int i;
;  struct file6502* file;
;  int actpos;
;
;  if ((fd < 3) || (fd > MAX_FDS+3)) return -1;
;  i = fd-3;
;  file = fdptr[i];
;
;  if (file->mode == O_WRONLY) {
;    fwrite(file->buffer, file->bufferidx, 1, file->f);
;  }
;
;  actpos = getactpos6502(file);
;  if (offset == 0) {
;    int size, count;
;    switch (whence) {
;    case SEEK_SET:
;      rewind6502(file);
;      break;
;    case SEEK_CUR:
;      break;
;    case SEEK_END:
;      size = getsize6502(file);
;      count = size - actpos;
;      readwriteseek6502(fd, NULL, count, 2);
;      break;
;    }
;  }
;  else if (offset > 0) {
;    int size, count;
;    switch (whence) {
;    case SEEK_SET:
;      if (offset > actpos) {
;        count = offset - actpos;
;        readwriteseek6502(fd, NULL, count, 2);
;      }
;      else if (offset < actpos) {
;        rewind6502(file);
;        readwriteseek6502(fd, NULL, offset, 2);
;      }
;      break;
;    case SEEK_CUR:
;      readwriteseek6502(fd, NULL, offset, 2);
;      break;
;    case SEEK_END:
;      size = getsize6502(file);
;      count = size - actpos;
;      readwriteseek6502(fd, NULL, count, 2);
;      break;
;    }
;  }
;  else if (offset < 0) {
;    int size, count, temp;
;    switch (whence) {
;    case SEEK_SET:
;      rewind6502(file);
;      break;
;    case SEEK_CUR:
;      count = actpos + offset;
;      rewind6502(file);
;      readwriteseek6502(fd, NULL, count, 2);
;      break;
;    case SEEK_END:
;      size = getsize6502(file);
;      temp = size + offset;
;      if (temp > actpos) {
;        count = temp - actpos;
;        readwriteseek6502(fd, NULL, count, 2);
;      }
;      else if (temp < actpos) {
;        rewind6502(file);
;        readwriteseek6502(fd, NULL, temp, 2);
;      }
;      break;
;    }
;  }
;
;  actpos = getactpos6502(file);
;  return actpos;
;}

_lseek:
	; off_t __fastcall__ lseek (int fd, off_t offset, int whence);

	; get parameter whence (in a/x)
	sta	WHENCE

	; get parameter offset (on stack)
	pla
	tax
	pla
	sta	OFFSET
	stx	OFFSET+1
	pla
	tax
	pla
	sta	OFFSET+2

	; get parameter fd (on stack)
	pla
	tax
	pla
	sta	FD

	ldy	#2
	sty	MODE

	;  if ((fd < 3) || (fd > MAX_FDS+3)) return -1;
	lda	FD
	cmp	#3
	bcc	labS2
	cmp	#(MAX_FDS+3)
	bcs	labS2
	jmp	labS1
labS2:
	; invalid file descriptor
	; error -> return -1
	lda	#$FF
	sta	sreg+1
	sta	sreg
	tax
	rts

labS1:
	;  i = fd-3;
	;  file = fdptr[i];
	jsr	getfpfromfd

	;  if (file->mode == O_WRONLY) {
	;    fwrite(file->buffer, file->bufferidx, 1, file->f);
	;  }
	ldy	#FILE_MODE
	lda	(FATLSSTR_FILE),y
	cmp	#O_RDONLY
	beq	labS3
	lda	FATLSSTR_FILE
	clc
	adc	#FILE_BUFFER
	sta	FATLSSTR_MEM
	lda	FATLSSTR_FILE+1
	adc	#0
	sta	FATLSSTR_MEM+1
	ldx	#<FATLSSTR_FILE
	ldy	#>FATLSSTR_FILE
	callatm	fatwritenextsector6502
	lda	RERRCODE6502
	bne	labS2
labS3:

	;  actpos = getactpos6502(file);
	;  -> size, avail, actpos
	jsr	__getintvars
	;  if (offset == 0) {
	lda	OFFSET+2
	ora	OFFSET+1
	ora	OFFSET
	bne	labS4
	;    switch (whence) {
	;    case SEEK_SET:
	lda	WHENCE
	cmp	#SEEK_SET
	bne	labS5
labS13:
	;      rewind6502(file);
	jsr	__rewind
	;      break;
	jmp	labS30
labS5:
	;    case SEEK_CUR:
	cmp	#SEEK_CUR
	bne	labS6
	;      break;
	jmp	labS30
labS6:
	;    case SEEK_END:
	cmp	#SEEK_END
	bne	labS7
labS12:
	;      count = size - actpos;
	lda	AVAIL+2
	sta	COUNT+2
	lda	AVAIL+1
	sta	COUNT+1
	lda	AVAIL
	sta	COUNT
	;      readwriteseek6502(fd, NULL, count, 2);
	jsr	__readwriteseek
	;      break;
	;    }
	;  }
	jmp	labS30
labS4:
	;  else if (offset > 0) {
	lda	OFFSET+2
	bmi	labS7
	;    switch (whence) {
	lda	WHENCE
	;    case SEEK_SET:
	cmp	#SEEK_SET
	bne	labS8
	lda	OFFSET+2
	cmp	ACTPOS+2
	bcc	labS9
	bne	labS10
	lda	OFFSET+1
	cmp	ACTPOS+1
	bcc	labS9
	bne	labS10
	lda	OFFSET
	cmp	ACTPOS
	bcc	labS9
	bne	labS10
	; offset == actpos
	jmp	labS30
labS10:
	;      if (offset > actpos) {
	;        count = offset - actpos;
	sec
	lda	OFFSET
	sbc	ACTPOS
	sta	COUNT
	lda	OFFSET+1
	sbc	ACTPOS+1
	sta	COUNT+1
	lda	OFFSET+2
	sbc	ACTPOS+2
	sta	COUNT+2
	;        readwriteseek6502(fd, NULL, count, 2);
	jsr	__readwriteseek
	;      }
	jmp	labS30
labS9:
	;      else if (offset < actpos) {
	;        rewind6502(file);
	jsr	__rewind
labS11:
	;        readwriteseek6502(fd, NULL, offset, 2);
	jsr	__readwriteseek
	;      }
	;      break;
	jmp	labS30
labS8:
	;    case SEEK_CUR:
	cmp	#SEEK_CUR
	bne	labS11
	;      break;
	jmp	labS30
	;    case SEEK_END:
	beq	labS12
	;      break;
	;    }
	;  }
	jmp	labS30
labS7:
	;  else if (offset < 0) {
	;    switch (whence) {
	lda	WHENCE
	;    case SEEK_SET:
	cmp	#SEEK_SET
	beq	labS13
	;    case SEEK_CUR:
	cmp	#SEEK_CUR
	bne	labS14
	;      count = actpos + offset;
	clc
	lda	OFFSET
	adc	ACTPOS
	sta	COUNT
	lda	OFFSET+1
	adc	ACTPOS+1
	sta	COUNT+1
	lda	OFFSET+2
	adc	ACTPOS+2
	sta	COUNT+2
	jmp	labS9
labS14:
	;    case SEEK_END:
	cmp	#SEEK_END
	bne	labS30
	;      temp = size + offset;
	clc
	lda	SIZE
	adc	OFFSET
	sta	TEMP
	lda	SIZE+1
	adc	OFFSET+1
	sta	TEMP+1
	lda	SIZE+2
	adc	OFFSET+2
	sta	TEMP+2
	cmp	ACTPOS+2
	bcc	labS15
	bne	labS16
	lda	TEMP+1
	cmp	ACTPOS+1
	bcc	labS15
	bne	labS16
	lda	TEMP
	cmp	ACTPOS
	bcc	labS15
	bne	labS16
	; temp == actpos
	jmp	labS30
labS16:
	;      if (temp > actpos) {
	;        count = temp - actpos;
	sec
	lda	TEMP
	sbc	ACTPOS
	sta	COUNT
	lda	TEMP+1
	sbc	ACTPOS+1
	sta	COUNT+1
	lda	TEMP+2
	sbc	ACTPOS+2
	sta	COUNT+2
	;        readwriteseek6502(fd, NULL, count, 2);
	jsr	__readwriteseek
	;      }
	jmp	labS30
labS15:
	;      else if (temp < actpos) {
	;        rewind6502(file);
	jsr	__rewind
	;        readwriteseek6502(fd, NULL, temp, 2);
	jsr	__readwriteseek
	;      }
	;      break;
	jmp	labS30
	;    }
	;  }
labS30:
	;  actpos = getactpos6502(file);
	jsr	__getintvars
	;  return actpos;
	lda	#0
	sta	sreg+1
	lda	ACTPOS+2
	sta	sreg
	ldx	ACTPOS+1
	lda	ACTPOS
	rts
#endif // ENABLE_LSEEK
