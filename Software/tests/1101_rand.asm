; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

test:
    ; n=0
    store #0x01, rand_a ; init lfsr prng

    pushw #rand_a

    ; n=1
    call rand_lfsr8
    assert b, #0xAD

    ; n=2
    call rand_lfsr8
    assert b, #0x4C

    ; n=3
    call rand_lfsr8
    assert b, #0x3E

    ; n=4
    call rand_lfsr8
    assert b, #0xC7

    ; n=5
    call rand_lfsr8
    assert b, #0x6D

    ; n=5
    call rand_lfsr8
    assert b, #0xBA

    dalloc 2

    halt

; simulated sequnece from libdev/xorshift.py
; 0 0x01
; 1 0xAD 
; 2 0x4C 
; 3 0x3E 
; 4 0xC7 
; 5 0x6D 
; 6 0xBA 
; ...

; constants
; -- none --

; includes
#include "../src/CPU.asm"
#include "../src/lib/rand.asm"

; global vars
#bank ram
rand_a: #res 1
STACK_BASE: #res 0