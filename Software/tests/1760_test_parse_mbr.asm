; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    call fs_read_mbr
    assert b, #0

    halt

; includes
#include "../src/CPU.asm"
#include "../src/lib/lib_fs.asm"

; global vars
#bank ram
token_name: #res 128
STACK_BASE: #res 1024