#include "../src/CPU.asm"

#bank rom

top:
init_pointers:
loadw sp, #DEFAULT_STACK
storew #0xABCD, BP


push #0x12
push #0x34

call function

pop b ; discard parameters
pop b ; discard parameters

assert a, #0x46

halt

; @function
; @section description
; test function
;       _____________________
; -6   |______.param8_a______|
; -5   |______.param8_b______|
; -4   |__________?__________| RESERVED
; -3   |__________?__________|    .
; -2   |__________?__________|    .
; -1   |__________?__________| RESERVED
function: ; x, y (addreses SP+6, SP+5)

.param8_a = -6
.param8_b = -5

__prologue

loadw hl, BP
subw hl, #6
load a, (hl)

loadw hl, BP
subw hl, #5
load b, (hl)

add a, b

__epilogue
ret

