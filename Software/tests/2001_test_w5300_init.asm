; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:

    call w5300_init
    assert b, #0

    call print_net_info

    halt

; includes
#include "../src/CPU.asm"
#include "../src/lib/lib_w5300.asm"

; global vars
#bank ram
STACK_BASE: #res 1024