#include "../src/CPU.asm"

#bank rom

top:
init_pointers:
loadw sp, #STACK_BASE
storew #0x0000, BP

__store32 #0x1234_5678, input

pushw #input
pushw #output
call rshift_32
dalloc 4

; expect result of 0x091A_2B3C, with no carry out
loadw hl, output
assert hl, #0x091A
loadw hl, output+2
assert hl, #0x2B3C
assert b, #0x00


__store32 #0x1234_5677, input

pushw #input
pushw #output
call rshift_32
dalloc 4

; expect result of 0x091A_2B3B, with carry out
loadw hl, output
assert hl, #0x091A
loadw hl, output+2
assert hl, #0x2B3B
assert b, #0x01

halt

#include "../src/lib/math.asm"


#bank ram
input: #res 4
output: #res 4
STACK_BASE: #res 0