;;
; @file
; @author Eric Sims
;
; @section Description
; tests hl register immedate loads
;
; @section Test Coverage
; @coverage loadw_hl_imm loadw_hl_dir storew_hl_dir
;
;;

#include "../src/CPU.asm"

#bank ram
w:
    #res 2

#bank rom

; tests load hl register with immediate value

loadw hl, #0x0000
assert hl, #0x0000 ; check that hl reg is correct

loadw hl, #0x0001
assert hl, #0x001 ; check that hl reg is correct

loadw hl, #0xAAAA
assert hl, #0xAAAA ; check that hl reg is correct
halt
loadw hl, #0x55
assert hl, #0x55 ; check that hl reg is correct

loadw hl, #0xFFFF
assert hl, #0xFFFF ; check that hl reg is correct

loadw hl, #0x1
assert hl, #0x1; check that hl reg is correct

loadw hl, #0xF
assert hl, #0xF; check that hl reg is correct

loadw hl, #0x0000
assert hl, #0x0000 ; check that hl reg is correct

storew #0xABCD, w
loadw hl, w
assert hl, #0xABCD

loadw hl, #0xDEAD
storew hl, w
loadw hl, #0xBEEF
loadw hl, w
assert hl, #0xDEAD

halt