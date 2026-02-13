; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:

    ; test CS
    store #0x01, SDCARD_CTRL
    load a, SDCARD_CTRL
    and a, #0x01
    assert a, #0x01
    store #0x00, SDCARD_CTRL
    load a, SDCARD_CTRL
    and a, #0x01
    assert a, #0x00

    call sd_init
    assert b, #0x00

    __push32 #0x00000000
    call sd_read_block
    dealloc 4
    assert b, #0x00

    halt

; includes
#include "../src/CPU.asm"
#include "../src/lib/lib_sd.asm"

; global vars
#bank ram
STACK_BASE: #res 1024