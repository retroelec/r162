#
# cc65 makefile for the r162 specific modules
#

.SUFFIXES: .o .s .c

#--------------------------------------------------------------------------
# Programs and flags

SYS	= none

AS	= ../../src/ca65/ca65
CC	= ../../src/cc65/cc65
LD	= ../../src/ld65/ld65

AFLAGS	= -t $(SYS) --forget-inc-paths -I../../asminc
CFLAGS	= -Osir -g -T -t $(SYS) --forget-inc-paths -I . -I ../../include

#--------------------------------------------------------------------------
# Rules

%.o:   	%.c
	@$(CC) $(CFLAGS) $<
	@$(AS) -o $@ $(AFLAGS) $(*).s

%.o:	%.s 6502defcc.inc
	@$(AS) -g -o $@ $(AFLAGS) $<

#--------------------------------------------------------------------------
# Object files

C_OBJS =

S_OBJS  =       crt0.o ctype.o mainargs.o conio.o ncurses.o file.o systime.o clock.o tgi.o r162.o

#--------------------------------------------------------------------------
# Targets

.PHONY:	all clean zap

all:   	$(C_OBJS) $(S_OBJS)

clean:
	@$(RM) $(C_OBJS:.c=.s) $(C_OBJS) $(S_OBJS)

zap:	clean

