;;
; @file
; @author Eric Sims
;
; @section Description
; tests trasfer byte microcode
;
; @section Test Coverage
; @coverage xfr8_dir_dir_imm xfr8
;
;;

; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP
main:
    xfr8 test_src, test_dst, #(test_src.end - test_src)

    ; check result
    pushw #test_src
    pushw #test_dst
    call strcmp
    dealloc 4
    assert b, #0
    
    halt

; constants
test_src: #d "this is some test data made up of characters the total length is pretty long, but it is less than the 255 character limit for the xftr 8 instruction\0"
    .end:

; includes
#include "../src/CPU.asm"
#include "../src/lib/char_utils.asm"

; global vars
#bank ram
test_dst: #res 256
STACK_BASE: #res 0