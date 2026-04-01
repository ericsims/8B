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

    
    ; fill background color
    pushw #0x0000 ; x
    pushw #0x0000 ; y
    pushw #TFT_SCREEN_WIDTH ; width
    pushw #TFT_SCREEN_HEIGHT ; height
    pushw #COLOR65K_GRAYSCALE10
    call ra8876_draw_sqaure_fill
    dealloc 10


    call ra8876_enable_text_mode

    
    pushw #COLOR65K_GRAYSCALE1
    call ra8876_set_background_color_16bpp
    dealloc 2

    pushw #COLOR65K_LIGHTGREEN
    call ra8876_set_foreground_color_16bpp
    dealloc 2
    
    pushw #15
    pushw #5
    call ra8876_set_text_cursor_pos
    dealloc 4
    
    store #RA8876_MRWDP, RA8876_ADDR ; ram access
    store #"a", RA8876_DATA
    store #"b", RA8876_DATA

    halt

; includes
#include "../src/CPU.asm"
#include "../src/lib/lib_ra8876.asm"

; global vars
#bank ram
STACK_BASE: #res 1024