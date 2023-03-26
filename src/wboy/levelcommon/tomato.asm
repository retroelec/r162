createtomato:
	; Tomate erzeugen
	ldy	#MSPRITEY
	lda	actenemyfruitparam
	sta	(enemysprite),y
	ldy	#MSPRITEW
	lda	#TOMATOWIDTH
	sta	(enemysprite),y
	ldy	#MSPRITEH
	lda	#TOMATOHEIGHT
	sta	(enemysprite),y
	ldy	#MSPRITEDATA
	lda	#<tomato
	sta	(enemysprite),y
	iny
	lda	#>tomato
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

tomato:
; tomatosprite.ppm (8x10)
.byt 238, 136, 200, 238, 229, 88, 197, 30 
.byt 225, 136, 133, 21, 21, 17, 69, 177 
.byt 17, 17, 17, 187, 17, 17, 17, 21 
.byt 17, 17, 21, 81, 65, 17, 21, 20 
.byt 224, 17, 17, 14, 238, 64, 4, 238
TOMATOWIDTH = 8
TOMATOHEIGHT = 10
