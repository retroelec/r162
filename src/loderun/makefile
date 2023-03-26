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

all:	loderun

clean:
	@rm -f level.s level.o utils.s utils.o move.s move.o loderun.s loderun.o loderun

utils.s:	utils.c loderun.h $(CCHOME)/libsrc/r162.lib
	@$(CC) $(CCFLAGS) $<

utils.o:	utils.s
	@$(CA) $(CAFLAGS) $<

level.s:	level.c loderun.h $(CCHOME)/libsrc/r162.lib
	@$(CC) $(CCFLAGS) $<

level.o:	level.s
	@$(CA) $(CAFLAGS) $<

move.s:	move.c loderun.h $(CCHOME)/libsrc/r162.lib
	@$(CC) $(CCFLAGS) $<

move.o:	move.s
	@$(CA) $(CAFLAGS) $<

loderun.s:	loderun.c loderun.h $(CCHOME)/libsrc/r162.lib
	@$(CC) $(CCFLAGS) $<

loderun.o:	loderun.s
	@$(CA) $(CAFLAGS) $<

loderun:	loderun.o move.o level.o utils.o
	@$(LD) $(LDCONF) $^ $(LDLIB) -o loderun
