#include "../src/CPU.asm"

#bank rom

top:
init_pointers:
loadw sp, #DEFAULT_STACK
storew #0x0000, BP

test_ln:
; ln(0x0000) = 0x00. this is actually undef, but ln will return whatever we init the placeholder to
push #0x00 ; result placeholder
pushw #0x0000
call ln
popw hl
pop a
assert a, #0x00

; ln(0x0001) = 0x00
push #0x00 ; result placeholder
pushw #0x0001
call ln
popw hl
pop a
assert a, #0x00

; ln(0x0003) = 0x01
push #0x00 ; result placeholder
pushw #0x0003
call ln
popw hl
pop a
assert a, #0x01

; ln(0x0008) = 0x02
push #0x00 ; result placeholder
pushw #0x0008
call ln
popw hl
pop a
assert a, #0x02

; ln(0x0101) = 0x05
push #0x00 ; result placeholder
pushw #0x0101
call ln
popw hl
pop a
assert a, #0x05

; ln(0xDEAD) = 0x0A
push #0x00 ; result placeholder
pushw #0xDEAD
call ln
popw hl
pop a
assert a, #0x0A

; ln(0xBEEF) = 0x0A
push #0x00 ; result placeholder
pushw #0xBEEF
call ln
popw hl
pop a
assert a, #0x0A

; ln(0xFFFF) = 0x0B
push #0x00 ; result placeholder
pushw #0xFFFF
call ln
popw hl
pop a
assert a, #0x0B

done:
halt

#include "../src/lib/math_ln.asm"
#include "../src/lib/static_math.asm"

halt ; extra dummy byte to see program size