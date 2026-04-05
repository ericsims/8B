; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

test:
    pushw #0
    push #0
    push #0
    call mult8
    dealloc 2
    popw hl
    assert hl, #0x0000

    pushw #0
    push #111
    push #123
    call mult8
    dealloc 2
    popw hl
    assert hl, #111*123
    
    pushw #0
    push #77
    push #-115
    call mult8
    dealloc 2
    popw hl
    assert hl, #77*-115
    
    pushw #0
    push #-123
    push #-109
    call mult8
    dealloc 2
    popw hl
    assert hl, #-123*-109

    pushw #0
    push #49
    push #-49
    call mult8
    dealloc 2
    popw hl
    assert hl, #49*-49

    halt


; includes
#include "../src/CPU.asm"
#include "../src/lib/lib_math.asm"

; global vars
#bank ram
STACK_BASE: #res 0