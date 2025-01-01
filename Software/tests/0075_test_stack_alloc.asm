;;
; @file
; @author Eric Sims
;
; @section Description
; tests allocating bytes on the stack
;
; @section Test Coverage
; @coverage alloc
;
;;

; program entry
#bank rom
top:
    loadw sp, #STACK_BASE

    alloc 0
    loadw hl, sp
    assert hl, #STACK_BASE

    alloc 1
    loadw hl, sp
    assert hl, #STACK_BASE+1
    
    alloc 19
    loadw hl, sp
    assert hl, #STACK_BASE+20

    alloc 200
    loadw hl, sp
    assert hl, #STACK_BASE+220

    alloc 200
    loadw hl, sp
    assert hl, #STACK_BASE+420

    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"

; global vars
#bank ram
DUMMY: #res 250
STACK_BASE: #res 0