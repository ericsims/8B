; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

test_sqrt:
    ; sqrt(0) = 0
    push #0x00 ; result placeholder
    pushw #0x0
    call sqrt
    popw hl
    pop a
    ; assert a, #0

    ; sqrt(1) = 1
    push #0x00 ; result placeholder
    pushw #1
    call sqrt
    popw hl
    pop a
    ; assert a, #1

    ; sqrt(15) = 3
    push #0x00 ; result placeholder
    pushw #15
    call sqrt
    popw hl
    pop a
    ; assert a, #3

    ; sqrt(16) = 4
    push #0x00 ; result placeholder
    pushw #16
    call sqrt
    popw hl
    pop a
    ; assert a, #4

    ; sqrt(0x1234) = 0x44
    push #0x00 ; result placeholder
    pushw #0x1234
    call sqrt
    popw hl
    pop a
    assert a, #0x44

    ; sqrt(0xDEAD) = 0xEE
    push #0x00 ; result placeholder
    pushw #0xDEAD
    call sqrt
    popw hl
    pop a
    assert a, #0xEE

    ; sqrt(0xBEEF) = 0xDD
    push #0x00 ; result placeholder
    pushw #0xBEEF
    call sqrt
    popw hl
    pop a
    ; assert a, #0xDD

    ; sqrt(0xFFFF) = 0xFF
    push #0x00 ; result placeholder
    pushw #0xFFFF
    call sqrt
    popw hl
    pop a
    assert a, #0xFF

done:
    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"
#include "../src/lib/math_sqrt.asm"
#include "../src/lib/static_math.asm"

; global vars
#bank ram
STACK_BASE: #res 0