; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    call init_graphics
    

    store #0x01, angle
    call draw_point

    halt

init_graphics:
    call ra8876_init

    ; set active window
    pushw #0x0000 ; x
    pushw #0x0000 ; y
    pushw #TFT_SCREEN_WIDTH ; width
    pushw #TFT_SCREEN_HEIGHT ; height
    call ra8876_set_active_window_xywh
    dealloc 8

    ; clear screen
    pushw #0x0000 ; x0
    pushw #0x0000 ; y0
    pushw #TFT_SCREEN_WIDTH ; x1
    pushw #TFT_SCREEN_HEIGHT ; y1
    pushw #COLOR65K_BLACK
    call ra8876_draw_sqaure_fill
    dealloc 10

    ret

draw_point:
    pushw #0 ; result
    push angle
    call cos
    pop a
    popw hl
    storew hl, point.x

    
    pushw #0 ; result
    push angle
    call sin
    pop a
    popw hl
    storew hl, point.y

    ; clear screen
    pushw point.x ; x0
    pushw point.y ; y0
    loadw hl, point.x
    addw hl, #5
    pushw hl ; x1
    loadw hl, point.y
    addw hl, #5
    pushw hl ; y1
    pushw #APP_COLOR_GREEN
    call ra8876_draw_sqaure_fill
    dealloc 10

    ret


; constants
APP_COLOR_GREEN = 0x4669
APP_COLOR_YELLOW = 0xDE60

; includes
#include "../src/CPU.asm"
#include "../src/lib/char_utils.asm"
#include "../src/lib/lib_ra8876.asm"
#include "../src/lib/lib_math_trig.asm"

; global vars
#bank ram
point:
    .x: #res 2
    .y: #res 2
angle: #res 1
STACK_BASE: #res 0