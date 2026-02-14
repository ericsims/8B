; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    ; tests macros
    ; special status reg
    __load a, RA8876, RA8876_STSR
    assert a, #0x50 ; default status reg
    
    __load b, RA8876, RA8876_STSR
    assert b, #0x50 ; default status reg

    ; read reg 0x00
    __load a, RA8876, RA8876_SRR
    assert a, #0xD6 ; default SRR reg value

    __load b, RA8876, RA8876_SRR
    assert b, #0xD6 ; default SRR reg value

    ; read reg 0x01
    __load a, RA8876, RA8876_CCR
    assert a, #0x88 ; default CCR reg value

    __load b, RA8876, RA8876_CCR
    assert b, #0x88 ; default CCR reg value

    ; imm write reg 0x03
    __store #0x80, RA8876, RA8876_ICR
    __load a, RA8876, RA8876_ICR
    assert a, #0x80
    __store #0x00, RA8876, RA8876_ICR
    __load a, RA8876, RA8876_ICR
    assert a, #0x00

    __store #0x80, RA8876, RA8876_ICR
    __load b, RA8876, RA8876_ICR
    assert b, #0x80
    __store #0x00, RA8876, RA8876_ICR
    __load b, RA8876, RA8876_ICR
    assert b, #0x00

    ; reg write reg 0x03
    load a, #0x80
    __store a, RA8876, RA8876_ICR
    __load b, RA8876, RA8876_ICR
    assert b, #0x80
    load a, #0x00
    __store a, RA8876, RA8876_ICR
    __load b, RA8876, RA8876_ICR
    assert b, #0x00

    load b, #0x80
    __store b, RA8876, RA8876_ICR
    __load a, RA8876, RA8876_ICR
    assert a, #0x80
    load b, #0x00
    __store b, RA8876, RA8876_ICR
    __load a, RA8876, RA8876_ICR
    assert a, #0x00

    halt

; includes
#include "../src/CPU.asm"
#include "../src/lib/lib_ra8876.asm"

; global vars
#bank ram
STACK_BASE: #res 1024