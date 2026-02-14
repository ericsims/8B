; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:

    call sd_init
    assert b, #0x00
    
    call fs_read_mbr
    assert b, #0

    halt

; includes
#include "../src/CPU.asm"
#include "../src/lib/lib_fs.asm"
#include "../src/lib/lib_sd.asm"

; global vars
#bank ram
token_name: #res 128
STACK_BASE: #res 1024