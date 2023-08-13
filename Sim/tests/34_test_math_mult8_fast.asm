#include "../CPU.asm"

#bank ram
sum: #res 2 ; base pointer for function calls


#bank rom

top:
init_pointers:
loadw sp, #0xBFFF
storew #0x0000, BP

a=0xFF
b=0xFF


push #{a}
push #{b}
pushw #sum

call multiply8_fast

; disacard params
; TODO: there is probably a faster way to write to the SP to discard these... each "pop a" is 5 clock cycles
pop a
pop a
pop a
pop a

loadw hl, sum

assert hl, #(a*b)


halt


#include "../math.asm"