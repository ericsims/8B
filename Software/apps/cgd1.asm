; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    call init_graphics


    store #5, iterations
    store #0x00, angle
    storew #0x0000, scale

    .loop:
    call draw_point

    ; incr scale
    loadw hl, scale
    addw hl, #0x2
    storew hl, scale

    ; incr angle
    load a, angle
    add a, #10
    store a, angle
    jnc .loop

    ; decr iter
    load a, iterations
    sub a, #1
    store a, iterations

    jnc .loop

    .done:

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
    ; rotate x
    pushw #0 ; result
    push angle
    call cos
    pop a
    popw hl
    storew hl, point.x
    
    ; rotate y
    pushw #0 ; result
    push angle
    call sin
    pop a
    popw hl
    storew hl, point.y

    ; scale x
    alloc 4
    pushw point.x
    pushw scale
    call mult16
    dealloc 5
    popw hl
    storew hl, point.x
    dealloc 1

    ; scale y
    alloc 4
    pushw point.y
    pushw scale
    call mult16
    dealloc 5
    popw hl
    storew hl, point.y
    dealloc 1


    ; draw in center of screen
    loadw hl, point.x 
    addw hl, #TFT_SCREEN_WIDTH/4 - 1
    addw hl, #TFT_SCREEN_WIDTH/4 +1 - 2
    pushw hl ; x0
    
    loadw hl, point.y
    addw hl, #TFT_SCREEN_HEIGHT/4
    addw hl, #TFT_SCREEN_HEIGHT/4 - 2
    pushw hl ; y0

    loadw hl, point.x
    addw hl, #TFT_SCREEN_WIDTH/4 - 1
    addw hl, #TFT_SCREEN_WIDTH/4 - 1
    addw hl, #2 + 2
    pushw hl ; x1
    
    loadw hl, point.y
    addw hl, #TFT_SCREEN_HEIGHT/4
    addw hl, #TFT_SCREEN_HEIGHT/4 + 2
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
#include "../src/lib/lib_math.asm"
#include "../src/lib/lib_math_trig.asm"

; global vars
#bank ram
point:
    .x: #res 2
    .y: #res 2
iterations: #res 1
angle: #res 1
scale: #res 2
STACK_BASE: #res 0