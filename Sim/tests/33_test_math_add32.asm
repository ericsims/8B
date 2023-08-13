#include "../CPU.asm"

#bank rom

top:
init_pointers:
loadw sp, #0xBFFF
storew #0x0000, BP


__push32 #0x1234_5678
__push32 #0x0000_BEEF

call add32

;popw hl ; save result to hl reg
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

;assert hl, #0x88EF

halt


#include "../math.asm"