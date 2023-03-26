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

all:	cp more creat

cleancp:
	@rm -f cp.s cp.o cp

cp.s:	cp.c $(CCHOME)/libsrc/r162.lib
	@$(CC) $(CCFLAGS) $<

cp.o:	cp.s
	@$(CA) $(CAFLAGS) $<

cp:	cp.o
	@$(LD) $(LDCONF) $< $(LDLIB) -o cp

cleanmore:
	@rm -f more.s more.o more

more.s:	more.c $(CCHOME)/libsrc/r162.lib
	@$(CC) $(CCFLAGS) $<

more.o:	more.s
	@$(CA) $(CAFLAGS) $<

more:	more.o
	@$(LD) $(LDCONF) $< $(LDLIB) -o more

cleancreat:
	@rm -f creat.s creat.o creat

creat.s:	creat.c $(CCHOME)/libsrc/r162.lib
	@$(CC) $(CCFLAGS) $<

creat.o:	creat.s
	@$(CA) $(CAFLAGS) $<

creat:	creat.o
	@$(LD) $(LDCONF) $< $(LDLIB) -o creat
