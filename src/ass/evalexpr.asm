START6502CODE = 2512
RATOI6502 = 65298
RMUL6502 = 65294
ITOASTRING = 65077
SHELLBUFFER = 65088

jmpsh = 15
callatm = 255
println6502 = 12
printstring6502 = 18
mul16x16mod6502 = 22
div16x166502 = 24
atoi6502 = 26
itoa6502 = 28

* = START6502CODE

; Variabeln

; Funktion findChar -> String, in dem nach einem bestimmten Zeichen gesucht werden soll (Pointer)
fC_s = 10
; Funktion findChar -> Zeichen, nach dem gesucht werden soll
fC_c = fC_s+2
; Funktion findChar -> lokale Variable, Zaehler-Variable
fC_cnt = fC_c+1
; Funktion eval -> String, der ausgewertet werden soll (Pointer)
eval_s = fC_cnt+1


; Autostart-Programm
jmp	main
.asc	"AUTO"


findChar:
	; Suche das angegebene Zeichen fC_c im String fC_s
	; Eingabe fC_s -> String, in dem nach einem bestimmten Zeichen gesucht werden soll
	; Eingabe fC_c -> Zeichen, nach dem gesucht werden soll
	; Ausgabe y-Reg. -> Position im String, an dem das Zeichen gefunden wurde oder 255, wenn das Zeichen nicht gefunden wurde

	; int findChar(char *s, char c) {
	;    int cnt = 0;
	;    int i = 0;
	; 
	;    while (s[i] != '\0') {
	;       if (s[i] == '(') cnt++;
	;       else if (s[i] == ')') cnt--;
	;       else if ((s[i] == c) && (cnt == 0)) {
	;          return i;
	;       }
	;       i++;
	;    }
	;    return -1;
	; }

	;    int cnt = 0;
	;    int i = 0;
	ldy	#0
	sty	fC_cnt
	;    while (s[i] != '\0') {
findChar_lab1:
	lda	(fC_s),y
	beq	findChar_lab2
	;       if (s[i] == '(') cnt++;
	cmp	#'('
	bne	findChar_lab3
	inc	fC_cnt
	jmp	findChar_lab5
findChar_lab3:
	;       else if (s[i] == ')') cnt--;
	cmp	#')'
	bne	findChar_lab4
	dec	fC_cnt
	jmp	findChar_lab5
findChar_lab4:
	;       else if ((s[i] == c) && (cnt == 0)) {
	cmp	fC_c
	bne	findChar_lab5
	lda	fC_cnt
	bne	findChar_lab5
	;          return i;
	rts
findChar_lab5:
	;       i++;
	iny
	jmp	findChar_lab1
findChar_lab2:
	;    return -1;
	ldy	#255
	rts


eval:
	; Werte den angegebenen Ausdruck (Parameter eval_s) aus
	; Eingabe eval_s -> Ausdruck, der ausgewertet werden soll
	; Ausgabe RATOI6502 -> Ergebnis (16 Bit Zahl)

	; int eval(char *s) {
	;    int idx;
	; 
	;    if ((idx = findChar(s, '-')) >= 0) {
	;       int left, right;
	;       s[idx] = '\0';
	;       left = eval(s);
	;       right = eval(s+idx+1);
	;       return left - right;
	;    }
	;    else if ((idx = findChar(s, '+')) >= 0) {
	;       int left, right;
	;       s[idx] = '\0';
	;       left = eval(s);
	;       right = eval(s+idx+1);
	;       return left + right;
	;    }
	;    else if ((idx = findChar(s, '/')) >= 0) {
	;       int left, right;
	;       s[idx] = '\0';
	;       left = eval(s);
	;       right = eval(s+idx+1);
	;       return left / right;
	;    }
	;    else if ((idx = findChar(s, '*')) >= 0) {
	;       int left, right;
	;       s[idx] = '\0';
	;       left = eval(s);
	;       right = eval(s+idx+1);
	;       return left * right;
	;    }
	;    else if ((idx = findChar(s, '%')) >= 0) {
	;       int left, right;
	;       s[idx] = '\0';
	;       left = eval(s);
	;       right = eval(s+idx+1);
	;       return left % right;
	;    }
	;    else if ((s[0] == '(') && (s[strlen(s)-1] == ')')) {
	;       s[strlen(s)-1] = '\0';
	;       return eval(s+1);
	;    }
	;    else {
	;       return atoi(s);
	;    }
	; }

	lda	eval_s
	sta	fC_s
	lda	eval_s+1
	sta	fC_s+1
	;    if ((idx = findChar(s, '-')) >= 0) {
	lda	#'-'
	sta	fC_c
	jsr	findChar
	cpy	#255
	beq	eval_lab2
	jsr	eval_lab0
	lda	RATOI6502
	pha
	lda	RATOI6502+1
	pha
	jsr	eval_lab1
	;       return left - right;
	sec
	pla
	sbc	RATOI6502+1
	sta	RATOI6502+1
	pla
	sbc	RATOI6502
	sta	RATOI6502
	rts
eval_lab2:
	;    else if ((idx = findChar(s, '+')) >= 0) {
	lda	#'+'
	sta	fC_c
	jsr	findChar
	cpy	#255
	beq	eval_lab3
	jsr	eval_lab0
	lda	RATOI6502+1
	pha
	lda	RATOI6502
	pha
	jsr	eval_lab1
	;       return left + right;
	clc
	pla
	adc	RATOI6502
	sta	RATOI6502
	pla
	adc	RATOI6502+1
	sta	RATOI6502+1
	rts
eval_lab3:
	;    else if ((idx = findChar(s, '/')) >= 0) {
	lda	#'/'
	sta	fC_c
	jsr	findChar
	cpy	#255
	beq	eval_lab7
	jsr	eval_lab0
	lda	RATOI6502
	sta	RMUL6502
	lda	RATOI6502+1
	sta	RMUL6502+1
	jsr	eval_lab1
	;       return left / right;
	lda	RATOI6502
	sta	RMUL6502+2
	lda	RATOI6502+1
	sta	RMUL6502+3
	.byt	callatm,div16x166502
	lda	RMUL6502
	sta	RATOI6502
	lda	RMUL6502+1
	sta	RATOI6502+1
	rts
eval_lab7:
	;    else if ((idx = findChar(s, '*')) >= 0) {
	lda	#'*'
	sta	fC_c
	jsr	findChar
	cpy	#255
	beq	eval_lab8
	jsr	eval_lab0
	lda	RATOI6502
	sta	RMUL6502
	lda	RATOI6502+1
	sta	RMUL6502+1
	jsr	eval_lab1
	;       return left * right;
	lda	RATOI6502
	sta	RMUL6502+2
	lda	RATOI6502+1
	sta	RMUL6502+3
	.byt	callatm,mul16x16mod6502
	lda	RMUL6502
	sta	RATOI6502
	lda	RMUL6502+1
	sta	RATOI6502+1
	rts
eval_lab8:
	;    else if ((idx = findChar(s, '%')) >= 0) {
	lda	#'%'
	sta	fC_c
	jsr	findChar
	cpy	#255
	beq	eval_lab9
	jsr	eval_lab0
	lda	RATOI6502
	sta	RMUL6502
	lda	RATOI6502+1
	sta	RMUL6502+1
	jsr	eval_lab1
	;       return left % right;
	lda	RATOI6502
	sta	RMUL6502+2
	lda	RATOI6502+1
	sta	RMUL6502+3
	.byt	callatm,div16x166502
	lda	RMUL6502+2
	sta	RATOI6502
	lda	RMUL6502+3
	sta	RATOI6502+1
	rts
eval_lab9:
	;    else if ((s[0] == '(') && (s[strlen(s)-1] == ')')) {
	ldy	#0
	lda	(eval_s),y
	cmp	#'('
	bne	eval_lab6
eval_lab5:
	lda	(eval_s),y
	beq	eval_lab4
	iny
	jmp	eval_lab5
eval_lab4:
	dey
	lda	(eval_s),y
	cmp	#')'
	bne	eval_lab6
	;       s[strlen(s)-1] = '\0';
	lda	#0
	sta	(eval_s),y
	;       return eval(s+1);
	ldy	#0
	jmp	eval_lab1
eval_lab6:
	;       return atoi(s);
	ldx	eval_s
	ldy	eval_s+1
	.byt	callatm,atoi6502
	rts


eval_lab0:
	;       s[idx] = '\0';
	lda	#0
	sta	(eval_s),y
	;       left = eval(s);
	tya
	pha
	lda	eval_s
	pha
	lda	eval_s+1
	pha
	jsr	eval
	pla
	sta	eval_s+1
	pla
	sta	eval_s
	pla
	tay
	rts


eval_lab1:
	;       right = eval(s+idx+1);
	lda	eval_s
	pha
	lda	eval_s+1
	pha
	iny
	tya
	clc
	adc	eval_s
	sta	eval_s
	lda	#0
	adc	eval_s+1
	sta	eval_s+1
	jsr	eval
	pla
	sta	eval_s+1
	pla
	sta	eval_s
	rts


main:
	; 1. Argument holen
	lda	#<SHELLBUFFER
	sta	eval_s
	lda	#>SHELLBUFFER
	sta	eval_s+1
	ldy	#0
main_lab1:
	inc	eval_s
	bne	main_lab5
	inc	eval_s+1
main_lab5:
	lda	(eval_s),y
	bne	main_lab1
	inc	eval_s
	bne	main_lab4
	inc	eval_s+1
main_lab4:
	; Ausdruck auswerten
	jsr	eval
	; Resultat auf dem Bildschirm anzeigen
	ldx	RATOI6502
	ldy	RATOI6502+1
	.byt	callatm,itoa6502
	ldx	#<ITOASTRING
	ldy	#>ITOASTRING
	.byt	callatm,printstring6502
	.byt	callatm,println6502
	; Zurueck zur Shell
	.byt	jmpsh
