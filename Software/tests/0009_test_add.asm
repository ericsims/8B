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
    assert a, #0x0B
    assert cf, #0
    assert zf, #0
    assert nf, #0

    load a, #0x00
    add a, #0x00
    assert cf, #0
    assert zf, #1
    assert nf, #0

    load a, #0xFA
    add a, #0xAB
    assert a, #0xA5
    assert cf, #1
    assert zf, #0
    assert nf, #1

    ; b register imm adds
    load b, #0x05
    add b, #0x06
    assert b, #0x0B
    assert cf, #0
    assert zf, #0
    assert nf, #0

    load b, #0x00
    add b, #0x00
    assert b, #0x00
    assert cf, #0
    assert zf, #1
    assert nf, #0

    load b, #0xFA
    add b, #0xAB
    assert b, #0xA5
    assert cf, #1
    assert zf, #0
    assert nf, #1

    ; a + b adds
    load a, #0xAB
    load b, #0xCD
    add a, b
    assert a, #0x78
    assert cf, #1
    assert zf, #0
    assert nf, #0

    ; a sub imm
    load a, #0x00
    sub a, #0x00
    assert a, #0x00
    assert cf, #0
    assert zf, #1
    assert nf, #0

    load a, #0x00
    sub a, #0x01
    assert a, #0xFF
    assert cf, #1
    assert zf, #0
    assert nf, #1

    load a, #0xCD
    sub a, #0xAB
    assert a, #0x22
    assert cf, #0
    assert zf, #0
    assert nf, #0

    load a, #0xAB
    sub a, #0xCD
    assert a, #0xDE
    assert cf, #1
    assert zf, #0
    assert nf, #1

    ; b sub imm
    load b, #0x00
    sub b, #0x00
    assert b, #0x00
    assert cf, #0
    assert zf, #1
    assert nf, #0

    load b, #0x00
    sub b, #0x01
    assert b, #0xFF
    assert cf, #1
    assert zf, #0
    assert nf, #1

    load b, #0xCD
    sub b, #0xAB
    assert b, #0x22
    assert cf, #0
    assert zf, #0
    assert nf, #0

    load b, #0xAB
    sub b, #0xCD
    assert b, #0xDE
    assert cf, #1
    assert zf, #0
    assert nf, #1

    ; a - b subs
    load a, #0xAB
    load b, #0xCD
    sub a, b
    assert a, #0xDE
    assert cf, #1
    assert zf, #0
    assert nf, #1

    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"

; global vars
; -- none --