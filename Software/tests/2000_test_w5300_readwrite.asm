; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    load a, W5300_MR0
    assert a, #0x38 ; check init value or MR0

    loadw hl, W5300_IDR0
    assert hl, #0x5300 ; check id reg
    halt

; includes
#include "../src/CPU.asm"
#include "../src/lib/lib_w5300.asm"

; global vars
#bank ram
STACK_BASE: #res 1024