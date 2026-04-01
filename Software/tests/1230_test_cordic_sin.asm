; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    pushw #output
    __push32 #59978
    call cordic_sin

    dealloc 6

    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"
#include "../src/lib/cordic.asm"

; global vars
#bank ram
output: #res 2
STACK_BASE: #res 0