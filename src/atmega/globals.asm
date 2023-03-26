; globals.asm, v1.6.2: global variables of the r162 system
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


; *** Memory-Map (overview) ***

;     0-  255:	ATMega registers (256 bytes)
;   256-  759:	internal variables + stack of the ATMega (504 bytes)
;   760-  767:	interrupt vectors for the 6502 (0xFFF8-0xFFFF) (8 bytes)
;   768- 1023:	zeropage of the 6502 (256 bytes)
;  1024- 1279:	stack of the 6502 (256 bytes)
;  1280- 2279:	textmap (default - changeable) (1000 bytes)
;  2280- 3279:	colormap in text mode (default - changeable) (1000 bytes)
;  3280-62975:	free memory area (e.g. for 6502 code) (59696 bytes)
; 46976-51071:	buffer for the function fatls (4096 byte)
; 46976-62975:	multicolormap (default - changeable) (16000 bytes)
; 62976-65023:	charmap (default - high byte changeable) (2048 bytes)
; 65024-65535:	FAT buffer (512 bytes)


.EQU	ATMEGAVARSTART = 256


; *** Input / Output ***

; Konstanten

; key code for cursor left (6502DEFC)
.EQU	KEYCURLEFT = 17
; key code for cursor down (6502DEFC)
.EQU	KEYCURDOWN = 18
; key code for cursor right (6502DEFC)
.EQU	KEYCURRIGHT = 19
; key code for cursor up (6502DEFC)
.EQU	KEYCURUP = 20
; key code for page up (6502DEFC)
.EQU	KEYPGUP = 21
; key code for page down (6502DEFC)
.EQU	KEYPGDOWN = 22
; key code for home (6502DEFC)
.EQU	KEYHOME = 23
; key code for end (6502DEFC)
.EQU	KEYEND = 24
; key code for insert (6502DEFC)
.EQU	KEYINSERT = 25
; key code for delete (6502DEFC)
.EQU	KEYDELETE = 26
; key code for printscreen (6502DEFC)
.EQU	KEYPRTSCR = 14
; key code for print scrolllock (6502DEFC)
.EQU	KEYSCRLCK = 15
; key code for print numlock (6502DEFC)
.EQU	KEYNUMLCK = 16
; key code for f1 (6502DEFC)
.EQU	KEYF1 = 1
; key code for f2 (6502DEFC)
.EQU	KEYF2 = 2
; key code for f3 (6502DEFC)
.EQU	KEYF3 = 28
; key code for f4 (6502DEFC)
.EQU	KEYF4 = 4
; key code for f5 (6502DEFC)
.EQU	KEYF5 = 5
; key code for f6 (6502DEFC)
.EQU	KEYF6 = 6
; key code for f7 (6502DEFC)
.EQU	KEYF7 = 7
; key code for f8 (6502DEFC)
.EQU	KEYF8 = 29
; key code for backspace (6502DEFC)
.EQU	KEYBACKSPACE = 8
; key code for tab (6502DEFC)
.EQU	KEYTAB = 9
; key code for windowsleft (6502DEFC)
.EQU	KEYWINLEFT = 30
; key code for windowsright (6502DEFC)
.EQU	KEYWINRIGHT = 31
; key code for escape (6502DEFC)
.EQU	KEYESCAPE = 127
; key code for ctrl-q (6502DEFC)
.EQU	KEYCTRLQ = 149
; key code for ctrl-w (6502DEFC)
.EQU	KEYCTRLW = 157
; key code for ctrl-e (6502DEFC)
.EQU	KEYCTRLE = 164
; key code for ctrl-r (6502DEFC)
.EQU	KEYCTRLR = 173
; key code for ctrl-t (6502DEFC)
.EQU	KEYCTRLT = 172
; key code for ctrl-z (6502DEFC)
.EQU	KEYCTRLZ = 181
; key code for ctrl-u (6502DEFC)
.EQU	KEYCTRLU = 188
; key code for ctrl-i (6502DEFC)
.EQU	KEYCTRLI = 195
; key code for ctrl-o (6502DEFC)
.EQU	KEYCTRLO = 196
; key code for ctrl-p (6502DEFC)
.EQU	KEYCTRLP = 205
; key code for ctrl-a (6502DEFC)
.EQU	KEYCTRLA = 156
; key code for ctrl-s (6502DEFC)
.EQU	KEYCTRLS = 155
; key code for ctrl-f (6502DEFC)
.EQU	KEYCTRLF = 171
; key code for ctrl-g (6502DEFC)
.EQU	KEYCTRLG = 180
; key code for ctrl-h (6502DEFC)
.EQU	KEYCTRLH = 179
; key code for ctrl-j (6502DEFC)
.EQU	KEYCTRLJ = 187
; key code for ctrl-k (6502DEFC)
.EQU	KEYCTRLK = 194
; key code for ctrl-l (6502DEFC)
.EQU	KEYCTRLL = 203
; key code for ctrl-y (6502DEFC)
.EQU	KEYCTRLY = 154
; key code for ctrl-x (6502DEFC)
.EQU	KEYCTRLX = 162
; key code for ctrl-c (6502DEFC)
.EQU	KEYCTRLC = 3
; key code for ctrl-v (6502DEFC)
.EQU	KEYCTRLV = 170
; key code for ctrl-b (6502DEFC)
.EQU	KEYCTRLB = 178
; key code for ctrl-n (6502DEFC)
.EQU	KEYCTRLN = 177
; key code for ctrl-m (6502DEFC)
.EQU	KEYCTRLM = 186
; key code for ctrl-, (6502DEFC)
.EQU	KEYCTRLCOMMA = 193
; key code for ctrl-. (6502DEFC)
.EQU	KEYCTRLDOT = 201
; key code for ctrl-- (6502DEFC)
.EQU	KEYCTRLMINUS = 202
; Laenge des Tastatur-Puffers
.EQU	KEYBDBUFFERLEN = 10

; Variablen

; Start
.EQU	INOUTSTART = ATMEGAVARSTART
; Aktuell gedrueckte Tasten (16 Bytes)
; currently pressed keys (ignoring key release) (32 bytes) (6502DEFM)
.EQU	KEYPRARR = INOUTSTART+0
; Variable (1 Byte), welche den Keyboard-Zustand festhaelt
.EQU	KBDSTATE = KEYPRARR+32
; Variable (1 Byte), welche die aktuell gedrueckte Taste festhaelt
; currently pressed key (1 byte) (6502DEFM)
.EQU	KEYPRESSED = KBDSTATE+1
; Variable (1 Byte), welche auf die aktuelle Schreib-Position im Tastatur-Puffer zeigt
.EQU	KBDBUFFERPRODPTR = KEYPRESSED+1
; Variable (1 Byte), welche auf die aktuelle Lese-Position im Tastatur-Puffer zeigt
.EQU	KBDBUFFERCONSPTR = KBDBUFFERPRODPTR+1
; Tastatur-Puffer (KEYBDBUFFERLEN Bytes)
.EQU	KBDBUFFER = KBDBUFFERCONSPTR+1
; Pointer (2 Bytes) auf die aktuelle Cursorposition
; pointer to the actual cursor position (6502DEFMP)
.EQU	ACTCURADDR = KBDBUFFER+10
; Variable (1 Byte) mit der aktuellen x-Cursor-Position
; actual cursor x position (1 byte) (6502DEFM)
.EQU	CURX = ACTCURADDR+2
; Variable (1 Byte) mit der aktuellen y-Cursor-Position
; actual cursor y position (1 byte) (6502DEFM)
.EQU	CURY = CURX+1
; Variable (1 Byte), die angibt, ob Daten "seitenweise" angezeigt werden sollen
; flag to determine if pager is active (1 byte) (6502DEFM)
.EQU	PAGERACTIVE = CURY+1
; Variable (1 Byte), welche die Anzahl angezeigter Zeilen zaehlt
; number of lines displayed if pager is active (1 byte) (6502DEFM)
.EQU	PAGERCNT = PAGERACTIVE+1
; Variable (1 Byte), die signalisiert, ob die "seitenweise" Anzeige abgebrochen wurde
; flag to determine if paging was quit (1 byte) (6502DEFM)
.EQU	PAGERBREAK = PAGERCNT+1
; Ende
.EQU	INOUTENDE = PAGERBREAK+1


; *** Diverse Konstanten / Variabeln ***

; Defines

.DEF	regzero = r5
.DEF	regmemoff6502 = r8

.MACRO	himemon
	sbi	PORTD,PORTD3
.ENDMACRO

.MACRO	himemoff
	cbi	PORTD,PORTD3
.ENDMACRO

; Konstanten

; High-Memory -> Videodaten
; bit to activate high memory for video (6502DEFC)
.EQU LOWHIMEMVIDEO = 0
; High-Memory -> Utility-Funktionen
; bit to activate high memory for utility functions (6502DEFC)
.EQU LOWHIMEMUTIL = 1
; High-Memory -> Filesystem-Funktionen
; bit to activate high memory for filesystem functions (6502DEFC)
.EQU LOWHIMEMFS = 2
; High-Memory -> Auto-Sound
; bit to activate high memory for auto sound (6502DEFC)
.EQU LOWHIMEMSOUND = 3
; Stack-Start
.EQU	STACKSTART = 759 ; CPU6502 -> FFF8-1
; Pointer auf die Keyboard-Map im Flash
.EQU	KEYBMAP = 0x1E80
; Liste -> next-Pointer
.EQU	LISTNODENEXT = 0
; Liste -> prev-Pointer
.EQU	LISTNODEPREV = 2
; Liste -> ID
.EQU	LISTNODEID = 4
; memfill6502-Struktur
; Pointer auf den Speicherbereich
; memfill6502 structure -> pointer to memory (6502DEFC)
.EQU	MEMFILL6502_MEMPTR = 0
; Anzahl Bytes
; memfill6502 structure -> number of bytes (6502DEFC)
.EQU	MEMFILL6502_N = 2
; Anzahl Elemente
; memfill6502 structure -> number of elements (6502DEFC)
.EQU	MEMFILL6502_M = 3
; Konstanter Wert
; memfill6502 structure -> constant (6502DEFC)
.EQU	MEMFILL6502_CONST = 4
; memcopy6502-Struktur
; Pointer auf den Quell-Speicherbereich
; memcopy6502 structure -> pointer to source memory (6502DEFC)
.EQU	MEMCOPY6502_SRC = 0
; Pointer auf den Ziel-Speicherbereich
; memcopy6502 structure -> pointer to destination memory (6502DEFC)
.EQU	MEMCOPY6502_DEST = 2
; Anzahl zu kopierende Bytes
; memcopy6502 structure -> number of bytes to copy (6502DEFC)
.EQU	MEMCOPY6502_N = 4

; Variabeln

; Start
.EQU	DIVVARSTART = INOUTENDE
; Speicherbereich (6 Bytes), der den durch die Funktion itoa umgewandelten String enthaelt
; memory area (6 bytes) for the string created by the function itoa (6502DEFM)
.EQU	ITOASTRING = DIVVARSTART+0
; Speicherbereich zur Ablage des BIN-Verzeichnis-Namens (5 Bytes)
.EQU	SYSBINDIRNAME = ITOASTRING+6
; Shell-Buffer (41 Bytes)
; shell buffer (41 bytes) (6502DEFM)
.EQU	SHELLBUFFER = SYSBINDIRNAME+5
; Anzahl Argumente (1 Byte)
; number of shell arguments (1 byte) (6502DEFM)
.EQU	SHELLNUMARGS = SHELLBUFFER+41
; Timer (2 Bytes)
; 6502 timer (2 bytes) (6502DEFM)
.EQU	TIMER = SHELLNUMARGS+1
; CPU mode (1 Byte) (6502DEFM)
.EQU	CPUMODE = TIMER+2
; Register (1 Byte), welches bestimmt, ob (in bestimmten Situationen) auf das Low- oder das High-Memory zugegriffen wird
; register (1 byte), to determine if low or high memory should be used (for certain actions) (6502DEFM)
.EQU	LOWHIMEM = CPUMODE+1
; Ende
.EQU	DIVVARENDE = LOWHIMEM+1


; *** Videogenerator ***

; Konstanten

; Textmap-Default
; default value for the start of the textmap (6502DEFM)
.EQU	TEXTMAPDEFAULT = 1280
; Farbenmap-Default (Text-Modus)
; default value for the start of the colormap in text mode (6502DEFM)
.EQU	COLORMAPTXTDEFAULT = 2280
; MColormap-Default
; default value for the start of the multicolormap (6502DEFM)
.EQU	MCOLORMAPDEFAULT = 46976
; default value for the start of character definitions in SRAM (6502DEFM)
.EQU	CHARDEFSDEFAULT = 62976
; Default-Blinking-Intervall des Cursors
; default blinking interval of cursor (6502DEFC)
.EQU	CURSPEEDDEFAULT = 30
; copyblock6502 structure -> pointer to the source memory block (6502DEFC)
.EQU	COPYBLOCK6502_SRC = 0
; copyblock6502 structure -> pointer to the destination memory block (6502DEFC)
.EQU	COPYBLOCK6502_DEST = 2
; copyblock6502 structure -> width of source memory block (6502DEFC)
.EQU	COPYBLOCK6502_WSRC = 4
; copyblock6502 structure -> height of source memory block (6502DEFC)
.EQU	COPYBLOCK6502_HSRC = 5
; copyblock6502 structure -> source memory block -> number of bytes to skip to read the next line (6502DEFC)
.EQU	COPYBLOCK6502_MODWSRC = 6
; copyblock6502 structure -> destination memory block -> number of bytes to skip to write the next line (6502DEFC)
.EQU	COPYBLOCK6502_MODWDEST = 7
; copychars6502 structure -> pointer to the source memory block (6502DEFC)
.EQU	COPYCHARS6502_SRC = 0
; copychars6502 structure -> start char in destination memory block (6502DEFC)
.EQU	COPYCHARS6502_DESTSTARTCHAR = 2
; copychars6502 structure -> number of chars to copy (6502DEFC)
.EQU	COPYCHARS6502_NUMCHARS = 3
; vic20multicolmapping6502 structure -> pointer to VIC20 screen map (6502DEFC)
.EQU	VIC20MULTICOLMAPPING_SCREENPTR = 0
; vic20multicolmapping6502 structure -> high byte of VIC20 char data (page aligned) (6502DEFC)
.EQU	VIC20MULTICOLMAPPING_CHARPAGE = 2
; vic20multicolmapping6502 structure -> high byte of color table (page aligned) (6502DEFC)
.EQU	VIC20MULTICOLMAPPING_COLTABPAGE = 3
; vic20multicolmapping6502 structure -> number of rows to process (6502DEFC)
.EQU	VIC20MULTICOLMAPPING_NUMOFROWS = 4
; vic20multicolmapping6502 structure -> pointer to destination address (somewhere in MCOLORMAP) (6502DEFC)
.EQU	VIC20MULTICOLMAPPING_DESTMAP = 5

; Variablen

; Start
.EQU	VIDEOGENERATORSTART = DIVVARENDE
; Anzahl Zeilen (1 Byte)
; number of rows (1 byte) (6502DEFM)
.EQU	NUMOFROWS = VIDEOGENERATORSTART+0
; Anzahl Zeilen im Modus 0+2 (1 Byte)
; number of rows in mode 0 and mode 2 (1 byte) (6502DEFM)
.EQU	NUMOFROWSM0 = NUMOFROWS+1
; Anzahl Zeilen im Modus 1 (1 Byte)
; number of rows in mode 1 (1 byte) (6502DEFM)
.EQU	NUMOFROWSM1 = NUMOFROWSM0+1
; Bild-Start (1 Byte)
.EQU	STARTROW = NUMOFROWSM1+1
; Bild-Start im Modus 0+2 (1 Byte)
; start of TV picture in mode 0 and mode 2 (1 byte) (6502DEFM)
.EQU	STARTROWM0 = STARTROW+1
; Bild-Start im Modus 1 (1 Byte)
; start of TV picture in mode 1 (1 byte) (6502DEFM)
.EQU	STARTROWM1 = STARTROWM0+1
; Pointer auf die Textmap
; pointer to textmap (6502DEFMP)
.EQU	TEXTMAP = STARTROWM1+1
; Pointer auf die Farbenmap (Text-Modus)
; pointer to colormap in mode 0 (text mode) (6502DEFMP)
.EQU	COLORMAPTXT = TEXTMAP+2
; Pointer auf die Multicolormap
; pointer to multicolormap (6502DEFMP)
.EQU	MCOLORMAP = COLORMAPTXT+2
; Variable (1 Byte), welche die Zeilen-Nummer waehrend der "Schwarzphase" des Bildes beinhaltet
; row number during the "vertical sync phase" (1 byte) (6502DEFM)
.EQU	VSYNCROW = MCOLORMAP+2
; Variable (1 Byte), welche die Bild-Zeilen-Nummer beinhaltet (wenn der Variableninhalt 0 ist, dann befindet sich das Bild in der "Schwarzphase")
; row number during the "picture drawing phase" (zero during the "vertical sync phase") (1 byte) (6502DEFM)
.EQU	PICROW = VSYNCROW+1
; Pointer auf den aktuellen Zeilenanfang im Textmap-Speicher
; pointer to the actual row in text map (usually automatically set by the Atmega system software) (2 bytes) (6502DEFMP)
.EQU	ACTTEXTPTR = PICROW+1
; Pointer auf den aktuellen Zeilenanfang im Farbenmap-Speicher (Text-Modus)
; pointer to the actual row in text color map (usually automatically set by the Atmega system software) (2 bytes) (6502DEFMP)
.EQU	ACTCOLPTR = ACTTEXTPTR+2
; Variable (1 Byte), welche die aktuelle Zeile innerhalb eines Characters beinhaltet
.EQU	CHARLINE = ACTCOLPTR+2
; Variable (1 Byte), welche die aktuelle Zeile innerhalb eines Color-Characters beinhaltet
.EQU	CHARCOLLINE = CHARLINE+1
; Pointer auf den aktuellen Zeilenanfang im Multicolormap-Speicher
; pointer to the actual row in the multi color map (usually automatically set by the Atmega system software) (2 bytes) (6502DEFMP)
.EQU	ACTMCOLMAPPTR = CHARCOLLINE+1
; Register (1 Byte), die den Video-Modus festhaelt
; video mode (1 byte) (6502DEFM)
.EQU	VIDEOMODE = ACTMCOLMAPPTR+2
; Register (1 Byte), die den synchronisierten Video-Modus beinhaltet
.EQU	VIDEOMODESYNC = VIDEOMODE+1
; Register (1 Byte), die den internen Video-Modus beinhaltet
.EQU	VIDEOMODEINT = VIDEOMODESYNC+1
; Variable (1 Byte), welche die Anzahl Zyklen enthaelt, die zur HSync-Vorbereitung benoetigt werden
.EQU	VGRINITCYC = VIDEOMODEINT+1
; Register, welches im Multi-Color-Modus die Anzahl Bytes zur Positionierung auf die naechste Zeile enthaelt (Breite des Screens, Default -> 80 Bytes) (1 Byte)
; "screen width" (number of bytes) in multicolor mode (may be larger than "physical screen width", default -> 80 bytes) (1 byte) (6502DEFM)
.EQU	MCOLSCRWIDTH = VGRINITCYC+1
; Register (1 Byte), welches die Start-Zeile des Multi-Color-Modus beinhaltet (= 0 -> kein Wechsel zwischen Text-Modus und Multi-Color-Modus)
; start row in multicolor mode if text and multicolor mode should be displayed concurrently (zero, if there is no change between text and multicolor mode) (1 byte) (6502DEFM)
.EQU	MODE2STARTLINE = MCOLSCRWIDTH+1
; Register (1 Byte), welches die End-Zeile des Multi-Color-Modus beinhaltet
; end row in multicolor mode (1 byte) (6502DEFM)
.EQU	MODE2ENDLINE = MODE2STARTLINE+1
; Variable (1 Byte), die bestimmt, ob der Cursor an ist oder nicht ("Wechsel" in den Textmodus notwendig)
; flag which determines if the cursor is blinking (1 byte) (6502DEFM)
.EQU	CURONOFF = MODE2ENDLINE+1
; Variable (1 Byte), die bestimmt, ob der Cursor in der aktuellen Rasterzeile ist
.EQU	CURINACTLINE = CURONOFF+1
; Register (1 Byte), die die Cursor-Blinking-Geschwindikeit bestimmt
; cursor blinking speed (1 byte) (6502DEFM)
.EQU	CURSPEED = CURINACTLINE+1
; Variable (1 Byte), die den Zaehler fuer das Cursor-Blinking enthaelt
.EQU	CURCNT = CURSPEED+1
; Pointer (2 Bytes) auf die aktuelle Cursor-Position bei der Ausgabe der Rasterzeilen
.EQU	CURADDRSYNC = CURCNT+1
; high byte of the pointer to the character definitions (1 byte) (6502DEFMP)
.EQU	CHARDEFSRAM = CURADDRSYNC+2
; number of lines minus 1 of a text character (default 7) (1 byte) (6502DEFM)
.EQU	NUMOFCHARLINES = CHARDEFSRAM+1
; number of lines minus 1 of the text character color (default 7) (1 byte) (6502DEFM)
.EQU	NUMOFCHARCOLLINES = NUMOFCHARLINES+1
;  number of char columns in text mode (1 byte) (6502DEFM)
.EQU   NUMCHARCOLS = NUMOFCHARCOLLINES+1
;  number of char rows in text mode (1 byte) (6502DEFM)
.EQU   NUMCHARROWS = NUMCHARCOLS+1
; Pointer auf die Tilemap
; pointer to tilemap (6502DEFMP)
.EQU	TILEMAP = NUMCHARROWS+1
; x-Start-Position innerhalb der Tilemap (2 Bytes)
; x start position in tilemap (2 bytes) (6502DEFM)
.EQU	TILEMAPSTARTX = TILEMAP+2
; y-Start-Position innerhalb der Tilemap (2 Bytes)
; y start position in tilemap (2 bytes) (6502DEFM)
.EQU	TILEMAPSTARTY = TILEMAPSTARTX+2
; Breite der Tilemap, z.B. 40 (2 Bytes)
; width of tilemap, e.g. 40 (2 bytes) (6502DEFM)
.EQU	TILEMAPWIDTH = TILEMAPSTARTY+2
; Hoehe der Tilemap, z.B. 25 (2 Bytes)
; height of tilemap, e.g. 25 (2 bytes) (6502DEFM)
.EQU	TILEMAPHEIGHT = TILEMAPWIDTH+2
; x-Start-Position der Tile-Daten in der Multi-Colormap, z.B. 0 (1 Byte)
; x start position of tile data in multicolormap, e.g. 0 (1 byte) (6502DEFM)
.EQU	TILEMCOLMAPX = TILEMAPHEIGHT+2
; y-Start-Position der Tile-Daten in der Multi-Colormap, z.B. 0 (1 Byte)
; y start position of tile data in multicolormap, e.g. 0 (1 byte) (6502DEFM)
.EQU	TILEMCOLMAPY = TILEMCOLMAPX+1
; Breite der Tile-Daten in der Multi-Colormap, z.B. 40 (1 Byte)
; width of tile data in multicolormap, e.g. 40 (1 byte) (6502DEFM)
.EQU	TILEMCOLMAPW = TILEMCOLMAPY+1
; Hoehe der Tile-Daten in der Multi-Colormap, z.B. 25 (1 Byte)
; height of tile data in multicolormap, e.g. 25 (1 byte) (6502DEFM)
.EQU	TILEMCOLMAPH = TILEMCOLMAPW+1
; Pointer auf die Tiles-Definitionen
; pointer to tiles definitions (6502DEFMP)
.EQU	GFXTILEDEFS = TILEMCOLMAPH+1
; x end position for the drawline6502 function (1 byte) (6502DEFM)
.EQU	DRAWLINEENDX = GFXTILEDEFS+2
; y end position for the drawline6502 function (1 byte) (6502DEFM)
.EQU	DRAWLINEENDY = DRAWLINEENDX+1
; flag which determines if 6502 code is executed in vsync (1 byte)
.EQU	INVSYNC = DRAWLINEENDY+1
; Flag, das bestimmt, ob Sprites gezeichnet werden muessen
.EQU	DRAWSPRITES = INVSYNC+1
; Temporaerer Pointer zur Abarbeitung der Sprite-Liste
.EQU	SPRITELISTTMPPTR = DRAWSPRITES+1
; Autosound-Konstante -> 0 = aus, 1 = 15625 Hz, 2 = 7812 Hz, etc. (1 Byte)
; autosound constant -> 0 = off, 1 = 15625 Hz, 2 = 7812 Hz, etc. (1 byte) (6502DEFM)
.EQU	AUTOSND = SPRITELISTTMPPTR+2
; Autosound synchronisiert, sollte mit der Autosound-Konstante initialisiert werden (1 Byte)
; autosound synchronized (init. with autosound constant) (1 byte) (6502DEFM)
.EQU	AUTOSNDSYNC = AUTOSND+1
; Autosound synchronisiert, auf 0 setzen, wenn der Sound deaktiviert werden soll (1 Byte)
; autosound synchronized, set to 0 if sound should be deactivated (1 byte) (6502DEFM)
.EQU	AUTOSNDSYNC2 = AUTOSNDSYNC+1
; Pointer auf Autosound-Array
; pointer to autosound array (6502DEFMP)
.EQU	AUTOSNDPTR = AUTOSNDSYNC2+1
; Anzahl Bytes des Autosounds (2 Bytes)
; number of bytes of autosound (2 bytes) (6502DEFM)
.EQU	AUTOSNDCNT = AUTOSNDPTR+2
; Aktuelles Daten-Byte des Autosounds (1 Byte)
; actual data of autosound (1 byte) (6502DEFM)
.EQU	AUTOSNDDATA = AUTOSNDCNT+2
; enable/disable interlace (1 byte) (6502DEFM)
.EQU	INTERLACEONOFF = AUTOSNDDATA+1
; interlace, toggle between even and odd lines (1 bytes) (6502DEFM)
.EQU	INTERLACEPHASE = INTERLACEONOFF+1
; Ende
.EQU	VIDEOGENERATORENDE = INTERLACEPHASE+1


; *** FAT ***

; Konstanten

; file structure -> FILESTARTCLUST (2 bytes) (6502DEFC)
.EQU	FILESTARTCLUST = 0 ; 2 bytes
; Datei-Struktur FILENEXTCLUST
.EQU	FILENEXTCLUST = 2 ; 2 bytes
; Datei-Struktur FILEACTSECT
.EQU	FILEACTSECT = 4 ; 3 bytes
; Datei-Struktur FILEACTSECTINCLUST
; file structure -> FILEACTSECTINCLUST (1 byte) (6502DEFC)
.EQU	FILEACTSECTINCLUST = 7 ; 1 byte
; Datei-Struktur FILEMODSIZE
; file structure -> FILEMODSIZE (2 bytes) (6502DEFC)
.EQU	FILEMODSIZE = 8 ; 2 bytes
; Datei-Struktur FILEDIVSIZE
; file structure -> FILEDIVSIZE (2 bytes) (6502DEFC)
.EQU	FILEDIVSIZE = 10 ; 2 bytes
; Fehler-Code Datei-System nicht initialisiert
; error code filesystem not initialized (6502DEFC)
.EQU	FATERRFSNOTINIT = 128
; Fehler-Code Master Boot Record konnte nicht gelesen werden
.EQU	FATERRREADMBR = 1
; Fehler-Code Ungueltiger Master Boot Record
.EQU	FATERRINVALIDMBR = 2
; Fehler-Code Fehler beim Lesen des Bootsektors
.EQU	FATERRREADBOOT = 3
; Fehler-Code Ungueltiger Bootsektors
.EQU	FATERRINVALIDBOOT = 4
; Fehler-Code Kein FAT16 Dateisystem
.EQU	FATERRINVALIDFATSYS = 5
; Fehler-Code Keine 512 Bytes pro Sektor
.EQU	FATERRINVALIDBYTESPERSECT = 6
; Fehler-Code Fehler beim Initialisieren der SD Card
.EQU	FATERRSDCARD = 8
; Fehler-Code Fehler beim Suchen eines Verzeichniseintrags
; error code error when searching for a directory entry (6502DEFC)
.EQU	FATERRDI1 = 1
; Fehler-Code Datei nicht gefunden
; error code file not found (6502DEFC)
.EQU	FATERRFNF = 2
; Fehler-Code Fehler beim Ermitteln des naechsten Sektors einer Datei
; error code error when determing the next sector of a file (6502DEFC)
.EQU	FATERRREADFAT = 4
; Info-Code Letzter Cluster einer Datei
; info code last cluster of a file (6502DEFC)
.EQU	FATINFOLASTCLUST = 8
; Fehler-Code Fehler beim Lesen des naechsten Sektors einer Datei
; error code error when reading the next sector of a file (6502DEFC)
.EQU	FATERRREAD = 16
; Fehler-Code Fehler beim Schreiben des naechsten Sektors einer Datei
; error code error when writing the next sector of a file (6502DEFC)
.EQU	FATERRWRITE = 32
; Fixer Speicherbereich fuer den FAT-Buffer (6502DEFM)
.EQU	FATBUFFER = 65024
; Groesse der Datei-Struktur
; size of the file structure (6502DEFC)
.EQU	FILESTRUCTSIZE = 12
; fatloadsave structure -> offset to the pointer to the file structure (6502DEFC)
.EQU	FATLOADSAVE_FILE = 0
; fatloadsave structure -> offset to the pointer to the file name (6502DEFC)
.EQU	FATLOADSAVE_NAME = 2
; fatloadsave structure -> offset to the pointer to the memory area (6502DEFC)
.EQU	FATLOADSAVE_MEM = 4
; start of the fatls buffer (6502DEFM)
.EQU	FATLSBUF = 46976
; sdreadwritesector structure -> offset to the sector number (6502DEFC)
.EQU	SDREADWRITESECTOR_NR = 0
; sdreadwritesector structure -> offset to the pointer to the memory area (6502DEFC)
.EQU	SDREADWRITESECTOR_MEM = 3

; Variablen

; Start
.EQU	FATSTART = VIDEOGENERATORENDE
; Flag, ob das Filesystem initialisiert werden konnte resp. OK ist (1 Byte) (6502DEFM)
.EQU	FATFSOK = FATSTART+0
; Start-Sektor-Nummer der FAT (3 Bytes)
; start sector number of the FAT (3 bytes) (6502DEFM)
.EQU 	FATFATSTARTSECNR = FATFSOK+1
; Start-Sektor-Nummer des Stammverzeichnisses (3 Bytes)
; start sector number of the root directory (3 bytes) (6502DEFM)
.EQU	FATROOTSTARTSECNR = FATFATSTARTSECNR+3
; Anzahl Sektoren des Stammverzeichnisses (2 Bytes)
; number of sectors of the root directory (2 bytes) (6502DEFM)
.EQU	FATNUMSECROOTDIR = FATROOTSTARTSECNR+3
; Start-Sektor-Nummer des Datenbereichs (3 Bytes)
; start sector number of the data area (3 bytes) (6502DEFM)
.EQU	FATDATASTARTSECNR = FATNUMSECROOTDIR+2
; Anzahl Sektoren pro Cluster (1 Byte)
; number of sectors per cluster (1 byte) (6502DEFM)
.EQU	FATNUMSECPERCLUST = FATDATASTARTSECNR+3
; Flag, ob das aktuelle Verzeichnis das Stammverzeichnis ist (1 Byte)
; flag to determine if the actual directory is the root directory (1 byte) (6502DEFM)
.EQU	FATROOTDIRFLAG = FATNUMSECPERCLUST+1
; Flag, ob das "gerettete" Verzeichnis das Stammverzeichnis ist (1 Byte)
.EQU	FATTMPROOTDIRFLAG = FATROOTDIRFLAG+1
; Speicherbereich fuer die Struktur des aktuellen Verzeichnisses falls es nicht das Stammverzeichnis ist (12 resp. FILESTRUCTSIZE Bytes)
.EQU	FATACTDIR = FATTMPROOTDIRFLAG+1
; Speicherbereich, um die Struktur des aktuellen Verzeichnisses zu "retten" (12 resp. FILESTRUCTSIZE Bytes)
.EQU	FATTMPACTDIR = FATACTDIR+12
; Pointer auf den Namen der zu oeffnenden Datei in der Funktion fatdiriter (2 Bytes)
.EQU	FATDIRITERNAME = FATTMPACTDIR+12
; Pointer auf die Datei-Struktur der zu oeffnenden Datei in der Funktion fatdiriter (2 Bytes)
.EQU	FATDIRITERFILE = FATDIRITERNAME+2
; Speicherbereich fuer den aktuellen Datei-Namen (13 Bytes)
.EQU	FATENTRYNAME = FATDIRITERFILE+2
; Startadresse (Pointer) an welche der Dateiinhalt geladen wird
; start address (pointer) to which the file content is loaded (6502DEFMP)
.EQU	FATLOADSTARTADDR = FATENTRYNAME+13
; Speicherbereich fuer die System-Datei-Struktur (12 resp. FILESTRUCTSIZE Bytes)
.EQU	SYSFILESTRUCT = FATLOADSTARTADDR+2
; unused (1 byte)
.EQU	FATUNUSED1 = SYSFILESTRUCT+12
; number of sectors of the FAT (2 bytes) (6502DEFM)
.EQU	FATNUMSECFAT = FATUNUSED1+1
; memory region to interact with the 6502 system (4 bytes)
.EQU	FATMEM6502 = FATNUMSECFAT+2
; number of the empty cluster determined by 6502 code used by the function fattraceclusterchain6502 (2 bytes) (6502DEFM)
.EQU	FATEMPTYCLUST6502 = FATMEM6502
; function fattraceclusterchain6502 -> flag to signal if the "cluster chain" should be removed or extended (1 byte) (6502DEFM)
.EQU	FATRMFLAG6502 = FATEMPTYCLUST6502+2
; memory to save the actual sector used in the function fatopen6502 (resp. fatdiriter) (3 bytes) (6502DEFM)
.EQU	FATOPENACTSECT6502 = FATMEM6502
; memory to save the actual entry in the actual sector used in the function fatopen6502 (resp. fatdiriter) (1 byte) (6502DEFM)
.EQU	FATOPENACTENTRY6502 = FATOPENACTSECT6502+3
; Ende
.EQU	FATENDE = FATMEM6502+4


; *** Sprites ***

; Konstanten

; Sprite-Status
; Status Sprite geloescht
; state sprite deleted (6502DEFC)
.EQU	MSPRITEDELETED = 0
; Status Sprite hinzufuegen
.EQU	MSPRITETOADD = 1
; Status Sprite neu zeichnen
.EQU	MSPRITETODRAW = 2
; Status Sprite loeschen
.EQU	MSPRITETODEL = 3
; Status Sprite nicht gezeichnet, aber zu loeschen
.EQU	MSPRITETODELNOTDRAWN = 4

; msprite-Struktur
; next-Pointer
.EQU	MSPRITENODENEXT = LISTNODENEXT
; prev-Pointer
.EQU	MSPRITENODEPREV = LISTNODEPREV
; ID des Sprites
; ID of sprite (6502DEFC)
.EQU	MSPRITEID = 4
; x-Position des Sprites
; x position of sprite (6502DEFC)
.EQU	MSPRITEX = 5
; y-Position des Sprites
; y position of sprite (6502DEFC)
.EQU	MSPRITEY = 6
; Breite des Sprites
; width of sprite (6502DEFC)
.EQU	MSPRITEW = 7
; Hoehe des Sprites
; height of sprite (6502DEFC)
.EQU	MSPRITEH = 8
; Pointer auf Sprite-Daten
; pointer to sprite data (6502DEFC)
.EQU	MSPRITEDATA = 9
; Pointer auf einen Speicherbereich, um den Hintergrund zu speichern
; pointer to a memory area to save the background (6502DEFC)
.EQU	MSPRITEBGDATA = 11
; Pointer auf die (alte) Position des Sprites innerhalb der Multi-Colormap
; pointer to the (old) position of the sprite inside the multicolormap (6502DEFC)
.EQU	MSPRITESTARTPOSOLD = 13
; (Alte) Breite des Sprites in Bytes
; (old) width of sprite in bytes (6502DEFC)
.EQU	MSPRITEWBYTESOLD = 15
; (Alte) Hoehe des Sprites
; (old) height of sprite (6502DEFC)
.EQU	MSPRITEHOLD = 16
; Status des Sprites (DELETED, TOADD, TODRAW, TODEL)
; state of sprite (DELETED, TOADD, TODRAW, TODEL) (6502DEFC)
.EQU	MSPRITESTATUS = 17
; Farbe, die als "transparent" interpretiert werden soll
; transparent color of sprite (6502DEFC)
.EQU	MSPRITETRANSPARENCY = 18
; Anzahl Pixel, um welche die Detektionsflaeche in horizontaler Richtung (links) reduziert wird
; number of pixels to which the detection area in horizontal direction (left) is reduced (6502DEFC)
.EQU	MSPRITECOINCREDLEFT = 19
; Anzahl Pixel, um welche die Detektionsflaeche in horizontaler Richtung (rechts) reduziert wird
; number of pixels to which the detection area in horizontal direction (right) is reduced (6502DEFC)
.EQU	MSPRITECOINCREDRIGHT = 20
; Anzahl Pixel, um welche die Detektionsflaeche in vertikaler Richtung (oben) reduziert wird
; number of pixels to which the detection area in vertical direction (up) is reduced (6502DEFC)
.EQU	MSPRITECOINCREDUP = 21
; Anzahl Pixel, um welche die Detektionsflaeche in vertikaler Richtung (unten) reduziert wird
; number of pixels to which the detection area in vertical direction (down) is reduced (6502DEFC)
.EQU	MSPRITECOINCREDDOWN = 22
; Flag, ob Sprite-Kollisions-Detektionen mit diesem Sprite gewuenscht sind
; flag to determine if sprite collisions (with this sprite) should be tracked (6502DEFC)
.EQU	MSPRITENOCOINCDETECT = 23
; Anzahl Sprites, mit denen dieses Sprite kollidiert ist
; number of sprites which collided with this sprite (6502DEFC)
.EQU	MSPRITENUMCOINC = 24
; Array der Sprite-IDs, mit denen dieses Sprite kollidiert ist
; array of sprite IDs this sprite collided with (6502DEFC)
.EQU	MSPRITECOINCARR = 25

; Variabeln

; Start
.EQU	SPRITESSTART = FATENDE
; Sprite-Liste (5 Bytes)
.EQU	SPRITELIST = SPRITESSTART+0
; Flag, ob die Sprite-Liste gerade manipuliert wird (1 Byte)
.EQU	SPRITELISTINWORK = SPRITELIST+5
; Sprite-ID, ab der die Sprites gezeichnet werden muessen (1 Byte)
; sprite ID from which sprites must be drawn (1 byte) (6502DEFM)
.EQU	MINSPRITEIDTODRAW = SPRITELISTINWORK+1
; Ende
.EQU	SPRITESENDE = MINSPRITEIDTODRAW+1


; *** 6502 ***

; Defines

.DEF	regint6502 = r6

; Konstanten

; Beginn des Bereichs fuer 6502-Code
; start of memory area for 6502 code (6502DEFM)
.EQU	START6502CODE = 3280
; Pointer auf die 6502-Befehlstabelle im Flash
.EQU	CMD6502JMPTAB = 0x1F00
; 6502-Interrupts-Bits
.EQU	INT6502CTRLS = 7
.EQU	INT6502DEBUG = 6
.EQU	INT6502VSYNC = 4
.EQU	INT6502CTRLD = 3
.EQU	INT6502TIMER = 2
; Adressen fuer Interrupt-Vektoren
.EQU	CPU6502FFF8 = 760
.EQU	CPU6502FFFA = 762
.EQU	CPU6502FFFC = 764
.EQU	CPU6502FFFE = 766

; Variabeln

; Start
.EQU	CPU6502START = SPRITESENDE
; Interrupt-Maske der maskierbaren 6502-Interrupts (1 Byte)
; interrupt mask of maskable 6502 interrupts (1 byte) (6502DEFM)
.EQU	INTMASK6502 = CPU6502START+0
; timer interrupt load value (1 byte) (6502DEFM)
.EQU	TIMERINTLOADVAL = INTMASK6502+1
; timer interrupt actual value (1 byte) (6502DEFM)
.EQU	TIMERINTACTVAL = TIMERINTLOADVAL+1
; ununsed (1 byte)
.EQU	CPU6502UNUSED1 = TIMERINTACTVAL+1
; memory to transfer results and (partly) parameters for the functions mul* und div16x166502 (4 bytes) (6502DEFM)
.EQU	RMUL6502 = CPU6502UNUSED1+1
; memory for the result of the function atoi6502 (2 bytes) (6502DEFM)
.EQU	RATOI6502 = RMUL6502+4
; memory for the result of the function getchwait6502 (2 bytes) (6502DEFM)
.EQU	RGETCH6502 = RATOI6502+2
; register to query error codes (miscellaneous functions) (1 byte) (6502DEFM)
.EQU	RERRCODE6502 = RGETCH6502+1
; mask to block/unblock interleaved processing of vsync interrupts (1 byte) (6502DEFM)
.EQU   BLOCKILVSYNCINT = RERRCODE6502+1
; Ende
.EQU   CPU6502ENDE = BLOCKILVSYNCINT+1


; *** Debug ***

; Konstanten

; default value for the start of the debug textmap (6502DEFM)
.EQU	DEBUGTEXTMAPDEFAULT = 27904
; default value for the start of the debug colormap (6502DEFM)
.EQU	DEBUGCOLORMAPTXTDEFAULT = 28928
; default value for the start of the breakpoint array (6502DEFM)
.EQU	DEBUGBPARRAYDEFAULT = 65024

; Variabeln

; Start
.EQU	DEBUGSTART = CPU6502ENDE
; flag to decide if a 6502 program starts in debug mode (1 byte) (6502DEFM)
.EQU	DEBUGONOFF = DEBUGSTART+0
; register to save the actual video mode (1 byte)
.EQU	DEBUGSAVEVIDEOMODE = DEBUGONOFF+1
; pointer to save the actual textmap (2 bytes)
.EQU	DEBUGSAVETEXTMAP = DEBUGSAVEVIDEOMODE+1
; pointer to save the actual colormap (2 bytes)
.EQU	DEBUGSAVECOLORMAPTXT = DEBUGSAVETEXTMAP+2
; pointer to debug textmap (2 bytes) (6502DEFMP)
.EQU	DEBUGTEXTMAP = DEBUGSAVECOLORMAPTXT+2
; pointer to debug colormap (2 bytes) (6502DEFMP)
.EQU	DEBUGCOLORMAPTXT = DEBUGTEXTMAP+2
; register to save the actual cursor x position (1 byte) (6502DEFM)
.EQU	DEBUGSAVECURX = DEBUGCOLORMAPTXT+2
; register to save the actual cursor y position (1 byte) (6502DEFM)
.EQU	DEBUGSAVECURY = DEBUGSAVECURX+1
; actual cursor x position in debug mode (1 byte) (6502DEFM)
.EQU	DEBUGCURX = DEBUGSAVECURY+1
; actual cursor y position in debug mode (1 byte) (6502DEFM)
.EQU	DEBUGCURY = DEBUGCURX+1
; pointer to the breakpoint array (2 bytes) (6502DEFMP)
.EQU	DEBUGBPARRAYPTR = DEBUGCURY+1
; flag to decide if "single step debugging" is activated (1 byte)
.EQU	DEBUGSINGLESTEP = DEBUGBPARRAYPTR+2
; Ende
.EQU   DEBUGENDE = DEBUGSINGLESTEP+1


; *** new features ***

; Variabeln

; Start
.EQU	NEWSTART = DEBUGENDE
; register to adapt colors in text modes (1 byte) (6502DEFM)
.EQU	XORTXTCOLOR = NEWSTART+0
; flag if autosound should be repeated (1 byte) (6502DEFM)
.EQU	AUTOSNDREPEAT = XORTXTCOLOR+1
; flag if autosound has been repeated (must be cleared in 6502 code) (1 byte) (6502DEFM)
.EQU	AUTOSNDREPEATED = AUTOSNDREPEAT+1
; repeat sound -> pointer to autosound array (6502DEFMP)
.EQU	AUTOSNDREPEATPTR = AUTOSNDREPEATED+1
; repeat sound -> number of bytes of autosound (2 bytes) (6502DEFM)
.EQU	AUTOSNDREPEATCNT = AUTOSNDREPEATPTR+2
; memory to save registers
.EQU	REG2 = AUTOSNDREPEATCNT+1
.EQU	REG3 = REG2+1
.EQU	REG4 = REG3+1
.EQU	REG7 = REG4+1
.EQU	REG8 = REG7+1
.EQU	REG25 = REG8+1
.EQU	REGYL = REG25+1
.EQU	REGYH = REGYL+1
; Ende
.EQU   NEWENDE = REGYH+1
