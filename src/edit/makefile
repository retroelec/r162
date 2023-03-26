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

all:	edit

clean:
	@rm -f edit.s edit.o edit editasm.o

editasm.o:	editasm.s
	@$(CA) $(CAFLAGS) $<

edit.s:	edit.c $(CCHOME)/libsrc/r162.lib
	@$(CC) $(CCFLAGS) $<

edit.o:	edit.s
	@$(CA) $(CAFLAGS) $<

edit:	edit.o editasm.o
	@$(LD) $(LDCONF) $< editasm.o $(LDLIB) -o edit
