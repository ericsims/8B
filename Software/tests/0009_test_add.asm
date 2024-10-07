;;
; @file
; @author Eric Sims
;
; @section Description
; tests add and subtract
;
; @section Test Coverage
; @coverage add_a_imm add_b_imm addw_hl_imm subw_hl_imm
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



; 16 bit add tests
loadw hl, #0x1234
addw hl, #0x00
assert hl, #0x1234

loadw hl, #0xABCD
addw hl, #0xEF
assert hl, #0xACBC

loadw hl, #0x00FE
addw hl, #0x01
assert hl, #0x00FF
addw hl, #0x01
assert hl, #0x0100
addw hl, #0x02
assert hl, #0x0102

loadw hl, #0xFFFE
addw hl, #0x01
assert hl, #0xFFFF
addw hl, #0x01
assert hl, #0x0000
addw hl, #0x02
assert hl, #0x0002


; 16 bit subtract
loadw hl, #0x1234
subw hl, #0x00
assert hl, #0x1234

loadw hl, #0x1234
subw hl, #0x45
assert hl, #0x11EF

halt