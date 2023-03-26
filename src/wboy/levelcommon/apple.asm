createapple:
	; Apfel erzeugen
	ldy	#MSPRITEY
	lda	actenemyfruitparam
	sta	(enemysprite),y
	ldy	#MSPRITEW
	lda	#APPLEWIDTH
	sta	(enemysprite),y
	ldy	#MSPRITEH
	lda	#APPLEHEIGHT
	sta	(enemysprite),y
	ldy	#MSPRITEDATA
	lda	#<apple
	sta	(enemysprite),y
	iny
	lda	#>apple
	sta	(enemysprite),y
	jsr	commoncreatefruit
	ldy	#MSPRITEFRUITSCORE
	lda	#5
	sta	(enemysprite),y
	ldy	#MSPRITEFRUITSCOREWIDTH
	lda	#SCORE50WIDTH
	sta	(enemysprite),y
	ldy	#MSPRITEFRUITSCOREDATA
	lda	#<score50
	sta	(enemysprite),y
	iny
	lda	#>score50
	sta	(enemysprite),y
	rts

apple:
; applesprite.ppm (6x11)
.byt 238, 142, 236, 238, 232, 200, 238, 232 
.byt 78, 229, 85, 85, 21, 81, 177, 17 
.byt 81, 91, 17, 17, 81, 17, 17, 17 
.byt 1, 17, 177, 225, 17, 30, 228, 0 
.byt 78
APPLEWIDTH = 6
APPLEHEIGHT = 11
