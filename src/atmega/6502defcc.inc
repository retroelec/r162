; currently pressed keys (ignoring key release) (32 bytes) (6502DEFM)
KEYPRARR = 65024
; currently pressed key (1 byte) (6502DEFM)
KEYPRESSED = 65057
; pointer to the actual cursor position (6502DEFMP)
ACTCURADDRP768 = 65070
; actual cursor x position (1 byte) (6502DEFM)
CURX = 65072
; actual cursor y position (1 byte) (6502DEFM)
CURY = 65073
; flag to determine if pager is active (1 byte) (6502DEFM)
PAGERACTIVE = 65074
; number of lines displayed if pager is active (1 byte) (6502DEFM)
PAGERCNT = 65075
; flag to determine if paging was quit (1 byte) (6502DEFM)
PAGERBREAK = 65076
; memory area (6 bytes) for the string created by the function itoa (6502DEFM)
ITOASTRING = 65077
; shell buffer (41 bytes) (6502DEFM)
SHELLBUFFER = 65088
; number of shell arguments (1 byte) (6502DEFM)
SHELLNUMARGS = 65129
; 6502 timer (2 bytes) (6502DEFM)
TIMER = 65130
; CPU mode (1 Byte) (6502DEFM)
CPUMODE = 65132
; register (1 byte), to determine if low or high memory should be used (for certain actions) (6502DEFM)
LOWHIMEM = 65133
; default value for the start of the textmap (6502DEFM)
TEXTMAPDEFAULT = 512
; default value for the start of the colormap in text mode (6502DEFM)
COLORMAPTXTDEFAULT = 1512
; default value for the start of the multicolormap (6502DEFM)
MCOLORMAPDEFAULT = 46208
; default value for the start of character definitions in SRAM (6502DEFM)
CHARDEFSDEFAULT = 62208
; number of rows (1 byte) (6502DEFM)
NUMOFROWS = 65134
; number of rows in mode 0 and mode 2 (1 byte) (6502DEFM)
NUMOFROWSM0 = 65135
; number of rows in mode 1 (1 byte) (6502DEFM)
NUMOFROWSM1 = 65136
; start of TV picture in mode 0 and mode 2 (1 byte) (6502DEFM)
STARTROWM0 = 65138
; start of TV picture in mode 1 (1 byte) (6502DEFM)
STARTROWM1 = 65139
; pointer to textmap (6502DEFMP)
TEXTMAPP768 = 65140
; pointer to colormap in mode 0 (text mode) (6502DEFMP)
COLORMAPTXTP768 = 65142
; pointer to multicolormap (6502DEFMP)
MCOLORMAPP768 = 65144
; row number during the "vertical sync phase" (1 byte) (6502DEFM)
VSYNCROW = 65146
; row number during the "picture drawing phase" (zero during the "vertical sync phase") (1 byte) (6502DEFM)
PICROW = 65147
; pointer to the actual row in text map (usually automatically set by the Atmega system software) (2 bytes) (6502DEFMP)
ACTTEXTPTRP768 = 65148
; pointer to the actual row in text color map (usually automatically set by the Atmega system software) (2 bytes) (6502DEFMP)
ACTCOLPTRP768 = 65150
; pointer to the actual row in the multi color map (usually automatically set by the Atmega system software) (2 bytes) (6502DEFMP)
ACTMCOLMAPPTRP768 = 65154
; video mode (1 byte) (6502DEFM)
VIDEOMODE = 65156
; "screen width" (number of bytes) in multicolor mode (may be larger than "physical screen width", default -> 80 bytes) (1 byte) (6502DEFM)
MCOLSCRWIDTH = 65160
; start row in multicolor mode if text and multicolor mode should be displayed concurrently (zero, if there is no change between text and multicolor mode) (1 byte) (6502DEFM)
MODE2STARTLINE = 65161
; end row in multicolor mode (1 byte) (6502DEFM)
MODE2ENDLINE = 65162
; flag which determines if the cursor is blinking (1 byte) (6502DEFM)
CURONOFF = 65163
; cursor blinking speed (1 byte) (6502DEFM)
CURSPEED = 65165
; high byte of the pointer to the character definitions (1 byte) (6502DEFMP)
CHARDEFSRAMP768 = 65169
; number of lines minus 1 of a text character (default 7) (1 byte) (6502DEFM)
NUMOFCHARLINES = 65170
; number of lines minus 1 of the text character color (default 7) (1 byte) (6502DEFM)
NUMOFCHARCOLLINES = 65171
; number of char columns in text mode (1 byte) (6502DEFM)
NUMCHARCOLS = 65172
; number of char rows in text mode (1 byte) (6502DEFM)
NUMCHARROWS = 65173
; pointer to tilemap (6502DEFMP)
TILEMAPP768 = 65174
; x start position in tilemap (2 bytes) (6502DEFM)
TILEMAPSTARTX = 65176
; y start position in tilemap (2 bytes) (6502DEFM)
TILEMAPSTARTY = 65178
; width of tilemap, e.g. 40 (2 bytes) (6502DEFM)
TILEMAPWIDTH = 65180
; height of tilemap, e.g. 25 (2 bytes) (6502DEFM)
TILEMAPHEIGHT = 65182
; x start position of tile data in multicolormap, e.g. 0 (1 byte) (6502DEFM)
TILEMCOLMAPX = 65184
; y start position of tile data in multicolormap, e.g. 0 (1 byte) (6502DEFM)
TILEMCOLMAPY = 65185
; width of tile data in multicolormap, e.g. 40 (1 byte) (6502DEFM)
TILEMCOLMAPW = 65186
; height of tile data in multicolormap, e.g. 25 (1 byte) (6502DEFM)
TILEMCOLMAPH = 65187
; pointer to tiles definitions (6502DEFMP)
GFXTILEDEFSP768 = 65188
; x end position for the drawline6502 function (1 byte) (6502DEFM)
DRAWLINEENDX = 65190
; y end position for the drawline6502 function (1 byte) (6502DEFM)
DRAWLINEENDY = 65191
; autosound constant -> 0 = off, 1 = 15625 Hz, 2 = 7812 Hz, etc. (1 byte) (6502DEFM)
AUTOSND = 65196
; autosound synchronized (init. with autosound constant) (1 byte) (6502DEFM)
AUTOSNDSYNC = 65197
; autosound synchronized, set to 0 if sound should be deactivated (1 byte) (6502DEFM)
AUTOSNDSYNC2 = 65198
; pointer to autosound array (6502DEFMP)
AUTOSNDPTRP768 = 65199
; number of bytes of autosound (2 bytes) (6502DEFM)
AUTOSNDCNT = 65201
; actual data of autosound (1 byte) (6502DEFM)
AUTOSNDDATA = 65203
; enable/disable interlace (1 byte) (6502DEFM)
INTERLACEONOFF = 65204
; interlace, toggle between even and odd lines (1 bytes) (6502DEFM)
INTERLACEPHASE = 65205
; Fixer Speicherbereich fuer den FAT-Buffer (6502DEFM)
FATBUFFER = 64256
; start of the fatls buffer (6502DEFM)
FATLSBUF = 46208
; Flag, ob das Filesystem initialisiert werden konnte resp. OK ist (1 Byte) (6502DEFM)
FATFSOK = 65206
; start sector number of the FAT (3 bytes) (6502DEFM)
FATFATSTARTSECNR = 65207
; start sector number of the root directory (3 bytes) (6502DEFM)
FATROOTSTARTSECNR = 65210
; number of sectors of the root directory (2 bytes) (6502DEFM)
FATNUMSECROOTDIR = 65213
; start sector number of the data area (3 bytes) (6502DEFM)
FATDATASTARTSECNR = 65215
; number of sectors per cluster (1 byte) (6502DEFM)
FATNUMSECPERCLUST = 65218
; flag to determine if the actual directory is the root directory (1 byte) (6502DEFM)
FATROOTDIRFLAG = 65219
; start address (pointer) to which the file content is loaded (6502DEFMP)
FATLOADSTARTADDRP768 = 65262
; number of sectors of the FAT (2 bytes) (6502DEFM)
FATNUMSECFAT = 65277
; number of the empty cluster determined by 6502 code used by the function fattraceclusterchain6502 (2 bytes) (6502DEFM)
FATEMPTYCLUST6502 = 65279
; function fattraceclusterchain6502 -> flag to signal if the "cluster chain" should be removed or extended (1 byte) (6502DEFM)
FATRMFLAG6502 = 65281
; memory to save the actual sector used in the function fatopen6502 (resp. fatdiriter) (3 bytes) (6502DEFM)
FATOPENACTSECT6502 = 65279
; memory to save the actual entry in the actual sector used in the function fatopen6502 (resp. fatdiriter) (1 byte) (6502DEFM)
FATOPENACTENTRY6502 = 65282
; sprite ID from which sprites must be drawn (1 byte) (6502DEFM)
MINSPRITEIDTODRAW = 65289
; start of memory area for 6502 code (6502DEFM)
START6502CODE = 2512
; interrupt mask of maskable 6502 interrupts (1 byte) (6502DEFM)
INTMASK6502 = 65290
; timer interrupt load value (1 byte) (6502DEFM)
TIMERINTLOADVAL = 65291
; timer interrupt actual value (1 byte) (6502DEFM)
TIMERINTACTVAL = 65292
; memory to transfer results and (partly) parameters for the functions mul* und div16x166502 (4 bytes) (6502DEFM)
RMUL6502 = 65294
; memory for the result of the function atoi6502 (2 bytes) (6502DEFM)
RATOI6502 = 65298
; memory for the result of the function getchwait6502 (2 bytes) (6502DEFM)
RGETCH6502 = 65300
; register to query error codes (miscellaneous functions) (1 byte) (6502DEFM)
RERRCODE6502 = 65301
; mask to block/unblock interleaved processing of vsync interrupts (1 byte) (6502DEFM)
BLOCKILVSYNCINT = 65302
; default value for the start of the debug textmap (6502DEFM)
DEBUGTEXTMAPDEFAULT = 27136
; default value for the start of the debug colormap (6502DEFM)
DEBUGCOLORMAPTXTDEFAULT = 28160
; default value for the start of the breakpoint array (6502DEFM)
DEBUGBPARRAYDEFAULT = 64256
; flag to decide if a 6502 program starts in debug mode (1 byte) (6502DEFM)
DEBUGONOFF = 65303
; pointer to debug textmap (2 bytes) (6502DEFMP)
DEBUGTEXTMAPP768 = 65309
; pointer to debug colormap (2 bytes) (6502DEFMP)
DEBUGCOLORMAPTXTP768 = 65311
; register to save the actual cursor x position (1 byte) (6502DEFM)
DEBUGSAVECURX = 65313
; register to save the actual cursor y position (1 byte) (6502DEFM)
DEBUGSAVECURY = 65314
; actual cursor x position in debug mode (1 byte) (6502DEFM)
DEBUGCURX = 65315
; actual cursor y position in debug mode (1 byte) (6502DEFM)
DEBUGCURY = 65316
; pointer to the breakpoint array (2 bytes) (6502DEFMP)
DEBUGBPARRAYPTRP768 = 65317
; register to adapt colors in text modes (1 byte) (6502DEFM)
XORTXTCOLOR = 65320
; flag if autosound should be repeated (1 byte) (6502DEFM)
AUTOSNDREPEAT = 65321
; flag if autosound has been repeated (must be cleared in 6502 code) (1 byte) (6502DEFM)
AUTOSNDREPEATED = 65322
; repeat sound -> pointer to autosound array (6502DEFMP)
AUTOSNDREPEATPTRP768 = 65323
; repeat sound -> number of bytes of autosound (2 bytes) (6502DEFM)
AUTOSNDREPEATCNT = 65325
; key code for cursor left (6502DEFC)
KEYCURLEFT = 17
; key code for cursor down (6502DEFC)
KEYCURDOWN = 18
; key code for cursor right (6502DEFC)
KEYCURRIGHT = 19
; key code for cursor up (6502DEFC)
KEYCURUP = 20
; key code for page up (6502DEFC)
KEYPGUP = 21
; key code for page down (6502DEFC)
KEYPGDOWN = 22
; key code for home (6502DEFC)
KEYHOME = 23
; key code for end (6502DEFC)
KEYEND = 24
; key code for insert (6502DEFC)
KEYINSERT = 25
; key code for delete (6502DEFC)
KEYDELETE = 26
; key code for printscreen (6502DEFC)
KEYPRTSCR = 14
; key code for print scrolllock (6502DEFC)
KEYSCRLCK = 15
; key code for print numlock (6502DEFC)
KEYNUMLCK = 16
; key code for f1 (6502DEFC)
KEYF1 = 1
; key code for f2 (6502DEFC)
KEYF2 = 2
; key code for f3 (6502DEFC)
KEYF3 = 28
; key code for f4 (6502DEFC)
KEYF4 = 4
; key code for f5 (6502DEFC)
KEYF5 = 5
; key code for f6 (6502DEFC)
KEYF6 = 6
; key code for f7 (6502DEFC)
KEYF7 = 7
; key code for f8 (6502DEFC)
KEYF8 = 29
; key code for backspace (6502DEFC)
KEYBACKSPACE = 8
; key code for tab (6502DEFC)
KEYTAB = 9
; key code for windowsleft (6502DEFC)
KEYWINLEFT = 30
; key code for windowsright (6502DEFC)
KEYWINRIGHT = 31
; key code for escape (6502DEFC)
KEYESCAPE = 127
; key code for ctrl-q (6502DEFC)
KEYCTRLQ = 149
; key code for ctrl-w (6502DEFC)
KEYCTRLW = 157
; key code for ctrl-e (6502DEFC)
KEYCTRLE = 164
; key code for ctrl-r (6502DEFC)
KEYCTRLR = 173
; key code for ctrl-t (6502DEFC)
KEYCTRLT = 172
; key code for ctrl-z (6502DEFC)
KEYCTRLZ = 181
; key code for ctrl-u (6502DEFC)
KEYCTRLU = 188
; key code for ctrl-i (6502DEFC)
KEYCTRLI = 195
; key code for ctrl-o (6502DEFC)
KEYCTRLO = 196
; key code for ctrl-p (6502DEFC)
KEYCTRLP = 205
; key code for ctrl-a (6502DEFC)
KEYCTRLA = 156
; key code for ctrl-s (6502DEFC)
KEYCTRLS = 155
; key code for ctrl-f (6502DEFC)
KEYCTRLF = 171
; key code for ctrl-g (6502DEFC)
KEYCTRLG = 180
; key code for ctrl-h (6502DEFC)
KEYCTRLH = 179
; key code for ctrl-j (6502DEFC)
KEYCTRLJ = 187
; key code for ctrl-k (6502DEFC)
KEYCTRLK = 194
; key code for ctrl-l (6502DEFC)
KEYCTRLL = 203
; key code for ctrl-y (6502DEFC)
KEYCTRLY = 154
; key code for ctrl-x (6502DEFC)
KEYCTRLX = 162
; key code for ctrl-c (6502DEFC)
KEYCTRLC = 3
; key code for ctrl-v (6502DEFC)
KEYCTRLV = 170
; key code for ctrl-b (6502DEFC)
KEYCTRLB = 178
; key code for ctrl-n (6502DEFC)
KEYCTRLN = 177
; key code for ctrl-m (6502DEFC)
KEYCTRLM = 186
; key code for ctrl-, (6502DEFC)
KEYCTRLCOMMA = 193
; key code for ctrl-. (6502DEFC)
KEYCTRLDOT = 201
; key code for ctrl-- (6502DEFC)
KEYCTRLMINUS = 202
; bit to activate high memory for video (6502DEFC)
LOWHIMEMVIDEO = 0
; bit to activate high memory for utility functions (6502DEFC)
LOWHIMEMUTIL = 1
; bit to activate high memory for filesystem functions (6502DEFC)
LOWHIMEMFS = 2
; bit to activate high memory for auto sound (6502DEFC)
LOWHIMEMSOUND = 3
; memfill6502 structure -> pointer to memory (6502DEFC)
MEMFILL6502_MEMPTR = 0
; memfill6502 structure -> number of bytes (6502DEFC)
MEMFILL6502_N = 2
; memfill6502 structure -> number of elements (6502DEFC)
MEMFILL6502_M = 3
; memfill6502 structure -> constant (6502DEFC)
MEMFILL6502_CONST = 4
; memcopy6502 structure -> pointer to source memory (6502DEFC)
MEMCOPY6502_SRC = 0
; memcopy6502 structure -> pointer to destination memory (6502DEFC)
MEMCOPY6502_DEST = 2
; memcopy6502 structure -> number of bytes to copy (6502DEFC)
MEMCOPY6502_N = 4
; default blinking interval of cursor (6502DEFC)
CURSPEEDDEFAULT = 30
; copyblock6502 structure -> pointer to the source memory block (6502DEFC)
COPYBLOCK6502_SRC = 0
; copyblock6502 structure -> pointer to the destination memory block (6502DEFC)
COPYBLOCK6502_DEST = 2
; copyblock6502 structure -> width of source memory block (6502DEFC)
COPYBLOCK6502_WSRC = 4
; copyblock6502 structure -> height of source memory block (6502DEFC)
COPYBLOCK6502_HSRC = 5
; copyblock6502 structure -> source memory block -> number of bytes to skip to read the next line (6502DEFC)
COPYBLOCK6502_MODWSRC = 6
; copyblock6502 structure -> destination memory block -> number of bytes to skip to write the next line (6502DEFC)
COPYBLOCK6502_MODWDEST = 7
; copychars6502 structure -> pointer to the source memory block (6502DEFC)
COPYCHARS6502_SRC = 0
; copychars6502 structure -> start char in destination memory block (6502DEFC)
COPYCHARS6502_DESTSTARTCHAR = 2
; copychars6502 structure -> number of chars to copy (6502DEFC)
COPYCHARS6502_NUMCHARS = 3
; vic20multicolmapping6502 structure -> pointer to VIC20 screen map (6502DEFC)
VIC20MULTICOLMAPPING_SCREENPTR = 0
; vic20multicolmapping6502 structure -> high byte of VIC20 char data (page aligned) (6502DEFC)
VIC20MULTICOLMAPPING_CHARPAGE = 2
; vic20multicolmapping6502 structure -> high byte of color table (page aligned) (6502DEFC)
VIC20MULTICOLMAPPING_COLTABPAGE = 3
; vic20multicolmapping6502 structure -> number of rows to process (6502DEFC)
VIC20MULTICOLMAPPING_NUMOFROWS = 4
; vic20multicolmapping6502 structure -> pointer to destination address (somewhere in MCOLORMAP) (6502DEFC)
VIC20MULTICOLMAPPING_DESTMAP = 5
; file structure -> FILESTARTCLUST (2 bytes) (6502DEFC)
FILESTARTCLUST = 0
; file structure -> FILEACTSECTINCLUST (1 byte) (6502DEFC)
FILEACTSECTINCLUST = 7
; file structure -> FILEMODSIZE (2 bytes) (6502DEFC)
FILEMODSIZE = 8
; file structure -> FILEDIVSIZE (2 bytes) (6502DEFC)
FILEDIVSIZE = 10
; error code filesystem not initialized (6502DEFC)
FATERRFSNOTINIT = 128
; error code error when searching for a directory entry (6502DEFC)
FATERRDI1 = 1
; error code file not found (6502DEFC)
FATERRFNF = 2
; error code error when determing the next sector of a file (6502DEFC)
FATERRREADFAT = 4
; info code last cluster of a file (6502DEFC)
FATINFOLASTCLUST = 8
; error code error when reading the next sector of a file (6502DEFC)
FATERRREAD = 16
; error code error when writing the next sector of a file (6502DEFC)
FATERRWRITE = 32
; size of the file structure (6502DEFC)
FILESTRUCTSIZE = 12
; fatloadsave structure -> offset to the pointer to the file structure (6502DEFC)
FATLOADSAVE_FILE = 0
; fatloadsave structure -> offset to the pointer to the file name (6502DEFC)
FATLOADSAVE_NAME = 2
; fatloadsave structure -> offset to the pointer to the memory area (6502DEFC)
FATLOADSAVE_MEM = 4
; sdreadwritesector structure -> offset to the sector number (6502DEFC)
SDREADWRITESECTOR_NR = 0
; sdreadwritesector structure -> offset to the pointer to the memory area (6502DEFC)
SDREADWRITESECTOR_MEM = 3
; state sprite deleted (6502DEFC)
MSPRITEDELETED = 0
; ID of sprite (6502DEFC)
MSPRITEID = 4
; x position of sprite (6502DEFC)
MSPRITEX = 5
; y position of sprite (6502DEFC)
MSPRITEY = 6
; width of sprite (6502DEFC)
MSPRITEW = 7
; height of sprite (6502DEFC)
MSPRITEH = 8
; pointer to sprite data (6502DEFC)
MSPRITEDATA = 9
; pointer to a memory area to save the background (6502DEFC)
MSPRITEBGDATA = 11
; pointer to the (old) position of the sprite inside the multicolormap (6502DEFC)
MSPRITESTARTPOSOLD = 13
; (old) width of sprite in bytes (6502DEFC)
MSPRITEWBYTESOLD = 15
; (old) height of sprite (6502DEFC)
MSPRITEHOLD = 16
; state of sprite (DELETED, TOADD, TODRAW, TODEL) (6502DEFC)
MSPRITESTATUS = 17
; transparent color of sprite (6502DEFC)
MSPRITETRANSPARENCY = 18
; number of pixels to which the detection area in horizontal direction (left) is reduced (6502DEFC)
MSPRITECOINCREDLEFT = 19
; number of pixels to which the detection area in horizontal direction (right) is reduced (6502DEFC)
MSPRITECOINCREDRIGHT = 20
; number of pixels to which the detection area in vertical direction (up) is reduced (6502DEFC)
MSPRITECOINCREDUP = 21
; number of pixels to which the detection area in vertical direction (down) is reduced (6502DEFC)
MSPRITECOINCREDDOWN = 22
; flag to determine if sprite collisions (with this sprite) should be tracked (6502DEFC)
MSPRITENOCOINCDETECT = 23
; number of sprites which collided with this sprite (6502DEFC)
MSPRITENUMCOINC = 24
; array of sprite IDs this sprite collided with (6502DEFC)
MSPRITECOINCARR = 25
REGINT6502 = 64774
SNDTCCR1A = 64847
SNDTCCR1B = 64846
SNDOCR1AH = 64843
SNDOCR1AL = 64842
SNDTCCR2 = 64839
SNDOCR2 = 64834
.define dbgit .byt $07
.define jmpsh .byt $0f
.define callatm .byt $ff,
.define setcursorpos6502 0
.define cursorleft6502 2
.define cursorright6502 4
.define cursorup6502 6
.define cursordown6502 8
.define scrollup6502 10
.define println6502 12
.define printchar6502 14
.define printcharnoctrl6502 16
.define printstring6502 18
.define mul8x86502 20
.define mul16x16mod6502 22
.define div16x166502 24
.define atoi6502 26
.define itoa6502 28
.define itoaformat6502 30
.define memfill6502 32
.define memcopy6502 34
.define memcopyr6502 36
.define memcopylowhi6502 38
.define memcopyhilow6502 40
.define keybinit6502 42
.define getchwait6502 44
.define getchnowait6502 46
.define sdinit6502 48
.define sdreadsector6502 50
.define sdwritesector6502 52
.define fatload6502 54
.define fatsave6502 56
.define fatopen6502 58
.define fatreadnextsector6502 60
.define fatwritenextsector6502 62
.define fatrmorextcc6502 64
.define copycharmap6502 66
.define addmsprite6502 68
.define delmsprite6502 70
.define initlistmsprites6502 72
.define coincmsprite6502 74
.define gfxcopytile6502 76
.define gfxcopytilecol6502 78
.define gfxcopytilerow6502 80
.define setpixel6502 82
.define drawline6502 84
.define copyblock6502 86
.define copychars6502 88
.define vic20multicolmapping6502 90
.define spi6502 92
.define spienable6502 94
.define spidisable6502 96
.define fatls6502 98
.define fatcd6502 100
