; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    __print_atoi_test #0x00
    __print_atoi_test #0x12
    __print_atoi_test #0x34
    __print_atoi_test #0x56
    __print_atoi_test #0x78
    __print_atoi_test #0x90
    __print_atoi_test #0xAB
    __print_atoi_test #0xCD
    __print_atoi_test #0xEF
    __print_atoi_test #0xFF

    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"
#include "../src/lib/char_utils.asm"
#ruledef
{
    __print_atoi_test #{val: i8} => asm
    {
        push #{val}
        call static_uart_print_hex_prefix
        call uart_print_itoa_hex
        call static_uart_print_newline
        dalloc 1
    }
}

; global vars
#bank ram
STACK_BASE: #res 0