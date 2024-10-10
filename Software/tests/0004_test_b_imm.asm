;;
; @file
; @author Eric Sims
;
; @section Description
; tests b register immedate loads
;
; @section Test Coverage
; @coverage load_b_imm
;
;;

#include "../src/CPU.asm"

#bank rom

; tests load b register with immediate value

load b, #0x00
assert b, #0x00 ; check that a reg is correct

load b, #0x01
assert b, #0x01 ; check that a reg is correct

load b, #0xAA
assert b, #0xAA ; check that a reg is correct

load b, #0x55
assert b, #0x55 ; check that a reg is correct

load b, #0xFF
assert b, #0xFF ; check that a reg is correct

load b, #0x00
assert b, #0x00 ; check that a reg is correct

halt