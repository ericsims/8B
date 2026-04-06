#once

;;
; @function
; @brief draw a set of points on screen
; @section description
;      _______________________
; -10 |    .param16_color     |
;  -9 |_______________________|
;  -8 |  .param16_list_ptr    |
;  -7 |_______________________|
;  -6 |___.param8_list_len____|
;  -5 |_____.param8_angle_____|
;  -4 |___________?___________| RESERVED
;  -3 |___________?___________|    .
;  -2 |___________?___________|    .
;  -1 |___________?___________| RESERVED
;
;;
#bank rom
draw_2d_points:
    .param16_color = -10
    .param16_list_ptr = -8
    .param8_list_len = -6
    .param8_angle = -5
    .init:
        __prologue
        
        loadw hl, (BP), .param16_list_ptr
        storew hl, point_list_ptr

        load a, (BP), .param8_list_len
        store a, point_list_len
    
    .compute_angle:
        load a, (BP), .param8_angle

        pushw #0 ; result
        push a ; angle
        call cos
        pop a ; preserve angle
        popw hl
        storew hl, cosx

        pushw #0 ; result
        push a ; angle
        call sin
        pop a
        popw hl
        storew hl, sinx
    
    .load_point:
        load a, point_list_len
        sub a, #1
        jmc .display_points
        store a, point_list_len

        loadw hl, point_list_ptr

        ; copy point from list to ram buffer
        load a, (hl)
        store a, point.x
        addw hl, #1
        load a, (hl)
        store a, point.x+1
        addw hl, #1
        load a, (hl)
        store a, point.y
        addw hl, #1
        load a, (hl)
        store a, point.y+1

        addw hl, #1
        storew hl, point_list_ptr
        
        ; invert y
        load a, point.y
        xor a, #0xFF
        store a, point.y
        load a, point.y+1
        xor a, #0xFF
        store a, point.y+1
        loadw hl, point.y
        addw hl, #1
        storew hl, point.y

    .rotate_x_point:
        ; x' = point.x * cos(theta) - point.y * sin(theta)
        
        ; point.x * cos(theta)
        alloc 4
        pushw point.x
        pushw cosx
        call mult16
        dealloc 5
        popw hl
        storew hl, temp1
        dealloc 1
        
        ; point.y * sin(theta)
        alloc 4
        pushw point.y
        pushw sinx
        call mult16
        dealloc 5
        popw hl
        storew hl, temp2
        dealloc 1

        ; invert point.y * sin(theta)
        load a, temp2
        xor a, #0xFF
        store a, temp2
        load a, temp2+1
        xor a, #0xFF
        store a, temp2+1
        loadw hl, temp2
        addw hl, #1
        storew hl, temp2

        ; sum
        load a, temp1
        load b, temp2
        add a, b ; msb
        store a, temp1
        
        loadw hl, temp1
        load a, temp2 + 1 ; lsb
        addw hl, a ; add lsb
        storew hl, point_t.x


    .rotate_y_point:
        ; x' = point.x * sin(theta) + point.y * cos(theta)
        
        ; point.x * sin(theta)
        alloc 4
        pushw point.x
        pushw sinx
        call mult16
        dealloc 5
        popw hl
        storew hl, temp1
        dealloc 1
        
        ; point.y * cos(theta)
        alloc 4
        pushw point.y
        pushw cosx
        call mult16
        dealloc 5
        popw hl
        storew hl, temp2
        dealloc 1

        ; sum
        load a, temp1
        load b, temp2
        add a, b ; msb
        store a, temp1
        
        loadw hl, temp1
        load a, temp2 + 1 ; lsb
        addw hl, a ; add lsb
        storew hl, point_t.y

    .push_point:
        ; center on screen
        loadw hl, point_t.x
        addw hl, #TFT_SCREEN_WIDTH/4 - 1
        addw hl, #TFT_SCREEN_WIDTH/4 - 1
        addw hl, #2
        pushw hl

        loadw hl, point_t.y
        addw hl, #TFT_SCREEN_HEIGHT/4
        addw hl, #TFT_SCREEN_HEIGHT/4
        pushw hl

        jmp .load_point

    .display_points:
        ; clear screen
        pushw #0x0000 ; x0
        pushw #0x0000 ; y0
        pushw #TFT_SCREEN_WIDTH ; x1
        pushw #TFT_SCREEN_HEIGHT ; y1
        pushw #COLOR65K_BLACK
        call ra8876_draw_sqaure_fill
        dealloc 10

        load a, (BP), .param8_list_len
        store a, point_list_len

    .draw_point:
        load a, point_list_len
        sub a, #1
        jmc .done
        store a, point_list_len

        popw hl
        storew hl, point_t.y
        popw hl
        storew hl, point_t.x

        ; draw point, with width 4px
        loadw hl, point_t.x 
        subw hl, #2
        pushw hl ; x0

        loadw hl, point_t.y
        subw hl, #2
        pushw hl ; y0

        loadw hl, point_t.x 
        addw hl, #2
        pushw hl ; x1

        loadw hl, point_t.y
        addw hl, #2
        pushw hl ; y1

        loadw hl, (BP), .param16_color
        pushw hl
        call ra8876_draw_sqaure_fill
        dealloc 10

        jmp .draw_point

    .done:
        __epilogue
        ret

#bank ram
point_list_ptr: #res 2
point_list_len: #res 1
point:
    .x: #res 2
    .y: #res 2
    .z: #res 2
point_t:
    .x: #res 2
    .y: #res 2
    .z: #res 2
sinx: #res 2
cosx: #res 2
temp1: #res 2
temp2: #res 2

#include "lib_math.asm"
#include "lib_math_trig.asm"