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

all:	soko

clean:
	@rm -f soko.s soko.o soko

soko.s:	soko.c $(CCHOME)/libsrc/r162.lib
	@$(CC) $(CCFLAGS) $<

soko.o:	soko.s
	@$(CA) $(CAFLAGS) $<

soko:	soko.o
	@$(LD) $(LDCONF) $< $(LDLIB) -o soko
