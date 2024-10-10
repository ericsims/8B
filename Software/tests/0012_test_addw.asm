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

loadw hl, #0xABCD
addw hl, #0xEF
assert hl, #0xACBC

loadw hl, #0x00FE
addw hl, #0x01
assert hl, #0x00FF
addw hl, #0x01
assert hl, #0x0100
addw hl, #0x02
assert hl, #0x0102

loadw hl, #0xFFFE
addw hl, #0x01
assert hl, #0xFFFF
addw hl, #0x01
assert hl, #0x0000
addw hl, #0x02
assert hl, #0x0002


; 16 bit subtract
loadw hl, #0x1234
subw hl, #0x00
assert hl, #0x1234

loadw hl, #0x1234
subw hl, #0x45
assert hl, #0x11EF

loadw hl, #0xFFFF
subw hl, #0xFF
assert hl, #0xFF00

loadw hl, #0xFFFE
subw hl, #0xFF
assert hl, #0xFEFF

loadw hl, #0x0000
subw hl, #0x00
assert hl, #0x0000

loadw hl, #0x0000
subw hl, #0x01
assert hl, #0xFFFF

halt