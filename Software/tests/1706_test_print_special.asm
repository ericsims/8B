#include "../src/CPU.asm"

top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    storew #data_test, static_uart_print.data_pointer
    call static_uart_print
    
    halt

#include "../src/lib/char_utils.asm"

data_test:
#d "abc\x08def\n\0"

#bank ram
STACK_BASE:
    #res 0