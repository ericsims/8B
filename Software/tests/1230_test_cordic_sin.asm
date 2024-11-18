; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    __push32 #59978
    call cordic_sin

    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"
#include "../src/lib/cordic.asm"

; global vars
#bank ram
STACK_BASE: #res 0