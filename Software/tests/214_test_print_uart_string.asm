#include "../src/CPU.asm"

top:
init_pointers:
loadw sp, #DEFAULT_STACK
storew #0x0000, BP



main:
hello_world:
    jmp .print
    .str: #d "Hello, world!\n\0"
    .print: storew #.str, static_uart_print.data_pointer
    call static_uart_print

fun:
    jmp .print
    .str: #d "Ths is fun!\n\0"
    .print: storew #.str, static_uart_print.data_pointer
    call static_uart_print

halt

#include "../src/lib/char_utils.asm"