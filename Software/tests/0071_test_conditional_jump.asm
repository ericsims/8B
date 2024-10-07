;;
; @file
; @author Eric Sims
;
; @section Description
; tests conditional jumps
; tests jmz, jmc, jnz. does not test jnc, jmn, jnn
;
; @section Test Coverage
; @coverage jmz jmc jnz
;
;;

#include "../src/CPU.asm"

#bank rom

; ** jmz tests ***
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
assert a, #0xCC


; ** JMC tests ***
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
assert a, #0xDD


; ** JNZ tests ***
; fifth test case
test5:
load a, #0x00
assert a, #0x00
add a, #0x00

; jump if not zero. should evaluate to false
jnz .b

; assert a reg is still correct
assert a, #0x00

; go to next test case
jmp test6

; if we jump here, we should error out
.b:
load a, #0x00
assert a, #0x05;


; sixth test case
test6:
load a, #0x01
assert a, #0x01
add a, #0x00

; jump if not zero. should evaluate to true
jnz .b

; we should error out if we end up here
assert a, #0x06
halt

; jump here is correct
.b:
load a, #0x06
assert a, #0x06

halt