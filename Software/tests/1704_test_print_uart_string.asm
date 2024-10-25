#include "../src/CPU.asm"

top:
init_pointers:
loadw sp, #STACK_BASE
storew #0x0000, BP



main:
hello_world:
    jmp .print
    .str: #d "Hello, world!\n\0"
    .print: storew #.str, static_uart_print.data_pointer
    call static_uart_print

fun:
    jmp .print
    .str: #d "This is fun!\n\0"
    .print: storew #.str, static_uart_print.data_pointer
    call static_uart_print

halt

#include "../src/lib/char_utils.asm"


#bank ram
STACK_BASE:
    #res 0