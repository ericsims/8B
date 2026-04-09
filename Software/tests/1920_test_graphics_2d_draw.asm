; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    call ra8876_init
    assert b, #0
    
    ; set active window
    pushw #0x0000 ; x
    pushw #0x0000 ; y
    pushw #TFT_SCREEN_WIDTH ; width
    pushw #TFT_SCREEN_HEIGHT ; height
    call ra8876_set_active_window_xywh
    dealloc 8

    store #0, angle

    .loop:
    pushw #APP_COLOR_GREEN
    pushw #face_list
    push #2
    push angle
    call draw_2d_points
    dealloc 6

    load a, angle
    add a, #5
    store a, angle

    jnc .loop

    halt

; constants
APP_COLOR_GREEN = 0x4669

; includes
#include "../src/CPU.asm"
#include "../src/lib/lib_ra8876.asm"
#include "../src/lib/lib_graphics.asm"

face_list:
#d16 0x0070, 0x0070, -0x0070, 0x0070, -0x0070, -0x0070
#d16 0x0070, 0x0070, 0x0070, -0x0070, -0x0070, -0x0070


; global vars
#bank ram
angle: #res 1
STACK_BASE: #res 1024