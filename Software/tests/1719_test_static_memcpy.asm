; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:

    storew #test_src, static_memcpy.src_ptr
    storew #test_dst, static_memcpy.dst_ptr
    storew #(test_src.end - test_src), static_memcpy.len
    call static_memcpy

    ; check result
    pushw #test_src
    pushw #test_dst
    call strcmp
    dealloc 4
    assert b, #0

    halt

; constants
test_src: #d "this is some test data made up of characters the total length is pretty long, but it is less than the 255 character limit for the xftr 8 instruction\0"
    .end:

; includes
#include "../src/CPU.asm"
#include "../src/lib/char_utils.asm"

; global vars
#bank ram
test_dst: #res 256
STACK_BASE: #res 0