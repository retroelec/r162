; anonymvars.asm, v1.2, generated variables for anonym
; 
; Copyright (C) 2011-2013 retroelec <retroelec@freenet.ch>
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
; www.gnu.org/licenses/.


; Variablen fuer Ghost Anonym

; Tile-X-Position von Anonym
anonymtilexpos = anonymstartblock
; Tile-Y-Position von Anonym
anonymtileypos = anonymtilexpos+1
; Aktuelle Richtung von Anonym
anonymactdir = anonymtileypos+1
; Geschwindigkeit von Anonym in y-Richtung
anonymspeedy = anonymactdir+1
; Temporaere Variable (Geschwindigkeit von Anonym in y-Richtung)
anonymactspeedy = anonymspeedy+1
; Geschwindigkeit von Anonym in x-Richtung
anonymspeedx = anonymactspeedy+1
; Temporaere Variable (Geschwindigkeit von Anonym in x-Richtung)
anonymactspeedx = anonymspeedx+1
; Flag, das anzeigt, ob Anonym sich nach der Bestimmung einer Richtung schon bewegt hat
anonymnochecktilepos = anonymactspeedx+1
; Target-X-Position von Anonym im einem der "Fixed-Modes" (TMODE_FRIGHTEN, TMODE_HOMEOUT, TMODE_HOMEIN, TMODE_GOHOME)
anonymfixedtargetxpos = anonymnochecktilepos+1
; Target-Y-Position von Anonym im einem der "Fixed-Modes" (TMODE_FRIGHTEN, TMODE_HOMEOUT, TMODE_HOMEIN, TMODE_GOHOME)
anonymfixedtargetypos = anonymfixedtargetxpos+1
; Target-Modus von Anonym
anonymtargetmode = anonymfixedtargetypos+1
; Vorheriger Target-Modus von Anonym
anonymoldtargetmode = anonymtargetmode+1
; Flag, ob Anonym einen Richtungswechsel machen muss
anonymchangedir = anonymoldtargetmode+1
; Ende des Variabeln-Blocks (Ghost Anonym)
anonymendblock = anonymchangedir+1
