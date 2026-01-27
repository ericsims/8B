; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    push #"a"
    call isspace
    pop a
    assert b, #0
    
    push #" "
    call isspace
    pop a
    assert b, #1

    push #"\t"
    call isspace
    pop a
    assert b, #1

    push #"\r"
    call isspace
    pop a
    assert b, #1

    push #"\n"
    call isspace
    pop a
    assert b, #1

    push #0x0B ; vertical tab lol
    call isspace
    pop a
    assert b, #1
    
    push #0x0C ; form feed kek
    call isspace
    pop a
    assert b, #1
    
    halt

; includes
#include "../src/CPU.asm"
#include "../src/lib/char_utils.asm"

; global vars
#bank ram
STACK_BASE: #res 0