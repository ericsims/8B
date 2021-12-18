#include "../CPU.asm"

#bank rom

; tests jmz, jmc. does not test jnz, jnc, jmn, jnn


; first test case
test1:
load a, #0xAA
assert a, #0xAA
add a, #0x00

; jump if zero. should evaluate to false
jmz .b

; assert a reg is still correct
assert a, #0xAA

; go to next test case
jmp test2

; if we jump here, we should error out
.b:
load a, #0x00
assert a, #0xBB;


; second test case
test2:
load a, #0x00
assert a, #0x00
add a, #0x00

; jump if zero. should evaluate to true
jmz .b

; we should error out if we end up here
assert a, #0xFF
halt

; jump here is correct
.b:
load a, #0xCC
assert a, #0xCC;



; third test case
test3:
load a, #0xAA
assert a, #0xAA
add a, #0x00

; jump if carry. should evaluate to false
jmc .b

; assert a reg is still correct
assert a, #0xAA

; go to next test case
jmp test4

; if we jump here, we should error out
.b:
load a, #0x00
assert a, #0xBB;


; fourth test case
test4:
load a, #0xFF
assert a, #0xFF
add a, #0x01

; jump if carry. should evaluate to true
jmc .b

; we should error out if we end up here
assert a, #0x12
halt

; jump here is correct
.b:
load a, #0xDD
assert a, #0xDD;

halt