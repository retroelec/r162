; spi.asm, v1.6.2: spi access for the r162 system
; 
; Copyright (C) 2010-2019 retroelec <retroelec42@gmail.com>
; 
; This program is free software; you can redistribute it and/or modify it
; under the terms of the GNU General Public License as published by the
; Free Software Foundation; either version 3 of the License, or (at your
; option) any later version.
; 
; This program is distributed in the hope that it will be useful, but
; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
; or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
; for more details.
; 
; For the complete text of the GNU General Public License see
; http://www.gnu.org/licenses/.


; CS: PD1 fuer CS verwenden -> Output
; DI: PB5/MOSI verwenden -> Output
; DO: PB6/MISO verwenden -> Input
; SCK: PB7/SCK verwenden -> Output


spi6502:
	; <proc>
	;   <name>spi6502</name>
	;   <desce>write/read a byte to/from SPI interface (CS: PD1)</desce>
	;   <input>
	;     <rparam>
	;       <name>a</name>
	;       <desce>byte to write</desce>
	;     </rparam>
	;   </input>
	;   <output>
	;     <rparam>
	;       <name>a</name>
	;       <desce>byte read</desce>
	;     </rparam>
	;   </output>
	; </proc>

	out	SPDR,rega
spi6502_lab1:
	sbis	SPSR,SPIF
	rjmp	spi6502_lab1
	in	rega,SPDR
	ret


spienable6502:
	; <proc>
	;   <name>spienable6502</name>
	;   <desce>enable SPI interface (CS: PD1)</desce>
	; </proc>

	cbi	PORTD,PORTD1
	ret


spidisable6502:
	; <proc>
	;   <name>spidisable6502</name>
	;   <desce>disable SPI interface (CS: PD1)</desce>
	; </proc>

	sbi	PORTD,PORTD1
	ret
