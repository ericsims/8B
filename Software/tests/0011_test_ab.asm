;;
; @file
; @author Eric Sims
;
; @section Description
; tests loading a register from b
;
; @section Test Coverage
; @coverage load_a_b
;
;;

#include "../src/CPU.asm"

#bank rom

load a, #0x55
load b, #0xAA
load a, b
assert a, #0xAA

load a, #0xCC
load b, a
assert b, #0xCC


halt