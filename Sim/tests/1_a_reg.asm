#include "../CPU.asm"

#bank rom

lai 0x00
tta 0x00 ; check that a reg is correct

lai 0x01
tta 0x01 ; check that a reg is correct

lai 0xAA
tta 0xAA ; check that a reg is correct

lai 0x55
tta 0x55 ; check that a reg is correct

lai 0xFF
tta 0xFF ; check that a reg is correct

lai 0x00
tta 0x00 ; check that a reg is correct

hlt