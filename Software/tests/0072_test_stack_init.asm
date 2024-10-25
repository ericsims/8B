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
loadw sp, #STACK_BASE
loadw hl, sp
assert hl, #STACK_BASE

halt

#bank ram
STACK_BASE:
    #res 0