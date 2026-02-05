; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    call fs_read_mbr
    assert b, #0

    pushw #fname
    call fs_find_file
    dealloc 2
    assert b, #0

    call load_file

    ; pushw #file_handle.buf
    ; pushw #token_name
    ; pushw #token_name
    ; push #0
    ; call json_print
    ; dealloc 7
    ; assert b, #0

    halt

fname: #d "DUMPY   TXT \0"

; includes
#include "../src/CPU.asm"
#include "../src/lib/char_utils.asm"
#include "../src/lib/fs.asm"
#include "../src/lib/json_print.asm"

; global vars
#bank ram
token_name: #res 128
STACK_BASE: #res 1024