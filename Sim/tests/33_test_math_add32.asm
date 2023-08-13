#include "../CPU.asm"

#bank ram
sum: #res 4 ; base pointer for function calls



#bank rom

top:
init_pointers:
loadw sp, #0xBFFF
storew #0x0000, BP



__push32 #0x1234_5678
__push32 #0xFFAD_BEEF
pushw #sum

call add32

; disacard params
; TODO: there is probably a faster way to write to the SP to discard these... each "pop b" is 5 clock cycles
pop b
pop b
pop b
pop b

pop b
pop b
pop b
pop b

pop b
pop b


;assert hl, #0x88EF

halt


#include "../math.asm"