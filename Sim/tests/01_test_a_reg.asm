#include "../CPU.asm"

#bank rom

; tests load a register with immediate value

load a, #0x00
assert a, #0x00 ; check that a reg is correct

load a, #0x01
assert a, #0x01 ; check that a reg is correct

load a, #0xAA
assert a, #0xAA ; check that a reg is correct

load a, #0x55
assert a, #0x55 ; check that a reg is correct

load a, #0xFF
assert a, #0xFF ; check that a reg is correct

load a, #0x00
assert a, #0x00 ; check that a reg is correct

halt