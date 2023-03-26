// 6502 assembler, v1.0, c code
// written for the R162 (see
// https://sites.google.com/site/retroelec/retroelecs-electronics-projects/r162)
//
// Copyright (C) 2012-2020 retroelec <retroelec42@gmail.com>
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

#include "assemble.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef __CC65__
#include <r162.h>
#endif

int main(int argc, char *argv[]) {
  FILE *fp;
#ifdef __CC65__
  int fd;
  char resfilename[13];
#else
  char resfilename[80];
#endif
  unsigned short size;
  unsigned char *buffer;
  unsigned char ret;
  unsigned short errlinenum;
  char errmsg[80];

  if ((argc != 2) && (argc != 3)) {
    printf("%s ass-input-file [bin-output-file]\n", argv[0]);
    return 1;
  }
  if (argc == 2) {
    char *tmpAddr;
    strcpy(resfilename, argv[1]);
    tmpAddr = strrchr(resfilename, '.');
    if (tmpAddr != NULL) {
      *tmpAddr = '\0';
    } else {
      printf("file extension missing (e.g. %s %s.asm)\n", argv[0], argv[1]);
      return 1;
    }
  } else {
    strcpy(resfilename, argv[2]);
  }

  // read file to buffer
  if ((fp = fopen(argv[1], "r")) == NULL) {
    printf("cannot open file %s for reading\n", argv[1]);
    return 1;
  }

  // get size
#ifdef __CC65__
  fd = fileno(fp);
  size = (int)getsize(fd);
#else
  fseek(fp, 0, SEEK_END);
  size = (int)ftell(fp);
  fseek(fp, 0, SEEK_SET);
#endif

  // read file to buffer
  buffer = malloc(size + 2);
  if (buffer == NULL) {
    printf("not enough memory available\n");
    return 1;
  }
  fread(buffer, 1, size, fp);
  buffer[size] = '\n';
  buffer[size + 1] = '\0';
  fclose(fp);

  // assemble
  if ((ret = assemble(buffer, buffer, &size, &errlinenum, errmsg, 1)) != 0) {
    printf("error in line %d: %s\n", errlinenum, errmsg);
    free(buffer);
    return ret;
  }

  // write buffer to file
  if ((fp = fopen(resfilename, "w")) == NULL) {
    printf("cannot open file %s for writing\n", resfilename);
    free(buffer);
    return 1;
  }
  fwrite(buffer, 1, size, fp);
  printf("%d bytes written\n", size);
  fclose(fp);
  free(buffer);

  return 0;
}
