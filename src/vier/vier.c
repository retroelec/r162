// four in a row, v1.0, c code
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
#include <ncurses.h>

//#define DEBUG
//#define CHANGELEVEL

#define byte unsigned char
#define pf(x, y) playfield[(x)][(y)]

#define CALCDEPTH 2
#define MAXVAL 32000
#define WINVAL 500

#define DIMX 7
#define DIMY 6
#define IDXMAX (DIMX+1) // max(DIMX, DIMY)+1

#define CENTERX1 (DIMX/2+1)

#define EMPTY 0
#define WHITE 1
#define BLACK 2
#define WALL 3

#define DIMPFX (DIMX+2)
#define DIMPFY (DIMY+2)

#define WHITECHAR 'O'
#define BLACKCHAR 'X'

#define OFFSETX 12
#define OFFSETY 6


// global variables
byte playfield[DIMPFX][DIMPFY];
byte bestmove;
byte dimy, dimx;
byte calcdepth;
byte toggle1, toggle2;

#ifdef DEBUG
byte dbgch;
byte debugon = 0;
#define WHITECHARDBG 'o'
#define BLACKCHARDBG 'x'
void dispchar(byte x, byte y, char character);
#endif


// ------------------------------------------------------------------------


int evaluateColor(byte color)
{
   byte cnt;
   int i;
   byte x, y;
   byte index;
   byte cntarr[3*IDXMAX];
   int sum;

   for (i = 0; i < 3*IDXMAX; i++)
      cntarr[i] = 0;

   for (x = 1; x <= DIMX; x++) {
      y = 1;
      while ((pf(x, y) != EMPTY) && (pf(x, y) != WALL)) y++;
      y--;
      if (pf(x, y) == color) {

         // x direction
         index = 0;
         cnt = 0;
         i = 0;
         while (pf(x+i, y) == color) {
            i++;
            cnt++;
         }
         if (pf(x+i, y) == EMPTY) index += IDXMAX;
         i = 1;
         while (pf(x-i, y) == color) {
            i++;
            cnt++;
         }
         if (pf(x-i, y) == EMPTY) index += IDXMAX;
         cntarr[(index+cnt)]++;

         // y direction
         index = 0;
         cnt = 0;
         i = 0;
         while (pf(x, y+i) == color) {
            i++;
            cnt++;
         }
         if (pf(x, y+i) == EMPTY) index += IDXMAX;
         i = 1;
         while (pf(x, y-i) == color) {
            i++;
            cnt++;
         }
         if (pf(x, y-i) == EMPTY) index += IDXMAX;
         cntarr[(index+cnt)]++;

         // xy direction
         index = 0;
         cnt = 0;
         i = 0;
         while (pf(x+i, y+i) == color) {
            i++;
            cnt++;
         }
         if (pf(x+i, y+i) == EMPTY) index += IDXMAX;
         i = 1;
         while (pf(x-i, y-i) == color) {
            i++;
            cnt++;
         }
         if (pf(x-i, y-i) == EMPTY) index += IDXMAX;
         cntarr[(index+cnt)]++;

         // yx direction
         index = 0;
         cnt = 0;
         i = 0;
         while (pf(x+i, y-i) == color) {
            i++;
            cnt++;
         }
         if (pf(x+i, y-i) == EMPTY) index += IDXMAX;
         i = 1;
         while (pf(x-i, y+i) == color) {
            i++;
            cnt++;
         }
         if (pf(x-i, y+i) == EMPTY) index += IDXMAX;
         cntarr[(index+cnt)]++;
      }
   }

   sum = cntarr[2+2*IDXMAX]+cntarr[3+IDXMAX]+10*cntarr[3+2*IDXMAX];
   for (i = 4; i < IDXMAX; i++) {
      sum += WINVAL*(cntarr[i]+cntarr[i+IDXMAX]+cntarr[i+2*IDXMAX]);
   }

   return sum;
}


int evaluate()
{
   return (evaluateColor(WHITE)-evaluateColor(BLACK));
}


byte put(byte x, byte color)
{
   byte y;

   y = 1;
   while (pf(x, y) != EMPTY) {
      if (pf(x, y) == WALL) return 0;
      y++;
   }
   pf(x, y) = color;
   return y;
}


void delete(byte x, byte y)
{
   pf(x, y) = EMPTY;
}


int min(byte depth);


int max(byte depth)
{
   int best;
   byte x, y;
   int val, valC;
   byte i;
   char s = -1;

   best = -MAXVAL;
   if (depth == 0) return evaluate();
   for (i = 1; i <= DIMX; i++) {
      char d = (i/2)*s;
      s = -s;
      x = CENTERX1+d;
      y = put(x, WHITE);
      if (y != 0) {
         valC = evaluateColor(WHITE);
#ifdef DEBUG
         if (debugon) {
            dispchar(x, y, WHITECHARDBG);
            mvprintw(dimy-1, 0, "valCmax(%d) = %d    ", depth, valC);
            while ((dbgch = getch()) != ' ') {}
         }
#endif
         if (valC >= WINVAL) {
            val = valC-evaluateColor(BLACK);
         }
         else {
            val = min(depth-1);
         }
         delete(x, y);
#ifdef DEBUG
         if (debugon) {
            dispchar(x, y, ' ');
         }
#endif
         if (val > best) {
            best = val;
#ifdef DEBUG
            if (debugon) {
               mvprintw(dimy-1, 0, "bestmovemax(%d) = %d, best = %d    ", depth, x, best);
            }
#endif
            if (depth == calcdepth) {
               bestmove = x;
            }
         }
      }
   }
   return best;
}


int min(byte depth)
{
   int best;
   byte x, y;
   int val, valC;
   byte i;
   char s = -1;

   best = MAXVAL;
   if (depth == 0) return evaluate();
   for (i = 1; i <= DIMX; i++) {
      char d = (i/2)*s;
      s = -s;
      x = CENTERX1+d;
      y = put(x, BLACK);
      if (y != 0) {
         valC = evaluateColor(BLACK);
#ifdef DEBUG
         if (debugon) {
            dispchar(x, y, BLACKCHARDBG);
            mvprintw(dimy-1, 0, "valCmin(%d) = %d    ", depth, valC);
            while ((dbgch = getch()) != ' ') {}
         }
#endif
         if (valC >= WINVAL) {
            val = evaluateColor(WHITE)-valC;
         }
         else {
            val = max(depth-1);
         }
         delete(x, y);
#ifdef DEBUG
         if (debugon) {
            dispchar(x, y, ' ');
         }
#endif
         if (val < best) {
            best = val;
#ifdef DEBUG
            if (debugon) {
               mvprintw(dimy-1, 0, "bestmovemin(%d) = %d, best = %d    ", depth, x, best);
            }
#endif
            if (depth == calcdepth) {
               bestmove = x;
            }
         }
      }
   }
   return best;
}


int minmax(byte depth, byte color)
{
   if (color == WHITE) return max(depth);
   else return min(depth);
}


void initplayfield()
{
   byte x, y;

   for (y = 1; y < DIMPFY-1; y++) {
      for (x = 1; x < DIMPFX-1; x++) {
         pf(x, y) = EMPTY;
      }
   }
   for (x = 0; x < DIMPFX; x++) {
      pf(x, 0) = WALL;
      pf(x, DIMPFY-1) = WALL;
   }
   for (y = 0; y < DIMPFY; y++) {
      pf(0, y) = WALL;
      pf(DIMPFX-1, y) = WALL;
   }
}


// ------------------------------------------------------------------------


void showtitle()
{
   int lrow = 1;
   attron(COLOR_PAIR(1));
   move(lrow++, 0);
   printw("     ######   ####   #    #  #####");
   move(lrow++, 0);
   printw("     #       #    #  #    #  #    #");
   move(lrow++, 0);
   printw("     #       #    #  #    #  #    #");
   move(lrow++, 0);
   printw("     ####    #    #  #    #  #####");
   move(lrow++, 0);
   printw("     #       #    #  #    #  #   #");
   move(lrow++, 0);
   printw("     #        ####    ####   #    #");

   lrow += 2;
   move(lrow++, 0);
   printw("         #  #    #         #");
   move(lrow++, 0);
   printw("         #  ##   #        # #");
   move(lrow++, 0);
   printw("         #  # #  #       #   #");
   move(lrow++, 0);
   printw("         #  #  # #      #######");
   move(lrow++, 0);
   printw("         #  #   ##      #     #");
   move(lrow++, 0);
   printw("         #  #    #      #     #");

   lrow += 2;
   move(lrow++, 0);
   printw("     #####    ####   #           #");
   move(lrow++, 0);
   printw("     #    #  #    #  #           #");
   move(lrow++, 0);
   printw("     #    #  #    #   #    #    #");
   move(lrow++, 0);
   printw("     #####   #    #   #   # #   #");
   move(lrow++, 0);
   printw("     #   #   #    #    # #   # #");
   move(lrow++, 0);
   printw("     #    #   ####      #     #");
   attroff(COLOR_PAIR(1));
   move(0, 0);
   refresh();
}


#ifdef CHANGELEVEL
void showdifficulty()
{
   move(dimy-1, dimx-15);
   printw("difficulty: ");
   addch((calcdepth/2)+48);
   move(0, 0);
   refresh();
}
#endif


byte evalkeys()
{
   byte key = getch();
   if ((key == 'a') || (key == 'A')) {
      if (toggle1 == 1) {
         toggle1 = 0;
         move(dimy-23, 0);
         printw("X: computer (press <a> to change)");
      }
      else if (toggle1 == 0) {
         toggle1 = 1;
         move(dimy-23, 0);
         printw("X: player   (press <a> to change)");
      }
   }
   else if ((key == 'b') || (key == 'B')) {
      if (toggle2 == 1) {
         toggle2 = 0;
         move(dimy-22, 0);
         printw("O: computer (press <b> to change)");
      }
      else if (toggle2 == 0) {
         toggle2 = 1;
         move(dimy-22, 0);
         printw("O: player   (press <b> to change)");
      }
   }
#ifdef CHANGELEVEL
   else if ((key == 'l') || (key == 'L')) {
      if (calcdepth > 2) calcdepth -= 2;
      showdifficulty();
   }
   else if ((key == 'h') || (key == 'H')) {
      if (calcdepth < 8) calcdepth += 2;
      showdifficulty();
   }
#endif
#ifdef DEBUG
   else if ((key == 'd') || (key == 'D')) debugon = 1;
   else if ((key == 'n') || (key == 'N')) debugon = 0;
#endif
   move(0, 0);
   refresh();
   return key;
}


void showplayfield()
{
   byte x, y, ch;

   for (x = OFFSETX; x < 15+OFFSETX; x++) {
      mvaddch(dimy-OFFSETY, x, '-');
   }
   for (y = 1; y <= 11; y += 2) {
      for (x = OFFSETX; x < 15+OFFSETX; x += 2) {
         mvaddch(dimy-OFFSETY-y, x, '|');
      }
   }
   for (y = 2; y <= 10; y += 2) {
      for (x = OFFSETX; x < 15+OFFSETX; x += 2) {
         mvaddch(dimy-OFFSETY-y, x, '+');
      }
   }
   for (x = 1; x < 15; x += 2) {
      ch = '1';
      ch += x/2;
      mvaddch(dimy-OFFSETY+1, x+OFFSETX, ch);
   }
#ifdef CHANGELEVEL
   showdifficulty();
#endif
   move(0, 0);
   refresh();
}


#ifdef DEBUG
void dispchar(byte x, byte y, char character)
{
   mvaddch(dimy-OFFSETY+1-y*2, x*2-1+OFFSETX, character);
   move(0, 0);
   refresh();
}
#endif


void dispchip(byte x, byte y, byte color)
{
   if (color == WHITE) {
      attron(COLOR_PAIR(3));
      mvaddch(dimy-OFFSETY+1-y*2, x*2-1+OFFSETX, WHITECHAR);
      attroff(COLOR_PAIR(3));
   }
   else {
      attron(COLOR_PAIR(2));
      mvaddch(dimy-OFFSETY+1-y*2, x*2-1+OFFSETX, BLACKCHAR);
      attroff(COLOR_PAIR(2));
   }
   move(0, 0);
   refresh();
}


byte usermove(byte color)
{
   byte x, y;

   // get user move
   do {
      do {
         x = getch();
         if ((x == 'q') || (x == 'Q')) return 2;
         x -= 48;
      } while ((x < 1) || (x > 7));
      y = put(x, color);
   } while (y == 0);

   move(dimy-OFFSETY+1-7*2, OFFSETX);
   printw("              ");
   mvaddch(dimy-OFFSETY+1-7*2, x*2-1+OFFSETX, '*');
   dispchip(x, y, color);

   // user wins?
   if (evaluateColor(color) >= WINVAL) return 1;
   return 0;
}


byte computermove(byte color)
{
   byte y;

   // determine next move of computer
   // first parameter of minmax must be > 0 and even
   bestmove = 255;
   minmax(calcdepth, color);
   if (bestmove == 255) {
      byte x1, y1;
      for (x1 = 1; x1 <= DIMX; x1++) {
         y1 = 1;
         while ((pf(x1, y1) != EMPTY) && (pf(x1, y1) != WALL)) y1++;
         if (pf(x1, y1) == EMPTY) {
            bestmove = x1;
            break;
         }
      }
   }
   y = put(bestmove, color);

   move(dimy-OFFSETY+1-7*2, OFFSETX);
   printw("              ");
   mvaddch(dimy-OFFSETY+1-7*2, bestmove*2-1+OFFSETX, '*');
   dispchip(bestmove, y, color);

   // computer wins?
   if (evaluateColor(color) >= WINVAL) return 1;
   return 0;
}


int main()
{
   byte key;
   int num;

   // init. curses
   initscr();
   noecho();
   getmaxyx(stdscr, dimy, dimx);
   if ((dimx < 40) || (dimy < 24) || (! has_colors())) {
      printf("terminal screen is too small\n");
      printf("or terminal does not support colors!\n");
      endwin();
      return 1;
   }
   start_color();
   init_pair(1, COLOR_GREEN, COLOR_BLACK);
   init_pair(2, COLOR_RED, COLOR_BLACK);
   init_pair(3, COLOR_YELLOW, COLOR_BLACK);

   // init. calc.
   calcdepth = CALCDEPTH;

   // show title screen
   showtitle();
   key = getch();

   while (1) {
      // init playfield
      initplayfield();

      // show play screen
      clear();
      showplayfield();
      move(dimy-23, 0);
      printw("X: player   (press <a> to change)");
      move(dimy-22, 0);
      printw("O: computer (press <b> to change)");
      move(dimy-20, 0);
      printw("actual move:");
      move(dimy-3, 0);
      printw("press <space> to start");
      move(dimy-1, 0);
      printw("press <q> to quit");
#ifdef CHANGELEVEL
      showdifficulty();
#endif
      move(0, 0);
      refresh();

      // wait for start
      toggle1 = 1;
      toggle2 = 0;
      do {
         key = evalkeys();
      } while ((key != ' ') && (key != 'q') && (key != 'Q'));

      if ((key == 'q') || (key == 'Q')) {
         endwin();
         return 0;
      }

      // start game
      move(dimy-3, 0);
      printw("                      ");
      num = 0;
      while (1) {
         mvaddch(dimy-20, 13, BLACKCHAR);
         move(0, 0);
         refresh();
         if (toggle1 == 0) {
            if (computermove(BLACK) == 1) {
               move(dimy-3, 0);
               printw("computer wins!");
               refresh();
               break;
            }
         }
         else if (toggle1 == 1) {
            byte ret = usermove(BLACK);
            if (ret == 1) {
               move(dimy-3, 0);
               printw("you win!");
               refresh();
               break;
            }
            else if (ret == 2) {
               move(dimy-3, 0);
               printw("user interrupt");
               refresh();
               break;
            }
         }
         mvaddch(dimy-20, 13, WHITECHAR);
         move(0, 0);
         refresh();
         num++;
         if (toggle2 == 0) {
            if (computermove(WHITE) == 1) {
               move(dimy-3, 0);
               printw("computer wins!");
               refresh();
               break;
            }
         }
         else if (toggle2 == 1) {
            byte ret = usermove(WHITE);
            if (ret == 1) {
               move(dimy-3, 0);
               printw("you win!");
               refresh();
               break;
            }
            else if (ret == 2) {
               move(dimy-3, 0);
               printw("user interrupt");
               refresh();
               break;
            }
         }
         num++;
         if (num == DIMX*DIMY) {
            move(dimy-3, 0);
            printw("draw!");
            refresh();
            break;
         }
      }

      // game ended
      move(dimy-1, 0);
      printw("press any key to continue");
      getch();
   }
}
