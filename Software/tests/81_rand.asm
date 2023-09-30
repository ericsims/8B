#include "../src/CPU.asm"

#bank rom
top:
init_pointers:
loadw sp, #0xBFFF
storew #0x0000, BP

; n=0
store #0x01, static_rand_lfsr8_x ; init lfsr prng
load a, static_rand_lfsr8_x
assert a, #0x01

; n=1
call static_rand_lfsr8
load a, static_rand_lfsr8_x
assert a, #0xAD

; n=2
call static_rand_lfsr8
load a, static_rand_lfsr8_x
assert a, #0x4C

; n=3
call static_rand_lfsr8
load a, static_rand_lfsr8_x
assert a, #0x3E



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


#include "../src/lib/rand.asm"