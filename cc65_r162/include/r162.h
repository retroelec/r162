#ifndef _R162_H
#define _R162_H

#include <r162defs.h>

#define usleep(usec) r162sleep(usec/20000)

// get the size of a file, implemented in file.s
long __fastcall__ getsize(int fd);

// set the current background drawing color for the tgi module, implemented in tgi.s
void __fastcall__ tgi_setbgcolor(unsigned char color);

// load data (or code) from file to memory
int __fastcall__ r162load(char* filename, unsigned char lohimem, unsigned char* addr);

// show picture in multicolor mode
void __fastcall__ r162multicolmode(unsigned char* addr, unsigned char startline, unsigned char endline);

// switch to text mode
void r162textmode();

#define JOYKEYUP 1
#define JOYKEYDOWN 2
#define JOYKEYLEFT 4
#define JOYKEYRIGHT 8
#define JOYKEYY 16
#define JOYKEYX 32
#define JOYKEYC 64
#define JOYKEYESC 128

// get the status (pressed or not) of "game" keys (cursor keys, y, x, space, c)
unsigned char r162getjoykey();

#define joy_read(joy) r162getjoykey()
#define JOY_BTN_UP(joykey) (joykey & JOYKEYUP)
#define JOY_BTN_DOWN(joykey) (joykey & JOYKEYDOWN)
#define JOY_BTN_LEFT(joykey) (joykey & JOYKEYLEFT)
#define JOY_BTN_RIGHT(joykey) (joykey & JOYKEYRIGHT)
#define JOY_BTN_FIRE(joykey) (joykey & JOYKEYY)

// get actual "time" in one byte (usually used to measure time differences in fiftieth seconds)
unsigned char r162getbytetime();

// start beep 
void __fastcall__ r162startbeep(unsigned char sndconst);

// stop beep
void r162stopbeep();

// sleep
void __fastcall__ r162sleep(int ticks);

#endif /* _R162_H */
