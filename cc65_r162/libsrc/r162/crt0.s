; ---------------------------------------------------------------------------
; crt0.s
; ---------------------------------------------------------------------------
;
; Startup code for cc65 (r162 version)
.include  "6502defcc.inc"
.include  "r162.inc"

.export   _init, _exit
.import   _main

.export   __STARTUP__ : absolute = 1        ; Mark as startup
.import   __RAM_START__, __RAM_SIZE__       ; Linker generated

.import    copydata, zerobss, initlib, donelib, callmain

.include  "zeropage.inc"

; ---------------------------------------------------------------------------
; Place the startup code in a special segment

.segment  "STARTUP"

; ---------------------------------------------------------------------------
; A little light 6502 housekeeping

_init:    JMP     _init0
          .byte   "AUTO"

_init0:   LDX     #$FF                 ; Initialize stack pointer to $01FF
          TXS
          CLD                          ; Clear decimal mode

; ---------------------------------------------------------------------------
; Set cc65 argument stack pointer

          LDA     #<(__RAM_START__ + __RAM_SIZE__)
          STA     sp
          LDA     #>(__RAM_START__ + __RAM_SIZE__)
          STA     sp+1

; ---------------------------------------------------------------------------
; Initialize memory storage

          JSR     zerobss              ; Clear BSS segment
          JSR     copydata             ; Initialize DATA segment
          JSR     initlib              ; Run constructors

; ---------------------------------------------------------------------------
; Further initialization

          LDA     #0
          STA     COLORONOFF
          STA     COLORBG
          STA     ECHOONOFF
          LDA     #240
          STA     COLORFG

; ---------------------------------------------------------------------------
; Call main()

          JSR     callmain

; ---------------------------------------------------------------------------
; Back from main (this is also the _exit entry):  force a software break

_exit:    JSR     donelib              ; Run destructors
          jmpsh                        ; Back to Shell
