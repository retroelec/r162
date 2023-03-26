#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ncurses.h>
#include "loderun.h"

extern byte *playfield;
extern byte *oriplayfield;
extern byte *backupplayfield;
extern struct s_movesprite moveplayerstruct;
extern struct s_movesprite enemies[MAXENEMIES];
extern struct s_hole holes[MAXHOLES];
extern byte maxenemynum;
extern byte acthole;
extern byte jewels;
extern byte maxx;
extern byte maxy;
extern byte height;

void addplayer() {
  moveplayerstruct.sprite = PLAYER;
  moveplayerstruct.spriteVR1 = PLAYERVR1;
  moveplayerstruct.spriteVR2 = PLAYERVR2;
  moveplayerstruct.spriteVR3 = PLAYERVR3;
  moveplayerstruct.spriteVL1 = PLAYERVL1;
  moveplayerstruct.spriteVL2 = PLAYERVL2;
  moveplayerstruct.spriteVL3 = PLAYERVL3;
  moveplayerstruct.spriteVD1 = PLAYERVD1;
  moveplayerstruct.spriteVD2 = PLAYERVD2;
  moveplayerstruct.spriteVD3 = PLAYERVD3;
  moveplayerstruct.spriteVF1 = PLAYERVF1;
  moveplayerstruct.spriteVF2 = PLAYERVF2;
  moveplayerstruct.spriteVF3 = PLAYERVF3;
  moveplayerstruct.spriteVRR1 = PLAYERVRR1;
  moveplayerstruct.spriteVRR2 = PLAYERVRR2;
  moveplayerstruct.spriteVRR3 = PLAYERVRR3;
  moveplayerstruct.spriteVRL1 = PLAYERVRL1;
  moveplayerstruct.spriteVRL2 = PLAYERVRL2;
  moveplayerstruct.spriteVRL3 = PLAYERVRL3;
  moveplayerstruct.ismoving = FALSE;
  moveplayerstruct.hasgold = FALSE;
  moveplayerstruct.justoutofhole = FALSE;
  moveplayerstruct.state = MOVESPRITE_NORMAL;
}

void initenemies() {
  byte i;
  for (i = 0; i < MAXENEMIES; i++) {
    enemies[i].state = MOVESPRITE_NOTACTIVE;
  }
}

void addenemy(byte x, byte y) {
  if (maxenemynum < MAXENEMIES) {
    enemies[maxenemynum].sprite =  ENEMY;
    enemies[maxenemynum].spriteVR1 = ENEMYVR1;
    enemies[maxenemynum].spriteVR2 = ENEMYVR2;
    enemies[maxenemynum].spriteVR3 = ENEMYVR3;
    enemies[maxenemynum].spriteVL1 = ENEMYVL1;
    enemies[maxenemynum].spriteVL2 = ENEMYVL2;
    enemies[maxenemynum].spriteVL3 = ENEMYVL3;
    enemies[maxenemynum].spriteVD1 = ENEMYVD1;
    enemies[maxenemynum].spriteVD2 = ENEMYVD2;
    enemies[maxenemynum].spriteVD3 = ENEMYVD3;
    enemies[maxenemynum].spriteVF1 = ENEMYVF1;
    enemies[maxenemynum].spriteVF2 = ENEMYVF2;
    enemies[maxenemynum].spriteVF3 = ENEMYVF3;
    enemies[maxenemynum].spriteVRR1 = ENEMYVRR1;
    enemies[maxenemynum].spriteVRR2 = ENEMYVRR2;
    enemies[maxenemynum].spriteVRR3 = ENEMYVRR3;
    enemies[maxenemynum].spriteVRL1 = ENEMYVRL1;
    enemies[maxenemynum].spriteVRL2 = ENEMYVRL2;
    enemies[maxenemynum].spriteVRL3 = ENEMYVRL3;
    enemies[maxenemynum].ismoving = FALSE;
    enemies[maxenemynum].hasgold = FALSE;
    enemies[maxenemynum].justoutofhole = FALSE;
    enemies[maxenemynum].state = MOVESPRITE_NORMAL;
    enemies[maxenemynum].actx = x;
    enemies[maxenemynum].acty = y;
    maxenemynum++;
  }
}

void initholes() {
  int i;
  acthole = 0;
  for (i = 0; i < MAXHOLES; i++) {
    holes[i].state = HOLE_NOTACTIVE;
  }
}

void clearplayfield1() {
  byte x, y;
  for (y = 0; y < DIMPFY; y++) {
    for (x = 0; x < DIMPFX; x++) {
      backuppf(x, y) = EMPTY;
    }
  }
}

void clearplayfield2() {
  byte x, y;
  for (y = 0; y < DIMPFY; y++) {
    for (x = 0; x < DIMPFX; x++) {
      pf(x, y) = EMPTY;
      oripf(x, y) = EMPTY;
    }
  }
}

void putchtopf(byte x, byte y, char ch) {
  pf(x, y) = ch;
  switch (ch) {
  case BORDERR:
    oripf(x, y) = BORDER;
    pf(x, y) = BORDER;
    break;
  case LADDEREND:
    pf(x, y) = EMPTY;
    break;
  case GOLD:
    jewels++;
    break;
  case ENEMY:
    addenemy(x, y);
    break;
  case PLAYER:
    break;
  default:
    oripf(x, y) = ch;
  }
  if (ch == PLAYER) {
    moveplayerstruct.actx = x;
    moveplayerstruct.acty = y;
  }
}

byte putlevellinetopf(char *bufline, byte y) {
  char ch = 0;
  byte x = 0;
  do {
    ch = *bufline++;
    backuppf(x, y) = ch;
    x++;
  } while ((ch != '\n') && (ch != '\0'));
  return --x;
}

byte readnextlevel(FILE *f, byte skipflag) {
  byte x, y;
  char ch;
  char bufline[DIMPFX+1];
  // clear playfield
  clearplayfield1();
  // search for start of level definitons
  do {
    fgets(bufline, DIMPFX+1, f);
    if (feof(f)) return FALSE;
    ch = *bufline;
  } while (ch != BORDER);
  // read level definitons line by line
  y = 1;
  maxx = maxy = 0;
  do {
    if (! skipflag) {
      byte x = 0;
      if (y >= DIMPFY) return FALSE;
      x = putlevellinetopf(bufline, y++);
      if (x > maxx) maxx = x;
    }
    fgets(bufline, DIMPFX+1, f);
    ch = *bufline;
    if (feof(f)) break;
  } while (ch == BORDER);
  maxy = y+1;
  // set border at top and bottom of playfield
  for (x = 0; x < maxx; x++) {
    backuppf(x, 0) = BORDER;
    backuppf(x, y) = SOLID;
  }
  backuppf(0, y) = BORDER;
  backuppf(maxx-1, y) = BORDER;
  return TRUE;
}

void showlevel(byte levelnr) {
  char str[10];
  byte x = 0;
  byte y = 0;
  byte v = 0;
  clear();
  clearplayfield2();
  addplayer();
  initenemies();
  initholes();
  jewels = 0;
  for (y = 0; y < maxy; y++) {
    for (x = 0; x < maxx; x++) {
      putchtopf(x, y, backuppf(x, y));
      v = pf(x, y);
      switch (v) {
      case ENEMY:
        v = ENEMYVR1;
        break;
      case PLAYER:
        v = PLAYERVR1;
        break;
      }
      setchar(x, y, v);
    }
  }
  move(height-1, 2);
  sprintf(str, "%03d", levelnr);
  printw("level  ");
  printw(str);
  move(height-1, 20);
  printw("gold bars left  ");
  printnumofjewels();
  refresh();
}

byte readactlevel(char *name) {
  FILE *f;
  char buf[4];
  if ((f = fopen(name, "r")) == NULL) return 1;
  fgets(buf, 4, f);
  fclose(f);
  return atoi(buf);
}

void writeactlevel(char *name, byte level) {
  FILE *f;
  char buf[4];
  if ((f = fopen(name, "w")) == NULL) return;
  sprintf(buf, "%d", level);
  fputs(buf, f);
  fclose(f);
}

int getfidxoflevel(FILE *flri, byte levelnr) {
  int idx = -1;
  long offset = 7*(levelnr-1);
  if ((fseek(flri, offset, SEEK_SET)) == 0) {
    char buf[7];
    fgets(buf, 7, flri);
    idx = atoi(buf);
  }
  return idx;
}

void seeklevel(FILE *f, FILE *flri, byte levelnr) {
  int idx = getfidxoflevel(flri, levelnr);
  if (idx == -1) return;
  fseek(f, idx, SEEK_SET);
}

void stspr1line(char* str, byte y) {
  byte i;
  move(y, 6);
  for (i = 0; i < strlen(str); i++) {
    if (str[i] == '#') {
      addch(BRICKV);
    }
    else {
      addch(EMPTY);
    }
  }
}

void printloderunner(byte y) {
  attron(COLOR_PAIR(2));
  stspr1line("    #    #### ###  ####", y); y++;
  stspr1line("    #    #  # #  # #   ", y); y++;
  stspr1line("    #    #  # #  # ##  ", y); y++;
  stspr1line("    #    #  # #  # #   ", y); y++;
  stspr1line("    #### #### ###  ####", y); y++;
  stspr1line("                       ", y); y++;
  stspr1line("#### #  # #  # #  # ### ####", y); y++;
  stspr1line("#  # #  # ## # ## # #   #  #", y); y++;
  stspr1line("#### #  # # ## # ## ##  ####", y); y++;
  stspr1line("# #  #  # #  # #  # #   # # ", y); y++;
  stspr1line("#  # #### #  # #  # ### #  #", y); y++;
  attroff(COLOR_PAIR(2));
}

void showtitlescreen() {
  byte y = height-20;
  clear();
  printloderunner(y);
  move(height-4, 1);
  printw("press 'r' to resume the last game");
  move(height-3, 1);
  printw("press 's' to start a new game");
  refresh();
}

void showendscreen() {
  byte y = height-20;
  clear();
  printloderunner(y);
  move(height-4, 1);
  printw("Congratulations!!!");
  move(height-3, 1);
  printw("You finished all levels!!!");
  refresh();
}
