// sokoban, v1.0, c code
// written for the R162 (see
// https://sites.google.com/site/retroelec/retroelecs-electronics-projects/r162)
//
// Copyright (C) 2010-2020 retroelec <retroelec42@gmail.com>
//
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the
// Free Software Foundation; either version 3 of the License, or (at your
// option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
// for more details.
//
// For the complete text of the GNU General Public License see
// www.gnu.org/licenses/.

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <ncurses.h>

#define byte unsigned char
#define schar signed char

#define PLAYER '@'
#define PLAYERGOAL '+'
#define GOAL '.'
#define JEWEL '$'
#define JEWELGOAL '*'
#define WALL '#'
#define EMPTY ' '
#define COMMENT ';'

#define UNDO_DOWN 2
#define UNDO_LEFT 4
#define UNDO_RIGHT 6
#define UNDO_UP 8

#define DIMPFX 40
#define DIMPFY 24
#define UNDOBUFFERSIZE 1024

#define TRUE 1
#define FALSE 0

#define pf(x, y) playfield[((byte)(x))+((byte)(y))*DIMPFX]
#define oripf(x, y) oriplayfield[((byte)(x))+((byte)(y))*DIMPFX]

// global variables
FILE *f = NULL;
char *playfield = NULL;
char *oriplayfield = NULL;
byte plx, ply;
byte maxx, maxy;
byte *undobuffer = NULL;
short undoidx;
byte startx, starty;
short width, height;
int jewels;
int levelnr;
char str[10];


void setchar(byte x, byte y, char ch)
{
  switch (ch) {
  case WALL:
#ifdef __CC65__
    attron(COLOR_PAIR(1));
#endif
    mvaddch(starty+y, startx+x, ch);
#ifdef __CC65__
    attroff(COLOR_PAIR(1));
#endif
    break;
  case GOAL:
#ifdef __CC65__
    attron(COLOR_PAIR(2));
#endif
    mvaddch(starty+y, startx+x, ch);
#ifdef __CC65__
    attroff(COLOR_PAIR(2));
#endif
    break;
  case JEWEL:
#ifdef __CC65__
    attron(COLOR_PAIR(3));
#endif
    mvaddch(starty+y, startx+x, ch);
#ifdef __CC65__
    attroff(COLOR_PAIR(3));
#endif
    break;
  case JEWELGOAL:
#ifdef __CC65__
    attron(COLOR_PAIR(4));
#endif
    mvaddch(starty+y, startx+x, ch);
#ifdef __CC65__
    attroff(COLOR_PAIR(4));
#endif
    break;
  case PLAYER:
  case PLAYERGOAL:
#ifdef __CC65__
    attron(COLOR_PAIR(5));
#endif
    mvaddch(starty+y, startx+x, ch);
#ifdef __CC65__
    attroff(COLOR_PAIR(5));
#endif
    break;
  default:
    mvaddch(starty+y, startx+x, ch);
  }
}


void moveplayer(schar dx1, schar dy1)
{
  char o = 0;
  pf(plx+dx1, ply+dy1) = PLAYER;
  setchar(plx+dx1, ply+dy1, PLAYER);
  o = oripf(plx, ply);
  pf(plx, ply) = o;
  setchar(plx, ply, o);
  plx += dx1;
  ply += dy1;
}


void movejewel(schar dx2, schar dy2, char actval)
{
  if (actval == GOAL) {
    pf(plx+dx2, ply+dy2) = JEWELGOAL;
    setchar(plx+dx2, ply+dy2, JEWELGOAL);
    jewels--;
  }
  else {
    pf(plx+dx2, ply+dy2) = JEWEL;
    setchar(plx+dx2, ply+dy2, JEWEL);
  }
}


void updundobuf(byte undodir)
{
  undobuffer[undoidx++] = undodir;
  if (undoidx >= UNDOBUFFERSIZE) {
    move(height-1, 1);
    printw("undo buffer is full!");
    undoidx = 0;
  }
}


void undomove(schar dx, schar dy)
{
  char o = 0;
  schar dx2 = -2*dx;
  schar dy2 = -2*dy;
  byte jewelposx = 0;
  byte jewelposy = 0;
  moveplayer(dx, dy);
  movejewel(-dx, -dy, pf(plx-dx, ply-dy));
  jewelposx = plx+dx2;
  jewelposy = ply+dy2;
  o = oripf(jewelposx, jewelposy);
  if (o == GOAL) jewels++;
  pf(jewelposx, jewelposy) = o;
  setchar(jewelposx, jewelposy, o);
}


byte moveinpf(schar dx1, schar dy1, byte undodir)
{
  schar dx2 = 2*dx1;
  schar dy2 = 2*dy1;
  char m = pf(plx+dx1, ply+dy1);
  if ((m == EMPTY) || (m == GOAL)) {
    moveplayer(dx1, dy1);
    updundobuf(undodir);
  }
  else if ((m == JEWEL) || (m == JEWELGOAL)) {
    char m2 = pf(plx+dx2, ply+dy2);
    if ((m2 == EMPTY) || (m2 == GOAL)) {
      if (m == JEWELGOAL) jewels++;
      movejewel(dx2, dy2, m2);
      moveplayer(dx1, dy1);
      updundobuf(undodir+1);
      if (jewels == 0) return TRUE;
    }
  }
  return FALSE;
}


byte checkline(char *bufline)
{
  char ch = 0;
  do {
    ch = *bufline++;
    if (ch == WALL) return TRUE;
    else if (ch == COMMENT) return FALSE;
  } while ((ch != '\n') && (ch != '\0'));
  return FALSE;
}


byte putlevellinetopf(char *bufline, byte y)
{
  char ch = 0;
  byte x = 0;
  do {
    ch = *bufline++;
    pf(x, y) = ch;
    switch (ch) {
    case JEWELGOAL:
    case PLAYERGOAL:
      oripf(x, y) = GOAL;
      break;
    case JEWEL:
      jewels++;
    case PLAYER:
      oripf(x, y) = EMPTY;
      break;
    default:
      oripf(x, y) = ch;
    }
    if ((ch == PLAYER) || (ch == PLAYERGOAL)) {
      plx = x;
      ply = y;
    }
    x++;
  } while ((ch != '\n') && (ch != '\0'));
  return x;
}


void clearpf()
{
  byte x = 0;
  byte y = 0;
  for (y = 0; y < DIMPFY; y++) {
    for (x = 0; x < DIMPFX; x++) {
      pf(x, y) = EMPTY;
    }
  }
}


byte readnextlevel(FILE *f, byte skipflag)
{
  byte y = 0;
  byte found = FALSE;
  char bufline[DIMPFX+1];
  clearpf();
  jewels = 0;
  do {
    fgets(bufline, DIMPFX+1, f);
    if (feof(f)) return FALSE;
    found = checkline(bufline);
  } while (! found);
  // start of level definitons found
  maxx = maxy = 0;
  while (found) {
    if (! skipflag) {
      byte x = 0;
      if (y >= DIMPFY) return FALSE;
      x = putlevellinetopf(bufline, y++);
      if (x > maxx) maxx = x;
    }
    fgets(bufline, DIMPFX+1, f);
    found = checkline(bufline);
    if (feof(f)) break;
  }
  maxy = y;
  return TRUE;
}


byte gotolevel(FILE *f, int level)
{
  int i = 0;
  int ret = TRUE;
  if (level <= levelnr) {
    rewind(f);
    if (level < 1) level = 1;
  }
  else {
    level -= levelnr;
  }
  level--;
  // overread levels
  for (i = 0; i < level; i++) {
    ret = readnextlevel(f, TRUE);
    if (! ret) return ret;
  }
  return ret;
}


void showlevel()
{
  byte x = 0;
  byte y = 0;
  char v = 0;
  clear();
  for (y = 0; y < maxy; y++) {
    for (x = 0; x < maxx; x++) {
      v = pf(x, y);
      setchar(x, y, v);
    }
  }
  move(height-1, 1);
  sprintf(str, "%d", levelnr);
  printw(" level: ");
  printw(str);
  move(height-1, 1);
  refresh();
}


void endsoko()
{
  if (playfield) free(playfield);
  if (oriplayfield) free(oriplayfield);
  if (undobuffer) free(undobuffer);
  if (f) fclose(f);
  endwin();
}


int main(int argc, char *argv[])
{
  int key;
  byte u;
  int levelskiped = FALSE;
#ifdef __CC65__
  byte walldef[8] = { 254, 254, 254, 0, 247, 247, 247, 0 };
  byte goaldef[8] = { 0, 60, 126, 126, 126, 126, 60, 0 };
  byte jeweldef[8] = { 255, 129, 185, 181, 173, 157, 129, 255 };
  byte playerdef[8] = { 24, 24, 60, 126, 60, 60, 36, 36 };
#endif

  // init terminal screen
  initscr();
  keypad(stdscr, TRUE);
  noecho();
  getmaxyx(stdscr, height, width);
#ifndef __CC65__
  if ((width < DIMPFX) || (height < DIMPFY)) {
    endsoko();
    printf("terminal screen is too small!\n");
    return 1;
  }
#else
  defch(PLAYER, playerdef);
  defch(PLAYERGOAL, playerdef);
  defch(GOAL, goaldef);
  defch(JEWEL, jeweldef);
  defch(JEWELGOAL, jeweldef);
  defch(WALL, walldef);
  start_color();
  init_pair(1, COLOR_WHITE, COLOR_BLACK);
  init_pair(2, COLOR_LIGHTGREEN, COLOR_BLACK);
  init_pair(3, COLOR_YELLOW, COLOR_DARKGREEN);
  init_pair(4, COLOR_RED, COLOR_ORANGE);
  init_pair(5, COLOR_BLUE, COLOR_BLACK);
  init_pair(6, COLOR_YELLOW, COLOR_BLACK);
#endif

  // allocate
  playfield = malloc(DIMPFX*DIMPFY);
  oriplayfield = malloc(DIMPFX*DIMPFY);
  undobuffer = malloc(UNDOBUFFERSIZE);
  if ((playfield == NULL) || (oriplayfield == NULL) || (undobuffer == NULL)) {
    printw("not enough memory available");
    refresh();
    getch();
    endsoko();
    return 1;
  }

  // open level file
  if (argc >= 2) {
    f = fopen(argv[1], "r");
  }
  else {
    f = fopen("SOKOORI.TXT", "r");
  }
  if (f == NULL) {
    printw("could not open file ");
    refresh();
    getch();
    endsoko();
    return 1;
  }

  // start screen
#ifdef __CC65__
  attron(COLOR_PAIR(6));
#endif
  move(height-18, 0);
  printw("  ###  ##  #   #  ##  ###    #   #    #");
  move(height-17, 0);
  printw(" #    #  # #  #  #  # #  #  # #  ##   #");
  move(height-16, 0);
  printw(" #    #  # # #   #  # #  # #   # # #  #");
  move(height-15, 0);
  printw("  ##  #  # ##    #  # ###  ##### # #  #");
  move(height-14, 0);
  printw("    # #  # # #   #  # #  # #   # #  # #");
  move(height-13, 0);
  printw("    # #  # #  #  #  # #  # #   # #   ##");
  move(height-12, 0);
  printw(" ###   ##  #   #  ##  ###  #   # #    #");
#ifdef __CC65__
  attroff(COLOR_PAIR(6));
#endif
  move(height-3, 1);
  printw("cursor keys: move player  u: undo move");
  move(height-2, 1);
  printw("n: next level  g: goto level  q: quit");
  move(height-1, 1);
  printw("press any key to start");

  move(height-1, 1);
  printw("press any key to start");
  refresh();
  getch();

  // load next level
  levelnr = 0;
  while (readnextlevel(f, FALSE)) {
    byte done = FALSE;
    levelnr++;
    undoidx = 0;
    startx = (width-maxx)/2;
    starty = (height-maxy)/2;
    showlevel();
    // level main loop
    levelskiped = FALSE;
    while (! done) {
      key = getch();
      switch (key) {
      case 'q':
      case 'Q':
        endsoko();
        return 0;
      case 'n':
      case 'N':
        levelskiped = TRUE;
        done = TRUE;
        break;
      case 'u':
      case 'U':
        if (undoidx > 0) {
          u = undobuffer[--undoidx];
          switch (u) {
          case UNDO_DOWN:
            moveplayer(0, -1);
            break;
          case UNDO_UP:
            moveplayer(0, 1);
            break;
          case UNDO_RIGHT:
            moveplayer(-1, 0);
            break;
          case UNDO_LEFT:
            moveplayer(1, 0);
            break;
          case UNDO_DOWN+1:
            undomove(0, -1);
            break;
          case UNDO_UP+1:
            undomove(0, 1);
            break;
          case UNDO_RIGHT+1:
            undomove(-1, 0);
            break;
          case UNDO_LEFT+1:
            undomove(1, 0);
            break;
          }
        }
        break;
      case KEY_DOWN:
        done = moveinpf(0, 1, UNDO_DOWN);
        break;
      case KEY_UP:
        done = moveinpf(0, -1, UNDO_UP);
        break;
      case KEY_RIGHT:
        done = moveinpf(1, 0, UNDO_RIGHT);
        break;
      case KEY_LEFT:
        done = moveinpf(-1, 0, UNDO_LEFT);
        break;
      case 'g':
      case 'G':
        move(height-2, 1);
        printw("goto level: ");
        echo();
        getstr(str);
        noecho();
        levelnr = atoi(str);
        gotolevel(f, levelnr);
        levelnr--;
        move(height-1, 1);
        levelskiped = TRUE;
        done = TRUE;
        break;
      }
      move(height-1, 1);
      refresh();
    }
    // level finished (or skipped)
    move(height-2, 1);
    printw("level ");
    if (levelskiped) printw("skipped  ");
    else printw("finished!");
    move(height-1, 1);
    printw("press any key for next level");
    refresh();
    getch();
  }
  move(height-2, 1);
  printw("no further levels");
  move(height-1, 1);
  printw("press any key");
  refresh();
  getch();
  endsoko();
  return 0;
}
