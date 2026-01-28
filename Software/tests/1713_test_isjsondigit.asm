; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    push #"\0"
    call isjsondigit
    pop a
    assert b, #0
    
    push #"a"
    call isjsondigit
    pop a
    assert b, #0

    push #"/"
    call isjsondigit
    pop a
    assert b, #0

    push #"0"
    call isjsondigit
    pop a
    assert b, #1

    push #"1"
    call isjsondigit
    pop a
    assert b, #1

    push #"2"
    call isjsondigit
    pop a
    assert b, #1

    push #"3"
    call isjsondigit
    pop a
    assert b, #1

    push #"4"
    call isjsondigit
    pop a
    assert b, #1

    push #"5"
    call isjsondigit
    pop a
    assert b, #1

    push #"6"
    call isjsondigit
    pop a
    assert b, #1

    push #"7"
    call isjsondigit
    pop a
    assert b, #1

    push #"8"
    call isjsondigit
    pop a
    assert b, #1

    push #"9"
    call isjsondigit
    pop a
    assert b, #1

    push #":"
    call isjsondigit
    pop a
    assert b, #0
    
    push #"-"
    call isjsondigit
    pop a
    assert b, #1

    push #"+"
    call isjsondigit
    pop a
    assert b, #1

    push #"e"
    call isjsondigit
    pop a
    assert b, #1

    push #"E"
    call isjsondigit
    pop a
    assert b, #1
    
    push #"/"
    call isjsondigit
    pop a
    assert b, #0

    push #","
    call isjsondigit
    pop a
    assert b, #0
    
    halt

; includes
#include "../src/CPU.asm"
#include "../src/lib/char_utils.asm"

; global vars
#bank ram
STACK_BASE: #res 0