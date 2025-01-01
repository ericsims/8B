;;
; @file
; @author Eric Sims
;
; @section Description
; tests indirect loads and stores
;
; @section Test Coverage
; @coverage store_a_indir store_b_indir load_a_indir load_b_indir
;
;;

; program entry
#bank rom
top:
    storew #location1, pointer1

    ; test store_a_indir
    load a, #0x12
    store a, (pointer1)
    load a, #0xFF ; clear value
    load a, location1 ; load value from RAM with direct addressing
    assert a, #0x12

    ; test store_b_indir
    load b, #0x24
    store b, (pointer1)
    load a, #0xFF ; clear value
    load a, location1 ; load value from RAM with direct addressing
    assert a, #0x24
    
    ; test load_a_indir and load_b_indir
    store #0x34, location1
    load a, (pointer1)
    load b, (pointer1)
    assert a, #0x34
    assert b, #0x34

    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"

; global vars
#bank ram
location1: #res 1
pointer1: #res 2
