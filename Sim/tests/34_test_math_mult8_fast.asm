#include "../CPU.asm"

#bank ram
sum: #res 2 ;result poitbed


#bank rom

top:
init_pointers:
loadw sp, #0xBFFF
storew #0x0000, BP

val_a=0xFF
val_b=0xFF


push #{val_a}
push #{val_b}
pushw #sum

call multiply8_fast

; disacard params
; TODO: there is probably a faster way to write to the SP to discard these... each "pop a" is 5 clock cycles
pop a
pop a
pop a
pop a

loadw hl, sum

assert hl, #(val_a*val_b)


halt


#include "../math.asm"