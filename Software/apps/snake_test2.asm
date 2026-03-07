; program entry
#ruledef
{
    __draw {x: i8} {y: i8} => asm
    {
    store #{x}, snake_pos_list
    store #{y}, snake_pos_list+1
    call draw_snake
    }
}

#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    ; play area 29 x 14
    call init_graphics

    call init_snake


    .loop:
        call draw_snake
        ..wait_for_char:
            call uart_getc
            test b
            jmz .loop ; loop if buffer is empty

        ..right:
            load a, b
            sub a, #"d"
            jnz ...next
            load a, snake_pos_list
            add a, #1
            store a, snake_pos_list
            jmp .loop
            ...next:
        ..left:
            load a, b
            sub a, #"a"
            jnz ...next
            load a, snake_pos_list
            sub a, #1
            store a, snake_pos_list
            jmp .loop
            ...next:
        ..up:
            load a, b
            sub a, #"w"
            jnz ...next
            load a, snake_pos_list+1
            sub a, #1
            store a, snake_pos_list+1
            jmp .loop
            ...next:
        ..down:
            load a, b
            sub a, #"s"
            jnz ...next
            load a, snake_pos_list+1
            add a, #1
            store a, snake_pos_list+1
            jmp .loop
            ...next:
        
        jmp .loop
    

    halt

init_graphics:
    call ra8876_init

    ; set active window
    pushw #0x0000 ; x
    pushw #0x0000 ; y
    pushw #TFT_SCREEN_WIDTH-1 ; width
    pushw #TFT_SCREEN_HEIGHT-1 ; height
    call ra8876_set_active_window_xywh
    dealloc 8

    ; clear screen
    pushw #0x0000 ; x0
    pushw #0x0000 ; y0
    pushw #TFT_SCREEN_WIDTH-1 ; x1
    pushw #TFT_SCREEN_HEIGHT-1 ; y1
    pushw #COLOR65K_BLACK
    call ra8876_draw_sqaure_fill
    dealloc 10

    .draw_border:
        ..border_width = 32
        ..bottom_margin = TFT_SCREEN_HEIGHT-32*(15+2) ; 15 rows playable
        pushw #(..border_width/2) ; x0
        pushw #(..border_width/2) ; y0
        pushw #(TFT_SCREEN_WIDTH-1-..border_width/2) ; x1
        pushw #(TFT_SCREEN_HEIGHT-1-..border_width/2-..bottom_margin) ; y1
        pushw #APP_COLOR_BORDER
        call ra8876_draw_sqaure
        dealloc 10
        
        pushw #(..border_width) ; x0
        pushw #(..border_width) ; y0
        pushw #(TFT_SCREEN_WIDTH-1-..border_width) ; x1
        pushw #(TFT_SCREEN_HEIGHT-1-..border_width-..bottom_margin) ; y1
        pushw #APP_COLOR_BORDER
        call ra8876_draw_sqaure
        dealloc 10

    ret

init_snake:
    ; set length to zero
    store #1, snake_len

    ; set an initial x,y sprite pos
    store #5, snake_pos_list
    store #5, snake_pos_list+1

    ret

draw_snake:
    load a, snake_pos_list

    ; compute x pixel cordinate
    load a, snake_pos_list
    add a, #1
    rshift a
    rshift a
    rshift a
    store a, cord_x
    
    load a, snake_pos_list
    add a, #1
    lshift a
    lshift a
    lshift a
    lshift a
    lshift a
    store a, cord_x+1

    ; compute y pixel cordinate
    load a, snake_pos_list+1
    add a, #1
    rshift a
    rshift a
    rshift a
    store a, cord_y
    
    load a, snake_pos_list+1
    add a, #1
    lshift a
    lshift a
    lshift a
    lshift a
    lshift a
    store a, cord_y+1

    ; draw sprite
    pushw cord_x ; x0
    pushw cord_y ; y0
    loadw hl, cord_x
    addw hl, #31
    pushw hl ; x1
    loadw hl, cord_y
    addw hl, #31
    pushw hl ; y1
    pushw #APP_COLOR_YELLOW
    call ra8876_draw_sqaure_fill
    dealloc 10


    ret

; constants
APP_COLOR_BORDER = 0x4669
APP_COLOR_YELLOW = 0xDE60

; includes
#include "../src/CPU.asm"
#include "../src/lib/char_utils.asm"
#include "../src/lib/lib_ra8876.asm"

; global vars
#bank ram
snake_len: #res 1
snake_pos_list: #res 512 ; list of x, y sprite cordinates

cord_x: #res 2 ; x cord in pixels
cord_y: #res 2 ; y cord in pixels


STACK_BASE: #res 0