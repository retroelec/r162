MKPATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKDIR := $(dir $(MKPATH))
CCHOME = $(MKDIR)../../cc65-2.13.3
CC = $(CCHOME)/src/cc65/cc65
CCFLAGS = -t none -O --cpu 6502 -I $(CCHOME)/include -I .
CA = $(CCHOME)/src/ca65/ca65
CAFLAGS = --cpu 6502
LD = $(CCHOME)/src/ld65/ld65
LDCONF = -C $(CCHOME)/src/ld65/cfg/r162.cfg
LDLIB = $(CCHOME)/libsrc/r162.lib

all:	ass

clean:
	@rm -f ass.s ass.o ass assemble.s assemble.o

assemble.s:	assemble.c assemble.h $(CCHOME)/libsrc/r162.lib
	@$(CC) $(CCFLAGS) $<

assemble.o:	assemble.s
	@$(CA) $(CAFLAGS) $<

ass.s:	ass.c assemble.h $(CCHOME)/libsrc/r162.lib
	@$(CC) $(CCFLAGS) $<

ass.o:	ass.s
	@$(CA) $(CAFLAGS) $<

ass:	ass.o assemble.o
	@$(LD) $(LDCONF) $^ $(LDLIB) -o ass

linux:
	gcc -Wall -c assemble.c -o assemblelinux.o
	gcc -Wall ass.c -o asslinux assemblelinux.o

format:
	@clang-format -i ass.c
	@clang-format -i assemble.c
	@clang-format -i assemble.h
