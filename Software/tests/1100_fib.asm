#include "../src/CPU.asm"

#bank rom

store #0x01, last_sum
load a, #0x00
top:
    load b, last_sum
    ;sta UART
    store a, last_sum
    add a, b
    load b, a
    jnc top


load a, last_sum
assert a, #233 ; last fib number <255 should be 233

halt

#bank ram
last_sum:
    #res 1
