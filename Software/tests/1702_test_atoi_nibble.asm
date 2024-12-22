; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    ; 0 -> '0'
    push #0x00
    call itoa_hex_nibble
    dealloc 1
    assert b, #"0"
    ; 1 -> '1'
    push #0x01
    call itoa_hex_nibble
    dealloc 1
    assert b, #"1"
    ; 2 -> '2'
    push #0x02
    call itoa_hex_nibble
    dealloc 1
    assert b, #"2"
    ; 3 -> '3'
    push #0x03
    call itoa_hex_nibble
    dealloc 1
    assert b, #"3"
    ; 4 -> '4'
    push #0x04 
    call itoa_hex_nibble
    dealloc 1
    assert b, #"4"
    ; 5 -> '5'
    push #0x05 
    call itoa_hex_nibble
    dealloc 1
    assert b, #"5"
    ; 6 -> '6'
    push #0x06 
    call itoa_hex_nibble
    dealloc 1
    assert b, #"6"
    ; 7 -> '7'
    push #0x07 
    call itoa_hex_nibble
    dealloc 1
    assert b, #"7"
    ; 8 -> '8'
    push #0x08
    call itoa_hex_nibble
    dealloc 1
    assert b, #"8"
    ; 9 -> '9'
    push #0x09
    call itoa_hex_nibble
    dealloc 1
    assert b, #"9"
    ; A -> 'A'
    push #0x0A
    call itoa_hex_nibble
    dealloc 1
    assert b, #"A"
    ; B -> 'B'
    push #0x0B
    call itoa_hex_nibble
    dealloc 1
    assert b, #"B"
    ; C -> 'C'
    push #0x0C
    call itoa_hex_nibble
    dealloc 1
    assert b, #"C"
    ; D -> 'D'
    push #0x0D
    call itoa_hex_nibble
    dealloc 1
    assert b, #"D"
    ; E -> 'E'
    push #0x0E
    call itoa_hex_nibble
    dealloc 1
    assert b, #"E"
    ; F -> 'F'
    push #0x0F
    call itoa_hex_nibble
    dealloc 1
    assert b, #"F"

    ; off nominal
    ; 0x10 -> '0'
    push #0x10
    call itoa_hex_nibble
    dealloc 1
    assert b, #"0"
    ; 0x19 -> '9'
    push #0x19
    call itoa_hex_nibble
    dealloc 1
    assert b, #"9"
    ; 0x1A -> 'A'
    push #0x1A
    call itoa_hex_nibble
    dealloc 1
    assert b, #"A"
    ; 0xFF -> 'F'
    push #0xFF
    call itoa_hex_nibble
    dealloc 1
    assert b, #"F"

    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"
#include "../src/lib/char_utils.asm"

; global vars
#bank ram
STACK_BASE: #res 0