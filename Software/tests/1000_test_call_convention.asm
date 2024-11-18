; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0xABCD, BP

test:
    push #0x12
    push #0x34

    call function

    pop a ; discard parameters
    pop a ; discard parameters

    assert b, #0x46

    halt

; @function
; @section description
; test function
;       _____________________
; -6   |______.param8_a______|
; -5   |______.param8_b______|
; -4   |__________?__________| RESERVED
; -3   |__________?__________|    .
; -2   |__________?__________|    .
; -1   |__________?__________| RESERVED
function: ; x, y (addreses SP+6, SP+5)

    .param8_a = -6
    .param8_b = -5

    __prologue

    load a, (BP), .param8_a
    load b, (BP), .param8_b
    add a, b
    load b, a

    __epilogue
    ret

; constants
; -- none --

; includes
#include "../src/CPU.asm"

; global vars

#bank ram
STACK_BASE: #res 0