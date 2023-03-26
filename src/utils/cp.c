#include <stdio.h>

#define BUFFERSIZE 32000


// global variables
unsigned char buffer[BUFFERSIZE];


// main
int main(int argc, char *argv[])
{
  FILE *fr;
  FILE *fw;
  unsigned short num;

  // test arguments
  if (argc != 3) {
    printf("usage: %s srcfile destfile\n", argv[0]);
    return 1;
  }

  // open files
  fr = fopen(argv[1], "r");
  if (fr == NULL) {
    printf("could not open file %s for reading\n", argv[1]);
    return 2;
  }
  fw = fopen(argv[2], "w");
  if (fw == NULL) {
    fclose(fr);
    printf("could not open file %s for writing\n", argv[2]);
    return 2;
  }

  // copy blocks of data
  while ((num = fread(buffer, 1, BUFFERSIZE, fr)) > 0) {
    if (fwrite(buffer, 1, num, fw) != num) {
      printf("could not write buffer\n");
      fclose(fw);
      fclose(fr);
      return 3;
    }
  }

  // close files
  fclose(fw);
  fclose(fr);

  return 0;
}
