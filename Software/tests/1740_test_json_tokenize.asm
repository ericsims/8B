; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    pushw #data_test
    pushw #token_name
    pushw #token_name
    call json_print
    dealloc 6
    
    halt

; includes
#include "../src/CPU.asm"
#include "../src/lib/char_utils.asm"
#include "../src/lib/json.asm"

data_test: #d incbin("./json_test_data3.json"), 0x00

; global vars
#bank ram
token_name: #res 128
STACK_BASE: #res 0