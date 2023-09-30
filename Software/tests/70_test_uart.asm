#include "../src/CPU.asm"

top:
init_pointers:
loadw sp, #DEFAULT_STACK
storew #0x0000, BP

main:
store #"H", static_uart_putc.char
call static_uart_putc

halt



#include "../src/lib/char_utils.asm"