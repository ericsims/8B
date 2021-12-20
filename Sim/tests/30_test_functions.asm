#include "../CPU.asm"

#bank rom

top:
loadw sp, #0xBFFF
storew #0xABCD, BP


push #0x12
push #0x34

call function

pop b ; discard parameters
pop b ; discard parameters

halt

function: ; x, y (addreses SP+6, SP+5)

; prologue 
pushw BP ; save old base pointer to stack
loadw hl, sp ; save SP to base pointer
storew hl, BP

loadw hl, BP
addw hl, #6
load a, (hl)

loadw hl, BP
addw hl, #5
load b, (hl)

add a, b

; epilogue
popw hl
storew hl, BP
ret

