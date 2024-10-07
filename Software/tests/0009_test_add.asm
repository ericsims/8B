;;
; @file
; @author Eric Sims
;
; @section Description
; tests add and subtract
;
; @section Test Coverage
; @coverage add_a_imm add_b_imm
;
;;
#include "../src/CPU.asm"

#bank rom

; a register imm adds
load a, #0x05
add a, #0x06
assert a, #0x0B

load a, #0x00
add a, #0x00
assert a, #0x00

load a, #0xFA
add a, #0xAB
assert a, #0xA5

; b register imm adds
load b, #0x05
add b, #0x06
assert b, #0x0B

load b, #0x00
add b, #0x00
assert b, #0x00

load b, #0xFA
add b, #0xAB
assert b, #0xA5

; a + b adds
load a, #0xAB
load b, #0xCD
add a, b
assert a, #0x78


halt