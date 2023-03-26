#include <stdio.h>
#include <string.h>

#ifndef __CC65__
#include <termios.h>
#include <unistd.h>
#else
#include <ncurses.h>
#endif

#define byte unsigned char

#define NUMOFLINES 25
#define LINEWIDTH 40
#define MAXLINELEN LINEWIDTH*(NUMOFLINES-1)

char bufline[MAXLINELEN];

int main(int argc, char *argv[])
{
  int line = 0;
  FILE *f;
  byte quit = 0;

  if (argc != 2) {
    printf("usage: %s filename\n", argv[0]);
    return 1;
  }

  f = fopen(argv[1], "r");
  if (f == NULL) {
    printf("file not found\n");
    return 1;
  }

#ifndef __CC65__
  struct termios t;
  tcgetattr(STDIN_FILENO, &t);
  t.c_lflag &= ~ECHO;
  tcsetattr(STDIN_FILENO, TCSANOW, &t);
#endif

  while (fgets(bufline, MAXLINELEN, f) != NULL) {
    int len = strlen(bufline);
    int numoflines = (len/LINEWIDTH)+1;
    line += numoflines;
    if (line >= NUMOFLINES) {
      byte wait = 1;
      while (wait) {
        char ch;
#ifndef __CC65__
        ch = getchar();
#else
        ch = getch();
#endif
        switch (ch) {
        case ' ':
          wait = 0;
          line = numoflines;
          break;
        case '\n':
          wait = 0;
          line -= numoflines;
          break;
        case 'q':
          wait = 0;
          quit = 1;
          break;
        }
      }
    }
    if (quit) break;
    printf("%s", bufline);
  }

#ifndef __CC65__
  t.c_lflag |= ECHO;
  tcsetattr(STDIN_FILENO, TCSANOW, &t);
#endif

  fclose(f);

  return 0;
}
