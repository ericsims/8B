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

    storew #test_src, src_ptr
    xfr_set_len #(test_src.end - test_src)
    xfr_set_dst test_dst
    xfr_set_src (src_ptr)
    xfr8_loop

    ; check result
    pushw #test_src
    pushw #test_dst
    call strcmp
    dealloc 4
    assert b, #0
    
    halt

; constants
test_src: #d "this is some test data made up of characters the total length is pretty long, but it is less than the 255 character limit for the xfr 8 instruction. Here are some more characters to add to the string. Oh and some numbers too 1234!\0"
    .end:

; includes
#include "../src/CPU.asm"
#include "../src/lib/char_utils.asm"

; global vars
#bank ram
src_ptr: #res 2
test_dst: #res 256
STACK_BASE: #res 0