; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:

    call ra8876_init
    assert b, #0

    pushw #0x0000 ; x
    pushw #0x0000 ; y
    pushw #TFT_SCREEN_WIDTH ; width
    pushw #TFT_SCREEN_HEIGHT ; height
    call ra8876_set_active_window_xywh
    dealloc 8

    pushw #0x0000 ; x
    pushw #0x0000 ; y
    pushw #64 ; width
    pushw #64 ; height
    pushw #img
    call ra8876_put_image_16bpp
    dealloc 10

    halt

; includes
#include "../src/CPU.asm"
#include "../src/lib/lib_ra8876.asm"

#bank rom
img: #d incbin("lenna_64_64_rgb565.img")

; global vars
#bank ram
STACK_BASE: #res 1024