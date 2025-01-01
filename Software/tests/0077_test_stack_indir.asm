;;
; @file
; @author Eric Sims
;
; @section Description
; tests stack manipulation with indirect addressing
;
; @section Test Coverage
; @coverage push_indir
;
;;

; program entry
#bank rom
top:
    loadw sp, #STACK_BASE
    storew #location1, pointer1
    store #0x12, location1
    
    ; push indir data
    push (pointer1)

    ; pop value to verify
    pop a
    assert a, #0x12

    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"

; global vars
#bank ram
pointer1: #res 2
location1: #res 1
STACK_BASE: #res 0