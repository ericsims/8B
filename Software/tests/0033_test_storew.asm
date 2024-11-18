;;
; @file
; @author Eric Sims
;
; @section Description
; tests storing immediate words 
;
; @section Test Coverage
; @coverage storew_imm_dir
;
;;

; program entry
#bank rom
top:
    ; test storew imm to direct address
    storew #0x3456, var2
    load a, var2
    assert a, #0x34 ; check that the write/read was sucessful
    load a, var2+1
    assert a, #0x56 ; check that the write/read was sucessful

    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"

; global vars
#bank ram
var1: #res 1
var2: #res 2