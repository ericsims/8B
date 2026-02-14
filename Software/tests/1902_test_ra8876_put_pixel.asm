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

    pushw #0x0012 ; x
    pushw #0x0034 ; y
    pushw #COLOR65K_LIGHTMAGENTA ; color
    call ra8876_put_pixel_16bpp
    dealloc 6

    halt

; includes
#include "../src/CPU.asm"
#include "../src/lib/lib_ra8876.asm"

; global vars
#bank ram
STACK_BASE: #res 1024