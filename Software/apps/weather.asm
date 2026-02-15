; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    call init_graphics

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

    call draw_header_border1
    call draw_header_border2
    call draw_footer_border1
    call draw_footer_border2

    call draw_header_text

    ret

draw_header_border1:
    .local8_paste_count = 0
    .local16_x0 = 1
    .local16_y0 = 3
    .local16_x1 = 5
    .local16_y1 = 7
    .local16_color = 9
        .init:
        __prologue
        push #(TFT_SCREEN_WIDTH/BORDER_PIXEL_WIDTH)-1 ; paste count

        pushw #1 ; x0
        pushw #1 ; y0
        pushw #(BORDER_PIXEL_WIDTH-2) ; x1
        pushw #(BORDER_PIXEL_HEIGHT-2) ; y1
        pushw #APP_COLOR_GREEN

    .draw_dots:
        call ra8876_draw_sqaure_fill

        load a, (BP), .local8_paste_count
        sub a, #1
        jmc .done
        store a, (BP), .local8_paste_count

        loadw hl, (BP), .local16_x0
        addw hl, #BORDER_PIXEL_WIDTH
        storew hl, (BP), .local16_x0
        
        loadw hl, (BP), .local16_x1
        addw hl, #BORDER_PIXEL_WIDTH
        storew hl, (BP), .local16_x1

        jmp .draw_dots

    .done:
        dealloc 11
        __epilogue
        ret

draw_header_border2:
    __prologue
    push #(TFT_SCREEN_WIDTH/BORDER_PIXEL_WIDTH)-1 ; paste count

    pushw #1 ; x0
    pushw #(9*BORDER_PIXEL_HEIGHT+1) ; y0
    pushw #(BORDER_PIXEL_WIDTH-2) ; x1
    pushw #(9*BORDER_PIXEL_HEIGHT+BORDER_PIXEL_HEIGHT-2) ; y1
    pushw #APP_COLOR_YELLOW

    jmp draw_header_border1.draw_dots ; carefully reusing the rest of the draw dot label!


draw_header_text:
    ; TODO: actual text of course
    pushw #(15*BORDER_PIXEL_WIDTH) ; x0
    pushw #(3*BORDER_PIXEL_HEIGHT) ; y0
    pushw #(15*BORDER_PIXEL_HEIGHT+16-1) ; x1
    pushw #(3*BORDER_PIXEL_HEIGHT+32-1) ; y1
    pushw #APP_COLOR_GREEN
    call ra8876_draw_sqaure_fill
    dealloc 10

    ret

draw_footer_border1:
    __prologue
    push #(TFT_SCREEN_WIDTH/BORDER_PIXEL_WIDTH)-1 ; paste count

    pushw #1 ; x0
    pushw #(67*BORDER_PIXEL_HEIGHT+1) ; y0
    pushw #(BORDER_PIXEL_WIDTH-2) ; x1
    pushw #(67*BORDER_PIXEL_HEIGHT+BORDER_PIXEL_HEIGHT-2) ; y1
    pushw #APP_COLOR_GREEN

    jmp draw_header_border1.draw_dots ; carefully reusing the rest of the draw dot label!

draw_footer_border2:
    __prologue
    push #(TFT_SCREEN_WIDTH/BORDER_PIXEL_WIDTH)-1 ; paste count

    pushw #1 ; x0
    pushw #(74*BORDER_PIXEL_HEIGHT+1) ; y0
    pushw #(BORDER_PIXEL_WIDTH-2) ; x1
    pushw #(74*BORDER_PIXEL_HEIGHT+BORDER_PIXEL_HEIGHT-2) ; y1
    pushw #APP_COLOR_YELLOW

    jmp draw_header_border1.draw_dots ; carefully reusing the rest of the draw dot label!

; draw_border4:
;     __prologue
;     push #10 ; paste count

;     pushw #(50*BORDER_PIXEL_WIDTH+1) ; x0
;     pushw #(20*BORDER_PIXEL_HEIGHT+1) ; y0
;     pushw #(50*BORDER_PIXEL_WIDTH+BORDER_PIXEL_WIDTH-2) ; x1
;     pushw #(20*BORDER_PIXEL_HEIGHT+BORDER_PIXEL_HEIGHT-2) ; y1
;     pushw #APP_COLOR_YELLOW

;     jmp draw_header_border1.draw_dots ; carefully reusing the rest of the draw dot label!

; constants
APP_COLOR_GREEN = 0x4669
APP_COLOR_YELLOW = 0xDE60
BORDER_PIXEL_WIDTH = 8
BORDER_PIXEL_HEIGHT = 8

; includes
#include "../src/CPU.asm"
#include "../src/lib/char_utils.asm"
#include "../src/lib/lib_ra8876.asm"

; global vars
#bank ram
STACK_BASE: #res 0