#ifndef __LOADRUN_H
#define __LOADRUN_H

#include <stdio.h>

#define byte unsigned char
#define sbyte signed char

#define PLAYER '@'
#define ENEMY '&'
#define GOLD '$'
#define BRICK '#'
#define INVBRICK 'V'
#define SOLID 'X'
#define LADDER 'H'
#define ROPE '-'
#define BORDER '['
#define BORDERR ']'
#define EMPTY ' '
#define LADDEREND '|'
#define BRICKHALF '~'
#define HOLE '_'

#ifndef __CC65__
#define JOYKEYUP 1
#define JOYKEYDOWN 2
#define JOYKEYLEFT 4
#define JOYKEYRIGHT 8
#define JOYKEYY 16
#define JOYKEYX 32
#define JOYKEYC 64
#define JOYKEYESC 128
#endif

#ifdef __CC65__
#define GOLDV 128
#define BRICKV GOLDV+1
#define SOLIDV BRICKV+1
#define LADDERV SOLIDV+1
#define ROPEV LADDERV+1
#define BRICKHALFV ROPEV+1
#define HOLEV BRICKHALFV+1
#define PLAYERVR1 HOLEV+1
#define PLAYERVR2 PLAYERVR1+1
#define PLAYERVR3 PLAYERVR2+1
#define PLAYERVL1 PLAYERVR3+1
#define PLAYERVL2 PLAYERVL1+1
#define PLAYERVL3 PLAYERVL2+1
#define PLAYERVD1 PLAYERVL3+1
#define PLAYERVD2 PLAYERVD1+1
#define PLAYERVD3 PLAYERVD2+1
#define PLAYERVF1 PLAYERVD3+1
#define PLAYERVF2 PLAYERVF1+1
#define PLAYERVF3 PLAYERVF2+1
#define PLAYERVRR1 PLAYERVF3+1
#define PLAYERVRR2 PLAYERVRR1+1
#define PLAYERVRR3 PLAYERVRR2+1
#define PLAYERVRL1 PLAYERVRR3+1
#define PLAYERVRL2 PLAYERVRL1+1
#define PLAYERVRL3 PLAYERVRL2+1
#define ENEMYVR1 PLAYERVRL3+1
#define ENEMYVR2 ENEMYVR1+1
#define ENEMYVR3 ENEMYVR2+1
#define ENEMYVL1 ENEMYVR3+1
#define ENEMYVL2 ENEMYVL1+1
#define ENEMYVL3 ENEMYVL2+1
#define ENEMYVD1 ENEMYVL3+1
#define ENEMYVD2 ENEMYVD1+1
#define ENEMYVD3 ENEMYVD2+1
#define ENEMYVF1 ENEMYVD3+1
#define ENEMYVF2 ENEMYVF1+1
#define ENEMYVF3 ENEMYVF2+1
#define ENEMYVRR1 ENEMYVF3+1
#define ENEMYVRR2 ENEMYVRR1+1
#define ENEMYVRR3 ENEMYVRR2+1
#define ENEMYVRL1 ENEMYVRR3+1
#define ENEMYVRL2 ENEMYVRL1+1
#define ENEMYVRL3 ENEMYVRL2+1
#else
#define GOLDV '$'
#define BRICKV '#'
#define SOLIDV 'X'
#define LADDERV 'H'
#define ROPEV '-'
#define BRICKHALFV '~'
#define HOLEV ' '
#define PLAYERVR1 'd'
#define PLAYERVR2 EMPTY
#define PLAYERVR3 EMPTY
#define PLAYERVL1 PLAYERVR1
#define PLAYERVL2 EMPTY
#define PLAYERVL3 EMPTY
#define PLAYERVD1 PLAYERVR1
#define PLAYERVD2 EMPTY
#define PLAYERVD3 EMPTY
#define PLAYERVF1 PLAYERVR1
#define PLAYERVF2 EMPTY
#define PLAYERVF3 EMPTY
#define PLAYERVRR1 PLAYERVR1
#define PLAYERVRR2 EMPTY
#define PLAYERVRR3 EMPTY
#define PLAYERVRL1 PLAYERVR1
#define PLAYERVRL2 EMPTY
#define PLAYERVRL3 EMPTY
#define ENEMYVR1 'e'
#define ENEMYVR2 EMPTY
#define ENEMYVR3 EMPTY
#define ENEMYVL1 ENEMYVR1
#define ENEMYVL2 EMPTY
#define ENEMYVL3 EMPTY
#define ENEMYVD1 ENEMYVR1
#define ENEMYVD2 EMPTY
#define ENEMYVD3 EMPTY
#define ENEMYVF1 ENEMYVR1
#define ENEMYVF2 EMPTY
#define ENEMYVF3 EMPTY
#define ENEMYVRR1 ENEMYVR1
#define ENEMYVRR2 EMPTY
#define ENEMYVRR3 EMPTY
#define ENEMYVRL1 ENEMYVR1
#define ENEMYVRL2 EMPTY
#define ENEMYVRL3 EMPTY
#endif

#define PLAYERFIRSTCHAR PLAYERVR1
#define ENEMYFIRSTCHAR ENEMYVR1

#define NONE 0
#define RIGHT 1
#define LEFT 2
#define DOWN 3
#define UP 4

#define SPEEDPLAYER 10
#define SPEEDENEMY 20
#define SPEEDDIGHOLE 10
#define SPEEDHOLE 50
#define SPEEDENEMYINHOLE 10

#define MAXHOLES 10
#define MAXENEMIES 6

#define STARTANIMCNT 5

#define NUMOFSTEPSTOHOLDGOLD 15

#define BEEPLEN 15

#define SCORE_ENEMYINHOLE 75

#define DIMPFX 40
#define DIMPFY 24

#define TRUE 1
#define FALSE 0

#define pf(x, y) playfield[((byte)(x))+((byte)(y))*DIMPFX]
#define oripf(x, y) oriplayfield[((byte)(x))+((byte)(y))*DIMPFX]
#define backuppf(x, y) backupplayfield[((byte)(x))+((byte)(y))*DIMPFX]

struct s_movesprite {
  byte sprite;
  byte spriteVR1;
  byte spriteVR2;
  byte spriteVR3;
  byte spriteVL1;
  byte spriteVL2;
  byte spriteVL3;
  byte spriteVD1;
  byte spriteVD2;
  byte spriteVD3;
  byte spriteVF1;
  byte spriteVF2;
  byte spriteVF3;
  byte spriteVRR1;
  byte spriteVRR2;
  byte spriteVRR3;
  byte spriteVRL1;
  byte spriteVRL2;
  byte spriteVRL3;
  byte spriteVnext;
  byte actx;
  byte acty;
  byte oldx;
  byte oldy;
  byte ismoving;
  byte hasgold;
  byte justoutofhole;
  byte state;
  byte timeinhole;
  byte timelastmove;
};
enum movespritestates { MOVESPRITE_NOTACTIVE, MOVESPRITE_NORMAL, MOVESPRITE_INHOLE, MOVESPRITE_DIED };

struct s_hole {
  byte state;
  byte x;
  byte y;
  byte time;
  byte timelastupdate;
};
enum holestates { HOLE_NOTACTIVE, HOLE_START, HOLE_HALF, HOLE_WAIT, HOLE_HALF2, HOLE_END };

// prototypes for level.c
byte readnextlevel(FILE *f, byte skipflag);
void showlevel(byte levelnr);
byte readactlevel(char *name);
void writeactlevel(char *name, byte level);
void seeklevel(FILE *f, FILE *flri, byte levelnr);
void showtitlescreen();
void showendscreen();

// prototypes for utils.c
void setchar(byte x, byte y, byte ch);
void printnumofjewels();
void beep2(byte sndconst, byte len);
#ifdef __CC65__
void defchars();
#else
byte r162getjoykey();
byte r162getbytetime();
void r162startbeep(byte sndconst);
void r162stopbeep();
#endif

// prototypes for move.c
void movesprite2(struct s_movesprite* movespritestruct);
void moveplayer(struct s_movesprite* moveplayerstruct, byte joykey);
void dighole(struct s_hole* hole);
void moveenemy(struct s_movesprite* enemy, struct s_movesprite* moveplayerstruct);

#endif /* __LOADRUN_H */
