; program entry
#bank rom
top:
    store #0x01, last_sum
    load a, #0x00
    .loop:
        load b, last_sum
        ;sta UART
        store a, last_sum
        add a, b
        load b, a
        jnc .loop


    load a, last_sum
    assert a, #233 ; last fib number <255 should be 233

    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"

; global vars
#bank ram
last_sum: #res 1
