;;
; @file
; @author Eric Sims
;
; @section Description
; tests add and subtract
;
; @section Test Coverage
; @coverage add_a_imm add_b_imm add_a_b sub_a_imm sub_b_imm sub_a_b
;
;;

; program entry
#bank rom
top:
    ; a register imm adds
    load a, #0x05
    add a, #0x06
    assert cf, #0
    assert zf, #0
    assert nf, #0
    assert a, #0x0B

    load a, #0x00
    add a, #0x00
    assert cf, #0
    assert zf, #1
    assert nf, #0

    load a, #0xFA
    add a, #0xAB
    assert cf, #1
    assert zf, #0
    assert nf, #1
    assert a, #0xA5

    ; b register imm adds
    load b, #0x05
    add b, #0x06
    assert cf, #0
    assert zf, #0
    assert nf, #0
    assert b, #0x0B

    load b, #0x00
    add b, #0x00
    assert cf, #0
    assert zf, #1
    assert nf, #0
    assert b, #0x00

    load b, #0xFA
    add b, #0xAB
    assert cf, #1
    assert zf, #0
    assert nf, #1
    assert b, #0xA5

    ; a + b adds
    load a, #0xAB
    load b, #0xCD
    add a, b
    assert cf, #1
    assert zf, #0
    assert nf, #0
    assert a, #0x78

    ; a sub imm
    load a, #0x00
    sub a, #0x00
    assert cf, #0
    assert zf, #1
    assert nf, #0
    assert a, #0x00

    load a, #0x00
    sub a, #0x01
    assert cf, #1
    assert zf, #0
    assert nf, #1
    assert a, #0xFF

    load a, #0xCD
    sub a, #0xAB
    assert cf, #0
    assert zf, #0
    assert nf, #0
    assert a, #0x22

    load a, #0xAB
    sub a, #0xCD
    assert cf, #1
    assert zf, #0
    assert nf, #1
    assert a, #0xDE

    ; b sub imm
    load b, #0x00
    sub b, #0x00
    assert cf, #0
    assert zf, #1
    assert nf, #0
    assert b, #0x00

    load b, #0x00
    sub b, #0x01
    assert cf, #1
    assert zf, #0
    assert nf, #1
    assert b, #0xFF

    load b, #0xCD
    sub b, #0xAB
    assert cf, #0
    assert zf, #0
    assert nf, #0
    assert b, #0x22

    load b, #0xAB
    sub b, #0xCD
    assert cf, #1
    assert zf, #0
    assert nf, #1
    assert b, #0xDE

    ; a - b subs
    load a, #0xAB
    load b, #0xCD
    sub a, b
    assert cf, #1
    assert zf, #0
    assert nf, #1
    assert a, #0xDE

    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"

; global vars
; -- none --