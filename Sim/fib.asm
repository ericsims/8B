#include "CPU.asm"

LAST_RES_PTR = 0x8000

sti, 0x01, LAST_RES_PTR
lai, 0x00
top:
    ldb, LAST_RES_PTR
    sta, UART
    sta, LAST_RES_PTR
    add
    lba
    jnc, top
    hlt

