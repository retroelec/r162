#include <stdio.h>
#include <string.h>

#define STARTLEVELSTRING "#---------------------------"
#define DIMPFX 40

int main(int argc, char *argv[]) {
  FILE *f = NULL;
  FILE *f2 = NULL;
  char bufline[DIMPFX+1];
  int index;
  char* ptr;

  if (argc != 2) {
    printf("usage: %s levelfile\n", argv[0]);
    return 5;
  }

  // open level file and index level file
  if ((f = fopen(argv[1], "r")) == NULL) {
    printf("could not open level file %s\n", argv[1]);
    return 1;
  }
  if ((ptr = strrchr(argv[1], '.')) != NULL) {
    *(++ptr) = '\0';
    strcat(argv[1], "LRI");
  }
  else {
    strcat(argv[1], ".LRI");
  }
  if ((f2 = fopen(argv[1], "w")) == NULL) {
    printf("could not open level file %s\n", argv[1]);
    fclose(f);
    return 1;
  }

  // search for start of level
  index = 0;
  while (fgets(bufline, DIMPFX+1, f) != NULL) {
    if (strncmp(STARTLEVELSTRING, bufline, strlen(STARTLEVELSTRING)) == 0) {
      fprintf(f2, "%6d\n", index);
    }
    index += strlen(bufline);
  }

  fclose(f);
  fclose(f2);
  return 0;
}
