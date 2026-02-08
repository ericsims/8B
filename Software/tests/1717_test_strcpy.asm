; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    ; copy str
    pushw #ram_str
    pushw #rom_str
    call strcpy
    dealloc 4

    ; check strings match
    pushw #ram_str
    pushw #rom_str
    call strcmp
    assert b, #0
    dealloc 4

    halt

; constants
rom_str: #d "this is a nice long null terminated test string\0"
.end:

; includes
#include "../src/CPU.asm"
#include "../src/lib/char_utils.asm"

; global vars
#bank ram

ram_str: #res (rom_str.end-rom_str)
STACK_BASE: #res 0