; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

test:
    push #0
    push #0
    call mult4
    dealloc 2
    assert b, #0

    push #15
    push #8
    call mult4
    dealloc 2
    assert b, #15*8

    push #-7
    push #9
    call mult4
    dealloc 2
    assert b, #-7*9

    push #-11
    push #-14
    call mult4
    dealloc 2
    assert b, #-11*-14

    halt


; includes
#include "../src/CPU.asm"
#include "../src/lib/lib_math.asm"

; global vars
#bank ram
STACK_BASE: #res 0