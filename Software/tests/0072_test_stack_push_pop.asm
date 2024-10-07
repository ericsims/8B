;;
; @file
; @author Eric Sims
;
; @section Description
; tests stack maniuplation
;
; @section Test Coverage
; @coverage push_imm pop_a pop_b push_a push_b pushw_imm popw_hl
;
;;
#include "../src/CPU.asm"

#bank rom

top:
loadw sp, #0xBFFF


; push imm data
push #0x12
push #0x34
push #0x56
push #0x78
push #0x9A
push #0xBC

; pop half of it to a register and check
pop a
assert a, #0xBC
pop a
assert a, #0x9A
pop a
assert a, #0x78

; pop other half of data to b register and check
pop b
assert b, #0x56
pop b
assert b, #0x34
pop b
assert b, #0x12


; push data from a register
load a, #0xAA
push a
load a, #0xBB
push a
load a, #0x00

; pop and check
pop a
assert a, #0xBB
pop a
assert a, #0xAA


; push data from b register
load b, #0xCC
push b
load b, #0xDD
push b
load b, #0x00

; pop and check
pop b
assert b, #0xDD
pop b
assert b, #0xCC

; push imm data word
pushw #0x1234
pushw #0x4567
popw hl
assert hl, #0x4567
popw hl
assert hl, #0x1234

halt