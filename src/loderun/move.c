#include <stdlib.h>
#include <ncurses.h>
#include "loderun.h"
#ifdef __CC65__
#include <r162.h>
#endif

extern byte *playfield;
extern byte *oriplayfield;
extern struct s_hole holes[MAXHOLES];
extern byte acthole;
extern byte maxx;
extern byte jewels;
extern byte playerdied;
extern unsigned int score;
extern byte beepcnt;

#ifndef __CC65__
extern byte r162getbytetime();
extern void r162startbeep(byte sndconst);
#endif

void dropgold(struct s_movesprite* movespritestruct) {
  byte x = movespritestruct->oldx;
  byte y = movespritestruct->oldy;
  if (pf(x, y) == GOLD) {
    jewels--;
    printnumofjewels();
  }
  pf(x, y) = GOLD;
  setchar(x, y, GOLD);
  movespritestruct->hasgold = FALSE;
}

void movesprite1(struct s_movesprite* movespritestruct, sbyte dx, sbyte dy, byte vsprite1, byte vsprite2, byte vsprite3, byte newpf) {
  byte x, y;
  movespritestruct->oldx = movespritestruct->actx;
  movespritestruct->oldy = movespritestruct->acty;
  movespritestruct->actx += dx;
  movespritestruct->acty += dy;
  x = movespritestruct->actx;
  y = movespritestruct->acty;
  pf(x, y) = movespritestruct->sprite;
  setchar(x, y, vsprite2);
  setchar(movespritestruct->oldx, movespritestruct->oldy, vsprite3);
  movespritestruct->spriteVnext = vsprite1;
  movespritestruct->ismoving = TRUE;
  if (newpf == GOLD) {
    if (movespritestruct->hasgold) dropgold(movespritestruct);
    movespritestruct->hasgold = TRUE;
  }
}

void movesprite2(struct s_movesprite* movespritestruct) {
  byte oldx = movespritestruct->oldx;
  byte oldy = movespritestruct->oldy;
  byte o = oripf(oldx, oldy);
  if (pf(oldx, oldy) != GOLD) {
    pf(oldx, oldy) = o;
    setchar(oldx, oldy, o);
  }
  setchar(movespritestruct->actx, movespritestruct->acty, movespritestruct->spriteVnext);
  movespritestruct->ismoving = FALSE;
}

void moveinpf(struct s_movesprite* movespritestruct, sbyte dx, sbyte dy, byte playermove) {
  byte x = movespritestruct->actx+dx;
  byte y = movespritestruct->acty+dy;
  byte new = oripf(x, y);
  byte newpf = pf(x, y);
  if (dx != 0) {
    if ((new != BORDER) && ((new != BRICK) || (playermove && (new == HOLE))) && (new != SOLID) && (newpf != ENEMY)) {
      if (dx == 1) {
        if (newpf == ROPE)
          movesprite1(movespritestruct, 1, 0, movespritestruct->spriteVRR1, movespritestruct->spriteVRR2, movespritestruct->spriteVRR3, newpf);
        else
          movesprite1(movespritestruct, 1, 0, movespritestruct->spriteVR1, movespritestruct->spriteVR2, movespritestruct->spriteVR3, newpf);
      }
      else { // (dx == -1)
        if (newpf == ROPE)
          movesprite1(movespritestruct, -1, 0, movespritestruct->spriteVRL1, movespritestruct->spriteVRL2, movespritestruct->spriteVRL3, newpf);
        else
          movesprite1(movespritestruct, -1, 0, movespritestruct->spriteVL1, movespritestruct->spriteVL2, movespritestruct->spriteVL3, newpf);
      }
    }
  }
  else if (dy == -1) {
    byte act = oripf(movespritestruct->actx, movespritestruct->acty);
    if ((act == LADDER) && ((new == EMPTY) || (new == LADDER) || (new == ROPE)) && (newpf != ENEMY)) {
      movesprite1(movespritestruct, 0, -1, movespritestruct->spriteVD1, movespritestruct->spriteVD3, movespritestruct->spriteVD2, newpf);
    }
  }
  else if (dy == 1) {
    byte act = oripf(movespritestruct->actx, movespritestruct->acty);
    if ((((new == LADDER) || ((act == LADDER) && (new != BRICK) && (new != SOLID))) || ((act == ROPE) && (new != BRICK) && (new != SOLID))) && (newpf != ENEMY)) {
      movesprite1(movespritestruct, 0, 1, movespritestruct->spriteVD1, movespritestruct->spriteVD2, movespritestruct->spriteVD3, newpf);
    }
  }
}

byte fallinpf(struct s_movesprite* movespritestruct, byte playerfall) {
  byte act;
  byte belowpf;
  byte x, y;
  byte cond1, cond2;
  if (movespritestruct->justoutofhole) {
    movespritestruct->justoutofhole = FALSE;
    return FALSE;
  }
  x = movespritestruct->actx;
  y = movespritestruct->acty;
  act = oripf(x, y);
  belowpf = pf(x, y+1);
  cond1 = ((belowpf == EMPTY) || (belowpf == INVBRICK) || (belowpf == HOLE) || (belowpf == ROPE) || (belowpf == GOLD) || (belowpf == PLAYER)) && (act != ROPE) && (act != LADDER);
  cond2 = cond1 && (!playerfall) && (act != HOLE);
  if (cond1 || cond2) {
    movesprite1(movespritestruct, 0, 1, movespritestruct->spriteVF1, movespritestruct->spriteVF2, movespritestruct->spriteVF3, belowpf);
    if ((belowpf == HOLE) || (belowpf == PLAYER)) {
      movespritestruct->state = MOVESPRITE_INHOLE;
      movespritestruct->timeinhole = SPEEDENEMYINHOLE;
      if (movespritestruct->hasgold) dropgold(movespritestruct);
    }
    return TRUE;
  }
  return FALSE;
}

void trytodighole(byte x, byte y) {
  byte v = pf(x, y);
  if ((pf(x, y+1) == BRICK) && ((v == EMPTY) || (v == HOLE))) {
    if (holes[acthole].state == HOLE_NOTACTIVE) {
      pf(x, y+1) = BRICKHALF;
      holes[acthole].state = HOLE_START;
      holes[acthole].timelastupdate = r162getbytetime();
      holes[acthole].x = x;
      holes[acthole].y = y+1;
      acthole++;
      acthole %= MAXHOLES;
      r162startbeep(50);
      beepcnt = 1;
    }
  }
}

void moveplayer(struct s_movesprite* moveplayerstruct, byte joykey) {
  switch (moveplayerstruct->state) {
  case MOVESPRITE_DIED:
    playerdied = TRUE;
    beep2(100, 30);
    break;
  case MOVESPRITE_INHOLE:
    if (pf(moveplayerstruct->actx, moveplayerstruct->acty) == BRICK) {
      moveplayerstruct->state = MOVESPRITE_DIED;
    }
  case MOVESPRITE_NORMAL:
    moveplayerstruct->ismoving = FALSE;
    if (! fallinpf(moveplayerstruct, TRUE)) {
      if (joykey & JOYKEYDOWN) {
        moveinpf(moveplayerstruct, 0, 1, TRUE);
      }
      else if (joykey & JOYKEYUP) {
        moveinpf(moveplayerstruct, 0, -1, TRUE);
      }
      else if (joykey & JOYKEYRIGHT) {
        moveinpf(moveplayerstruct, 1, 0, TRUE);
      }
      else if (joykey & JOYKEYLEFT) {
        moveinpf(moveplayerstruct, -1, 0, TRUE);
      }
      else if (joykey & JOYKEYY) {
        setchar(moveplayerstruct->actx, moveplayerstruct->acty, moveplayerstruct->spriteVL1);
        trytodighole(moveplayerstruct->actx-1, moveplayerstruct->acty);
      }
      else if (joykey & JOYKEYX) {
        setchar(moveplayerstruct->actx, moveplayerstruct->acty, moveplayerstruct->spriteVR1);
        trytodighole(moveplayerstruct->actx+1, moveplayerstruct->acty);
      }
    }
    else {
      r162startbeep(40);
      beepcnt = 1;
    }
  }
}

void dighole(struct s_hole* hole) {
  byte x = hole->x;
  byte y = hole->y;
  switch (hole->state) {
  case HOLE_WAIT:
    hole->time--;
    if (hole->time == 0) {
      pf(x, y) = BRICKHALF;
      oripf(x, y) = BRICKHALF;
      setchar(x, y, BRICKHALF);
      hole->state = HOLE_END;
    }
    break;
  case HOLE_START:
    pf(x, y) = BRICKHALF;
    oripf(x, y) = BRICKHALF;
    setchar(x, y, BRICKHALF);
    hole->state = HOLE_HALF;
    break;
  case HOLE_HALF:
    pf(x, y) = HOLE;
    oripf(x, y) = HOLE;
    setchar(x, y, HOLE);
    hole->state = HOLE_WAIT;
    hole->time = SPEEDHOLE;
    break;
  case HOLE_END:
    pf(x, y) = BRICK;
    oripf(x, y) = BRICK;
    setchar(x, y, BRICK);
    hole->state = HOLE_NOTACTIVE;
    break;
  }
}

void moveenemy(struct s_movesprite* enemy, struct s_movesprite* moveplayerstruct) {
  enemy->ismoving = FALSE;
  switch (enemy->state) {
  case MOVESPRITE_INHOLE:
    enemy->timeinhole--;
    if (enemy->timeinhole == 0) {
      byte actpf = pf(enemy->actx, enemy->acty);
      if (actpf == BRICK) {
        enemy->state = MOVESPRITE_DIED;
      }
      else {
        byte newpf = pf(enemy->actx, enemy->acty-1);
        enemy->state = MOVESPRITE_NORMAL;
        enemy->justoutofhole = TRUE;
        movesprite1(enemy, 0, -1, enemy->spriteVD1, enemy->spriteVD3, enemy->spriteVD2, newpf);
      }
    }
    break;
  case MOVESPRITE_DIED:
    enemy->actx = (rand()%(maxx-2))+1;
    enemy->acty = 1;
    enemy->state = MOVESPRITE_NORMAL;
    break;
  case MOVESPRITE_NORMAL:
    if (! fallinpf(enemy, FALSE)) {
      byte bestdir = NONE;
      byte enex = enemy->actx;
      byte eney = enemy->acty;
      byte plx = moveplayerstruct->actx;
      byte ply = moveplayerstruct->acty;
      byte below;
      byte act;
      if (eney == ply) {
        // is there a path to the player on the same floor?
        sbyte dx = (enex > plx) ? -1 : 1;
        byte x = enex;
        while ((x != plx) && ((((act = oripf(x, eney)) == EMPTY) && ((below = oripf(x, eney+1)) != EMPTY) && (below != ROPE)) || (act == ROPE) || (act == LADDER))) {
          x += dx;
        }
        if (x == plx) {
          if (dx == -1) {
            bestdir = LEFT;
          }
          else { // dx == 1
            bestdir = RIGHT;
          }
        }
      }
      // enemy not on player's floor
      if ((eney >= ply) && (bestdir == NONE)) {
        // try to move up
        byte x;
        byte cntl = 255;
        byte cntr = 255;
        act = oripf(enex, eney);
        if (act == LADDER) {
          bestdir = UP;
        }
        else {
          // search for a path to move up
          // search to the left
          x = enex-1;
          while ((((act = oripf(x, eney)) == EMPTY) && ((below = oripf(x, eney+1)) != EMPTY) && (below != ROPE)) || (act == ROPE)) {
            x--;
          }
          if (act == LADDER) {
            byte y = eney-1;
            while (oripf(x, y) == LADDER) y--;
            if (plx >= x) cntl = plx-x;
            else cntl = x-plx;
            if (ply >= y) cntl += (ply-y)<<3;
            else cntl += (y-ply)<<3;
          }
          // search to the right
          x = enex+1;
          while ((((act = oripf(x, eney)) == EMPTY) && ((below = oripf(x, eney+1)) != EMPTY) && (below != ROPE)) || (act == ROPE)) {
            x++;
          }
          if (act == LADDER) {
            byte y = eney-1;
            while (oripf(x, y) == LADDER) y--;
            if (plx >= x) cntr = plx-x;
            else cntr = x-plx;
            if (ply >= y) cntr += (ply-y)<<3;
            else cntr += (y-ply)<<3;
          }
          // choose direction
          if ((cntl < 5) || (cntr < 5)) {
            // go to the nearest ladder
            if (cntl <= cntr) bestdir = LEFT;
            else bestdir = RIGHT;
          }
          else {
            // go to the farthermost ladder
            if ((cntl != 255) && (cntr < cntl)) bestdir = LEFT;
            else if ((cntr != 255) && (cntl < cntr)) bestdir = RIGHT;
            if ((bestdir == NONE) && (cntl == 255) && (cntr != 255)) bestdir = RIGHT;
            else if ((bestdir == NONE) && (cntr == 255) && (cntl != 255)) bestdir = LEFT;
          }
        }
      }
      if ((eney <= ply) && (bestdir == NONE)) {
        // try to move down
        byte x;
        byte cntl = 255;
        byte cntr = 255;
        below = oripf(enex, eney+1);
        if ((below == LADDER) || (below == EMPTY)) {
          bestdir = DOWN;
        }
        else {
          // search for a path to move down
          // search to the left
          x = enex-1;
          while (((((act = oripf(x, eney)) == EMPTY) && ((below = oripf(x, eney+1)) != EMPTY) && (below != ROPE)) || (act == ROPE)) && (below != LADDER)) {
            x--;
          }
          if (below == LADDER) {
            byte y = eney+1;
            while (oripf(x, y) == LADDER) y++;
            y--;
            if (plx >= x) cntl = plx-x;
            else cntl = x-plx;
            if (ply >= y) cntl += (ply-y)<<3;
            else cntl += (y-ply)<<3;
          }
          // search to the right
          x = enex+1;
          while (((((act = oripf(x, eney)) == EMPTY) && ((below = oripf(x, eney+1)) != EMPTY) && (below != ROPE)) || (act == ROPE)) && (below != LADDER)) {
            x++;
          }
          if (below == LADDER) {
            byte y = eney+1;
            while (oripf(x, y) == LADDER) y++;
            y--;
            if (plx >= x) cntr = plx-x;
            else cntr = x-plx;
            if (ply >= y) cntr += (ply-y)<<3;
            else cntr += (y-ply)<<3;
          }
          // choose direction
          if ((cntl < 5) || (cntr < 5)) {
            // go to the nearest ladder
            if (cntl <= cntr) bestdir = LEFT;
            else bestdir = RIGHT;
          }
          else {
            // go to the farthermost ladder
            if ((cntl != 255) && (cntr < cntl)) bestdir = LEFT;
            else if ((cntr != 255) && (cntl < cntr)) bestdir = RIGHT;
            if ((bestdir == NONE) && (cntl == 255) && (cntr != 255)) bestdir = RIGHT;
            else if ((bestdir == NONE) && (cntr == 255) && (cntl != 255)) bestdir = LEFT;
          }
        }
      }
      // no "best" direction determined so far
      if (bestdir == NONE) {
        if (enex < enemy->oldx) {
          bestdir = LEFT;
        }
        else {
          bestdir = RIGHT;
        }
      }
      // move enemy in the "best" direction
      if (bestdir == LEFT) {
        moveinpf(enemy, -1, 0, FALSE);
      }
      else if (bestdir == RIGHT) {
        moveinpf(enemy, 1, 0, FALSE);
      }
      else if (bestdir == UP) {
        moveinpf(enemy, 0, -1, FALSE);
      }
      else if (bestdir == DOWN) {
        moveinpf(enemy, 0, 1, FALSE);
      }
      if (enemy->hasgold && enemy->ismoving && (rand()%NUMOFSTEPSTOHOLDGOLD == 0)) {
        act = oripf(enemy->oldx, enemy->oldy);
        if (act == EMPTY) dropgold(enemy);
      }
    }
    // coinc detection
    if ((enemy->actx == moveplayerstruct->actx) && (enemy->acty == moveplayerstruct->acty))
      moveplayerstruct->state = MOVESPRITE_DIED;
    break;
  }
}
