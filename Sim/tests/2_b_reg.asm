#include "../CPU.asm"

#bank rom

load b, #0x00
assert b, #0x00 ; check that a reg is correct

load b, #0x01
assert b, #0x01 ; check that a reg is correct

load b, #0xAA
assert b, #0xAA ; check that a reg is correct

load b, #0x55
assert b, #0x55 ; check that a reg is correct

load b, #0xFF
assert b, #0xFF ; check that a reg is correct

load b, #0x00
assert b, #0x00 ; check that a reg is correct

halt