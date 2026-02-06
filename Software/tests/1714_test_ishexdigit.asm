; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    push #"\0"
    call ishexdigit
    pop a
    assert b, #0
    
    push #"a"
    call ishexdigit
    pop a
    assert b, #0

    push #"/"
    call ishexdigit
    pop a
    assert b, #0

    push #"0"
    call ishexdigit
    pop a
    assert b, #1

    push #"1"
    call ishexdigit
    pop a
    assert b, #1

    push #"2"
    call ishexdigit
    pop a
    assert b, #1

    push #"3"
    call ishexdigit
    pop a
    assert b, #1

    push #"4"
    call ishexdigit
    pop a
    assert b, #1

    push #"5"
    call ishexdigit
    pop a
    assert b, #1

    push #"6"
    call ishexdigit
    pop a
    assert b, #1

    push #"7"
    call ishexdigit
    pop a
    assert b, #1

    push #"8"
    call ishexdigit
    pop a
    assert b, #1

    push #"9"
    call ishexdigit
    pop a
    assert b, #1

    push #":"
    call ishexdigit
    pop a
    assert b, #0
    
    push #"A"
    call ishexdigit
    pop a
    assert b, #1
    
    push #"B"
    call ishexdigit
    pop a
    assert b, #1
    
    push #"C"
    call ishexdigit
    pop a
    assert b, #1
    
    push #"D"
    call ishexdigit
    pop a
    assert b, #1
    
    push #"E"
    call ishexdigit
    pop a
    assert b, #1
    
    push #"F"
    call ishexdigit
    pop a
    assert b, #1
    
    push #"@"
    call ishexdigit
    pop a
    assert b, #0
    
    push #"G"
    call ishexdigit
    pop a
    assert b, #0
    halt

; includes
#include "../src/CPU.asm"
#include "../src/lib/char_utils.asm"

; global vars
#bank ram
STACK_BASE: #res 0