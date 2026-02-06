; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    push #"\0"
    call atoi_hex_nibble
    pop a
    assert b, #0xFF
    
    push #"a"
    call atoi_hex_nibble
    pop a
    assert b, #0xFF

    push #"/"
    call atoi_hex_nibble
    pop a
    assert b, #0xFF

    push #"0"
    call atoi_hex_nibble
    pop a
    assert b, #0

    push #"1"
    call atoi_hex_nibble
    pop a
    assert b, #1

    push #"2"
    call atoi_hex_nibble
    pop a
    assert b, #2

    push #"3"
    call atoi_hex_nibble
    pop a
    assert b, #3

    push #"4"
    call atoi_hex_nibble
    pop a
    assert b, #4

    push #"5"
    call atoi_hex_nibble
    pop a
    assert b, #5

    push #"6"
    call atoi_hex_nibble
    pop a
    assert b, #6

    push #"7"
    call atoi_hex_nibble
    pop a
    assert b, #7

    push #"8"
    call atoi_hex_nibble
    pop a
    assert b, #8

    push #"9"
    call atoi_hex_nibble
    pop a
    assert b, #9

    push #":"
    call atoi_hex_nibble
    pop a
    assert b, #0xFF
    
    push #"A"
    call atoi_hex_nibble
    pop a
    assert b, #0xA
    
    push #"B"
    call atoi_hex_nibble
    pop a
    assert b, #0xB
    
    push #"C"
    call atoi_hex_nibble
    pop a
    assert b, #0xC
    
    push #"D"
    call atoi_hex_nibble
    pop a
    assert b, #0xD
    
    push #"E"
    call atoi_hex_nibble
    pop a
    assert b, #0xE
    
    push #"F"
    call atoi_hex_nibble
    pop a
    assert b, #0xF
    
    push #"@"
    call atoi_hex_nibble
    pop a
    assert b, #0xFF
    
    push #"G"
    call atoi_hex_nibble
    pop a
    assert b, #0xFF
    halt

; includes
#include "../src/CPU.asm"
#include "../src/lib/char_utils.asm"

; global vars
#bank ram
STACK_BASE: #res 0