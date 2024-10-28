#include "../src/CPU.asm"

top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    pushw #data_test
    push #255
    call uart_dump_mem
    popw hl
    pop b

    halt

#include "../src/lib/char_utils.asm"

data_test:
#d "THIS IS A VERY LONG DATA BLOCK"
#d "THIS IS A VERY LONG DATA BLOCK"
#d "THIS IS A VERY LONG DATA BLOCK"
#d "THIS IS A VERY LONG DATA BLOCK"
#d "THIS IS A VERY LONG DATA BLOCK"
#d "THIS IS A VERY LONG DATA BLOCK"
#d "THIS IS A VERY LONG DATA BLOCK"
#d "THIS IS A VERY LONG DATA BLOCK"
#d "THIS IS A VERY LONG DATA BLOCK"
#d "THIS IS A VERY LONG DATA BLOCK"
#d "THIS IS A VERY LONG DATA BLOCK"
#d "THIS IS A VERY LONG DATA BLOCK"
#d "THIS IS A VERY LONG DATA BLOCK"
#d "THIS IS A VERY LONG DATA BLOCK"
#d "THIS IS A VERY LONG DATA BLOCK"
#d "THIS IS A VERY LONG DATA BLOCK"

#bank ram
STACK_BASE:
    #res 0