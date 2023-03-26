delay:
	ldy	#5
	ldx	#0
delay_lab1:
	dex
	bne	delay_lab1
	dey
	bne	delay_lab1
;	lda	TIMER
;delay_lab2:
;	cmp	TIMER
;	beq	delay_lab2
	rts


cmpstring:
	ldy	#0
cmpstring1:
	lda	(data),y
	cmp	(cmpstr),y
	bne	cmpstring_lab2
	cmp	#0
	beq	cmpstring_lab3
	iny
	cpy	#32
	bne	cmpstring1
cmpstring_lab2:
	lda	#255
cmpstring_lab3:
	rts


readSpiStatus:
	callatm	spienable6502
	lda	#4
	callatm	spi6502
	ldy	#0
readSpiStatus_lab1:
	callatm	spi6502
	sta	(data),y
	iny
	cpy	#4
	bne	readSpiStatus_lab1
	callatm	spidisable6502
	rts


readSpiBuffer:
	callatm	spienable6502
	lda	#3
	callatm	spi6502
	lda	#0
	callatm	spi6502
	ldy	#0
readSpiBuffer_lab1:
	callatm	spi6502
	sta	(data),y
	iny
	cpy	#32
	bne	readSpiBuffer_lab1
	callatm	spidisable6502
	rts


writeSpiStatus:
	callatm	spienable6502
	lda	#1
	callatm	spi6502
	ldy	#0
writeSpiStatus_lab1:
	lda	(data),y
	callatm	spi6502
	iny
	cpy	#4
	bne	writeSpiStatus_lab1
	callatm	spidisable6502
	rts


writeSpiBuffer:
	callatm	spienable6502
	lda	#2
	callatm	spi6502
	lda	#0
	callatm	spi6502
	ldy	#0
writeSpiBuffer_lab1:
	lda	(data),y
	callatm	spi6502
	iny
	cpy	#32
	bne	writeSpiBuffer_lab1
	callatm	spidisable6502
	rts
