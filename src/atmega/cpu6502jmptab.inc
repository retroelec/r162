.ORG	CMD6502JMPTAB
	; 00 - 0F
	.dw	cmd6502brk,cmd6502oraIndirectX,cmd6502illegal,cmd6502illegal,cmd6502illegal,cmd6502oraZeropage,cmd6502aslZeropage,cmd6502debug
	.dw	cmd6502php,cmd6502oraImmediate,cmd6502aslA,cmd6502illegal,cmd6502illegal,cmd6502oraAbsolute,cmd6502aslAbsolute,cmd6502shell
	; 10 - 1F
	.dw	cmd6502bpl,cmd6502oraIndirectY,cmd6502illegal,cmd6502illegal,cmd6502illegal,cmd6502oraZeropageX,cmd6502aslZeropageX,cmd6502illegal
	.dw	cmd6502clc,cmd6502oraAbsoluteY,cmd6502illegal,cmd6502illegal,cmd6502illegal,cmd6502oraAbsoluteX,cmd6502aslAbsoluteX,cmd6502illegal
	; 20 - 2F
	.dw	cmd6502jsr,cmd6502andIndirectX,cmd6502illegal,cmd6502illegal,cmd6502bitZeropage,cmd6502andZeropage,cmd6502rolZeropage,cmd6502illegal
	.dw	cmd6502plp,cmd6502andImmediate,cmd6502rolA,cmd6502illegal,cmd6502bitAbsolute,cmd6502andAbsolute,cmd6502rolAbsolute,cmd6502illegal
	; 30 - 3F
	.dw	cmd6502bmi,cmd6502andIndirectY,cmd6502illegal,cmd6502illegal,cmd6502illegal,cmd6502andZeropageX,cmd6502rolZeropageX,cmd6502illegal
	.dw	cmd6502sec,cmd6502andAbsoluteY,cmd6502illegal,cmd6502illegal,cmd6502illegal,cmd6502andAbsoluteX,cmd6502rolAbsoluteX,cmd6502illegal
	; 40 - 4F
	.dw	cmd6502rti,cmd6502eorIndirectX,cmd6502illegal,cmd6502illegal,cmd6502illegal,cmd6502eorZeropage,cmd6502lsrZeropage,cmd6502illegal
	.dw	cmd6502pha,cmd6502eorImmediate,cmd6502lsrA,cmd6502illegal,cmd6502jmpAbsolute,cmd6502eorAbsolute,cmd6502lsrAbsolute,cmd6502illegal
	; 50 - 5F
	.dw	cmd6502bvc,cmd6502eorIndirectY,cmd6502illegal,cmd6502illegal,cmd6502illegal,cmd6502eorZeropageX,cmd6502lsrZeropageX,cmd6502illegal
	.dw	cmd6502cli,cmd6502eorAbsoluteY,cmd6502illegal,cmd6502illegal,cmd6502illegal,cmd6502eorAbsoluteX,cmd6502lsrAbsoluteX,cmd6502illegal
	; 60 - 6F
	.dw	cmd6502rts,cmd6502adcIndirectX,cmd6502illegal,cmd6502illegal,cmd6502illegal,cmd6502adcZeropage,cmd6502rorZeropage,cmd6502illegal
	.dw	cmd6502pla,cmd6502adcImmediate,cmd6502rorA,cmd6502illegal,cmd6502jmpIndirect,cmd6502adcAbsolute,cmd6502rorAbsolute,cmd6502illegal
	; 70 - 7F
	.dw	cmd6502bvs,cmd6502adcIndirectY,cmd6502illegal,cmd6502illegal,cmd6502illegal,cmd6502adcZeropageX,cmd6502rorZeropageX,cmd6502illegal
	.dw	cmd6502sei,cmd6502adcAbsoluteY,cmd6502illegal,cmd6502illegal,cmd6502illegal,cmd6502adcAbsoluteX,cmd6502rorAbsoluteX,cmd6502illegal
	; 80 - 8F
	.dw	cmd6502illegal,cmd6502staIndirectX,cmd6502illegal,cmd6502illegal,cmd6502styZeropage,cmd6502staZeropage,cmd6502stxZeropage,cmd6502illegal
	.dw	cmd6502dey,cmd6502illegal,cmd6502txa,cmd6502illegal,cmd6502styAbsolute,cmd6502staAbsolute,cmd6502stxAbsolute,cmd6502illegal
	; 90 - 9F
	.dw	cmd6502bcc,cmd6502staIndirectY,cmd6502illegal,cmd6502illegal,cmd6502styZeropageX,cmd6502staZeropageX,cmd6502stxZeropageY,cmd6502illegal
	.dw	cmd6502tya,cmd6502staAbsoluteY,cmd6502txs,cmd6502illegal,cmd6502illegal,cmd6502staAbsoluteX,cmd6502illegal,cmd6502illegal
	; A0 - AF
	.dw	cmd6502ldyImmediate,cmd6502ldaIndirectX,cmd6502ldxImmediate,cmd6502illegal,cmd6502ldyZeropage,cmd6502ldaZeropage,cmd6502ldxZeropage,cmd6502illegal
	.dw	cmd6502tay,cmd6502ldaImmediate,cmd6502tax,cmd6502illegal,cmd6502ldyAbsolute,cmd6502ldaAbsolute,cmd6502ldxAbsolute,cmd6502illegal
	; B0 - BF
	.dw	cmd6502bcs,cmd6502ldaIndirectY,cmd6502illegal,cmd6502illegal,cmd6502ldyZeropageX,cmd6502ldaZeropageX,cmd6502ldxZeropageY,cmd6502illegal
	.dw	cmd6502clv,cmd6502ldaAbsoluteY,cmd6502tsx,cmd6502illegal,cmd6502ldyAbsoluteX,cmd6502ldaAbsoluteX,cmd6502ldxAbsoluteY,cmd6502illegal
	; C0 - CF
	.dw	cmd6502cpyImmediate,cmd6502cmpIndirectX,cmd6502illegal,cmd6502illegal,cmd6502cpyZeropage,cmd6502cmpZeropage,cmd6502decZeropage,cmd6502illegal
	.dw	cmd6502iny,cmd6502cmpImmediate,cmd6502dex,cmd6502illegal,cmd6502cpyAbsolute,cmd6502cmpAbsolute,cmd6502decAbsolute,cmd6502illegal
	; D0 - DF
	.dw	cmd6502bne,cmd6502cmpIndirectY,cmd6502illegal,cmd6502illegal,cmd6502illegal,cmd6502cmpZeropageX,cmd6502decZeropageX,cmd6502illegal
	.dw	cmd6502cld,cmd6502cmpAbsoluteY,cmd6502illegal,cmd6502illegal,cmd6502illegal,cmd6502cmpAbsoluteX,cmd6502decAbsoluteX,cmd6502illegal
	; E0 - EF
	.dw	cmd6502cpxImmediate,cmd6502sbcIndirectX,cmd6502illegal,cmd6502illegal,cmd6502cpxZeropage,cmd6502sbcZeropage,cmd6502incZeropage,cmd6502illegal
	.dw	cmd6502inx,cmd6502sbcImmediate,cmd6502nop,cmd6502illegal,cmd6502cpxAbsolute,cmd6502sbcAbsolute,cmd6502incAbsolute,cmd6502illegal
	; F0 - FF
	.dw	cmd6502beq,cmd6502sbcIndirectY,cmd6502illegal,cmd6502illegal,cmd6502illegal,cmd6502sbcZeropageX,cmd6502incZeropageX,cmd6502illegal
	.dw	cmd6502sed,cmd6502sbcAbsoluteY,cmd6502illegal,cmd6502illegal,cmd6502illegal,cmd6502sbcAbsoluteX,cmd6502incAbsoluteX,cmd6502atmega
