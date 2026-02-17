; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    pushw #data_test/16*16
    push #0x10
    call uart_dump_mem
    dealloc 3

    halt



; constants
data_test:
#d "THIS IS A VERY LONG DATA BLOCK\0"
#d "THIS IS A VERY LONG DATA BLOCK\0"
#d "THIS IS A VERY LONG DATA BLOCK\0"
#d "THIS IS A VERY LONG DATA BLOCK\0"
#d "THIS IS A VERY LONG DATA BLOCK\0"
#d "THIS IS A VERY LONG DATA BLOCK\0"
#d "THIS IS A VERY LONG DATA BLOCK\0"
#d "THIS IS A VERY LONG DATA BLOCK\0"
#d "THIS IS A VERY LONG DATA BLOCK\0"
#d "THIS IS A VERY LONG DATA BLOCK\0"
#d "THIS IS A VERY LONG DATA BLOCK\0"
#d "THIS IS A VERY LONG DATA BLOCK\0"
#d "THIS IS A VERY LONG DATA BLOCK\0"

; includes
#include "../src/CPU.asm"
#include "../src/lib/char_utils.asm"

; global vars
#bank ram
STACK_BASE: #res 0