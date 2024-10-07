;;
; @file
; @author Eric Sims
;
; @section Description
; reads and writes from various ram addresses
;
;;

#include "../src/CPU.asm"

#bank rom

; check frist address of ram
load a, #0x00
store a, 0x8000
load a, 0x8000
assert a, #0x00 ; check that the write/read was sucessful

load a, #0xAA
store a, 0x8000
load a, 0x8000
assert a, #0xAA ; check that the write/read was sucessful

load a, #0x55
store a, 0x8000
load a, 0x8000
assert a, #0x55 ; check that the write/read was sucessful

load a, #0xFF
store a, 0x8000
load a, 0x8000
assert a, #0xFF ; check that the write/read was sucessful

load a, #0x00
store a, 0x8000
load a, 0x8000
assert a, #0x00 ; check that the write/read was sucessful

; check near end of ram
load a, #0x00
store a, 0xBFF1
load a, 0xBFF1
assert a, #0x00 ; check that the write/read was sucessful

load a, #0xAA
store a, 0xBFF1
load a, 0xBFF1
assert a, #0xAA ; check that the write/read was sucessful

load a, #0x55
store a, 0xBFF1
load a, 0xBFF1
assert a, #0x55 ; check that the write/read was sucessful

load a, #0xFF
store a, 0xBFF1
load a, 0xBFF1
assert a, #0xFF ; check that the write/read was sucessful

load a, #0x00
store a, 0xBFF1
load a, 0xBFF1
assert a, #0x00 ; check that the write/read was sucessful

halt