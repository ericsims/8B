#include "../src/CPU.asm"

#bank rom

top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    __push32 #59978
    call cordic_sin




halt


#include "../src/lib/cordic.asm"


#bank ram
STACK_BASE:
    #res 0