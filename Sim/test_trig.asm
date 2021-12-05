#include "CPU.asm"
#include "math.asm"


#bank rom
#align 0x800
#d inchexstr("lut/sin_lut.dat")


#bank rom
#d8 0x00 ; end