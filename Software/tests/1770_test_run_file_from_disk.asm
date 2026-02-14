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

    pushw #progspace
    call load_file
    dealloc 2
    assert b, #0

    jmp progspace
    
    halt

fname: #d "HELLO1  BIN \0"

; includes
#bank rom
#include "../src/CPU.asm"
#include "../src/lib/lib_fs.asm"
#include "../src/lib/lib_sd.asm"

; global vars
#bank ram
STACK_BASE: #res 1024

#bank prog
progspace: #res 0