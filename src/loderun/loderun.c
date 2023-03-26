#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ncurses.h>
#include "loderun.h"
#ifdef __CC65__
#include <r162.h>
#endif

FILE *f = NULL;
FILE *flri = NULL;
byte *playfield = NULL;
byte *oriplayfield = NULL;
byte *backupplayfield = NULL;
byte startx, starty;
byte width, height;
byte maxx, maxy;
struct s_movesprite moveplayerstruct;
struct s_movesprite enemies[MAXENEMIES];
struct s_hole holes[MAXHOLES];
byte jewels;
byte acthole;
byte maxenemynum;
byte playerdied;
unsigned int score;
byte beepcnt;

void setmovementtimes(byte acttime) {
  byte i, j, k;
  j = 0;
  k = SPEEDENEMY/maxenemynum;
  for (i = 0; i < maxenemynum; i++) {
    enemies[i].timelastmove = acttime+j;
    j += k;
  }
  moveplayerstruct.timelastmove = acttime+1;
}

void addhiddenladders() {
  byte x, y;
  attron(COLOR_PAIR(1));
  for (y = 0; y < maxy; y++) {
    for (x = 0; x < maxx; x++) {
      byte v = backuppf(x, y);
      if (v == LADDEREND) {
        oripf(x, y) = LADDER;
        pf(x, y) = LADDER;
        mvaddch(starty+y, startx+x, LADDERV);
      }
    }
  }
  attroff(COLOR_PAIR(1));
  for (x = 0; x < 15; x++) beep2(65-x, 5);
  for (x = 0; x < 15; x++) beep2(50+x, 5);
}

void endgame() {
  if (f) fclose(f);
  if (flri) fclose(flri);
  if (playfield) free(playfield);
  if (oriplayfield) free(oriplayfield);
  if (backupplayfield) free(backupplayfield);
  endwin();
}


int main(int argc, char *argv[]) {
  char filenamebuf[30];
  byte levelnr;
  byte key;
  byte quit = FALSE;
  byte lriavailable = FALSE;
  char* strptr;
#ifdef DEBUG
#ifdef __CC65__
  byte* ptr = (byte*)(TEXTMAPDEFAULT+800);
  byte* ptr2 = (byte*)(TEXTMAPDEFAULT+840);
#endif
#endif

  // open level file
  if (argc >= 2) {
    strncpy(filenamebuf, argv[1], 13);
  }
  else {
#ifdef __CC65__
    strcpy(filenamebuf, "/DATA/LODERUN/ORIGINAL.TXT");
#else
    strcpy(filenamebuf, "ORIGINAL.TXT");
#endif
  }
  if ((f = fopen(filenamebuf, "r")) == NULL) {
    printf("could not open level file\n");
    return 1;
  }

  // try to open index file
  if ((strptr = strrchr(filenamebuf, '.')) != NULL) {
    *(++strptr) = '\0';
    strcat(filenamebuf, "LRI");
  }
  else {
    strcat(filenamebuf, ".LRI");
  }
  if ((flri = fopen(filenamebuf, "r")) != NULL) lriavailable = TRUE;

  // prepare "act level" filename
  if (lriavailable) {
    strptr = strrchr(filenamebuf, '.');
    *(++strptr) = '\0';
    strcat(filenamebuf, "LEV");
  }

  // init ncurses
  initscr();
  keypad(stdscr, TRUE);
  nodelay(stdscr, TRUE);
  curs_set(0);
  noecho();
  getmaxyx(stdscr, height, width);
#ifndef __CC65__
  if ((width < DIMPFX) || (height < DIMPFY)) {
    endgame();
    printf("terminal screen is too small!\n");
    return 1;
  }
#endif

  start_color();
#ifndef __CC65__
  init_pair(1, COLOR_WHITE, COLOR_BLACK);
  init_pair(2, COLOR_RED, COLOR_BLACK);
  init_pair(3, COLOR_BLUE, COLOR_BLACK);
  init_pair(4, COLOR_YELLOW, COLOR_BLACK);
#else
  defchars();
  init_pair(1, COLOR_WHITE, COLOR_BLACK);
  init_pair(2, COLOR_ORANGE, COLOR_BLACK);
  init_pair(3, COLOR_LIGHTBLUE, COLOR_BLACK);
  init_pair(4, COLOR_YELLOW, COLOR_BLACK);
#endif

  // allocate memory
  playfield = malloc(DIMPFX*DIMPFY);
  oriplayfield = malloc(DIMPFX*DIMPFY);
  backupplayfield = malloc(DIMPFX*DIMPFY);
  if ((playfield == NULL) || (oriplayfield == NULL) || (backupplayfield == NULL)) {
    endgame();
    printf("not enough memory available\n");
    return 1;
  }

  // show title screen, wait for start
  levelnr = 1;
  showtitlescreen();
  while (TRUE) {
    key = getch();
    if (key == 's') {
      break;
    }
    else if (key == 'r') {
      if (lriavailable) levelnr = readactlevel(filenamebuf);
      if (levelnr != 1) seeklevel(f, flri, levelnr);
      break;
    }
  }

  // load level main loop
  playerdied = FALSE;
  while (TRUE) {
    byte acttime = 0;
    byte difftime;
    byte leveldone = FALSE;
    byte oldtime = 0;
    byte i = 0;

#ifdef DEBUG
#ifdef __CC65__
    byte maxtime = 0;
#endif
#endif

    // read and show level
    maxenemynum = 0;
    if (! playerdied) {
      if (! readnextlevel(f, FALSE)) break;
      startx = (width-maxx)/2;
      starty = (height-maxy)/2;
    }
    else {
      playerdied = FALSE;
    }
    showlevel(levelnr);
    printnumofjewels();

    // wait for key press to start level
    while ((key = r162getjoykey()) == 0) {
      i++;
      if (i%STARTANIMCNT == 0) setchar(moveplayerstruct.actx, moveplayerstruct.acty, EMPTY);
      else setchar(moveplayerstruct.actx, moveplayerstruct.acty, moveplayerstruct.spriteVR1);
    }
    if (key & JOYKEYESC) {
      quit = TRUE;
      break;
    }

    // set times for movements
    acttime = r162getbytetime();
    setmovementtimes(acttime);

    // level main loop
    beepcnt = 0;
    while (! leveldone) {
      byte joykey;

      oldtime = acttime;
      acttime = r162getbytetime();
      difftime = acttime-oldtime;

      // beep sound handling
      if (beepcnt) {
        beepcnt += difftime;
        if (beepcnt >= BEEPLEN) {
          beepcnt = 0;
          r162stopbeep();
        }
      }

#ifdef DEBUG
#ifdef __CC65__
      *ptr = difftime+48;
      if (difftime > maxtime) {
        maxtime = difftime;
        *ptr2 = maxtime+48;
      }
#endif
#endif

      // move player
      difftime = acttime-moveplayerstruct.timelastmove;
      if (difftime >= SPEEDPLAYER) {
        moveplayerstruct.timelastmove = acttime;
        difftime = 0;
        joykey = r162getjoykey();
        if (joykey & JOYKEYC) moveplayerstruct.state = MOVESPRITE_DIED;
        moveplayer(&moveplayerstruct, joykey);
        if (playerdied) leveldone = TRUE;
        if (moveplayerstruct.hasgold) {
          r162startbeep(80);
          beepcnt = 1;
          moveplayerstruct.hasgold = FALSE;
          jewels--;
          printnumofjewels();
          if (jewels == 0) {
            addhiddenladders();
            acttime = r162getbytetime();
            setmovementtimes(acttime);
            for (i = 0; i < maxenemynum; i++) {
              if (enemies[i].ismoving) movesprite2(&enemies[i]);
            }
            for (i = 0; i < MAXHOLES; i++) {
              struct s_hole* hole = &holes[i];
              if (hole->state != HOLE_NOTACTIVE) {
                hole->timelastupdate = acttime;
              }
            }
            difftime = SPEEDPLAYER/2;
          }
        }
      }
      if (moveplayerstruct.ismoving && (difftime >= SPEEDPLAYER/2)) {
        movesprite2(&moveplayerstruct);
        if ((jewels == 0) && (moveplayerstruct.acty == 1)) {
          levelnr++;
          writeactlevel(filenamebuf, levelnr);
          leveldone = TRUE;
          for (i = 0; i < 15; i++) beep2(65-i, 5);
        }
      }

      // handle holes
      for (i = 0; i < MAXHOLES; i++) {
        struct s_hole* hole = &holes[i];
        if (hole->state != HOLE_NOTACTIVE) {
          difftime = acttime-hole->timelastupdate;
          if (difftime >= SPEEDDIGHOLE) {
            hole->timelastupdate = acttime;
            dighole(hole);
          }
        }
      }

      // move enemies
      for (i = 0; i < maxenemynum; i++) {
        difftime = acttime-enemies[i].timelastmove;
        if (difftime >= SPEEDENEMY) {
          enemies[i].timelastmove = acttime;
          //difftime = 0;
          moveenemy(&enemies[i], &moveplayerstruct);
          break;
        }
        if (enemies[i].ismoving && (difftime >= SPEEDENEMY/2)) {
          movesprite2(&enemies[i]);
        }
      }

      refresh();
    }
  }
  if (! quit) {
    showendscreen();
    nodelay(stdscr, FALSE);
    key = getch();
  }
  endgame();
  return 0;
}
