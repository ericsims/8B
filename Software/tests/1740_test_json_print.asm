; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    pushw #data_test1
    pushw #token_name
    pushw #token_name
    push #0
    call json_print
    dealloc 7
    assert b, #0


    pushw #data_test2
    pushw #token_name
    pushw #token_name
    push #0
    call json_print
    dealloc 7
    assert b, #0

    pushw #data_test3
    pushw #token_name
    pushw #token_name
    push #0
    call json_print
    dealloc 7
    assert b, #0

    pushw #data_test4
    pushw #token_name
    pushw #token_name
    push #0
    call json_print
    dealloc 7
    assert b, #0
    halt

jmp 0

; includes
#include "../src/CPU.asm"
#include "../src/lib/char_utils.asm"
#include "../src/lib/json_print.asm"

data_test1: #d incbin("./json_test_data1.json"), 0x00
data_test2: #d incbin("./json_test_data2.json"), 0x00
data_test3: #d incbin("./json_test_data3.json"), 0x00
data_test4: #d incbin("./json_test_data4.json"), 0x00

; global vars
#bank ram
token_name: #res 128
STACK_BASE: #res 1024