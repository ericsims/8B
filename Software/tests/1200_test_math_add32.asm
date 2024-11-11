#include "../src/CPU.asm"


#bank ram
input_x:
    #res 4
input_y:
    #res 4
result:
    #res 4

#bank rom

top:
init_pointers:
loadw sp, #STACK_BASE
storew #0x0000, BP

__store32 #0x1234_5678, input_x ; x
__store32 #0xFFAD_BEEF, input_y ; y


pushw #input_x
pushw #input_y
pushw #result

call add32

; disacard params
popw hl
popw hl
popw hl


; check result is 0x11E2_1567
load a, result
assert a, #0x11
load a, result+1
assert a, #0xE2
load a, result+2
assert a, #0x15
load a, result+3
assert a, #0x67

assert b, #0x01

halt


#include "../src/lib/math.asm"


#bank ram
STACK_BASE:
    #res 0