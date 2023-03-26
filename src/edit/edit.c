#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <ncurses.h>

#ifdef __CC65__
#include <r162.h>
#endif

#define byte unsigned char
#define ushort unsigned short

#define TRUE 1
#define FALSE 0

#define BUFFERSIZE 42000L

#ifndef __CC65__
#define KEY_CTRLC 3
#define KEY_CTRLF 6
#define KEY_CTRLG 7
#define KEY_CTRLH 8
#define KEY_CTRLI 14 // in linux, cygwin: ctrl-n !!!
#define KEY_CTRLK 11
#define KEY_CTRLQ 17
#define KEY_CTRLS 19
#define KEY_CTRLY 25
#endif


// file
FILE *f;
char filename[13];
// text buffer
char *buffer;
// screen buffer
char *screenbuf;
// screen width
byte scrwidth;
// screen height
byte scrheight;
// actual end of text buffer
ushort actendoftextbuf;
// actual start address of displayed text in text buffer
ushort actstartaddrofdisptext;
// actual end address of displayed text in text buffer
ushort actendaddrofdisptext;
// cursor position
byte curx;
byte cury;
// row at which a line should be inserted
byte rowinsy;
// max screen y position of an "insert char"
byte maxyscrins;
// line number at the start of displayed text
ushort linenumstart;
// flag which determines if text has been edited since last "copy screen to buffer"
byte edit;
// flag which determines if text has been edited since last save
byte modbuf;
// copy buffer
#ifdef __CC65__
char copybuf[40];
#else
char copybuf[200];
#endif


#ifdef __CC65__
#define TEXTMAPDEFAULT 512
#define COLORMAPDEFAULT 1512
void clearscreen(void);
void __fastcall__ copyblockl(char *srcaddr, char *destaddr, ushort len);
void __fastcall__ copyblockr(char *srcaddr, char *destaddr, ushort len);


void coloredstatusline() {
  byte *colormap;
  byte i;
  // status line in yellow on the r162
  colormap = (byte *)COLORMAPDEFAULT+scrheight*scrwidth;
  for (i = 0; i < scrwidth; i++) {
    *(colormap+i) = 208;
  }
}
#endif


// clear screen
#ifndef __CC65__
void clearscreen() {
  int i;
  for (i = 0; i < scrwidth*scrheight; i++) {
    screenbuf[i] = '\0';
  }
  erase();
}
#endif


// copy text block in buffer to the "left"
// param srcaddr: source address
// param destaddr: destination address
#ifndef __CC65__
void copyblockl(char *srcaddr, char *destaddr, ushort len) {
  ushort i;
  for (i = 0; i < len; i++) {
    *destaddr++ = *srcaddr++;
  }
}
#endif


// copy text block in buffer to the "right"
// param srcaddr: source address
// param destaddr: destination address
#ifndef __CC65__
void copyblockr(char *srcaddr, char *destaddr, ushort len) {
  ushort i;
  srcaddr += len;
  destaddr += len;
  for (i = 0; i < len; i++) {
    *(--destaddr) = *(--srcaddr);
  }
}
#endif


// cleanup
void cleanup() {
  if (f != NULL) fclose(f);
  if (buffer != NULL) free(buffer);
#ifndef __CC65__
  if (screenbuf != NULL) free(screenbuf);
#endif
  endwin();
}


// insert a new line if check is successful
void checkinsertline(byte *acty) {
  if (*acty == rowinsy) {
    screenbuf[(*acty)*scrwidth] = '\n';
    (*acty)++;
  }
}


// update "start line" information
void showstartline() {
  char str[10];
  move(scrheight, 0);
  sprintf(str, "%d", linenumstart);
  printw("--------------------- start line ");
  printw(str);
  move(cury, curx);
}


// copy text from buffer to screen
void copybuf2screen() {
  ushort addr = actstartaddrofdisptext;
  byte actx = 0;
  byte acty = 0;
  char ch;
  clearscreen();
#ifndef __CC65__
  move(0, 0);
#endif
  // insert line?
  checkinsertline(&acty);
  while ((acty < scrheight) && (addr < actendoftextbuf)) {
    ch = buffer[addr++];
    screenbuf[acty*scrwidth+actx] = ch;
#ifndef __CC65__
    // addch(ch); should be ok, but cygwin needs mvaddch(...)...
    mvaddch(acty, actx, ch);
#endif
    if (ch == '\n') {
      actx = 0;
      acty++;
      checkinsertline(&acty);
    }
    else {
      actx++;
      if (actx == scrwidth) {
        actx = 0;
        acty++;
        checkinsertline(&acty);
      }
    }
  }
  actendaddrofdisptext = addr;
  maxyscrins = 0;
  showstartline();
}


// replace "empty" chars with the space char
// param scridx: start index of screen buffer
// param scridx2: end index of screen buffer, must be smaller than scridx
void replemptywithspace(short scridx, short scridx2) {
  scridx--;
  while (scridx > scridx2) {
    char ch = screenbuf[scridx];
    if ((ch == '\0') || (ch == '\n')) screenbuf[scridx] = ' ';
    scridx--;
  }
}


// prepare text on screen to be copied to the buffer
// return: number of chars to be copied
ushort preparescrtext() {
  byte acty = 0;
  ushort cnt = 0;
  while (acty < scrheight) {
    // if the last char of a screen line is not "empty"
    // then the "buffer" line is longer than one screen line
    short scridx = (acty+1)*scrwidth-1;
    short scridx2 = scridx - scrwidth; // = acty*scrwidth-1
    if (screenbuf[scridx--] == '\0') {
      // CR in row?
      while (scridx > scridx2) {
        char ch = screenbuf[scridx];
        if (ch != '\0') break;
        scridx--;
      }
      if (scridx != scridx2) {
        if (screenbuf[scridx] != '\n') screenbuf[++scridx] = '\n';
        replemptywithspace(scridx, scridx2);
        cnt += scridx-scridx2;
      }
      else if (acty < maxyscrins) {
        screenbuf[++scridx] = '\n';
        cnt++;
      }
    }
    else {
      replemptywithspace(scridx, scridx2);
      cnt += scrwidth;
    }
    acty++;
  }
  return cnt;
}


// copy text from screen to buffer
void copyscreen2buf() {
  if (edit) {
    ushort i = 0;
    ushort addr = actstartaddrofdisptext;
    ushort bytes2copy = preparescrtext();
    ushort newendaddrofdisptext = actstartaddrofdisptext+bytes2copy;
    // move text block
    if (newendaddrofdisptext > actendaddrofdisptext) {
      // move text block in buffer to the "right" -> "reverse copy"
      ushort diff = newendaddrofdisptext-actendaddrofdisptext;
      ushort len = actendoftextbuf-actendaddrofdisptext;
      actendoftextbuf += diff;
      if (actendoftextbuf >= BUFFERSIZE) {
        actendoftextbuf = BUFFERSIZE-1;
        move(scrheight, 0);
        printw("buffer full! please quit! (press key)   ");
        getch();
        move(cury, curx);
        return;
      }
      if (len > 0) copyblockr(buffer+actendaddrofdisptext, buffer+newendaddrofdisptext, len);
      actendaddrofdisptext = newendaddrofdisptext;
    }
    else if (newendaddrofdisptext < actendaddrofdisptext) {
      // move text block in buffer to the "left" -> "normal copy"
      ushort diff = actendaddrofdisptext-newendaddrofdisptext;
      ushort len = actendoftextbuf-actendaddrofdisptext;
      actendoftextbuf -= diff;
      if (len > 0) copyblockl(buffer+actendaddrofdisptext, buffer+newendaddrofdisptext, len);
      actendaddrofdisptext = newendaddrofdisptext;
    }
    // copy screen text to text buffer
    for (i = 0; i < scrwidth*scrheight; i++) {
      char ch = screenbuf[i];
      if (ch != '\0') buffer[addr++] = ch;
    }
    edit = FALSE;
  }
}


// move "forward" a given number of rows in text buffer
void movedownintextbuf(ushort numrows, byte countpseudolines) {
  ushort addr = actstartaddrofdisptext;
  ushort row = 0;
  ushort col = 0;
  while ((row < numrows) && (addr < actendoftextbuf)) {
    if (buffer[addr++] == '\n') {
      row++;
      col = 0;
      linenumstart++;
    }
    else if (countpseudolines) {
      col++;
      if (col == scrwidth) {
        row++;
        col = 0;
      }
    }
  }
  cury = numrows-1;
  actstartaddrofdisptext = addr;
}


// move "backward" a given number of rows in text buffer
void moveupintextbuf(ushort numrows, byte countpseudolines) {
  ushort addr = actstartaddrofdisptext;
  ushort row = 0;
  ushort col = 0;
  while ((row < numrows+1) && (addr > 0)) {
    if (buffer[--addr] == '\n') {
      row++;
      linenumstart--;
      col = 0;
    }
    else if (countpseudolines) {
      col++;
      if (col == scrwidth) {
        row++;
        col = 0;
      }
    }
  }
  if (addr != 0) {
    if (buffer[addr] == '\n') linenumstart++;
    addr++;
    cury = numrows-1;
  }
  actstartaddrofdisptext = addr;
}


// search text
byte search(char *stext, ushort *saddr) {
  ushort tmplinenum = linenumstart;
  ushort addr = actstartaddrofdisptext;
  while (addr < actendoftextbuf) {
    char chb, chs;
    ushort tmpaddr;
    byte i = 0;
    if (buffer[addr] == '\n') {
      tmplinenum++;
      addr++;
    }
    tmpaddr = addr;
    while (((chb = buffer[tmpaddr++]) == (chs = stext[i++])) && (chs != '\0')) {}
    if (chs == '\0') {
      // search text found
      // search for start in line
      while (addr > 0) {
        if (buffer[addr] == '\n') break;
        addr--;
      }
      if (addr != 0) addr++;
      *saddr = addr;
      linenumstart = tmplinenum;
      return 1;
    }
    else if (chs == '\n') {
      tmplinenum++;
    }
    addr = tmpaddr;
  }
  // search text not found
  return 0;
}


// goto line
void gotoline(ushort line) {
  copyscreen2buf();
  if (line > linenumstart) {
     movedownintextbuf(line-linenumstart, FALSE);
  }
  else if (line < linenumstart) {
     moveupintextbuf(linenumstart-line, FALSE);
  }
  copybuf2screen();
  curx = 0;
  cury = 0;
  move(cury, curx);
}


// insert line
void insertline() {
  rowinsy = cury;
  copyscreen2buf();
  copybuf2screen();
  edit = TRUE;
  modbuf = TRUE;
  rowinsy = 255;
}


// kill line
void killline() {
  byte i;
  ushort addr = cury*scrwidth;
  for (i = 0; i < scrwidth; i++) {
    copybuf[i] = screenbuf[addr];
    screenbuf[addr++] = '\0';
  }
  edit = TRUE;
  modbuf = TRUE;
  copyscreen2buf();
  copybuf2screen();
}


// copy line
void copyline() {
  byte i;
  ushort addr = cury*scrwidth;
  for (i = 0; i < scrwidth; i++) {
    copybuf[i] = screenbuf[addr++];
  }
}


// yank line
void yankline() {
  byte i;
  ushort addr = cury*scrwidth;
  for (i = 0; i < scrwidth; i++) {
    char ch = copybuf[i];
    if (ch != '\0') {
      screenbuf[addr++] = ch;
#ifndef __CC65__
      mvaddch(cury, i, ch);
#endif
    }
  }
  edit = TRUE;
  modbuf = TRUE;
  move(cury, curx);
}


// page down
void pagedown() {
  if (actstartaddrofdisptext < actendoftextbuf) {
    copyscreen2buf();
    movedownintextbuf(scrheight, TRUE);
    copybuf2screen();
    curx = 0;
    cury = 0;
    move(cury, curx);
  }
}


// page up
void pageup() {
  copyscreen2buf();
  moveupintextbuf(scrheight, TRUE);
  copybuf2screen();
  curx = 0;
  move(cury, curx);
}


// scroll down
void scrolldown() {
  copyscreen2buf();
  movedownintextbuf(12, TRUE);
  copybuf2screen();
}


// scroll up
void scrollup() {
  copyscreen2buf();
  moveupintextbuf(12, TRUE);
  copybuf2screen();
}


// move the cursor to the left
void movecurleft() {
  if (curx == 0) {
    if (cury > 0) {
      curx = scrwidth-1;
      cury--;
    }
  }
  else {
    curx--;
  }
  move(cury, curx);
}


// move the cursor to the right
void movecurright() {
  if (curx == scrwidth-1) {
    if (cury < scrheight-1) {
      curx = 0;
      cury++;
    }
  }
  else {
    curx++;
  }
  move(cury, curx);
}


// move the cursor upwards
void movecurup() {
  if (cury > 0) {
    cury--;
  }
  else {
    scrollup();
  }
  move(cury, curx);
}


// move the cursor downwards
void movecurdown() {
  if (cury < scrheight-1) {
    cury++;
  }
  else {
    scrolldown();
  }
  move(cury, curx);
}


// delete char
void deletechar() {
  byte j;
  ushort scraddr = cury*scrwidth;
  for (j = curx; j < scrwidth-1; j++) {
    screenbuf[scraddr+j] = screenbuf[scraddr+j+1];
  }
  screenbuf[scraddr+j] = '\0';
  edit = TRUE;
  modbuf = TRUE;
#ifndef __CC65__
  for (j = curx; j < scrwidth; j++) {
    char ch1 = screenbuf[scraddr+j];
    if (ch1 == '\0') mvaddch(cury, j, ' ');
    else mvaddch(cury, j, ch1);
  }
  move(cury, curx);
#endif
}


// insert char
void insertchar() {
  byte j;
  ushort scraddr = cury*scrwidth;
  for (j = scrwidth-2; j >= curx; j--) {
    screenbuf[scraddr+j+1] = screenbuf[scraddr+j];
  }
  screenbuf[scraddr+curx] = ' ';
#ifndef __CC65__
  for (j = curx; j < scrwidth; j++) {
    char ch1 = screenbuf[scraddr+j];
    if (ch1 == '\0') mvaddch(cury, j, ' ');
    else mvaddch(cury, j, ch1);
  }
  move(cury, curx);
#endif
}


// display help page
void disphelppage() {
  copyscreen2buf();
  erase();
  move(scrheight-20, 3);
  printw("edit (copyright by retroelec)");
  move(scrheight-19, 3);
  printw("-----------------------------");
  move(scrheight-17, 3);
  printw("help page");
  move(scrheight-15, 3);
  printw("ctrl-s : save buffer");
  move(scrheight-14, 3);
  printw("ctrl-q : quit");
  move(scrheight-13, 3);
  printw("ctrl-k : kill line");
  move(scrheight-12, 3);
  printw("ctrl-c : copy line");
  move(scrheight-11, 3);
  printw("ctrl-y : paste line");
  move(scrheight-10, 3);
#ifdef __CC65__
  printw("ctrl-i : insert new line");
#else
  printw("ctrl-n : insert new line");
#endif
  move(scrheight-9, 3);
  printw("ctrl-g : goto line");
  move(scrheight-8, 3);
  printw("ctrl-f : search buffer");
  move(scrheight-7, 3);
  printw("ctrl-h : display this help page");
  move(scrheight-5, 3);
  printw("press any key to go back");
  move(scrheight, 0);
  getch();
  copybuf2screen();
  move(cury, curx);
#ifdef __CC65__
  coloredstatusline();
#endif
}


// write file
byte writefile() {
  f = fopen(filename, "w");
  if (f == NULL) return 0;
  fwrite(buffer, actendoftextbuf, 1, f);
  fclose(f);
  f = NULL;
  move(scrheight, 0);
  printw("wrote file            ");
  move(cury, curx);
  return 1;
}


// main
int main(int argc, char *argv[])
{
#ifdef __CC65__
  int fd;
#endif
  byte quit;
  byte insertmode;
  char str[30];
  ushort searchaddr;

  // test arguments
  if (argc != 2) {
    printf("usage: %s file_to_edit\n", argv[0]);
    return 1;
  }

  // init.
  f = NULL;
  buffer = NULL;
  screenbuf = NULL;
  actstartaddrofdisptext = 0;
  curx = 0;
  cury = 0;
  rowinsy = 255;
  maxyscrins = 0;
  actendoftextbuf = 0;
  linenumstart = 1;
  edit = FALSE;
  modbuf = FALSE;

  // init terminal screen
  initscr();
  keypad(stdscr, TRUE);
  raw();
  noecho();
  getmaxyx(stdscr, scrheight, scrwidth);
  scrheight--;

  // allocate buffer(s)
  buffer = malloc(BUFFERSIZE);
  if (buffer == NULL) {
    cleanup();
    printf("not enough memory available\n");
    return 1;
  }
#ifndef __CC65__
  screenbuf = malloc(scrwidth*scrheight);
  if (screenbuf == NULL) {
    cleanup();
    printf("not enough memory available\n");
    return 1;
  }
#else
  screenbuf = (char *)TEXTMAPDEFAULT;
#endif

  // read file content to buffer (if file exists)
  strncpy(filename, argv[1], 12);
  filename[12] = '\0';
  f = fopen(filename, "r");
  if (f != NULL) {
    // get size of file and read file to buffer
#ifdef __CC65__
    fd = fileno(f);
    actendoftextbuf = (int)getsize(fd);
#else
    fseek(f, 0, SEEK_END);
    actendoftextbuf = (int)ftell(f);
    fseek(f, 0, SEEK_SET);
#endif
    if (actendoftextbuf > BUFFERSIZE) {
      cleanup();
      printf("not enough memory available to read the file\n");
      return 1;
    }
    fread(buffer, actendoftextbuf, 1, f);
    fclose(f);
    f = NULL;
  }

  // display first page
  copybuf2screen();
  move(0, 0);

#ifdef __CC65__
  coloredstatusline();
#endif

  // edit
  insertmode = FALSE;
  quit = FALSE;
  while (! quit)
  {
    int ch;
    ch = getch();
    if (((ch >= ' ') && (ch <= '~')) || (ch == '\t')) {
      if (insertmode) {
        insertchar();
      }
      screenbuf[cury*scrwidth+curx] = ch;
      if (cury > maxyscrins) maxyscrins = cury;
      edit = TRUE;
      modbuf = TRUE;
#ifndef __CC65__
      addch(ch);
#endif
      movecurright();
    }
    else if (ch == '\n') {
      curx = 0;
      movecurdown();
    }
    else {
      switch (ch) {
      case KEY_BACKSPACE:
        movecurleft();
        deletechar();
        break;
      case KEY_IC:
         insertmode = ! insertmode;
        break;
      case KEY_DC:
        deletechar();
        break;
      case KEY_CTRLS:
        copyscreen2buf();
        if (! writefile()) {
          cleanup();
          printf("could not open file %s for writing\n", filename);
          return 1;
        }
        modbuf = FALSE;
        break;
      case KEY_CTRLQ:
        quit = TRUE;
        // quit -> unsaved changes?
        if (modbuf) {
          int ch = ' ';
          move(scrheight, 0);
          clrtoeol();
          printw("buffer edited, save and quit? (y/n/c)");
          while ((ch != 'n') && (ch != 'y') && (ch != 'c')) {
            ch = getch();
            if (ch == 'y') {
              copyscreen2buf();
              if (! writefile()) {
                cleanup();
                printf("could not open file %s for writing\n", filename);
                return 1;
              }
            }
            else if (ch == 'c') {
              move(scrheight, 0);
              clrtoeol();
              showstartline();
              quit = FALSE;
            }
          }
        }
        break;
      case KEY_CTRLK:
        killline();
        break;
      case KEY_CTRLC:
        copyline();
        break;
      case KEY_CTRLY:
        yankline();
        break;
      case KEY_CTRLI:
        insertline();
        break;
      case KEY_CTRLG:
        move(scrheight, 0);
        clrtoeol();
        printw("line number: ");
        echo();
        getstr(str);
        noecho();
        gotoline(atoi(str));
        break;
      case KEY_CTRLF:
        move(scrheight, 0);
        clrtoeol();
        printw("search string: ");
        echo();
        getstr(str);
        noecho();
        if (search(str, &searchaddr)) {
          if (searchaddr != actstartaddrofdisptext) {
            copyscreen2buf();
            actstartaddrofdisptext = searchaddr;
            copybuf2screen();
          }
        }
        else {
          move(scrheight, 0);
          clrtoeol();
          printw("string not found");
        }
        move(cury, curx);
        break;
      case KEY_CTRLH:
        disphelppage();
        break;
      case KEY_PPAGE:
        pageup();
        break;
      case KEY_NPAGE:
        pagedown();
        break;
      case KEY_LEFT:
        movecurleft();
        break;
      case KEY_RIGHT:
        movecurright();
        break;
      case KEY_UP:
        movecurup();
        break;
      case KEY_DOWN:
        movecurdown();
        break;
      }
    }
  }

  // end
  cleanup();
  return 0;
}
