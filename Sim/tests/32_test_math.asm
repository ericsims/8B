#include "../CPU.asm"

#bank rom

top:
loadw sp, #0xBFFF
storew #0x0000, BP


push #0xFF
push #0xFF

call multiply

pop b ; discard parameters
pop b ; discard parameters

halt


#include "../math.asm"