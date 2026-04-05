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

    push #3
    push #-5
    call mult4
    dealloc 2
    assert b, #3*-5

    push #-2
    push #7
    call mult4
    dealloc 2
    assert b, #-2*7

    push #-8
    push #1
    call mult4
    dealloc 2
    assert b, #-8*1

    push #6
    push #-3
    call mult4
    dealloc 2
    assert b, #6*-3

    push #-4
    push #-6
    call mult4
    dealloc 2
    assert b, #-4*-6

    push #5
    push #2
    call mult4
    dealloc 2
    assert b, #5*2

    push #-1
    push #-7
    call mult4
    dealloc 2
    assert b, #-1*-7

    push #7
    push #-8
    call mult4
    dealloc 2
    assert b, #7*-8

    push #-3
    push #4
    call mult4
    dealloc 2
    assert b, #-3*4

    push #2
    push #-2
    call mult4
    dealloc 2
    assert b, #2*-2

    push #-6
    push #3
    call mult4
    dealloc 2
    assert b, #-6*3

    push #1
    push #-4
    call mult4
    dealloc 2
    assert b, #1*-4

    push #-5
    push #5
    call mult4
    dealloc 2
    assert b, #-5*5

    push #4
    push #4
    call mult4
    dealloc 2
    assert b, #4*4

    push #-7
    push #-2
    call mult4
    dealloc 2
    assert b, #-7*-2

    push #0
    push #-6
    call mult4
    dealloc 2
    assert b, #0*-6

    push #-8
    push #-1
    call mult4
    dealloc 2
    assert b, #-8*-1

    push #3
    push #6
    call mult4
    dealloc 2
    assert b, #3*6

    push #-2
    push #-3
    call mult4
    dealloc 2
    assert b, #-2*-3

    push #7
    push #1
    call mult4
    dealloc 2
    assert b, #7*1

    push #7
    push #7
    call mult4
    dealloc 2
    assert b, #7*7

    push #-8
    push #-8
    call mult4
    dealloc 2
    assert b, #-8*-8

    push #7
    push #-8
    call mult4
    dealloc 2
    assert b, #7*-8

    push #-8
    push #7
    call mult4
    dealloc 2
    assert b, #-8*7

    push #6
    push #7
    call mult4
    dealloc 2
    assert b, #6*7

    push #-7
    push #-7
    call mult4
    dealloc 2
    assert b, #-7*-7

    push #-8
    push #6
    call mult4
    dealloc 2
    assert b, #-8*6

    push #6
    push #-8
    call mult4
    dealloc 2
    assert b, #6*-8

    push #5
    push #7
    call mult4
    dealloc 2
    assert b, #5*7

    push #-7
    push #5
    call mult4
    dealloc 2
    assert b, #-7*5

    push #-6
    push #-8
    call mult4
    dealloc 2
    assert b, #-6*-8

    push #7
    push #6
    call mult4
    dealloc 2
    assert b, #7*6

    push #-8
    push #-7
    call mult4
    dealloc 2
    assert b, #-8*-7

    push #4
    push #7
    call mult4
    dealloc 2
    assert b, #4*7

    push #-8
    push #5
    call mult4
    dealloc 2
    assert b, #-8*5

    push #7
    push #-6
    call mult4
    dealloc 2
    assert b, #7*-6

    push #-7
    push #6
    call mult4
    dealloc 2
    assert b, #-7*6

    push #-8
    push #4
    call mult4
    dealloc 2
    assert b, #-8*4

    push #3
    push #7
    call mult4
    dealloc 2
    assert b, #3*7

    push #-7
    push #-6
    call mult4
    dealloc 2
    assert b, #-7*-6

    halt


; includes
#include "../src/CPU.asm"
#include "../src/lib/lib_math.asm"

; global vars
#bank ram
STACK_BASE: #res 0