; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:

    .test1:
        ; copy string to ram
        pushw #str
        pushw #test_str1
        call strcpy
        dealloc 4
        ; get token
        push #" "
        pushw #str
        pushw #0
        call strtok
        dealloc 6
        assert b, #-1
    
    .test2:
        ; copy string to ram
        pushw #str
        pushw #test_str2
        call strcpy
        dealloc 4

        push #" "
        pushw #str
        pushw #0
        ..get_token_a:
            call strtok
            assert b, #1
            
        ..check_token_a:
            pushw #test_str2.a
            call strcmp
            dealloc 4
            assert b, #0

        ..get_token_b:
            pushw #0
            call strtok
            assert b, #1
        ..check_token_b:
            pushw #test_str2.b
            call strcmp
            dealloc 4
            assert b, #0

        ..get_token_c:
            pushw #0
            call strtok
            assert b, #1
        ..check_token_c:
            pushw #test_str2.c
            call strcmp
            dealloc 4
            assert b, #0

        ..get_token_d:
            pushw #0
            call strtok
            assert b, #0
        ..check_token_d:
            pushw #test_str2.d
            call strcmp
            dealloc 4
            assert b, #0

        ..cleanup:
            dealloc 3


    halt

; constants
    test_str1: #d "\0"
    test_str2: #d "this is some words\0"
        .a: #d "this\0"
        .b: #d "is\0"
        .c: #d "some\0"
        .d: #d "words\0"

; includes
#include "../src/CPU.asm"
#include "../src/lib/char_utils.asm"

; global vars
#bank ram
str: #res 256
STACK_BASE: #res 0