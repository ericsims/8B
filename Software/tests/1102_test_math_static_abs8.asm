; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

test_abs8:
    ; abs(0) = 0
    store #0x00, static_x_32+3
    call static_abs8
    load a, static_x_32+3
    assert a, #0x00

    ; abs(0x01) = 0x01
    store #0x01, static_x_32+3
    call static_abs8
    load a, static_x_32+3
    assert a, #0x01

    ; abs(0xDE) = 0x22
    store #0xDE, static_x_32+3
    call static_abs8
    load a, static_x_32+3
    assert a, #0x22

    ; abs(0xAD) = 0x53
    store #0xAD, static_x_32+3
    call static_abs8
    load a, static_x_32+3
    assert a, #0x53

    ; abs(0xBE) = 0x42
    store #0xBE, static_x_32+3
    call static_abs8
    load a, static_x_32+3
    assert a, #0x42

    ; abs(0xEF) = 0x11
    store #0xEF, static_x_32+3
    call static_abs8
    load a, static_x_32+3
    assert a, #0x11

    ; abs(0xFF) = 0x01
    store #0xFF, static_x_32+3
    call static_abs8
    load a, static_x_32+3
    assert a, #0x01

    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"
#include "../src/lib/static_math.asm"

; global vars
#bank ram
sum: #res 2 ; result
STACK_BASE: #res 0