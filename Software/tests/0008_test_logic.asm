;;
; @file
; @author Eric Sims
;
; @section Description
; tests 8 bit logic functions
; TODO: does NOT check flags
;
; @section Test Coverage
; @coverage and_a_b or_a_b xor_a_b lshift_a rshift_a lshift_b rshift_b and_a_imm or_a_imm xor_a_imm and_b_imm or_b_imm xor_b_imm
;
;;

#include "../src/CPU.asm"

#bank rom

; AND tests
; 0x00 & 0x00 = 0x00
load a, #0x00
load b, #0x00
and a, b
assert a, #0x00
assert zf, #1
assert nf, #0


; 0x00 & 0xFF = 0x00
load a, #0x00
load b, #0xFF
and a, b
assert a, #0x00    
assert zf, #1
assert nf, #0

; 0xFF & 0xFF = 0xFF
load a, #0xFF
load b, #0xFF
and a, b
assert a, #0xFF
assert zf, #0
assert nf, #1

; 0x12 & 0x34 = 0x10
load a, #0x12
load b, #0x34
and a, b
assert a, #0x10
assert zf, #0
assert nf, #0

load a, #0x55
and a, #0xAA
assert a, #0x00
assert zf, #1
assert nf, #0

load b, #0x55
and b, #0xAA
assert b, #0x00
assert zf, #1
assert nf, #0

; OR tests
; 0x00 | 0x00 = 0x00
load a, #0x00
load b, #0x00
or a, b
assert a, #0x00
assert zf, #1
assert nf, #0

; 0x00 | 0xFF = 0xFF
load a, #0x00
load b, #0xFF
or a, b
assert a, #0xFF
assert zf, #0
assert nf, #1

; 0xFF | 0xFF = 0xFF
load a, #0xFF
load b, #0xFF
or a, b
assert a, #0xFF
assert zf, #0
assert nf, #1

; 0x12 | 0x34 = 0x53
load a, #0x12
load b, #0x34
or a, b
assert a, #0x36
assert zf, #0
assert nf, #0

load a, #0x55
or a, #0xAA
assert a, #0xFF
assert zf, #0
assert nf, #1

load b, #0x55
or b, #0xAA
assert b, #0xFF
assert zf, #0
assert nf, #1

; XOR tests
; 0x00 ^ 0x00 = 0x00
load a, #0x00
load b, #0x00
xor a, b
assert a, #0x00
assert zf, #1
assert nf, #0

; 0x00 ^ 0xFF = 0xFF
load a, #0x00
load b, #0xFF
xor a, b
assert a, #0xFF
assert zf, #0
assert nf, #1

; 0xFF ^ 0xFF = 0x00
load a, #0xFF
load b, #0xFF
xor a, b
assert a, #0x00
assert zf, #1
assert nf, #0

; 0x12 | 0x34 = 0x26
load a, #0x12
load b, #0x34
xor a, b
assert a, #0x26
assert zf, #0
assert nf, #0

load a, #0x55
xor a, #0xFF
assert a, #0xAA
assert zf, #0
assert nf, #1

load b, #0x55
xor b, #0xFF
assert b, #0xAA
assert zf, #0
assert nf, #1

; left sfhit tests
; 0x00 << 1 = 0x00
load a, #0x00
lshift a
assert a, #0x00
assert zf, #1
assert nf, #0
assert cf, #0

; 0x02 << 1 = 0x04
load a, #0x02
lshift a
assert a, #0x04
assert zf, #0
assert nf, #0
assert cf, #0

; 0xFF << 1 = 0xFE
load a, #0xFF
lshift a
assert a, #0xFE
assert zf, #0
assert nf, #1
assert cf, #1

; 0x12 << 1 = 0x24
load a, #0x12
lshift a
assert a, #0x24
assert zf, #0
assert nf, #0
assert cf, #0

; 0x00 << 1 = 0x00
load b, #0x00
lshift b
assert b, #0x00
assert zf, #1
assert nf, #0
assert cf, #0

; 0x02 << 1 = 0x04
load b, #0x02
lshift b
assert b, #0x04
assert zf, #0
assert nf, #0
assert cf, #0

; 0xFF << 1 = 0xFE
load b, #0xFF
lshift b
assert b, #0xFE
assert zf, #0
assert nf, #1
assert cf, #1

; 0x12 << 1 = 0x24
load b, #0x12
lshift b
assert b, #0x24
assert zf, #0
assert nf, #0
assert cf, #0

; right shift tests
; 0x00 >> 1 = 0x00
load a, #0x00
rshift a
assert a, #0x00
assert zf, #1
assert nf, #0
assert cf, #0

; 0x02 >> 1 = 0x01
load a, #0x02
rshift a
assert a, #0x01
assert zf, #0
assert nf, #0
assert cf, #0

; 0xFF >> 1 = 0x7F
load a, #0xFF
rshift a
assert a, #0x7F
assert zf, #0
assert nf, #0
assert cf, #1

; 0x12 >> 1 = 0x09
load a, #0x12
rshift a
assert a, #0x09
assert zf, #0
assert nf, #0
assert cf, #0

; 0x00 >> 1 = 0x00
load b, #0x00
rshift b
assert b, #0x00
assert zf, #1
assert nf, #0
assert cf, #0

; 0x02 >> 1 = 0x01
load b, #0x02
rshift b
assert b, #0x01
assert zf, #0
assert nf, #0
assert cf, #0

; 0xFF >> 1 = 0x7F
load b, #0xFF
rshift b
assert b, #0x7F
assert zf, #0
assert nf, #0
assert cf, #1

; 0x12 >> 1 = 0x09
load b, #0x12
rshift b
assert b, #0x09
assert zf, #0
assert nf, #0
assert cf, #0


halt