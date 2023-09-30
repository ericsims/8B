#include "../src/CPU.asm"

#bank rom

store #0x01, LAST_RES_PTR
load a, #0x00
top:
    load b, LAST_RES_PTR
    ;sta UART
    store a, LAST_RES_PTR
    add a, b
    load b, a
    jnc top


load a, LAST_RES_PTR
assert a, #233 ; last fib number <255 should be 233

halt

#bank ram
LAST_RES_PTR:
    #res 1
