createbanana:
	; Banane erzeugen
	ldy	#MSPRITEY
	lda	actenemyfruitparam
	sta	(enemysprite),y
	ldy	#MSPRITEW
	lda	#BANANAWIDTH
	sta	(enemysprite),y
	ldy	#MSPRITEH
	lda	#BANANAHEIGHT
	sta	(enemysprite),y
	ldy	#MSPRITEDATA
	lda	#<banana
	sta	(enemysprite),y
	iny
	lda	#>banana
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

banana:
; bananasprite.ppm (10x12)
.byt 238, 237, 158, 238, 238, 221, 217, 158 
.byt 238, 238, 153, 149, 159, 238, 238, 85 
.byt 157, 217, 255, 238, 229, 153, 217, 221 
.byt 253, 229, 217, 217, 89, 221, 229, 217 
.byt 157, 153, 149, 228, 221, 157, 221, 249 
.byt 228, 157, 217, 221, 213, 238, 93, 221 
.byt 157, 148, 238, 224, 153, 80, 78, 238 
.byt 238, 0, 78, 238
BANANAWIDTH = 10
BANANAHEIGHT = 12
