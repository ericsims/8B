#include "../CPU.asm"

#bank rom
top:
init_pointers:
loadw sp, #0xBFFF
storew #0x0000, BP


storew #0x1234, static_x_32
storew #0x5678, static_x_32+2

call static_negate32


; check result is 0xEDCB_A988
load a, static_x_32+3
assert a, #0x88
load a, static_x_32+2
assert a, #0xA9
load a, static_x_32+1
assert a, #0xCB
load a, static_x_32
assert a, #0xED
; TODO: check carry flag

halt


#include "../lib/static_math.asm"