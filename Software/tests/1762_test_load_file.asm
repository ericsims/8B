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
    assert b, #0

    storew #file_handle.buf, static_uart_print.data_pointer
    call static_uart_print

    halt

fname: #d "HELLO   TXT \0"


; includes
#include "../src/CPU.asm"
#include "../src/lib/char_utils.asm"
#include "../src/lib/lib_fs.asm"

; global vars
#bank ram
token_name: #res 128
STACK_BASE: #res 1024