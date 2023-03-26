; list.asm, v1.6: list functions for the r162 system
; 
; Copyright (C) 2010-2017 retroelec <retroelec42@gmail.com>
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


; Listen Aufbau (Beispiel mit 2 Elementen):
; Dummy-Element <-> 1. Element <-> 2. Element <-> Dummy-Element


listinit:
	; Initialisieren einer Liste
	; Signatur listinit (in: z; out: -; changed: z)
	; Eingabe: z -> Pointer auf die Liste resp. das Dummy-Listenelement

	std	z+LISTNODENEXT,zl
	std	z+LISTNODENEXT+1,zh
	std	z+LISTNODEPREV,zl
	std	z+LISTNODEPREV+1,zh
	std	z+LISTNODEID,regzero
	ret


listinsert:
	; Einfuegen eines Knotens in eine Liste
	; Signatur listinsert (in: r18,r19,z; out: -; changed: r16,r17,r20,x,y)
	; Eingabe: r18, r19 -> Pointer auf die Liste
	; Eingabe: z -> Pointer auf den einzufuegenden Knoten
	; Veraenderte Register: r16, r17, r20, x, y
	; Pseudocode:
	;   listinsert(list, node) {
	;     prevnode = list;
	;     nextnode = prevnode->next;
	;     while (nextnode != list) {
	;       if (node->id < nextnode->id) break;
	;       prevnode = nextnode;
	;       nextnode = prevnode->next;
	;     }
	;     node->next = nextnode;
	;     node->prev = prevnode;
	;     prevnode->next = node;
	;     nextnode->prev = node;
	;   }

	mov	yl,r18
	mov	yh,r19
	; node->id in r20
	ldd	r20,z+LISTNODEID
listinsert_lab3:
	; prevnode = list in x
	; resp. prevnode = nextnode in x
	mov	xl,yl
	mov	xh,yh
	; nextnode = prevnode->next in y
	ldd	r16,y+LISTNODENEXT
	ldd	r17,y+LISTNODENEXT+1
	mov	yl,r16
	mov	yh,r17
	; if (nextnode == list) goto lab1
	cp	yl,r18
	brne	listinsert_lab4
	cp	yh,r19
	breq	listinsert_lab1
listinsert_lab4:
	; if (node->id < nextnode->id) goto lab1
	ldd	r16,y+LISTNODEID
	cp	r20,r16
	brlo	listinsert_lab1
	rjmp	listinsert_lab3
listinsert_lab1:
	; node->next = nextnode;
	std	z+LISTNODENEXT,yl
	std	z+LISTNODENEXT+1,yh
	; node->prev = prevnode;
	std	z+LISTNODEPREV,xl
	std	z+LISTNODEPREV+1,xh
	; nextnode->prev = node;
	std	y+LISTNODEPREV,zl
	std	y+LISTNODEPREV+1,zh
	; prevnode->next = node;
	mov	yl,xl
	mov	yh,xh
	std	y+LISTNODENEXT,zl
	std	y+LISTNODENEXT+1,zh
	ret


listremove:
	; Loeschen eines Knotens in einer Liste
	; Signatur listremove (in: z; out: y,z; changed: r16,r17,y,z)
	; Eingabe: z -> Pointer auf den zu loeschenden Knoten
	; Ausgabe: z -> Pointer auf den naechsten Knoten in der Liste
	; Ausgabe: y -> Pointer auf den vorhergehenden Knoten in der Liste
	; Veraenderte Register: r16, r17, y, z

	; prevnode = node->prev;
	ldd	yl,z+LISTNODEPREV
	ldd	yh,z+LISTNODEPREV+1
	; nextnode = node->next;
	ldd	r16,z+LISTNODENEXT
	ldd	r17,z+LISTNODENEXT+1
	; prevnode->next = nextnode;
	std	y+LISTNODENEXT,r16
	std	y+LISTNODENEXT+1,r17
	; nextnode->prev = prevnode;
	mov	zl,r16
	mov	zh,r17
	std	z+LISTNODEPREV,yl
	std	z+LISTNODEPREV+1,yh
	ret
