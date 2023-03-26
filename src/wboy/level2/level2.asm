#include "../wboydef.inc"

* = leveldata
.word	tilesdef+768
.word	worldarray
.word	groundarray-39
.word	eventarray-1
createenemytable:
; Hier muss die "Feind-Tabelle" folgen
#include "enemyl2.asm"
#include "level2data.asm"
#include "wboydatal2.asm"
