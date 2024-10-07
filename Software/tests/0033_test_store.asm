#include "../src/CPU.asm"

#bank rom

; test store imm to direct address
store #0x12, var1
load a, var1
assert a, #0x12 ; check that the write/read was sucessful

; test storew imm to direct address
storew #0x3456, var2
load a, var2
assert a, #0x34 ; check that the write/read was sucessful
load a, var2+1
assert a, #0x56 ; check that the write/read was sucessful

halt

#bank ram
var1:
    #res 1
var2:
    #res 2