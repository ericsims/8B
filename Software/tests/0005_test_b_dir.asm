;;
; @file
; @author Eric Sims
;
; @section Description
; tests loading and storing b register with direct addressing
;
; @section Test Coverage
; @coverage store_b_dir load_b_dir
;
;;

; program entry
#bank rom
top:
    load b, #0xBB
    store b, x
    load b, #0x00 ; zero register

    load b, x
    assert b, #0xBB

    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"

; global vars
#bank ram
x: #res 1 ; dummy var