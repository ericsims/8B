;;
; @file
; @author Eric Sims
;
; @section Description
; tests calls and returns
;
; @section Test Coverage
; @coverage call ret
;
;;

; program entry
#bank rom
top:
    loadw sp, #STACK_BASE

    load a, #0xAA
    assert a, #0xAA

    call func
    assert a, #0xBB

    halt

func:
    load a, #0xBB
    assert a, #0xBB
    ret

; should never reach here
load a, #0xCC
assert a, #0x00

; constants
; -- none --

; includes
#include "../src/CPU.asm"

; global vars
#bank ram
STACK_BASE: #res 0