#include "../src/CPU.asm"

#bank rom

top:
init_pointers:
loadw sp, #0xBFFF
storew #0x0000, BP


push #0x12
push #0x34

call multiply_repeat_add

pop b ; discard parameters
pop b ; discard parameters

assert a, #0xA8

push #0xAB
push #0xCD
push #0x00 ; allocate 2 bytes for z
push #0x00

call multiply16_repeat_add

popw hl ; save result to hl reg
pop b ; disacard params
pop b ; disacard params

assert hl, #0x88EF

halt


#include "../src/lib/math.asm"