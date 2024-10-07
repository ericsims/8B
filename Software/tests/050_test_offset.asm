;;
; @file
; @author Eric Sims
;
; @section Description
; tests offset address
;
; @section Test Coverage
; @coverage load_a_indir_offset
;
;;

#include "../src/CPU.asm"

#bank ram
#res 0x100
x0:
#res 1
x1:
#res 1
x2:
#res 1

#bank rom

top:

halt

store #0xAB, x0
store #0xCD, x1
store #0xEF, x2
storew #x1, BP

load a, (BP), 0
assert a, #0xCD
load a, (BP), 1
assert a, #0xEF
load a, (BP), -1
assert a, #0xAB


halt