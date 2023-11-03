#include "../src/CPU.asm"

#bank rom

top:

load a, #0xAA
assert a, #0xAA

jmp next

assert a, #0x00
halt

next:
load a, #0xBB
assert a, #0xBB;

halt