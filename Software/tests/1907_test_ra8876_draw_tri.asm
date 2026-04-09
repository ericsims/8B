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

    pushw #0x0010 ; x0
    pushw #0x0020 ; y0
    pushw #0x0030 ; x1
    pushw #0x0060 ; y1
    pushw #0x0070 ; x2
    pushw #0x0090 ; y2
    pushw #COLOR65K_RED
    call ra8876_draw_triangle_fill
    dealloc 14


    pushw #0x0050 ; x0
    pushw #0x0010 ; y0
    pushw #0x0090 ; x1
    pushw #0x0010 ; y1
    pushw #0x0060 ; x2
    pushw #0x0040 ; y2
    pushw #COLOR65K_BLUE
    call ra8876_draw_triangle
    dealloc 14

    halt

; includes
#include "../src/CPU.asm"
#include "../src/lib/lib_ra8876.asm"

; global vars
#bank ram
STACK_BASE: #res 1024