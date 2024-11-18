;;
; @file
; @author Eric Sims
;
; @section Description
; tests loading and storing a register with direct addressing
;
; @section Test Coverage
; @coverage store_a_dir load_a_dir
;
;;

; program entry
#bank rom
top:
    load a, #0xAA
    store a, x
    load a, #0x00 ; zero register

    load a, x
    assert a, #0xAA

    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"

; global vars
#bank ram
x: #res 1 ; dummy var