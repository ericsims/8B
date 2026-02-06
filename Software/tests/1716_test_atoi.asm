; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:

    jmp test1
    test1_str: #d "\0"
    test1:
    pushw #test1_str
    pushw #res_ptr
    call atoi_hex
    dealloc 4
    assert b, #0
    
    
    jmp test2
    test2_str: #d "0\0"
    test2:
    pushw #test2_str
    pushw #res_ptr
    call atoi_hex
    dealloc 4
    assert b, #4
    load a, res_ptr+3
    assert a, #0
    
    jmp test3
    test3_str: #d "1\0"
    test3:
    pushw #test3_str
    pushw #res_ptr
    call atoi_hex
    dealloc 4
    assert b, #4
    load a, res_ptr+3
    assert a, #1

    jmp test4
    test4_str: #d "9\0"
    test4:
    pushw #test4_str
    pushw #res_ptr
    call atoi_hex
    dealloc 4
    assert b, #4
    load a, res_ptr+3
    assert a, #0x9

    jmp test5
    test5_str: #d "A\0"
    test5:
    pushw #test5_str
    pushw #res_ptr
    call atoi_hex
    dealloc 4
    assert b, #4
    load a, res_ptr+3
    assert a, #0xA

    jmp test6
    test6_str: #d "F\0"
    test6:
    pushw #test6_str
    pushw #res_ptr
    call atoi_hex
    dealloc 4
    assert b, #4
    load a, res_ptr+3
    assert a, #0xF

    jmp test7
    test7_str: #d "00\0"
    test7:
    pushw #test7_str
    pushw #res_ptr
    call atoi_hex
    dealloc 4
    assert b, #8
    load a, res_ptr+3
    assert a, #0x00
    
    jmp test8
    test8_str: #d "12\0"
    test8:
    pushw #test8_str
    pushw #res_ptr
    call atoi_hex
    dealloc 4
    assert b, #8
    load a, res_ptr+3
    assert a, #0x12

    jmp test9
    test9_str: #d "ABC\0"
    test9:
    pushw #test9_str
    pushw #res_ptr
    call atoi_hex
    dealloc 4
    assert b, #12
    load a, res_ptr+2
    assert a, #0x0A
    load a, res_ptr+3
    assert a, #0xBC

    jmp test10
    test10_str: #d "ABCD\0"
    test10:
    pushw #test10_str
    pushw #res_ptr
    call atoi_hex
    dealloc 4
    assert b, #16
    load a, res_ptr+2
    assert a, #0xAB
    load a, res_ptr+3
    assert a, #0xCD
    
    jmp test11
    test11_str: #d "ABCDE\0"
    test11:
    pushw #test11_str
    pushw #res_ptr
    call atoi_hex
    dealloc 4
    assert b, #20
    load a, res_ptr+1
    assert a, #0x0A
    load a, res_ptr+2
    assert a, #0xBC
    load a, res_ptr+3
    assert a, #0xDE
    
    jmp test12
    test12_str: #d "ABCDEF\0"
    test12:
    pushw #test12_str
    pushw #res_ptr
    call atoi_hex
    dealloc 4
    assert b, #24
    load a, res_ptr+1
    assert a, #0xAB
    load a, res_ptr+2
    assert a, #0xCD
    load a, res_ptr+3
    assert a, #0xEF

    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"
#include "../src/lib/char_utils.asm"

; global vars
#bank ram
res_ptr: #res 4
STACK_BASE: #res 0