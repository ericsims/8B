;;
; @file
; @author Eric Sims
;
; @section Description
; tests nop and halt
;
; @section Test Coverage
; @coverage nop halt
;
;;

; program entry
#bank rom
top:
    nop
    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"

; global vars
; -- none --