;;
; @file
; @author Eric Sims
;
; @section Description
; tests offset address
;
; @section Test Coverage
; @coverage load_a_indir_poffset load_a_indir_noffset load_b_indir_poffset load_b_indir_noffset
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

load b, (BP), 0
assert b, #0xCD
load b, (BP), 1
assert b, #0xEF
load b, (BP), -1
assert b, #0xAB


halt