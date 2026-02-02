;;
; @file
; @author Eric Sims
;
; @section Description
; tests flags
;
; @section Test Coverage
; @coverage test_a test_b
;
;;

; program entry
#bank rom
top:
    ; a reg
    load a, #0x00
    test a
    assert zf, #1
    assert nf, #0

    load a, #0x01
    test a
    assert zf, #0
    assert nf, #0

    load a, #0xFF
    test a
    assert zf, #0
    assert nf, #1

    ; b reg
    load b, #0x00
    test b
    assert zf, #1
    assert nf, #0

    load b, #0x01
    test b
    assert zf, #0
    assert nf, #0

    load b, #0xFF
    test b
    assert zf, #0
    assert nf, #1

    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"

; global vars
; -- none --