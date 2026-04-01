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
    call draw_footer_text

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
    pushw #(8*BORDER_PIXEL_HEIGHT+1) ; y0
    pushw #(BORDER_PIXEL_WIDTH-2) ; x1
    pushw #(8*BORDER_PIXEL_HEIGHT+BORDER_PIXEL_HEIGHT-2) ; y1
    pushw #APP_COLOR_YELLOW

    jmp draw_header_border1.draw_dots ; carefully reusing the rest of the draw dot label!


draw_header_text:
    pushw #(48*BORDER_PIXEL_WIDTH)
    pushw #(3*BORDER_PIXEL_HEIGHT)
    call ra8876_set_text_cursor_pos
    dealloc 4

    pushw #APP_COLOR_GREEN
    call ra8876_set_foreground_color_16bpp
    dealloc 2
    
    call ra8876_enable_text_mode
    call ra8876_text_chroma_key_enable
    call ra8876_set_text_size_32

    pushw #.header_text
    call ra8876_put_string
    dealloc 2

    call ra8876_enable_graphics_mode

    ret
    .header_text: #d "WEATHER REPORT\0"

draw_footer_border1:
    __prologue
    push #(TFT_SCREEN_WIDTH/BORDER_PIXEL_WIDTH)-1 ; paste count

    pushw #1 ; x0
    pushw #(68*BORDER_PIXEL_HEIGHT+1) ; y0
    pushw #(BORDER_PIXEL_WIDTH-2) ; x1
    pushw #(68*BORDER_PIXEL_HEIGHT+BORDER_PIXEL_HEIGHT-2) ; y1
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

draw_footer_text:
    pushw #(20*BORDER_PIXEL_WIDTH)
    pushw #(70*BORDER_PIXEL_HEIGHT)
    call ra8876_set_text_cursor_pos
    dealloc 4

    pushw #APP_COLOR_GREEN
    call ra8876_set_foreground_color_16bpp
    dealloc 2
    
    call ra8876_enable_text_mode
    call ra8876_text_chroma_key_enable
    call ra8876_set_text_size_24
    
    pushw #.footer_text
    call ra8876_put_string
    dealloc 2

    call ra8876_enable_graphics_mode

    ret
    .footer_text: #d "Footer text goes here...\0"

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