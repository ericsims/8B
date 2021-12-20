#include "../CPU.asm"

#bank rom

top:
loadw sp, #0xBFFF

load a, #0xAA
assert a, #0xAA

call func
assert a, #0xBB
halt


func:
load a, #0xBB
assert a, #0xBB
ret

; should never reach here
load a, #0xCC
assert a, #0x00