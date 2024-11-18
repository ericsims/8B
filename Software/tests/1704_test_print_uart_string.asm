; program entry
#bank rom
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

; constants
; -- none --

; includes
#include "../src/CPU.asm"
#include "../src/lib/char_utils.asm"

; global vars
#bank ram
STACK_BASE: #res 0