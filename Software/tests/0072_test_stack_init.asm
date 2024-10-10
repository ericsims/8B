;;
; @file
; @author Eric Sims
;
; @section Description
; tests initializing stack pointer
;
; @section Test Coverage
; @coverage loadw_sp_imm loadw_hl_sp
;
;;
#include "../src/CPU.asm"

#bank rom

top:
loadw sp, #DEFAULT_STACK
loadw hl, sp
assert hl, #DEFAULT_STACK

halt