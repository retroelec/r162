createcarrot:
	; Karotte erzeugen
	ldy	#MSPRITEY
	lda	actenemyfruitparam
	sta	(enemysprite),y
	ldy	#MSPRITEW
	lda	#CARROTWIDTH
	sta	(enemysprite),y
	ldy	#MSPRITEH
	lda	#CARROTHEIGHT
	sta	(enemysprite),y
	ldy	#MSPRITEDATA
	lda	#<carrot
	sta	(enemysprite),y
	iny
	lda	#>carrot
	sta	(enemysprite),y
	jsr	commoncreatefruit
	ldy	#MSPRITEFRUITSCORE
	lda	#10
	sta	(enemysprite),y
	ldy	#MSPRITEFRUITSCOREWIDTH
	lda	#SCORE100WIDTH
	sta	(enemysprite),y
	ldy	#MSPRITEFRUITSCOREDATA
	lda	#<score100
	sta	(enemysprite),y
	iny
	lda	#>score100
	sta	(enemysprite),y
	rts

carrot:
; carrotsprite.ppm (6x12)
.byt 232, 238, 140, 228, 136, 136, 228, 136 
.byt 142, 69, 153, 217, 5, 89, 217, 5 
.byt 153, 255, 5, 153, 221, 5, 153, 255 
.byt 69, 153, 217, 225, 153, 254, 228, 89 
.byt 158, 238, 73, 238
CARROTWIDTH = 6
CARROTHEIGHT = 12
