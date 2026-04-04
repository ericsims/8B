; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

test:
    push #0
    push #0
    call umult4
    dealloc 2
    assert b, #0

    push #0xA
    push #0xB
    call umult4
    dealloc 2
    assert b, #0xA*0xB

    push #0xF
    push #0xF
    call umult4
    dealloc 2
    assert b, #0xF*0xF

    halt


; includes
#include "../src/CPU.asm"
#include "../src/lib/lib_math.asm"

; global vars
#bank ram
STACK_BASE: #res 0