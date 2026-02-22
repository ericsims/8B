;;
; @file
; @author Eric Sims
;
; @section Description
; tests 16bit adds
;
; @section Test Coverage
; @coverage addw_hl_imm subw_hl_imm subw_hl_a subw_hl_b addw_hl_a addw_hl_b
;
;;

; program entry
#bank rom
top:
    ; 16 bit add tests
    loadw hl, #0x1234
    addw hl, #0x00
    assert nf, #0
    assert cf, #0
    assert hl, #0x1234

    loadw hl, #0xABCD
    addw hl, #0xEF
    assert nf, #1
    assert cf, #0
    assert hl, #0xACBC

    loadw hl, #0x00FE
    addw hl, #0x01
    assert nf, #0
    assert cf, #0
    assert hl, #0x00FF

    addw hl, #0x01
    assert nf, #0
    assert cf, #0
    assert hl, #0x0100

    addw hl, #0x02
    assert nf, #0
    assert cf, #0
    assert hl, #0x0102

    loadw hl, #0xFFFE
    addw hl, #0x01
    assert nf, #1
    assert cf, #0
    assert hl, #0xFFFF

    addw hl, #0x01
    assert nf, #0
    assert cf, #1
    assert hl, #0x0000

    addw hl, #0x02
    assert nf, #0
    assert cf, #0
    assert hl, #0x0002


    ; 16 bit subtract
    loadw hl, #0x1234
    subw hl, #0x00
    assert nf, #0
    assert cf, #0
    assert hl, #0x1234

    loadw hl, #0x1234
    subw hl, #0x45
    assert nf, #0
    assert cf, #0
    assert hl, #0x11EF

    loadw hl, #0xFFFF
    subw hl, #0xFF
    assert nf, #1
    assert cf, #0
    assert hl, #0xFF00

    loadw hl, #0xFFFE
    subw hl, #0xFF
    assert nf, #1
    assert cf, #0
    assert hl, #0xFEFF

    loadw hl, #0x0000
    subw hl, #0x00
    assert nf, #0
    assert cf, #0
    assert hl, #0x0000

    loadw hl, #0x0000
    subw hl, #0x01
    assert nf, #1
    assert cf, #1
    assert hl, #0xFFFF

    ; 16 bit subtract a register
    loadw hl, #0x1234
    load b, #0x00
    subw hl, b
    assert nf, #0
    assert cf, #0
    assert hl, #0x1234

    loadw hl, #0x1234
    load b, #0x45
    subw hl, b
    assert nf, #0
    assert cf, #0
    assert hl, #0x11EF

    loadw hl, #0xFFFF
    load b, #0xFF
    subw hl, b
    assert nf, #1
    assert cf, #0
    assert hl, #0xFF00

    loadw hl, #0xFFFE
    load b, #0xFF
    subw hl, b
    assert nf, #1
    assert cf, #0
    assert hl, #0xFEFF

    loadw hl, #0x0000
    load b, #0x00
    subw hl, b
    assert nf, #0
    assert cf, #0
    assert hl, #0x0000

    loadw hl, #0x0000
    load b, #0x01
    subw hl, b
    assert nf, #1
    assert cf, #1
    assert hl, #0xFFFF

    ; 16 bit subtract b register
    loadw hl, #0x1234
    load a, #0x00
    subw hl, a
    assert nf, #0
    assert cf, #0
    assert hl, #0x1234

    loadw hl, #0x1234
    load a, #0x45
    subw hl, a
    assert nf, #0
    assert cf, #0
    assert hl, #0x11EF

    loadw hl, #0xFFFF
    load a, #0xFF
    subw hl, a
    assert nf, #1
    assert cf, #0
    assert hl, #0xFF00

    loadw hl, #0xFFFE
    load a, #0xFF
    subw hl, a
    assert nf, #1
    assert cf, #0
    assert hl, #0xFEFF

    loadw hl, #0x0000
    load a, #0x00
    subw hl, a
    assert nf, #0
    assert cf, #0
    assert hl, #0x0000

    loadw hl, #0x0000
    load a, #0x01
    subw hl, a
    assert nf, #1
    assert cf, #1
    assert hl, #0xFFFF

    ; 16 bit add a register
    loadw hl, #0x1234
    load a, #0x00
    addw hl, a
    assert nf, #0
    assert cf, #0
    assert hl, #0x1234

    loadw hl, #0xABCD
    load a, #0xEF
    addw hl, a
    assert nf, #1
    assert cf, #0
    assert hl, #0xACBC

    loadw hl, #0x00FE
    load a, #0x01
    addw hl, a
    assert nf, #0
    assert cf, #0
    assert hl, #0x00FF

    load a, #0x01
    addw hl, a
    assert nf, #0
    assert cf, #0
    assert hl, #0x0100

    load a, #0x02
    addw hl, a
    assert nf, #0
    assert cf, #0
    assert hl, #0x0102

    loadw hl, #0xFFFE
    load a, #0x01
    addw hl, a
    assert nf, #1
    assert cf, #0
    assert hl, #0xFFFF

    load a, #0x01
    addw hl, a
    assert nf, #0
    assert cf, #1
    assert hl, #0x0000

    load a, #0x02
    addw hl, a
    assert nf, #0
    assert cf, #0
    assert hl, #0x0002

    ; 16 bit add b register
    loadw hl, #0x1234
    load b, #0x00
    addw hl, b
    assert nf, #0
    assert cf, #0
    assert hl, #0x1234

    loadw hl, #0xABCD
    load b, #0xEF
    addw hl, b
    assert nf, #1
    assert cf, #0
    assert hl, #0xACBC

    loadw hl, #0x00FE
    load b, #0x01
    addw hl, b
    assert nf, #0
    assert cf, #0
    assert hl, #0x00FF

    load b, #0x01
    addw hl, b
    assert nf, #0
    assert cf, #0
    assert hl, #0x0100

    load b, #0x02
    addw hl, b
    assert nf, #0
    assert cf, #0
    assert hl, #0x0102

    loadw hl, #0xFFFE
    load b, #0x01
    addw hl, b
    assert nf, #1
    assert cf, #0
    assert hl, #0xFFFF

    load b, #0x01
    addw hl, b
    assert nf, #0
    assert cf, #1
    assert hl, #0x0000

    load b, #0x02
    addw hl, b
    assert nf, #0
    assert cf, #0
    assert hl, #0x0002

    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"

; global vars
; -- none --