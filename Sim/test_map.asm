#include "CPU.asm"

#bank rom
start:
store 31, set_map_bit.coll
store 0x00, set_map_bit.roww

store 0x03, set_map_bit.value


#bank rom
clear_map:
store map_start, set_map_bit.pixel_ptr
.loop:




#bank rom
set_map_bit:
load a, (.roww) ; load row number
rlc
rlc
rlc
rlc
rlc
rlc
lba

load a, (.coll) ; load col number
rrc
rrc ; divide by 4

oor

store a, .pixel_ptr+1 ; save off the LSB of the pixel pointer

load a, (.roww) ; load row, and divide by 4. keep only lower 4 bits
rrc
rrc
load b, 0x0F
and

load b, map_start[15:8]
add
store a, .pixel_ptr ; save MSB of pointer

move [.pixel_ptr], .value ; copy value in to the location of memory reference by .pixel_ptr


hlt

#bank ram
.roww:
    #res 1
.coll:
    #res 1
.value:
    #res 1
.pixel_ptr:
    #res 2



#bankdef map
{
    #addr 0xA000
    #size 0x1000
}

#bank map 
    map_start:
        #res 0x1000




#include "math.asm"

#bank rom
#d8 0x00 ; end