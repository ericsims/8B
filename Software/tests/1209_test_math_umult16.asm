; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

test:
    ; alloc 4 ; res
    ; pushw #0 ; x
    ; pushw #0 ; y
    ; call umult16
    ; dealloc 4 ; x,y
    ; popw hl
    ; assert hl, #0x0000
    ; popw hl
    ; assert hl, #0x0000
    
    ; alloc 4 ; res
    ; pushw #0xDEAD ; x
    ; pushw #0xBEEF ; y
    ; call umult16
    ; dealloc 4 ; x,y
    ; popw hl
    ; assert hl, #(0xDEAD*0xBEEF)&0xFFFF
    ; popw hl
    ; assert hl, #(0xDEAD*0xBEEF)>>16
    

    ; alloc 4
    ; pushw #0xFFFF
    ; pushw #0xFFFF
    ; call umult16
    ; dealloc 4
    ; popw hl
    ; assert hl, #(0xFFFF*0xFFFF)&0xFFFF
    ; popw hl
    ; assert hl, #(0xFFFF*0xFFFF)>>16

    ; alloc 4
    ; pushw #0xFFFE
    ; pushw #0xFFFF
    ; call umult16
    ; dealloc 4
    ; popw hl
    ; assert hl, #(0xFFFE*0xFFFF)&0xFFFF
    ; popw hl
    ; assert hl, #(0xFFFE*0xFFFF)>>16

    ; alloc 4
    ; pushw #0x8000
    ; pushw #0x8000
    ; call umult16
    ; dealloc 4
    ; popw hl
    ; assert hl, #(0x8000*0x8000)&0xFFFF
    ; popw hl
    ; assert hl, #(0x8000*0x8000)>>16

    ; alloc 4
    ; pushw #0x8000
    ; pushw #0xFFFF
    ; call umult16
    ; dealloc 4
    ; popw hl
    ; assert hl, #(0x8000*0xFFFF)&0xFFFF
    ; popw hl
    ; assert hl, #(0x8000*0xFFFF)>>16

    ; alloc 4
    ; pushw #0x7FFF
    ; pushw #0xFFFF
    ; call umult16
    ; dealloc 4
    ; popw hl
    ; assert hl, #(0x7FFF*0xFFFF)&0xFFFF
    ; popw hl
    ; assert hl, #(0x7FFF*0xFFFF)>>16

    alloc 4
    pushw #0xF000
    pushw #0xF000
    call umult16
    dealloc 4
    popw hl
    assert hl, #(0xF000*0xF000)&0xFFFF
    popw hl
    assert hl, #(0xF000*0xF000)>>16

    halt

    alloc 4
    pushw #0x00FF
    pushw #0xFFFF
    call umult16
    dealloc 4
    popw hl
    assert hl, #(0x00FF*0xFFFF)&0xFFFF
    popw hl
    assert hl, #(0x00FF*0xFFFF)>>16

    alloc 4
    pushw #0x0F0F
    pushw #0xF0F0
    call umult16
    dealloc 4
    popw hl
    assert hl, #(0x0F0F*0xF0F0)&0xFFFF
    popw hl
    assert hl, #(0x0F0F*0xF0F0)>>16

    alloc 4
    pushw #0xAAAA
    pushw #0x5555
    call umult16
    dealloc 4
    popw hl
    assert hl, #(0xAAAA*0x5555)&0xFFFF
    popw hl
    assert hl, #(0xAAAA*0x5555)>>16

    alloc 4
    pushw #0xCCCC
    pushw #0xDDDD
    call umult16
    dealloc 4
    popw hl
    assert hl, #(0xCCCC*0xDDDD)&0xFFFF
    popw hl
    assert hl, #(0xCCCC*0xDDDD)>>16

    alloc 4
    pushw #0x1234
    pushw #0xFEDC
    call umult16
    dealloc 4
    popw hl
    assert hl, #(0x1234*0xFEDC)&0xFFFF
    popw hl
    assert hl, #(0x1234*0xFEDC)>>16

    alloc 4
    pushw #0x8001
    pushw #0x8001
    call umult16
    dealloc 4
    popw hl
    assert hl, #(0x8001*0x8001)&0xFFFF
    popw hl
    assert hl, #(0x8001*0x8001)>>16

    alloc 4
    pushw #0xFFFF
    pushw #0x0001
    call umult16
    dealloc 4
    popw hl
    assert hl, #(0xFFFF*0x0001)&0xFFFF
    popw hl
    assert hl, #(0xFFFF*0x0001)>>16

    alloc 4
    pushw #0x0002
    pushw #0xFFFF
    call umult16
    dealloc 4
    popw hl
    assert hl, #(0x0002*0xFFFF)&0xFFFF
    popw hl
    assert hl, #(0x0002*0xFFFF)>>16

    alloc 4
    pushw #0x7FFF
    pushw #0x7FFF
    call umult16
    dealloc 4
    popw hl
    assert hl, #(0x7FFF*0x7FFF)&0xFFFF
    popw hl
    assert hl, #(0x7FFF*0x7FFF)>>16

    alloc 4
    pushw #0xF123
    pushw #0x0FED
    call umult16
    dealloc 4
    popw hl
    assert hl, #(0xF123*0x0FED)&0xFFFF
    popw hl
    assert hl, #(0xF123*0x0FED)>>16

    alloc 4
    pushw #0xE000
    pushw #0x9000
    call umult16
    dealloc 4
    popw hl
    assert hl, #(0xE000*0x9000)&0xFFFF
    popw hl
    assert hl, #(0xE000*0x9000)>>16

    alloc 4
    pushw #0xBEEF
    pushw #0xC0DE
    call umult16
    dealloc 4
    popw hl
    assert hl, #(0xBEEF*0xC0DE)&0xFFFF
    popw hl
    assert hl, #(0xBEEF*0xC0DE)>>16

    alloc 4
    pushw #0xDEAD
    pushw #0x0002
    call umult16
    dealloc 4
    popw hl
    assert hl, #(0xDEAD*0x0002)&0xFFFF
    popw hl
    assert hl, #(0xDEAD*0x0002)>>16

    alloc 4
    pushw #0xF00F
    pushw #0xF00F
    call umult16
    dealloc 4
    popw hl
    assert hl, #(0xF00F*0xF00F)&0xFFFF
    popw hl
    assert hl, #(0xF00F*0xF00F)>>16

    halt


; includes
#include "../src/CPU.asm"
#include "../src/lib/lib_math.asm"

; global vars
#bank ram
STACK_BASE: #res 0