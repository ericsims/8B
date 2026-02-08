; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:

    pushw #test_str1
    call cli_parse_cmd
    dealloc 2
    assert b, #1
    
    pushw #test_str2
    call cli_parse_cmd
    dealloc 2
    assert b, #2

    pushw #test_str3
    call cli_parse_cmd
    dealloc 2
    assert b, #0xFF

    pushw #test_str4
    call cli_parse_cmd
    dealloc 2
    assert b, #0

    pushw #test_str5
    call cli_parse_cmd
    dealloc 2
    assert b, #0

    halt

test_str1: #d "TEST1\0"
test_str2: #d "TEST2\0"
test_str3: #d "FAKE\0"
test_str4: #d "$?\0"
test_str5: #d "HELP\0"


; includes
#bank rom
#include "../src/CPU.asm"
#include "../src/lib/cli.asm"

; global vars
#bank ram
STACK_BASE: #res 1024