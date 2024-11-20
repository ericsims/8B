; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

test:
    __store32 #0x1234_5678, inx
    __store32 #0xFFAD_BEEF, iny

    pushw #inx
    pushw #iny
    pushw #result
    call add32
    dalloc 6

    ; check result is 0x11E2_1567
    load a, result
    assert a, #0x11
    load a, result+1
    assert a, #0xE2
    load a, result+2
    assert a, #0x15
    load a, result+3
    assert a, #0x67

    assert b, #0x01

    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"
#include "../src/lib/math.asm"

; global vars
#bank ram
inx: #res 4
iny: #res 4
result: #res 4
STACK_BASE: #res 0