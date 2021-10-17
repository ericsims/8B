#include "CPU.asm"

jmp, top

top:
sti, 0x64, mult_A
sti, 0x03, mult_B
cal, divide
lda, mult_res
sta, UART
hlt


#include "math.asm"



