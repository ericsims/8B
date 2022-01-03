#include "../CPU.asm"

#bank rom

store #0x12, location1
storew #location1, pointer1
load a, (pointer1)
load b, (pointer1)
assert a, #0x12
assert b, #0x12

load a, #0x23
store a, (pointer1)
halt

#bank ram
location1:
    #res 1
pointer1:
    #res 2
