;;
; @file
; @author Eric Sims
;
; @section Description
; tests deallocating bytes from stack
;
; @section Test Coverage
; @coverage dalloc
;
;;

; program entry
#bank rom
top:
    loadw sp, #STACK_BASE

    push #0x00
    push #0x11
    push #0x22
    push #0x33
    push #0x44
    push #0x55
    push #0x66
    push #0x77
    push #0x88
    push #0x99
    push #0xAA
    push #0xBB
    push #0xCC
    push #0xDD
    push #0xEE
    push #0xFF

    dalloc 0
    pop a
    assert a, #0xFF
    
    dalloc 1
    pop a
    assert a, #0xDD

    dalloc 2
    pop a
    assert a, #0xAA

    dalloc 8
    pop a
    assert a, #0x11

    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"

; global vars
#bank ram
DUMMY: #res 250
STACK_BASE: #res 0