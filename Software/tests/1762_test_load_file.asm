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

    pushw #fname
    call fs_find_file
    dealloc 2
    assert b, #0

    pushw #data_loc
    call load_file
    dealloc 2
    assert b, #0

    halt

fname: #d "HELLO   TXT \0"


; includes
#include "../src/CPU.asm"
#include "../src/lib/lib_fs.asm"
#include "../src/lib/lib_sd.asm"

; global vars
#bank ram
token_name: #res 128
data_loc: #res 512
STACK_BASE: #res 1024