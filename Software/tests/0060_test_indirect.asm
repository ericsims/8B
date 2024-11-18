;;
; @file
; @author Eric Sims
;
; @section Description
; tests indirect loads and stores
;
; @section Test Coverage
; @coverage load_a_indir load_b_indir
;
;;

; program entry
#bank rom
top:
    store #0x12, location1
    storew #location1, pointer1
    load a, (pointer1)
    load b, (pointer1)
    assert a, #0x12
    assert b, #0x12

    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"

; global vars
#bank ram
location1: #res 1
pointer1: #res 2
