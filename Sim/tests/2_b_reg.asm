#include "../CPU.asm"

#bank rom

lai 0x00
lbi 0x00
add
tta 0x00 ; check that a reg is correct

lai 0x00
lbi 0x01
add
tta 0x01 ; check that a reg is correct

lai 0x00
lbi 0xAA
add
tta 0xAA ; check that a reg is correct

lai 0x00
lbi 0x55
add
tta 0x55 ; check that a reg is correct

lai 0x00
lbi 0xFF
add
tta 0xFF ; check that a reg is correct

lai 0x00
lbi 0x00
add
tta 0x00 ; check that a reg is correct

hlt