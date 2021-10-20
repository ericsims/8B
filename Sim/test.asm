#include "CPU.asm"

#bank ram
test_counter:
    #res 1

#bank rom
top:
sti 150, test_counter

loop:

    lda test_counter

    sta uitoa_b.input_byte
    cal uitoa_b
    lda uitoa_b.buffer+0
    sta UART
    lda uitoa_b.buffer+1
    sta UART
    lda uitoa_b.buffer+2
    sta UART
    lda uitoa_b.buffer+3
    sta UART
    sti "\n", UART

    lda test_counter
    lbi 0x01
    add
    sta test_counter

jmp loop


hlt

#include "math.asm"
#include "utils.asm"

