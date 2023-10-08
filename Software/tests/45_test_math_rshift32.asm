#include "../src/CPU.asm"

#bank rom

top:
init_pointers:
loadw sp, #0xBFFF
storew #0x0000, BP

__push32 #0x1234_5678

call rshift_32
; expect result of 0x091A_2B3C, with no carry out
popw hl
assert hl, #0x2B3C
popw hl
assert hl, #0x091A
assert b, #0x00


__push32 #0x1234_5677

call rshift_32
; expect result of 0x091A_2B3B, with carry out
popw hl
assert hl, #0x2B3B
popw hl
assert hl, #0x091A
assert b, #0x01

halt


#include "../src/lib/math.asm"