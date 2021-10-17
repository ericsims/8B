#include "CPU.asm"

sti, 0x01, 0x8000
lai, 0x00
top:
    ldb, 0x8000
    sta, 0xD008
    sta, 0x8000
    add
    lba
    jnc, top
    cal, print
    hlt
nop
nop
nop
nop
sti, 0xBC, 0xD008
hlt
print:
    sti, 0xAB, 0xD008
    ret
sti, 0xDE, 0xD008