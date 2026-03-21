; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:


    storew #str_init, static_uart_print.data_pointer
    call static_uart_print

    call w5300_init
    assert b, #0

    call print_net_info

    call dns_init

    storew #str_query, static_uart_print.data_pointer
    call static_uart_print

    pushw #0
    call dns_lookup
    dealloc 2


    halt



; includes
#include "../src/CPU.asm"
#include "../src/lib/lib_dns.asm"

#bank rom


str_init: #d "initializing...\n\0"
str_query: #d "making dns query...\n \0"
str_done: #d "done.\n \0"

; global vars
#bank ram
STACK_BASE: #res 1024