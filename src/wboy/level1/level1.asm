#include "../wboydef.inc"

* = leveldata
.word	tilesdef+768
.word	worldarray
.word	groundarray-39
.word	eventarray-1
createenemytable:
; Hier muss die "Feind-Tabelle" folgen
#include "enemyl1.asm"
#include "level1data.asm"
#include "wboydatal1.asm"
