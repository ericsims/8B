; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

test:
    push #{val_a}
    push #{val_b}
    pushw #sum

    call mult8

    ; disacard params
    ; TODO: there is probably a faster way to write to the SP to discard these... each "pop a" is 5 clock cycles
    pop a
    pop a
    pop a
    pop a

    loadw hl, sum

    assert hl, #(val_a*val_b)

    halt

; constants
val_a=0xFF
val_b=0xFF

; includes
#include "../src/CPU.asm"
#include "../src/lib/math.asm"

; global vars
#bank ram
sum: #res 2 ;result poitbed
STACK_BASE: #res 0