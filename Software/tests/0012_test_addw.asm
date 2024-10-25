;;
; @file
; @author Eric Sims
;
; @section Description
; tests 16bit adds
;
; @section Test Coverage
; @coverage addw_hl_imm subw_hl_imm
;
;;
#include "../src/CPU.asm"

#bank rom

; 16 bit add tests
loadw hl, #0x1234
addw hl, #0x00
assert hl, #0x1234
assert nf, #0
assert cf, #0

loadw hl, #0xABCD
addw hl, #0xEF
assert hl, #0xACBC
assert nf, #1
assert cf, #0

loadw hl, #0x00FE
addw hl, #0x01
assert hl, #0x00FF
assert nf, #0
assert cf, #0

addw hl, #0x01
assert hl, #0x0100
assert nf, #0
assert cf, #0

addw hl, #0x02
assert hl, #0x0102
assert nf, #0
assert cf, #0

loadw hl, #0xFFFE
addw hl, #0x01
assert hl, #0xFFFF
assert nf, #1
assert cf, #0

addw hl, #0x01
assert hl, #0x0000
assert nf, #0
assert cf, #1

addw hl, #0x02
assert hl, #0x0002
assert nf, #0
assert cf, #0


; 16 bit subtract
loadw hl, #0x1234
subw hl, #0x00
assert hl, #0x1234
assert nf, #0
assert cf, #0

loadw hl, #0x1234
subw hl, #0x45
assert hl, #0x11EF
assert nf, #0
assert cf, #0

loadw hl, #0xFFFF
subw hl, #0xFF
assert hl, #0xFF00
assert nf, #1
assert cf, #0

loadw hl, #0xFFFE
subw hl, #0xFF
assert hl, #0xFEFF
assert nf, #1
assert cf, #0

loadw hl, #0x0000
subw hl, #0x00
assert hl, #0x0000
assert nf, #0
assert cf, #0

loadw hl, #0x0000
subw hl, #0x01
assert hl, #0xFFFF
assert nf, #1
assert cf, #1

halt