#include "../src/CPU.asm"

#bank rom

top:
init_pointers:
loadw sp, #DEFAULT_STACK
storew #0x0000, BP



__push32 #0x0000_0000 ; result placeholder
__push32 #0x1234_5678 ; x
__push32 #0xFFAD_BEEF ; y

call add32

; disacard params
; TODO: there is probably a faster way to write to the SP to discard these... each "pop a" is 5 clock cycles
pop a
pop a
pop a
pop a

pop a
pop a
pop a
pop a

; check result is 0x11E2_1567
;assert hl, ???

halt


#include "../src/lib/math.asm"