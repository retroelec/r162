#include <ncurses.h>
#include "loderun.h"
#ifdef __CC65__
#include <r162.h>
#else
#include <sys/time.h>
#endif

extern byte startx;
extern byte starty;
extern byte jewels;
extern byte height;

void setchar(byte x, byte y, byte ch)
{
  if (ch >= ENEMYFIRSTCHAR) {
    attron(COLOR_PAIR(3));
    mvaddch(starty+y, startx+x, ch);
    attroff(COLOR_PAIR(3));
  }
  else if (ch >= PLAYERFIRSTCHAR) {
    attron(COLOR_PAIR(1));
    mvaddch(starty+y, startx+x, ch);
    attroff(COLOR_PAIR(1));
  }
  else {
    switch (ch) {
    case LADDER:
      attron(COLOR_PAIR(1));
      mvaddch(starty+y, startx+x, LADDERV);
      attroff(COLOR_PAIR(1));
      break;
    case ROPE:
      attron(COLOR_PAIR(1));
      mvaddch(starty+y, startx+x, ROPEV);
      attroff(COLOR_PAIR(1));
      break;
    case HOLE:
      attron(COLOR_PAIR(1));
      mvaddch(starty+y, startx+x, HOLEV);
      attroff(COLOR_PAIR(1));
      break;
    case GOLD:
      attron(COLOR_PAIR(4));
      mvaddch(starty+y, startx+x, GOLDV);
      attroff(COLOR_PAIR(4));
      break;
    case BRICK:
      attron(COLOR_PAIR(2));
      mvaddch(starty+y, startx+x, BRICKV);
      attroff(COLOR_PAIR(2));
      break;
    case SOLID:
      attron(COLOR_PAIR(2));
      mvaddch(starty+y, startx+x, SOLIDV);
      attroff(COLOR_PAIR(2));
      break;
    case BRICKHALF:
      attron(COLOR_PAIR(2));
      mvaddch(starty+y, startx+x, BRICKHALFV);
      attroff(COLOR_PAIR(2));
      break;
    case INVBRICK:
      attron(COLOR_PAIR(2));
      mvaddch(starty+y, startx+x, BRICKV);
      attroff(COLOR_PAIR(2));
      break;
    case BORDER:
      attron(COLOR_PAIR(1));
      mvaddch(starty+y, startx+x, EMPTY);
      attroff(COLOR_PAIR(1));
      break;
    case EMPTY:
      mvaddch(starty+y, startx+x, EMPTY);
      break;
    }
  }
}

void printnumofjewels() {
  char str[3];
  sprintf(str, "%02d", jewels);
  mvprintw(height-1, 36, str);
}

#ifdef __CC65__
void beep2(byte sndconst, byte len) {
  byte acttime = r162getbytetime();
  byte oldtime = acttime;
  r162startbeep(sndconst);
  while ((acttime - oldtime) < len) acttime = r162getbytetime();
  r162stopbeep();
}

void defchars()
{
  byte runner_v1r_def[8] = { 28, 28, 56, 94, 24, 28, 114, 2 };
  byte runner_v2r_def[8] = { 192, 192, 128, 192, 176, 192, 128, 128 };
  byte runner_v3r_def[8] = { 1, 1, 3, 7, 7, 1, 3, 1 };
  byte runner_v1l_def[8] = { 56, 56, 28, 122, 24, 56, 78, 64 };
  byte runner_v2l_def[8] = { 3, 3, 1, 3, 13, 3, 1, 1 };
  byte runner_v3l_def[8] = { 128, 128, 192, 224, 224, 128, 192, 128 };
  byte runner_v1updown_def[8] = { 24, 25, 31, 248, 24, 60, 34, 224 };
  byte runner_v2updown_def[8] = { 24, 60, 68, 7, 0, 0, 0, 0 };
  byte runner_v3updown_def[8] = { 0, 0, 0, 0, 24, 152, 248, 31 };
  byte runner_v1fall_def[8] = { 153, 153, 255, 24, 24, 56, 72, 8 };
  byte runner_v2fall_def[8] = { 24, 56, 72, 8, 0, 0, 0, 0 };
  byte runner_v3fall_def[8] = { 0, 0, 0, 0, 153, 153, 255, 24 };
  byte runner_v1roper_def[8] = { 129, 153, 153, 126, 24, 56, 72, 72 };
  byte runner_v2roper_def[8] = { 128, 128, 128, 224, 144, 192, 64, 64 };
  byte runner_v3roper_def[8] = { 9, 13, 7, 1, 1, 3, 2, 2 };
  byte runner_v1ropel_def[8] = { 129, 153, 153, 126, 24, 28, 18, 18 };
  byte runner_v2ropel_def[8] = { 1, 1, 1, 7, 9, 3, 2, 2 };
  byte runner_v3ropel_def[8] = { 144, 176, 224, 128, 128, 192, 64, 64 };
  byte golddef[8] = { 0, 0, 0, 255, 255, 255, 255, 0 };
  byte brickdef[8] = { 251, 251, 251, 0, 223, 223, 223, 0 };
  byte brickhalfdef[8] = { 0, 0, 0, 0, 223, 223, 223, 0 };
  byte soliddef[8] = { 255, 255, 255, 255, 255, 255, 255, 0 };
  byte ropedef[8] = { 0, 255, 0, 0, 0, 0, 0, 0 };
  byte ladderdef[8] = { 195, 195, 255, 195, 195, 195, 255, 195 };
  byte holedef[8] = { 0, 0, 0, 0, 0, 0, 0, 0 };
  defch(PLAYERVR1, runner_v1r_def);
  defch(PLAYERVR2, runner_v2r_def);
  defch(PLAYERVR3, runner_v3r_def);
  defch(PLAYERVL1, runner_v1l_def);
  defch(PLAYERVL2, runner_v2l_def);
  defch(PLAYERVL3, runner_v3l_def);
  defch(PLAYERVD1, runner_v1updown_def);
  defch(PLAYERVD2, runner_v2updown_def);
  defch(PLAYERVD3, runner_v3updown_def);
  defch(PLAYERVF1, runner_v1fall_def);
  defch(PLAYERVF2, runner_v2fall_def);
  defch(PLAYERVF3, runner_v3fall_def);
  defch(PLAYERVRR1, runner_v1roper_def);
  defch(PLAYERVRR2, runner_v2roper_def);
  defch(PLAYERVRR3, runner_v3roper_def);
  defch(PLAYERVRL1, runner_v1ropel_def);
  defch(PLAYERVRL2, runner_v2ropel_def);
  defch(PLAYERVRL3, runner_v3ropel_def);
  defch(ENEMYVR1, runner_v1r_def);
  defch(ENEMYVR2, runner_v2r_def);
  defch(ENEMYVR3, runner_v3r_def);
  defch(ENEMYVL1, runner_v1l_def);
  defch(ENEMYVL2, runner_v2l_def);
  defch(ENEMYVL3, runner_v3l_def);
  defch(ENEMYVD1, runner_v1updown_def);
  defch(ENEMYVD2, runner_v2updown_def);
  defch(ENEMYVD3, runner_v3updown_def);
  defch(ENEMYVF1, runner_v1fall_def);
  defch(ENEMYVF2, runner_v2fall_def);
  defch(ENEMYVF3, runner_v3fall_def);
  defch(ENEMYVRR1, runner_v1roper_def);
  defch(ENEMYVRR2, runner_v2roper_def);
  defch(ENEMYVRR3, runner_v3roper_def);
  defch(ENEMYVRL1, runner_v1ropel_def);
  defch(ENEMYVRL2, runner_v2ropel_def);
  defch(ENEMYVRL3, runner_v3ropel_def);
  defch(GOLDV, golddef);
  defch(BRICKV, brickdef);
  defch(SOLIDV, soliddef);
  defch(LADDERV, ladderdef);
  defch(ROPEV, ropedef);
  defch(BRICKHALFV, brickhalfdef);
  defch(HOLEV, holedef);
}
#endif

#ifndef __CC65__
void beep2(byte sndconst, byte len) {
}

byte r162getjoykey() {
  byte retval = 0;
  int ch = getch();
  switch (ch) {
  case KEY_UP:
    retval = JOYKEYUP;
    break;
  case KEY_DOWN:
    retval = JOYKEYDOWN;
    break;
  case KEY_LEFT:
    retval = JOYKEYLEFT;
    break;
  case KEY_RIGHT:
    retval = JOYKEYRIGHT;
    break;
  case 'y':
    retval = JOYKEYY;
    break;
  case 'x':
    retval = JOYKEYX;
    break;
  case 'c':
    retval = JOYKEYC;
    break;
  case 'q':
    retval = JOYKEYESC;
    break;
  }
  return retval;
}

byte r162getbytetime() {
  struct timeval t;

  (void)gettimeofday (&t, 0);
  return (t.tv_sec*50 + t.tv_usec/20000)&255;
}

void r162startbeep(byte sndconst) {
}

void r162stopbeep() {
}
#endif
