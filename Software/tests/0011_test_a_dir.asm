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

#include "../src/CPU.asm"

#bank ram
x: ; dummy var
    #res 1

#bank rom

load a, #0xAA
store a, x
load a, #0x00 ; zero register

load a, x
assert a, #0xAA

halt