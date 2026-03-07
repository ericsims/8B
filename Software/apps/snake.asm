; program entry
#ruledef
{
    __draw {x: i8} {y: i8} => asm
    {
    store #{x}, snake_ring_buf
    store #{y}, snake_ring_buf+1
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

        ..check_for_char:
            call uart_getc
            test b
            jmz .loop ; loop if buffer is empty

        ..right:
            load a, b
            sub a, #"d"
            jnz ...next
            store #0, snake_heading
            jmp .loop
            ...next:
        ..left:
            load a, b
            sub a, #"a"
            jnz ...next
            store #2, snake_heading
            jmp .loop
            ...next:
        ..up:
            load a, b
            sub a, #"w"
            jnz ...next
            store #1, snake_heading
            jmp .loop
            ...next:
        ..down:
            load a, b
            sub a, #"s"
            jnz ...next
            store #3, snake_heading
            jmp .loop
            ...next:
        ..advance:
            load a, b
            sub a, #" "
            jnz ...next
            call advance_snake
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
    ; set length
    store #3, snake_len

    ; init head pointer
    store #3<<1, snake_ring_start

    ; init snake direction
    store #0, snake_heading

    ; set an initial x,y sprite pos
    store #4, snake_ring_buf
    store #5, snake_ring_buf+1
    
    store #5, snake_ring_buf+2
    store #5, snake_ring_buf+2+1
    
    store #6, snake_ring_buf+4
    store #5, snake_ring_buf+4+1

    store #7, snake_ring_buf+6
    store #5, snake_ring_buf+6+1

    ret

advance_snake:
    ; load x and y
    ; halt
    loadw hl, #snake_ring_buf
    load b, snake_ring_start
    addw hl, b
    load a, (hl) ; x
    push a
    addw hl, #1
    load a, (hl) ; y
    push a

    add b, #2
    store b, snake_ring_start

    load a, snake_heading
    sub a, #1
    jmc .heading_right; heading = 0
    sub a, #1
    jmc .heading_up; heading = 1
    sub a, #1
    jmc .heading_left; heading = 2
    sub a, #1
    jmc .heading_down; heading = 3

    .heading_right:
        loadw hl, #snake_ring_buf
        addw hl, b
        addw hl, #1
        pop a
        store a, (hl) ; y
        subw hl, #1
        pop a
        add a, #1 ; move to the right
        store a, (hl) ; x
        ret

    .heading_up:
        loadw hl, #snake_ring_buf
        addw hl, b
        addw hl, #1
        pop a
        sub a, #1 ; move up
        store a, (hl) ; y
        subw hl, #1
        pop a
        store a, (hl) ; x
        ret

    .heading_left:
        loadw hl, #snake_ring_buf
        addw hl, b
        addw hl, #1
        pop a
        store a, (hl) ; y
        subw hl, #1
        pop a
        sub a, #1 ; move left
        store a, (hl) ; x
        ret
        
    .heading_down:
        loadw hl, #snake_ring_buf
        addw hl, b
        addw hl, #1
        pop a
        add a, #1 ; move down
        store a, (hl) ; y
        subw hl, #1
        pop a
        store a, (hl) ; x
        ret
        

draw_snake:
    loadw hl, #snake_ring_buf
    load a, snake_ring_start
    addw hl, a
    loadw hl, (hl)
    storew hl, snake_chunk

    storew #APP_COLOR_YELLOW, snake_chunk.color
    call draw_chunk ; draw new head


    loadw hl, #snake_ring_buf
    load a, snake_ring_start
    load b, snake_len
    lshift b ; two bytes per chunk
    sub a, b
    addw hl, a
    loadw hl, (hl)
    storew hl, snake_chunk

    storew #COLOR65K_BLACK, snake_chunk.color
    call draw_chunk ; erase old tail
    ret

draw_chunk:
    load a, snake_chunk.x

    ; compute x pixel cordinate
    load a, snake_chunk.x
    add a, #1
    rshift a
    rshift a
    rshift a
    store a, cord_x
    
    load a, snake_chunk.x
    add a, #1
    lshift a
    lshift a
    lshift a
    lshift a
    lshift a
    store a, cord_x+1

    ; compute y pixel cordinate
    load a, snake_chunk.y
    add a, #1
    rshift a
    rshift a
    rshift a
    store a, cord_y
    
    load a, snake_chunk.y
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
    pushw snake_chunk.color
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
snake_heading: #res 1 ; direction of snake 0 = right, 1 = up, 2 = left, 3 = down
snake_ring_start: #res 1 ; position head of snake in snake_ring_buf
snake_chunk: ;  x, y cordinates of next chunk to draw
    .x: #res 1
    .y: #res 1
    .color: #res 2
#align 256*8
snake_ring_buf: #res 256 ; list of x, y sprite cordinates

cord_x: #res 2 ; x cord in pixels
cord_y: #res 2 ; y cord in pixels


STACK_BASE: #res 0