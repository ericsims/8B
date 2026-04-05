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

    push #0x3
    push #0x7
    call umult4
    dealloc 2
    assert b, #0x3*0x7

    push #0x1
    push #0xE
    call umult4
    dealloc 2
    assert b, #0x1*0xE

    push #0x9
    push #0x4
    call umult4
    dealloc 2
    assert b, #0x9*0x4

    push #0x2
    push #0xD
    call umult4
    dealloc 2
    assert b, #0x2*0xD

    push #0x6
    push #0x8
    call umult4
    dealloc 2
    assert b, #0x6*0x8

    push #0x5
    push #0xC
    call umult4
    dealloc 2
    assert b, #0x5*0xC

    push #0x7
    push #0x7
    call umult4
    dealloc 2
    assert b, #0x7*0x7

    push #0x4
    push #0xB
    call umult4
    dealloc 2
    assert b, #0x4*0xB

    push #0xD
    push #0x3
    call umult4
    dealloc 2
    assert b, #0xD*0x3

    push #0x8
    push #0x2
    call umult4
    dealloc 2
    assert b, #0x8*0x2

    push #0xC
    push #0x6
    call umult4
    dealloc 2
    assert b, #0xC*0x6

    push #0xE
    push #0x5
    call umult4
    dealloc 2
    assert b, #0xE*0x5

    push #0xB
    push #0x9
    call umult4
    dealloc 2
    assert b, #0xB*0x9

    push #0xA
    push #0x1
    call umult4
    dealloc 2
    assert b, #0xA*0x1

    push #0x2
    push #0x2
    call umult4
    dealloc 2
    assert b, #0x2*0x2

    push #0x3
    push #0xF
    call umult4
    dealloc 2
    assert b, #0x3*0xF

    push #0x9
    push #0x9
    call umult4
    dealloc 2
    assert b, #0x9*0x9

    push #0x6
    push #0x1
    call umult4
    dealloc 2
    assert b, #0x6*0x1

    push #0xE
    push #0x2
    call umult4
    dealloc 2
    assert b, #0xE*0x2

    push #0x4
    push #0x4
    call umult4
    dealloc 2
    assert b, #0x4*0x4

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