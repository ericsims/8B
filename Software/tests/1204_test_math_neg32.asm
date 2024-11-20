#include "../src/CPU.asm"

#bank rom

top:
init_pointers:
loadw sp, #STACK_BASE
storew #0x0000, BP



pushw #input
pushw #result
call negate32
dalloc 4

; check result is 0xEDCB_A988
load a, result
assert a, #0xED
load a, result+1
assert a, #0xCB
load a, result+2
assert a, #0xA9
load a, result+3
assert a, #0x88

halt

input: #d 0x12345678

#include "../src/lib/math.asm"

#bank ram
result: #res 4
STACK_BASE: #res 0