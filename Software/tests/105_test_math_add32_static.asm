#include "../src/CPU.asm"

#bank rom

top:
init_pointers:
loadw sp, #0xBFFF
storew #0x0000, BP



storew #0x1234, static_x_32
storew #0x5678, static_x_32+2

storew #0xFFAD, static_y_32
storew #0xBEEF, static_y_32+2

call static_add32

; check result is 0x11E2_1567
load a, static_z_32+3
assert a, #0x67
load a, static_z_32+2
assert a, #0x15
load a, static_z_32+1
assert a, #0xE2
load a, static_z_32
assert a, #0x11
load a, static_cf
assert a, #0x01

halt


#include "../src/lib/static_math.asm"