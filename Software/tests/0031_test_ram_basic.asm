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

; simple test of top and bottom addresses
test_addr1 = RAM
test_addr2 = RAM+RAM_SIZE-1

; check frist address of ram
load a, #0x00
store a, test_addr1
load a, test_addr1
assert a, #0x00 ; check that the write/read was sucessful

load a, #0xAA
store a, test_addr1
load a, test_addr1
assert a, #0xAA ; check that the write/read was sucessful

load a, #0x55
store a, test_addr1
load a, test_addr1
assert a, #0x55 ; check that the write/read was sucessful

load a, #0xFF
store a, test_addr1
load a, test_addr1
assert a, #0xFF ; check that the write/read was sucessful

load a, #0x00
store a, test_addr1
load a, test_addr1
assert a, #0x00 ; check that the write/read was sucessful

; check near end of ram
load a, #0x00
store a, test_addr2
load a, test_addr2
assert a, #0x00 ; check that the write/read was sucessful

load a, #0xAA
store a, test_addr2
load a, test_addr2
assert a, #0xAA ; check that the write/read was sucessful

load a, #0x55
store a, test_addr2
load a, test_addr2
assert a, #0x55 ; check that the write/read was sucessful

load a, #0xFF
store a, test_addr2
load a, test_addr2
assert a, #0xFF ; check that the write/read was sucessful

load a, #0x00
store a, test_addr2
load a, test_addr2
assert a, #0x00 ; check that the write/read was sucessful

halt