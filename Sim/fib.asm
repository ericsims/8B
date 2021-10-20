#include "CPU.asm"

#bank rom

sti 0x01, LAST_RES_PTR
lai 0x00
top:
    ldb LAST_RES_PTR
    sta UART
    sta LAST_RES_PTR
    add
    lba
    jnc top
    hlt

#bank ram
LAST_RES_PTR:
    #res 1
