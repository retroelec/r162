#ifndef _NCURSES_H
#define _NCURSES_H

#include <conio.h>
#include <r162defs.h>

#define bool unsigned char

#define move(y, x) gotoxy(x, y)
#define mvaddch(y, x, ch) cputcxy(x, y, ch)
#define addch(ch) cputc(ch)
#define addstr(str) cputs(str)
#define printw(str) cputs(str)
#define scanw(format, arg) cscanf(format, arg)
#define clear() clrscr()
#define erase() clrscr()
#define refresh()
#define cbreak()
#define nocbreak()
#define keypad(scr, flag)
#define scrollok(scr, flag)
#define idlok(scr, flag)
#define nonl()
#define raw()
#define getmaxyx(win, height, width) { height = 25; width = 40; }
#define has_colors() (1 == 1)
#define attrset(color) attron(color)

//#define mvprintw(y, x, str) { move(y, x); printw(str); }
#define mvprintw(y, x, ...) { move(y, x); printf (__VA_ARGS__); }

void* initscr(void);
int endwin(void);
void start_color(void);
void __fastcall__ init_pair(unsigned char nr, unsigned char fgcolor, unsigned char bgcolor);
unsigned char __fastcall__ COLOR_PAIR(unsigned char nr);
void __fastcall__ attron(unsigned char color);
void __fastcall__ attroff(unsigned char color);
int echo(void);
int noecho(void);
int getch(void);
void __fastcall__ getstr(char* str);
int clrtoeol(void);
int __fastcall__ scrl(int n);
int beep(void);
int __fastcall__ nodelay(void*, bool bf);
int __fastcall__ curs_set(int n);
char inch(void);
int __fastcall__ box(void*, char vch, char hch);
extern void* stdscr;

// additional function defch (NOT part of the ncurses library!): redefinition of a character
void __fastcall__ defch(unsigned char ch, unsigned char* data);

#define LINES 25
#define COLS 40

#define KEY_DOWN 18
#define KEY_UP 20
#define KEY_RIGHT 19
#define KEY_LEFT 17
#define KEY_BACKSPACE 8
#define KEY_PPAGE 21
#define KEY_NPAGE 22
#define KEY_HOME 23
#define KEY_END 24
#define KEY_IC 25
#define KEY_DC 26
#define KEY_ENTER 10

#define ACS_CKBOARD 160
#define ACS_HLINE '-'
#define ACS_VLINE '|'
#define ACS_DIAMOND '*'

#define A_REVERSE 128
#define WA_REVERSE A_REVERSE
#define A_BLINK 0
#define WA_BLINK A_BLINK
#define A_BOLD 0
#define WA_BOLD A_BOLD
#define A_NORMAL 0
#define WA_NORMAL A_NORMAL

#define ERR 0

#undef TRUE
#define TRUE    1
#undef FALSE
#define FALSE   0

// *** not ncurses standard ***

#define KEY_F1 1
#define KEY_F2 2
#define KEY_F3 28
#define KEY_F4 4
#define KEY_F5 5
#define KEY_F6 6
#define KEY_F7 7
#define KEY_F8 29
#define KEY_WINLEFT 30
#define KEY_WINRIGHT 31
#define KEY_DELETE 26
#define KEY_CTRLQ 149
#define KEY_CTRLW 157
#define KEY_CTRLE 164
#define KEY_CTRLR 173
#define KEY_CTRLT 172
#define KEY_CTRLZ 181
#define KEY_CTRLU 188
#define KEY_CTRLI 195
#define KEY_CTRLO 196
#define KEY_CTRLP 205
#define KEY_CTRLA 156
#define KEY_CTRLS 155
#define KEY_CTRLF 171
#define KEY_CTRLG 180
#define KEY_CTRLH 179
#define KEY_CTRLJ 187
#define KEY_CTRLK 194
#define KEY_CTRLL 203
#define KEY_CTRLY 154
#define KEY_CTRLX 162
#define KEY_CTRLC 3
#define KEY_CTRLV 170
#define KEY_CTRLB 178
#define KEY_CTRLN 177
#define KEY_CTRLM 186
#define KEY_CTRLCOMMA 193
#define KEY_CTRLDOT 201
#define KEY_CTRLMINUS 202

// default value for the start of the textmap
#define TEXTMAPDEFAULT 512
// default value for the start of the colormap in text mode
#define COLORMAPTXTDEFAULT 1512

#endif /* _NCURSES_H */
