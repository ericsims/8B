#include "../src/CPU.asm"


#bank ram
result:
    #res 4
#bank rom

top:
init_pointers:
loadw sp, #STACK_BASE
storew #0x0000, BP



; __push32 #0x0000_0000 ; allocate result placeholder
; __push_pointer_sp -4 ; push pointer to address of result

pushw #result
__push32 #0x1234_5678 ; x
__push32 #0xFFAD_BEEF ; y



call add32

; disacard params
pop a
pop a
pop a
pop a

pop a
pop a
pop a
pop a

pop a
pop a

; check result is 0x11E2_1567
load a, result
assert a, #0x11
load a, result+1
assert a, #0xE2
load a, result+2
assert a, #0x15
load a, result+3
assert a, #0x67

assert b, #0x01

halt


#include "../src/lib/math.asm"


#bank ram
STACK_BASE:
    #res 0