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

    pushw #0
    push #0x31
    push #0x31
    call umult8
    dealloc 2
    popw hl
    assert hl, #(0x31*0x31)

    pushw #0
    push #0xFE
    push #0xFF
    call umult8
    dealloc 2
    popw hl
    assert hl, #(0xFE*0xFF)

    pushw #0
    push #0xFD
    push #0xFE
    call umult8
    dealloc 2
    popw hl
    assert hl, #(0xFD*0xFE)

    pushw #0
    push #0xF0
    push #0xF0
    call umult8
    dealloc 2
    popw hl
    assert hl, #(0xF0*0xF0)

    pushw #0
    push #0xE1
    push #0xF2
    call umult8
    dealloc 2
    popw hl
    assert hl, #(0xE1*0xF2)

    pushw #0
    push #0xC8
    push #0xD4
    call umult8
    dealloc 2
    popw hl
    assert hl, #(0xC8*0xD4)

    pushw #0
    push #0xFF
    push #0x80
    call umult8
    dealloc 2
    popw hl
    assert hl, #(0xFF*0x80)

    pushw #0
    push #0x80
    push #0x80
    call umult8
    dealloc 2
    popw hl
    assert hl, #(0x80*0x80)

    pushw #0
    push #0x7F
    push #0xFF
    call umult8
    dealloc 2
    popw hl
    assert hl, #(0x7F*0xFF)

    pushw #0
    push #0xAA
    push #0xFF
    call umult8
    dealloc 2
    popw hl
    assert hl, #(0xAA*0xFF)

    pushw #0
    push #0xCC
    push #0xDD
    call umult8
    dealloc 2
    popw hl
    assert hl, #(0xCC*0xDD)

    pushw #0
    push #0x99
    push #0xEE
    call umult8
    dealloc 2
    popw hl
    assert hl, #(0x99*0xEE)

    pushw #0
    push #0xF8
    push #0x0F
    call umult8
    dealloc 2
    popw hl
    assert hl, #(0xF8*0x0F)

    pushw #0
    push #0x01
    push #0xFF
    call umult8
    dealloc 2
    popw hl
    assert hl, #(0x01*0xFF)

    pushw #0
    push #0x02
    push #0xFE
    call umult8
    dealloc 2
    popw hl
    assert hl, #(0x02*0xFE)

    pushw #0
    push #0x10
    push #0xF0
    call umult8
    dealloc 2
    popw hl
    assert hl, #(0x10*0xF0)

    pushw #0
    push #0xEF
    push #0xBE
    call umult8
    dealloc 2
    popw hl
    assert hl, #(0xEF*0xBE)

    pushw #0
    push #0xD3
    push #0xF7
    call umult8
    dealloc 2
    popw hl
    assert hl, #(0xD3*0xF7)

    pushw #0
    push #0xB6
    push #0xE9
    call umult8
    dealloc 2
    popw hl
    assert hl, #(0xB6*0xE9)

    pushw #0
    push #0xFA
    push #0xFA
    call umult8
    dealloc 2
    popw hl
    assert hl, #(0xFA*0xFA)

    pushw #0
    push #0xF1
    push #0x8F
    call umult8
    dealloc 2
    popw hl
    assert hl, #(0xF1*0x8F)

    halt


; includes
#include "../src/CPU.asm"
#include "../src/lib/lib_math.asm"

; global vars
#bank ram
STACK_BASE: #res 0