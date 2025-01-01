;;
; @file
; @author Eric Sims
;
; @section Description
; tests indirect loads and stores with address in hl reg
;
; @section Test Coverage
; @coverage load_a_hl_indir load_b_hl_indir store_a_hl_indir store_b_hl_indir
;
;;

; program entry
#bank rom
top:
    loadw hl, #location1

    ; test store_a_hl_indir
    load a, #0x12
    store a, (hl)
    load a, #0xFF ; clear value
    load a, location1
    assert a, #0x12
    
    ; test store_b_hl_indir
    load b, #0x23
    store b, (hl)
    load a, #0xFF ; clear value
    load a, location1
    assert a, #0x23

    ; test load_a_hl_indir and load_a_hl_indir
    store #0x34, location1
    load a, (hl)
    load b, (hl)
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
