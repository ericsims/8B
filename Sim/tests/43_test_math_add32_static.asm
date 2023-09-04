#include "../CPU.asm"

#bank ram
sum: #res 4 ; base pointer for function calls



#bank rom

top:
init_pointers:
loadw sp, #0xBFFF
storew #0x0000, BP



storew #0x1234, static_x_32
storew #0x5678, static_x_32+2

storew #0xFFAD, static_y_32
storew #0xBEEF, static_y_32+2

halt

call static_add32


;assert hl, #0x88EF

halt


#include "../math.asm"