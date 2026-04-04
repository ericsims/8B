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
    call umult8
    dealloc 2
    popw hl
    assert hl, #0x0000

    pushw #0
    push #0xAB
    push #0xBC
    call umult8
    dealloc 2
    popw hl
    assert hl, #(0xAB*0xBC)
    
    pushw #0
    push #0x78
    push #0x9A
    call umult8
    dealloc 2
    popw hl
    assert hl, #(0x78*0x9A)
    
    pushw #0
    push #0xFF
    push #0xFF
    call umult8
    dealloc 2
    popw hl
    assert hl, #(0xFF*0xFF)

    halt


; includes
#include "../src/CPU.asm"
#include "../src/lib/lib_math.asm"

; global vars
#bank ram
STACK_BASE: #res 0