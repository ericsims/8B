; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

test:
    alloc 4 ; res
    pushw #0x0000 ; x
    pushw #0x0000 ; y
    call mult16
    dealloc 4 ; x,y
    popw hl
    assert hl, #0x0000
    popw hl
    assert hl, #0x0000

    alloc 4
    pushw #0x7FFF
    pushw #0x7FFF
    call mult16
    dealloc 4
    popw hl
    assert hl, #(0x7FFF*0x7FFF)&0xFFFF
    popw hl
    assert hl, #(0x7FFF*0x7FFF)>>16

    alloc 4
    pushw #-32768
    pushw #-32768
    call mult16
    dealloc 4
    popw hl
    assert hl, #(-32768*-32768)&0xFFFF
    popw hl
    assert hl, #(-32768*-32768)>>16

    alloc 4
    pushw #-32768
    pushw #32767
    call mult16
    dealloc 4
    popw hl
    assert hl, #(-32768*32767)&0xFFFF
    popw hl
    assert hl, #(-32768*32767)>>16

    alloc 4
    pushw #32767
    pushw #-32768
    call mult16
    dealloc 4
    popw hl
    assert hl, #(32767*-32768)&0xFFFF
    popw hl
    assert hl, #(32767*-32768)>>16

    alloc 4
    pushw #-1
    pushw #-1
    call mult16
    dealloc 4
    popw hl
    assert hl, #(-1*-1)&0xFFFF
    popw hl
    assert hl, #(-1*-1)>>16

    alloc 4
    pushw #-1
    pushw #32767
    call mult16
    dealloc 4
    popw hl
    assert hl, #(-1*32767)&0xFFFF
    popw hl
    assert hl, #(-1*32767)>>16

    alloc 4
    pushw #-1
    pushw #-32768
    call mult16
    dealloc 4
    popw hl
    assert hl, #(-1*-32768)&0xFFFF
    popw hl
    assert hl, #(-1*-32768)>>16

    alloc 4
    pushw #12345
    pushw #-23456
    call mult16
    dealloc 4
    popw hl
    assert hl, #(12345*-23456)&0xFFFF
    popw hl
    assert hl, #(12345*-23456)>>16

    alloc 4
    pushw #-22222
    pushw #11111
    call mult16
    dealloc 4
    popw hl
    assert hl, #(-22222*11111)&0xFFFF
    popw hl
    assert hl, #(-22222*11111)>>16

    alloc 4
    pushw #30000
    pushw #30000
    call mult16
    dealloc 4
    popw hl
    assert hl, #(30000*30000)&0xFFFF
    popw hl
    assert hl, #(30000*30000)>>16

    alloc 4
    pushw #-30000
    pushw #-30000
    call mult16
    dealloc 4
    popw hl
    assert hl, #(-30000*-30000)&0xFFFF
    popw hl
    assert hl, #(-30000*-30000)>>16

    alloc 4
    pushw #-30000
    pushw #30000
    call mult16
    dealloc 4
    popw hl
    assert hl, #(-30000*30000)&0xFFFF
    popw hl
    assert hl, #(-30000*30000)>>16

    alloc 4
    pushw #16384
    pushw #-2
    call mult16
    dealloc 4
    popw hl
    assert hl, #(16384*-2)&0xFFFF
    popw hl
    assert hl, #(16384*-2)>>16

    alloc 4
    pushw #-16384
    pushw #2
    call mult16
    dealloc 4
    popw hl
    assert hl, #(-16384*2)&0xFFFF
    popw hl
    assert hl, #(-16384*2)>>16

    alloc 4
    pushw #0x4000
    pushw #0x4000
    call mult16
    dealloc 4
    popw hl
    assert hl, #(0x4000*0x4000)&0xFFFF
    popw hl
    assert hl, #(0x4000*0x4000)>>16

    alloc 4
    pushw #0x8000
    pushw #-1
    call mult16
    dealloc 4
    popw hl
    assert hl, #(0x8000)&0xFFFF
    popw hl
    assert hl, #(0x8000)>>16

    alloc 4
    pushw #-1234
    pushw #-5678
    call mult16
    dealloc 4
    popw hl
    assert hl, #(-1234*-5678)&0xFFFF
    popw hl
    assert hl, #(-1234*-5678)>>16

    alloc 4
    pushw #4321
    pushw #-8765
    call mult16
    dealloc 4
    popw hl
    assert hl, #(4321*-8765)&0xFFFF
    popw hl
    assert hl, #(4321*-8765)>>16

    alloc 4
    pushw #-2222
    pushw #3333
    call mult16
    dealloc 4
    popw hl
    assert hl, #(-2222*3333)&0xFFFF
    popw hl
    assert hl, #(-2222*3333)>>16

    alloc 4
    pushw #1111
    pushw #-4444
    call mult16
    dealloc 4
    popw hl
    assert hl, #(1111*-4444)&0xFFFF
    popw hl
    assert hl, #(1111*-4444)>>16

    alloc 4
    pushw #-32768
    pushw #1
    call mult16
    dealloc 4
    popw hl
    assert hl, #(-32768*1)&0xFFFF
    popw hl
    assert hl, #(-32768*1)>>16

    alloc 4
    pushw #32767
    pushw #1
    call mult16
    dealloc 4
    popw hl
    assert hl, #(32767*1)&0xFFFF
    popw hl
    assert hl, #(32767*1)>>16

    alloc 4
    pushw #-15
    pushw #-15
    call mult16
    dealloc 4
    popw hl
    assert hl, #(-15*-15)&0xFFFF
    popw hl
    assert hl, #(-15*-15)>>16

    alloc 4
    pushw #15
    pushw #-15
    call mult16
    dealloc 4
    popw hl
    assert hl, #(15*-15)&0xFFFF
    popw hl
    assert hl, #(15*-15)>>16

    alloc 4
    pushw #-256
    pushw #256
    call mult16
    dealloc 4
    popw hl
    assert hl, #(-256*256)&0xFFFF
    popw hl
    assert hl, #(-256*256)>>16

    alloc 4
    pushw #1024
    pushw #-1024
    call mult16
    dealloc 4
    popw hl
    assert hl, #(1024*-1024)&0xFFFF
    popw hl
    assert hl, #(1024*-1024)>>16

    alloc 4
    pushw #-8192
    pushw #-4
    call mult16
    dealloc 4
    popw hl
    assert hl, #(-8192*-4)&0xFFFF
    popw hl
    assert hl, #(-8192*-4)>>16

    alloc 4
    pushw #8192
    pushw #-4
    call mult16
    dealloc 4
    popw hl
    assert hl, #(8192*-4)&0xFFFF
    popw hl
    assert hl, #(8192*-4)>>16

    alloc 4
    pushw #-500
    pushw #500
    call mult16
    dealloc 4
    popw hl
    assert hl, #(-500*500)&0xFFFF
    popw hl
    assert hl, #(-500*500)>>16

    alloc 4
    pushw #123
    pushw #456
    call mult16
    dealloc 4
    popw hl
    assert hl, #(123*456)&0xFFFF
    popw hl
    assert hl, #(123*456)>>16

    alloc 4
    pushw #-123
    pushw #456
    call mult16
    dealloc 4
    popw hl
    assert hl, #(-123*456)&0xFFFF
    popw hl
    assert hl, #(-123*456)>>16

    alloc 4
    pushw #123
    pushw #-456
    call mult16
    dealloc 4
    popw hl
    assert hl, #(123*-456)&0xFFFF
    popw hl
    assert hl, #(123*-456)>>16

    alloc 4
    pushw #-123
    pushw #-456
    call mult16
    dealloc 4
    popw hl
    assert hl, #(-123*-456)&0xFFFF
    popw hl
    assert hl, #(-123*-456)>>16

    alloc 4
    pushw #25000
    pushw #-12345
    call mult16
    dealloc 4
    popw hl
    assert hl, #(25000*-12345)&0xFFFF
    popw hl
    assert hl, #(25000*-12345)>>16

    alloc 4
    pushw #-25000
    pushw #12345
    call mult16
    dealloc 4
    popw hl
    assert hl, #(-25000*12345)&0xFFFF
    popw hl
    assert hl, #(-25000*12345)>>16

    alloc 4
    pushw #300
    pushw #300
    call mult16
    dealloc 4
    popw hl
    assert hl, #(300*300)&0xFFFF
    popw hl
    assert hl, #(300*300)>>16

    alloc 4
    pushw #-300
    pushw #-300
    call mult16
    dealloc 4
    popw hl
    assert hl, #(-300*-300)&0xFFFF
    popw hl
    assert hl, #(-300*-300)>>16

    alloc 4
    pushw #-300
    pushw #300
    call mult16
    dealloc 4
    popw hl
    assert hl, #(-300*300)&0xFFFF
    popw hl
    assert hl, #(-300*300)>>16

    alloc 4
    pushw #0x7FFF
    pushw #-1
    call mult16
    dealloc 4
    popw hl
    assert hl, #(0x7FFF*-1)&0xFFFF
    popw hl
    assert hl, #(0x7FFF*-1)>>16

    alloc 4
    pushw #-32768
    pushw #-1
    call mult16
    dealloc 4
    popw hl
    assert hl, #(-32768*-1)&0xFFFF
    popw hl
    assert hl, #(-32768*-1)>>16

    halt


; includes
#include "../src/CPU.asm"
#include "../src/lib/lib_math.asm"

; global vars
#bank ram
STACK_BASE: #res 0