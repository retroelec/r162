#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUFFERSIZE 512


// global variables
unsigned char buffer[BUFFERSIZE];


// main
int main(int argc, char *argv[])
{
  FILE *fw;
  FILE *fr;
  int size;

  // test arguments
  if (argc != 3) {
    printf("usage: %s newfile size\n", argv[0]);
    return 1;
  }

  // file exists already?
  fr = fopen(argv[1], "r");
  if (fr != NULL) {
    printf("file %s exists already, nothing done\n", argv[1]);
    return 1;
  }
  fclose(fr);
  // create new file
  fw = fopen(argv[1], "w");
  if (fw == NULL) {
    printf("could not open file %s for writing\n", argv[1]);
    return 1;
  }

  // clear buffer
  memset(buffer, 0, BUFFERSIZE);

  // get number of bytes to write
  size = atoi(argv[2]);

  // copy blocks of data
  while (size >= BUFFERSIZE) {
    if (fwrite(buffer, 1, BUFFERSIZE, fw) != BUFFERSIZE) {
      printf("could not write buffer\n");
      fclose(fw);
      return 3;
    }
    size -= BUFFERSIZE;
  }
  if (size > 0) {
    if (fwrite(buffer, 1, size, fw) != size) {
      printf("could not write buffer\n");
      fclose(fw);
      return 4;
    }
  }

  // close file
  fclose(fw);

  return 0;
}
