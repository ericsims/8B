#include "../src/CPU.asm"

top:
init_pointers:
loadw sp, #DEFAULT_STACK
storew #0x0000, BP

main:
storew #str_1, static_uart_print.data_pointer
call static_uart_print

storew #str_2, static_uart_print.data_pointer
call static_uart_print

halt

str_1: #d "hello world\n\0"
str_2: #d "This assembly thing seems to be working!!!\nyay.\n\0"


#include "../src/lib/char_utils.asm"