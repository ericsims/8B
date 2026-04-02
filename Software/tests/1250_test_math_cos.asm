#include "../src/CPU.asm"

#bank rom

top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

test:
quadrant_1:
    pushw #0 ; result
    push #0x1 ; x
    call cos
    dealloc 1
    popw hl
    assert hl, #0x0100 ; cos(0x00)=0x0100
    
    pushw #0 ; result
    push #0x20 ; x
    call cos
    dealloc 1
    popw hl
    assert hl, #0x00B5 ; cos(0x09)=0x00B5
    
    pushw #0 ; result
    push #0x3F ; x
    call cos
    dealloc 1
    popw hl
    assert hl, #0x0006 ; cos(0x3F)=0x0006

quadrant_2:
    pushw #0 ; result
    push #0x40 ; x
    call cos
    dealloc 1
    popw hl
    assert hl, #0x0000 ; cos(0x40)=0x0000

    pushw #0 ; result
    push #0x60 ; x
    call cos
    dealloc 1
    popw hl
    assert hl, #0xFF4B ; cos(0x60)=0xFF4B

    pushw #0 ; result
    push #0x7F ; x
    call cos
    dealloc 1
    popw hl
    assert hl, #0xFF00 ; cos(0x7F)=0xFF00

quadrant_3:
    pushw #0 ; result
    push #0x80 ; x
    call cos
    dealloc 1
    popw hl
    assert hl, #0xFF00 ; cos(0x80)=0xFF00

    pushw #0 ; result
    push #0xA0 ; x
    call cos
    dealloc 1
    popw hl
    assert hl, #0xFF4B ; cos(0xA0)=0xFF4B

    pushw #0 ; result
    push #0xBF ; x
    call cos
    dealloc 1
    popw hl
    assert hl, #0xFFFA ; cos(0xBF)=0xFFFA


quadrant_4:
    pushw #0 ; result
    push #0xC0 ; x
    call cos
    dealloc 1
    popw hl
    assert hl, #0x0000 ; cos(0xC0)=0x0000

    pushw #0 ; result
    push #0xE0 ; x
    call cos
    dealloc 1
    popw hl
    assert hl, #0x00B5 ; cos(0xE0)=0x00B5

    pushw #0 ; result
    push #0xFF ; x
    call cos
    dealloc 1
    popw hl
    assert hl, #0x0100 ; cos(0xFF)=0x0100

    halt


#include "../src/lib/lib_math_trig.asm"

#bank ram
result: #res 4
STACK_BASE: #res 0