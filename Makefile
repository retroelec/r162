all6502:
	@cd src && make all6502

atmega:
	@cd src && make atmega

install:
	@cd src && make install

cc65:
ifeq (, $(shell which gcc))
	$(info "gcc not found, cannot build target cc65")
else
	@echo "compile cc65 system"
	@cd cc65-2.13.3 && make --no-print-directory -f make/gcc.mak
endif

.PHONY:	all6502 atmega install cc65
