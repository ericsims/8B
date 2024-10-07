#include "../src/CPU.asm"

top:
init_pointers:
loadw sp, #DEFAULT_STACK
storew #0x0000, BP

main:
; 0 -> '0'
push #0x00
call itoa_hex_nibble
pop a
assert a, #"0"
; 1 -> '1'
push #0x01
call itoa_hex_nibble
pop a
assert a, #"1"
; 2 -> '2'
push #0x02
call itoa_hex_nibble
pop a
assert a, #"2"
; 3 -> '3'
push #0x03
call itoa_hex_nibble
pop a
assert a, #"3"
; 4 -> '4'
push #0x04 
call itoa_hex_nibble
pop a
assert a, #"4"
; 5 -> '5'
push #0x05 
call itoa_hex_nibble
pop a
assert a, #"5"
; 6 -> '6'
push #0x06 
call itoa_hex_nibble
pop a
assert a, #"6"
; 7 -> '7'
push #0x07 
call itoa_hex_nibble
pop a
assert a, #"7"
; 8 -> '8'
push #0x08
call itoa_hex_nibble
pop a
assert a, #"8"
; 9 -> '9'
push #0x09
call itoa_hex_nibble
pop a
assert a, #"9"
; A -> 'A'
push #0x0A
call itoa_hex_nibble
pop a
assert a, #"A"
; B -> 'B'
push #0x0B
call itoa_hex_nibble
pop a
assert a, #"B"
; C -> 'C'
push #0x0C
call itoa_hex_nibble
pop a
assert a, #"C"
; D -> 'D'
push #0x0D
call itoa_hex_nibble
pop a
assert a, #"D"
; E -> 'E'
push #0x0E
call itoa_hex_nibble
pop a
assert a, #"E"
; F -> 'F'
push #0x0F
call itoa_hex_nibble
pop a
assert a, #"F"

; off nominal
; 0x10 -> '0'
push #0x10
call itoa_hex_nibble
pop a
assert a, #"0"
; 0x19 -> '9'
push #0x19
call itoa_hex_nibble
pop a
assert a, #"9"
; 0x1A -> 'A'
push #0x1A
call itoa_hex_nibble
pop a
assert a, #"A"
; 0xFF -> 'F'
push #0xFF
call itoa_hex_nibble
pop a
assert a, #"F"


halt



#include "../src/lib/char_utils.asm"