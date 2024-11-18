;;
; @file
; @author Eric Sims
;
; @section Description
; tests storing immediate value
;
; @section Test Coverage
; @coverage store_imm_dir
;
;;

; program entry
#bank rom
top:
    load a, #0x00 ; zero register

    store #0x55, x

    load a, x
    assert a, #0x55

    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"

; global vars
#bank ram
x: ; dummy var
    #res 1