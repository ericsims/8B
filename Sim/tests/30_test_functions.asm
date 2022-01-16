#include "../CPU.asm"

#bank rom

top:
init_pointers:
loadw sp, #0xBFFF
storew #0xABCD, BP


push #0x12
push #0x34

call function

pop b ; discard parameters
pop b ; discard parameters

assert a, #0x46

halt

function: ; x, y (addreses SP+6, SP+5)

__prologue

loadw hl, BP
addw hl, #6
load a, (hl)

loadw hl, BP
addw hl, #5
load b, (hl)

add a, b

__epilogue

