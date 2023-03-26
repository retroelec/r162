ASSBINS = pacman eval stktrc rm playsnd wavplay mon wboy
CBINS = ass edit soko vier loderun cp more creat

UNAME_S := $(shell uname -s)
ifneq ($(UNAME_S),Linux)
  $(error "makefile only works on linux")
endif


all6502:	asm c
	@echo "to install the r162 binaries you can use the install"
	@echo "target providing the SD-Card directory in SDCARD,"
	@echo "e.g. make SDCARD=/media/daniel/R162DISK install"


asm:
ifeq (, $(shell which xa))
	$(info "xa not found, cannot build asm binaries")
else
	make r162asm
endif


c:
ifeq (, $(wildcard ../cc65-2.13.3/src/cc65/cc65))
	$(info "cc65 not found, cannot build c binaries, try 'make cc65' in the r162 directory first")
else
	make r162c
endif


atmega:
ifeq (, $(shell which avra))
	$(info "avra not found, cannot build target atmega")
else
	@echo "assemble atmega system software"
	@cd atmega && avra main.asm -m main.map > /dev/null && ./gen6502definc && ./gen6502doc
endif


r162asm:	$(ASSBINS)
	@echo "asm binaries built"

r162c:	$(CBINS)
	@echo "c binaries built"

pacman:
	@echo "  assemble pacman"
	@cd pacman && ./asspacman.sh

eval:
	@echo "  assemble eval"
	@cd eval && xa eval.asm -o eval

stktrc:
	@echo "  assemble stktrc"
	@cd utils && xa stktrc.asm -o stktrc

rm:
	@echo "  assemble rm"
	@cd utils && xa rm.asm -o rm

playsnd:
	@echo "  assemble playsnd"
	@cd utils && xa playsnd.asm -o playsnd

wavplay:
	@echo "  assemble wavplay"
	@cd utils && xa wavplay.asm -o wavplay

mon:
	@echo "  assemble mon"
	@cd utils && xa mon.asm -o mon

wboy:
ifeq (, $(shell which java))
	$(info "java not found, cannot build target wboy")
else
	@echo "  assemble wboy"
	@cd wboy && ./genwboy.sh > /dev/null
endif

ass:
	@echo "  compile ass"
	@cd ass && make -s clean > /dev/null && make --no-print-directory ass

edit:
	@echo "  compile edit"
	@cd edit && make clean > /dev/null && make --no-print-directory edit

soko:
	@echo "  compile soko"
	@cd soko && make clean > /dev/null && make --no-print-directory soko

vier:
	@echo "  compile vier"
	@cd vier && make clean > /dev/null && make --no-print-directory vier

loderun:
	@echo "  compile loderunc"
	@cd loderun && make clean > /dev/null && make --no-print-directory loderun

cp:
	@echo "  compile cp"
	@cd utils && make cleancp > /dev/null && make --no-print-directory cp

more:
	@echo "  compile more"
	@cd utils && make cleanmore > /dev/null && make --no-print-directory more

creat:
	@echo "  compile creat"
	@cd utils && make cleancreat > /dev/null && make --no-print-directory creat


install:
ifndef SDCARD
	$(error "env var SDCARD not defined, cannot install")
endif
ifeq (, $(wildcard $(SDCARD)/.))
	$(error "directory $(SDCARD) not found, cannot install")
endif
	@echo "copy r162 binaries to $(SDCARD)"
	@mkdir -p $(SDCARD)/BIN
	@mkdir -p $(SDCARD)/DATA
	@mkdir -p $(SDCARD)/TMP
	@if [ -d "$(SDCARD)/BIN" ]; then \
		cp pacman/pacman $(SDCARD)/BIN/; \
		cp ass/ass $(SDCARD)/BIN/; \
		cp edit/edit $(SDCARD)/BIN/; \
		cp soko/soko $(SDCARD)/BIN/; \
		cp vier/vier $(SDCARD)/BIN/; \
		cp loderun/loderun $(SDCARD)/BIN/loderunc; \
		cp eval/eval $(SDCARD)/BIN/; \
		cp utils/cp $(SDCARD)/BIN/; \
		cp utils/more $(SDCARD)/BIN/; \
		cp utils/creat $(SDCARD)/BIN/; \
		cp utils/stktrc $(SDCARD)/BIN/; \
		cp utils/rm $(SDCARD)/BIN/; \
		cp utils/playsnd $(SDCARD)/BIN/; \
		cp utils/wavplay $(SDCARD)/BIN/; \
		cp utils/mon $(SDCARD)/BIN/; \
		cp wboy/wboy $(SDCARD)/BIN/; \
	fi
	@if [ -d "$(SDCARD)/DATA" ]; then \
		mkdir -p $(SDCARD)/DATA/IMGC ; \
		cp ../data/pics/multicol/*.pic $(SDCARD)/DATA/IMGC/ ;\
		mkdir -p $(SDCARD)/DATA/SND ; \
		mkdir -p $(SDCARD)/DATA/LODERUN ; \
		cp loderun/ORIGINAL.LRI $(SDCARD)/DATA/LODERUN/ ;\
		cp loderun/ORIGINAL.TXT $(SDCARD)/DATA/LODERUN/ ;\
		mkdir -p $(SDCARD)/DATA/SOKO ; \
		cp soko/sokoori.txt $(SDCARD)/DATA/SOKO/ ;\
		cp soko/microban.txt $(SDCARD)/DATA/SOKO/ ;\
		cp soko/sasq.txt $(SDCARD)/DATA/SOKO/ ;\
		mkdir -p $(SDCARD)/DATA/WBOY ; \
		cp wboy/pics/*.pic $(SDCARD)/DATA/WBOY/ ;\
		cp wboy/sound/*.asd $(SDCARD)/DATA/WBOY/ ;\
		cp wboy/level1/level1.dat $(SDCARD)/DATA/WBOY/ ;\
		cp wboy/level2/level2.dat $(SDCARD)/DATA/WBOY/ ;\
		cp wboy/pics/gameov2x.raw $(SDCARD)/DATA/WBOY/ ;\
	fi

.PHONY:	all6502 asm c r162asm r162c atmega install $(ASSBINS) $(CBINS)
