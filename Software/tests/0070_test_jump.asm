;;
; @file
; @author Eric Sims
;
; @section Description
; tests unconditional jump
;
; @section Test Coverage
; @coverage jmp
;
;;

; program entry
#bank rom
top:
    load a, #0xAA
    assert a, #0xAA

    jmp next

    assert a, #0x00 ; fail if no jump
    halt

    next:
    load a, #0xBB
    assert a, #0xBB

halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"

; global vars
; -- none --