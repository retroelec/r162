startcode = 2512
KEYPRARR = 65024
TEXTMAPDEFAULT = 512

jmpsh = 15

* = startcode

	jmp	start
	.asc	"AUTO"

start:
	lda	#48
	ldy	#0
lab4:
	sta	TEXTMAPDEFAULT,y
	tax
	inx
	cpx	#58
	bne	lab3
	ldx	#48
lab3:
	txa
	iny
	cpy	#32
	bne	lab4

lab2:
	ldy	#0
lab1:   
	lda	KEYPRARR,y
	clc
	adc	#65
	sta	TEXTMAPDEFAULT+40,y
	iny       
	cpy	#32
	bne	lab1
	beq	lab2 
