;;
; @file
; @author Eric Sims
;
; @section Description
; tests stack manipulation
;
; @section Test Coverage
; @coverage push_imm pop_a pop_b push_a push_b pushw_imm popw_hl pushw_hl push_dir pushw_dir
;
;;

; program entry
#bank rom
top:
    loadw sp, #STACK_BASE

    ; push imm data
    push #0x12
    push #0x34
    push #0x56
    push #0x78
    push #0x9A
    push #0xBC

    ; pop half of it to a register and check
    pop a
    assert a, #0xBC
    pop a
    assert a, #0x9A
    pop a
    assert a, #0x78

    ; pop other half of data to b register and check
    pop b
    assert b, #0x56
    pop b
    assert b, #0x34
    pop b
    assert b, #0x12


    ; push data from a register
    load a, #0xAA
    push a
    load a, #0xBB
    push a
    load a, #0x00

    ; pop and check
    pop a
    assert a, #0xBB
    pop a
    assert a, #0xAA


    ; push data from b register
    load b, #0xCC
    push b
    load b, #0xDD
    push b
    load b, #0x00

    ; pop and check
    pop b
    assert b, #0xDD
    pop b
    assert b, #0xCC

    ; push data from direct address
    store #0xAB, var8
    push var8
    ; pop and check
    pop a
    assert a, #0xAB

    ; push imm data word
    pushw #0x1234
    pushw #0x4567
    popw hl
    assert hl, #0x4567
    popw hl
    assert hl, #0x1234

    loadw hl, #0xDEAD
    pushw hl
    loadw hl, #0xBEEF
    popw hl
    assert hl, #0xDEAD

    ; push word from direct address
    storew #0x1234, var16
    pushw var16
    storew #0x4567, var16
    pushw var16
    popw hl
    assert hl, #0x4567
    popw hl
    assert hl, #0x1234


    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"

; global vars
#bank ram
var8: #res 1
var16: #res 2
STACK_BASE: #res 0